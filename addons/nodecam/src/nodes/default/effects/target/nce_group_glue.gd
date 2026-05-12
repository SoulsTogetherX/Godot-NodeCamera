# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
@tool
extends NodeCameraEffect

#region External Variables
@export_node_path("Node2D", "Node3D")
var follow_targets: Array[NodePath]:
	set = set_follow_targets,
	get = get_follow_targets

@export var one_shot : bool = false:
	set = set_one_shot,
	get = get_one_shot

@export var reconstruct_allowed : bool = true:
	set = set_reconstruct_allowed,
	get = get_reconstruct_allowed
#endregion


#region External Variables
var _2d_follow_nodes: Array[Node2D]
var _3d_follow_nodes: Array[Node3D]
#endregion



#region Private Methods
func _cache_follow_nodes() -> void:
	_2d_follow_nodes = []
	_3d_follow_nodes = []
	
	for path : NodePath in follow_targets:
		var node : Node = get_node_or_null(path)
		if node is Node2D:
			_2d_follow_nodes.append(node)
			continue
		if node is Node3D:
			_3d_follow_nodes.append(node)


func _set_target_pos(target : NodeCameraState) -> void:
	if target is NodeCamera2DState:
		var pos : Vector2
		for node : Node2D in _2d_follow_nodes:
			pos += node.global_position
		target.global_position = pos / _2d_follow_nodes.size()
		return
	
	var pos : Vector3
	for node : Node3D in _3d_follow_nodes:
		pos += node.global_position
	target.global_position = pos / _3d_follow_nodes.size()
#endregion


#region Virtual Methods (User Overwrite)
func process_effect(
	_delta : float, target : NodeCameraState, _stage : LAYER_STAGES
) -> void:
	_set_target_pos(target)

func effect_stage_changed(
	target : NodeCameraState, _stage : LAYER_STAGES
) -> void:
	_set_target_pos(target)
#endregion


#region Public Methods (Stages)
func get_needed_process_stages() -> PackedInt32Array:
	if follow_targets.size() && !one_shot:
		return [LAYER_STAGES.RUNNING]
	return []
func get_needed_change_stages() -> PackedInt32Array:
	if follow_targets.size():
		return [LAYER_STAGES.STARTING]
	return []
#endregion


#region Accessor Method
func set_follow_targets(val : Array[NodePath]) -> void:
	if follow_targets == val:
		return
	
	follow_targets = val
	_cache_follow_nodes.call_deferred()
	notify_stage_masks_changed()
func get_follow_targets() -> Array[NodePath]:
	return follow_targets

func set_one_shot(val : bool) -> void:
	if val == one_shot:
		return
	one_shot = val
	notify_stage_masks_changed()
func get_one_shot() -> bool:
	return one_shot

func set_reconstruct_allowed(val : bool) -> void:
	reconstruct_allowed = val
func get_reconstruct_allowed() -> bool:
	return reconstruct_allowed
#endregion

# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
