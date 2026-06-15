# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
@tool
class_name NodeCameraEffectCamera extends NodeCameraEffect
## An effect that sets the camera position to a given target.

#region External Variables
## Determines if this node should be used for 2D or 3D purposes.
## [br][br]
## Also see [enum NodeCameraUtility.DIMENSION].
var dimention : NodeCameraUtility.DIMENSION = NodeCameraUtility.DIMENSION.TWO_DIMENSIONAL:
	set = set_dimention,
	get = get_dimention

## The the node, either [Node2D] or [Node3D], this effect will follow.
## [br][br]
## Also see [member dimention]. 
var camera : Node:
	set = set_camera,
	get = get_camera

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
		"name": "camera",
		"type": TYPE_OBJECT,
		"hint": PROPERTY_HINT_NODE_TYPE,
		"hint_string": "Camera2D" if dimention == NodeCameraUtility.DIMENSION.TWO_DIMENSIONAL else "Camera3D",
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
		&"camera":
			return camera != null
		&"one_shot":
			return one_shot
	return false
func _property_get_revert(property: StringName) -> Variant:
	match property:
		&"dimention":
			return NodeCameraUtility.DIMENSION.TWO_DIMENSIONAL
		&"camera":
			return null
		&"one_shot":
			return false
	return null
#endregion


#region Virtual Methods (User Overwrite)
func process_effect(
	_delta : float, target : NodeCameraState, _stage : LAYER_STAGES
) -> void:
	if (camera is Camera2D) != (dimention == NodeCameraUtility.DIMENSION.TWO_DIMENSIONAL):
		return
	target.overwrite_status_with(camera)

func effect_stage_changed(
	target : NodeCameraState, _stage : LAYER_STAGES
) -> void:
	if (camera is Camera2D) != (dimention == NodeCameraUtility.DIMENSION.TWO_DIMENSIONAL):
		return
	target.overwrite_status_with(camera)
#endregion


#region Public Methods (Stages)
func get_needed_process_stages() -> PackedInt32Array:
	if camera && !one_shot:
		return [LAYER_STAGES.RUNNING]
	return []
func get_needed_change_stages() -> PackedInt32Array:
	if camera:
		return [LAYER_STAGES.STARTING]
	return []
#endregion


#region Accessor Method
func set_dimention(val : NodeCameraUtility.DIMENSION) -> void:
	if val == dimention:
		return
	camera = null
	dimention = val
	notify_property_list_changed()
func get_dimention() -> NodeCameraUtility.DIMENSION:
	return dimention

func set_camera(val : Node) -> void:
	if !(val is Camera2D) && !(val is Camera3D):
		val = null
	if val == camera:
		return
	camera = val
	notify_stage_masks_changed()
func get_camera() -> Node:
	return camera


func set_one_shot(val : bool) -> void:
	if val == one_shot:
		return
	one_shot = val
	notify_stage_masks_changed()
func get_one_shot() -> bool:
	return one_shot
#endregion
# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
