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
func enforce_local_selection(sel : int) -> void:
	(_scope as NodeCameraSelectorExecutionScope).flag_update_selection(sel)

func get_local_selection_layer(scope : NodeCameraSelectorExecutionScope) -> NodeCameraLayer:
	return scope.get_selection()
func get_global_selection_layer() -> NodeCameraLayer:
	if selection == -1:
		return null
	return _layer_storage.get_registered_layers()[selection]
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
	var sel := (param_scope as NodeCameraSelectorExecutionScope).get_selection()
	
	if !param_scope.has_record(sel):
		return TICK_TYPE.NONE
	return sel._get_tick_mask(param_scope)
#endregion

# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
