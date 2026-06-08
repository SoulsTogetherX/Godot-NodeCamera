# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
@tool
class_name NodeCameraEffectGroup extends NodeCameraEffect
## An effect that sets the camera position to the center of a
## group of targets.

#region External Variables
## Determines if this node should be used for 2D or 3D purposes.
## [br][br]
## Also see [enum NodeCameraUtility.DIMENSION].
var is_2d : NodeCameraUtility.DIMENSION = NodeCameraUtility.DIMENSION.TWO_DIMENSIONAL:
	set = set_is_2d,
	get = get_is_2d

## The nodes, [Node2D] or [Node3D], that this layer will follow.
## [br][br]
## Also see: [member is_2d].
var follow_targets : Array[Node]:
	set = set_follow_targets,
	get = get_follow_targets

## Determines whether a 3D camera will look at the target position, or
## reposition itself to the target position
var follow_type := NodeCameraUtility.FOLLOW_TYPE.POSITION:
	set = set_follow_type,
	get = get_follow_type

# Zoom
## If [code]true[/code], the layer will automatically zoom in or
## out to fit all following elements in.
var change_zoom : bool = false:
	set = set_change_zoom,
	get = get_change_zoom
## The ratio margin the camera will automatically zoom with.
## [br][br]
## Also see [member change_zoom].
var zoom_ratio_margin : float = 0.15:
	set = set_zoom_ratio_margin,
	get = get_zoom_ratio_margin
## The pixel margin the camera will automatically zoom with.
## [br][br]
## Also see [member change_zoom].
var zoom_margin : int = 0:
	set = set_zoom_margin,
	get = get_zoom_margin

# 2D Fit
## The minimum zoom the camera will automatically be resized.
## [br][br]
## Also see [member change_zoom].
var zoom_min : float = 0.1:
	set = set_zoom_min,
	get = get_zoom_min
## The maximum zoom the camera will automatically be resized.
## [br][br]
## Also see [member m_max].
var zoom_max : float = 10.0:
	set = set_zoom_max,
	get = get_zoom_max

# Addtional Arguments
## If [code]true[/code], the layer will only set the effect's position
## for one frame in [method effect_stage_changed]'s starting stage.
var one_shot : bool = false:
	set = set_one_shot,
	get = get_one_shot
#endregion


#region Private Variables
var _follow_nodes: Array[Node]
#endregion



#region Virtual Methods
func _get_property_list() -> Array[Dictionary]:
	var ret : Array[Dictionary]
	
	ret.append({
		"name": "is_2d",
		"type": TYPE_INT,
		"hint": PROPERTY_HINT_ENUM,
		"hint_string": NodeCameraUtility.DIMENSION_FLAGS,
		"usage": PROPERTY_USAGE_DEFAULT
	})
	
	ret.append({
		"name": "follow_targets",
		"type": TYPE_ARRAY,
		"hint": PROPERTY_HINT_TYPE_STRING,
		"hint_string": "24/34:Node2D" if is_2d == NodeCameraUtility.DIMENSION.TWO_DIMENSIONAL else "24/34:Node3D",
		"usage": PROPERTY_USAGE_DEFAULT
	})
	
	if is_2d == NodeCameraUtility.DIMENSION.THREE_DIMENSIONAL:
		ret.append({
			"name": "follow_type",
			"type": TYPE_INT,
			"hint": PROPERTY_HINT_ENUM,
			"hint_string": NodeCameraUtility.FOLLOW_TYPE_FLAGS,
			"usage": PROPERTY_USAGE_DEFAULT
		})
	
	if (
		follow_type == NodeCameraUtility.FOLLOW_TYPE.LOOK_AT ||
		is_2d == NodeCameraUtility.DIMENSION.TWO_DIMENSIONAL
	):
		ret.append({
			"name": "Zoom",
			"type": TYPE_NIL,
			"usage": PROPERTY_USAGE_GROUP,
		})
		ret.append({
			"name": "change_zoom",
			"type": TYPE_BOOL,
			"usage": PROPERTY_USAGE_DEFAULT
		})
		ret.append({
			"name": "zoom_ratio_margin",
			"type": TYPE_FLOAT,
			"hint": PROPERTY_HINT_RANGE,
			"hint_string": "0.0,1.0,0.001,or_less,or_greater",
			"usage": PROPERTY_USAGE_DEFAULT
		})
		ret.append({
			"name": "zoom_margin",
			"type": TYPE_INT,
			"usage": PROPERTY_USAGE_DEFAULT
		})
		
		if is_2d == NodeCameraUtility.DIMENSION.TWO_DIMENSIONAL:
			ret.append({
				"name": "2D Fit",
				"type": TYPE_NIL,
				"usage": PROPERTY_USAGE_SUBGROUP,
			})
			ret.append({
				"name": "zoom_min",
				"type": TYPE_FLOAT,
				"hint": PROPERTY_HINT_RANGE,
				"hint_string": "0.0,10.0,0.001,or_greater",
				"usage": PROPERTY_USAGE_DEFAULT
			})
			ret.append({
				"name": "zoom_max",
				"type": TYPE_FLOAT,
				"hint": PROPERTY_HINT_RANGE,
				"hint_string": "0.0,10.0,0.001,or_greater",
				"usage": PROPERTY_USAGE_DEFAULT
			})
	
	ret.append({
		"name": "Settings",
		"type": TYPE_NIL,
		"usage": PROPERTY_USAGE_GROUP
	})
	ret.append({
		"name": "one_shot",
		"type": TYPE_BOOL,
		"usage": PROPERTY_USAGE_DEFAULT
	})
	
	return ret

func _property_can_revert(property: StringName) -> bool:
	match property:
		&"is_2d":
			return is_2d != NodeCameraUtility.DIMENSION.TWO_DIMENSIONAL
		&"follow_type":
			return !follow_type
		&"change_zoom":
			return change_zoom
		&"zoom_min":
			return zoom_min != 0.1
		&"zoom_max":
			return zoom_max != 10.0
		&"zoom_margin":
			return zoom_margin != 0
		&"zoom_ratio_margin":
			return zoom_ratio_margin != 0.15
		&"one_shot":
			return one_shot != false
	return false
func _property_get_revert(property: StringName) -> Variant:
	match property:
		&"is_2d":
			return NodeCameraUtility.DIMENSION.TWO_DIMENSIONAL
		&"follow_type":
			return true
		&"change_zoom":
			return false
		&"zoom_min":
			return 0.1
		&"zoom_max":
			return 10.0
		&"zoom_margin":
			return 0
		&"zoom_ratio_margin":
			return 0.15
		&"one_shot":
			return false
	return null
#endregion


#region Private Methods
func _handle_center(target : NodeCamera3DState, center : Vector3) -> void:
	if follow_type == NodeCameraUtility.FOLLOW_TYPE.LOOK_AT:
		NodeCameraUtility.look_at_camera(target, center, Vector3.UP)
		return
	target.global_position = center

func _set_target_pos(target : NodeCameraState) -> void:
	if target is NodeCamera2DState:
		var pos : Vector2
		var max_vec : Vector2
		var min_vec : Vector2
		for node : Node2D in _follow_nodes:
			pos += node.global_position
			max_vec = max_vec.max(node.global_position)
			min_vec = max_vec.min(node.global_position)
		target.global_position = pos / _follow_nodes.size()
		
		if !change_zoom:
			return
		
		# Furthest offset, in all four corners, from the
		# camera's center
		max_vec = (max_vec - target.global_position).abs().max(
			(min_vec - target.global_position).abs()
		)
		
		var cam : Camera2D = target.get_camera()
		var viewport_size := NodeCameraUtility.get_2D_unzoomed_viewport_size(target)
		var zoom_view : Vector2 = (
			(
				viewport_size - Vector2(zoom_margin, zoom_margin)
			) * 0.5 * (1.0 - zoom_ratio_margin)
		) / max_vec
		target.zoom = Vector2.ONE * clampf(
			minf(zoom_view.x, zoom_view.y), zoom_min, zoom_max
		)
		return
	
	if target is NodeCamera3DState:
		var center := Vector3.ZERO
		var min_p := Vector3(INF, INF, INF)
		var max_p := Vector3(-INF, -INF, -INF)

		for node : Node3D in _follow_nodes:
			var p := node.global_position
			center += p
			min_p = min_p.min(p)
			max_p = max_p.max(p)
		
		center /= float(_follow_nodes.size())
		var extents := (max_p - min_p) * 0.5
		
		if !change_zoom:
			_handle_center(target, center)
			return
		
		var cam : Camera3D = target.get_camera()
		
		# Perspective: "zoom" = move camera farther away.
		var viewport_size := NodeCameraUtility.get_3D_viewport_size(target)
		var aspect := viewport_size.x / maxf(viewport_size.y, 0.001)
		
		var half_fov := deg_to_rad(cam.fov) * 0.5
		var half_h_fov := atan(tan(half_fov) * aspect)
		
		var radius := extents.length()
		var required_distance := radius / maxf(sin(minf(half_fov, half_h_fov)), 0.001)
		
		target.global_position = center + cam.global_transform.basis.z.normalized() * required_distance
		NodeCameraUtility.look_at_camera(target, center, Vector3.UP)
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
	if follow_targets.is_empty() || one_shot:
		return []
	return [LAYER_STAGES.RUNNING]
func get_needed_change_stages() -> PackedInt32Array:
	if !follow_targets.is_empty():
		return [LAYER_STAGES.STARTING]
	return []
#endregion


#region Accessor Method
func set_is_2d(val : NodeCameraUtility.DIMENSION) -> void:
	if val == is_2d:
		return
	follow_targets.clear()
	_follow_nodes.clear()
	is_2d = val
	notify_property_list_changed()
func get_is_2d() -> NodeCameraUtility.DIMENSION:
	return is_2d

func set_follow_targets(val : Array[Node]) -> void:
	if val == follow_targets:
		return
	follow_targets = val.filter(
		(func(v : Node): return v is Node2D || v == null) if is_2d == NodeCameraUtility.DIMENSION.TWO_DIMENSIONAL
		else (func(v : Node): return v is Node3D || v == null)
	)
	_follow_nodes.assign(
		follow_targets.filter(func(v : Node): return v != null)
	)
	notify_stage_masks_changed()
func get_follow_targets() -> Array[Node]:
	return follow_targets

func set_follow_type(val : NodeCameraUtility.FOLLOW_TYPE) -> void:
	if val == follow_type:
		return
	follow_type = val
	notify_property_list_changed()
func get_follow_type() -> NodeCameraUtility.FOLLOW_TYPE:
	return follow_type


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


func set_one_shot(val : bool) -> void:
	if val == one_shot:
		return
	one_shot = val
	notify_stage_masks_changed()
func get_one_shot() -> bool:
	return one_shot
#endregion

# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
