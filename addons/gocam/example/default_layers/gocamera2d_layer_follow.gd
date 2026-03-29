@tool
extends GoCamera2DEffect

@export var follow_target : Node2D


func run_effect(state : CameraStateResource) -> void:
	state.position = follow_target.position
