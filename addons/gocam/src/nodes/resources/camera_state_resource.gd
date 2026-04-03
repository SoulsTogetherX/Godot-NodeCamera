@tool
class_name GoCameraStateResource extends Resource


#region External Variables
@export var offset : Vector2:
	set = set_offset,
	get = get_offset
@export var position : Vector2:
	set = set_position,
	get = get_position
@export var zoom : Vector2:
	set = set_zoom,
	get = get_zoom

@export_custom(
	0, "", PROPERTY_USAGE_EDITOR
) var rotation : float:
	set = set_rotation,
	get = get_rotation
var rotation_degrees : float:
	set = set_rotation_degrees,
	get = get_rotation_degrees
#endregion


#region Private Variables
var _rotation : float
#endregion



#region Public Methods (Accessor)
func set_offset(val : Vector2) -> void:
	if val == offset:
		return
	offset = val
	emit_changed()
func get_offset() -> Vector2:
	return offset

func set_position(val : Vector2) -> void:
	if val == position:
		return
	position = val
	emit_changed()
func get_position() -> Vector2:
	return position

func set_zoom(val : Vector2) -> void:
	if val == zoom:
		return
	zoom = val
	emit_changed()
func get_zoom() -> Vector2:
	return zoom

func set_rotation(val : float) -> void:
	if val == _rotation:
		return
	_rotation = val
	emit_changed()
func get_rotation() -> float:
	return _rotation

func set_rotation_degrees(val : float) -> void:
	val = deg_to_rad(val)
	
	if val == _rotation:
		return
	_rotation = val
	emit_changed()
func get_rotation_degrees() -> float:
	return rad_to_deg(_rotation)
#endregion


#region Methods (Helper)
func overwrite_status(cam : Camera2D) -> void:
	offset = cam.offset
	position = cam.position
	zoom = cam.zoom
	rotation = cam.rotation

func apply_status(cam : Camera2D) -> void:
	cam.offset = offset
	cam.position = position
	cam.zoom = zoom
	cam.rotation = rotation
#endregion
