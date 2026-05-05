# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
@tool
class_name NodeCameraExecutionScope extends Object

#region Enums
enum DIRTY_FLAGS {
	STRUCTURE_CHANGED		= 1 << 0,
	STRUCTURE_CLEARED		= 1 << 1,
	REMOVE_LAYER			= 1 << 2,
	REORDER_LAYER			= 1 << 3,
	ADD_LAYER				= 1 << 4,
	STAGE_CHANGED			= 1 << 5,
	MULTI_TICK_MASK_CHANGED	= 1 << 6
}

enum LAYER_STAGES {
	HAULTED = 1 << 0,
	ENDING = 1 << 1,
	RUNNING = 1 << 2,
	STARTING = 1 << 3,
}

enum TICK_TYPE {
	NONE		= 0b00,
	EFFECTS		= 0b01,
	TRANSITIONS	= 0b10
}
#endregion


#region Private Variables
var _host_scope : NodeCameraHostExecutionScope
var _parent_record : MultiLayerRecord
var _layer_storage : NodeCameraLayerStorage

var _effect_storage := NodeCameraRecordStorage.new()
var _transition_storage := NodeCameraRecordStorage.new()

var _record_by_layer : Dictionary[NodeCameraLayer, LayerRecord]

var _dirty_mask : int
var _layer_to_dirty_op : Dictionary[NodeCameraLayer, int]
var _layer_to_old_priority : Dictionary[NodeCameraLayer, int]
var _layer_to_force_stage : Dictionary[NodeCameraStaged, LAYER_STAGES]
#endregion



#region Virtual Methods
func _init(
	host_scope : NodeCameraHostExecutionScope, parent_record : MultiLayerRecord,
	layer_storage : NodeCameraLayerStorage
) -> void:
	_host_scope = host_scope
	_parent_record = parent_record
	_settup_layer_storage(layer_storage)

func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		_clear_scope()
		_effect_storage.free()
		_transition_storage.free()
#endregion


#region Initialize Methods
func _settup_layer_storage(storage : NodeCameraLayerStorage) -> void:
	if _layer_storage == storage:
		return
	if _layer_storage != null:
		_layer_storage.layer_added.disconnect(_flag_add_layer)
		_layer_storage.layer_removed.disconnect(_flag_remove_layer)
		_layer_storage.layer_changed_mask.disconnect(_flag_camera_mask_changed)
		_layer_storage.layer_changed_priority.disconnect(_reorder_layer)
	
	_layer_storage = storage
	if _layer_storage != null:
		_layer_storage.layer_added.connect(_flag_add_layer)
		_layer_storage.layer_removed.connect(_flag_remove_layer)
		_layer_storage.layer_changed_mask.connect(_flag_camera_mask_changed)
		_layer_storage.layer_changed_priority.connect(_reorder_layer)
#endregion


#region Dirty Flagging Methods
func flag_construct_scope() -> void:
	_flag_request(DIRTY_FLAGS.STRUCTURE_CHANGED)
func flag_clear_scope() -> void:
	_flag_request(DIRTY_FLAGS.STRUCTURE_CLEARED)

func _flag_remove_layer(layer : NodeCameraLayer) -> void:
	_layer_to_dirty_op[layer] = _layer_to_dirty_op.get(
		layer, 0
	) | DIRTY_FLAGS.REMOVE_LAYER
	_flag_request(DIRTY_FLAGS.REMOVE_LAYER)
func _flag_reorder_layer(layer : NodeCameraLayer, old_priority : int) -> void:
	_layer_to_old_priority[layer] = old_priority
	_layer_to_dirty_op[layer] = _layer_to_dirty_op.get(
		layer, 0
	) | DIRTY_FLAGS.REORDER_LAYER
	_flag_request(DIRTY_FLAGS.REORDER_LAYER)
func _flag_add_layer(layer : NodeCameraLayer) -> void:
	_layer_to_dirty_op[layer] = _layer_to_dirty_op.get(
		layer, 0
	) | DIRTY_FLAGS.ADD_LAYER
	_flag_request(DIRTY_FLAGS.ADD_LAYER)
func _flag_camera_mask_changed(layer : NodeCameraLayer, old_mask : int) -> void:
	var host_mask := _host_scope.get_mask()
	var new_mask := layer.camera_mask
	var mask_diff := old_mask ^ new_mask
	
	if mask_diff & host_mask:
		if new_mask & host_mask:
			_flag_add_layer(layer)
			return
		_flag_remove_layer(layer)

func _flag_stage_advance(layer : NodeCameraStaged) -> void:
	_layer_to_dirty_op[layer as NodeCameraLayer] = (
		_layer_to_dirty_op.get(
			layer as NodeCameraLayer, 0
		) | DIRTY_FLAGS.STAGE_CHANGED
	)
	_flag_request(DIRTY_FLAGS.STAGE_CHANGED)
func _flag_stage_overwrite(
	layer : NodeCameraStaged, stage : LAYER_STAGES
) -> void:
	_layer_to_force_stage[layer] = stage
	_flag_request(DIRTY_FLAGS.STAGE_CHANGED)

func _flag_multi_tick_mask_changed(record : LayerRecord) -> void:
	_layer_to_dirty_op[record.layer] = _layer_to_dirty_op.get(
		record.layer, 0
	) | DIRTY_FLAGS.REMOVE_LAYER
	_flag_request(DIRTY_FLAGS.MULTI_TICK_MASK_CHANGED)

func _flag_request(op : DIRTY_FLAGS) -> void:
	if _dirty_mask == 0:
		_handle_dirty_layers.call_deferred()
	_dirty_mask |= op
#endregion


#region Dirty Operations Methods
func _handle_dirty_layers() -> void:
	if _dirty_mask & DIRTY_FLAGS.STRUCTURE_CLEARED:
		_clear_scope()
		_clear_dirty_flags()
		return
	if _host_scope.is_disabled():
		_clear_dirty_flags()
		return
	if _dirty_mask & DIRTY_FLAGS.STRUCTURE_CHANGED:
		_construct_scope(_layer_storage.get_registered_layers())
		_clear_dirty_flags()
		return
	
	var rebuild_flags : int = TICK_TYPE.NONE
	for layer : NodeCameraLayer in _layer_to_dirty_op:
		var op := _layer_to_dirty_op[layer]
		if _dirty_mask & DIRTY_FLAGS.REMOVE_LAYER:
			rebuild_flags |= _remove_layer(layer)
			continue
		if _dirty_mask & DIRTY_FLAGS.REORDER_LAYER:
			rebuild_flags |= _reorder_layer(layer)
			continue
		if _dirty_mask & DIRTY_FLAGS.ADD_LAYER:
			rebuild_flags |= _add_layer(layer)
			continue
		
		if _dirty_mask & DIRTY_FLAGS.MULTI_TICK_MASK_CHANGED:
			rebuild_flags |= _update_multi_tick_mask(_record_by_layer[layer])
		if _dirty_mask & DIRTY_FLAGS.STAGE_CHANGED:
			rebuild_flags |= _host_scope._advance_layer_stage(
				layer, _record_by_layer[layer], self
			)
			continue
	
	for layer : NodeCameraStaged in _layer_to_force_stage:
		var record := _record_by_layer.get(layer as NodeCameraLayer, null)
		var stage := _layer_to_force_stage[layer]
		
		if record == null:
			rebuild_flags |= _add_layer(layer, stage)
			continue
		rebuild_flags |= _host_scope._set_layer_stage(
			layer, record, self, _layer_to_force_stage[layer]
		)
	
	if rebuild_flags & TICK_TYPE.EFFECTS > 0:
		_effect_storage.rebuild()
	if rebuild_flags & TICK_TYPE.TRANSITIONS > 0:
		_transition_storage.rebuild()
	if rebuild_flags > 0 && _parent_record:
		_parent_record.request_tick_mask_update.emit()
	
	_clear_dirty_flags()
func _clear_dirty_flags() -> void:
	_layer_to_dirty_op.clear()
	_layer_to_old_priority.clear()
	_layer_to_force_stage.clear()
	_dirty_mask = 0


func force_construct_scope() -> void:
	_construct_scope(_layer_storage.get_registered_layers())
func _construct_scope(scope_layers : Array[NodeCameraLayer]) -> void:
	_clear_scope()
	
	var rebuild_flags : int = TICK_TYPE.NONE
	var mask := _host_scope.get_mask()
	for layer : NodeCameraLayer in scope_layers:
		if !(layer.camera_mask & mask):
			continue
		rebuild_flags |= _add_layer(layer)

	if rebuild_flags & TICK_TYPE.EFFECTS > 0:
		_effect_storage.rebuild()
	if rebuild_flags & TICK_TYPE.TRANSITIONS > 0:
		_transition_storage.rebuild()
func _clear_scope() -> void:
	_effect_storage.clear()
	_transition_storage.clear()
	
	for record : LayerRecord in _record_by_layer.values():
		record.free()
	_record_by_layer.clear()


func _add_layer(
	layer : NodeCameraLayer, default_stage : LAYER_STAGES = LAYER_STAGES.STARTING
) -> int:
	if _record_by_layer.has(layer):
		return TICK_TYPE.NONE
	var record := _construct_record(layer, default_stage)
	if record == null:
		return TICK_TYPE.NONE
	
	if record.tick_mask & TICK_TYPE.EFFECTS > 0:
		_effect_storage.add(record, layer.priority)
	if record.tick_mask & TICK_TYPE.TRANSITIONS > 0:
		_transition_storage.add(record, layer.priority)
	
	_record_by_layer.set(layer, record)
	return record.tick_mask
func _remove_layer(layer : NodeCameraLayer) -> int:
	var record : LayerRecord = _record_by_layer.get(layer, null)
	if record == null:
		return TICK_TYPE.NONE
	
	if record.tick_mask & TICK_TYPE.EFFECTS > 0:
		_effect_storage.remove(record, layer.priority)
	if record.tick_mask & TICK_TYPE.TRANSITIONS > 0:
		_transition_storage.remove(record, layer.priority)
	
	var mask := record.tick_mask
	_record_by_layer.erase(layer)
	record.free()
	return mask
func _reorder_layer(layer : NodeCameraLayer) -> int:
	var record := _record_by_layer.get(layer, null)
	if record == null:
		return 0
	
	var old_priority := _layer_to_old_priority[layer]
	
	if record.tick_mask & TICK_TYPE.EFFECTS > 0:
		_effect_storage.reorder(record, layer.priority, old_priority)
	if record.tick_mask & TICK_TYPE.TRANSITIONS > 0:
		_transition_storage.reorder(record, layer.priority, old_priority)
	return record.tick_mask


func _update_multi_tick_mask(record : MultiLayerRecord) -> int:
	var priority := record.layer.priority
	var new_mask : int = record.layer._get_tick_mask(record.scope)
	var mask_diff := record.tick_mask ^ new_mask
	
	if mask_diff & TICK_TYPE.EFFECTS:
		if new_mask & TICK_TYPE.EFFECTS:
			_effect_storage.add(record, priority)
		else:
			_effect_storage.remove(record, priority)
	if mask_diff & TICK_TYPE.TRANSITIONS:
		if new_mask & TICK_TYPE.TRANSITIONS:
			_transition_storage.add(record, priority)
		else:
			_transition_storage.remove(record, priority)
	
	record.tick_mask = new_mask
	return mask_diff
#endregion


#region Helper Methods
func _construct_record(
	layer : NodeCameraLayer, default_stage : LAYER_STAGES = LAYER_STAGES.STARTING
) -> LayerRecord:
	if layer is NodeCameraStaged:
		return _construct_staged_record(layer, default_stage)
	if layer is NodeCameraMulti:
		return _construct_multi_record(layer)
	return null
func _construct_staged_record(
	layer : NodeCameraStaged, starting_stage : LAYER_STAGES
) -> LayerRecord:
	var record := StagedLayerRecord.new()
	
	record.stage = starting_stage
	record.stage_changed_mask = _get_stage_mask(layer.get_needed_change_stages())
	record.stage_process_mask  = _get_stage_mask(layer.get_needed_process_stages())
	
	_host_scope._sync_layer_stage(layer, record, self, true)
	if record.stage == LAYER_STAGES.HAULTED:
		record.free()
		return null
	
	record.layer = layer
	record.scope = self
	if layer is NodeCameraEffect:
		record.tick_mask = TICK_TYPE.EFFECTS
	else:
		record.tick_mask = TICK_TYPE.TRANSITIONS
	return record
func _construct_multi_record(
	layer : NodeCameraMulti
) -> LayerRecord:
	var record := MultiLayerRecord.new()
	var scope : NodeCameraExecutionScope
	
	if layer is NodeCameraSelector:
		scope = NodeCameraSelectorExecutionScope.new(
			_host_scope, record, layer.get_layer_storage(),
			layer, layer.selection
		)
	else:
		scope = NodeCameraExecutionScope.new(
			_host_scope, record, layer.get_layer_storage()
		)
	
	scope.force_construct_scope()
	record.tick_mask = layer._get_tick_mask(scope)
	if record.tick_mask == TICK_TYPE.NONE:
		record.free()
		return
	
	record.scope = scope
	record.layer = layer
	record.request_tick_mask_update.connect(
		_flag_multi_tick_mask_changed, CONNECT_APPEND_SOURCE_OBJECT
	)
	return record

func _get_stage_mask(stages : PackedInt32Array) -> int:
	var mask : int = 0
	for stage : int in stages:
		mask |= stage
	return mask
#endregion


#region Tick Methods
func run_effects(target : NodeCameraState) -> void:
	for record : LayerRecord in _effect_storage.get_flat_list():
		record.layer._scope = record.scope
		record.layer.process_effect(target, record.stage)
func run_transitions(
	target : NodeCameraState, current : NodeCameraState
) -> void:
	for record : LayerRecord in _transition_storage.get_flat_list():
		record.layer._scope = record.scope
		record.layer.process_transition(target, current, record.stage)
#endregion


#region Storage Access
func has_effects() -> bool:
	return !_effect_storage.is_empty()
func has_transitions() -> bool:
	return !_transition_storage.is_empty()
#endregion

# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
