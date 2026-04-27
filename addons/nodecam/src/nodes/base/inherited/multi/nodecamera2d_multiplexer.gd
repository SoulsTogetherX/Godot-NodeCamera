# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
@tool
class_name NodeCamera2DMultiplexer extends NodeCamera2DMulti

#region External Variables
@export var selection : int:
	set = set_selection,
	get = get_selection
#endregion



#region Public Virtual Methods (Abstract)
func ticks_on_transition() -> bool:
	return false
func ticks_on_effect() -> bool:
	return false
func needs_tick() -> bool:
	return false
#endregion


#region Public Methods
func set_selection(val : int) -> void:
	selection = val
func get_selection() -> int:
	return selection
#endregion

# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
