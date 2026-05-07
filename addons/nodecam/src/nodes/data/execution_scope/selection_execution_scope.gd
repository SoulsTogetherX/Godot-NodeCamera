# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
@tool
class_name NodeCameraSelectionExecutionScope extends NodeCameraExecutionScope


#region Private Variables
var _selected_layer : NodeCameraLayer
#endregion



#region Initialize Methods
func _get_selected_layer() -> NodeCameraLayer:
	var layer : NodeCameraSelector = _container_record.layer
	
	var selection_idx := layer.selection
	if 0 <= selection_idx && selection_idx < _layer_storage.size():
		return _layer_storage.get_registered_at(selection_idx)
	return null
#endregion

func flag_selection_change() -> void:
	var end_record := get_record(_selected_layer)
	if end_record:
		flag_advance_to_stage(_selected_layer, LAYER_STAGES.ENDING)
	
	_selected_layer = _get_selected_layer()
	if _selected_layer:
		flag_overwrite_stage(_selected_layer, LAYER_STAGES.STARTING)


#region Dirty Operations Methods
func _construct_scope(
	scope_layers : Array[NodeCameraLayer], init_stage : LAYER_STAGES
) -> void:
	_selected_layer = _get_selected_layer()
	_clear_scope()
	
	var mask := _host_scope.get_mask()
	for layer : NodeCameraLayer in _sort_priority_order(scope_layers):
		if !(layer.camera_mask & mask) || layer != _selected_layer:
			continue
		_add_layer(layer, init_stage)
#endregion

# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
