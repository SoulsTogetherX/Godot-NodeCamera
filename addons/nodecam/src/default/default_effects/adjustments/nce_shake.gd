# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
@tool
class_name NodeCamera2DShakeTransition extends NodeCamera2DEffect
## A basic effect that applies a shake to the current camera's offset.

@export var strength : float
@export var frequency : float

@export_group("Delay")
@export_range(
	0.0, 1.0, 0.001, "or_greater", "prefer_slider"
) var fade_in : float
@export_range(
	0.0, 1.0, 0.001, "or_greater", "prefer_slider"
) var fade_out : float


# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
