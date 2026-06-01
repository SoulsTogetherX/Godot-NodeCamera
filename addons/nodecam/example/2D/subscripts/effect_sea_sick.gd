# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
@tool
extends NodeCameraEffect


#region Virtual Methods (User Overwrite)
func effect_stage_changed(
	target : NodeCameraState, stage : LAYER_STAGES
) -> void:
	var tween : Tween = target.get_var(self, null)
	if tween:
		tween.kill()
	if stage == LAYER_STAGES.HALTED:
		target.rotation_degrees = 0.0
		target.clear_var(self)
		return
	
	tween = create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN_OUT)
	
	tween.set_loops(-1)
	tween.tween_property(
		target, "rotation_degrees", -2.0, 2
	)
	tween.tween_property(
		target, "rotation_degrees", 2.0, 2
	)
	
	target.set_var(self, tween)
#endregion


#region Public Methods (Stages)
func get_needed_linger_stages() -> PackedInt32Array:
	return [LAYER_STAGES.RUNNING]
func get_needed_change_stages() -> PackedInt32Array:
	return [LAYER_STAGES.RUNNING, LAYER_STAGES.HALTED]
#endregion

# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
