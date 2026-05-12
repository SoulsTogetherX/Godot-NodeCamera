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
## This method is called whenever a record, containing this layer, is being
## processed in an execution scope.
## [br][br]
## [b]NOTE[/b]: This method will always be called after [method effect_stage_changed],
## and [method NodeCameraTransition.transition_stage_changed].
func process_effect(
	delta : float, target : NodeCameraState, stage : LAYER_STAGES
) -> void:
	pass

## This is a [color=#D6D000][b]Runtime Method[/b][/color]. All
## [color=#D6D000][b]Runtime Method[/b][/color] requiring methods can
## be called within this method, if implemented.
## [br][br]
## This method is called whenever a record, containing this layer, has it's
## stage changed.
## [br][br]
## [b]NOTE[/b]: This method will always be called before [method process_effect],
## and [method NodeCameraTransition.process_transition].
func effect_stage_changed(
	target : NodeCameraState, stage : LAYER_STAGES
) -> void:
	pass
#endregion


#region Tick Methods
func _get_tick_mask(_param_scope : NodeCameraExecutionScope) -> int:
	return TICK_TYPE.EFFECTS
#endregion


#region Public Methods (Stages)
func get_needed_process_stages() -> PackedInt32Array:
	return []
func get_needed_linger_stages() -> PackedInt32Array:
	return []
func get_needed_change_stages() -> PackedInt32Array:
	return []
#endregion

# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
