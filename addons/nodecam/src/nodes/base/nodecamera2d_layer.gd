# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
@tool
@abstract
@icon("uid://dssbc6kgt43an")
class_name NodeCamera2DLayer extends Node
## The base layer for all camera manipulation.


#region Signals
signal activated
signal deactivated

signal priority_changed
signal camera_mask_changed

signal tick_requirement_changed
#endregion


#region External Variables
@export var disabled : bool:
	set = set_disabled,
	get = get_disabled
@export var priority : int:
	set = set_priority,
	get = get_priority
@export var camera_mask : int = 1:
	set = set_camera_mask,
	get = get_camera_mask
#endregion



#region Virtual Methods
func _notification(what: int) -> void:
	match what:
		NOTIFICATION_ENTER_TREE:
			NodeCamera2DManager.register_layer(self)
		NOTIFICATION_EXIT_TREE:
			NodeCamera2DManager.unregister_layer(self)
#endregion


#region Public Accessor Methods
func set_disabled(val : bool) -> void:
	if val == disabled:
		return
	disabled = val 
	
	if is_inside_tree():
		if val:
			NodeCamera2DManager.unregister_layer(self)
			return
		NodeCamera2DManager.register_layer(self)
func get_disabled() -> bool:
	return disabled

func set_priority(val : int) -> void:
	if val == priority:
		return
	priority = val
	priority_changed.emit()
func get_priority() -> int:
	return priority

func set_camera_mask(val : int) -> void:
	if val == camera_mask:
		return
	camera_mask = val
	camera_mask_changed.emit()
func get_camera_mask() -> int:
	return camera_mask
#endregion

# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
