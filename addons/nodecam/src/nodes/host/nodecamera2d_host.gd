# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
@tool
@icon("uid://kq0ubmkoup4y")
class_name NodeCamera2DHost extends Node
## The main node that controls the camera for the NodeCamera2D addon.


#region Signals
## This signal is emited when [member callback] is changed.
signal callback_changed(old : CONSTANTS.CALLBACK_MODES)
## This signal is emited when [member camera_flag_mask] is changed.
signal camera_mask_changed(old : int)
#endregion


#region Constants
## The script containing all shared constants used by the NodeCamera2D addon.
const CONSTANTS := preload("uid://b8t21yw0evfx")
#endregion


#region External Variables
## If [code]true[/code], this property disabled the processing of this host.
@export var disabled : bool = false:
	set = set_disabled,
	get = get_disabled

@export_group("Camera Settings")
## Controls when this host's camera should be processed.
@export var callback : CONSTANTS.CALLBACK_MODES = CONSTANTS.CALLBACK_MODES.PHYSICS:
	set = set_callback,
	get = get_callback
## A bitmask used to filter out what top-level [NodeCamera2DLayer] should
## affect this host.
@export var camera_flag_mask : int = 1:
	set = set_camera_flag_mask,
	get = get_camera_flag_mask
#endregion


#region Private Variables
var _camera : Camera2D

var _target_status := GoCameraStateResource.new()
var _current_status := GoCameraStateResource.new()
#endregion



#region Virtual Methods
func _notification(what: int) -> void:
	match what:
		NOTIFICATION_READY, NOTIFICATION_POST_ENTER_TREE:
			_settup_camera()
		NOTIFICATION_EXIT_TREE:
			_clear_camera()
#endregion


#region Private Methods
func _settup_camera() -> void:
	if !is_node_ready():
		return
	
	_camera = (get_parent() as Camera2D)
	if _camera:
		_target_status.overwrite_status(_camera)
		_current_status.overwrite_status(_camera)
		
		if !disabled:
			NodeCamera2DManager.register_host(self)
		return
func _clear_camera() -> void:
	_camera = null
	NodeCamera2DManager.unregister_host(self)
#endregion


#region Public Methods (Tick)
## Manually ticks this camera forward one tick.
## [br][br]
## [b]NOTE[/b]: This will tick the camera regardless of [member callback].
func manual_tick() -> void:
	NodeCamera2DManager.tick_host(self)
#endregion


#region Public Methods (Status Access)
## Returns the target camera status this host is transitioning to.
## [br][br]
## [b]NOTE[/b]: If there are no running [NodeCamera2DTransition] nodes,
## then this is treated as the current state.
func get_target_status() -> GoCameraStateResource:
	return _target_status
## Returns the current camera status this host's camera.
## [br][br]
## [b]NOTE[/b]: If there are no running [NodeCamera2DTransition] nodes,
## then this is ignored.
func get_current_status() -> GoCameraStateResource:
	return _current_status
#endregion


#region Public Methods (Status Manipulation)
## 
func teleport_cam() -> void:
	_target_status.apply_status(_camera)
## 
func update_cam() -> void:
	_current_status.apply_status(_camera)

## 
func reset_cam() -> void:
	_target_status.overwrite_status(_camera)
	_current_status.overwrite_status(_camera)
#endregion


#region Public Methods (Accessors)
## Returns the current [Camera2D] this [NodeCamera2DHost] is attached to.
## Returns [code]null[/code] if not a child of any [Camera2D] node.
func get_camera() -> Camera2D:
	return _camera

## Sets the [member callback] value.
func set_callback(val : CONSTANTS.CALLBACK_MODES) -> void:
	if val == callback:
		return
	
	var old := callback
	callback = val
	callback_changed.emit(old)
## Gets the [member callback] value.
func get_callback() -> CONSTANTS.CALLBACK_MODES:
	return callback

## Sets the [member camera_flag_mask] value.
func set_camera_flag_mask(val : int) -> void:
	if val == camera_flag_mask:
		return
	
	var old := camera_flag_mask
	camera_flag_mask = val
	camera_mask_changed.emit(old)
## Sets the [member camera_flag_mask] value.
func get_camera_flag_mask() -> int:
	return camera_flag_mask

## Sets the [member camera_flag_mask] value.
func set_disabled(val : bool) -> void:
	if val == disabled:
		return
	disabled = val
	
	if _camera:
		if disabled:
			NodeCamera2DManager.unregister_host(self)
			return
		NodeCamera2DManager.register_host(self)
## Sets the [member camera_flag_mask] value.
func get_disabled() -> bool:
	return disabled
#endregion

# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
