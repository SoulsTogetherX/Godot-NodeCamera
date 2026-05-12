# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
class_name GroupLayerRecord extends LayerRecord
## The [LayerRecord] class extension for [NodeCameraGroup] nodes.

#region Public Variables
## The [member LayerRecord.layer]'s parent scope.
var parent_scope : NodeCameraExecutionScope
#endregion



#region Virtual Methods
func _notification(what: int) -> void:
	match what:
		NOTIFICATION_PREDELETE:
			scope.free()
#endregion

# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
