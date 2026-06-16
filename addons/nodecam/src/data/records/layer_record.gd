# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
@abstract
class_name LayerRecord extends Object
## An abstract data container used to store all information of layer's current
## state within an [NodeCameraExecutionScope].

#region Public Variables
## The [NodeCameraLayer] attributed to this [LayerRecord].
var layer : NodeCameraLayer

## The record's local scope if this [LayerRecord] is a [GroupLayerRecord].
## Otherwise, it is the record's parent scope.
var scope : NodeCameraExecutionScope

## The current stage of this [LayerRecord], within the current
## [NodeCameraExecutionScope].
## [br][br]
## [b]NOTE[/b]: This member is always [enum NodeCameraUtility.LAYER_STAGES].HALTED
## if this [LayerRecord] is a [GroupLayerRecord].
var stage : NodeCameraUtility.LAYER_STAGES = NodeCameraUtility.LAYER_STAGES.HALTED

## A byte holding if this [LayerRecord] controls an effect, transition, or both.
## [br][br]
## Also see [enum NodeCameraExecutionScope.TICK_TYPE].
var tick_mask : int
#endregion

# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
