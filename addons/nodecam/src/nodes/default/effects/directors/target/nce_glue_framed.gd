# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
@tool
class_name NodeCameraEffectGlueFramed extends NodeCameraEffect
## A [Camera2D] effect that applies a deadzone on a frame, only
## following the target position when it tries to leave.
## [br[br]
## [b]NOTE[/b]: Currently only works for 2D.

#region External Variables
## Determines if this node should be used for 2D or 3D purposes.
@export var is_2d : bool = true:
	set = set_is_2d,
	get = get_is_2d

## The deadzone this transition uses. Each coordinate uses a ratio
## from 0-1 to calculate the frame's width and height, depending
## on the current viewport of the camera.
@export var dead_zone := Vector2(0.2, 0.2)

@export_group("Additional Arguments")
## The the node, either [Node2D] or [Node3D], this effect will follow.
## [br][br]
## Also see [member is_2d]. 
var follow_target : Node:
	set = set_follow_target,
	get = get_follow_target

## The offset that will be applied to the camera position, if
## [member is_2d] is [code]true[/code].
## [br][br]
## Also see [member is_2d]. 
var offset := Vector2.ZERO:
	set = set_offset,
	get = get_offset

## The distance that will be used in camera position calculations, if
## [member is_2d] is [code]false[/code].
## [br][br]
## Also see [member is_2d]. 
var distance : float = 100.0:
	set = set_distance,
	get = get_distance
	

## If [code]true[/code], the layer will only set the effect's position
## for one frame in [method effect_stage_changed]'s starting stage.
## [br][br]
## Also see [enum NodeCameraExecutionScope.LAYER_STAGES].
var one_shot : bool = false:
	set = set_one_shot,
	get = get_one_shot
#endregion



#region Virtual Methods
func _get_property_list() -> Array[Dictionary]:
	var ret : Array[Dictionary]
	
	ret.append({
		"name": "follow_target",
		"type": TYPE_OBJECT,
		"hint": PROPERTY_HINT_NODE_TYPE,
		"hint_string": "Node2D" if is_2d else "Node3D",
		"usage": PROPERTY_USAGE_DEFAULT
	})
	
	if is_2d:
		ret.append({
			"name": "offset",
			"type": TYPE_VECTOR2,
			"usage": PROPERTY_USAGE_DEFAULT
		})
	else:
		ret.append({
			"name": "distance",
			"type": TYPE_FLOAT,
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
		&"offset":
			return offset != Vector2.ZERO
		&"distance":
			return distance != 100.0
		&"one_shot":
			return one_shot
	return false
func _property_get_revert(property: StringName) -> Variant:
	match property:
		&"follow_target":
			return null
		&"offset":
			return Vector2.ZERO
		&"distance":
			return 100.0
		&"one_shot":
			return false
	return null
#endregion


#region Virtual Methods (User Overwrite)
func process_effect(
	_delta : float, target : NodeCameraState, _stage : LAYER_STAGES
) -> void:
	if target is NodeCamera2DState:
		NodeCameraUtility.frame_camera_2D(
			target, follow_target.global_position + offset, dead_zone
		)
		return
	NodeCameraUtility.frame_camera_3D(
		target, follow_target.global_position, distance, dead_zone
	)

func effect_stage_changed(
	target : NodeCameraState, _stage : LAYER_STAGES
) -> void:
	if target is NodeCamera2DState:
		NodeCameraUtility.frame_camera_2D(
			target, follow_target.global_position + offset, dead_zone
		)
		return
	NodeCameraUtility.frame_camera_3D(
		target, follow_target.global_position, distance, dead_zone
	)
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

func set_offset(val : Vector2) -> void:
	offset = val
func get_offset() -> Vector2:
	return offset

func set_distance(val : float) -> void:
	distance = val
func get_distance() -> float:
	return distance

func set_one_shot(val : bool) -> void:
	if val == one_shot:
		return
	one_shot = val
	notify_stage_masks_changed()
func get_one_shot() -> bool:
	return one_shot
#endregion

# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
