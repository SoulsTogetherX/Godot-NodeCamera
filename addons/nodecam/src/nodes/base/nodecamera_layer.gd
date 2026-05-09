# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
@tool
@abstract
@icon("uid://briuld2likt26")
class_name NodeCameraLayer extends Node
## The base NodeCam Layer node for all camera effects and transitions.

#region Signals
## Emitted when the layer is first registered in [NodeCameraManager]
## or a [NodeCameraGroup], typically from being added to the scenetree.
## [br][br]
## Also see [signal deactivated], and [member disabled].
signal activated
## Emitted when the layer was previously registered, but later unregistered
## from [NodeCameraManager] or a [NodeCameraGroup], typically from being
## removed from the scenetree.
## [br][br]
## Also see [signal activated], and [member disabled].
signal deactivated

## Emitted when [member priority] changes value.
signal priority_changed
## Emitted when [member camera_mask] changes value.
signal camera_mask_changed
#endregion


#region Enums
## The bitwise flags for [LayerRecord] stages. Also see
## [enum NodeCameraExecutionScope.LAYER_STAGES].
## [br][br]
## Stages go in order: [code]STARTING > RUNNING > ENDING > HAULTED[/code].
const LAYER_STAGES	= NodeCameraExecutionScope.LAYER_STAGES
## Defines what type a [LayerRecord] is defined as (effect,
## transition, both, or neither). Also see
## [enum NodeCameraExecutionScope.TICK_TYPE].
const TICK_TYPE		= NodeCameraExecutionScope.TICK_TYPE
#endregion


#region External Variables
## Controls the order [NodeCameraLayer]s are processed, when relevant.
## Higher priority layers are processed before lower priority layers.
@export var priority : int:
	set = set_priority,
	get = get_priority
## Provides a filter mask. NodeCamera nodes can exist in one or more of 32 layers.
## [br][br]
## [b]NOTE[/b]: This [NodeCameraLayer] is only processed by [NodeCameraHost] that
## share one or more layers, checked via a bitwise 'and' operation.
@export var camera_mask : int = 1:
	set = set_camera_mask,
	get = get_camera_mask

## If [code]true[/code], this [NodeCameraLayer] will forcibly unregister.
@export var disabled : bool:
	set = set_disabled,
	get = get_disabled
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
	
	if parent is NodeCameraGroup:
		parent.unregister_layer(self)
		return
	NodeCameraManager.unregister_layer(self)
func _register() -> void:
	var parent := get_parent()
	
	if parent is NodeCameraGroup:
		parent.register_layer(self)
		return
	NodeCameraManager.register_layer(self)
#endregion


#region Scope Methods
## A virtual method called when this [NodeCameraLayer] is added to the
## execution scope [param scope].
func _added_to_scope(scope : NodeCameraExecutionScope) -> void:
	pass
## A virtual method called when this [NodeCameraLayer] is removed from the
## execution scope [param scope].
func _removed_from_scope(scope : NodeCameraExecutionScope) -> void:
	pass
#endregion


#region Tick Methods
## An abstract method that determines the classification of this
## [NodeCameraLayer].
## [br][br]
## Also see: [enum NodeCameraExecutionScope.TICK_TYPE].
@abstract
func _get_tick_mask(param_scope : NodeCameraExecutionScope) -> int
#endregion


#region Public Methods (Accessors)
## Returns the current scope of the [color=#D6D000][b]Runtime Method[/b][/color].
## [br][br]
## [b]Note[/b]: This method can only be called in a
## [color=#D6D000][b]Runtime Method[/b][/color]. Undefined behavior otherwise.
## [br][br]
## [b]Note[/b]: Freeing the returned value may cause an engine crash.
func get_scope() -> NodeCameraExecutionScope:
	return _scope

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

# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
