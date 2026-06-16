# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
@tool
class_name NodeCameraInspectorPlugin extends EditorInspectorPlugin
## An [EditorInspectorPlugin] used to implement the node camera bitmask's
## editor visual. Also see [member NodeCameraLayer.camera_mask].

#region Virtual Methods
func _can_handle(object: Object) -> bool:
	return object is NodeCameraLayer || object is NodeCameraHost

func _parse_property(
	object: Object,
	type: Variant.Type,
	name: String,
	hint_type: PropertyHint,
	hint_string: String,
	usage_flags: int,
	wide: bool
) -> bool:
	if name != "camera_mask":
		return false
	if type != TYPE_INT:
		return false

	var editor := NodeCameraMaskProperty.new()
	add_property_editor(name, editor, false, "Camera Mask")
	return true
#endregion

# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
