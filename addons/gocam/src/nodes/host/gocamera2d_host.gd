@tool
class_name GoCamera2DHost extends Node


#region Constants
const CONSTANTS := preload("uid://b8t21yw0evfx")
#endregion


#region External Variables
@export var callback : CONSTANTS.CALLBACK_MODES = CONSTANTS.CALLBACK_MODES.PHYSICS:
	set = set_callback,
	get = get_callback
@export var camera_flag_mask : int = 1
#endregion


#region Private Variables
var _camera : Camera2D

var _target_status := GoCameraStateResource.new()
var _current_status := GoCameraStateResource.new()
#endregion



#region Virtual Methods
func _init() -> void:
	_settup_private_signals()
func _notification(what: int) -> void:
	match what:
		NOTIFICATION_READY, NOTIFICATION_POST_ENTER_TREE:
			_settup_camera()
		NOTIFICATION_EXIT_TREE:
			_clear_camera()
#endregion


#region Private Methods
func _settup_private_signals() -> void:
	if !has_signal(CONSTANTS.INTERAL_CALLBACK_CHANGED):
		add_user_signal(
			CONSTANTS.INTERAL_CALLBACK_CHANGED,
			[{"name": "effect", "type": TYPE_OBJECT},
			{"name": "old", "type": TYPE_INT}]
		)

func _settup_camera() -> void:
	if !is_node_ready():
		return
	
	_camera = (get_parent() as Camera2D)
	if _camera:
		_target_status.overwrite_status(_camera)
		_current_status.overwrite_status(_camera)
		GoCamera2DManager.register_host(self)
		return
func _clear_camera() -> void:
	_camera = null
	GoCamera2DManager.unregister_host(self)
#endregion


#region Public Methods (Accessors)
func get_camera() -> Camera2D:
	return _camera

func set_callback(val : CONSTANTS.CALLBACK_MODES) -> void:
	callback = val
func get_callback() -> CONSTANTS.CALLBACK_MODES:
	return callback

func get_target_status() -> GoCameraStateResource:
	return _target_status
func get_current_status() -> GoCameraStateResource:
	return _current_status
#endregion
