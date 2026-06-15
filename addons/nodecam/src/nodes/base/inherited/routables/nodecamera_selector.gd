# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
@tool
@icon("res://addons/nodecam/assets/icons/NodeCameraSelector.svg")
class_name NodeCameraSelector extends NodeCameraRoutable
## A [NodeCameraRoutable] that routes to one selected layer, depending on
## [member selection].

#region External Variables
## The index for the layer to be routed to.
@export var selection : int = 0:
	set = set_selection,
	get = get_selection
#endregion


#region Private Variables
var _valid_layers : Array[NodeCameraLayer]

var _selected_layer : NodeCameraLayer
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
	selection = mini(selection, _valid_layers.size() - 1)
	
	_settup_selected_layer()
	if old_selection != _selected_layer:
		flag_route_layers_changed()
func _settup_vaild_layers() -> void:
	_valid_layers.assign(get_children().filter(_is_node_cam_layer))
	
func _settup_selected_layer() -> void:
	if selection < 0:
		_selected_layer = null
		return
	_selected_layer = _valid_layers[selection]
#endregion


#region Acessing Methods
func set_selection(val : int) -> void:
	if !is_node_ready():
		selection = val
		return
	
	val = clamp(val, -1, _valid_layers.size() - 1)
	if val == selection:
		return
	selection = val
	
	_settup_selected_layer()
	flag_route_layers_changed()
func get_selection() -> int:
	return selection

## Returns the layer currently being routed to.
func get_selected_layer() -> NodeCameraLayer:
	return _selected_layer
#endregion

# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
