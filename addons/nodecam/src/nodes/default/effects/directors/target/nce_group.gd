# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
@tool
class_name NodeCameraEffectGroup extends NodeCameraEffect
## An effect that sets the camera position to the center of a
## group of targets.

#region External Variables
## Determines if this node should be used for 2D or 3D purposes.
## [br][br]
## Also see [enum NodeCameraUtility.DIMENSION].
var dimention : NodeCameraUtility.DIMENSION = NodeCameraUtility.DIMENSION.TWO_DIMENSIONAL:
	set = set_dimention,
	get = get_dimention

## The nodes, [Node2D] or [Node3D], that this layer will follow.
## [br][br]
## Also see: [member dimention].
var follow_targets : Array[Node]:
	set = set_follow_targets,
	get = get_follow_targets

## Determines whether a 3D camera will look at the target position, or
## reposition itself to the target position
var follow_type := NodeCameraUtility.FOLLOW_TYPE.POSITION:
	set = set_follow_type,
	get = get_follow_type
	
## The offset that will be applied to the camera's position, if
## [member dimention] is [code]true[/code].
var offset_2d := Vector2.ZERO:
	set = set_offset_2d,
	get = get_offset_2d
## The offset that will be applied to the camera's position, if
## [member dimention] is [code]false[/code].
var offset_3d := Vector3.ZERO:
	set = set_offset_3d,
	get = get_offset_3d

# Zoom
## If [code]true[/code], the layer will automatically zoom in or
## out to fit all following elements in.
var change_size : bool = false:
	set = set_change_size,
	get = get_change_size
## The ratio padding the camera will automatically zoom with.
## [br][br]
## Also see [member change_zoom].
var size_padding : float = 0.5:
	set = set_size_padding,
	get = get_size_padding

# 2D Fit
## The minimum zoom the camera will automatically be resized.
## [br][br]
## Also see [member change_zoom].
var size_min : float = 0.1:
	set = set_size_min,
	get = get_size_min
## The maximum zoom the camera will automatically be resized.
## [br][br]
## Also see [member m_max].
var size_max : float = 10.0:
	set = set_size_max,
	get = get_size_max

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
		"name": "dimention",
		"type": TYPE_INT,
		"hint": PROPERTY_HINT_ENUM,
		"hint_string": NodeCameraUtility.DIMENSION_FLAGS,
		"usage": PROPERTY_USAGE_DEFAULT
	})
	
	ret.append({
		"name": "follow_targets",
		"type": TYPE_ARRAY,
		"hint": PROPERTY_HINT_TYPE_STRING,
		"hint_string": "24/34:Node2D" if dimention == NodeCameraUtility.DIMENSION.TWO_DIMENSIONAL else "24/34:Node3D",
		"usage": PROPERTY_USAGE_DEFAULT
	})
	
	if dimention == NodeCameraUtility.DIMENSION.TWO_DIMENSIONAL:
		ret.append({
			"name": "follow_type",
			"type": TYPE_INT,
			"hint": PROPERTY_HINT_ENUM,
			"hint_string": NodeCameraUtility.FOLLOW_TYPE_2D_FLAGS,
			"usage": PROPERTY_USAGE_DEFAULT
		})
	else:
		ret.append({
			"name": "follow_type",
			"type": TYPE_INT,
			"hint": PROPERTY_HINT_ENUM,
			"hint_string": NodeCameraUtility.FOLLOW_TYPE_3D_FLAGS,
			"usage": PROPERTY_USAGE_DEFAULT
		})
	
	ret.append({
		"name": "offset",
		"type": TYPE_VECTOR2 if dimention == NodeCameraUtility.DIMENSION.TWO_DIMENSIONAL else TYPE_VECTOR3,
		"usage": PROPERTY_USAGE_DEFAULT
	})
	
	ret.append({
		"name": "Sizing",
		"type": TYPE_NIL,
		"usage": PROPERTY_USAGE_GROUP,
	})
	ret.append({
		"name": "change_size",
		"type": TYPE_BOOL,
		"usage": PROPERTY_USAGE_DEFAULT
	})
	ret.append({
		"name": "size_padding",
		"type": TYPE_FLOAT,
		"hint": PROPERTY_HINT_RANGE,
		"hint_string": "0.0,2.0,0.001,or_less,or_greater",
		"usage": PROPERTY_USAGE_DEFAULT
	})
	
	ret.append({
		"name": "Size Fit",
		"type": TYPE_NIL,
		"usage": PROPERTY_USAGE_SUBGROUP,
	})
	ret.append({
		"name": "size_min",
		"type": TYPE_FLOAT,
		"hint": PROPERTY_HINT_RANGE,
		"hint_string": "0.0,100.0,0.001,or_greater",
		"usage": PROPERTY_USAGE_DEFAULT
	})
	ret.append({
		"name": "size_max",
		"type": TYPE_FLOAT,
		"hint": PROPERTY_HINT_RANGE,
		"hint_string": "0.0,100.0,0.001,or_greater",
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
		&"dimention":
			return dimention != NodeCameraUtility.DIMENSION.TWO_DIMENSIONAL
		&"follow_type":
			return !follow_type
		&"offset":
			return (
				offset_2d != Vector2.ZERO if dimention == NodeCameraUtility.DIMENSION.TWO_DIMENSIONAL
				else offset_3d != Vector3.ZERO
			)
		&"change_size":
			return change_size
		&"size_min":
			return size_min != (0.1 if dimention == NodeCameraUtility.DIMENSION.TWO_DIMENSIONAL else 1.0)
		&"size_max":
			return size_max != (10.0 if dimention == NodeCameraUtility.DIMENSION.TWO_DIMENSIONAL else 179.0)
		&"size_padding":
			return size_padding != 0.5
		&"one_shot":
			return one_shot != false
	return false
func _property_get_revert(property: StringName) -> Variant:
	match property:
		&"dimention":
			return NodeCameraUtility.DIMENSION.TWO_DIMENSIONAL
		&"follow_type":
			return true
		&"offset":
			return Vector2.ZERO if dimention == NodeCameraUtility.DIMENSION.TWO_DIMENSIONAL else Vector3.ZERO
		&"change_size":
			return false
		&"size_min":
			return 0.1 if dimention == NodeCameraUtility.DIMENSION.TWO_DIMENSIONAL else 1.0
		&"size_max":
			return 10.0 if dimention == NodeCameraUtility.DIMENSION.TWO_DIMENSIONAL else 179.0
		&"size_padding":
			return 0.5
		&"one_shot":
			return false
	return null

func _set(property: StringName, value: Variant) -> bool:
	if property == &"offset":
		if dimention == NodeCameraUtility.DIMENSION.TWO_DIMENSIONAL:
			offset_2d = value
			return false
		offset_3d = value
		return false
	return true
func _get(property: StringName) -> Variant:
	if property == &"offset":
		if dimention == NodeCameraUtility.DIMENSION.TWO_DIMENSIONAL:
			return offset_2d
		return offset_3d
	return null
#endregion


#region Private Methods
func _handle_vector_3D(target : NodeCamera3DState, center : Vector3) -> void:
	if follow_type == NodeCameraUtility.FOLLOW_TYPE.SIZE:
		NodeCameraUtility.zoom_to_point_3D(
			target, center
		)
		return
	if follow_type == NodeCameraUtility.FOLLOW_TYPE.ROTATE_MIMIC:
		return
	if follow_type == NodeCameraUtility.FOLLOW_TYPE.LOOK_AT:
		NodeCameraUtility.look_at_camera(
			target, center, Vector3.UP
		)
		return
	target.global_position = center
func _handle_vector_2D(target : NodeCamera2DState, center : Vector2) -> void:
	if follow_type == NodeCameraUtility.FOLLOW_TYPE.SIZE:
		NodeCameraUtility.zoom_to_point_2D(
			target, center
		)
		return
	target.global_position = center
	

func _set_target_pos(target : NodeCameraState) -> void:
	if target is NodeCamera2DState:
		var center : Vector2
		var max_p : Vector2 = Vector2(-INF, -INF)
		var min_p : Vector2 = Vector2(INF, INF)
		for node : Node2D in _follow_nodes:
			var p := node.global_position
			center += p
			max_p = max_p.max(p)
			min_p = min_p.min(p)
		
		center = (center / _follow_nodes.size()) + offset_2d
		_handle_vector_2D(target, center + offset_2d)
		
		if !change_size:
			return
		
		var zoom_pos : Vector2 = (
			(max_p - target.global_position).abs().max(
				(min_p - target.global_position).abs()
			) + target.global_position
		)
		NodeCameraUtility.zoom_to_point_2D(
			target, zoom_pos, size_padding
		)
		
		target.zoom = Vector2.ONE * clampf(
			target.zoom.x, size_min, size_max
		)
		return
	
	if target is NodeCamera3DState:
		var center := Vector3.ZERO
		var min_p := Vector3(INF, INF, INF)
		var max_p := Vector3(-INF, -INF, -INF)

		for node : Node3D in _follow_nodes:
			var p := node.global_position
			center += p
			max_p = max_p.max(p)
			min_p = min_p.min(p)
		
		center = (center / float(_follow_nodes.size()))
		_handle_vector_3D(target, center + offset_3d)
		
		if !change_size:
			return
		
		var size_pos : Vector3 = (
			(max_p - center).abs().max(
				(min_p - center).abs()
			) + center
		)
		NodeCameraUtility.zoom_to_point_3D(target, size_pos, size_padding)
		
		if target.camera.projection == Camera3D.ProjectionType.PROJECTION_PERSPECTIVE:
			target.fov = clampf(
				target.fov, size_min, size_max
			)
			return
		target.size = clampf(
			target.size, size_min, size_max
		)
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
func set_dimention(val : NodeCameraUtility.DIMENSION) -> void:
	if val == dimention:
		return
	follow_targets.clear()
	_follow_nodes.clear()
	follow_type = 0
	dimention = val
	notify_property_list_changed()
func get_dimention() -> NodeCameraUtility.DIMENSION:
	return dimention

func set_follow_targets(val : Array[Node]) -> void:
	if val == follow_targets:
		return
	follow_targets = val.filter(
		(func(v : Node): return v is Node2D || v == null) if dimention == NodeCameraUtility.DIMENSION.TWO_DIMENSIONAL
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


func set_offset_2d(val : Variant) -> void:
	offset_2d = val
func get_offset_2d() -> Variant:
	return offset_2d
func set_offset_3d(val : Variant) -> void:
	offset_3d = val
func get_offset_3d() -> Variant:
	return offset_3d


func set_change_size(val : bool) -> void:
	change_size = val
func get_change_size() -> bool:
	return change_size

func set_size_min(val : float) -> void:
	size_min = maxf(val, 0.0)
func get_size_min() -> float:
	return size_min

func set_size_max(val : float) -> void:
	size_max = maxf(val, 0.0)
func get_size_max() -> float:
	return size_max

func set_size_padding(val : float) -> void:
	size_padding = val
func get_size_padding() -> float:
	return size_padding


func set_one_shot(val : bool) -> void:
	if val == one_shot:
		return
	one_shot = val
	notify_stage_masks_changed()
func get_one_shot() -> bool:
	return one_shot
#endregion

# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
