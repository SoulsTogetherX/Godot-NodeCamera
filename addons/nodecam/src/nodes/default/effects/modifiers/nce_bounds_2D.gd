# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
@tool
class_name NodeCameraEffect2DBoundary extends NodeCameraEffect
## An effect for keeping a camera within a rectangle (not rotated) region.

#region External Variables
## The bounds the camera is limited to staying in.
@export_node_path("TileMapLayer", "TileMap", "CollisionShape2D")
var limits_path: NodePath:
	set = set_limits_path,
	get = get_limits_path

## If [code]true[/code], calculations will include the offset in boundaries.
var include_offset: bool = true:
	set = set_include_offset,
	get = get_include_offset
#endregion


#region Private Variables
var _limits_bounds : Node
#endregion



#region Private Methods
func _cache_limits_node() -> void:
	_limits_bounds = get_node_or_null(limits_path)
#endregion


#region Virtual Methods (User Overwrite)
## Implements the [method NodeCameraEffect.process_effect] method.
func process_effect(
	_delta : float, target : NodeCameraState,
	_stage : LAYER_STAGES
) -> void:
	if target is NodeCamera2DState:
		var bound_rect: Rect2
		
		if _limits_bounds is CollisionShape2D:
			var shape : Shape2D = _limits_bounds.shape
			if shape == null:
				return
			bound_rect = shape.get_rect()
			bound_rect.position += _limits_bounds.global_position
		elif _limits_bounds != null:
			bound_rect = _limits_bounds.get_used_rect()
		
		NodeCameraUtility.fit_to_rectangle(
			target, bound_rect, include_offset
		)
#endregion


#region Public Methods (Stages)
## Implements the [method NodeCameraStaged.get_needed_change_stages] method.
func get_needed_process_stages() -> PackedInt32Array:
	if _limits_bounds:
		return [LAYER_STAGES.RUNNING]
	return []
#endregion


#region Accessor Methods
func set_limits_path(val : NodePath) -> void:
	if limits_path == val:
		return
	
	limits_path = val
	_cache_limits_node.call_deferred()
	notify_stage_masks_changed()
func get_limits_path() -> NodePath:
	return limits_path

func set_include_offset(val : bool) -> void:
	if include_offset == val:
		return
	include_offset = val
func get_include_offset() -> bool:
	return include_offset
#endregion

# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
