# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
@tool
class_name NodeCamera2DJumpEffect extends NodeCamera2DEffect


#region External Variables
@export var skip_point : Node2D
@export_flags("Position:1", "Rotation:2") var flags : int = 1
#endregion



#endregion Virtual Methods
func _start_effect(target : GoCameraStateResource) -> void:
	if !skip_point:
		push_warning("'skip_point' in 'NodeCamera2DJumpEffect' is null.")
		return
	if flags == 0:
		push_warning("Flags in 'NodeCamera2DJumpEffect' are empty.")
		return
	
	if flags & 1:
		target.position = skip_point.position
	if flags & 2:
		target.rotation = skip_point.rotation
#endregion

# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
