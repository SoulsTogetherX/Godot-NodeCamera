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
func _init(host : NodeCameraHost) -> void:
	_host = host
	_host_scope = self
	_container_record = null
func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		_free_camera_states.call_deferred()
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
	_target_state._vars = {}
	_current_state._vars = _target_state._vars
	
	# Overwrite the states with the current camera information
	_target_state.set_camera(cam)
	_current_state.set_camera(cam)
	
	_target_state.overwrite_status()
	_current_state.overwrite_status()

func _free_camera_states() -> void:
	if _target_state:
		_target_state.free()
	if _current_state:
		_current_state.free()
#endregion


#region Layer State Methods
func _sync_layer_stage(
	record : StagedLayerRecord, update_start : bool = false
) -> int:
	var layer : NodeCameraStaged = record.layer
	layer._scope = record.scope
	
	var process_mask := get_process_mask(record)
	var linger_mask := get_linger_mask(record)
	var changed_mask := get_changed_mask(record)
	
	if update_start && record.stage & changed_mask:
		_force_stage_change(layer, record.stage)
	
	if !(record.stage & linger_mask):
		while record.stage > LAYER_STAGES.HALTED:
			record.stage >>= 1
			if record.stage & changed_mask:
				_force_stage_change(layer, record.stage)
			
			if record.stage & linger_mask:
				break
	
	if record.stage == LAYER_STAGES.HALTED:
		return record.scope._remove_layer(layer)
	if record.stage & process_mask:
		return record.scope._set_pause_layer(record, false)
	return record.scope._set_pause_layer(record, true)
func _force_stage_change(layer : NodeCameraStaged, stage : LAYER_STAGES) -> void:
	if layer is NodeCameraEffect:
		layer.effect_stage_changed(_target_state, stage)
	elif layer is NodeCameraTransition:
		layer.transition_stage_changed(_target_state, _current_state, stage)


func _advance_stage_record(record : LayerRecord) -> int:
	if record == null:
		return TICK_TYPE.NONE
	if record is GroupLayerRecord:
		return _propagate_call_record(
			record, _advance_stage_record
		)
	if record.stage == LAYER_STAGES.HALTED:
		return record.scope._remove_layer(record.layer)
	
	record.stage >>= 1
	return _sync_layer_stage(record, true)

func _advance_to_stage_record(
	record : LayerRecord, stage : LAYER_STAGES
) -> int:
	if record == null:
		return TICK_TYPE.NONE
	if record is GroupLayerRecord:
		return _propagate_call_record(
			record, _advance_to_stage_record.bind(stage)
		)
	if stage == LAYER_STAGES_INHERITED:
		stage = record.layer.inital_stage
	if record.stage == LAYER_STAGES.HALTED:
		return record.scope._remove_layer(record.layer)
	if record.stage <= stage:
		return TICK_TYPE.NONE
	
	record.stage = stage
	return _sync_layer_stage(record, true)

func _overwrite_stage(
	layer : NodeCameraLayer, scope : NodeCameraExecutionScope,
	stage : LAYER_STAGES
) -> int:
	var record := scope.get_record(layer)
	if record == null:
		return scope._add_layer(layer, stage)
	return _overwrite_record_stage(record, stage)
func _overwrite_record_stage(
	record : LayerRecord, stage : LAYER_STAGES
) -> int:
	if record == null:
		return TICK_TYPE.NONE
	if record is GroupLayerRecord:
		return _propagate_call(
			record.layer, record.scope, _overwrite_stage.bind(stage)
		)
	if stage == LAYER_STAGES_INHERITED:
		stage = record.layer.inital_stage
	if record.stage == stage:
		return TICK_TYPE.NONE
	
	record.stage = stage
	return _sync_layer_stage(record, true)


func _propagate_call(
	layer : NodeCameraGroup, scope : NodeCameraExecutionScope,
	foo : Callable
) -> int:
	var mask := TICK_TYPE.NONE
	if layer is NodeCameraRoutable:
		for l : NodeCameraLayer in layer._route_to_layers():
			mask |= foo.call(l, scope)
	else:
		for l : NodeCameraLayer in layer._layer_storage.get_registered():
			mask |= foo.call(l, scope)
	
	scope.flag_tick_mask_direct_changed(mask)
	return mask
func _propagate_call_record(
	record : LayerRecord, foo : Callable
) -> int:
	var mask := TICK_TYPE.NONE
	var layer := record.layer
	var scope := record.scope
	
	if layer is NodeCameraRoutable:
		for l : NodeCameraLayer in layer._route_to_layers():
			mask |= foo.call(scope.get_record(l))
	else:
		for l : NodeCameraLayer in layer._layer_storage.get_registered():
			mask |= foo.call(scope.get_record(l))
	
	scope.flag_tick_mask_direct_changed(mask)
	return mask

func _force_halt_records(scope : NodeCameraExecutionScope) -> void:
	for record : LayerRecord in scope.get_records():
		if (
			record.stage != LAYER_STAGES.HALTED &&
			record is StagedLayerRecord && record.layer &&
			get_changed_mask(record) & LAYER_STAGES.HALTED
		):
			_host_scope._force_stage_change(record.layer, LAYER_STAGES.HALTED)
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
## 1.) Runs all effects in order of priority.[br]
## 2.) If there are no transitions, overwrite the 'current'
## state with the 'target' state, then set the camera to the
## 'target' state and return.[br]
## 3.) Runs all transitions in order of priority.[br]
## 4.) Set the camera to be the 'current' state.
func run_tick(delta: float) -> void:
	if _effect_storage.is_empty():
		return
	
	run_effects(delta, _target_state)
	if _transition_storage.is_empty():
		_target_state.apply_status()
		_current_state.assign(_target_state)
		return
	
	run_transitions(delta, _target_state, _current_state)
	_current_state.apply_status()
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
