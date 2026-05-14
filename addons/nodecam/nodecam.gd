# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
@tool
extends EditorPlugin

#region Constants
const NODE_CAMERA_AUTOLOAD_NAME := "NodeCameraManager"
const NODE_CAMERA_AUTOLOAD_PATH := "res://addons/nodecam/src/global/nodecamera_manager.gd"

const SRC_DIR = "res://addons/nodecam/src/"

const LAYER_NAMES_SETTING_BASE = "addons/nodecam/layer_names"
#endregion


#region Private Variables
var _interface_plugin : NodeCameraInspectorPlugin
var _export_plugin : NodeCameraExportPlugin
#endregion



#region Virtual Methods (Plugin)
func _enable_plugin() -> void:
	# Camera Mask Layers
	_initalize_camera_mask_settings()
	
	# Manager Autoload
	add_autoload_singleton(
		NODE_CAMERA_AUTOLOAD_NAME, NODE_CAMERA_AUTOLOAD_PATH
	)
func _disable_plugin() -> void:
	# Camera Mask Layers
	_clear_camera_mask_settings()
	
	# Manager Autoload
	remove_autoload_singleton(NODE_CAMERA_AUTOLOAD_NAME)
#endregion


#region Virtual Methods (Type Creation)
func _enter_tree():
	# Camera Mask Layers
	_initalize_camera_mask_settings()
	
	# Interface Plugin
	_interface_plugin = NodeCameraInspectorPlugin.new()
	add_inspector_plugin(_interface_plugin)
	
	# Export Plugin
	_export_plugin = NodeCameraExportPlugin.new()
	add_export_plugin(_export_plugin)
	
	# Node Scripts
	var scripts := _get_all_files(SRC_DIR)
	for script_path : String in scripts:
		var script := load(script_path)
		var script_name : StringName = script.get_global_name()
		if script.get_global_name() == &"":
			continue
		
		var base_type : StringName = script.get_instance_base_type()
		add_custom_type(
			script_name, base_type, script, null
		)

func _exit_tree():
	# Interface Plugin
	if _interface_plugin:
		remove_inspector_plugin(_interface_plugin)
		_interface_plugin = null
	
	# Export Plugin
	if _export_plugin:
		remove_export_plugin(_export_plugin)
		_export_plugin = null
	
	# Node Scripts
	var scripts := _get_all_files(SRC_DIR)
	for script_path : String in scripts:
		var script_name := script_path.get_file().get_basename()
		remove_custom_type(script_name)
#endregion


#region Private Methods
func _get_all_files(path: String) -> PackedStringArray:
	var files := PackedStringArray()
	var dir := DirAccess.open(path)
	
	if dir:
		dir.list_dir_begin()
		var file_name := dir.get_next()
		
		while file_name != "":
			if dir.current_is_dir():
				files.append_array(_get_all_files(path + file_name + "/"))
			elif file_name.ends_with(".gd"):
				files.append(path + file_name)
			file_name = dir.get_next()
		
		dir.list_dir_end()
	return files


func _initalize_camera_mask_settings() -> void:
	for i in range(32):
		var key := "%s/layer_%d" % [LAYER_NAMES_SETTING_BASE, i + 1]
		var default_name := "Layer %d" % (i + 1)
		
		if !ProjectSettings.has_setting(key):
			ProjectSettings.set_setting(key, default_name)
		
		ProjectSettings.set_initial_value(key, default_name)
		ProjectSettings.add_property_info({
			"name": key, "type": TYPE_STRING,
		})
func _clear_camera_mask_settings() -> void:
	for i in range(32):
		var key := "%s/layer_%d" % [LAYER_NAMES_SETTING_BASE, i + 1]
		ProjectSettings.set_setting(key, null)
#endregion

# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
