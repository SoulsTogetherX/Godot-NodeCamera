# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
@tool
@abstract
class_name NodeCamera2DMulti extends NodeCamera2DLayer


#region Public Virtual Methods (Abstract)
@abstract
func ticks_on_transition() -> bool
@abstract
func ticks_on_effect() -> bool
@abstract
func needs_tick() -> bool
#endregion


#region Virtual Methods (User Overwrite)
func process_effect_stage(target : NodeCameraState) -> void:
	pass
func process_translation_stage(
	target : NodeCameraState, current : NodeCameraState
) -> void:
	pass
#endregion


# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
