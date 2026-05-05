# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
@tool
@icon("uid://82l5l3rm2fkd")
class_name NodeCameraEffect extends NodeCameraStaged
## The base [NodeCameraLayer] node for all camera effects, reliant on
## manipulating the target [GoCameraStateResource] resource of hosts.

#region Virtual Methods (User Overwrite)
func effect_stage_changed(
	target : NodeCameraState, stage : LAYER_STAGES
) -> void:
	pass

func process_effect(
	target : NodeCameraState, stage : LAYER_STAGES
) -> void:
	pass
#endregion


#region Tick Methods
func _get_tick_mask(_param_scope : NodeCameraExecutionScope) -> int:
	return TICK_TYPE.EFFECTS
#endregion

# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
