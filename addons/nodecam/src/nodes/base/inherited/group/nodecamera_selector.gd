# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
@tool
@icon("res://addons/nodecam/assets/icons/NodeCameraSelector.svg")
class_name NodeCameraSelector extends NodeCameraGroup
## A [NodeCameraGroup] class with only a single active layer, switching
## via the [member selection] index. Switching active layers advances the
## previous's status to [enum NodeCameraExecutionScope.LAYER_STAGES].ENDING,
## if possible to advance to.

#region External Variables
## The current selection index.
@export var selection : int:
	set = set_selection,
	get = get_selection
#endregion


#region Private Variables
var _current_layer : NodeCameraLayer
var _layers : Array[NodeCameraLayer]
#endregion



#region Virtual Methods
func _ready() -> void:
	child_order_changed.connect(_initalize_selection_variables)
	_initalize_selection_variables()
#endregion


#region Private Scope Methods
func _get_allowed_layers(_scope : NodeCameraExecutionScope) -> Array[NodeCameraLayer]:
	var ret : Array[NodeCameraLayer]
	if _current_layer:
		ret = [_current_layer]
	return ret
func _allow_auto_add() -> bool:
	return false
#endregion


#region Private Scope Methods
func _initalize_selection_variables() -> void:
	_update_layer()
	_update_selected_layer()


func _is_layer(l : Node) -> bool:
	return l is NodeCameraLayer
func _update_layer() -> void:
	_layers = get_children().filter(_is_layer)
func _update_selected_layer() -> void:
	if selection < 0 || selection >= _layers.size():
		_flag_selection_changed(_current_layer, null)
		_current_layer = null
		return
	
	var old_selection := _current_layer
	_current_layer = _layers[selection]
	_flag_selection_changed(old_selection, _current_layer)


func _flag_selection_changed(old : NodeCameraLayer, new : NodeCameraLayer) -> void:
	if old == new:
		return
	for scope : NodeCameraExecutionScope in get_active_scopes():
		var record := scope.get_record(self)
		if !record:
			scope.flag_add_layer(self)
			continue
		
		var old_record := record.scope.get_record(old)
		if old_record && old_record.stage > LAYER_STAGES.ENDING:
			record.scope.flag_overwrite_stage(old, LAYER_STAGES.ENDING)
		record.scope.flag_overwrite_stage(new, LAYER_STAGES.STARTING)
#endregion


#region Accessor Methods
func set_selection(val : int) -> void:
	if val == selection:
		return
	selection = val
	_update_selected_layer()
func get_selection() -> int:
	return selection

## Returns the currently selected layer.
func get_selected_layer() -> NodeCameraLayer:
	return _current_layer
#endregion

# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
