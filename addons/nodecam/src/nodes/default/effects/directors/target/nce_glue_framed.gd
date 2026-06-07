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
		&"offset":
			return offset != Vector2.ZERO if is_2d else offset != Vector3.ZERO
		&"one_shot":
			return one_shot
	return false
func _property_get_revert(property: StringName) -> Variant:
	match property:
		&"follow_target":
			return null
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
	_process_frame(target)

func effect_stage_changed(
	target : NodeCameraState, _stage : LAYER_STAGES
) -> void:
	_process_frame(target)
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


#region Private Methods
func _process_frame(target : NodeCameraState) -> void:
	if target is NodeCamera2DState:
		var pos : Vector2 = follow_target.global_position
		
		var viewport_target_offset := Vector2.ZERO
		var cam : Camera2D = target.get_camera()
		var view_size : Vector2 = (
			cam.get_viewport_rect().size / target.zoom.abs()
		)
		
		## Dead Zone
		var viewport_dead_zone := Vector2(
			view_size.x * dead_zone.x, view_size.y * dead_zone.y
		) * 0.5
		var dead_zone := Vector4(
			cam.global_position.x - viewport_dead_zone.x,
			cam.global_position.x + viewport_dead_zone.x,
			cam.global_position.y - viewport_dead_zone.y,
			cam.global_position.y + viewport_dead_zone.y,
		)
		
		## Horizontal Dead Zone
		if dead_zone.x > pos.x:
			viewport_target_offset.x = dead_zone.x - pos.x
		elif dead_zone.y < pos.x:
			viewport_target_offset.x = dead_zone.y - pos.x
		
		## Vertical Dead Zone
		if dead_zone.z > pos.y:
			viewport_target_offset.y = dead_zone.z - pos.y
		elif dead_zone.w < pos.y:
			viewport_target_offset.y = dead_zone.w - pos.y
		
		target.global_position -= viewport_target_offset
#endregion

# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
