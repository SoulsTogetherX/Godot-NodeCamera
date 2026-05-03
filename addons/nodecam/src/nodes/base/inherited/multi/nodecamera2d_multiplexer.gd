# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
@tool
@icon("uid://cax3r21pd3net")
class_name NodeCamera2DMultiplexer extends NodeCamera2DMulti

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
	pass

func unregister_layer(layer : NodeCamera2DLayer) -> void:
	pass
#endregion

# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
