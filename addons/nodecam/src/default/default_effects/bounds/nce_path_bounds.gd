# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
@tool
class_name NodeCamera2DPathBoundEffect extends NodeCamera2DEffect
## A basic effect that constantly updates the target camera's position status
## to be on the closest point on the provided [member path].


#endregion External Variables
@export var path: Path2D

@export var include_offset : bool = false
#endregion



#endregion Virtual Methods
func _start_effect(target : GoCameraStateResource) -> void:
	if !path:
		push_warning("'path' in 'NodeCamera2DPathBoundEffect' is null.")
		return

func _effect_tick(target : GoCameraStateResource) -> void:
	target.position = (
		path.get_closest_point(target.position + target.offset) if include_offset
		else path.get_closest_point(target.position)
	)
func _effect_tick_needed() -> bool:
	return path != null
#endregion

# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
