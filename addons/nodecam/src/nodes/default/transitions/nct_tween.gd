# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
@tool
extends NodeCameraTransition

#region External Variables
@export var ease_type : Tween.EaseType
@export var trans_type : Tween.TransitionType
@export_range(0.001, 1.0, 0.001, "or_greater") var duration : float
#endregion


#region Private Variables
var _tween : Tween
#endregion



#region Virtual Methods (User Overwrite)
func transition_stage_changed(
	target : NodeCameraState, current : NodeCameraState,
	stage : LAYER_STAGES
) -> void:
	prints(target.position, current.position, target, current)
	if _tween:
		_tween.kill()
	
	_tween = create_tween()
	_tween.set_ease(ease_type)
	_tween.set_trans(trans_type)
	_tween.set_parallel(true)
	
	if target is NodeCamera2DState:
		_tween.tween_property(
			current, "position", target.position, duration
		)
		_tween.tween_property(
			current, "rotation", target.rotation, duration
		)
		
		_tween.tween_property(
			current, "offset", target.offset, duration
		)
		_tween.tween_property(
			current, "zoom", target.zoom, duration
		)
	if target is NodeCamera3DState:
		_tween.tween_property(
			current, "position", target.position, duration
		)
		_tween.tween_property(
			current, "rotation", target.rotation, duration
		)
		
		_tween.tween_property(
			current, "h_offset", target.h_offset, duration
		)
		_tween.tween_property(
			current, "v_offset", target.v_offset, duration
		)
		
		_tween.tween_property(
			current, "fov", target.fov, duration
		)
		_tween.tween_property(
			current, "near", target.near, duration
		)
		_tween.tween_property(
			current, "far", target.far, duration
		)
	
	_tween.chain().tween_callback(get_scope().flag_advance_stage.bind(self))
#endregion


#region Public Methods (Stages)
func get_needed_linger_stages() -> PackedInt32Array:
	return [LAYER_STAGES.RUNNING]
func get_needed_change_stages() -> PackedInt32Array:
	return [LAYER_STAGES.RUNNING]
#endregion

# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
