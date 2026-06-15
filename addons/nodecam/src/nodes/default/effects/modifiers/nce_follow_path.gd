# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
@tool
class_name NodeCameraEffectFollowPath extends NodeCameraEffect
## An effect that clamps camera position to a path.

#region External Variables
## Determines if this node should be used for 2D or 3D purposes.
## [br][br]
## Also see [enum NodeCameraUtility.DIMENSION].
var dimention : NodeCameraUtility.DIMENSION = NodeCameraUtility.DIMENSION.TWO_DIMENSIONAL:
	set = set_dimention,
	get = get_dimention

@export_group("Additional Arguments")
## The path the effect will cling to.
var path_node: Node:
	set = set_path_node,
	get = get_path_node

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
		"name": "path_node",
		"type": TYPE_OBJECT,
		"hint": PROPERTY_HINT_NODE_TYPE,
		"hint_string": "Path2D" if dimention == NodeCameraUtility.DIMENSION.TWO_DIMENSIONAL else "Path3D",
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
		&"path_node":
			return path_node != null
		&"one_shot":
			return one_shot
	return false
func _property_get_revert(property: StringName) -> Variant:
	match property:
		&"path_node":
			return null
		&"one_shot":
			return false
	return null
#endregion


#region Virtual Methods (User Overwrite)
## Implements the [method NodeCameraEffect.process_effect] method.
func process_effect(
	delta : float, target : NodeCameraState, stage : LAYER_STAGES
) -> void:
	target.global_position = (
		path_node.curve.get_closest_point(target.global_position)
	) + path_node.global_position
#endregion


#region Public Methods (Stages)
## Implements the [method NodeCameraStaged.get_needed_process_stages] method.
func get_needed_process_stages() -> PackedInt32Array:
	if path_node:
		return [LAYER_STAGES.RUNNING]
	return []
#endregion


#region Accessor Method
func set_dimention(val : NodeCameraUtility.DIMENSION) -> void:
	if val == dimention:
		return
	path_node = null
	dimention = val
	notify_property_list_changed()
func get_dimention() -> NodeCameraUtility.DIMENSION:
	return dimention

func set_path_node(val : Node) -> void:
	if !(val is Path2D) && !(val is Path3D):
		val = null
	if val == path_node:
		return
	path_node = val
	notify_stage_masks_changed()
func get_path_node() -> Node:
	return path_node

func set_one_shot(val : bool) -> void:
	if val == one_shot:
		return
	one_shot = val
	notify_stage_masks_changed()
func get_one_shot() -> bool:
	return one_shot
#endregion

# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
