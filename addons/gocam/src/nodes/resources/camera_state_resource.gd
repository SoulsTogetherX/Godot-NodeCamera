class_name CameraStateResource extends Resource


#region External Variables
@export var offset : Vector2
@export var position : Vector2
@export var zoom : Vector2 = Vector2.ONE

@export_custom(
	PROPERTY_HINT_NONE, "", PROPERTY_USAGE_EDITOR
) var rotation : float:
	set = set_rotation,
	get = get_rotation
#endregion


#region Private Variables
@export_storage var _rotation : float
#endregion


#region Public Variables
var rotation_degrees : float:
	set = set_rotation_degrees,
	get = get_rotation_degrees
#endregion



#region Private Methods (Helper)
func set_rotation(val : float) -> void:
	_rotation = val
func get_rotation() -> float:
	return _rotation

func set_rotation_degrees(val : float) -> void:
	_rotation = deg_to_rad(val)
func get_rotation_degrees() -> float:
	return rad_to_deg(_rotation)
#endregion
