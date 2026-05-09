# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
@tool
extends NodeCameraEffect

#region External Variables
@export_node_path("TileMapLayer", "TileMap", "CollisionShape2D")
var limits: NodePath
#endregion


#region Private Variables
var _limits_bounds : Object
#endregion



#region Virtual Methods (User Overwrite)
func process_effect(
	_delta : float, target : NodeCameraState, _stage : LAYER_STAGES
) -> void:
	var st : Vector2 = target.position + target.offset
	var ed : Vector2 = target.camera.get_viewport_rect().size + st
	var bound_rect : Rect2
	
	if _limits_bounds is CollisionShape2D:
		if _limits_bounds.shape == null:
			return
		bound_rect = _limits_bounds.shape.get_rect()
	elif _limits_bounds != null:
		bound_rect = _limits_bounds.get_used_rect()
	
	if bound_rect.end.x > ed.x:
		target.position.x -= (bound_rect.end.x - ed.x)
	elif bound_rect.position.x < st.x:
		target.position.x += (st.x - bound_rect.position.x)
	
	if bound_rect.end.y < ed.y:
		target.position.x -= (bound_rect.end.x - ed.x)
	elif bound_rect.position.y > st.y:
		target.position.x += (st.y - bound_rect.position.y)
#endregion


#region Public Methods (Stages)
func get_needed_process_stages() -> PackedInt32Array:
	if _limits_bounds:
		return [LAYER_STAGES.RUNNING]
	return []
#endregion


#region Accessor Methods
func set_boundery(val : NodePath) -> void:
	if limits == val:
		return
	limits = val
	_limits_bounds = get_node_or_null(val)
	notify_stage_masks_changed()
func get_boundery() -> NodePath:
	return limits
#endregion

# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
