extends CharacterBody2D

#region Constants
const KEY_STRINGNAME: StringName = &"Key"
const ACTION_STRINGNAME: StringName = &"Action"

const INPUT_MOVE_LEFT_STRINGNAME: StringName = &"move_left"
const INPUT_MOVE_RIGHT_STRINGNAME: StringName = &"move_right"
const INPUT_JUMP_STRINGNAME: StringName = &"jump"
const INPUT_INTERACT_STRINGNAME: StringName = &"interact"

const SPEED := 300.0
const JUMP_VELOCITY := -400.0
#endregion


#region Constant Input Definitions
const INPUT_MOVEMENT_DIC: Dictionary[StringName, Array] = {
	INPUT_MOVE_LEFT_STRINGNAME: [KEY_A, KEY_LEFT],
	INPUT_MOVE_RIGHT_STRINGNAME: [KEY_D, KEY_RIGHT],
	INPUT_JUMP_STRINGNAME: [KEY_W, KEY_UP],
	INPUT_INTERACT_STRINGNAME: [KEY_Z, KEY_SPACE],
}
#endregion


#region Private Variables
var _interacting : bool = false

var _interactables : Array[Node]
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
	# If you came here for good player interaction code, you
	# are in the wrong place.
	if !_interactables.is_empty() && event.is_action_pressed("interact"):
		_interactables[0].on_interact()
		if _interactables[0].force_stop_player:
			set_physics_process(_interacting)
			_interacting = !_interacting
func _physics_process(delta: float) -> void:
	if !is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("jump") && is_on_floor():
		velocity.y = JUMP_VELOCITY

	var direction := Input.get_axis("move_left", "move_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
#endregion


#region Interact Methods
func add_to_interactables(node : Node) -> void:
	_interactables.append(node)
func remove_from_interactables(node : Node) -> void:
	_interactables.erase(node)
#endregion
