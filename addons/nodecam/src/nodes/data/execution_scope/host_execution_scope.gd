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
		_target_state = NodeCamera2DState.new()
		_current_state = NodeCamera2DState.new()
	elif cam is Camera3D:
		if _current_state is NodeCamera2DState:
			return
		_target_state = NodeCamera3DState.new()
		_current_state = NodeCamera3DState.new()
	else:
		_target_state = null
		_current_state = null
		return
	
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
	layer: NodeCameraStaged, record : StagedLayerRecord,
	scope : NodeCameraExecutionScope,
	update_start : bool = false
) -> void:
	layer._scope = scope
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
		_remove_layer(layer)

func _set_layer_stage(
	layer : NodeCameraStaged, record : StagedLayerRecord,
	scope : NodeCameraExecutionScope,
	stage : LAYER_STAGES
) -> void:
	if record.stage == stage:
		return
	record.stage = stage
	
	_sync_layer_stage(layer, record, scope, true)
func _advance_layer_stage(
	layer : NodeCameraStaged, record : StagedLayerRecord,
	scope : NodeCameraExecutionScope
) -> void:
	record.stage >>= 1
	_sync_layer_stage(layer, record, scope, false)
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
func is_disabled() -> bool:
	return _host.disabled

func get_mask() -> int:
	return _host.camera_mask
#endregion

# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
