# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
@abstract
class_name LayerRecord extends Object
## The basic abstract [Object] class that stores all information of layer's current
## state within an [NodeCameraExecutionScope].

#region Public Variables
## The [NodeCameraLayer] attributed to this [LayerRecord].
var layer : NodeCameraLayer

## The [member layer]'s local scope if this [LayerRecord] is a [GroupLayerRecord].
## Otherwise, it is the [member layer]'s parent scope.
var scope : NodeCameraExecutionScope

## The current stage this [LayerRecord] is in within the current
## [NodeCameraExecutionScope].
## [br][br]
## [b]NOTE[/b]: This member is always [enum NodeCameraExecutionScope.LAYER_STAGES].HALTED
## if this [LayerRecord] is a [GroupLayerRecord].
var stage : NodeCameraExecutionScope.LAYER_STAGES = NodeCameraExecutionScope.LAYER_STAGES.HALTED

## A byte holding if this [LayerRecord] controls an effect, transition, or both.
## Also see: [enum NodeCameraExecutionScope.TICK_TYPE].
var tick_mask : int
#endregion

# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
