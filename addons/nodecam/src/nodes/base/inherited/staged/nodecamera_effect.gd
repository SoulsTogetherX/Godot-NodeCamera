# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
@tool
@icon("uid://bw67jma5jjbq8")
class_name NodeCameraEffect extends NodeCameraStaged
## A [NodeCameraStaged] node used to describe the desired values any relevant
## camera should transition to via chaining these nodes together.

#region Virtual Methods (User Overwrite)
## This is a [color=#D6D000][b]Runtime Method[/b][/color]. All
## [color=#D6D000][b]Runtime Method[/b][/color] requiring methods can
## be called within this method, if implemented.
## [br][br]
## This method is called whenever a record, containing this layer, has it's
## stage changed.
func effect_stage_changed(
	delta : float, target : NodeCameraState, stage : LAYER_STAGES
) -> void:
	pass

## This is a [color=#D6D000][b]Runtime Method[/b][/color]. All
## [color=#D6D000][b]Runtime Method[/b][/color] requiring methods can
## be called within this method, if implemented.
## [br][br]
## This method is called whenever a record, containing this layer, is being
## processed in an execution scope.
func process_effect(
	delta : float, target : NodeCameraState, stage : LAYER_STAGES
) -> void:
	pass
#endregion


#region Tick Methods
func _get_tick_mask(_param_scope : NodeCameraExecutionScope) -> int:
	return TICK_TYPE.EFFECTS
#endregion

# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
