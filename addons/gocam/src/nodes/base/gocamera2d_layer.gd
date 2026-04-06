@tool
@icon("uid://dssbc6kgt43an")
class_name GoCamera2DLayer extends Node
## The base layer for all camera manipulation.


#region Signals
## Emited when this [GoCamera2DLayer] is activated.
## [br][br]
## Also see: [member active] and [member disabled].
signal activated
## Emited when this [GoCamera2DLayer] is deactivated.
## [br][br]
## Also see: [member active] and [member disabled].
signal deactivated

## Emited when the [member priority] is changed.
signal priority_changed
## Emited when the starting or stopping tick updates.
## [br][br]
## Also see [method GoCamera2DEffect.effect_tick], and
## [method GoCamera2DTransition.transition_tick].
signal tick_state_changed

## Emited when the [member camera_flag_mask] is changed.
signal camera_mask_changed(old : int)
#endregion


#region Constants
## The script containing all shared constants used by the GoCamera2D addon.
const CONSTANTS := preload("uid://b8t21yw0evfx")
#endregion


#region Private
var _master_manager := GoCamera2DLayerManager.new()

var _is_in_group : bool = false
var _is_top_level : bool = false
#endregion


#region External Variables
## The priority order this layer will be run in. In the case of a tie, then
## layers activated first are given priority.
## [br][br]
## [b]NOTE[/b]: This priority will be local to the group if not
## top_level.
@export var priority : int = 0:
	set = set_priority,
	get = get_priority
## If [code]true[/code], this property disabled the activation of this layer.
@export var disabled : bool = false:
	set = set_disabled,
	get = get_disabled
## If [code]true[/code], this layer is always considered top_level, regardless
## of it is in a group or not.
@export var top_level : bool = false:
	set = set_top_level,
	get = get_top_level

@export_group("Group Manage")
## Activates or deactivates this layer. If this layer is in a group,
## this property is readonly.
@export var active : bool = true:
	set = set_active,
	get = get_active
## Sets a mask that [GoCamera2DHost] will use filter out unneeded layers.
## If this layer is in a group, this property is readonly.
@export var camera_flag_mask : int = 1:
	set = set_camera_flag_mask,
	get = get_camera_flag_mask
#endregion



#region Virtual Methods
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
## Sets the [member disabled] property of this layer.
func set_disabled(val : bool) -> void:
	if val == disabled:
		return
	disabled = val
	
	if active:
		tick_state_changed.emit()
		
		if !disabled:
			activated.emit()
			return
		deactivated.emit()
## Gets the [member disabled] property of this layer.
func get_disabled() -> bool:
	return disabled

## Sets the [member priority] property of this layer.
func set_priority(val : int) -> void:
	if val == priority:
		return
	priority = val
	priority_changed.emit()
## Gets the [member priority] property of this layer.
func get_priority() -> int:
	return priority

## Sets the [member top_level] property of this layer.
func set_top_level(val : bool) -> void:
	if val == top_level:
		return
	top_level = val
	_settup_registry()
## Gets the [member top_level] property of this layer.
func get_top_level() -> bool:
	return top_level

## Sets the [member active] property of this layer.
func set_active(val : bool) -> void:
	if val == active:
		return
	active = val
	
	if !disabled:
		tick_state_changed.emit()
		
		if active:
			activated.emit()
			return
		deactivated.emit()
## Gets the [member active] property of this layer.
func get_active() -> bool:
	return active

## Sets the [member camera_flag_mask] property of this layer.
func set_camera_flag_mask(val : int) -> void:
	if val == camera_flag_mask:
		return
	
	var old := camera_flag_mask
	camera_flag_mask = val
	camera_mask_changed.emit(old)
## Gets the [member camera_flag_mask] property of this layer.
func get_camera_flag_mask() -> int:
	return camera_flag_mask
#endregion


#region Public Methods (Notify)
## Notifies this layer's manager that tick updates should either be started
## or stopped.
## [br][br]
## Also see [method GoCamera2DEffect.effect_tick],
## [method GoCamera2DTransition.transition_tick], and [signal tick_state_changed].
func notify_tick_changed() -> void:
	tick_state_changed.emit()
#endregion


#region Public Methods (State Checkers)
## Returns [code]true[/code] if this node is in a child of a [GoCamera2DGroup] node.
func is_in_layer_group() -> bool:
	return _is_in_group
## Returns [code]true[/code] if this node is top_level.
## A layer is considered top_level if either [member top_level] is [code]true[/code]
## or this layer is not a child of a [GoCamera2DGroup] node.
func is_top_level() -> bool:
	return _is_top_level

## Returns if this layer is running. This is equivalent to
## [code]active && !disabled[/code].
func is_running() -> bool:
	return active && !disabled

## Returns if this layer is subscribed for tick updates.
## [br][br]
## Also see: [signal tick_state_changed] and [method notify_tick_changed].
func is_subscribed() -> bool:
	return _master_manager.is_layer_subscribed(self)
#endregion
