# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
@tool
@abstract
@icon("uid://dssbc6kgt43an")
class_name NodeCameraLayer extends Node
## The base layer for all camera manipulation.

#region Signals
signal activated
signal deactivated

signal priority_changed
signal camera_mask_changed

signal tick_requirement_changed
#endregion


#region Enums
const LAYER_STAGES	= NodeCameraExecutionScope.LAYER_STAGES
const TICK_TYPE		= NodeCameraExecutionScope.TICK_TYPE
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


#region Private Variables
var _scope : NodeCameraExecutionScope
#endregion



#region Virtual Methods
func _notification(what: int) -> void:
	if disabled:
		return
	
	match what:
		NOTIFICATION_ENTER_TREE:
			_register()
		NOTIFICATION_EXIT_TREE:
			_unregister()
#endregion


#region Private Methods (Register)
func _unregister() -> void:
	var parent := get_parent()
	
	if parent is NodeCameraMulti:
		parent.unregister_layer(self)
		return
	NodeCameraManager.unregister_layer(self)
func _register() -> void:
	var parent := get_parent()
	
	if parent is NodeCameraMulti:
		parent.register_layer(self)
		return
	NodeCameraManager.register_layer(self)
#endregion


#region Public Methods (Accessors)
func set_disabled(val : bool) -> void:
	if val == disabled:
		return
	disabled = val 
	
	if is_inside_tree():
		if val:
			_unregister()
			return
		_register()
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


#region Tick Methods
@abstract
func _get_tick_mask(param_scope : NodeCameraExecutionScope) -> int
#endregion


#region Public Methods (Check)
func is_top_level() -> bool:
	return false
#endregion

# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
