# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
@tool
@icon("uid://chab621uln4on")
class_name NodeCameraHost extends Node
## The main controller for camera changes. Put this as a child of a
## [Camera2D] and [Camera3D] node to work.

#region Signals
## Emitted when the host is first registered in [NodeCameraManager], typically
## when inside the tree and as a child to a [Camera2D] and [Camera3D] node.
## [br][br]
## Also see [signal deactivate], [member disabled], [member run_in_engine],
## [method get_camera], and [method is_running].
signal activate
## Emitted when the host was previously registered in [NodeCameraManager], but
## later unregistered, typically when removed from the tree or as a child
## to a [Camera2D] and [Camera3D] node.
## [br][br]
## Also see [member disabled], [member run_in_engine], [method get_camera],
## and [method is_running].
signal deactivate

## Emitted when [member callback_mode] changes value.
signal callback_mode_changed
## Emitted when [member camera_mask] changes value.
signal camera_mask_changed
#endregion


#region Enums
## Represents possible modes this [NodeCameraHost] can use to determine when to
## update the camera on.
enum CALLBACK_MODES {
	AUTO,		## If this [NodeCameraHost] is a child to a [Camera3D], this mode will act like [constant CALLBACK_MODES.PHYSICS]. If a child to a [Camera2D] instead, this mode will change (when initially registering) according to the [Camera2D]'s [member Camera2D.process_callback].
	IDLE,		## This [NodeCameraHost] will run on the process frames. Also see [MainLoop._process].
	PHYSICS,	## This [NodeCameraHost] will run on the physic frames. Also see [MainLoop._physic].
	MANUAL		## This [NodeCameraHost] will not run automatically. Use [method process_tick] to run it.
}
#endregion


#region External Variables
## Determines when the attached camera is updated between frames.
@export var callback_mode : CALLBACK_MODES = CALLBACK_MODES.PHYSICS:
	set = set_callback_mode,
	get = get_callback_mode
## Provides a filter mask. NodeCamera nodes can exist in one or more of 32 layers.
## [br][br]
## [b]NOTE[/b]: This [NodeCameraHost] only processes [NodeCameraLayer] that share
## one or more layers, checked via a bitwise 'and' operation.
@export_flags_avoidance var camera_mask : int = 1:
	set = set_camera_mask,
	get = get_camera_mask

## If [code]true[/code], this [NodeCameraHost] will forcibly unregister.
@export var disabled : bool:
	set = set_disabled,
	get = get_disabled
## If [code]false[/code], this [NodeCameraHost] will forcibly unregister
## if run in the Engine editor.
@export var run_in_engine : bool:
	set = set_run_in_engine,
	get = get_run_in_engine
#endregion


#region Private Variables
var _camera : Node

var _scope : NodeCameraHostExecutionScope = NodeCameraHostExecutionScope.new(
	self, NodeCameraManager.get_layer_storage()
)
#endregion



#region Virtual Methods (Engine)
func _notification(what: int) -> void:
	match what:
		NOTIFICATION_ENTER_TREE:
			_settup_camera()
		NOTIFICATION_EXIT_TREE:
			NodeCameraManager.unregister_host(self)
		NOTIFICATION_PREDELETE:
			_scope.free()
#endregion


#region Camera Methods
func _settup_camera() -> void:
	_camera = get_parent()
	if !(_camera is Camera2D || _camera is Camera3D):
		_camera = null
		NodeCameraManager.unregister_host(self)
		return
	_scope._settup_camera_states()
	if is_running():
		NodeCameraManager.register_host(self)

## Returns the cached camera being acted on.
func get_camera() -> Node:
	return _camera
#endregion


#region Public Helper Methods
## Ignores all active [NodeCameraTransition]s and instantly sets the camera to
## the current state defined by active [NodeCameraEffect]s.
## [br][br]
## [b]NOTE[/b]: This does not affect the current status defined by all
## active [NodeCameraTransition] layers. If you also wish to affect those, use
## [method teleport_overwrite_status].
func teleport_status() -> void:
	_scope.teleport_cam_status()
## Similar to [method teleport_status], but also forces all active
## [NodeCameraTransition] to align with affect [NodeCameraEffect]s.
func teleport_overwrite_status() -> void:
	_scope.teleport_overwrite_cam_status()

## Forces the camera's effects and transitions to tick forward once.
func process_tick(delta: float) -> void:
	_scope.run_tick(delta)

## Returns if this [NodeCameraHost] should be considered running.
func is_running() -> bool:
	return (run_in_engine || !Engine.is_editor_hint()) && !disabled && _camera != null

## Returns the current [NodeCameraHostExecutionScope] attached to this
## [NodeCameraHost].
## [br][br]
## [b]NOTE[/b]: Freeing this may cause an engine crash.
func get_scope() -> NodeCameraHostExecutionScope:
	return _scope
#endregion


#region Public Accessor Methods
func set_callback_mode(val : CALLBACK_MODES) -> void:
	if val == callback_mode:
		return
	
	callback_mode = val
	callback_mode_changed.emit()
func get_callback_mode() -> CALLBACK_MODES:
	return callback_mode

func set_camera_mask(val : int) -> void:
	if val == camera_mask:
		return
	
	camera_mask = val
	camera_mask_changed.emit()
func get_camera_mask() -> int:
	return camera_mask

func set_disabled(val : bool) -> void:
	if val == disabled:
		return
	disabled = val
	
	if is_running():
		_scope.overwrite_cam_status()
		NodeCameraManager.register_host(self)
		return
	NodeCameraManager.unregister_host(self)
func get_disabled() -> bool:
	return disabled

func set_run_in_engine(val : bool) -> void:
	if val == run_in_engine:
		return
	run_in_engine = val
	
	if is_running():
		_scope.overwrite_cam_status()
		NodeCameraManager.register_host(self)
		return
	NodeCameraManager.unregister_host(self)
func get_run_in_engine() -> bool:
	return run_in_engine
#endregion

# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
