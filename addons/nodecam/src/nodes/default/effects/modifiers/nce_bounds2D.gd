# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
@tool
class_name NodeCameraEffect2DBoundary extends NodeCameraEffect
## An effect for keeping a camera within a rectanglar (not rotated) bounds.

#region External Variables
## The bounds the camera is limited to staying in.
@export_node_path("TileMapLayer", "TileMap", "CollisionShape2D")
var limits_path: NodePath:
	set = set_limits_path,
	get = get_limits_path
#endregion


#region Private Variables
var _limits_bounds : Node
#endregion



#region Private Methods
func _cache_limits_node() -> void:
	_limits_bounds = get_node_or_null(limits_path)
#endregion


#region Virtual Methods (User Overwrite)
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
		
		var cam : Camera2D = target.get_camera()
		var center : Vector2 = target.global_position + cam.offset
		var half_view : Vector2 = cam.get_viewport_rect().size / (2 * target.zoom.abs())
		var min_center := bound_rect.position + half_view
		var max_center := bound_rect.position + bound_rect.size - half_view
		
		if min_center.x > max_center.x:
			center.x = bound_rect.position.x + bound_rect.size.x * 0.5
		else:
			center.x = clampf(center.x, min_center.x, max_center.x)
		
		if min_center.y > max_center.y:
			center.y = bound_rect.position.y + bound_rect.size.y * 0.5
		else:
			center.y = clampf(center.y, min_center.y, max_center.y)
		
		target.global_position = center - cam.offset
#endregion


#region Public Methods (Stages)
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
#endregion

# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
