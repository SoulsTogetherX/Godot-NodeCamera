@tool
extends GoCamera2DEffect


func start_effect(target : GoCameraStateResource) -> void:
	print("EFX START")
func end_effect(target : GoCameraStateResource) -> void:
	print("EFX END")

func effect_tick(target : GoCameraStateResource) -> void:
	print("EFX TICK")
func effect_tick_needed() -> bool:
	print("EFX TICK NEEDED CHECK")
	return false
