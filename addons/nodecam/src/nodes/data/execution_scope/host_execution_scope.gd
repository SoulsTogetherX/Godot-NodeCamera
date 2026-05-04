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
	host : NodeCameraHost, layer_storage : NodeCameraLayerStorage,
	target_state : NodeCameraState, current_state : NodeCameraState
) -> void:
	_host = host
	_host_scope = self
	_parent_record = null
	
	set_target_state(target_state)
	set_current_state(current_state)
	_settup_layer_storage(layer_storage)
#endregion


#region Camera Status Methods
func set_target_state(state : NodeCameraState) -> void:
	if state == null:
		state = NodeCamera2DState.new()
	_target_state = state
func set_current_state(state : NodeCameraState) -> void:
	if state == null:
		state = NodeCamera2DState.new()
	_current_state = state
#endregion


#region Layer State Methods
func _sync_layer_stage(
	layer: NodeCameraStaged, record : StagedLayerRecord,
	scope : NodeCameraExecutionScope,
	update_start : bool = false, allow_remove : bool = true
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
	if record.stage == LAYER_STAGES.HAULTED && allow_remove:
		scope._remove_layer(layer)

func _set_layer_stage(
	layer : NodeCameraStaged, record : StagedLayerRecord,
	scope : NodeCameraExecutionScope,
	stage : LAYER_STAGES
) -> void:
	if record.stage == stage:
		return
	record.stage = stage
	
	_sync_layer_stage(layer, record, scope, true, true)
func _advance_layer_stage(
	layer : NodeCameraStaged, record : StagedLayerRecord,
	scope : NodeCameraExecutionScope
) -> void:
	record.stage >>= 1
	_sync_layer_stage(layer, record, scope, false, true)
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
