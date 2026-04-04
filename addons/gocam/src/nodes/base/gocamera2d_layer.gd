@tool
class_name GoCamera2DLayer extends Node


#region Constants
const CONSTANTS := preload("uid://b8t21yw0evfx")
#endregion


#region Private
var _master_manager := GoCamera2DLayerManager.new()

var _is_in_group : bool = false
var _is_top_level : bool = false
#endregion


#region External Variables
@export var priority : int = 0:
	set = set_priority,
	get = get_priority
@export var disabled : bool = false:
	set = set_disabled,
	get = get_disabled
@export var top_level : bool = false:
	set = set_top_level,
	get = get_top_level

@export_group("Top Level")
@export var active : bool = true:
	set = set_active,
	get = get_active
@export var camera_flag_mask : int = 1:
	set = set_camera_flag_mask,
	get = get_camera_flag_mask
#endregion



#region Virtual Methods
func _init() -> void:
	_settup_private_signals()
func _notification(what: int) -> void:
	match what:
		NOTIFICATION_READY, NOTIFICATION_POST_ENTER_TREE:
			_settup_group()
			_settup_registry()
		NOTIFICATION_PREDELETE:
			_master_manager.unregister_layer(self)

func _validate_property(property: Dictionary) -> void:
	if _is_in_group && property.name in [&"active", &"camera_flag_mask"]:
		property.usage |= PROPERTY_USAGE_READ_ONLY
#endregion


#region Private Methods (Helper)
func _settup_private_signals() -> void:
	if !has_signal(CONSTANTS.INTERAL_PRIORITY_CHANGED):
		add_user_signal(
			CONSTANTS.INTERAL_PRIORITY_CHANGED,
			[{"name": "effect", "type": TYPE_OBJECT}]
		)
	if !has_signal(CONSTANTS.INTERAL_TICK_CHANGED):
		add_user_signal(
			CONSTANTS.INTERAL_TICK_CHANGED,
			[{"name": "effect", "type": TYPE_OBJECT}]
		)

func _settup_group() -> void:
	_is_in_group = (get_parent() is GoCamera2DGroup)
func _settup_registry() -> void:
	if !is_node_ready():
		return
	_master_manager.unregister_layer(self)
	
	if !top_level:
		var parent := get_parent()
		if parent is GoCamera2DGroup:
			_is_top_level = false
			notify_property_list_changed()
			
			_master_manager = parent.get_layer_manager()
			_master_manager.register_layer(self)
			return
	
	_is_top_level = true
	notify_property_list_changed()
	
	_master_manager = GoCamera2DManager.get_layer_manager()
	_master_manager.register_layer(self)
#endregion


#region Public Methods (Accessor)
func set_disabled(val : bool) -> void:
	if val == disabled:
		return
	disabled = val
	
	if active:
		emit_signal(CONSTANTS.INTERAL_TICK_CHANGED, self)
func get_disabled() -> bool:
	return disabled

func set_priority(val : int) -> void:
	if val == priority:
		return
	priority = val
	emit_signal(CONSTANTS.INTERAL_PRIORITY_CHANGED, self)
func get_priority() -> int:
	return priority

func set_top_level(val : bool) -> void:
	if val == top_level:
		return
	top_level = val
	_settup_registry()
func get_top_level() -> bool:
	return top_level

func set_active(val : bool) -> void:
	if val == active:
		return
	active = val
	
	if !disabled:
		emit_signal(CONSTANTS.INTERAL_TICK_CHANGED, self)
func get_active() -> bool:
	return active

func set_camera_flag_mask(val : int) -> void:
	if val == camera_flag_mask:
		return
	camera_flag_mask = val
func get_camera_flag_mask() -> int:
	return camera_flag_mask
#endregion


#region Public Methods (Notify)
func notify_tick_changed() -> void:
	emit_signal(CONSTANTS.INTERAL_TICK_CHANGED, self)
#endregion


#region Public Methods (State Checkers)
func is_in_layer_group() -> bool:
	return _is_in_group
func is_top_level() -> bool:
	return _is_top_level

func is_running() -> bool:
	return active && !disabled

func is_subscribed() -> bool:
	return _master_manager.is_layer_subscribed(self)
#endregion
