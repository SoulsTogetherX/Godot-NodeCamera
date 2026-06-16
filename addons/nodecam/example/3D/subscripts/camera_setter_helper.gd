extends Node

#region External Variables
@export var effect_rotation : NodeCameraEffectRotate
#endregion



#region Signal Methods
func set_rotation(_body : Node3D) -> void:
	# Don't roast my bad code, okay? This is just an example! D:
	if $"..".selector.selection == $"..".index:
		return
	effect_rotation.rotation_3D = Vector3(0.0, -90, 0.0)
#endregion
