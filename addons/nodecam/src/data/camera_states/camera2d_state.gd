# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
@tool
class_name NodeCamera2DState extends NodeCameraState
## The [NodeCameraState] class extension for [Camera2D] nodes.

#region External Variables
## The expected [member Node2D.global_transform] of the [Camera2D].
@export var transform: Transform2D = Transform2D.IDENTITY:
	set = set_transform,
	get = get_transform
var _transform: Transform2D = Transform2D.IDENTITY

## The expected [member Camera2D.offset] of the [Camera2D].
@export var offset : Vector2:
	set = set_offset,
	get = get_offset
var _offset: Vector2
## The expected [member Camera2D.zoom] of the [Camera2D].
@export var zoom : Vector2 = Vector2.ONE:
	set = set_zoom,
	get = get_zoom
var _zoom: Vector2

## The expected [member Node2D.global_position] of the [Camera2D].
@export var global_position : Vector2:
	set = set_global_position,
	get = get_global_position
## The expected [member Node2D.rotation] of the [Camera2D].
@export_range(0.0, 360.0, 0.1, "radians_as_degrees")
var rotation : float:
	set = set_rotation,
	get = get_rotation
## The expected [member Node2D.rotation_degrees] of the [Camera2D].
var rotation_degrees : float:
	set = set_rotation_degrees,
	get = get_rotation_degrees
#endregion


#region Public Variables
## The camera being edited. It is considered bad practice to edit
## this directly.
var camera : Camera2D:
	set = set_camera,
	get = get_camera
#endregion



#region Public Accessor Methods
func set_transform(val : Transform2D) -> void:
	_transform = val
	_mask |= NodeCameraUtility.CAMERA_PROPERTY.TRANSFORM
func get_transform() -> Transform2D:
	return _transform


func set_offset(val : Vector2) -> void:
	_offset = val
	_mask |= NodeCameraUtility.CAMERA_PROPERTY.OFFSET
func get_offset() -> Vector2:
	return _offset

func set_zoom(val : Vector2) -> void:
	_zoom = val
	_mask |= NodeCameraUtility.CAMERA_PROPERTY.ZOOM
func get_zoom() -> Vector2:
	return _zoom


func set_global_position(val : Vector2) -> void:
	_transform.origin = val
	_mask |= NodeCameraUtility.CAMERA_PROPERTY.POSITION
func get_global_position() -> Vector2:
	return _transform.origin

func set_rotation(val : float) -> void:
	_transform = Transform2D(val, _transform.origin)
	_mask |= NodeCameraUtility.CAMERA_PROPERTY.ROTATION
func get_rotation() -> float:
	return _transform.get_rotation()

## Sets the [member rotation] to an angle in degrees.
func set_rotation_degrees(val : float) -> void:
	_transform = Transform2D(deg_to_rad(val), _transform.origin)
	_mask |= NodeCameraUtility.CAMERA_PROPERTY.ROTATION
## Converts [member rotation] to degrees and returns it.
func get_rotation_degrees() -> float:
	return rad_to_deg(_transform.get_rotation())

func set_camera(cam : Camera2D) -> void:
	camera = cam
func get_camera() -> Camera2D:
	return camera
#endregion


#region Public Helper Methods
## A method for setting all values, of this [NodeCamera2DState],
## with the values of [param cam].
func overwrite_status_with(cam : Camera2D) -> void:
	_transform = cam.global_transform
	_offset = cam.offset
	_zoom = cam.zoom
	
	_mask = ~0 # All properties changed
## A method for setting all values, of this [NodeCamera2DState],
## with the values of [member camera].
func overwrite_status() -> void:
	_transform = camera.global_transform
	_offset = camera.offset
	_zoom = camera.zoom
	
	_mask = ~0 # All properties changed
## A method for setting all values, of [member camera], with
## the values of this [NodeCamera2DState].
func apply_status() -> void:
	camera.global_transform = _transform
	camera.offset = _offset
	camera.zoom = _zoom


## A method to reassign all values to match the given
## [NodeCamera2DState].
func assign(status : NodeCamera2DState) -> void:
	_transform = status.transform
	_offset = status.offset
	_zoom = status.zoom
	
	_mask = ~0
## A method to reassign all values to match the given
## [NodeCamera2DState]. If they were already changed (in this
## object) since the last time this method called, then
## leave them unchanged.
func assign_unchanged(status : NodeCamera2DState) -> void:
	if !(_mask & NodeCameraUtility.CAMERA_PROPERTY.TRANSFORM):
		_transform = status.transform
	elif !(_mask & NodeCameraUtility.CAMERA_PROPERTY.POSITION):
		global_position = status.global_position
	elif !(_mask & NodeCameraUtility.CAMERA_PROPERTY.ROTATION):
		rotation = status.rotation
	
	if !(_mask & NodeCameraUtility.CAMERA_PROPERTY.OFFSET):
		_offset = status.offset
	if !(_mask & NodeCameraUtility.CAMERA_PROPERTY.ZOOM):
		_zoom = status.zoom
	
	_mask = 0


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
