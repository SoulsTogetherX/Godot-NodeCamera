# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
@tool
@icon("uid://0xkswoe4y0tm")
class_name NodeCameraTransition extends NodeCameraStaged
## A [NodeCameraStaged] node used to describe the current values any relevant
## camera should have, while transitioning the desired values, via chaining
## these nodes together.
## [br][br]
## [color=#D6D000]NOTE[/color]: If a [NodeCameraTransition] is active, make
## sure [color=#D6D000]at least one[/color] [NodeCameraTransition] layer is
## transferring all desired camera properties, from 'target' to 'current',
## in either the [method process_transition] or
## [method transition_stage_changed] methods, [color=#D6D000]including
## properties not being transitioned.[/color]

#region Virtual Methods (User Overwrite)
## This is a [color=#D6D000][b]Runtime Method[/b][/color]. All
## [color=#D6D000][b]Runtime Method[/b][/color] requiring methods can
## be called within this method, if implemented.
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
## be called within this method, if implemented.
## [br][br]
## This method is called whenever a record, containing this layer, has it's
## stage changed.
## [br][br]
## [b]NOTE[/b]: This method will always be called before
## [method process_transition].
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
