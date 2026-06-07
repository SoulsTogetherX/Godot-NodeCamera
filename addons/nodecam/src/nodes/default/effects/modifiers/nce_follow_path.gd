# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
@tool
class_name NodeCameraEffectFollowPath extends NodeCameraEffect
## An effect for clamping an effect to a path.

#region External Variables
## The path the effect will cling to.
@export_node_path("Path2D", "Path3D")
var path_node: NodePath:
	set = set_path_node,
	get = get_path_node
#endregion


#region External Variables
var _path_node: Node
#endregion



#region Private Methods
func _cache_path_node() -> void:
	_path_node = get_node_or_null(path_node)
#endregion



#region Virtual Methods (User Overwrite)
func process_effect(
	delta : float, target : NodeCameraState, stage : LAYER_STAGES
) -> void:
	target.global_position = (
		_path_node.curve.get_closest_point(target.global_position)
	)
#endregion


#region Public Methods (Stages)
func get_needed_process_stages() -> PackedInt32Array:
	if _path_node:
		return [LAYER_STAGES.RUNNING]
	return []
#endregion


#region Accessor Method
func set_path_node(val : NodePath) -> void:
	if val == path_node:
		return
	path_node = val
	_cache_path_node.call_deferred()
	notify_stage_masks_changed()
func get_path_node() -> NodePath:
	return path_node
#endregion

# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
