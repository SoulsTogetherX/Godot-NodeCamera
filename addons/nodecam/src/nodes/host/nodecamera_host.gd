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
			
			if !disabled:
				_scope.overwrite_status()
				NodeCameraManager.register_host(self)
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
		return
	_scope.settup_camera_states()
func get_camera() -> Node:
	return _camera
#endregion


#region Public Helper Methods
func teleport_position() -> void:
	_scope.teleport_overwrite()
func process_tick() -> void:
	NodeCameraManager.tick_host_scope(_scope)

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
	disabled = val
	
	if !disabled && _camera:
		NodeCameraManager.register_host(self)
		_scope.overwrite_status()
		return
	NodeCameraManager.unregister_host(self)
func get_disabled() -> bool:
	return disabled
#endregion

# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
