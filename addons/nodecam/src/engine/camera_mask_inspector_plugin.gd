@tool
class_name NodeCameraInspectorPlugin extends EditorInspectorPlugin

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
