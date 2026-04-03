@tool
class_name GoCamera2DTransition extends GoCamera2DLayer


#region Public Virtual Methods
func start_transition(
	target : GoCameraStateResource, current : GoCameraStateResource
) -> void:
	pass
func end_transition(
	target : GoCameraStateResource, current : GoCameraStateResource
) -> void:
	pass

func transition_tick(
	target : GoCameraStateResource, current : GoCameraStateResource
) -> void:
	pass
func transition_tick_needed() -> bool:
	return false
#endregion
