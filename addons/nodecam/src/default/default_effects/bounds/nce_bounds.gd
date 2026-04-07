# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
@tool
class_name NodeCamera2DBoundEffect extends NodeCamera2DEffect
## A basic effect that constantly updates the target camera status to be with
## the provided [Rect2] bounaries of [member bounary].


#endregion External Variables
@export_custom(
	PROPERTY_HINT_NODE_TYPE, "TileMapLayer,CollisionShape2D"
) var bounary: Node2D

@export var include_offset : bool = false
#endregion



#endregion Virtual Methods
func _start_effect(target : GoCameraStateResource) -> void:
	if !bounary:
		push_warning("'bounary' in 'NodeCamera2DBoundEffect' is null.")
		return

func _effect_tick(target : GoCameraStateResource) -> void:
	var cam_half_size : Vector2 = (get_viewport().size / target.zoom) * 0.5
	var cam_min_pos : Vector2 = target.position - cam_half_size
	var cam_max_pos : Vector2 = target.position + cam_half_size
	if include_offset:
		cam_min_pos += target.offset
		cam_max_pos += target.offset
	
	var bounary_rect : Rect2
	if bounary is CollisionShape2D:
		bounary_rect = bounary.shape.get_rect()
	elif bounary is TileMapLayer:
		bounary_rect = bounary.get_used_rect()
	var bounary_min_pos : Vector2 = bounary_rect.position
	var bounary_max_pos : Vector2 = bounary_rect.position + bounary_rect.size

	if bounary_min_pos.x > cam_min_pos.x:
		target.position.x += (bounary_min_pos.x - cam_min_pos.x)
	elif bounary_max_pos.x < cam_max_pos.x:
		target.position.x += (cam_max_pos.x - bounary_max_pos.x)
	
	if bounary_min_pos.y > cam_min_pos.y:
		target.position.y += (bounary_min_pos.y - cam_min_pos.y)
	elif bounary_max_pos.y < cam_max_pos.y:
		target.position.y += (cam_max_pos.y - bounary_max_pos.y)
func _effect_tick_needed() -> bool:
	return bounary != null
#endregion

# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
