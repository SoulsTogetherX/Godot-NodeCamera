# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
@tool
class_name NodeCameraEffectGlue extends NodeCameraEffect
## An effect that sets the camera position to a given target.

#region External Variables
## The path to the node this effect will follow.
@export_node_path("Node2D", "Node3D")
var follow_target : NodePath:
	set = set_follow_target,
	get = get_follow_target

## If [code]true[/code], the layer will only set the effect's position
## for one frame in [method effect_stage_changed]'s starting stage.
## [br][br]
## Also see [enum NodeCameraExecutionScope.LAYER_STAGES].
@export var one_shot : bool = false:
	set = set_one_shot,
	get = get_one_shot
#endregion


#region External Variables
var _follow_node: Node
#endregion



#region Private Methods
func _cache_follow_node() -> void:
	_follow_node = get_node_or_null(follow_target)
#endregion


#region Virtual Methods (User Overwrite)
func process_effect(
	_delta : float, target : NodeCameraState, _stage : LAYER_STAGES
) -> void:
	target.global_position = _follow_node.position

func effect_stage_changed(
	target : NodeCameraState, _stage : LAYER_STAGES
) -> void:
	target.global_position = _follow_node.position
#endregion


#region Public Methods (Stages)
func get_needed_process_stages() -> PackedInt32Array:
	if _follow_node && !one_shot:
		return [LAYER_STAGES.RUNNING]
	return []
func get_needed_change_stages() -> PackedInt32Array:
	if _follow_node:
		return [LAYER_STAGES.STARTING]
	return []
#endregion


#region Accessor Method
func set_follow_target(val : NodePath) -> void:
	if val == follow_target:
		return
	follow_target = val
	_cache_follow_node.call_deferred()
	notify_stage_masks_changed()
func get_follow_target() -> NodePath:
	return follow_target

func set_one_shot(val : bool) -> void:
	if val == one_shot:
		return
	one_shot = val
	notify_stage_masks_changed()
func get_one_shot() -> bool:
	return one_shot
#endregion

# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
