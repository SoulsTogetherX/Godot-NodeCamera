# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
@tool
@icon("uid://cax3r21pd3net")
class_name NodeCameraSelector extends NodeCameraGroup

#region Signal
signal selection_changed
#endregion


#region External Variables
@export var selection : int:
	get = get_selection,
	set = set_selection
#endregion


#region Private Variables
var _current_selection : NodeCameraLayer

var _connected_scopes : Array[NodeCameraExecutionScope]
#endregion



#region Grouping Methods
func _on_remove(param_scope : NodeCameraExecutionScope) -> void:
	_connected_scopes.erase(param_scope)
	if selection_changed.is_connected(test) && _connected_scopes.is_empty():
		selection_changed.disconnect(test)
func _on_add(param_scope : NodeCameraExecutionScope) -> void:
	if !_connected_scopes.has(param_scope):
		_connected_scopes.append(param_scope)
	if !selection_changed.is_connected(test):
		selection_changed.connect(test)
#endregion


func test() -> void:
	var sel_layer := _layer_storage.get_registered_at(selection)
	
	for scope : NodeCameraExecutionScope in _connected_scopes:
		scope.flag_advance_to_stage(_current_selection, LAYER_STAGES.ENDING)
		scope.flag_overwrite_stage(sel_layer, LAYER_STAGES.STARTING)
	
	_current_selection = sel_layer

#region Virtual Methods (Register)
func register_layer(layer : NodeCameraLayer) -> void:
	super(layer)
	selection = selection
	_current_selection = _layer_storage.get_registered_at(selection)
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

# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
