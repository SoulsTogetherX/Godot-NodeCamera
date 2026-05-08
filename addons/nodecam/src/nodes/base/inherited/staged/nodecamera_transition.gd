# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
@tool
@icon("uid://0xkswoe4y0tm")
class_name NodeCameraTransition extends NodeCameraStaged
## The base [NodeCameraLayer] node for all camera effects, reliant on
## easing the current [GoCameraStateResource] resource into the target
## [GoCameraStateResource] resource of hosts.

#region Virtual Methods (User Overwrite)
func transition_stage_changed(
	target : NodeCameraState, current : NodeCameraState,
	stage : LAYER_STAGES
) -> void:
	pass

func process_transition(
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
