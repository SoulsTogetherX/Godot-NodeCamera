# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
@tool
class_name NodeCameraHostExecutionScope extends NodeCameraExecutionScope

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
	_parent_record = null
	
	_settup_layer_storage(layer_storage)
func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		_free_camera_states()
#endregion


#region Camera Status Methods
func settup_camera_states() -> void:
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
	_target_state.overwrite_status(cam)
	_current_state.overwrite_status(cam)
func _free_camera_states() -> void:
	if _target_state:
		_target_state.free()
	if _current_state:
		_current_state.free()
#endregion


#region Layer State Methods
func sync_layer_stage(
	record : StagedLayerRecord, update_start : bool = false
) -> int:
	var layer : NodeCameraStaged = record.layer
	layer._scope = record.scope
	
	if update_start:
		if layer is NodeCameraEffect:
			layer.effect_stage_changed(_target_state, record.stage)
		elif layer is NodeCameraTransition:
			layer.transition_stage_changed(_target_state, _current_state, record.stage)
	
	if record.stage & record.stage_process_mask == 0:
		while record.stage > LAYER_STAGES.HAULTED:
			record.stage >>= 1
			if record.stage & record.stage_changed_mask > 0:
				if layer is NodeCameraEffect:
					layer.effect_stage_changed(_target_state, record.stage)
				elif layer is NodeCameraTransition:
					layer.transition_stage_changed(_target_state, _current_state, record.stage)
			
			if record.stage & record.stage_process_mask > 0:
				break
	if record.stage == LAYER_STAGES.HAULTED:
		return record.scope._remove_layer(layer)
	return TICK_TYPE.NONE

func advance_stage(record : LayerRecord) -> int:
	if record == null:
		return TICK_TYPE.NONE
	if record is MultiLayerRecord:
		return propagate_advance_stage(record)
	
	record.stage >>= 1
	return sync_layer_stage(record, false)
func overwrite_stage(
	record : LayerRecord, stage : LAYER_STAGES
) -> int:
	if record == null:
		return TICK_TYPE.NONE
	if record is MultiLayerRecord:
		return propagate_overwrite_stage(record, stage)
	if record.stage == stage:
		return TICK_TYPE.NONE
	
	record.stage = stage
	return sync_layer_stage(record, true)

func propagate_advance_stage(record : MultiLayerRecord) -> int:
	var mask := TICK_TYPE.NONE
	for rec : LayerRecord in record.scope.get_effect_records():
		mask |= advance_stage(rec)
	for rec : LayerRecord in record.scope.get_transitions_records():
		mask |= advance_stage(rec)
	
	return mask
func propagate_overwrite_stage(
	record : MultiLayerRecord, stage : LAYER_STAGES
) -> int:
	var mask := TICK_TYPE.NONE
	for rec : LayerRecord in record.scope.get_effect_records():
		mask |= overwrite_stage(rec, stage)
	for rec : LayerRecord in record.scope.get_transitions_records():
		mask |= overwrite_stage(rec, stage)
	
	return mask
#endregion


#region Camera Movement Methods
func align_position() -> void:
	_current_state.apply_status(_host.get_camera())
func teleport_position() -> void:
	_target_state.apply_status(_host.get_camera())

func overwrite_status() -> void:
	var cam := _host.get_camera()
	_current_state.overwrite_status(cam)
	_target_state.overwrite_status(cam)
func teleport_overwrite() -> void:
	var cam := _host.get_camera()
	_target_state.apply_status(cam)
	_current_state.overwrite_status(cam)
#endregion


#region Tick Methods
func run_tick() -> void:
	if _effect_storage.is_empty():
		return
	
	run_effects(_target_state)
	if _transition_storage.is_empty():
		teleport_position()
		return
	
	run_transitions(_target_state, _current_state)
	align_position()
#endregion


#region Host Accessor Methods
func is_running() -> bool:
	return _host.is_running()

func get_mask() -> int:
	return _host.camera_mask
#endregion

# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
