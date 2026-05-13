# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
@tool
class_name NodeCameraTweenTransition extends NodeCameraGeneralTransition
## A general transitions that uses a tween to transition property values.

#region External Variables
@export_group("Tween Settings")
## The EaseType that will be used to tween between property values.
## [br][br]
## Also see [Tween] and [enum Tween.EaseType].
@export var ease_type : Tween.EaseType
## The TransitionType that will be used to tween between property values.
## [br][br]
## Also see [Tween] and [enum Tween.TransitionType].
@export var trans_type : Tween.TransitionType
## The duration the tween will take until finished.
## [br][br]
## Also see [Tween].
@export_range(0.001, 1.0, 0.001, "or_greater") var duration : float = 0.5

@export_group("Extra Args")
## The TweenProcessModethat will be used to tween between property values.
## This is ignored if [member manual_step] is [code]true[/code].
## [br][br]
## Also see [Tween] and [enum Tween.TweenProcessMode].
@export var tween_process_mode : Tween.TweenProcessMode = Tween.TweenProcessMode.TWEEN_PROCESS_PHYSICS

## If [code]true[/code], this transition will use [method custom_step]
## for tween transitions instead. Can cause issues if value is changed
## mid-transition.
@export var manual_step : bool = false
#endregion



#region Private Methods
func _tween_transition(
	delta : float, target : NodeCameraState, current : NodeCameraState,
	st : NodeCameraState
) -> void:
	# BOTH
	if _op_mask & CAMERA_PROPERTY.POSITION:
		current.global_position = (
			st.global_position + delta * (target.global_position - st.global_position)
		)
	else:
		current.global_position = target.global_position
	
	
	# 2D
	if current is NodeCamera2DState:
		if _op_mask & CAMERA_PROPERTY.ROTATION:
			current.rotation = (
				st.rotation + delta * (target.rotation - st.rotation)
			)
		else:
			current.rotation = target.rotation
		
		
		if _op_mask & CAMERA_PROPERTY.OFFSET:
			current.offset = (
				st.offset + delta * (target.offset - st.offset)
			)
		else:
			current.offset = target.offset
		
		if _op_mask & CAMERA_PROPERTY.ZOOM:
			current.zoom = (
				st.zoom + delta * (target.zoom - st.zoom)
			)
		else:
			current.zoom = target.zoom
	
	# 3D
	if current is NodeCamera3DState:
		if _op_mask & CAMERA_PROPERTY.ROTATION:
			current.rotation = (
				st.rotation + delta * wrapf(
					target.rotation - st.rotation, -180, 180
				)
			)
		else:
			current.rotation = target.rotation
		
		
		if _op_mask & CAMERA_PROPERTY.H_OFFSET:
			current.h_offset = (
				st.h_offset + delta * (target.h_offset - st.h_offset)
			)
		else:
			current.h_offset = target.h_offset
		
		if _op_mask & CAMERA_PROPERTY.V_OFFSET:
			current.v_offset = (
				st.v_offset + delta * (target.v_offset - st.v_offset)
			)
		else:
			current.v_offset = target.v_offset
		
		
		if _op_mask & CAMERA_PROPERTY.FOV:
			current.fov = (
				st.fov + delta * (target.fov - st.fov)
			)
		else:
			current.fov = target.fov
		
		if _op_mask & CAMERA_PROPERTY.NEAR:
			current.near = (
				st.near + delta * (target.near - st.near)
			)
		else:
			current.near = target.near
		
		if _op_mask & CAMERA_PROPERTY.FAR:
			current.far = (
				st.far + delta * (target.far - st.far)
			)
		else:
			current.far = target.far
#endregion


#region Virtual Methods (User Overwrite)
func transition_stage_changed(
	target : NodeCameraState, current : NodeCameraState,
	stage : LAYER_STAGES
) -> void:
	var tween : Tween = target.get_var(self, null)
	if tween:
		tween.kill()
	if stage == LAYER_STAGES.HAULTED:
		target.clear_var(self)
		return
	
	tween = create_tween()
	tween.set_ease(ease_type)
	tween.set_trans(trans_type)
	tween.set_process_mode(tween_process_mode)
	
	if manual_step:
		tween.pause()
	
	var dup : NodeCameraState = current.duplicate()
	tween.tween_method(
		_tween_transition.bind(target, current, dup),
		0.0, 1.0, duration
	)
	tween.tween_callback(dup.free)
	tween.tween_callback(get_active_scope().flag_advance_stage.bind(self))
	
	target.set_var(self, tween)
func process_transition(
	delta : float, target : NodeCameraState, _current : NodeCameraState,
	_stage : LAYER_STAGES
) -> void:
	(target.get_var(self) as Tween).custom_step(delta)
#endregion


#region Public Methods (Stages)
func get_needed_process_stages() -> PackedInt32Array:
	if manual_step:
		return [LAYER_STAGES.RUNNING]
	return []
func get_needed_linger_stages() -> PackedInt32Array:
	return [LAYER_STAGES.RUNNING]
func get_needed_change_stages() -> PackedInt32Array:
	return [LAYER_STAGES.RUNNING, LAYER_STAGES.HAULTED]
#endregion


#region Accessor Methods
func set_manual_step(val : bool) -> void:
	if val == manual_step:
		return
	manual_step = val
	notify_stage_masks_changed()
func get_manual_step() -> bool:
	return manual_step
#endregion

# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
