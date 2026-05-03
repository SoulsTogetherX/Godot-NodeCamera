# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
@tool
@icon("uid://dl0jprapnu02l")
class_name NodeCamera2DParallel extends NodeCamera2DMulti
## The [NodeCamera2DLayer] node used to help sync the activation and filter of
## children [NodeCamera2DLayer], while also boosting performance.

#region Virtual Methods (Overwritable)
func process_effect(
	target : NodeCameraState, stage : LAYER_STAGES
) -> void:
	pass

func process_transition(
	target : NodeCameraState, current : NodeCameraState,
	stage : LAYER_STAGES
) -> void:
	pass
#endregion


#region Virtual Methods (Register)
func register_layer(layer : NodeCamera2DLayer) -> void:
	_layer_storage.register_layer(layer)

func unregister_layer(layer : NodeCamera2DLayer) -> void:
	_layer_storage.unregister_layer(layer)
#endregion

# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
