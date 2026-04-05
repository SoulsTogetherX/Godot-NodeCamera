@tool
extends GoCamera2DTransition

func _start_transition(
	target : GoCameraStateResource, current : GoCameraStateResource
) -> void:
	pass
func _end_transition(
	target : GoCameraStateResource, current : GoCameraStateResource
) -> void:
	pass

func _transition_tick(
	target : GoCameraStateResource, current : GoCameraStateResource
) -> void:
	pass
func _transition_tick_needed() -> bool:
	return false
