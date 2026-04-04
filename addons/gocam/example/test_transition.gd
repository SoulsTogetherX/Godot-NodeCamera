@tool
extends GoCamera2DTransition

func start_transition(
	target : GoCameraStateResource, current : GoCameraStateResource
) -> void:
	print("TRANS START")
func end_transition(
	target : GoCameraStateResource, current : GoCameraStateResource
) -> void:
	print("TRANS END")

func transition_tick(
	target : GoCameraStateResource, current : GoCameraStateResource
) -> void:
	print("TRANS TICK")
func transition_tick_needed() -> bool:
	print("TRANS TICK NEEDED CHECK")
	return false
