# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
@tool
class_name NodeCameraHostExecutionScope extends NodeCameraExecutionScope
## The primary host execution scope used by [NodeCameraHost] nodes.

#region Private Variables
var _host : NodeCameraHost

var _target_state : NodeCameraState
var _current_state : NodeCameraState
#endregion



#region Virtual Methods
func _init(
	host : NodeCameraHost, layer_storage : NodeCameraLayerStorage
) -> void:
	_host = host
	_host_scope = self
	_container_record = null
	
	_settup_layer_storage(layer_storage)
func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		_free_camera_states()
#endregion


#region Camera Status Methods
func _settup_camera_states() -> void:
	var cam := _host.get_camera()
	if cam is Camera2D:
		if _target_state is NodeCamera2DState:
			return
		_free_camera_states()
		_target_state = NodeCamera2DState.new()
		_current_state = NodeCamera2DState.new()
	elif cam is Camera3D:
		if _current_state is NodeCamera2DState:
			return
		_free_camera_states()
		_target_state = NodeCamera3DState.new()
		_current_state = NodeCamera3DState.new()
	else:
		_free_camera_states()
		_target_state = null
		_current_state = null
		return
	
	# Args record is referenced in both camera states
	_target_state.args = {}
	_current_state.args = _target_state.args
	
	# Overwrite the states with the current camera information
	_target_state.set_camera(cam)
	_current_state.set_camera(cam)

func _free_camera_states() -> void:
	if _target_state:
		_target_state.free()
	if _current_state:
		_current_state.free()
#endregion


#region Dirty Operations Methods
func _add_check(layer : NodeCameraLayer) -> bool:
	return true
#endregion


#region Layer State Methods
func _sync_layer_stage(
	record : StagedLayerRecord, update_start : bool = false
) -> int:
	var layer : NodeCameraStaged = record.layer
	layer._scope = record.scope
	
	var process_mask := record.get_process_mask()
	var linger_mask := record.get_linger_mask()
	var changed_mask := record.get_changed_mask()
	
	if update_start && record.stage & changed_mask:
		_force_stage_change(layer, record.stage)
	
	if !(record.stage & linger_mask):
		while record.stage > LAYER_STAGES.HAULTED:
			record.stage >>= 1
			if record.stage & changed_mask:
				_force_stage_change(layer, record.stage)
			
			if record.stage & linger_mask:
				break
	
	if record.stage == LAYER_STAGES.HAULTED:
		return record.scope._remove_layer(layer)
	if record.stage & process_mask:
		return record.scope._set_pause_layer(record, false)
	else:
		record.scope._set_pause_layer(record, true)
	
	return TICK_TYPE.NONE
func _force_stage_change(layer : NodeCameraStaged, stage : LAYER_STAGES) -> void:
	if layer is NodeCameraEffect:
		layer.effect_stage_changed(_target_state, stage)
	elif layer is NodeCameraTransition:
		layer.transition_stage_changed(_target_state, _current_state, stage)


func _advance_stage(
	layer : NodeCameraLayer, scope : NodeCameraExecutionScope
) -> int:
	return _advance_stage_record(scope.get_record(layer))
func _advance_stage_record(record : LayerRecord) -> int:
	if record == null:
		return TICK_TYPE.NONE
	if record is MultiLayerRecord:
		return _propagate_call(record.layer, record.scope, _advance_stage)
	if record.stage == LAYER_STAGES.HAULTED:
		return TICK_TYPE.NONE
	
	record.stage >>= 1
	return _sync_layer_stage(record, true)

func _overwrite_stage(
	layer : NodeCameraLayer, scope : NodeCameraExecutionScope,
	stage : LAYER_STAGES
) -> int:
	var record := scope.get_record(layer)
	if record == null && scope._add_check(layer):
		return scope._add_layer(layer, stage)
	return _overwrite_record_stage(record, stage)
func _overwrite_record_stage(
	record : LayerRecord, stage : LAYER_STAGES
) -> int:
	if record == null:
		return TICK_TYPE.NONE
	if record is MultiLayerRecord:
		return _propagate_call(record.layer, record.scope, _overwrite_stage.bind(stage))
	if record.stage == stage:
		return TICK_TYPE.NONE
	
	record.stage = stage
	return _sync_layer_stage(record, true)


func _propagate_call(
	layer : NodeCameraLayer, scope : NodeCameraExecutionScope,
	foo : Callable
) -> int:
	var mask := TICK_TYPE.NONE
	for l : NodeCameraLayer in layer._get_allowed_layers(scope):
		mask |= foo.call(l, scope)
	return mask
func _force_hault_records(scope : NodeCameraExecutionScope) -> void:
	for record : LayerRecord in scope.get_records():
		if (
			record.stage != LAYER_STAGES.HAULTED &&
			record is StagedLayerRecord &&
			(record as StagedLayerRecord).get_changed_mask() & LAYER_STAGES.HAULTED
		):
			_host_scope._force_stage_change(record.layer, LAYER_STAGES.HAULTED)
#endregion


#region Camera Movement Methods
## Sets the attached [NodeCameraHost]'s camera's values to the transitional
## 'current` [NodeCameraState].
func align_cam_position() -> void:
	_current_state.apply_status()
## Sets the attached [NodeCameraHost]'s camera's values to the effects-bound
## 'target` [NodeCameraState].
func teleport_cam_status() -> void:
	_target_state.apply_status()

## Overwrites the transitional 'current' and effects-bound 'target`
## [NodeCameraState]s to the attached [NodeCameraHost]'s camera's values
func overwrite_cam_status() -> void:
	_current_state.overwrite_status()
	_target_state.overwrite_status()
## Sets the attached [NodeCameraHost]'s camera's values, and overwrites the
## transitional 'current' [NodeCameraState], to the effects-bound 'target`
## [NodeCameraState].
func teleport_overwrite_cam_status() -> void:
	_target_state.apply_status()
	_current_state.overwrite_status()
#endregion


#region Tick Methods
## Runs all effect and transition [LayerRecord]s in order of priority.
## [br][br]
## [b]NOTE[/b]: Operations happen in a set order:[br]
## 1.) If there are no effects, return without doing anything.[br]
## 2.) Runs all effects in order of priority.[br]
## 3.) If there are no transitions, call [method teleport_cam_status] and return.[br]
## 4.) Runs all transitions in order of priority.[br]
## 5.) Call [method align_cam_position].
func run_tick(delta: float) -> void:
	if _effect_storage.is_empty():
		return
	
	run_effects(delta, _target_state)
	if _transition_storage.is_empty():
		teleport_cam_status()
		return
	
	run_transitions(delta, _target_state, _current_state)
	align_cam_position()
#endregion


#region Accessor Methods
## Returns if the attached [NodeCameraHost] is running.
## [br][br]
## Also see [method NodeCameraHost.is_running].
func is_running() -> bool:
	return _host.is_running()

## Returns the attached [NodeCameraHost]'s camera_mask.
## [br][br]
## Also see [member NodeCameraHost.camera_mask].
func get_mask() -> int:
	return _host.camera_mask
#endregion

# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
