# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
@tool
class_name NodeCameraEffectGlue extends NodeCameraEffect
## An effect that sets the camera properties according to a given target.

#region External Variables
## Determines if this node should be used for 2D or 3D purposes.
var dimention : NodeCameraUtility.DIMENSION = NodeCameraUtility.DIMENSION.TWO_DIMENSIONAL:
	set = set_dimention,
	get = get_dimention

## The node, either [Node2D] or [Node3D], this effect will follow.
## [br][br]
## Also see [member dimention] and [member follow_type]. 
var follow_target : Node:
	set = set_follow_target,
	get = get_follow_target

## Determines how this layer will process [member follow_target].
## [br][br]
## Also see [member dimention].
var follow_type := NodeCameraUtility.FOLLOW_TYPE.POSITION:
	set = set_follow_type,
	get = get_follow_type

## The offset that will be applied to the camera's position, if
## [member dimention] is [code]TWO_DIMENSIONAL[/code].
var offset_2d := Vector2.ZERO:
	set = set_offset_2d,
	get = get_offset_2d
## The offset that will be applied to the camera's position, if
## [member dimention] is [code]THREE_DIMENSIONAL[/code].
var offset_3d := Vector3.ZERO:
	set = set_offset_3d,
	get = get_offset_3d

## If [code]true[/code], the layer will only set the effect's position
## for one frame in [method effect_stage_changed]'s starting stage.
var one_shot : bool = false:
	set = set_one_shot,
	get = get_one_shot
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
		"name": "follow_target",
		"type": TYPE_OBJECT,
		"hint": PROPERTY_HINT_NODE_TYPE,
		"hint_string": "Node2D" if dimention == NodeCameraUtility.DIMENSION.TWO_DIMENSIONAL else "Node3D",
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
		"name": "Settings",
		"type": TYPE_NIL,
		"usage": PROPERTY_USAGE_GROUP,
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
		&"follow_target":
			return follow_target != null
		&"follow_type":
			return follow_type != NodeCameraUtility.FOLLOW_TYPE.POSITION
		&"offset":
			return (
				offset_2d != Vector2.ZERO if dimention == NodeCameraUtility.DIMENSION.TWO_DIMENSIONAL
				else offset_3d != Vector3.ZERO
			)
		&"one_shot":
			return one_shot
	return false
func _property_get_revert(property: StringName) -> Variant:
	match property:
		&"dimention":
			return NodeCameraUtility.DIMENSION.TWO_DIMENSIONAL
		&"follow_target":
			return null
		&"follow_type":
			return NodeCameraUtility.FOLLOW_TYPE.POSITION
		&"offset":
			return Vector2.ZERO if dimention == NodeCameraUtility.DIMENSION.TWO_DIMENSIONAL else Vector3.ZERO
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


#region Virtual Methods (User Overwrite)
## Implements the [method NodeCameraEffect.process_effect] method.
func process_effect(
	_delta : float, target : NodeCameraState, _stage : LAYER_STAGES
) -> void:
	_handle_glue(target)

## Implements the [method NodeCameraEffect.effect_stage_changed] method.
func effect_stage_changed(
	target : NodeCameraState, _stage : LAYER_STAGES
) -> void:
	_handle_glue(target)
#endregion


#region Public Methods (Stages)
## Implements the [method NodeCameraStaged.get_needed_process_stages] method.
func get_needed_process_stages() -> PackedInt32Array:
	if follow_target && !one_shot:
		return [LAYER_STAGES.RUNNING]
	return []
## Implements the [method NodeCameraStaged.get_needed_change_stages] method.
func get_needed_change_stages() -> PackedInt32Array:
	if follow_target:
		return [LAYER_STAGES.STARTING]
	return []
#endregion


#region Accessor Method
func set_dimention(val : NodeCameraUtility.DIMENSION) -> void:
	if val == dimention:
		return
	follow_target = null
	follow_type = 0
	dimention = val
	notify_property_list_changed()
func get_dimention() -> NodeCameraUtility.DIMENSION:
	return dimention

func set_follow_target(val : Node) -> void:
	if !(val is Node2D) && !(val is Node3D):
		val = null
	if val == follow_target:
		return
	follow_target = val
	notify_stage_masks_changed()
func get_follow_target() -> Node:
	return follow_target

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


func set_one_shot(val : bool) -> void:
	if val == one_shot:
		return
	one_shot = val
	notify_stage_masks_changed()
func get_one_shot() -> bool:
	return one_shot
#endregion


#region Private Methods
func _handle_glue(target : NodeCameraState) -> void:
	if (dimention == NodeCameraUtility.DIMENSION.THREE_DIMENSIONAL) != (target is NodeCamera3DState):
		return
	if dimention == NodeCameraUtility.DIMENSION.THREE_DIMENSIONAL:
		if follow_type == NodeCameraUtility.FOLLOW_TYPE.LOOK_AT:
			NodeCameraUtility.look_at_camera(
				target, follow_target.global_position + offset_3d, Vector3.UP
			)
			return
		if follow_type == NodeCameraUtility.FOLLOW_TYPE.FIT:
			NodeCameraUtility.fit_to_point_3D(
				target, follow_target.global_position + offset_3d
			)
			return
		if follow_type == NodeCameraUtility.FOLLOW_TYPE.ROTATE_MIMIC:
			target.rotation = follow_target.global_rotation
			return
		target.global_position = follow_target.global_position + offset_3d
		return
	
	if follow_type == NodeCameraUtility.FOLLOW_TYPE.FIT:
		NodeCameraUtility.fit_to_point_2D(
			target, follow_target.global_position + offset_2d
		)
		return
	target.global_position = follow_target.global_position + offset_2d
#endregion

# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
