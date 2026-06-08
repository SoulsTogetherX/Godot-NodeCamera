extends Node2D

#region External Varables
@export var active : bool = false
@export var layer_controlled : NodeCameraLayer

@export var text : String
#endregion


#region OnReady Varables
@onready var _label: Label = $Label
@onready var _sprite: Sprite2D = $Sprite
#endregion



#region Virtual Methods
func _ready() -> void:
	_label.text = text
	
	_set_active_color()
	_on_interact()
#endregion


#region Interaction Methods
func _on_player_enter(player : Node2D) -> void:
	modulate = Color.RED
	_label.visible = true
func _on_player_exit(player : Node2D) -> void:
	_set_active_color()
	_label.visible = false

func interact() -> void:
	active = !active
	_on_interact()
func _on_interact() -> void:
	if !layer_controlled:
		return
	
	if layer_controlled is NodeCameraSelector:
		layer_controlled.selection = int(active)
		return
	
	if active:
		layer_controlled.notify_overwrite_stage(NodeCameraUtility.LAYER_STAGES.STARTING)
		return
	layer_controlled.notify_overwrite_stage(NodeCameraUtility.LAYER_STAGES.HALTED)

func _set_active_color() -> void:
	modulate = Color.YELLOW if active else Color.WHITE
#endregion
