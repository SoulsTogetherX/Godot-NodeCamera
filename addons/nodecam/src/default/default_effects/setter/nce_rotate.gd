# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
@tool
class_name NodeCamera2DRotateEffect extends NodeCamera2DEffect
## A basic effect that rotates the target camera status, by a certain amount,
## once when activated.

#endregion Enums
enum MATH_METHOD {
	REPLACE,
	ADD,
	MUL
}
#endregion


#endregion External Variables
@export var rotation : float = 0.0
@export var method : MATH_METHOD = MATH_METHOD.REPLACE

@export_group("Limit")
@export var limit_min : float = 0.0
@export var limit_max : float = TAU
#endregion



#endregion Virtual Methods
func _start_effect(target : GoCameraStateResource) -> void:
	match method:
		MATH_METHOD.ADD:
			rotation += target.rotation
		MATH_METHOD.MUL:
			rotation *= target.rotation
	
	target.rotation = fposmod(
		rotation - limit_min, limit_max - limit_min
	) + limit_min
#endregion

# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
