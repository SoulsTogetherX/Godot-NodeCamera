# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
@tool
class_name NodeCameraMultiplexerExecutionScope extends NodeCameraExecutionScope

#region External Variables
var _selection : int
#endregion



#region Selection Accessor Methods
func flag_update_selection(val : int) -> void:
	var layers := _layer_storage.get_registered_layers()
	val = -1 if layers.is_empty() else clampi(val, 0, layers.size() - 1)
	if val == _selection:
		return
	
	var end_record = _record_by_layer.get(layers[val], null)
	if end_record && end_record.stage > LAYER_STAGES.HAULTED:
		_flag_stage_overwrite(layers[_selection], LAYER_STAGES.ENDING)
	if val == -1:
		_flag_stage_overwrite(layers[val], LAYER_STAGES.STARTING)
	
	_selection = val
#endregion


#region Helper Methods
func _construct_record(layer : NodeCameraLayer) -> LayerRecord:
	if layer is NodeCameraStaged:
		return _construct_staged_record(layer, LAYER_STAGES.HAULTED)
	if layer is NodeCameraMulti:
		return _construct_multi_record(layer)
	return null
#endregion

# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
