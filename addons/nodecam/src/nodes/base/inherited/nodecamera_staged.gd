# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
@tool
@abstract
class_name NodeCameraStaged extends NodeCameraLayer

#region Public Methods (Stages)
func get_needed_process_stages() -> PackedInt32Array:
	return []

func get_needed_linger_stages() -> PackedInt32Array:
	return [ LAYER_STAGES.RUNNING ]
func get_needed_change_stages() -> PackedInt32Array:
	return [ LAYER_STAGES.STARTING, LAYER_STAGES.HAULTED ]
#endregion

# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
