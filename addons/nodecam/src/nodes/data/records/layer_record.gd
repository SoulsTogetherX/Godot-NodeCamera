# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
class_name LayerRecord extends Object

#region Public Variables
var paused : bool = false

var layer : NodeCameraLayer
var tick_mask : int
var stage : NodeCameraExecutionScope.LAYER_STAGES = NodeCameraExecutionScope.LAYER_STAGES.HAULTED

# Layer's local scope if [member layer] is a [NodeCameraMulti]. Otherwise,
# it is the [member layer]'s parent scope.
var scope : NodeCameraExecutionScope
#endregion

# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
