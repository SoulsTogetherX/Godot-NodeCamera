# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
class_name MultiLayerRecord extends LayerRecord

#region Public Variables
var scope : NodeCamera2DExecutionScope
#endregion



#region Virtual Methods
func _notification(what: int) -> void:
	match what:
		NOTIFICATION_PREDELETE:
			scope.free()
#endregion

# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
