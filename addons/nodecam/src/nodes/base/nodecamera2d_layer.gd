# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
@tool
@icon("uid://dssbc6kgt43an")
class_name NodeCamera2DLayer extends Node
## The base layer for all camera manipulation.


#region Signals
## Emited when this [NodeCamera2DLayer] is activated.
## [br][br]
## Also see: [member active] and [member disabled].
signal activated
## Emited when this [NodeCamera2DLayer] is deactivated.
## [br][br]
## Also see: [member active] and [member disabled].
signal deactivated

## Emited when the [member priority] is changed.
signal priority_changed
## Emited when the starting or stopping tick updates.
## [br][br]
## Also see [method NodeCamera2DEffect.effect_tick], and
## [method NodeCamera2DTransition.transition_tick].
signal tick_state_changed

## Emited when the [member camera_flag_mask] is changed.
signal camera_mask_changed(old : int)
#endregion



# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
