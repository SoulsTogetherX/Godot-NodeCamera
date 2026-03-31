@tool
extends GoCamera2DTransition


#region Public Virtual Methods
func transition_tick(
	target_state : CameraStateResource, current_state : CameraStateResource
) -> void:
	current_state.position = lerp(
		current_state.position, target_state.position, 0.5
	)
	
	if (current_state.position - target_state.position).is_zero_approx():
		active = false
func transition_tick_needed() -> bool:
	return true
#endregion
