# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
@tool
class_name NodeCameraMultiplexerExecutionScope extends NodeCameraExecutionScope

#region External Variables
var _selection : NodeCameraLayer
#endregion



#region Virtual Methods
func _init(
	host_scope : NodeCameraHostExecutionScope, parent_record : MultiLayerRecord,
	layer_storage : NodeCameraLayerStorage, layer : NodeCameraMultiplexer,
	start_selection : int
) -> void:
	_host_scope = host_scope
	_parent_record = parent_record
	_settup_layer_storage(layer_storage)
	
	layer.selection_changed.connect(
		_flag_global_selection
	)
	
	var layers := layer_storage.get_registered_layers()
	if 0 <= start_selection && start_selection < layers.size():
		_selection = layers[start_selection]
		return
	_selection = null
#endregion


#region Dirty Flagging Methods
func _flag_global_selection() -> void:
	flag_update_selection(
		(_parent_record.layer as NodeCameraMultiplexer).selection
	)
func flag_update_selection(idx : int) -> void:
	var end_record = _record_by_layer.get(_selection, null)
	if end_record && end_record.stage > LAYER_STAGES.ENDING:
		_flag_stage_overwrite(_selection, LAYER_STAGES.ENDING)
	
	var layers := _layer_storage.get_registered_layers()
	if idx < 0 || idx >= layers.size():
		_selection = null
		return
	
	var sel := layers[idx]
	_flag_stage_overwrite(sel, LAYER_STAGES.STARTING)
	_selection = sel
#endregion


#region Helper Methods
func _construct_record(layer : NodeCameraLayer) -> LayerRecord:
	if layer is NodeCameraStaged:
		return _construct_staged_record(layer, 
			LAYER_STAGES.STARTING if layer == _selection else LAYER_STAGES.HAULTED
		)
	if layer is NodeCameraMulti:
		return _construct_multi_record(layer)
	return null
#endregion


#region Accessor Methods
func get_selection() -> NodeCameraLayer:
	return _selection
#endregion

# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
