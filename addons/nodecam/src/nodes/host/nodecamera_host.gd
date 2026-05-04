# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
@tool
@icon("uid://kq0ubmkoup4y")
class_name NodeCameraHost extends Node
## The main node that controls the camera for the NodeCamera addon.

#region Signals
signal activate
signal deactivate

signal callback_mode_changed
signal camera_mask_changed
#endregion


#region Enums
## An enum used to denote at what times layers will run for
## each [NodeCameraHost].
enum CALLBACK_MODES {
	AUTO,
	IDLE, ## Layers will run on process frames.
	PHYSICS, ## Layers will run on physics frames.
	MANUAL ## Layers will run when manually requested to run. See [method NodeCameraHost.manual_tick]
}
#endregion


#region External Variables
@export var callback_mode : CALLBACK_MODES = CALLBACK_MODES.PHYSICS:
	set = set_callback_mode,
	get = get_callback_mode
@export var camera_mask : int = 1:
	set = set_camera_mask,
	get = get_camera_mask

@export var disabled : bool:
	set = set_disabled,
	get = get_disabled

@export_group("Camera Status")
@export var target_status : NodeCameraState:
	get = get_target_status,
	set = set_target_status
@export var current_status : NodeCameraState:
	get = get_current_status,
	set = set_current_status
#endregion


#region Private Variables
var _camera : Node

var _scope : NodeCameraHostExecutionScope = NodeCameraHostExecutionScope.new(
	self, NodeCameraManager.get_layer_storage(),
	target_status, current_status
)
#endregion



#region Virtual Methods (Engine)
func _notification(what: int) -> void:
	match what:
		NOTIFICATION_ENTER_TREE:
			_camera = get_parent()
			if !(_camera is Camera2D || _camera is Camera3D):
				_camera = null
				return
			
			if !disabled:
				_scope.overwrite_status()
				NodeCameraManager.register_host(self)
		NOTIFICATION_EXIT_TREE:
			NodeCameraManager.unregister_host(self)
		NOTIFICATION_PREDELETE:
			_scope.free()
#endregion



#region Public Methods (Helper)
func teleport_position() -> void:
	_scope.teleport_overwrite()
func process_tick() -> void:
	NodeCameraManager.tick_host_scope(_scope)

func get_scope() -> NodeCameraHostExecutionScope:
	return _scope
func get_camera() -> Node:
	return _camera
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
	disabled = val
	
	if !disabled && _camera:
		NodeCameraManager.register_host(self)
		_scope.overwrite_status()
		return
	NodeCameraManager.unregister_host(self)
func get_disabled() -> bool:
	return disabled

func set_target_status(val : NodeCameraState) -> void:
	target_status = val
	if val:
		val.overwrite_status(_camera)
	
	_scope.set_target_state(val)
func get_target_status() -> NodeCameraState:
	return target_status

func set_current_status(val : NodeCameraState) -> void:
	current_status = val
	if val:
		val.overwrite_status(_camera)
	
	_scope.set_current_state(val)
func get_current_status() -> NodeCameraState:
	return current_status
#endregion

# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
