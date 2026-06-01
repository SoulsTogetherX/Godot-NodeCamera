# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
@tool
class_name NodeCameraEffectGroupGlue extends NodeCameraEffect
## An effect that sets the camera position to the center of a
## group of targets.

#region External Variables
## The paths to the nodes this effect will follow. 2D and 3D
## nodes are considered different groups.
@export_node_path("Node2D", "Node3D")
var follow_targets: Array[NodePath]:
	set = set_follow_targets,
	get = get_follow_targets

@export_group("Other")
## If [code]true[/code], the layer will only set the effect's position
## for one frame in [method effect_stage_changed]'s starting stage.
## [br][br]
## Also see [enum NodeCameraExecutionScope.LAYER_STAGES].
@export var one_shot : bool = false:
	set = set_one_shot,
	get = get_one_shot

@export_subgroup("Zoom")
## If [code]true[/code], the layer will automatically zoom in or
## out to fit all following elements in.
@export var change_zoom : bool = false:
	set = set_change_zoom,
	get = get_change_zoom

## The minimum zoom the camera will automatically be resized.
## [br][br]
## Also see [member change_zoom].
@export var zoom_min : float = 0.1:
	set = set_zoom_min,
	get = get_zoom_min
## The maximum zoom the camera will automatically be resized.
## [br][br]
## Also see [member m_max].
@export var zoom_max : float = 10.0:
	set = set_zoom_max,
	get = get_zoom_max
## The pixel margin the camera will automatically zoom with.
## [br][br]
## Also see [member change_zoom].
@export var zoom_margin : int = 0:
	set = set_zoom_margin,
	get = get_zoom_margin
## The ratio margin the camera will automatically zoom with.
## [br][br]
## Also see [member change_zoom].
@export var zoom_ratio_margin : float = 0.15:
	set = set_zoom_ratio_margin,
	get = get_zoom_ratio_margin
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
		var max_vec : Vector2
		var min_vec : Vector2
		for node : Node2D in _2d_follow_nodes:
			pos += node.global_position
			max_vec = max_vec.max(node.global_position)
			min_vec = max_vec.min(node.global_position)
		target.global_position = pos / _2d_follow_nodes.size()
		
		if !change_zoom:
			return
		
		# Furthest offset, in all four corners, from the
		# camera's center
		max_vec = (max_vec - target.global_position).abs().max(
			(min_vec - target.global_position).abs()
		)
		
		var cam : Camera2D = target.get_camera()
		var zoom_view : Vector2 = (
			(
				cam.get_viewport_rect().size - Vector2(zoom_margin, zoom_margin)
			) * 0.5 * (1.0 - zoom_ratio_margin)
		) / max_vec
		target.zoom = Vector2.ONE * clampf(
			minf(zoom_view.x, zoom_view.y), zoom_min, zoom_max
		)
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

func set_change_zoom(val : bool) -> void:
	change_zoom = val
func get_change_zoom() -> bool:
	return change_zoom

func set_zoom_min(val : float) -> void:
	zoom_min = val
func get_zoom_min() -> float:
	return zoom_min
func set_zoom_max(val : float) -> void:
	zoom_max = val
func get_zoom_max() -> float:
	return zoom_max

func set_zoom_margin(val : int) -> void:
	zoom_margin = val
func get_zoom_margin() -> int:
	return zoom_margin
func set_zoom_ratio_margin(val : float) -> void:
	zoom_ratio_margin = val
func get_zoom_ratio_margin() -> float:
	return zoom_ratio_margin
#endregion

# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
