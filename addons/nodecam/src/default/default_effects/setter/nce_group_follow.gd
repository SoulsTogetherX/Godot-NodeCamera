# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
@tool
class_name NodeCamera2DGroupEffect extends NodeCamera2DEffect
## A basic effect that constantly updates the target camera status to view
## the provided [member follows] nodes.


#region External Variables
@export var follows : Array[Node2D]:
	set(val):
		if val == follows:
			return
		
		if follows.is_empty() || val.is_empty():
			follows = val
			notify_tick_changed()
			return
		follows = val
@export_flags("Position:1", "Zoom:2") var flags : int = 5

@export_group("Other")
@export var min_zoom : float = 0.2
@export var max_zoom : float = 2.0
#endregion



#endregion Virtual Methods
func _start_effect(target : GoCameraStateResource) -> void:
	if follows.is_empty():
		push_warning("'follows' in 'NodeCamera2DGroupEffect' is empty.")
		return
	if flags == 0:
		push_warning("Flags in 'NodeCamera2DFollowEffect' are empty.")
		return

func _effect_tick(target : GoCameraStateResource) -> void:
	if flags & 1:
		var pos : Vector2
		
		for p : Node2D in follows:
			pos += p.position
		target.position = pos / follows.size()
	if flags & 2:
		var min_v : Vector2
		var max_v : Vector2
		
		for p : Node2D in follows:
			min_v = min_v.min(p.position)
			max_v = max_v.min(p.position)
		
		var max_length := (
			(target.position - min_v).abs().max((target.position - max_v).abs())
		) * 2.0
		var zoom_temp : Vector2 = get_viewport().size / max_length
		zoom_temp = Vector2(zoom_temp.y, zoom_temp.x).min(zoom_temp)
		
		if min_zoom > 0.0:
			zoom_temp = zoom_temp.maxf(min_zoom)
		if max_zoom > min_zoom:
			zoom_temp = zoom_temp.minf(max_zoom)
		target.zoom = zoom_temp
func _effect_tick_needed() -> bool:
	return !follows.is_empty()
#endregion

# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
