# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
@tool
class_name NodeCameraTweenTransition extends NodeCameraGeneralTransition

#region External Variables
@export_group("Tween Settings")
@export var ease_type : Tween.EaseType
@export var trans_type : Tween.TransitionType
@export_range(0.001, 1.0, 0.001, "or_greater") var duration : float = 0.2
#endregion



#region Private Variables
var _tween : Tween
#endregion



#region Virtual Methods (User Overwrite)
func transition_stage_changed(
	target : NodeCameraState, current : NodeCameraState,
	stage : LAYER_STAGES
) -> void:
	if _tween:
		_tween.kill()
	if stage == LAYER_STAGES.HAULTED:
		return
	
	_tween = create_tween()
	_tween.set_ease(ease_type)
	_tween.set_trans(trans_type)
	_tween.set_parallel(true)
	
	if target is NodeCamera2DState:
		if _op_mask & CAMERA_PROPERTY.POSITION:
			_tween.tween_property(
				current, "global_position", target.global_position, duration
			)
		if _op_mask & CAMERA_PROPERTY.ROTATION:
			_tween.tween_property(
				current, "rotation", target.rotation, duration
			)
		
		if _op_mask & CAMERA_PROPERTY.OFFSET:
			_tween.tween_property(
				current, "offset", target.offset, duration
			)
		if _op_mask & CAMERA_PROPERTY.ZOOM:
			_tween.tween_property(
				current, "zoom", target.zoom, duration
			)
	if target is NodeCamera3DState:
		if _op_mask & CAMERA_PROPERTY.POSITION:
			_tween.tween_property(
				current, "global_position", target.global_position, duration
			)
		if _op_mask & CAMERA_PROPERTY.ROTATION:
			_tween.tween_property(
				current, "rotation", target.rotation, duration
			)
		
		if _op_mask & CAMERA_PROPERTY.H_OFFSET:
			_tween.tween_property(
				current, "h_offset", target.h_offset, duration
			)
		if _op_mask & CAMERA_PROPERTY.V_OFFSET:
			_tween.tween_property(
				current, "v_offset", target.v_offset, duration
			)
		
		if _op_mask & CAMERA_PROPERTY.FOV:
			_tween.tween_property(
				current, "fov", target.fov, duration
			)
		if _op_mask & CAMERA_PROPERTY.NEAR:
			_tween.tween_property(
				current, "near", target.near, duration
			)
		if _op_mask & CAMERA_PROPERTY.FAR:
			_tween.tween_property(
				current, "far", target.far, duration
			)
	
	_tween.chain().tween_callback(advance_stage)
#endregion


#region Public Methods (Stages)
func get_needed_linger_stages() -> PackedInt32Array:
	return [LAYER_STAGES.RUNNING]
func get_needed_change_stages() -> PackedInt32Array:
	return [LAYER_STAGES.RUNNING, LAYER_STAGES.HAULTED]
#endregion

# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
