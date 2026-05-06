# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
@tool
@icon("uid://cax3r21pd3net")
class_name NodeCameraSelector extends NodeCameraMulti

#region Signal
signal selection_changed
#endregion


#region External Variables
@export var selection : int:
	get = get_selection,
	set = set_selection
#endregion



#region Selection Methods

#endregion


#region Virtual Methods (Register)
func register_layer(layer : NodeCameraLayer) -> void:
	super(layer)
	selection = selection
func unregister_layer(layer : NodeCameraLayer) -> void:
	super(layer)
	selection = selection
#endregion


#region Accessor Methods
func set_selection(val : int) -> void:
	val = clampi(val, 0, _layer_storage.size() - 1)
	if val == selection:
		return
	
	selection = val
	selection_changed.emit()
func get_selection() -> int:
	return selection
#endregion


#region Tick Methods
func _get_tick_mask(param_scope : NodeCameraExecutionScope) -> int:
	return TICK_TYPE.NONE
#endregion

# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
