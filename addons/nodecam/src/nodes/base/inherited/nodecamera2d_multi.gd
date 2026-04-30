# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
@tool
@abstract
class_name NodeCamera2DMulti extends NodeCamera2DLayer

#region Virtual Methods (Overwritable)
@abstract
func process_effect(
	target : NodeCameraState, stage : NodeCamera2DConstants.LAYER_STAGES
) -> void

@abstract
func process_transition(
	target : NodeCameraState, current : NodeCameraState,
	stage : NodeCamera2DConstants.LAYER_STAGES
) -> void
#endregion


#region Virtual Methods (Register)
@abstract
func register_layer(layer : NodeCamera2DLayer) -> void

@abstract
func unregister_layer(layer : NodeCamera2DLayer) -> void
#endregion


# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
