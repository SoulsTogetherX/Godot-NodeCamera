# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
@tool
@icon("uid://dcxauqphisp2y")
class_name NodeCamera2DTransition extends NodeCamera2DStaged
## The base [NodeCamera2DLayer] node for all camera effects, reliant on
## easing the current [GoCameraStateResource] resource into the target
## [GoCameraStateResource] resource of hosts.


#region Virtual Methods (User Overwrite)
func transition_stage_changed(
	target : NodeCameraState, current : NodeCameraState,
	stage : NodeCamera2DConstants.LAYER_STAGES
) -> void:
	pass

func process_transition(
	target : NodeCameraState, current : NodeCameraState,
	stage : NodeCamera2DConstants.LAYER_STAGES
) -> void:
	pass
#endregion


# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
