@tool
class_name GoCamera2DTransition extends GoCamera2DLayer


#region Enum Variables
enum PROPERTIES_FILTER {
	NONE     = 0,
	ALL      = -1,
	OFFSET   = 1 << 0,
	POSITION = 1 << 1,
	ZOOM     = 1 << 2,
	ROTATION = 1 << 3
}
#endregion


#region Public Virtual Methods
func layer_start(
	target_state : CameraStateResource, current_state : CameraStateResource
) -> void:
	pass
func layer_end(
	target_state : CameraStateResource, current_state : CameraStateResource
) -> void:
	pass

func transition_tick(
	target_state : CameraStateResource, current_state : CameraStateResource
) -> void:
	pass
func transition_tick_needed() -> bool:
	return false
#endregion
