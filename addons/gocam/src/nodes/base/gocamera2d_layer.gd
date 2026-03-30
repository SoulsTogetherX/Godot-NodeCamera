@abstract
@tool
class_name GoCamera2DLayer extends Node


#region Constants
const CONSTANTS := preload("uid://b8t21yw0evfx")
#endregion


#region External Variables
@export var top_level : bool = false:
	set = set_top_level,
	get = get_top_level

@export var active : bool = false:
	set = set_active,
	get = get_active

@export var disabled : bool = false:
	set = set_disabled,
	get = get_disabled

@export var priority : int = 0:
	set = set_priority,
	get = get_priority
#endregion



#region Virtual Methods
func _notification(what: int) -> void:
	match what:
		NOTIFICATION_READY:
			_update_registry_check()
		NOTIFICATION_ENTER_TREE:
			_update_registry_check()
			_settup_private_signals()
		NOTIFICATION_PREDELETE:
			GoCamera2DManager.unregister_layer(self)

func _validate_property(property: Dictionary) -> void:
	match property.name:
		&"active", &"priority":
			if is_in_effect_group() && !top_level:
				property.usage |= PROPERTY_USAGE_READ_ONLY
#endregion


#region Public Virtual Methods
func layer_start() -> void:
	pass
func layer_end() -> void:
	pass

func process_tick_needed() -> bool:
	return false
func notify_tick_request_changed() -> void:
	emit_signal(CONSTANTS.INTERAL_TICK_CHANGED, self)
#endregion


#region Private Methods (Register)
func _update_registry_check() -> void:
	if !is_node_ready():
		return
	
	var should_register := (
		is_top_level() && active && !disabled
	)
	
	if should_register:
		GoCamera2DManager.register_layer(self)
		return
	GoCamera2DManager.unregister_layer(self)
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
#endregion


#region Public Methods (Accessor)
func set_priority(val : int) -> void:
	if priority == val:
		return
	priority = val
	
	if is_node_ready():
		emit_signal(CONSTANTS.INTERAL_PRIORITY_CHANGED, self)
func get_priority() -> int:
	return priority

func set_active(val : bool) -> void:
	if val == active:
		return
	active = val
	_update_registry_check()
	
	if disabled:
		return
	if active:
		layer_start()
		return
	layer_end()
func get_active() -> bool:
	return active

func set_disabled(val : bool) -> void:
	if val == disabled:
		return
	disabled = val
	_update_registry_check()
	
	if !active:
		return
	if disabled:
		layer_end()
		return
	layer_start()
func get_disabled() -> bool:
	return disabled

func set_top_level(val : bool) -> void:
	top_level = val
func get_top_level() -> bool:
	return top_level
#endregion


#region Public Methods (Helper)
func get_effect_group() -> GoCamera2DGroup:
	return get_parent() as GoCamera2DGroup
func is_in_effect_group() -> bool:
	return get_effect_group() != null

func is_top_level() -> bool:
	return top_level || !is_in_effect_group()

func is_registered() -> bool:
	return GoCamera2DManager.is_layer_registered(self)
#endregion


#region Public Methods (Helper)
func activate() -> void:
	active = true
func deactivate() -> void:
	active = false
#endregion
