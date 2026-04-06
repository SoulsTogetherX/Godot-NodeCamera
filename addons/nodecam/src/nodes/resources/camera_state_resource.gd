# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
@tool
class_name GoCameraStateResource extends Resource
## A basic [Resource] used to hold, store, and manipulate the status of a camera.


#region External Variables
## The offset state of a camera.
@export var offset : Vector2:
	set = set_offset,
	get = get_offset
## The position state of a camera.
@export var position : Vector2:
	set = set_position,
	get = get_position
## The zoom state of a camera.
@export var zoom : Vector2:
	set = set_zoom,
	get = get_zoom

## The rotational (radians) state of a camera.
@export_custom(
	0, "", PROPERTY_USAGE_EDITOR
) var rotation : float:
	set = set_rotation,
	get = get_rotation
## The rotational (degrees) state of a camera.
var rotation_degrees : float:
	set = set_rotation_degrees,
	get = get_rotation_degrees
#endregion


#region Private Variables
var _rotation : float
#endregion



#region Public Methods (Accessor)
## Sets the offset state of a camera.
func set_offset(val : Vector2) -> void:
	if val == offset:
		return
	offset = val
	emit_changed()
## Gets the offset state of a camera.
func get_offset() -> Vector2:
	return offset

## Sets the position state of a camera.
func set_position(val : Vector2) -> void:
	if val == position:
		return
	position = val
	emit_changed()
## Gets the position state of a camera.
func get_position() -> Vector2:
	return position

## Sets the zoom state of a camera.
func set_zoom(val : Vector2) -> void:
	if val == zoom:
		return
	zoom = val
	emit_changed()
## Gets the zoom state of a camera.
func get_zoom() -> Vector2:
	return zoom

## Sets the rotational (radians) state of a camera.
func set_rotation(val : float) -> void:
	if val == _rotation:
		return
	_rotation = val
	emit_changed()
## Gets the rotational (radians) state of a camera.
func get_rotation() -> float:
	return _rotation

## Sets the rotational (degrees) state of a camera.
func set_rotation_degrees(val : float) -> void:
	val = deg_to_rad(val)
	
	if val == _rotation:
		return
	_rotation = val
	emit_changed()
## Gets the rotational (degrees) state of a camera.
func get_rotation_degrees() -> float:
	return rad_to_deg(_rotation)
#endregion


#region Methods (Helper)
## Overwrite's the given [param cam]'s variables with this resources's state.
func overwrite_status(cam : Camera2D) -> void:
	offset = cam.offset
	position = cam.position
	zoom = cam.zoom
	rotation = cam.rotation

## Overwrite's this resources's state with the given [param cam]'s variables.
func apply_status(cam : Camera2D) -> void:
	cam.offset = offset
	cam.position = position
	cam.zoom = zoom
	cam.rotation = rotation
#endregion

# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
