# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
class_name ChangeStageRecord extends Object
## A data container used to record a requested stage change to
## [NodeCameraStaged] nodes.
## [br][br]
## Also see [method NodeCameraStaged.transition_stage_changed]
## [method NodeCameraEffect.effect_stage_changed].

#region Public Variables
## The [NodeCameraStaged] node, who's stage is requested to change.
var layer : NodeCameraStaged

## The stage the node is requested to change into.
var stage : NodeCameraUtility.LAYER_STAGES

## The classifiction of [member layer], whether it is an 'effect' or
## 'transition'.
var type : NodeCameraExecutionScope.TICK_TYPE
#endregion

# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
