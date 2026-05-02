# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
@tool
class_name NodeCamera2DExecutionScope extends Object


#region Constants
enum QUEUE_TYPE {
	EFFECT,
	TRANSITION
}
#endregion


#region Private Variables
# 		Context
var _host_context : NodeCamera2DHostContext

# 		Layer Management
# Dictionary[int priority, Array[LayerRecord]]
var _effect_buckets : Dictionary[int, Array] = {}
var _effect_priorities : Array[int] = []
var _effect_list: Array[LayerRecord] = []

# Dictionary[int priority, Array[LayerRecord]]
var _transition_buckets : Dictionary[int, Array] = {}
var _transition_priorities : Array[int] = []
var _transition_list: Array[LayerRecord] = []

var _record_by_layer: Dictionary[NodeCamera2DLayer, LayerRecord] = {}

# 		Dirty Cleanup
var _dirty_flags : int
# NodeCamera2DLayer -> int flags
var _pending_dirty_layers : Dictionary[NodeCamera2DLayer, int] = {}
var _pending_dirty_stage_layers : Dictionary[NodeCamera2DStaged, NodeCamera2DConstants.LAYER_STAGES] = {}
#endregion



#region Virtual Methods (Engine)
func _init(ctx : NodeCamera2DHostContext) -> void:
	_host_context = ctx

func _notification(what: int) -> void:
	match what:
		NOTIFICATION_PREDELETE:
			_free_runtime_queue()
#endregion


#region Bucket Priority Helpers
func _insert_priority_sorted(priorities: Array[int], priority: int) -> void:
	var idx := priorities.bsearch(priority)
	if idx < priorities.size() && priorities[idx] == priority:
		return
	priorities.insert(idx, priority)

func _insert_record_into_bucket(record: LayerRecord) -> void:
	var buckets : Dictionary
	var priorities : Array[int]

	if record.queue_kind == QUEUE_TYPE.EFFECT:
		buckets = _effect_buckets
		priorities = _effect_priorities
	else:
		buckets = _transition_buckets
		priorities = _transition_priorities

	var priority := record.priority
	if !buckets.has(priority):
		buckets[priority] = []
		_insert_priority_sorted(priorities, priority)

	# Array[LayerRecord]
	var bucket: Array = buckets[priority]
	bucket.append(record)

func _remove_record_from_bucket(record: LayerRecord) -> void:
	var buckets : Dictionary
	var priorities : Array[int]

	if record.queue_kind == QUEUE_TYPE.EFFECT:
		buckets = _effect_buckets
		priorities = _effect_priorities
	else:
		buckets = _transition_buckets
		priorities = _transition_priorities

	var priority := record.priority
	if !buckets.has(priority):
		return
	
	# Array[LayerRecord]
	var bucket: Array = buckets[priority]
	bucket.erase(record)

	if bucket.is_empty():
		buckets.erase(priority)
		priorities.erase(priority)

func _rebuild_flat_lists() -> void:
	_effect_list.clear()
	for priority in _effect_priorities:
		# Array[LayerRecord]
		var bucket: Array = _effect_buckets[priority]
		_effect_list.append_array(bucket)

	_transition_list.clear()
	for priority in _transition_priorities:
		# Array[LayerRecord]
		var bucket: Array = _transition_buckets[priority]
		_transition_list.append_array(bucket)
#endregion


#region Layer Management Methods
func _get_queue_kind(layer: NodeCamera2DLayer) -> QUEUE_TYPE:
	if layer is NodeCamera2DEffect:
		return QUEUE_TYPE.EFFECT
	elif layer is NodeCamera2DTransition:
		return QUEUE_TYPE.TRANSITION
	return -1


func _free_runtime_queue() -> void:
	for record: LayerRecord in _record_by_layer.values():
		record.free()
func _clear_context() -> void:
	_effect_buckets.clear()
	_effect_priorities.clear()
	_effect_list.clear()
	
	_transition_buckets.clear()
	_transition_priorities.clear()
	_transition_list.clear()
	
	_free_runtime_queue()
	_record_by_layer.clear()


func _rebuild_runtime_queue(top_layers : Array[NodeCamera2DLayer]) -> void:
	_clear_context()

	var mask := _host_context.get_mask()
	for layer : NodeCamera2DLayer in top_layers:
		if !(layer.camera_mask & mask):
			continue
		_add_layer(layer)

	_rebuild_flat_lists()


func _add_layer(layer: NodeCamera2DLayer) -> void:
	if layer.disabled:
		return
	var kind := _get_queue_kind(layer)
	if kind == -1:
		return
	
	var record : LayerRecord
	if layer is NodeCamera2DStaged:
		record = StagedLayerRecord.new()
		record.layer = layer
		record.queue_kind = kind
		record.priority = layer.priority
		record.stage = NodeCamera2DConstants.LAYER_STAGES.STARTING
		
		record.stage_changed_mask = _get_stage_mask(layer.get_needed_change_stages())
		record.stage_process_mask  = _get_stage_mask(layer.get_needed_process_stages())
		
		_host_context.sync_stage(layer, record, self, true, false)
		if record.stage == NodeCamera2DConstants.LAYER_STAGES.HAULTED:
			record.free()
			return
	elif layer is NodeCamera2DMulti:
		record = MultiLayerRecord.new()
		record.layer = layer
		record.priority = layer.priority
		record.scope = NodeCamera2DExecutionScope.new(_host_context)
	
	_record_by_layer[layer] = record
	_insert_record_into_bucket(record)
func _remove_layer(layer: NodeCamera2DLayer) -> void:
	var record: LayerRecord = _record_by_layer.get(layer, null)
	if record == null:
		return
	
	_remove_record_from_bucket(record)
	_record_by_layer.erase(layer)
	record.free()
func _reorder_layer(layer: NodeCamera2DLayer) -> void:
	var record: LayerRecord = _record_by_layer.get(layer)
	var new_priority := layer.priority
	if record.priority == new_priority:
		return

	_remove_record_from_bucket(record)
	record.priority = new_priority
	_insert_record_into_bucket(record)
#endregion


#region Priority Dirty Flag Methods
func flag_structure_changed() -> void:
	_queue_flag_handle()
	_dirty_flags |= NodeCamera2DConstants.DIRTY_FLAGS.STRUCTURE_CHANGED
func flag_clear_layers() -> void:
	_queue_flag_handle()
	_dirty_flags |= NodeCamera2DConstants.DIRTY_FLAGS.CLEAR_LAYERS

func flag_layer_remove(layer : NodeCamera2DLayer) -> void:
	_mark_layer_op(layer, NodeCamera2DConstants.DIRTY_FLAGS.LAYER_REMOVE)
func flag_layer_reorder(layer : NodeCamera2DLayer) -> void:
	_mark_layer_op(layer, NodeCamera2DConstants.DIRTY_FLAGS.LAYER_REORDER)
func flag_layer_add(layer : NodeCamera2DLayer) -> void:
	_mark_layer_op(layer, NodeCamera2DConstants.DIRTY_FLAGS.LAYER_ADD)
func flag_layer_stage_advance(layer : NodeCamera2DStaged) -> void:
	_mark_layer_op(layer, NodeCamera2DConstants.DIRTY_FLAGS.LAYER_STAGE_CHANGED)
func _mark_layer_op(layer: NodeCamera2DLayer, op: int) -> void:
	if _host_context.is_disabled():
		return
	_queue_flag_handle()
	_pending_dirty_layers[layer] = _pending_dirty_layers.get(layer, 0) | op
	_dirty_flags |= op

func flag_layer_direct_stage_change(
	layer : NodeCamera2DStaged, stage : NodeCamera2DConstants.LAYER_STAGES
) -> void:
	if _host_context.is_disabled():
		return
	_queue_flag_handle()
	_pending_dirty_stage_layers[layer] = stage
	_dirty_flags |= NodeCamera2DConstants.DIRTY_FLAGS.LAYER_STAGE_CHANGED

func _queue_flag_handle() -> void:
	if _dirty_flags > 0:
		return
	_handle_flags.call_deferred()
func _handle_flags() -> void:
	if (_dirty_flags & NodeCamera2DConstants.DIRTY_FLAGS.CLEAR_LAYERS):
		_clear_context()
	elif (_dirty_flags & NodeCamera2DConstants.DIRTY_FLAGS.STRUCTURE_CHANGED):
		_rebuild_runtime_queue(NodeCamera2DManager.get_top_level_layers())
	else:
		var rebuild_needed : bool = false
		
		for layer: NodeCamera2DLayer in _pending_dirty_layers.keys():
			var op: int = _pending_dirty_layers[layer]
			if op & NodeCamera2DConstants.DIRTY_FLAGS.LAYER_REMOVE:
				_remove_layer(layer)
				rebuild_needed = true
				continue
			if op & NodeCamera2DConstants.DIRTY_FLAGS.LAYER_REORDER:
				_reorder_layer(layer)
				rebuild_needed = true
				continue
			if op & NodeCamera2DConstants.DIRTY_FLAGS.LAYER_ADD:
				_add_layer(layer)
				rebuild_needed = true
				continue
			if op & NodeCamera2DConstants.DIRTY_FLAGS.LAYER_STAGE_CHANGED:
				var record := _record_by_layer[layer]
				record.stage >>= 0
				_host_context.sync_stage(
					layer, record, self, true
				)
		
		for layer: NodeCamera2DStaged in _pending_dirty_stage_layers.keys():
			_host_context.set_layer_to_stage(
				layer, _record_by_layer[layer as NodeCamera2DLayer], self,
				_pending_dirty_stage_layers[layer]
			)
		
		if rebuild_needed:
			_rebuild_flat_lists()

	_pending_dirty_layers.clear()
	_pending_dirty_stage_layers.clear()
	_dirty_flags = 0
#endregion


#region Tick Methods
func run_effects(target : NodeCameraState) -> void:
	for record : LayerRecord in _effect_list:
		record.layer._scope = self
		record.layer.process_effect(target, record.stage)
func run_transitions(
	target : NodeCameraState, current : NodeCameraState
) -> void:
	for record : LayerRecord in _transition_list:
		record.layer._scope = self
		record.layer.process_transition(target, current, record.stage)
#endregion


#region Accessor Methods
func effects_empty() -> bool:
	return _effect_list.is_empty()
func transitions_empty() -> bool:
	return _transition_list.is_empty()
#endregion


#region Helper Methods
func _get_stage_mask(stages : PackedInt32Array) -> int:
	var mask : int = 0
	for stage : int in stages:
		mask |= stage
	return mask
#endregion


# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
