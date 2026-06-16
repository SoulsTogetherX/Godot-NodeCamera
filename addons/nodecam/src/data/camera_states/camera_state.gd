# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
@tool
@abstract
class_name NodeCameraState extends Object
## The base abstract class that holds a camera's property values.
## This object is sent and edited by [NodeCameraEffect] and
## [NodeCameraTransition] nodes.

#region External Variables
## A dictionary of varables, which may be accessed or edited.
## The key should be whichever layer using the varable. If
## you need multiple variables for a single layer, consider an
## inner class or dictionary.
var _vars : Dictionary[NodeCameraLayer, Variant]

# Mask used to cache which values were changed since the last
# checkin.
var _mask : int = 0
#endregion



#region Public Helper Methods
## An abstract method for setting all values, of this [NodeCameraState],
## with the values of the current camera.
@abstract
func overwrite_status() -> void
## An abstract method for setting all values, of the current camera
## with the values of this [NodeCameraState].
@abstract
func apply_status() -> void


## Sets a variable for the [param layer] to freely use.
func set_var(layer : NodeCameraLayer, val : Variant = null) -> void:
	_vars.set(layer, val)
## Gets a variable [param layer] previously set.
func get_var(layer : NodeCameraLayer, default : Variant = null) -> Variant:
	return _vars.get(layer, default)
## Clears a variable [param layer] previously set, preventing memory leaks.
func clear_var(layer : NodeCameraLayer) -> void:
	_vars.erase(layer)
#endregion

# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
