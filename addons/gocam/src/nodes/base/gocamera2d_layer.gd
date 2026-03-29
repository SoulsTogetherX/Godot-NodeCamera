@abstract
@tool
class_name GoCamera2DLayer extends Node


#region Signals
signal activated
signal deactivated
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
			_create_private_signal()
#endregion


#region Private Methods (Helper)
func _create_private_signal() -> void:
	if !has_signal(&"_priority_changed"):
		var new_signal = Signal(self, &"_priority_changed")
		add_user_signal(
			&"_priority_changed",
		)
#endregion


#region Public Methods (Accessor)
func set_priority(val : int) -> void:
	if priority == val:
		return
	priority = val
	
	if is_node_ready():
		emit_signal(&"_priority_changed", self)
func get_priority() -> int:
	return priority

func set_active(val : bool) -> void:
	active = val
func get_active() -> bool:
	return active

func set_disabled(val : bool) -> void:
	disabled = val
func get_disabled() -> bool:
	return disabled

func set_top_level(val : bool) -> void:
	top_level = val
func get_top_level() -> bool:
	return top_level
#endregion
