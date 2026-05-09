# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
@tool
@abstract
class_name NodeCameraState extends Object
## The base abstract [Object] class that holds a camera's state. Is sent and edited by
## [NodeCameraEffect] and [NodeCameraTransition] nodes.

#region External Variables
## A dictionary of arguments, which may be accessed or edited.
@export var args : Dictionary[StringName, Variant]
#endregion



#region Public Helper Methods
## An abstract method for setting the current camera of this
## [NodeCameraState].
@abstract
func set_camera(cam : Node) -> void

## An abstract method for setting all values, of this [NodeCameraState],
## with the values of the given camera.
@abstract
func overwrite_status() -> void
## An abstract method for setting all values, of the given camera, with
## the values of this [NodeCameraState].
@abstract
func apply_status() -> void
#endregion

# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
