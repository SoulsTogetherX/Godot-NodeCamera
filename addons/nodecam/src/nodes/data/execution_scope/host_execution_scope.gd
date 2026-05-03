# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
@tool
class_name NodeCamera2DHostExecutionScope extends NodeCamera2DExecutionScope

#region Private Variables
var _host : NodeCamera2DHost

var _current_state := NodeCameraState.new()
var _target_state := NodeCameraState.new()
#endregion



#region Virtual Methods
func _init(
	host : NodeCamera2DHost, 
	layer_storage : NodeCamera2DLayerStorage
) -> void:
	_host = host
	_host_scope = self
	_parent_record = null
	_layer_storage = layer_storage

func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		_current_state.free()
		_target_state.free()
#endregion


#region Layer State Methods
func _sync_layer_stage(
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
		while record.stage > LAYER_STAGES.HAULTED:
			record.stage >>= 1
			if record.stage & record.stage_changed_mask > 0:
				if layer is NodeCamera2DEffect:
					layer.effect_stage_changed(_target_state, record.stage)
				elif layer is NodeCamera2DTransition:
					layer.transition_stage_changed(_target_state, _current_state, record.stage)
			
			if record.stage & record.stage_process_mask > 0:
				break
	if record.stage == LAYER_STAGES.HAULTED && allow_remove:
		scope._remove_layer(layer)

func _set_layer_stage(
	layer : NodeCamera2DStaged, record : StagedLayerRecord,
	scope : NodeCamera2DExecutionScope,
	stage : LAYER_STAGES
) -> void:
	if record.stage == stage:
		return
	record.stage = stage
	
	_sync_layer_stage(layer, record, scope, true, true)
func _advance_layer_stage(
	layer : NodeCamera2DStaged, record : StagedLayerRecord,
	scope : NodeCamera2DExecutionScope
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
