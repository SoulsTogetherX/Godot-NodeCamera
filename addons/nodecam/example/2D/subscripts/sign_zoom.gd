extends Sprite2D

#region External Variables
@export var selection : int
@export var selector : NodeCameraSelector

@export var text : String
#endregion


#region OnReady Variables
@onready var _label: Label = $Label
#endregion



#region Virtual Methods
func _ready() -> void:
	_label.text = text
#endregion


#region Interaction Methods
func entered_interaction() -> void:
	_label.visible = true
func exited_interaction() -> void:
	_label.visible = false

func interact() -> void:
	if !selector:
		return
	if selector.selection == selection:
		selector.selection = 0
		%SignTexture.visible = false
		_label.visible = true
		return
	selector.selection = selection
	%SignTexture.visible = true
	_label.visible = false
#endregion
