# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
@tool
class_name NodeCamera2DlookAroundEffect extends NodeCamera2DEffect
## An independent effect that shifts the camera towards a certain offset from
## the current position. It is not recommended to use this effect more multiple
## [NodeCamera2DHost] nodes.


#endregion External Variables
@export var base_offset : Vector2 = Vector2.ZERO
@export var float_spread : Vector2 = Vector2(100, 50)

@export_group("Other")
@export_range(
	0.001, 1.0, 0.001, "or_greater", "prefer_slider"
) var float_weight : float = 0.7
#endregion


#endregion Private Variables
var _desired_pos : Vector2
#endregion



#endregion Virtual Methods
func _effect_tick(target : GoCameraStateResource) -> void:
	if _desired_pos.is_equal_approx(target.position):
		return
	
	target.position = target.position.lerp(
		_desired_pos, 1.0 - (1.0 / (float_weight * target.get_delta()) + 1.0)
	)
func _effect_tick_needed() -> bool:
	return true
#endregion


#endregion Public Methods
func set_desired_direction(dir : Vector2) -> void:
	_desired_pos = (dir.sign() * float_spread) + base_offset
#endregion

# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
