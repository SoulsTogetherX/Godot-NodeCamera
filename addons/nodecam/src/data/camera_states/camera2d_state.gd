# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
@tool
class_name NodeCamera2DState extends NodeCameraState
## The [NodeCameraState] class extension for [Camera2D] nodes.

#region External Variables
## The expected [member Node2D.global_transform] of the [Camera2D].
@export var transform: Transform2D = Transform2D.IDENTITY:
	set = set_transform,
	get = get_transform

## The expected [member Camera2D.offset] of the [Camera2D].
@export var offset : Vector2:
	set = set_offset,
	get = get_offset
## The expected [member Camera2D.zoom] of the [Camera2D].
@export var zoom : Vector2 = Vector2.ONE:
	set = set_zoom,
	get = get_zoom

## The expected [member Node2D.global_position] of the [Camera2D].
@export var global_position : Vector2:
	set = set_global_position,
	get = get_global_position
## The expected [member Node2D.rotation] of the [Camera2D].
@export var rotation : float:
	set = set_rotation,
	get = get_rotation
## The expected [member Node2D.rotation_degrees] of the [Camera2D].
@export var rotation_degrees : float:
	set = set_rotation_degrees,
	get = get_rotation_degrees
#endregion


#region Public Variables
## The camera itself. It is considered bad practice to edit this directly.
var camera : Camera2D
#endregion



#region Public Accessor Methods
func set_transform(val : Transform2D) -> void:
	transform = val 
func get_transform() -> Transform2D:
	return transform


func set_offset(val : Vector2) -> void:
	offset = val 
func get_offset() -> Vector2:
	return offset

func set_zoom(val : Vector2) -> void:
	zoom = val 
func get_zoom() -> Vector2:
	return zoom


func set_global_position(val : Vector2) -> void:
	transform.origin = val 
func get_global_position() -> Vector2:
	return transform.origin

func set_rotation(val : float) -> void:
	transform = Transform2D(val, transform.origin) 
func get_rotation() -> float:
	return transform.get_rotation()

## Sets the [member rotation] to an angle in degrees.
func set_rotation_degrees(val : float) -> void:
	transform = Transform2D(deg_to_rad(val), transform.origin) 
## Converts [member rotation] to degrees and returns it.
func get_rotation_degrees() -> float:
	return rad_to_deg(transform.get_rotation())
#endregion


#region Public Helper Methods
## An method for setting the current [Camera2D] of this
## [NodeCameraState].
func set_camera(cam : Camera2D) -> void:
	camera = cam
## An method for setting the current [Camera2D] of this
## [NodeCameraState].
func get_camera() -> Camera2D:
	return camera

## A method for setting all values, of this [NodeCamera2DState],
## with the values of the given [Camera2D].
func overwrite_status() -> void:
	transform = camera.global_transform
	offset = camera.offset
	zoom = camera.zoom
## A method for setting all values, of the given [Camera2D], with
## the values of this [NodeCamera2DState].
func apply_status() -> void:
	camera.global_transform = transform
	camera.offset = offset
	camera.zoom = zoom
## A method to reassign all values to match the given
## [NodeCamera2DState].
func assign(status : NodeCamera2DState) -> void:
	transform = status.transform
	offset = status.offset
	zoom = status.zoom


## Returns a duplicate of the current [NodeCamera2DState].
func duplicate() -> NodeCamera2DState:
	var ret := NodeCamera2DState.new()
	ret._vars = _vars.duplicate()
	ret.set_camera(camera)
	
	ret.transform = transform
	ret.offset = offset
	ret.zoom = zoom
	
	return ret
#endregion

# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
