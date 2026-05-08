# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
@tool
class_name NodeCameraLayerStorage extends Object

#region Signals
signal layer_added(layer : NodeCameraLayer)
signal layer_removed(layer : NodeCameraLayer)

signal layer_changed_priority(layer : NodeCameraLayer, old_priority : int)
signal layer_changed_mask(layer : NodeCameraLayer, old_mask : int)
#endregion


#region Private Variables
var _layers : Array[NodeCameraLayer]

var _priority_by_layer : Dictionary[NodeCameraLayer, int]
var _masks_by_layer : Dictionary[NodeCameraLayer, int]
#endregion



#region Private Methods (Updating Layers)
func _layer_changed_priority(layer : NodeCameraLayer) -> void:
	layer_changed_priority.emit(
		layer, _priority_by_layer[layer]
	)
	_priority_by_layer[layer] = layer.priority
func _layer_changed_mask(layer : NodeCameraLayer) -> void:
	layer_changed_mask.emit(
		layer, _masks_by_layer[layer]
	)
	_masks_by_layer[layer] = layer.camera_mask
#endregion


#region Public Methods (Register Layer)
func register_layer(layer : NodeCameraLayer) -> void:
	if is_layer_registered(layer):
		return
	
	layer.priority_changed.connect(
		_layer_changed_priority, CONNECT_APPEND_SOURCE_OBJECT
	)
	layer.camera_mask_changed.connect(
		_layer_changed_mask, CONNECT_APPEND_SOURCE_OBJECT
	)
	
	_layers.append(layer)
	
	_masks_by_layer[layer] = layer.camera_mask
	_priority_by_layer[layer] = layer.priority
	
	layer_added.emit(layer)
	layer.activated.emit()
func unregister_layer(layer : NodeCameraLayer) -> void:
	if !is_layer_registered(layer):
		return
	
	layer.priority_changed.disconnect(
		_layer_changed_priority
	)
	layer.camera_mask_changed.disconnect(
		_layer_changed_mask
	)
	
	# Removes the layer fast, without preserving order.
	var idx := _layers.find(layer)
	var val := _layers.pop_back()
	if idx != _layers.size():
		_layers[idx] = val
	
	_masks_by_layer.erase(layer)
	_priority_by_layer.erase(layer)
	
	layer_removed.emit(layer)
	layer.deactivated.emit()

func is_layer_registered(layer : NodeCameraLayer) -> bool:
	return layer.priority_changed.is_connected(
		_layer_changed_priority
	)
#endregion


#region Accessor Methods
func get_registered() -> Array[NodeCameraLayer]:
	return _layers
func get_registered_at(idx : int) -> NodeCameraLayer:
	return _layers[idx]

func size() -> int:
	return _layers.size()
func is_empty() -> bool:
	return _layers.is_empty()
#endregion


# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
