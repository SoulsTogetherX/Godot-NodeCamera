# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
@tool
class_name NodeCamera2DStaged extends NodeCamera2DLayer


#region Private Variables
var _stage : NodeCamera2DConstants.LAYER_STAGES
#endregion



#region Public Methods (Helper)
func get_stage() -> NodeCamera2DConstants.LAYER_STAGES:
	return _stage
func advance_stage() -> void:
	pass

func notify_needed_stages_changed() -> void:
	pass
func get_needed_stages() -> PackedInt32Array:
	return []
#endregion
