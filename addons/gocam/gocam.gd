@tool
extends EditorPlugin


#region Constants
const GO_CAMERA_AUTOLOAD_NAME := "GoCamera2DManager"
const GO_CAMERA_AUTOLOAD_PATH := "res://addons/gocam/src/autoloads/gocamera2d_manager.gd"
#endregion



#region Virtual Methods (Plugin)
func _enable_plugin() -> void:
	add_autoload_singleton(
		GO_CAMERA_AUTOLOAD_NAME, GO_CAMERA_AUTOLOAD_PATH
	)
	EditorInterface.restart_editor()
func _disable_plugin() -> void:
	remove_autoload_singleton(GO_CAMERA_AUTOLOAD_NAME)
#endregion


#region Virtual Methods (Type Creation)
func _enter_tree() -> void:
	# Initialization of the plugin goes here.
	pass
func _exit_tree() -> void:
	# Clean-up of the plugin goes here.
	pass
#endregion
