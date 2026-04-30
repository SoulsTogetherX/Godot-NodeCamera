# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
@tool
@icon("uid://dl0jprapnu02l")
class_name NodeCamera2DParallel extends NodeCamera2DMulti
## The [NodeCamera2DLayer] node used to help sync the activation and filter of
## children [NodeCamera2DLayer], while also boosting performance.


#region Virtual Methods (Overwritable)
func process_effect(
	target : NodeCameraState, stage : NodeCamera2DConstants.LAYER_STAGES
) -> void:
	pass

func process_transition(
	target : NodeCameraState, current : NodeCameraState,
	stage : NodeCamera2DConstants.LAYER_STAGES
) -> void:
	pass
#endregion


#region Virtual Methods (Register)
func register_layer(layer : NodeCamera2DLayer) -> void:
	pass

func unregister_layer(layer : NodeCamera2DLayer) -> void:
	pass
#endregion

# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
