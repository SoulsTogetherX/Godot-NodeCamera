# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
@tool
class_name NodeCamera2DState extends NodeCameraState
## The [NodeCameraState] class extension for [Camera2D] nodes.

#region External Variables
## The expected [member Node2D.position] of the [Camera2D].
@export var position : Vector2:
	set = set_position,
	get = get_position
## The expected [member Camera2D.offset] of the [Camera2D].
@export var offset : Vector2:
	set = set_offset,
	get = get_offset
## The expected [member Camera2D.zoom] of the [Camera2D].
@export var zoom : Vector2 = Vector2.ONE:
	set = set_zoom,
	get = get_zoom
## The expected [member Node2D.rotation] of the [Camera2D].
@export var rotation : float:
	set = set_rotation,
	get = get_rotation
#endregion


#region Private Variables
var _rotation : float
#endregion



#region Public Accessor Methods
func set_position(val : Vector2) -> void:
	position = val 
func get_position() -> Vector2:
	return position

func set_offset(val : Vector2) -> void:
	offset = val 
func get_offset() -> Vector2:
	return offset

func set_zoom(val : Vector2) -> void:
	zoom = val 
func get_zoom() -> Vector2:
	return zoom

func set_rotation(val : float) -> void:
	_rotation = val 
func get_rotation() -> float:
	return _rotation

## Sets the [member rotation] to an angle in degrees.
func set_rotation_degrees(val : float) -> void:
	_rotation = deg_to_rad(_rotation) 
## Converts [member rotation] to degrees and returns it.
func get_rotation_degrees() -> float:
	return rad_to_deg(_rotation)
#endregion


#region Public Helper Methods
## A method for setting all values, of this [NodeCamera2DState],
## with the values of the given [Camera2D].
func overwrite_status(cam : Node) -> void:
	if !(cam is Camera2D):
		return
	position = cam.position
	offset = cam.offset
	zoom = cam.zoom
	_rotation = cam.rotation
## A method for setting all values, of the given [Camera2D], with
## the values of this [NodeCamera2DState].
func apply_status(cam : Node) -> void:
	if !(cam is Camera2D):
		return
	cam.position = position
	cam.offset = offset
	cam.zoom = zoom
	cam.rotation = _rotation
#endregion

# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
