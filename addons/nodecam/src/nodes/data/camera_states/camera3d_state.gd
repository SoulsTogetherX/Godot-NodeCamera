# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
@tool
class_name NodeCamera3DState extends NodeCameraState
## The [NodeCameraState] class extension for [Camera3D] nodes.

#region External Variables
## The expected [member Node3D.position] of the [Camera3D].
@export var position : Vector3:
	set = set_position,
	get = get_position
## The expected [member Node3D.rotation] of the [Camera3D].
@export var rotation : Vector3:
	set = set_rotation,
	get = get_rotation

## The expected [member Camera3D.h_offset] of the [Camera3D].
@export var h_offset : float:
	set = set_h_offset,
	get = get_h_offset
## The expected [member Camera3D.v_offset] of the [Camera3D].
@export var v_offset : float:
	set = set_v_offset,
	get = get_v_offset

## The expected [member Camera3D.fov] of the [Camera3D].
@export var fov : float:
	set = set_fov,
	get = get_fov
## The expected [member Camera3D.near] of the [Camera3D].
@export var near : float:
	set = set_near,
	get = get_near
## The expected [member Camera3D.far] of the [Camera3D].
@export var far : float:
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
func set_position(val : Vector3) -> void:
	position = val 
func get_position() -> Vector3:
	return position

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
## An method for setting the current [Camera2D] of this
## [NodeCameraState].
func set_camera(cam : Node) -> void:
	if cam is Node3D:
		camera = cam
		apply_status()
## A method for setting all values, of this [NodeCamera3DState],
## with the values of the given [Camera3D].
func overwrite_status() -> void:
	position = camera.position
	rotation = camera.rotation
	
	h_offset = camera.h_offset
	v_offset = camera.v_offset
	
	fov = camera.fov
	near = camera.near
	far = camera.far
## A method for setting all values, of the given [Camera3D], with
## the values of this [NodeCamera3DState].
func apply_status() -> void:
	camera.position = position
	camera.rotation = rotation
	
	camera.h_offset = h_offset
	camera.v_offset = v_offset
	
	camera.fov = fov
	camera.near = near
	camera.far = far
#endregion

# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
