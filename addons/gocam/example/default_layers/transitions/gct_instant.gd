@tool
extends GoCamera2DTransition


#region Public Virtual Methods
func transition_tick(
	target_state : CameraStateResource, current_state : CameraStateResource
) -> void:
	current_state.position = target_state.position
func transition_tick_needed() -> bool:
	return true
#endregion
