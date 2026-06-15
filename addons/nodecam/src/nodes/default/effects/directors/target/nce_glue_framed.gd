# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
@tool
class_name NodeCameraEffectGlueFramed extends NodeCameraEffect
## A [Camera2D] effect that applies a deadzone on a frame, only
## following the target's position when it tries to leave the deadzone.
## [br[br]
## [b]NOTE[/b]: Currently only works for 2D.

#region External Variables
## Determines if this node should be used for 2D or 3D purposes.
## [br][br]
## Also see [enum NodeCameraUtility.DIMENSION].
var dimention : NodeCameraUtility.DIMENSION = NodeCameraUtility.DIMENSION.TWO_DIMENSIONAL:
	set = set_dimention,
	get = get_dimention

## The node, either [Node2D] or [Node3D], this effect will follow.
## [br][br]
## Also see [member dimention]. 
var follow_target : Node:
	set = set_follow_target,
	get = get_follow_target

## The deadzone this effect uses. Each coordinate uses a ratio
## (from 0.0 to 1.0) to calculate the frame's width and height, depending
## on the current viewport of the camera.
var dead_zone := Vector2(0.2, 0.2)

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

## The normal that will be used in camera position calculations, if
## [member dimention] is [code]THREE_DIMENSIONAL[/code].
## [br][br]
## Also see [member dimention]. 
var normal := Vector3.UP:
	set = set_normal,
	get = get_normal

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
	
	ret.append({
		"name": "dead_zone",
		"type": TYPE_VECTOR2,
		"usage": PROPERTY_USAGE_DEFAULT
	})
	
	ret.append({
		"name": "Additional Arguments",
		"type": TYPE_NIL,
		"usage": PROPERTY_USAGE_GROUP,
	})
	ret.append({
		"name": "offset",
		"type": TYPE_VECTOR2 if dimention == NodeCameraUtility.DIMENSION.TWO_DIMENSIONAL else TYPE_VECTOR3,
		"usage": PROPERTY_USAGE_DEFAULT
	})
	
	if dimention == NodeCameraUtility.DIMENSION.THREE_DIMENSIONAL:
		ret.append({
			"name": "normal",
			"type": TYPE_VECTOR3,
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
		&"offset":
			return (
				offset_2d != Vector2.ZERO if dimention == NodeCameraUtility.DIMENSION.TWO_DIMENSIONAL
				else offset_3d != Vector3.ZERO
			)
		&"normal":
			return normal != Vector3.UP
		&"one_shot":
			return one_shot
	return false
func _property_get_revert(property: StringName) -> Variant:
	match property:
		&"dimention":
			return NodeCameraUtility.DIMENSION.TWO_DIMENSIONAL
		&"follow_target":
			return null
		&"offset":
			return (
				Vector2.ZERO if dimention == NodeCameraUtility.DIMENSION.TWO_DIMENSIONAL
				else Vector3.ZERO
			)
		&"normal":
			return Vector3.UP
		&"one_shot":
			return false
	return null

func _set(property: StringName, value: Variant) -> bool:
	if property == "offset":
		if dimention == NodeCameraUtility.DIMENSION.TWO_DIMENSIONAL:
			offset_2d = value
		else:
			offset_3d = value
		return true
	return false
func _get(property: StringName) -> Variant:
	if property == "offset":
		return (
			offset_2d if dimention == NodeCameraUtility.DIMENSION.TWO_DIMENSIONAL
			else offset_3d
		)
	return null
#endregion


#region Virtual Methods (User Overwrite)
## Implements the [method NodeCameraEffect.process_effect] method.
func process_effect(
	_delta : float, target : NodeCameraState, _stage : LAYER_STAGES
) -> void:
	if target is NodeCamera2DState:
		NodeCameraUtility.frame_camera_2D(
			target, follow_target.global_position + offset_2d, dead_zone
		)
		return
	NodeCameraUtility.frame_camera_3D(
		target, follow_target.global_position + offset_3d, normal, dead_zone
	)

## Implements the [method NodeCameraEffect.effect_stage_changed] method.
func effect_stage_changed(
	target : NodeCameraState, _stage : LAYER_STAGES
) -> void:
	if target is NodeCamera2DState:
		NodeCameraUtility.frame_camera_2D(
			target, follow_target.global_position + offset_2d, dead_zone
		)
		return
	NodeCameraUtility.frame_camera_3D(
		target, follow_target.global_position + offset_3d, normal, dead_zone
	)
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

func set_offset_2d(val : Vector2) -> void:
	offset_2d = val
func get_offset_2d() -> Vector2:
	return offset_2d
func set_offset_3d(val : Vector3) -> void:
	offset_3d = val
func get_offset_3d() -> Vector3:
	return offset_3d

func set_normal(val : Vector3) -> void:
	normal = val
func get_normal() -> Vector3:
	return normal

func set_one_shot(val : bool) -> void:
	if val == one_shot:
		return
	one_shot = val
	notify_stage_masks_changed()
func get_one_shot() -> bool:
	return one_shot
#endregion

# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
