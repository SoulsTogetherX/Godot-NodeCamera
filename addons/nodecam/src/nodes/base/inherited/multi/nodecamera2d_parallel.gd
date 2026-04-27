# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
@tool
@icon("uid://dl0jprapnu02l")
class_name NodeCamera2DParallel extends NodeCamera2DMulti
## The [NodeCamera2DLayer] node used to help sync the activation and filter of
## children [NodeCamera2DLayer], while also boosting performance.


#region Public Virtual Methods (Abstract)
func ticks_on_transition() -> bool:
	return false
func ticks_on_effect() -> bool:
	return false
func needs_tick() -> bool:
	return false
#endregion


# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
