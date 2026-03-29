class_name GoCamera2DHost extends Node


#region Private Variables
var _camera : Camera2D = null

var _target_state := CameraStateResource.new()
#endregion



#region Virtual Methods
func _notification(what: int) -> void:
	match what:
		NOTIFICATION_ENTER_TREE:
			GoCamera2DManager.register_host(self)
			_set_camera()
		NOTIFICATION_EXIT_TREE:
			GoCamera2DManager.unregister_host(self)
			_camera = null
#endregion


#region Private Methods
func _set_camera() -> void:
	var parent := get_parent()
	if parent is Camera2D:
		_camera = parent
		return
	_camera = null
#endregion


#region Public Methods (Accesser)
func get_camera() -> Camera2D:
	return _camera
func get_target_camera_state() -> CameraStateResource:
	return _target_state
#endregion
