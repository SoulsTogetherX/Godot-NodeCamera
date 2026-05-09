# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
@tool
class_name NodeCamera2DState extends NodeCameraState
## The [NodeCameraState] class extension for [Camera2D] nodes.

#region External Variables
## The expected [member Node2D.position] of the [Camera2D].
@export var position : Vector2:
	set = set_position,
	get = get_position
## The expected [member Node2D.rotation] of the [Camera2D].
@export var rotation : float:
	set = set_rotation,
	get = get_rotation

## The expected [member Camera2D.offset] of the [Camera2D].
@export var offset : Vector2:
	set = set_offset,
	get = get_offset
## The expected [member Camera2D.zoom] of the [Camera2D].
@export var zoom : Vector2 = Vector2.ONE:
	set = set_zoom,
	get = get_zoom
#endregion


#region Public Variables
## The camera itself. It is considered bad pratice to edit this directly.
var camera : Camera2D
#endregion


#region Private Variables
var _rotation : float
#endregion



#region Public Accessor Methods
func set_position(val : Vector2) -> void:
	position = val 
func get_position() -> Vector2:
	return position

func set_rotation(val : float) -> void:
	_rotation = val 
func get_rotation() -> float:
	return _rotation
## Sets the [member rotation] to an angle in degrees.
func set_rotation_degrees(val : float) -> void:
	_rotation = deg_to_rad(val) 
## Converts [member rotation] to degrees and returns it.
func get_rotation_degrees() -> float:
	return rad_to_deg(_rotation)

func set_offset(val : Vector2) -> void:
	offset = val 
func get_offset() -> Vector2:
	return offset

func set_zoom(val : Vector2) -> void:
	zoom = val 
func get_zoom() -> Vector2:
	return zoom
#endregion


#region Public Helper Methods
## An method for setting the current [Camera2D] of this
## [NodeCameraState].
func set_camera(cam : Node) -> void:
	if cam is Node2D:
		camera = cam
		apply_status()
## A method for setting all values, of this [NodeCamera2DState],
## with the values of the given [Camera2D].
func overwrite_status() -> void:
	position = camera.position
	offset = camera.offset
	zoom = camera.zoom
	_rotation = camera.rotation
## A method for setting all values, of the given [Camera2D], with
## the values of this [NodeCamera2DState].
func apply_status() -> void:
	camera.position = position
	camera.offset = offset
	camera.zoom = zoom
	camera.rotation = _rotation
#endregion

# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
