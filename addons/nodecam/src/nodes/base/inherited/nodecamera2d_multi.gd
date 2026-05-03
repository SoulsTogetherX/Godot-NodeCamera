# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
@tool
@abstract
class_name NodeCamera2DMulti extends NodeCamera2DLayer

#region Private Variables
var _layer_storage : NodeCamera2DLayerStorage
#endregion


#region Virtual Methods (Overwritable)
@abstract
func process_effect(
	target : NodeCameraState, stage : LAYER_STAGES
) -> void

@abstract
func process_transition(
	target : NodeCameraState, current : NodeCameraState,
	stage : LAYER_STAGES
) -> void
#endregion


#region Virtual Methods (Register)
@abstract
func register_layer(layer : NodeCamera2DLayer) -> void

@abstract
func unregister_layer(layer : NodeCamera2DLayer) -> void
#endregion

# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
