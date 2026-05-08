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
	_container_record = null
	
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


func _advance_stage_record(record : LayerRecord) -> int:
	if record == null:
		return TICK_TYPE.NONE
	if record is MultiLayerRecord:
		return TICK_TYPE.NONE
	if record.stage == LAYER_STAGES.HAULTED:
		return TICK_TYPE.NONE
	
	record.stage >>= 1
	return _sync_layer_stage(record, true)

func _overwrite_stage(
	layer : NodeCameraLayer, scope : NodeCameraExecutionScope,
	stage : LAYER_STAGES
) -> int:
	var record := scope.get_record(layer)
	if record == null:
		if stage != LAYER_STAGES.HAULTED:
			return scope._add_layer(layer, stage)
		return TICK_TYPE.NONE
	return _overwrite_record_stage(record, stage)
func _overwrite_record_stage(
	record : LayerRecord, stage : LAYER_STAGES
) -> int:
	if record == null:
		return TICK_TYPE.NONE
	if record is MultiLayerRecord:
		return TICK_TYPE.NONE
	
	record.stage = stage
	return _sync_layer_stage(record, true)

func _force_hault_records(scope : NodeCameraExecutionScope) -> void:
	for record : LayerRecord in scope.get_records():
		if (
			record.stage != LAYER_STAGES.HAULTED &&
			record.get_changed_mask() & LAYER_STAGES.HAULTED
		):
			# NOTE: MultiLayerRecord always have a stage of LAYER_STAGES.HAULTED
			_host_scope._force_stage_change(record.layer, LAYER_STAGES.HAULTED)
#endregion


#region Camera Movement Methods
func align_cam_position() -> void:
	_current_state.apply_status(_host.get_camera())
func teleport_cam_position() -> void:
	_target_state.apply_status(_host.get_camera())

func overwrite_cam_status() -> void:
	var cam := _host.get_camera()
	_current_state.overwrite_status(cam)
	_target_state.overwrite_status(cam)
func teleport_cam_status() -> void:
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
		teleport_cam_position()
		return
	
	run_transitions(_target_state, _current_state)
	align_cam_position()
#endregion


#region Accessor Methods
func is_running() -> bool:
	return _host.is_running()
func is_paused() -> bool:
	return false

func get_mask() -> int:
	return _host.camera_mask
#endregion

# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
