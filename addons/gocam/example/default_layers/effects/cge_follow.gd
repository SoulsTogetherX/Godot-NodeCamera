@tool
extends GoCamera2DEffect

@export var follow_target : Node2D


#region Public Virtual Methods
func process_tick(target_state : CameraStateResource) -> void:
	target_state.position = follow_target.position
func process_tick_needed() -> bool:
	return true
#endregion
