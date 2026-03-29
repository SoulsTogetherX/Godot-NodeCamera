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
		NOTIFICATION_POST_ENTER_TREE:
			_settup_private_signals()
#endregion


#region Public Virtual Methods
func start_tick() -> void:
	pass
func end_tick() -> void:
	pass

func process_tick(state : CameraStateResource) -> void:
	pass
func process_tick_needed() -> bool:
	return false
func notify_tick_request_changed() -> void:
	emit_signal(CONSTANTS.INTERAL_TICK_CHANGED, self)
#endregion


#region Private Methods (Helper)
func _settup_private_signals() -> void:
	if !has_signal(CONSTANTS.INTERAL_PRIORITY_CHANGED):
		add_user_signal(
			CONSTANTS.INTERAL_PRIORITY_CHANGED,
			[{"name": "layer", "type": TYPE_OBJECT}]
		)
	if !has_signal(CONSTANTS.INTERAL_TICK_CHANGED):
		add_user_signal(
			CONSTANTS.INTERAL_TICK_CHANGED,
			[{"name": "layer", "type": TYPE_OBJECT}]
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
	
	if disabled:
		return
	if active:
		start_tick()
		return
	end_tick()
func get_active() -> bool:
	return active

func set_disabled(val : bool) -> void:
	if val == disabled:
		return
	disabled = val
	
	if !active:
		return
	if disabled:
		end_tick()
		return
	start_tick()
func get_disabled() -> bool:
	return disabled

func set_top_level(val : bool) -> void:
	top_level = val
func get_top_level() -> bool:
	return top_level

func is_registered() -> bool:
	return GoCamera2DManager.is_effect_registered(self)
#endregion


#region Public Methods (Helper)
func activate() -> void:
	active = true
func deactivate() -> void:
	active = false
#endregion
