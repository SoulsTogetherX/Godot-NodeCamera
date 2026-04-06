# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
@tool
class_name NodeCamera2DlookAroundEffect extends NodeCamera2DEffect


#endregion External Variables
@export var base_offset : Vector2 = Vector2.ZERO
@export var float_spread : Vector2 = Vector2(100, 50)

@export_group("Other")
@export_range(
	0.001, 1.0, 0.001, "or_greater", "prefer_slider"
) var float_time : float = 2.0
@export var float_when_end : bool = true
#endregion


#endregion Private Variables
var _desired_pos : Vector2
#endregion


#endregion Virtual Methods
func _end_effect(target : GoCameraStateResource) -> void:
	if float_when_end:
		
		
		
		return
	target.offset = base_offset

func _effect_tick(target : GoCameraStateResource) -> void:
	pass
func _effect_tick_needed() -> bool:
	return false
#endregion

# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
