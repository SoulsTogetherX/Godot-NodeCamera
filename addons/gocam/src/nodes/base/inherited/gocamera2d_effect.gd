@abstract
@tool
class_name GoCamera2DEffect extends GoCamera2DLayer


#region Public Virtual Methods
func layer_start(target_state : CameraStateResource) -> void:
	pass
func layer_end(target_state : CameraStateResource) -> void:
	pass

func process_tick(target_state : CameraStateResource) -> void:
	pass
func process_tick_needed() -> bool:
	return false
#endregion
