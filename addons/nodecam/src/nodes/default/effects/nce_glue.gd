# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
@tool
extends NodeCameraEffect

#region External Variables
@export_node_path("Node2D", "Node3D")
var follow_target : NodePath:
	set = set_follow_target,
	get = get_follow_target

@export var one_time : bool:
	set = set_one_time,
	get = get_one_time
#endregion


#region External Variables
var _follow_node : Node
#endregion



#region Virtual Methods
func _ready() -> void:
	_follow_node = get_node_or_null(follow_target)
#endregion


#region Virtual Methods (User Overwrite)
func process_effect(
	_delta : float, target : NodeCameraState, _stage : LAYER_STAGES
) -> void:
	target.position = _follow_node.position
	prints(target.position, target)

func effect_stage_changed(
	target : NodeCameraState, _stage : LAYER_STAGES
) -> void:
	target.position = _follow_node.position
#endregion


#region Public Methods (Stages)
func get_needed_process_stages() -> PackedInt32Array:
	if one_time || _follow_node == null:
		return []
	return [LAYER_STAGES.STARTING]
func get_needed_change_stages() -> PackedInt32Array:
	if one_time && _follow_node != null:
		return [LAYER_STAGES.STARTING]
	return []
#endregion


#region Accessor Method
func set_follow_target(val : NodePath) -> void:
	if val == follow_target:
		return
	
	follow_target = val
	_follow_node = get_node_or_null(val)
	notify_stage_masks_changed()
func get_follow_target() -> NodePath:
	return follow_target

func set_one_time(val : bool) -> void:
	if val == one_time:
		return
	one_time = val
	notify_stage_masks_changed()
func get_one_time() -> bool:
	return one_time
#endregion

# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
