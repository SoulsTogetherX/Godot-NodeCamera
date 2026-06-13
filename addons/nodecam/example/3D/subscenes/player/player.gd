extends CharacterBody3D


#region Constants
const KEY_STRINGNAME: StringName = &"Key"
const ACTION_STRINGNAME: StringName = &"Action"

const INPUT_MOVE_LEFT_STRINGNAME: StringName = &"move_left"
const INPUT_MOVE_RIGHT_STRINGNAME: StringName = &"move_right"
const INPUT_MOVE_FORWARD_STRINGNAME: StringName = &"move_forward"
const INPUT_MOVE_BACKWARD_STRINGNAME: StringName = &"move_back"
const INPUT_INTERACT_STRINGNAME: StringName = &"interact"

const SPEED := 150.0
#endregion


#region Constant Input Definitions
const INPUT_MOVEMENT_DIC: Dictionary[StringName, Array] = {
	INPUT_MOVE_LEFT_STRINGNAME: [KEY_A, KEY_LEFT],
	INPUT_MOVE_RIGHT_STRINGNAME: [KEY_D, KEY_RIGHT],
	INPUT_MOVE_FORWARD_STRINGNAME: [KEY_W, KEY_UP],
	INPUT_MOVE_BACKWARD_STRINGNAME: [KEY_S, KEY_DOWN],
	INPUT_INTERACT_STRINGNAME: [KEY_Z, KEY_SPACE],
}
#endregion


#region External Variables
@export_group("Camera")
@export var cam : Camera3D
@export var effect_rotation : NodeCameraEffectRotate
@export var spring_rotation : SpringArm3D

@export_group("Camera Settings")
@export var mouse_sensitivity : float = 0.02

@export_range(-90.0, 0.0, 0.1, "radians_as_degrees")
var min_vertical_angle : float = -PI / 2

@export_range(0.0, 90.0, 0.1, "radians_as_degrees")
var max_vertical_angle : float = PI / 4
#endregion



#region Virtual Methods
func _ready() -> void:
	# Needs to dynmanically set inputs, since mapping inputs --
	# in engine -- don't translate for addons.
	for key : StringName in INPUT_MOVEMENT_DIC:
		InputMap.add_action(key)
		var movements : Array = INPUT_MOVEMENT_DIC[key]
		
		for k : int in movements:
			var movement_input = InputEventKey.new()
			movement_input.physical_keycode = k
			InputMap.action_add_event(key, movement_input)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if effect_rotation:
			var rot := effect_rotation.rotation_3D
			
			rot.y -= event.relative.x * mouse_sensitivity
			rot.y = wrapf(rot.y, 0.0, TAU)
			
			rot.x -= event.relative.y * mouse_sensitivity
			rot.x = clampf(rot.x, min_vertical_angle, max_vertical_angle)
			
			effect_rotation.rotation_3D = rot
		if spring_rotation:
			var rot := spring_rotation.global_rotation
			
			rot.y -= event.relative.x * mouse_sensitivity
			rot.y = wrapf(rot.y, 0.0, TAU)
			
			rot.x -= event.relative.y * mouse_sensitivity
			rot.x = clampf(rot.x, min_vertical_angle, max_vertical_angle)
			
			spring_rotation.global_rotation = rot
	

func _physics_process(delta: float) -> void:
	var input_dir := Input.get_vector(
		INPUT_MOVE_LEFT_STRINGNAME,
		INPUT_MOVE_RIGHT_STRINGNAME,
		INPUT_MOVE_FORWARD_STRINGNAME,
		INPUT_MOVE_BACKWARD_STRINGNAME,
	)
	var direction := Vector3(input_dir.x, 0, input_dir.y).normalized()
	if cam:
		direction = direction.rotated(Vector3.UP, cam.global_rotation.y)
	
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
#endregion
