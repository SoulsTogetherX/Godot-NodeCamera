extends Area2D

#region External Variables
@export var selector : NodeCameraSelector
@export var index : int
#endregion

#region Static Variables
static var _indexes : Array[int]
#endregion



#region Virtual Methods
func _ready() -> void:
	collision_layer = 0
	collision_mask = 2
	body_entered.connect(_player_entered)
#endregion


#region Private Methods
func _player_entered(_player : Node2D) -> void:
	_indexes.append(index)
	_on_room_update()
func _player_exited(_player : Node2D) -> void:
	_indexes.erase(index)
	_on_room_update()

func _on_room_update() -> void:
	selector.selection = _indexes.back()
#endregion
