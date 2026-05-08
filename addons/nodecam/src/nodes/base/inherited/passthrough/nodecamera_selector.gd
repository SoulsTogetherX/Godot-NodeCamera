# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
@tool
@icon("res://addons/nodecam/assets/icons/NodeCameraSelector.svg")
class_name NodeCameraSelector extends NodeCameraPassthrough

#region External Variables
@export var selection : int:
	set = set_selection,
	get = get_selection
#endregion


#region Private Variables
var _current_layer : NodeCameraLayer
#endregion



#region Virtual Methods
func _ready() -> void:
	child_order_changed.connect(_update_selected_layer)
	_update_selected_layer()
#endregion


#region Private Scope Methods
func _get_active_layers() -> Array[NodeCameraLayer]:
	var ret : Array[NodeCameraLayer]
	if _current_layer:
		ret = [_current_layer]
	return ret
#endregion


#region Public Scope Methods
func _is_layer(l : Node) -> bool:
	return l is NodeCameraLayer
func _update_selected_layer() -> void:
	var layers : Array[Node] = get_children().filter(_is_layer)
	
	if selection < 0 || selection >= layers.size():
		for scope : NodeCameraExecutionScope in get_active_scopes():
			scope.flag_construct_scope()
		_current_layer = null
		return
	
	var old_selection := _current_layer
	_current_layer = layers[selection]
	for scope : NodeCameraExecutionScope in get_active_scopes():
		scope.flag_construct_scope()
#endregion


#region Accessor Methods
func set_selection(val : int) -> void:
	if val == selection:
		return
	selection = val
	_update_selected_layer()
func get_selection() -> int:
	return selection
#endregion

# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
