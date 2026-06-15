extends Node

#region External Variables
@export var effect_rotation : NodeCameraEffectRotate
#endregion



#region Signal Methods
func set_rotation(_body : Node3D) -> void:
	effect_rotation.rotation_3D = Vector3(0.0, -90, 0.0)
#endregion
