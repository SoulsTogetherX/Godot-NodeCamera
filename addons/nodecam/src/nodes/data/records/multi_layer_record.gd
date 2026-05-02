class_name MultiLayerRecord extends LayerRecord

var layer : NodeCamera2DMulti
var scope : NodeCamera2DExecutionScope


func _notification(what: int) -> void:
	match what:
		NOTIFICATION_PREDELETE:
			scope.free()
