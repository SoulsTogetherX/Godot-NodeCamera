# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
@tool
@icon("uid://0xkswoe4y0tm")
class_name NodeCameraTransition extends NodeCameraStaged
## A [NodeCameraStaged] node used to describe the current values any relevant
## camera should have, while transitioning the desired values, via chaining
## these nodes together.

#region Virtual Methods (User Overwrite)
## This is a [color=#D6D000][b]Runtime Method[/b][/color]. All
## [color=#D6D000][b]Runtime Method[/b][/color] requiring methods can
## be called within this method, if implemented.
## [br][br]
## This method is called whenever a record, containing this layer, is being
## processed in an execution scope.
## [br][br]
## [b]NOTE[/b]: This method will always be called after
## [method NodeCameraEffect.effect_stage_changed], and [method transition_stage_changed].
func process_transition(
	delta : float, target : NodeCameraState, current : NodeCameraState,
	stage : LAYER_STAGES
) -> void:
	pass

## This is a [color=#D6D000][b]Runtime Method[/b][/color]. All
## [color=#D6D000][b]Runtime Method[/b][/color] requiring methods can
## be called within this method, if implemented.
## [br][br]
## This method is called whenever a record, containing this layer, has it's
## stage changed.
## [br][br]
## [b]NOTE[/b]: This method will always be called before
## [method NodeCameraEffect.process_effect], and [method process_transition].
func transition_stage_changed(
	target : NodeCameraState, current : NodeCameraState,
	stage : LAYER_STAGES
) -> void:
	pass
#endregion


#region Tick Methods
func _get_tick_mask(_param_scope : NodeCameraExecutionScope) -> int:
	return TICK_TYPE.TRANSITIONS
#endregion

# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
