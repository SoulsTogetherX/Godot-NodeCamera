extends Node2D


#region External Variables
@export var player1 : CharacterBody2D
@export var player2 : CharacterBody2D
@export var player_selector: NodeCameraSelector

@export var boundary: NodeCamera2DBoundaryEffect
@export var shake: NodeCameraEffectShake
#endregion


#region Private Variables
var _current_player : bool = false
var _uses_bounary : bool = true
var _uses_shake : bool = false
#endregion



#region Virtual Methods
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("PlayerSelect"):
		_current_player = !_current_player
		player_selector.selection = int(_current_player)
		
		if _current_player:
			player1.process_mode = Node.PROCESS_MODE_DISABLED
			player2.process_mode = Node.PROCESS_MODE_INHERIT
		else:
			player1.process_mode = Node.PROCESS_MODE_INHERIT
			player2.process_mode = Node.PROCESS_MODE_DISABLED
	elif event.is_action_pressed("Boundaries"):
		_uses_bounary = !_uses_bounary
		boundary.notify_overwrite_stage(
			NodeCameraStaged.LAYER_STAGES.STARTING if _uses_bounary
			else NodeCameraStaged.LAYER_STAGES.HAULTED
		)
	elif event.is_action_pressed("Shake"):
		_uses_shake = !_uses_shake
		shake.notify_overwrite_stage(
			NodeCameraStaged.LAYER_STAGES.STARTING if _uses_shake
			else NodeCameraStaged.LAYER_STAGES.HAULTED
		)
#endregion
