# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
class_name LayerRecord extends Object

#region Public Variables
var layer : NodeCameraLayer
var tick_mask : int
var stage : NodeCameraExecutionScope.LAYER_STAGES = NodeCameraExecutionScope.LAYER_STAGES.HAULTED

# Layer's local scope if [member layer] is a [NodeCameraMulti]. Otherwise,
# it is the [member layer]'s parent scope.
var scope : NodeCameraExecutionScope

func set_run_mask(val : int) -> void:
	tick_mask = (tick_mask & ~0b11) | (val & 0b11)
func get_run_mask() -> int:
	return tick_mask & 0b11

func set_paused(val : bool) -> void:
	tick_mask = (tick_mask & ~0b100) | (int(val) << 2)
func get_paused() -> bool:
	return tick_mask & 0b100
#endregion

# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
