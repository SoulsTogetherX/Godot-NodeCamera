@tool
extends GoCamera2DEffect

@export var jump_target : Node2D


#region Public Virtual Methods
func layer_start(target_state : CameraStateResource) -> void:
	target_state.position = jump_target.position
#endregion
