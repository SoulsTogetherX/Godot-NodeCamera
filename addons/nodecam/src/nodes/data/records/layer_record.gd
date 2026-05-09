# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
@abstract
class_name LayerRecord extends Object
## The basic abstract [Object] class that stores all information of layer's current
## state within an [NodeCameraExecutionScope].

#region Public Variables
## The [NodeCameraLayer] attributed to this [LayerRecord].
var layer : NodeCameraLayer

## A byte holding if this [LayerRecord] controls an effect, transition, or both.
## Also see: [enum NodeCameraExecutionScope.TICK_TYPE].
var tick_mask : int

## The current stage this [LayerRecord] is in within the current
## [NodeCameraExecutionScope].
## [br][br]
## [b]NOTE[/b]: This member is always [enum NodeCameraExecutionScope.LAYER_STAGES].HAULTED
## if this [LayerRecord] is a [MultiLayerRecord].
var stage : NodeCameraExecutionScope.LAYER_STAGES = NodeCameraExecutionScope.LAYER_STAGES.HAULTED

## If [code]true[/code], this record will not call the process method on effects and
## transitions, for the current stage.
var paused : bool = false

## The [member layer]'s local scope if this [LayerRecord] is a [MultiLayerRecord].
## Otherwise, it is the [member layer]'s parent scope.
var scope : NodeCameraExecutionScope
#endregion

# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
