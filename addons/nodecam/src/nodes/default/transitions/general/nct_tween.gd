# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
@tool
class_name NodeCameraTweenTransition extends NodeCameraGeneralTransition
## 

#region External Variables
@export_group("Tween Settings")
## 
@export var ease_type : Tween.EaseType
## 
@export var trans_type : Tween.TransitionType
## 
@export_range(0.001, 1.0, 0.001, "or_greater") var duration : float = 0.2
#endregion


#region Private Variables
var _tween : Tween
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
	if _tween:
		_tween.kill()
	if stage == LAYER_STAGES.HAULTED:
		return
	
	_tween = create_tween()
	_tween.set_ease(ease_type)
	_tween.set_trans(trans_type)
	
	_tween.tween_method(
		_tween_transition.bind(
			target, current, current.duplicate()
		),
		0.0, 1.0, duration
	)
	_tween.tween_callback(
		get_active_scope().flag_advance_stage.bind(self)
	)
#endregion


#region Public Methods (Stages)
func get_needed_linger_stages() -> PackedInt32Array:
	return [LAYER_STAGES.RUNNING]
func get_needed_change_stages() -> PackedInt32Array:
	return [LAYER_STAGES.RUNNING, LAYER_STAGES.HAULTED]
#endregion

# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
