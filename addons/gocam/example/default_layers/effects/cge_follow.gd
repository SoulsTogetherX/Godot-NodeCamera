@tool
extends GoCamera2DEffect

@export var follow_target : Node2D


#region Public Virtual Methods
func layer_start(state : CameraStateResource) -> void:
	state.position = follow_target.position
#endregion
