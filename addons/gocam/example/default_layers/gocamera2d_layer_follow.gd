@tool
extends GoCamera2DEffect

@export var follow_target : Node2D


#region Public Virtual Methods
func start_tick() -> void:
	pass
func end_tick() -> void:
	pass

func process_tick(state : CameraStateResource) -> void:
	state.position = follow_target.position
func process_tick_needed() -> bool:
	return true
#endregion
