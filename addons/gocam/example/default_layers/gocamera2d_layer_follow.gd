extends GoCamera2DEffect

@export var follow_target : Node2D


func run_effect(cam : CameraStateResource) -> void:
	cam.position = follow_target.position
