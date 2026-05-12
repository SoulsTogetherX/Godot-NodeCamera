# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
@tool
@icon("res://addons/nodecam/assets/icons/NodeCameraSelector.svg")
class_name NodeCameraSelector extends NodeCameraRoutable
## A [NodeCameraRoutable] that only activates one layer at a time.

#region External Variables
## The index for the layer to be selected.
@export_custom(PROPERTY_HINT_NONE, "", PROPERTY_USAGE_EDITOR)
var selection : int:
	set = set_selection,
	get = get_selection
#endregion


#region Private Variables
var _valid_layers : Array[NodeCameraLayer]

var _selected_layer : NodeCameraLayer
@export_storage var _selection_idx : int
#endregion



#region Virtual Methods
func _ready() -> void:
	child_order_changed.connect(_settup_bundle)
	_settup_vaild_layers()
	_settup_selected_layer()
#endregion


#region Routing Methods
func _route_to_layers() -> Array[NodeCameraLayer]:
	if _selected_layer:
		return [_selected_layer]
	return []
#endregion


#region Selection Methods
func _is_node_cam_layer(node : Node) -> bool:
	return node is NodeCameraLayer

func _settup_bundle() -> void:
	var old_selection : NodeCameraLayer = _selected_layer
	_settup_vaild_layers()
	_settup_selected_layer()
	if old_selection != _selected_layer:
		flag_route_layers_changed()
func _settup_vaild_layers() -> void:
	_valid_layers.assign(get_children().filter(_is_node_cam_layer))
	_selection_idx = mini(_selection_idx, _valid_layers.size() - 1)
func _settup_selected_layer() -> void:
	if _selection_idx < 0:
		_selected_layer = null
		return
	_selected_layer = _valid_layers[_selection_idx]
#endregion


#region Acessing Methods
func set_selection(val : int) -> void:
	val = clampi(val, 0, _valid_layers.size() - 1)
	if val == _selection_idx:
		return
	_selection_idx = val
	
	if is_node_ready():
		_settup_selected_layer()
		flag_route_layers_changed()
func get_selection() -> int:
	return _selection_idx

## Returns the currenly selected layer.
func get_selected_layer() -> NodeCameraLayer:
	return _selected_layer
#endregion

# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
