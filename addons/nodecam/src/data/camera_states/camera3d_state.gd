# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
@tool
class_name NodeCamera3DState extends NodeCameraState
## The [NodeCameraState] class extension for [Camera3D] nodes.

#region External Variables
## The expected [member Node3D.global_position] of the [Camera3D].
@export var global_position : Vector3:
	set = set_global_position,
	get = get_global_position

## The expected [member Node3D.rotation] of the [Camera3D].
@export var rotation : Vector3:
	set = set_rotation,
	get = get_rotation
## The expected [member Node3D.rotation_degrees] of the [Camera3D].
@export var rotation_degrees : Vector3:
	set = set_rotation_degrees,
	get = get_rotation_degrees

## The expected [member Camera3D.h_offset] of the [Camera3D].
@export var h_offset : float:
	set = set_h_offset,
	get = get_h_offset
## The expected [member Camera3D.v_offset] of the [Camera3D].
@export var v_offset : float:
	set = set_v_offset,
	get = get_v_offset

## The expected [member Camera3D.fov] of the [Camera3D].
@export var fov : float = 75.0:
	set = set_fov,
	get = get_fov
## The expected [member Camera3D.near] of the [Camera3D].
@export var near : float = 0.05:
	set = set_near,
	get = get_near
## The expected [member Camera3D.far] of the [Camera3D].
@export var far : float = 4000.0:
	set = set_far,
	get = get_far
#endregion


#region Public Variables
## The camera itself. It is considered bad pratice to edit this directly.
var camera : Camera3D
#endregion


#region Private Variables
var _rotation : Vector3
#endregion



#region Public Accessor Methods
func set_global_position(val : Vector3) -> void:
	global_position = val 
func get_global_position() -> Vector3:
	return global_position

func set_rotation(val : Vector3) -> void:
	_rotation = val 
func get_rotation() -> Vector3:
	return _rotation
## Sets the [member rotation] to an angle in degrees.
func set_rotation_degrees(val : Vector3) -> void:
	_rotation = Vector3(
		deg_to_rad(val.x), deg_to_rad(val.y), deg_to_rad(val.z)
	)
## Converts [member rotation] to degrees and returns it.
func get_rotation_degrees() -> Vector3:
	return Vector3(
		rad_to_deg(_rotation.x), rad_to_deg(_rotation.y), rad_to_deg(_rotation.z)
	)

func set_h_offset(val : float) -> void:
	h_offset = val 
func get_h_offset() -> float:
	return h_offset
func set_v_offset(val : float) -> void:
	v_offset = val 
func get_v_offset() -> float:
	return v_offset

func set_fov(val : float) -> void:
	fov = val 
func get_fov() -> float:
	return fov
func set_near(val : float) -> void:
	near = val 
func get_near() -> float:
	return near
func set_far(val : float) -> void:
	far = val 
func get_far() -> float:
	return far
#endregion


#region Public Helper Methods
## An method for setting the current [Camera3D] of this
## [NodeCameraState].
func set_camera(cam : Camera3D) -> void:
	camera = cam
	apply_status()
## An method for setting the current [Camera3D] of this
## [NodeCameraState].
func get_camera() -> Camera3D:
	return camera

## A method for setting all values, of this [NodeCamera3DState],
## with the values of the given [Camera3D].
func overwrite_status() -> void:
	global_position = camera.global_position
	rotation = camera.rotation
	
	h_offset = camera.h_offset
	v_offset = camera.v_offset
	
	fov = camera.fov
	near = camera.near
	far = camera.far
## A method for setting all values, of the given [Camera3D], with
## the values of this [NodeCamera3DState].
func apply_status() -> void:
	camera.global_position = global_position
	camera.rotation = rotation
	
	camera.h_offset = h_offset
	camera.v_offset = v_offset
	
	camera.fov = fov
	camera.near = near
	camera.far = far
## A method to reassign all values to match the given
## [NodeCamera3DState].
func assign(status : NodeCamera3DState) -> void:
	global_position = status.global_position
	rotation = status.rotation
	
	h_offset = status.h_offset
	v_offset = status.v_offset
	
	fov = status.fov
	near = status.near
	far = status.far


## Returns a duplicate of the current [NodeCamera3DState].
func duplicate() -> NodeCamera3DState:
	var ret := NodeCamera3DState.new()
	ret._vars = _vars.duplicate()
	ret.set_camera(camera)
	
	ret.global_position = global_position
	ret.rotation = rotation
	
	ret.h_offset = h_offset
	ret.v_offset = v_offset
	
	ret.fov = fov
	ret.near = near
	ret.far = far
	
	return ret
#endregion

# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
