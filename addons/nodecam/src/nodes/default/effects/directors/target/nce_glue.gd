# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
@tool
class_name NodeCameraEffectGlue extends NodeCameraEffect
## An effect that sets the camera position to a given target.

#region External Variables
## Determines if this node should be used for 2D or 3D purposes.
@export var is_2d : bool = true:
	set = set_is_2d,
	get = get_is_2d

@export_group("Additional Arguments")
## The the node, either [Node2D] or [Node3D], this effect will follow.
## [br][br]
## Also see [member is_2d]. 
var follow_target : Node:
	set = set_follow_target,
	get = get_follow_target

##
var follow_type : bool = true:
	set = set_follow_type,
	get = get_follow_type
	
## The offset, either [Vector2] or [Vector3], that will be applied to
## the camera position.
## [br][br]
## Also see [member is_2d]. 
var offset : Variant = Vector2.ZERO:
	set = set_offset,
	get = get_offset

## If [code]true[/code], the layer will only set the effect's position
## for one frame in [method effect_stage_changed]'s starting stage.
## [br][br]
## Also see [enum NodeCameraExecutionScope.LAYER_STAGES].
var one_shot : bool = false:
	set = set_one_shot,
	get = get_one_shot
#endregion



#region Virtual Methods
func _init() -> void:
	if offset == null:
		offset = Vector2.ZERO if is_2d else Vector3.ZERO
func _get_property_list() -> Array[Dictionary]:
	var ret : Array[Dictionary]
	
	ret.append({
		"name": "follow_target",
		"type": TYPE_OBJECT,
		"hint": PROPERTY_HINT_NODE_TYPE,
		"hint_string": "Node2D" if is_2d else "Node3D",
		"usage": PROPERTY_USAGE_DEFAULT
	})
	
	if !is_2d:
		ret.append({
			"name": "follow_type",
			"type": TYPE_INT,
			"hint": PROPERTY_HINT_ENUM,
			"hint_string": "Position:0, Look:1",
			"usage": PROPERTY_USAGE_DEFAULT
		})
	
	ret.append({
		"name": "offset",
		"type": TYPE_VECTOR2 if is_2d else TYPE_VECTOR3,
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
		&"follow_target":
			return follow_target != null
		&"follow_type":
			return !follow_type
		&"offset":
			return offset != Vector2.ZERO if is_2d else offset != Vector3.ZERO
		&"one_shot":
			return one_shot
	return false
func _property_get_revert(property: StringName) -> Variant:
	match property:
		&"follow_target":
			return null
		&"follow_type":
			return true
		&"offset":
			return Vector2.ZERO if is_2d else Vector3.ZERO
		&"one_shot":
			return false
	return null
#endregion


#region Virtual Methods (User Overwrite)
func process_effect(
	_delta : float, target : NodeCameraState, _stage : LAYER_STAGES
) -> void:
	if !is_2d && target is NodeCamera3DState && follow_type:
		NodeCameraUtility.look_at_camera(target, follow_target.position, Vector3.UP)
		return
	target.global_position = follow_target.position + offset

func effect_stage_changed(
	target : NodeCameraState, _stage : LAYER_STAGES
) -> void:
	if !is_2d && target is NodeCamera3DState && follow_type:
		NodeCameraUtility.look_at_camera(target, follow_target.position, Vector3.UP)
		return
	target.global_position = follow_target.position + offset
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
func set_is_2d(val : bool) -> void:
	if val == is_2d:
		return
	follow_target = null
	offset = Vector2.ZERO if val else Vector3.ZERO
	is_2d = val
	notify_property_list_changed()
func get_is_2d() -> bool:
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

func set_follow_type(val : bool) -> void:
	if val == follow_type:
		return
	follow_type = val
	notify_property_list_changed()
func get_follow_type() -> bool:
	return follow_type


func set_offset(val : Variant) -> void:
	offset = val
func get_offset() -> Variant:
	return offset


func set_one_shot(val : bool) -> void:
	if val == one_shot:
		return
	one_shot = val
	notify_stage_masks_changed()
func get_one_shot() -> bool:
	return one_shot
#endregion

# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
