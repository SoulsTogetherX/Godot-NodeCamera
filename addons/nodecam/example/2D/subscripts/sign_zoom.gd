extends Sprite2D

#region External Variables
@export var selection : int
@export var selector : NodeCameraSelector
#endregion


#region OnReady Variables
@onready var _label: Label = $Label
#endregion



#region Interaction Methods
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

func entered_interaction() -> void:
	_label.visible = true
func exited_interaction() -> void:
	_label.visible = false
#endregion
