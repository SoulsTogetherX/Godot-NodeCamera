# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
@tool
class_name NodeCameraTransitionLerp extends NodeCameraTransitionGeneral
## A general transition that uses lerp to transition property values.

#region External Variables
## The lerp factor used.
@export_range(0, 1, 0.001, "or_less", "or_greater")
var factor : float = 0.95

## If [code]true[/code], this layer scale the factor according to
## the delta.
## [br][br]
## Ths can make the lerping feel sluggish.
@export var scale_factor_to_delta : bool = false

## If [code]true[/code], this layer will halt if [b]ALL[/b]
## transitioning properties are within [member threshold] distance.
@export var auto_halt : bool = true
## The distance [b]ALL[/b] transitioning properties need to be within
## for this layer to halt. Also see [member auto_halt].
@export_range(0, 10.0, 0.001) var threshold : float = 1.0
#endregion



#region Virtual Methods (User Overwrite)
func process_transition(
	delta : float, target : NodeCameraState, current : NodeCameraState,
	stage : LAYER_STAGES
) -> void:
	var f := (
		1.0 - pow(1.0 - factor, delta) if scale_factor_to_delta
		else factor
	)
	var disable_check : bool = true
	
	# BOTH
	if _op_mask & CAMERA_PROPERTY.POSITION:
		current.global_position = current.global_position.lerp(
			target.global_position, f
		)
		disable_check = (
			disable_check &&
			current.global_position.distance_squared_to(target.global_position) < threshold
		)
	
	
	# 2D
	if current is NodeCamera2DState:
		if _op_mask & CAMERA_PROPERTY.ROTATION:
			current.rotation = lerp_angle(current.rotation, target.rotation, f)
			disable_check = (
				disable_check &&
				abs(current.rotation - target.rotation) < threshold
			)
		
		
		if _op_mask & CAMERA_PROPERTY.OFFSET:
			current.offset = current.offset.lerp(target.offset, f)
			disable_check = (
				disable_check &&
				current.offset.distance_squared_to(target.offset) < threshold
			)
		
		if _op_mask & CAMERA_PROPERTY.ZOOM:
			current.zoom = current.zoom.lerp(target.zoom, f)
			disable_check = (
				disable_check &&
				current.zoom.distance_squared_to(target.zoom) < threshold
			)
	
	# 3D
	if current is NodeCamera3DState:
		if _op_mask & CAMERA_PROPERTY.ROTATION:
			current.rotation = Vector3(
				lerp_angle(current.rotation.x, target.rotation.x, f),
				lerp_angle(current.rotation.y, target.rotation.y, f),
				lerp_angle(current.rotation.z, target.rotation.z, f)
			)
			disable_check = (
				disable_check &&
				current.rotation.distance_squared_to(target.rotation) < threshold
			)
		
		
		if _op_mask & CAMERA_PROPERTY.H_OFFSET:
			current.h_offset = lerpf(current.h_offset, target.h_offset, f)
			disable_check = (
				disable_check &&
				abs(current.h_offset - target.h_offset) < threshold
			)
		
		if _op_mask & CAMERA_PROPERTY.V_OFFSET:
			current.v_offset = lerpf(current.v_offset, target.v_offset, f)
			disable_check = (
				disable_check &&
				abs(current.v_offset - target.v_offset) < threshold
			)
		
		
		if _op_mask & CAMERA_PROPERTY.FOV:
			current.fov = lerpf(current.fov, target.fov, f)
			disable_check = (
				disable_check &&
				abs(current.fov - target.fov) < threshold
			)
		
		if _op_mask & CAMERA_PROPERTY.NEAR:
			current.near = lerpf(current.near, target.near, f)
			disable_check = (
				disable_check &&
				abs(current.near - target.near) < threshold
			)
		
		if _op_mask & CAMERA_PROPERTY.FAR:
			current.far = lerpf(current.far, target.far, f)
			disable_check = (
				disable_check &&
				abs(current.far - target.far) < threshold
			)
	
	if disable_check && auto_halt:
		advance_stage()
#endregion


#region Public Methods (Stages)
func get_needed_process_stages() -> PackedInt32Array:
	return [LAYER_STAGES.RUNNING]
#endregion

# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
