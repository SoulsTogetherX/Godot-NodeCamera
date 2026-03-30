@tool
class_name GoCamera2DHost extends Node


#region Constants
const CONSTANTS := preload("uid://b8t21yw0evfx")
#endregion


#region External Variables
@export var process_callback := CONSTANTS.PROCESS_CALLBACK.PHYSICS:
	set = set_process_callback,
	get = get_process_callback
#endregion


#region Private Variables
var _camera : Camera2D = null

var _target_state := CameraStateResource.new()
var _current_state := CameraStateResource.new()
#endregion



#region Virtual Methods
func _notification(what: int) -> void:
	match what:
		NOTIFICATION_ENTER_TREE:
			_settup_private_signals()
			
			GoCamera2DManager.register_host(self)
			_set_camera()
		NOTIFICATION_EXIT_TREE:
			GoCamera2DManager.unregister_host(self)
			_camera = null
#endregion


#region Private Methods (Helper)
func _settup_private_signals() -> void:
	if has_signal(CONSTANTS.INTERAL_CALLBACK_CHANGED):
		return
	
	add_user_signal(
		CONSTANTS.INTERAL_CALLBACK_CHANGED,
		[
			{"name": "host", "type": TYPE_OBJECT},
			{"name": "new", "type": TYPE_INT}
		]
	)

func _set_camera() -> void:
	var parent := get_parent()
	if parent is Camera2D:
		_camera = parent
		return
	_camera = null
#endregion


#region Public Methods (External Accesser)
func set_process_callback(val : CONSTANTS.PROCESS_CALLBACK) -> void:
	if val == process_callback:
		return
	var old := process_callback
	process_callback = val
	
	if is_node_ready():
		emit_signal(
			CONSTANTS.INTERAL_CALLBACK_CHANGED,
			self, old
		)

func get_process_callback() -> CONSTANTS.PROCESS_CALLBACK:
	return process_callback
#endregion


#region Public Methods (Manual Tick)
func manual_tick() -> void:
	GoCamera2DManager._tick_host(self)
#endregion


#region Public Methods (Private Accesser)
func get_camera() -> Camera2D:
	return _camera

func get_target_camera_state() -> CameraStateResource:
	return _target_state
func get_current_camera_state() -> CameraStateResource:
	return _current_state
#endregion
