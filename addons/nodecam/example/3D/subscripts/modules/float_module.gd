extends Node

#region External Varables
@export var float_distance : float = 5.0
#endregion


#region Private Varables
var _tween : Tween
#endregion



#region Virtual Methods
func _ready() -> void:
	var parent := get_parent()
	if !(parent is Node2D) && !(parent is Node3D) && !(parent is Control):
		return
	
	_tween = create_tween()
	_tween.set_trans(Tween.TRANS_SINE)
	_tween.set_ease(Tween.EASE_IN_OUT)
	
	_tween.set_loops(-1)
	
	parent.position.y -= float_distance
	_tween.tween_property(
		parent, "position:y", parent.position.y + (2 * float_distance),
		2
	)
	_tween.tween_property(
		parent, "position:y", parent.position.y, 2
	)
#endregion
