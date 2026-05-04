# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
@tool
@icon("uid://cax3r21pd3net")
class_name NodeCameraMultiplexer extends NodeCameraMulti

#region External Variables
@export var inital_selection : int
#endregion



#region Tick Methods
func get_tick_mask(param_scope : NodeCameraExecutionScope) -> int:
	return 0
#endregion


#region Public Methods (Selection-Change Helper)
func change_selection(sel : int) -> void:
	(_scope as NodeCameraMultiplexerExecutionScope).flag_update_selection(sel)
#endregion

# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
