# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
@tool
class_name NodeCamera3DState extends NodeCameraState
## The [NodeCameraState] class extension for [Camera3D] nodes.

#region External Variables
## The expected [member Node3D.global_transform] of the [Camera3D].
@export var transform: Transform3D = Transform3D.IDENTITY:
	set = set_transform,
	get = get_transform
var _transform: Transform3D = Transform3D.IDENTITY

## The expected [member Camera3D.h_offset] of the [Camera3D].
@export var h_offset : float:
	set = set_h_offset,
	get = get_h_offset
var _h_offset: float
## The expected [member Camera3D.v_offset] of the [Camera3D].
@export var v_offset : float:
	set = set_v_offset,
	get = get_v_offset
var _v_offset: float

## The expected [member Camera3D.fov] of the [Camera3D].
@export var fov : float = 75.0:
	set = set_fov,
	get = get_fov
var _fov: float = 75.0
## The expected [member Camera3D.size] of the [Camera3D].
@export var size : float = 1.0:
	set = set_size,
	get = get_size
var _size: float = 1.0
## The expected [member Camera3D.frustum_offset] of the [Camera3D].
@export var frustum_offset : Vector2 = Vector2.ZERO:
	set = set_frustum_offset,
	get = get_frustum_offset
var _frustum_offset: Vector2 = Vector2.ZERO

## The expected [member Camera3D.near] of the [Camera3D].
@export var near : float = 0.05:
	set = set_near,
	get = get_near
var _near: float = 0.05
## The expected [member Camera3D.far] of the [Camera3D].
@export var far : float = 4000.0:
	set = set_far,
	get = get_far
var _far: float = 4000.0

## The expected [member Node3D.global_position] of the [Camera3D].
@export var global_position : Vector3:
	set = set_global_position,
	get = get_global_position

## The expected [member Node3D.rotation] of the [Camera3D].
@export_custom(
	PROPERTY_HINT_NONE, "radians"
) var rotation : Vector3:
	set = set_rotation,
	get = get_rotation
## The expected [member Node3D.rotation_degrees] of the [Camera3D].
var rotation_degrees : Vector3:
	set = set_rotation_degrees,
	get = get_rotation_degrees
#endregion


#region Public Variables
## The camera being edited. It is considered bad practice to edit
## this directly.
var camera : Camera3D:
	set = set_camera,
	get = get_camera
#endregion



#region Public Accessor Methods
func set_transform(val : Transform3D) -> void:
	_transform = val
	_mask |= NodeCameraUtility.CAMERA_PROPERTY.TRANSFORM
func get_transform() -> Transform3D:
	return _transform


func set_h_offset(val : float) -> void:
	_h_offset = val
	_mask |= NodeCameraUtility.CAMERA_PROPERTY.H_OFFSET
func get_h_offset() -> float:
	return _h_offset
func set_v_offset(val : float) -> void:
	_v_offset = val
	_mask |= NodeCameraUtility.CAMERA_PROPERTY.V_OFFSET
func get_v_offset() -> float:
	return _v_offset

func set_size(val : float) -> void:
	_size = maxf(val, 0.001)
	_mask |= NodeCameraUtility.CAMERA_PROPERTY.SIZE
func get_size() -> float:
	return _size
func set_frustum_offset(val : Vector2) -> void:
	_frustum_offset = val
	_mask |= NodeCameraUtility.CAMERA_PROPERTY.FRUSTUM_OFFSET
func get_frustum_offset() -> Vector2:
	return _frustum_offset

func set_fov(val : float) -> void:
	_fov = clampf(val, 1.0, 179.0)
	_mask |= NodeCameraUtility.CAMERA_PROPERTY.FOV
func get_fov() -> float:
	return _fov
func set_near(val : float) -> void:
	_near = maxf(val, 0.001)
	_mask |= NodeCameraUtility.CAMERA_PROPERTY.NEAR
func get_near() -> float:
	return _near
func set_far(val : float) -> void:
	_far = maxf(val, 0.01)
	_mask |= NodeCameraUtility.CAMERA_PROPERTY.FAR
func get_far() -> float:
	return _far


func set_global_position(val : Vector3) -> void:
	_transform.origin = val
	_mask |= NodeCameraUtility.CAMERA_PROPERTY.POSITION
func get_global_position() -> Vector3:
	return _transform.origin

func set_rotation(val : Vector3) -> void:
	_transform.basis = Basis.from_euler(val)
	_mask |= NodeCameraUtility.CAMERA_PROPERTY.ROTATION
func get_rotation() -> Vector3:
	return _transform.basis.get_euler()
## Sets the [member rotation] to an angle in degrees.
func set_rotation_degrees(val : Vector3) -> void:
	_transform.basis = Basis.from_euler(Vector3(
		deg_to_rad(val.x),
		deg_to_rad(val.y),
		deg_to_rad(val.z)
	))
	_mask |= NodeCameraUtility.CAMERA_PROPERTY.ROTATION
## Converts [member rotation] to degrees and returns it.
func get_rotation_degrees() -> Vector3:
	var r := _transform.basis.get_euler()
	return Vector3(rad_to_deg(r.x), rad_to_deg(r.y), rad_to_deg(r.z))

func set_camera(cam : Camera3D) -> void:
	camera = cam
	apply_status()
func get_camera() -> Camera3D:
	return camera
#endregion


#region Public Helper Methods
## A method for setting all values, of this [NodeCamera3DState],
## with the values of the given [param cam].
func overwrite_status_with(cam : Camera3D) -> void:
	_transform = cam.global_transform
	
	_h_offset = cam.h_offset
	_v_offset = cam.v_offset
	
	_fov = cam.fov
	_size = cam.size
	_frustum_offset = cam.frustum_offset
	
	_near = cam.near
	_far = cam.far
	
	_mask = ~0
## A method for setting all values, of this [NodeCamera3DState],
## with the values of [member camera].
func overwrite_status() -> void:
	_transform = camera.global_transform
	
	_h_offset = camera.h_offset
	_v_offset = camera.v_offset
	
	_fov = camera.fov
	_size = camera.size
	_frustum_offset = camera.frustum_offset
	
	_near = camera.near
	_far = camera.far
	
	_mask = ~0
## A method for setting all values, of [member camera], with
## the values of this [NodeCamera3DState].
func apply_status() -> void:
	camera.global_transform = _transform
	
	camera.h_offset = _h_offset
	camera.v_offset = _v_offset
	
	camera.fov = _fov
	camera.size = _size
	camera.frustum_offset = _frustum_offset
	
	camera.near = _near
	camera.far = _far


## A method to reassign all values to match the given
## [NodeCamera3DState].
func assign(status : NodeCamera3DState) -> void:
	_transform = status.transform
	
	_h_offset = status.h_offset
	_v_offset = status.v_offset
	
	_fov = status.fov
	_size = status.size
	_frustum_offset = status.frustum_offset
	
	_near = status.near
	_far = status.far
	
	_mask = 0
## A method to reassign all values to match the given
## [NodeCamera3DState]. If they were already changed (in this
## object) since the last time this method called, then
## leave them unchanged.
func assign_unchanged(status : NodeCamera3DState) -> void:
	if !(_mask & NodeCameraUtility.CAMERA_PROPERTY.TRANSFORM):
		_transform = status.transform
	elif !(_mask & NodeCameraUtility.CAMERA_PROPERTY.POSITION):
		global_position = status.global_position
	elif !(_mask & NodeCameraUtility.CAMERA_PROPERTY.ROTATION):
		rotation = status.rotation
	
	if !(_mask & NodeCameraUtility.CAMERA_PROPERTY.H_OFFSET):
		_h_offset = status.h_offset
	if !(_mask & NodeCameraUtility.CAMERA_PROPERTY.V_OFFSET):
		_v_offset = status.v_offset
	
	if !(_mask & NodeCameraUtility.CAMERA_PROPERTY.FOV):
		_fov = status.fov
	if !(_mask & NodeCameraUtility.CAMERA_PROPERTY.SIZE):
		_size = status.size
	if !(_mask & NodeCameraUtility.CAMERA_PROPERTY.FRUSTUM_OFFSET):
		_frustum_offset = status.frustum_offset
	
	if !(_mask & NodeCameraUtility.CAMERA_PROPERTY.NEAR):
		_near = status.near
	if !(_mask & NodeCameraUtility.CAMERA_PROPERTY.FOV):
		_far = status.far
	
	_mask = 0


## Returns a duplicate of the current [NodeCamera3DState].
func duplicate() -> NodeCamera3DState:
	var ret := NodeCamera3DState.new()
	ret._vars = _vars.duplicate()
	ret.set_camera(camera)
	
	ret._transform = transform
	
	ret._h_offset = h_offset
	ret._v_offset = v_offset
	
	ret._fov = fov
	ret._size = size
	ret._frustum_offset = frustum_offset
	
	ret._near = near
	ret._far = far
	
	return ret
#endregion

# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
