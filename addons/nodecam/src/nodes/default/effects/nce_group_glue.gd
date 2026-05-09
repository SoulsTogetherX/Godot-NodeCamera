# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
@tool
extends NodeCameraEffect

#region External Variables
@export var follow_targets : Array[Node2D]:
	set = set_follow_targets,
	get = get_follow_targets

@export var one_time : bool:
	set = set_one_time,
	get = get_one_time
#endregion



#region Virtual Methods (User Overwrite)
func process_effect(
	_delta : float, target : NodeCameraState, _stage : LAYER_STAGES
) -> void:
	if follow_targets.is_empty():
		return
	
	var pos : Vector2
	for tar : Node2D in follow_targets:
		pos += tar.position
	target.position = pos / follow_targets.size()

func effect_stage_changed(
	target : NodeCameraState, _stage : LAYER_STAGES
) -> void:
	if follow_targets.is_empty():
		return
	
	var pos : Vector2
	for tar : Node2D in follow_targets:
		pos += tar.position
	target.position = pos / follow_targets.size()
#endregion


#region Public Methods (Stages)
func get_needed_process_stages() -> PackedInt32Array:
	if set_one_time || follow_targets.is_empty():
		return []
	return [LAYER_STAGES.RUNNING]
func get_needed_change_stages() -> PackedInt32Array:
	if set_one_time && !follow_targets.is_empty():
		return [LAYER_STAGES.STARTING]
	return []
#endregion


#region Accessor Method
func set_follow_targets(val : Array[Node2D]) -> void:
	if val == follow_targets:
		return
	follow_targets = val
	notify_stage_masks_changed()
func get_follow_targets() -> Array[Node2D]:
	return follow_targets

func set_one_time(val : bool) -> void:
	if val == one_time:
		return
	one_time = val
	notify_stage_masks_changed()
func get_one_time() -> bool:
	return one_time
#endregion

# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
