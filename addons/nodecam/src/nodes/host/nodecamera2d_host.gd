# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
@tool
@icon("uid://kq0ubmkoup4y")
class_name NodeCamera2DHost extends Node
## The main node that controls the camera for the NodeCamera2D addon.

#region Signals
signal activate
signal deactivate

signal callback_mode_changed
signal camera_mask_changed
#endregion


#region Enums
## An enum used to denote at what times layers will run for
## each [NodeCamera2DHost].
enum CALLBACK_MODES {
	AUTO,
	IDLE, ## Layers will run on process frames.
	PHYSICS, ## Layers will run on physics frames.
	MANUAL ## Layers will run when manually requested to run. See [method NodeCamera2DHost.manual_tick]
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
var _camera : Camera2D

var _scope : NodeCamera2DHostExecutionScope = NodeCamera2DHostExecutionScope.new(
	self, NodeCamera2DManager.get_layer_storage()
)
#endregion



#region Virtual Methods (Engine)
func _notification(what: int) -> void:
	match what:
		NOTIFICATION_ENTER_TREE:
			_camera = get_parent() as Camera2D
			
			if !disabled && _camera:
				_scope.overwrite_status()
				NodeCamera2DManager.register_host(self)
		NOTIFICATION_EXIT_TREE:
			NodeCamera2DManager.unregister_host(self)
		NOTIFICATION_PREDELETE:
			_scope.free()
#endregion



#region Public Methods (Helper)
func teleport_position() -> void:
	_scope.teleport_overwrite()
func process_tick() -> void:
	NodeCamera2DManager.tick_host_scope(_scope)

func get_scope() -> NodeCamera2DHostExecutionScope:
	return _scope
func get_camera() -> Camera2D:
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
		NodeCamera2DManager.register_host(self)
		_scope.overwrite_status()
		return
	NodeCamera2DManager.unregister_host(self)
func get_disabled() -> bool:
	return disabled
#endregion

# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
