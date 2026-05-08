# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
@tool
class_name NodeCameraExecutionScope extends Object

#region Enums
enum DIRTY_FLAGS {
	STRUCTURE_CHANGED			= 1 << 0,
	STRUCTURE_CLEARED			= 1 << 1,
	REMOVE_LAYER				= 1 << 2,
	REORDER_LAYER				= 1 << 3,
	ADD_LAYER					= 1 << 4,
	PAUSE_LAYER					= 1 << 5,
	UNPAUSE_LAYER				= 1 << 6,
	STAGE_CHANGED				= 1 << 7,
	MULTI_TICK_MASK_CHANGED		= 1 << 8,
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
	TRANSITIONS	= 0b10,
	BOTH		= 0b11
}
#endregion


#region Private Variables
var _host_scope : NodeCameraHostExecutionScope
var _container_record : MultiLayerRecord
var _layer_storage : NodeCameraLayerStorage

var _effect_storage := NodeCameraRecordStorage.new()
var _transition_storage := NodeCameraRecordStorage.new()

var _record_by_layer : Dictionary[NodeCameraLayer, LayerRecord]

var _dirty_mask : int
var _layer_to_dirty_op : Dictionary[NodeCameraLayer, int]
var _layer_to_old_priority : Dictionary[NodeCameraLayer, int]
var _layer_to_force_stage : Dictionary[NodeCameraLayer, int]
#endregion



#region Virtual Methods
func _init(
	host_scope : NodeCameraHostExecutionScope, container_record : MultiLayerRecord,
	layer_storage : NodeCameraLayerStorage
) -> void:
	_host_scope = host_scope
	_container_record = container_record
	_settup_layer_storage(layer_storage)

func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		_host_scope._force_hault_records(self)
		_clear_scope()
		_effect_storage.free()
		_transition_storage.free()
#endregion


#region Initialize Methods
func _settup_layer_storage(storage : NodeCameraLayerStorage) -> void:
	if _layer_storage == storage:
		return
	if _layer_storage != null:
		_layer_storage.layer_added.disconnect(flag_add_layer)
		_layer_storage.layer_removed.disconnect(flag_remove_layer)
		_layer_storage.layer_changed_mask.disconnect(flag_camera_mask_changed)
		_layer_storage.layer_changed_priority.disconnect(flag_reorder_layer)
	
	_layer_storage = storage
	if _layer_storage != null:
		_layer_storage.layer_added.connect(flag_add_layer)
		_layer_storage.layer_removed.connect(flag_remove_layer)
		_layer_storage.layer_changed_mask.connect(flag_camera_mask_changed)
		_layer_storage.layer_changed_priority.connect(flag_reorder_layer)
#endregion


#region Dirty Flagging Methods
func flag_construct_scope() -> void:
	_flag_request(DIRTY_FLAGS.STRUCTURE_CHANGED)
func flag_clear_scope() -> void:
	_flag_request(DIRTY_FLAGS.STRUCTURE_CLEARED)

func flag_remove_layer(layer : NodeCameraLayer) -> void:
	# If remove, ignore all other layer flags
	_layer_to_dirty_op[layer] = DIRTY_FLAGS.REMOVE_LAYER
	_flag_request(DIRTY_FLAGS.REMOVE_LAYER)
func flag_reorder_layer(layer : NodeCameraLayer, old_priority : int) -> void:
	_layer_to_old_priority[layer] = old_priority
	_layer_to_dirty_op[layer] = _layer_to_dirty_op.get(
		layer, 0
	) | DIRTY_FLAGS.REORDER_LAYER
	_flag_request(DIRTY_FLAGS.REORDER_LAYER)
func flag_add_layer(layer : NodeCameraLayer) -> void:
	if _layer_to_dirty_op.get(layer, 0) & DIRTY_FLAGS.REMOVE_LAYER:
		# Can't remove and add
		_layer_to_dirty_op[layer] = (_layer_to_dirty_op.get(
			layer, 0
		) & ~DIRTY_FLAGS.REMOVE_LAYER) | DIRTY_FLAGS.ADD_LAYER
		
		_dirty_mask = (
			_dirty_mask & ~DIRTY_FLAGS.REMOVE_LAYER
		) | DIRTY_FLAGS.ADD_LAYER
		return
	
	_layer_to_dirty_op[layer] = _layer_to_dirty_op.get(
		layer, 0
	) | DIRTY_FLAGS.ADD_LAYER
	_flag_request(DIRTY_FLAGS.ADD_LAYER)
func flag_camera_mask_changed(layer : NodeCameraLayer, old_mask : int) -> void:
	var host_mask := _host_scope.get_mask()
	var new_mask := layer.camera_mask
	var mask_diff := old_mask ^ new_mask
	
	if mask_diff & host_mask:
		if new_mask & host_mask:
			flag_add_layer(layer)
			return
		flag_remove_layer(layer)

func flag_pause(layer : NodeCameraLayer) -> void:
	if _layer_to_dirty_op.get(layer, 0) & DIRTY_FLAGS.UNPAUSE_LAYER:
		# Can't unpause and pause
		_layer_to_dirty_op[layer] = (_layer_to_dirty_op.get(
			layer, 0
		) & ~DIRTY_FLAGS.UNPAUSE_LAYER) | DIRTY_FLAGS.PAUSE_LAYER
		
		_dirty_mask = (
			_dirty_mask & ~DIRTY_FLAGS.UNPAUSE_LAYER
		) | DIRTY_FLAGS.PAUSE_LAYER
		return
	
	_layer_to_dirty_op[layer] = _layer_to_dirty_op.get(
		layer, 0
	) | DIRTY_FLAGS.PAUSE_LAYER
	_flag_request(DIRTY_FLAGS.PAUSE_LAYER)
func flag_unpause(layer : NodeCameraLayer) -> void:
	if _layer_to_dirty_op.get(layer, 0) & DIRTY_FLAGS.UNPAUSE_LAYER:
		# Can't pause and unpause
		_layer_to_dirty_op[layer] = (_layer_to_dirty_op.get(
			layer, 0
		) & ~DIRTY_FLAGS.PAUSE_LAYER) | DIRTY_FLAGS.UNPAUSE_LAYER
		
		_dirty_mask = (
			_dirty_mask & ~DIRTY_FLAGS.PAUSE_LAYER
		) | DIRTY_FLAGS.UNPAUSE_LAYER
		return
	
	_layer_to_dirty_op[layer] = _layer_to_dirty_op.get(
		layer, 0
	) | DIRTY_FLAGS.UNPAUSE_LAYER
	_flag_request(DIRTY_FLAGS.UNPAUSE_LAYER)

func flag_advance_stage(layer : NodeCameraLayer) -> void:
	_layer_to_dirty_op[layer] = _layer_to_dirty_op.get(
		layer, 0
	) | DIRTY_FLAGS.STAGE_CHANGED
	_layer_to_force_stage[layer] = DIRTY_FLAGS.STAGE_CHANGED
	_flag_request(DIRTY_FLAGS.STAGE_CHANGED)
func flag_overwrite_stage(
	layer : NodeCameraLayer, stage : LAYER_STAGES
) -> void:
	_layer_to_dirty_op[layer] = _layer_to_dirty_op.get(
		layer, 0
	) | DIRTY_FLAGS.STAGE_CHANGED
	_layer_to_force_stage[layer] = stage
	_flag_request(DIRTY_FLAGS.STAGE_CHANGED)

func flag_multi_tick_mask_changed(record : LayerRecord) -> void:
	_layer_to_dirty_op[record.layer] = _layer_to_dirty_op.get(
		record.layer, 0
	) | DIRTY_FLAGS.MULTI_TICK_MASK_CHANGED
	_flag_request(DIRTY_FLAGS.MULTI_TICK_MASK_CHANGED)

func _flag_request(op : DIRTY_FLAGS) -> void:
	if _dirty_mask == 0:
		_handle_dirty_layers.call_deferred()
	_dirty_mask |= op
#endregion


#region Dirty Operations Methods
# Flag Handler Overhead
func _handle_dirty_layers() -> void:
	if _dirty_mask & DIRTY_FLAGS.STRUCTURE_CLEARED:
		_host_scope._force_hault_records(self)
		_clear_scope()
		_force_rebuild_flat_lists(TICK_TYPE.BOTH)
		_clear_dirty_flags()
		_flag_parent_multi_tick_mask_changed()
		return
	if !_host_scope.is_running():
		_clear_dirty_flags()
		return
	if _dirty_mask & DIRTY_FLAGS.STRUCTURE_CHANGED:
		_force_rebuild_scope()
		_clear_dirty_flags()
		_flag_parent_multi_tick_mask_changed()
		return
	
	var rebuild_flags : int = TICK_TYPE.NONE
	var record : LayerRecord
	#			REBUILD PHASE: LAYERS
	for layer : NodeCameraLayer in _sort_priority_order(_layer_to_dirty_op.keys()):
		var op := _layer_to_dirty_op.get(layer, null)
		
		if op & DIRTY_FLAGS.REMOVE_LAYER:
			rebuild_flags |= _remove_layer(layer)
			# If removed, nothing else matters
			continue
		if op & DIRTY_FLAGS.ADD_LAYER:
			rebuild_flags |= _add_layer(layer)
			# Adding a layer takes care of everything already, but addtional
			# editions can be made
		
		if op & DIRTY_FLAGS.STAGE_CHANGED:
			var stage := _layer_to_force_stage.get(layer, 0) # Either Advance or Overwrite
			
			if stage == DIRTY_FLAGS.STAGE_CHANGED:
				# Advance Stage
				rebuild_flags |= _host_scope._advance_stage_record(
					_record_by_layer.get(layer, null)
				)
			else:
				# Overwrite Stage
				rebuild_flags |= _host_scope._overwrite_stage(layer, self, stage)
			
			if !_record_by_layer.has(layer):
				# Record was removed. We can ignore everything after.
				continue
		
		if op & DIRTY_FLAGS.MULTI_TICK_MASK_CHANGED:
			rebuild_flags |= _update_multi_tick_mask(
				_record_by_layer.get(layer, null)
			)
			
			if !_record_by_layer.has(layer):
				# Record was removed. We can ignore everything after.
				continue
		
		if op & DIRTY_FLAGS.REORDER_LAYER:
			rebuild_flags |= _reorder_layer(layer)
		
		# You can only unpausing or pause in a single frame
		if op & DIRTY_FLAGS.UNPAUSE_LAYER:
			rebuild_flags |= _set_pause_layer(
				_record_by_layer.get(layer, null), false
			)
		elif op & DIRTY_FLAGS.PAUSE_LAYER:
			rebuild_flags |= _set_pause_layer(
				_record_by_layer.get(layer, null), true
			)
	
	_force_rebuild_flat_lists(rebuild_flags)
	if rebuild_flags && _container_record:
		if _record_by_layer.is_empty():
			_container_record.parent_scope.flag_remove_layer(
				_container_record.layer
			)
	
	_clear_dirty_flags()
func _clear_dirty_flags() -> void:
	_layer_to_dirty_op.clear()
	_layer_to_old_priority.clear()
	_layer_to_force_stage.clear()
	_dirty_mask = 0
func _flag_parent_multi_tick_mask_changed() -> void:
	if !_container_record:
		return
	_container_record.parent_scope.flag_multi_tick_mask_changed(
		_container_record
	)


# Scope rebuild Methods
func _force_rebuild_scope() -> void:
	# Rebuilds scop and flatlists
	_construct_scope()
	_force_rebuild_flat_lists(TICK_TYPE.BOTH)
func _force_rebuild_flat_lists(tick_mask : int) -> void:
	if tick_mask & TICK_TYPE.EFFECTS:
		_effect_storage.rebuild()
	if tick_mask & TICK_TYPE.TRANSITIONS:
		_transition_storage.rebuild()

func _construct_scope() -> void:
	_clear_scope()
	
	var lay : NodeCameraLayer = _container_record.layer if _container_record else null
	if lay is NodeCameraPassthrough:
		_construct_passthrough_check(lay._get_active_layers())
		return
	_construct_scope_layers_check()
func _construct_passthrough_check(layers : Array[NodeCameraLayer]) -> void:
	var mask := _host_scope.get_mask()
	var parent : NodeCameraPassthrough = _container_record.layer
	
	for layer : NodeCameraLayer in layers:
		if !(layer.camera_mask & mask) || !layer.get_parent() == parent:
			continue
		_add_layer(layer)
func _construct_scope_layers_check() -> void:
	var mask := _host_scope.get_mask()
	var layers := _sort_priority_order(_layer_storage.get_registered())
	
	for layer : NodeCameraLayer in layers:
		if !(layer.camera_mask & mask):
			continue
		_add_layer(layer)
	
func _clear_scope() -> void:
	_effect_storage.clear()
	_transition_storage.clear()
	
	for record : LayerRecord in _record_by_layer.values():
		record.layer._removed_from_scope(self)
		record.free()
	_record_by_layer.clear()


# Flag Handler Methods
func _remove_layer(layer : NodeCameraLayer) -> int:
	var record : LayerRecord = _record_by_layer.get(layer, null)
	if record == null:
		return TICK_TYPE.NONE
	layer._removed_from_scope(self)
	
	if record.tick_mask & TICK_TYPE.EFFECTS:
		_effect_storage.remove(record, layer.priority)
	if record.tick_mask & TICK_TYPE.TRANSITIONS:
		_transition_storage.remove(record, layer.priority)
	
	if (
		record.stage != LAYER_STAGES.HAULTED &&
		(record as StagedLayerRecord).get_changed_mask() & LAYER_STAGES.HAULTED
	):
		# NOTE: MultiLayerRecord always have a stage of LAYER_STAGES.HAULTED
		_host_scope._force_stage_change(layer, LAYER_STAGES.HAULTED)
	
	if record.paused:
		_record_by_layer.erase(layer)
		record.free()
		return TICK_TYPE.NONE
	
	var mask := record.tick_mask
	_record_by_layer.erase(layer)
	record.free()
	return mask
func _add_layer(
	layer : NodeCameraLayer, init_stage : LAYER_STAGES = LAYER_STAGES.STARTING
) -> int:
	if _record_by_layer.has(layer):
		return TICK_TYPE.NONE
	layer._added_to_scope(self)
	
	var record := _construct_record(layer, init_stage)
	if record == null:
		return TICK_TYPE.NONE
	
	if record.tick_mask & TICK_TYPE.EFFECTS:
		_effect_storage.add(record, layer.priority)
	if record.tick_mask & TICK_TYPE.TRANSITIONS:
		_transition_storage.add(record, layer.priority)
	
	_record_by_layer.set(layer, record)
	
	if record.paused:
		return TICK_TYPE.NONE
	return record.tick_mask
func _reorder_layer(layer : NodeCameraLayer) -> int:
	var record : LayerRecord = _record_by_layer.get(layer, null)
	if record == null:
		return 0
	
	var old_priority := _layer_to_old_priority[layer]
	
	if record.tick_mask & TICK_TYPE.EFFECTS:
		_effect_storage.reorder(record, layer.priority, old_priority)
	if record.tick_mask & TICK_TYPE.TRANSITIONS:
		_transition_storage.reorder(record, layer.priority, old_priority)
	
	if record.paused:
		return TICK_TYPE.NONE
	return record.tick_mask

func _set_pause_layer(record : LayerRecord, pause : bool) -> int:
	if record == null:
		return TICK_TYPE.NONE
	if record.paused == pause:
		return TICK_TYPE.NONE
	
	record.paused = pause
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
	layer : NodeCameraLayer, init_stage : LAYER_STAGES = LAYER_STAGES.STARTING
) -> LayerRecord:
	var record : LayerRecord
	if layer is NodeCameraStaged:
		record = _construct_staged_record(layer, init_stage)
	elif layer is NodeCameraGroup:
		record = _construct_multi_record(layer)
	return record
func _construct_staged_record(
	layer : NodeCameraStaged, init_stage : LAYER_STAGES
) -> LayerRecord:
	var record := StagedLayerRecord.new()
	var process_mask := _get_stage_mask(layer.get_needed_process_stages())
	
	record.layer = layer
	record.stage = init_stage
	record.scope = self
	
	record.set_masks(
		_get_stage_mask(layer.get_needed_process_stages()),
		_get_stage_mask(layer.get_needed_linger_stages()),
		_get_stage_mask(layer.get_needed_change_stages())
	)
	
	_host_scope._sync_layer_stage(record, true)
	
	if record.stage == LAYER_STAGES.HAULTED:
		record.free()
		return null
	
	if layer is NodeCameraEffect:
		record.tick_mask = TICK_TYPE.EFFECTS
	else:
		record.tick_mask = TICK_TYPE.TRANSITIONS
	return record
func _construct_multi_record(layer : NodeCameraGroup) -> LayerRecord:
	var record := MultiLayerRecord.new()
	
	record.layer = layer
	record.parent_scope = self
	record.scope = NodeCameraExecutionScope.new(
		_host_scope, record, layer.get_layer_storage()
	)
	
	record.scope._force_rebuild_scope()
	
	record.tick_mask = layer._get_tick_mask(record.scope)
	if !(layer is NodeCameraPassthrough):
		if record.tick_mask == TICK_TYPE.NONE:
			record.free()
			return
	
	return record

func _get_stage_mask(stages : PackedInt32Array) -> int:
	var mask : int = 0
	for stage : int in stages:
		mask |= stage
	return mask

func _priority_check(l1 : NodeCameraLayer, l2 : NodeCameraLayer) -> bool:
	return l1.priority > l2.priority
func _sort_priority_order(ret : Array[NodeCameraLayer]) -> Array[NodeCameraLayer]:
	ret.sort_custom(_priority_check)
	return ret
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


#region Accesor Access
func has_effects() -> bool:
	return !_effect_storage.is_empty()
func has_transitions() -> bool:
	return !_transition_storage.is_empty()

func get_effect_records() -> Array[LayerRecord]:
	return _effect_storage.get_flat_list()
func get_transitions_records() -> Array[LayerRecord]:
	return _effect_storage.get_flat_list()

func get_records() -> Array[LayerRecord]:
	return _record_by_layer.values()

func has_record(layer : NodeCameraLayer) -> bool:
	return _record_by_layer.has(layer)
func get_record(layer : NodeCameraLayer) -> LayerRecord:
	return _record_by_layer.get(layer, null)
func is_record_running(layer : NodeCameraLayer) -> bool:
	var record : LayerRecord = _record_by_layer.get(layer, null)
	return record != null && !record.paused

func get_registered_layers() -> Array[NodeCameraLayer]:
	return _layer_storage.get_registered()
#endregion

# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
