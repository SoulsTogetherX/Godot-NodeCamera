# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
@tool
class_name NodeCamera2DHostContext extends Object


#region Private Variables (Camera Status)
var _host : NodeCamera2DHost

var _current_state := NodeCameraState.new()
var _target_state := NodeCameraState.new()

var _main_scope := NodeCamera2DExecutionScope.new(self)
#endregion



#region Virtual Methods (Engine)
func _init(host : NodeCamera2DHost) -> void:
	_host = host

func _notification(what: int) -> void:
	match what:
		NOTIFICATION_PREDELETE:
			_current_state.free()
			_target_state.free()
			_main_scope.free()
#endregion


#region Layer Management Methods
func sync_stage(
	layer: NodeCamera2DStaged, record : StagedLayerRecord,
	scope : NodeCamera2DExecutionScope,
	update_start : bool = false, allow_remove : bool = true
) -> void:
	layer._scope = scope
	if update_start:
		if layer is NodeCamera2DEffect:
			layer.effect_stage_changed(_target_state, record.stage)
		elif layer is NodeCamera2DTransition:
			layer.transition_stage_changed(_target_state, _current_state, record.stage)
	
	if record.stage & record.stage_process_mask == 0:
		while record.stage > NodeCamera2DConstants.LAYER_STAGES.HAULTED:
			record.stage >>= 1
			if record.stage & record.stage_changed_mask > 0:
				if layer is NodeCamera2DEffect:
					layer.effect_stage_changed(_target_state, record.stage)
				elif layer is NodeCamera2DTransition:
					layer.transition_stage_changed(_target_state, _current_state, record.stage)
			
			if record.stage & record.stage_process_mask > 0:
				break
	if record.stage == NodeCamera2DConstants.LAYER_STAGES.HAULTED && allow_remove:
		scope._remove_layer(layer)

func set_layer_to_stage(
	layer : NodeCamera2DStaged, record : StagedLayerRecord,
	scope : NodeCamera2DExecutionScope,
	stage : NodeCamera2DConstants.LAYER_STAGES
) -> void:
	if record.stage == stage:
		return
	record.stage = stage
	
	sync_stage(layer, record, scope, true, true)
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
	if _main_scope.effects_empty():
		return
	
	_main_scope.run_effects(_target_state)
	if _main_scope.transitions_empty():
		teleport_position()
		return
	
	_main_scope.run_transitions(_target_state, _current_state)
	align_position()
#endregion


#region Accessor Methods
func get_mask() -> int:
	return _host.camera_mask
func get_scope() -> NodeCamera2DExecutionScope:
	return _main_scope

func is_disabled() -> bool:
	return _host.disabled
#endregion

# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
