# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
@tool
class_name NodeCameraExecutionScope extends Object
## The base execution scope for all NodeCam operations.

#region Enums
## The dirty operation bitflags used for batch mutations.
enum DIRTY_FLAGS {
	STRUCTURE_CHANGED			= 1 << 0,	## Flags the scope structure to be recreated.
	STRUCTURE_CLEARED			= 1 << 1,	## Flags the scope to be freed.
	REMOVE_LAYER				= 1 << 2,	## Flags the scope to remove a layer.
	REORDER_LAYER				= 1 << 3,	## Flags the scope to change a layer's priority.
	ADD_LAYER					= 1 << 4,	## Flags the scope to remove a layer.
	PAUSE_LAYER					= 1 << 5,	## Flags the scope to pause a layer's execution.
	UNPAUSE_LAYER				= 1 << 6,	## Flags the scope to unpause a layer's execution.
	STAGE_CHANGED				= 1 << 7,	## Flags the scope to change a layer's stage.
	STAGE_MASK_CHANGED			= 1 << 8,	## Flags the scope to change a layer's record's stage masks.
	TICK_MASK_CHANGED			= 1 << 9,	## Flags the scope to change a layer's usage (effect, transition, both, or neither)
	TICK_MASK_CHANGED_DIRECT	= 1 << 10,	## Flags the scope to rebuild it's flatlists (effect, transition, both, or neither)
}

## The bitwise flags for [LayerRecord] stages.
## [br][br]
## Stages go in order: [code]STARTING > RUNNING > ENDING > HAULTED[/code].
enum LAYER_STAGES {
	HAULTED		= 1 << 0,	## [LayerRecord] has finished execution and about to be removed.
	ENDING		= 1 << 1,	## [LayerRecord] has ended execution and is clearing itself up.
	RUNNING		= 1 << 2,	## [LayerRecord] is running it's execution.
	STARTING	= 1 << 3,	## [LayerRecord] has started execution and is setting itself up.
}
## [b]For internal use only[/b].
## [br][br]
## A [enum TICK_TYPE] bit unused for [LayerRecord]. Instead signals
## that the layer should use the stage [member NodeCameraStaged.inital_stage]
## by default on creation.
const LAYER_STAGES_INHERITED := 0b0

## Defines what type a [LayerRecord] is defined as (effect,
## transition, both, or neither).
enum TICK_TYPE {
	NONE		= 0b00,	## This [LayerRecord] is not used for anything. Will normally be deleted soon.
	EFFECTS		= 0b01,	## This [LayerRecord] is an effect.
	TRANSITIONS	= 0b10,	## This [LayerRecord] is a transition.
	BOTH		= 0b11,	## This [LayerRecord] is both an effect and transition.
}
## [b]For internal use only[/b].
## [br][br]
## A [enum TICK_TYPE] bit unused for [LayerRecord]. Instead signals
## that the parent scope should have it's tick_mask checked
## regardless of anything else.
const TICK_TYPE_PARENT = 0b100
#endregion


#region Private Variables
var _host_scope : NodeCameraHostExecutionScope
var _container_record : GroupLayerRecord
var _layer_storage : NodeCameraLayerStorage

var _effect_storage := NodeCameraRecordStorage.new()
var _transition_storage := NodeCameraRecordStorage.new()

var _record_by_layer : Dictionary[NodeCameraLayer, LayerRecord]

var _dirty_mask : int
var _direct_tick_mask_change : int

var _layer_to_dirty_op : Dictionary[NodeCameraLayer, int]
var _layer_to_old_priority : Dictionary[NodeCameraLayer, int]
var _layer_to_force_stage : Dictionary[NodeCameraLayer, int]
#endregion



#region Virtual Methods
func _init(
	host_scope : NodeCameraHostExecutionScope, container_record : GroupLayerRecord,
	layer_storage : NodeCameraLayerStorage
) -> void:
	_host_scope = host_scope
	_container_record = container_record
	_settup_layer_storage(layer_storage)

func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		if is_instance_valid(_layer_storage):
			_layer_storage.unregister_scope(self)
		_host_scope._force_hault_records(self)
		
		_clear_scope()
		_effect_storage.free()
		_transition_storage.free()
#endregion


#region Initialize Methods
func _settup_layer_storage(storage : NodeCameraLayerStorage) -> void:
	_layer_storage = storage
	if _layer_storage != null:
		_layer_storage.register_scope(self)
		
		_layer_storage.layer_added.connect(flag_add_layer)
		_layer_storage.layer_removed.connect(flag_remove_layer)
#endregion


#region Dirty Flagging Methods
## Flags this scope for reconstruction next mutation batch.
func flag_construct_scope() -> void:
	_flag_request(DIRTY_FLAGS.STRUCTURE_CHANGED)
	# If rebuilding, don't clear.
	_dirty_mask = (_dirty_mask & ~ DIRTY_FLAGS.STRUCTURE_CLEARED)
## Flags this scope to be cleared next mutation batch.
func flag_clear_scope() -> void:
	_flag_request(DIRTY_FLAGS.STRUCTURE_CLEARED)
	# If clearing, don't rebuild.
	_dirty_mask = (_dirty_mask & ~ DIRTY_FLAGS.STRUCTURE_CHANGED)

## Flags this scope to remove [param layer] next mutation batch.
func flag_remove_layer(layer : NodeCameraLayer) -> void:
	if !layer: return
	
	# If remove, ignore all other layer flags
	_layer_to_dirty_op[layer] = DIRTY_FLAGS.REMOVE_LAYER
	_flag_request(DIRTY_FLAGS.REMOVE_LAYER)
## Flags this scope to add [param layer] next mutation batch.
func flag_add_layer(layer : NodeCameraLayer) -> void:
	if !layer: return
	
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
## Flags this scope to change the priority of [param layer]'s record
## next mutation batch.
func flag_reorder_layer(layer : NodeCameraLayer, old_priority : int) -> void:
	if !layer: return
	
	_layer_to_old_priority[layer] = old_priority
	_layer_to_dirty_op[layer] = _layer_to_dirty_op.get(
		layer, 0
	) | DIRTY_FLAGS.REORDER_LAYER
	_flag_request(DIRTY_FLAGS.REORDER_LAYER)

## Flags this scope to remove or add [param layer], depending on the
## camera mask change.
func flag_camera_mask_changed(layer : NodeCameraLayer, old_mask : int) -> void:
	if !layer: return
	
	var host_mask := _host_scope.get_mask()
	var new_mask := layer.camera_mask
	var mask_diff := old_mask ^ new_mask
	
	if mask_diff & host_mask:
		if new_mask & host_mask:
			flag_add_layer(layer)
			return
		flag_remove_layer(layer)

## Flags this scope to pause [param layer] next mutation batch.
func flag_pause(layer : NodeCameraLayer) -> void:
	if !layer: return
	
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
## Flags this scope to unpause [param layer] next mutation batch.
func flag_unpause(layer : NodeCameraLayer) -> void:
	if !layer: return
	
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

## Flags this scope to advance the [param layer]'s stage,
## to the next stage, next mutation batch.
## [br][br]
## [b]NOTE[/b]: Using this on a [NodeCameraGroup] layer will propagate it
## to it's children instead.
## [br][br]
## Also see [enum LAYER_STAGES].
func flag_advance_stage(layer : NodeCameraLayer) -> void:
	if !layer: return
	
	_layer_to_dirty_op[layer] = _layer_to_dirty_op.get(
		layer, 0
	) | DIRTY_FLAGS.STAGE_CHANGED
	_layer_to_force_stage[layer] = DIRTY_FLAGS.STAGE_CHANGED
	_flag_request(DIRTY_FLAGS.STAGE_CHANGED)
## Flags this scope to advance the [param layer]'s stage,
## until [stage] is reached, next mutation batch. Does nothing if
## [param layer] is already passed the given stage.
## [br][br]
## [b]NOTE[/b]: Using this on a [NodeCameraGroup] layer will propagate it
## to it's children instead.
## [br][br]
## Also see [enum LAYER_STAGES].
func flag_advance_to_stage(
	layer : NodeCameraLayer, stage : LAYER_STAGES
) -> void:
	if !layer: return
	
	_layer_to_dirty_op[layer] = _layer_to_dirty_op.get(
		layer, 0
	) | DIRTY_FLAGS.STAGE_CHANGED
	_layer_to_force_stage[layer] = DIRTY_FLAGS.STAGE_CHANGED | stage
	_flag_request(DIRTY_FLAGS.STAGE_CHANGED)
## Flags this scope to advance the [param layer]'s stage next mutation batch.
## [br][br]
## [b]NOTE[/b]: Using this on a [NodeCameraGroup] layer will propagate it
## to it's children instead.
## [br][br]
## Also see [enum LAYER_STAGES].
func flag_overwrite_stage(
	layer : NodeCameraLayer, stage : LAYER_STAGES
) -> void:
	if !layer: return
	
	_layer_to_dirty_op[layer] = _layer_to_dirty_op.get(
		layer, 0
	) | DIRTY_FLAGS.STAGE_CHANGED
	_layer_to_force_stage[layer] = stage
	_flag_request(DIRTY_FLAGS.STAGE_CHANGED)

## Flags this scope to update a [NodeCameraStaged]'s stage mask.
## [br][br]
## Also see: [method NodeCameraStaged.get_needed_process_stages],
## [method NodeCameraStaged.get_needed_linger_stages], and
## [method NodeCameraStaged.get_needed_change_stages].
func flag_stage_mask_changed(layer : NodeCameraStaged) -> void:
	if !layer: return
	
	_layer_to_dirty_op[layer as NodeCameraLayer] = _layer_to_dirty_op.get(
		layer, 0
	) | DIRTY_FLAGS.STAGE_MASK_CHANGED
	_flag_request(DIRTY_FLAGS.STAGE_MASK_CHANGED)

## Flags this scope to update [param layer]'s type classification.
## [br][br]
## Also see [enum TICK_TYPE].
func flag_tick_mask_changed(layer : NodeCameraGroup) -> void:
	if !layer: return
	
	_layer_to_dirty_op[layer as NodeCameraLayer] = _layer_to_dirty_op.get(
		layer, 0
	) | DIRTY_FLAGS.TICK_MASK_CHANGED
	_flag_request(DIRTY_FLAGS.TICK_MASK_CHANGED)

## Flags this scope to update it's flatlists. Only used internally.
## [br][br]
## Also see [enum TICK_TYPE].
func flag_tick_mask_direct_changed(tick : TICK_TYPE) -> void:
	if tick == TICK_TYPE.NONE: return
	_direct_tick_mask_change |= tick
	_flag_request(DIRTY_FLAGS.TICK_MASK_CHANGED_DIRECT)


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
		_flag_parent_tick_mask_changed()
		return
	if !_host_scope.is_running():
		_clear_dirty_flags()
		return
	if _dirty_mask & DIRTY_FLAGS.STRUCTURE_CHANGED:
		_force_rebuild_scope(LAYER_STAGES_INHERITED)
		_clear_dirty_flags()
		_flag_parent_tick_mask_changed()
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
			record = _record_by_layer.get(layer, null)
			
			if stage > DIRTY_FLAGS.STAGE_CHANGED:
				# Advance Stage
				rebuild_flags |= _host_scope._advance_to_stage_record(
					record, stage & ~DIRTY_FLAGS.STAGE_CHANGED
				)
			elif stage == DIRTY_FLAGS.STAGE_CHANGED:
				# Advance Stage
				rebuild_flags |= _host_scope._advance_stage_record(
					record
				)
			else:
				# Overwrite Stage
				rebuild_flags |= _host_scope._overwrite_stage(
					layer, self, stage
				)
			
			if layer is NodeCameraGroup:
				_update_tick_mask(record)
			
			if !_record_by_layer.has(layer):
				if layer is NodeCameraGroup:
					_flag_parent_tick_mask_changed()
				
				# Record was removed. We can ignore everything after.
				continue
		
		if op & DIRTY_FLAGS.TICK_MASK_CHANGED:
			rebuild_flags |= _update_tick_mask(
				_record_by_layer.get(layer, null)
			)
			
			if !_record_by_layer.has(layer):
				# Record was removed. We can ignore everything after.
				continue
		
		if op & DIRTY_FLAGS.STAGE_MASK_CHANGED:
			rebuild_flags |= _update_stage_mask(
				_record_by_layer.get(layer, null)
			)
		
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
	
	if _dirty_mask & DIRTY_FLAGS.TICK_MASK_CHANGED_DIRECT:
		rebuild_flags |= _direct_tick_mask_change
	
	if rebuild_flags:
		_force_rebuild_flat_lists(rebuild_flags)
		_flag_parent_tick_mask_changed()
	
	_clear_dirty_flags()
func _clear_dirty_flags() -> void:
	_layer_to_dirty_op.clear()
	_layer_to_old_priority.clear()
	_layer_to_force_stage.clear()
	_direct_tick_mask_change = 0
	_dirty_mask = 0
func _flag_parent_tick_mask_changed() -> void:
	if !_container_record:
		return
	var layer := _container_record.layer
	if _container_record.tick_mask == layer._get_tick_mask(self):
		return
	_container_record.parent_scope.flag_tick_mask_changed(layer)


# Scope rebuild Methods
func _force_rebuild_scope(init_stage : LAYER_STAGES) -> void:
	# Rebuilds scop and flatlists
	_construct_scope(init_stage)
	_force_rebuild_flat_lists(TICK_TYPE.BOTH)
func _force_rebuild_flat_lists(tick_mask : int) -> void:
	if tick_mask & TICK_TYPE.EFFECTS:
		_effect_storage.rebuild()
	if tick_mask & TICK_TYPE.TRANSITIONS:
		_transition_storage.rebuild()

func _construct_scope(init_stage : LAYER_STAGES) -> void:
	_clear_scope()
	if _container_record:
		var layer := _container_record.layer
		if layer is NodeCameraRoutable:
			_construct_routable_scope(init_stage, layer._route_to_layers())
			return
	_construct_group_scope(init_stage)
func _construct_routable_scope(
	init_stage : LAYER_STAGES, layers : Array[NodeCameraLayer]
) -> void:
	var mask := _host_scope.get_mask()
	var parent : NodeCameraGroup = _container_record.layer # Never null
	
	for layer : NodeCameraLayer in layers:
		if !(layer.camera_mask & mask) || !_layer_storage.is_layer_registered(layer):
			continue
		_add_layer(layer, init_stage)
func _construct_group_scope(init_stage : LAYER_STAGES) -> void:
	var mask := _host_scope.get_mask()
	var layers := _layer_storage.get_registered() # Already Priority Sorted
	
	for layer : NodeCameraLayer in layers:
		if !(layer.camera_mask & mask):
			continue
		_add_layer(layer, init_stage)

func _clear_scope() -> void:
	_effect_storage.clear()
	_transition_storage.clear()
	
	for record : LayerRecord in _record_by_layer.values():
		record.free()
	_record_by_layer.clear()


# Flag Handler Methods
func _remove_layer(layer : NodeCameraLayer) -> int:
	var record : LayerRecord = _record_by_layer.get(layer, null)
	if record == null:
		return TICK_TYPE.NONE
	
	if record.tick_mask & TICK_TYPE.EFFECTS:
		_effect_storage.remove(record, layer.priority)
	if record.tick_mask & TICK_TYPE.TRANSITIONS:
		_transition_storage.remove(record, layer.priority)
	
	if (
		record.stage != LAYER_STAGES.HAULTED &&
		record is StagedLayerRecord &&
		(record as StagedLayerRecord).get_changed_mask() & LAYER_STAGES.HAULTED
	):
		_host_scope._force_stage_change(layer, LAYER_STAGES.HAULTED)
	
	if record.paused:
		_record_by_layer.erase(layer)
		record.free()
		return TICK_TYPE_PARENT
	
	var mask := record.tick_mask
	_record_by_layer.erase(layer)
	record.free()
	return mask

func _add_layer(
	layer : NodeCameraLayer, init_stage : LAYER_STAGES = LAYER_STAGES_INHERITED
) -> int:
	if _record_by_layer.has(layer):
		return TICK_TYPE.NONE
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


func _update_stage_mask(record : StagedLayerRecord) -> int:
	if record == null:
		return TICK_TYPE.NONE
	
	record.set_masks(
		_get_stage_mask(record.layer.get_needed_process_stages()),
		_get_stage_mask(record.layer.get_needed_linger_stages()),
		_get_stage_mask(record.layer.get_needed_change_stages())
	)
	if record.packed_masks == 0:
		return _remove_layer(record.layer)
	
	return _host_scope._sync_layer_stage(record, true)

func _update_tick_mask(record : GroupLayerRecord) -> int:
	if record == null:
		return TICK_TYPE.NONE
	
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
	
	if new_mask == TICK_TYPE.NONE:
		return _remove_layer(record.layer)
	record.tick_mask = new_mask
	return mask_diff
#endregion


#region Helper Methods
func _construct_record(
	layer : NodeCameraLayer, init_stage : LAYER_STAGES = LAYER_STAGES_INHERITED
) -> LayerRecord:
	var record : LayerRecord
	if layer is NodeCameraStaged:
		record = _construct_staged_record(layer, init_stage)
	elif layer is NodeCameraGroup:
		record = _construct_multi_record(layer, init_stage)
	return record
func _construct_staged_record(
	layer : NodeCameraStaged, init_stage : LAYER_STAGES = LAYER_STAGES_INHERITED
) -> LayerRecord:
	var record := StagedLayerRecord.new()
	record.layer = layer
	record.scope = self
	
	if init_stage == LAYER_STAGES_INHERITED:
		record.stage = layer.inital_stage
	else:
		record.stage = init_stage
	
	record.set_masks(
		_get_stage_mask(layer.get_needed_process_stages()),
		_get_stage_mask(layer.get_needed_linger_stages()),
		_get_stage_mask(layer.get_needed_change_stages())
	)
	if record.packed_masks == 0:
		record.free()
		return null
	
	_host_scope._sync_layer_stage(record, true)
	if record.stage == LAYER_STAGES.HAULTED:
		record.free()
		return null
	
	if layer is NodeCameraEffect:
		record.tick_mask = TICK_TYPE.EFFECTS
	else:
		record.tick_mask = TICK_TYPE.TRANSITIONS
	return record
func _construct_multi_record(
	layer : NodeCameraGroup, init_stage : LAYER_STAGES = LAYER_STAGES_INHERITED
) -> LayerRecord:
	var record := GroupLayerRecord.new()
	
	record.layer = layer
	record.parent_scope = self
	record.scope = NodeCameraExecutionScope.new(
		_host_scope, record, layer.get_layer_storage()
	)
	
	record.scope._force_rebuild_scope(init_stage)
	record.tick_mask = layer._get_tick_mask(record.scope)
	if record.tick_mask == TICK_TYPE.NONE:
		record.free()
		return null
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
## Runs all [LayerRecord]s, classified as 'effects', within this scope.
## [br][br]
## Also see [enum TICK_TYPE].
func run_effects(delta: float, target : NodeCameraState) -> void:
	for record : LayerRecord in _effect_storage.get_flat_list():
		record.layer._scope = record.scope
		record.layer.process_effect(delta, target, record.stage)
## Runs all [LayerRecord]s, classified as 'transitions', within this scope.
## [br][br]
## Also see [enum TICK_TYPE].
func run_transitions(
	delta: float, target : NodeCameraState, current : NodeCameraState
) -> void:
	for record : LayerRecord in _transition_storage.get_flat_list():
		record.layer._scope = record.scope
		record.layer.process_transition(delta, target, current, record.stage)
#endregion


#region Accesor Access
## Returns if this scope has any [LayerRecord]s classified as 'effects'.
## [br][br]
## Also see [enum TICK_TYPE] and [method has_transitions].
func has_effects() -> bool:
	return !_effect_storage.is_empty()
## Returns if this scope has any [LayerRecord]s classified as 'transitions'.
## [br][br]
## Also see [enum TICK_TYPE] and [method has_effects].
func has_transitions() -> bool:
	return !_transition_storage.is_empty()

## Returns if this scope has any unpaused [LayerRecord]s classified as
## 'effects'.
## [br][br]
## Also see [enum TICK_TYPE] and [method has_running_transitions].
func has_running_effects() -> bool:
	return !_effect_storage.is_flat_list_empty()
## Returns if this scope has any unpaused [LayerRecord]s classified as
## 'transitions'.
## [br][br]
## Also see [enum TICK_TYPE] and [method has_running_effects].
func has_running_transitions() -> bool:
	return !_transition_storage.is_flat_list_empty()

## Returns all [LayerRecord], classified as 'effects', in this scope.
## [br][br]
## [b]NOTE[/b]: Freeing any [LayerRecord] may cause an engine crash.
func get_effect_records() -> Array[LayerRecord]:
	return _effect_storage.get_flat_list().duplicate()
## Returns all [LayerRecord], classified as 'transitions', in this scope.
## [br][br]
## [b]NOTE[/b]: Freeing any [LayerRecord] may cause an engine crash.
func get_transitions_records() -> Array[LayerRecord]:
	return _transition_storage.get_flat_list().duplicate()

## Returns all [LayerRecord] in this scope.
## [br][br]
## [b]NOTE[/b]: Freeing any [LayerRecord] may cause an engine crash.
func get_records() -> Array[LayerRecord]:
	return _record_by_layer.values()
## Returns if [param layer] has a [LayerRecord]s in this scope.
func has_record(layer : NodeCameraLayer) -> bool:
	return _record_by_layer.has(layer)
## Returns the [LayerRecord], attributed to a [param layer], if in the scope.
## [br][br]
## [b]NOTE[/b]: Freeing the returned [LayerRecord] may cause an engine crash.
func get_record(layer : NodeCameraLayer) -> LayerRecord:
	return _record_by_layer.get(layer, null)

## Returns all [NodeCameraLayer] registered to this scope.
func get_registered_layers() -> Array[NodeCameraLayer]:
	return _layer_storage.get_registered().duplicate()
#endregion

# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
