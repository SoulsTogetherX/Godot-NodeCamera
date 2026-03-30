@tool
class_name GoCamera2DTransition extends GoCamera2DLayer


#region Public Virtual Methods
func transition_start(
	current_state : CameraStateResource, target_state : CameraStateResource
) -> void:
	pass
func transition_end(
	current_state : CameraStateResource, target_state : CameraStateResource
) -> void:
	pass

func process_tick(
	current_state : CameraStateResource, target_state : CameraStateResource
) -> void:
	pass

func notify_finished() -> void:
	pass
#endregion
