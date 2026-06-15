# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
@tool
@abstract
@icon("uid://0xkswoe4y0tm")
class_name NodeCameraTransition extends NodeCameraStaged
## A [NodeCameraStaged] node used to define the current values any relevant
## camera should have, while transitioning to the desired values, via chaining
## a pipeline of transtion nodes together.

#region Virtual Methods (User Overwrite)
## This is a [color=#D6D000][b]Runtime Method[/b][/color]. All
## [color=#D6D000][b]Runtime Method[/b][/color] requiring methods can
## be called within this method.
## [br][br]
## This method is called whenever a record, containing this layer, is being
## processed in an execution scope.
## [br][br]
## [b]NOTE[/b]: This method will always be called after
## [method transition_stage_changed].
func process_transition(
	delta : float, target : NodeCameraState, current : NodeCameraState,
	stage : LAYER_STAGES
) -> void:
	pass

## This is a [color=#D6D000][b]Runtime Method[/b][/color]. All
## [color=#D6D000][b]Runtime Method[/b][/color] requiring methods can
## be called within this method.
## [br][br]
## Whenever a record (containing this layer) has it's stage changed,
## this method gets queued to run at the start of the next camera frame.
## [br][br]
## [b]NOTE[/b]: This method will always be called before
## [method process_transition].
## [br][br]
## Also see [method NodeCameraHostExecutionScope.defer_method].
func transition_stage_changed(
	target : NodeCameraState, current : NodeCameraState,
	stage : LAYER_STAGES
) -> void:
	pass
#endregion

# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
