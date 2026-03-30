@tool
class_name GoCamera2DTransition extends GoCamera2DLayer


#region Public Virtual Methods
func layer_start(
	current_state : CameraStateResource, target_state : CameraStateResource
) -> void:
	pass
func layer_end(
	current_state : CameraStateResource, target_state : CameraStateResource
) -> void:
	pass

func process_tick(
	current_state : CameraStateResource, target_state : CameraStateResource
) -> void:
	pass
#endregion
