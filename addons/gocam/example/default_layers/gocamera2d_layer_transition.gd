@tool
extends GoCamera2DTransition


#region Public Virtual Methods
func process_tick(
	current_state : CameraStateResource, target_state : CameraStateResource
) -> void:
	current_state.position = lerp(
		current_state.position, target_state.position, 0.5
	)
func process_tick_needed() -> bool:
	return true
#endregion
