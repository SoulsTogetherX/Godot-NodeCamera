# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
@tool
extends NodeCameraEffect

#region Virtual Methods (User Overwrite)
func process_effect(
	delta : float, target : NodeCameraState, stage : LAYER_STAGES
) -> void:
	pass

func effect_stage_changed(
	target : NodeCameraState, stage : LAYER_STAGES
) -> void:
	pass
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
