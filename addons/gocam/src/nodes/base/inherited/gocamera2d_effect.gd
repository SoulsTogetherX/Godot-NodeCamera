@tool
class_name GoCamera2DEffect extends GoCamera2DLayer


#region Public Virtual Methods
func start_effect(target : GoCameraStateResource) -> void:
	pass
func end_effect(target : GoCameraStateResource) -> void:
	pass

func effect_tick(target : GoCameraStateResource) -> void:
	pass
func effect_tick_needed() -> bool:
	return false
#endregion
