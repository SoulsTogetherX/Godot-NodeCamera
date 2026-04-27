# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
@tool
@icon("uid://82l5l3rm2fkd")
class_name NodeCamera2DEffect extends NodeCamera2DStaged
## The base [NodeCamera2DLayer] node for all camera effects, reliant on
## manipulating the target [GoCameraStateResource] resource of hosts.


#region Virtual Methods (User Overwrite)
func effect_stage_changed(
	target : NodeCameraState, stage : NodeCamera2DConstants.LAYER_STAGES
) -> void:
	pass

func process_effect(
	target : NodeCameraState, stage : NodeCamera2DConstants.LAYER_STAGES
) -> void:
	pass
#endregion


# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
