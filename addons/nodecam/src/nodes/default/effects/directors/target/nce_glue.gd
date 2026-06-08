# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
@tool
class_name NodeCameraEffectGlue extends NodeCameraEffect
## An effect that sets the camera position to a given target.

#region External Variables
## Determines if this node should be used for 2D or 3D purposes.
## [br][br]
## Also see [enum NodeCameraUtility.DIMENSION].
var is_2d : NodeCameraUtility.DIMENSION = NodeCameraUtility.DIMENSION.TWO_DIMENSIONAL:
	set = set_is_2d,
	get = get_is_2d

## The the node, either [Node2D] or [Node3D], this effect will follow.
## [br][br]
## Also see [member is_2d]. 
var follow_target : Node:
	set = set_follow_target,
	get = get_follow_target

## Determines whether a 3D camera will look at the target position, or
## reposition itself to the target position
var follow_type := NodeCameraUtility.FOLLOW_TYPE.POSITION:
	set = set_follow_type,
	get = get_follow_type
	
## The offset that will be applied to the camera's position, if
## [member is_2d] is [code]true[/code].
var offset_2d := Vector2.ZERO:
	set = set_offset_2d,
	get = get_offset_2d
## The offset that will be applied to the camera's position, if
## [member is_2d] is [code]false[/code].
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
		"name": "is_2d",
		"type": TYPE_INT,
		"hint": PROPERTY_HINT_ENUM,
		"hint_string": NodeCameraUtility.DIMENSION_FLAGS,
		"usage": PROPERTY_USAGE_DEFAULT
	})
	
	ret.append({
		"name": "follow_target",
		"type": TYPE_OBJECT,
		"hint": PROPERTY_HINT_NODE_TYPE,
		"hint_string": "Node2D" if is_2d == NodeCameraUtility.DIMENSION.TWO_DIMENSIONAL else "Node3D",
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
	
	ret.append({
		"name": "offset",
		"type": TYPE_VECTOR2 if is_2d == NodeCameraUtility.DIMENSION.TWO_DIMENSIONAL else TYPE_VECTOR3,
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
		&"is_2d":
			return is_2d != NodeCameraUtility.DIMENSION.TWO_DIMENSIONAL
		&"follow_target":
			return follow_target != null
		&"follow_type":
			return follow_type != NodeCameraUtility.FOLLOW_TYPE.POSITION
		&"offset":
			return (
				offset_2d != Vector2.ZERO if is_2d == NodeCameraUtility.DIMENSION.TWO_DIMENSIONAL
				else offset_3d != Vector3.ZERO
			)
		&"one_shot":
			return one_shot
	return false
func _property_get_revert(property: StringName) -> Variant:
	match property:
		&"is_2d":
			return NodeCameraUtility.DIMENSION.TWO_DIMENSIONAL
		&"follow_target":
			return null
		&"follow_type":
			return NodeCameraUtility.FOLLOW_TYPE.POSITION
		&"offset":
			return Vector2.ZERO if is_2d == NodeCameraUtility.DIMENSION.TWO_DIMENSIONAL else Vector3.ZERO
		&"one_shot":
			return false
	return null
#endregion


#region Virtual Methods (User Overwrite)
func process_effect(
	_delta : float, target : NodeCameraState, _stage : LAYER_STAGES
) -> void:
	_handle_glue(target)

func effect_stage_changed(
	target : NodeCameraState, _stage : LAYER_STAGES
) -> void:
	_handle_glue(target)
#endregion


#region Public Methods (Stages)
func get_needed_process_stages() -> PackedInt32Array:
	if follow_target && !one_shot:
		return [LAYER_STAGES.RUNNING]
	return []
func get_needed_change_stages() -> PackedInt32Array:
	if follow_target:
		return [LAYER_STAGES.STARTING]
	return []
#endregion


#region Accessor Method
func set_is_2d(val : NodeCameraUtility.DIMENSION) -> void:
	if val == is_2d:
		return
	follow_target = null
	is_2d = val
	notify_property_list_changed()
func get_is_2d() -> NodeCameraUtility.DIMENSION:
	return is_2d

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
	if (is_2d == NodeCameraUtility.DIMENSION.THREE_DIMENSIONAL) != (target is NodeCamera3DState):
		return
	if is_2d == NodeCameraUtility.DIMENSION.THREE_DIMENSIONAL:
		if follow_type == NodeCameraUtility.FOLLOW_TYPE.LOOK_AT:
			NodeCameraUtility.look_at_camera(target, follow_target.position + offset_3d, Vector3.UP)
			return
		target.global_position = follow_target.position + offset_3d
		return
	target.global_position = follow_target.position + offset_2d
#endregion

# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
