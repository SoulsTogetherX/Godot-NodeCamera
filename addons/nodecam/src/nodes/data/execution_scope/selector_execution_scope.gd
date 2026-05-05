# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
@tool
class_name NodeCameraSelectorExecutionScope extends NodeCameraExecutionScope

#region External Variables
var _selection : NodeCameraLayer
#endregion



#region Virtual Methods
func _init(
	host_scope : NodeCameraHostExecutionScope, parent_record : MultiLayerRecord,
	layer_storage : NodeCameraLayerStorage, start_selection : int
) -> void:
	_host_scope = host_scope
	_parent_record = parent_record
	_settup_layer_storage(layer_storage)
	
	var layers := layer_storage.get_registered_layers()
	if 0 <= start_selection && start_selection < layers.size():
		_selection = layers[start_selection]
		return
	_selection = null
#endregion


#region Dirty Operations Methods
func _add_layer(
	layer : NodeCameraLayer, init_stage : LAYER_STAGES = LAYER_STAGES.STARTING
) -> int:
	if layer != _selection:
		return TICK_TYPE.NONE
	return super(layer, init_stage)

func _update_selection(idx : int) -> int:
	var mask := TICK_TYPE.NONE
	
	var end_record = _record_by_layer.get(_selection, null)
	if end_record && end_record.stage > LAYER_STAGES.ENDING:
		mask |= _host_scope.overwrite_stage(end_record, LAYER_STAGES.ENDING)
	
	var layers := _layer_storage.get_registered_layers()
	if idx < 0 || idx >= layers.size():
		_selection = null
		return mask
	
	var sel := layers[idx]
	mask |= _host_scope.overwrite_stage(
		_record_by_layer.get(_selection, null), LAYER_STAGES.STARTING
	)
	_selection = sel
	
	return mask
#endregion


#region Accessor Methods
func get_selection() -> NodeCameraLayer:
	return _selection
#endregion

# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
