# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
class_name StagedLayerRecord extends LayerRecord
## The [LayerRecord] class extension record for [NodeCameraStaged] nodes.

#region Public Variables
## The packed masks for stage manipulation.
var packed_masks : int
#endregion



#region Accessor Methods
## Sets the [param packed_masks] value with the given 4bit values.
## [br][br]
## Also see [method get_process_mask], [method get_linger_mask],
## and [method get_changed_mask].
func set_masks(process : int, linger : int, changed : int) -> void:
	packed_masks = (process << 8) | (process << 4) | (linger << 4) | changed

## Gets the mask of stages the layer should have it's process_stage method
## called (every relevant frame after inital change).
## [br][br]
## Alsos see [method set_masks].
func get_process_mask() -> int:
	return (packed_masks >> 8) & 0b1111
## Gets the mask of stages the layer stays at (unless otherwise requested).
## All process stages are considered linger stages by default.
## [br][br]
## Alsos see [method get_process_mask] and [method set_masks].
func get_linger_mask() -> int:
	return (packed_masks >> 4) & 0b1111
## Gets the mask of stages the layer should have it's process_stage method
## called (once at inital change).
## [br][br]
## Alsos see [method set_masks].
func get_changed_mask() -> int:
	return packed_masks & 0b1111
#endregion

# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
