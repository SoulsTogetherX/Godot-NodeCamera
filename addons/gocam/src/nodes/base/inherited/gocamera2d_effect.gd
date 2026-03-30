@abstract
@tool
class_name GoCamera2DEffect extends GoCamera2DLayer


#region Public Virtual Methods
func effect_start(state : CameraStateResource) -> void:
	pass
func effect_end(state : CameraStateResource) -> void:
	pass

func process_tick(state : CameraStateResource) -> void:
	pass
#endregion
