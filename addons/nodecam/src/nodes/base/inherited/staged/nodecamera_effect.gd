# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
@tool
@icon("uid://82l5l3rm2fkd")
class_name NodeCameraEffect extends NodeCameraStaged
## The base [NodeCameraLayer] node for all camera effects, reliant on
## manipulating the target [GoCameraStateResource] resource of hosts.

#region Tick Methods
func get_tick_mask(_param_scope : NodeCameraExecutionScope) -> int:
	return TICK_TYPE.EFFECTS
#endregion


#region Virtual Methods (User Overwrite)
func effect_stage_changed(
	target : NodeCameraState, stage : LAYER_STAGES
) -> void:
	prints(1, name, target, stage)

func process_effect(
	target : NodeCameraState, stage : LAYER_STAGES
) -> void:
	prints(2, name, target, stage)
#endregion


#region Public Methods (Stages)
func get_needed_process_stages() -> PackedInt32Array:
	return [LAYER_STAGES.RUNNING]
func get_needed_change_stages() -> PackedInt32Array:
	return [
		LAYER_STAGES.STARTING,
		LAYER_STAGES.HAULTED
	]
#endregion

# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
