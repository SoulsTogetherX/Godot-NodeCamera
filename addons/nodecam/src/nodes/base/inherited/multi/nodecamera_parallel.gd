# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
@tool
@icon("uid://dl0jprapnu02l")
class_name NodeCameraParallel extends NodeCameraMulti
## The [NodeCameraLayer] node used to help sync the activation and filter of
## children [NodeCameraLayer], while also boosting performance.

#region Tick Methods
func get_tick_mask(param_scope : NodeCameraExecutionScope) -> int:
	var mask := NodeCameraExecutionScope.TICK_TYPE.NONE
	
	if param_scope.has_effects():
		mask |= NodeCameraExecutionScope.TICK_TYPE.EFFECTS
	if param_scope.has_transitions():
		mask |= NodeCameraExecutionScope.TICK_TYPE.TRANSITIONS
	
	return mask
#endregion

# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
