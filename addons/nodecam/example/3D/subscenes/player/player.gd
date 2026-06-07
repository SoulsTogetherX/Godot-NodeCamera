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

func _physics_process(delta: float) -> void:
	var input_dir := Input.get_vector(
		INPUT_MOVE_LEFT_STRINGNAME,
		INPUT_MOVE_RIGHT_STRINGNAME,
		INPUT_MOVE_FORWARD_STRINGNAME,
		INPUT_MOVE_BACKWARD_STRINGNAME,
	)
	var direction := Vector3(input_dir.x, 0, input_dir.y).normalized()
	
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
#endregion
