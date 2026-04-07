# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
@tool
class_name NodeCamera2DFollowEffect extends NodeCamera2DEffect
## A basic effect that constantly updates the target camera status to
## the provided [member follow] node.


#region External Variables
@export var follow : Node2D:
	set(val):
		if val == follow:
			return
		
		if follow == null || val == null:
			follow = val
			notify_tick_changed()
			return
		follow = val
@export_flags("Position:1", "Rotation:2") var flags : int = 1
#endregion



#endregion Virtual Methods
func _start_effect(target : GoCameraStateResource) -> void:
	if !follow:
		push_warning("'follow' in 'NodeCamera2DFollowEffect' is null.")
		return
	if flags == 0:
		push_warning("Flags in 'NodeCamera2DFollowEffect' are empty.")
		return

func _effect_tick(target : GoCameraStateResource) -> void:
	if flags & 1:
		target.position = follow.position
	if flags & 2:
		target.rotation = follow.rotation
func _effect_tick_needed() -> bool:
	return follow != null
#endregion

# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
