extends Area2D

#region Signals
signal entered_interacted
signal exited_interacted

signal interacted
#endregion

#region External Variables
@export var force_stop_player : bool = false
#endregion



#region Virtual Methods
func _ready() -> void:
	collision_mask = 2
	collision_layer = 0
	
	body_entered.connect(_player_entered)
	body_exited.connect(_player_exited)
	
	var parent := get_parent()
	if parent.has_method("interact"):
		interacted.connect(parent.interact)
	if parent.has_method("entered_interaction"):
		entered_interacted.connect(parent.entered_interaction)
	if parent.has_method("exited_interaction"):
		exited_interacted.connect(parent.exited_interaction)
#endregion


#region Private Methods
func _player_entered(player : Node2D) -> void:
	player.add_to_interactables(self)
	entered_interacted.emit()
func _player_exited(player : Node2D) -> void:
	player.remove_from_interactables(self)
	exited_interacted.emit()
#endregion


#region Interaction Methods
func on_interact() -> void:
	interacted.emit()
#endregion
