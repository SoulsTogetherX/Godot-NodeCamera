@tool
class_name NodeCameraExportPlugin extends EditorExportPlugin

#region Constants
## The name of this plugin.
const PLUGIN_NAME := "NodeCameraExportPlugin"

## Local path to assets directory.
const ASSETS_DIR := "res://addons/nodecam/assets/"
## Local path to examples directory.
const EXAMPLES_DIR := "res://addons/nodecam/example/"
#endregion



#region Virtual Methods
func _get_name() -> String:
	return PLUGIN_NAME

func _export_file(
	path: String,
	type: String,
	features: PackedStringArray
) -> void:
	if path.begins_with(ASSETS_DIR):
		skip()
	if path.begins_with(EXAMPLES_DIR):
		skip()
#endregion
