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

var _parent_scopes : Array[NodeCameraExecutionScope]
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


#region Flag Methods
func _flag_priority_changed(old : int) -> void:
	for scope : NodeCameraExecutionScope in _parent_scopes:
		scope.flag_reorder_layer(self, old)
func _flag_camera_mask_changed(old : int) -> void:
	for scope : NodeCameraExecutionScope in _parent_scopes:
		scope.flag_camera_mask_changed(self, old)

## Flags all active cached scopes to be recreated.
func flag_refresh_scopes() -> void:
	for scope : NodeCameraExecutionScope in _parent_scopes:
		scope.flag_construct_scope()
#endregion


#region Tick Methods
## An abstract method that determines the classification of this
## [NodeCameraLayer].
## [br][br]
## Also see: [enum NodeCameraExecutionScope.TICK_TYPE].
@abstract
func _get_tick_mask(param_scope : NodeCameraExecutionScope) -> int
#endregion


#region Accessor Methods
## Returns the current scope of the [color=#D6D000][b]Runtime Method[/b][/color].
## [br][br]
## [b]Note[/b]: This method can only be called in a
## [color=#D6D000][b]Runtime Method[/b][/color]. Undefined behavior otherwise.
## [br][br]
## [b]Note[/b]: Freeing the returned value may cause an engine crash.
func get_active_scope() -> NodeCameraExecutionScope:
	return _scope
## Returns all scopes this layer is currently active in.
## [br][br]
## [b]NOTE[/b]: Freeing any scope returned may cause an engine to crash.
func get_parent_scopes() -> Array[NodeCameraExecutionScope]:
	return _parent_scopes.duplicate()
## Returns if this layer is not currently active in any scope.
func without_parent_scopes() -> bool:
	return _parent_scopes.is_empty()

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
	
	var old := priority
	priority = val
	_flag_priority_changed(old)
	
	priority_changed.emit()
func get_priority() -> int:
	return priority

func set_camera_mask(val : int) -> void:
	if val == camera_mask:
		return
	
	var old := camera_mask
	camera_mask = val
	_flag_camera_mask_changed(old)
	
	camera_mask_changed.emit()
func get_camera_mask() -> int:
	return camera_mask
#endregion

# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
