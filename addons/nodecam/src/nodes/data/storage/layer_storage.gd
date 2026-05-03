# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
@tool
class_name NodeCamera2DLayerStorage extends Object

#region Signals
signal layer_added(layer : NodeCamera2DLayer)
signal layer_removed(layer : NodeCamera2DLayer)

signal layer_changed_priority(layer : NodeCamera2DLayer, old_priority : int)
signal layer_changed_mask(layer : NodeCamera2DLayer, old_mask : int)
#endregion


#region Private Variables
var _layers : Array[NodeCamera2DLayer]

var _masks_by_layer : Dictionary[NodeCamera2DLayer, int]
var _priority_by_layer : Dictionary[NodeCamera2DLayer, int]
#endregion



#region Private Methods (Updating Layers)
func _layer_changed_mask(layer : NodeCamera2DLayer) -> void:
	layer_changed_mask.emit(
		layer, _masks_by_layer[layer]
	)
func _layer_changed_priority(layer : NodeCamera2DLayer) -> void:
	layer_changed_priority.emit(
		layer, _priority_by_layer[layer]
	)
#endregion


#region Public Methods (Register Layer)
func get_registered_layers() -> Array[NodeCamera2DLayer]:
	return _layers

func register_layer(layer : NodeCamera2DLayer) -> void:
	if is_layer_registered(layer):
		return
	
	layer.camera_mask_changed.connect(
		_layer_changed_mask, CONNECT_APPEND_SOURCE_OBJECT
	)
	layer.priority_changed.connect(
		_layer_changed_priority, CONNECT_APPEND_SOURCE_OBJECT
	)
	
	layer_added.emit(layer)
	_layers.append(layer)
	
	_masks_by_layer[layer] = layer.camera_mask
	_priority_by_layer[layer] = layer.priority
	layer.activated.emit()
func unregister_layer(layer : NodeCamera2DLayer) -> void:
	if !is_layer_registered(layer):
		return
	
	layer.camera_mask_changed.disconnect(
		_layer_changed_mask
	)
	layer.priority_changed.disconnect(
		_layer_changed_priority
	)
	
	layer_removed.emit(layer)
	# Removes the layer, without preserving order.
	var idx := _layers.find(layer)
	var val := _layers.pop_back()
	if idx != _layers.size():
		_layers[idx] = val
	
	_masks_by_layer.erase(layer)
	_priority_by_layer.erase(layer)
	layer.deactivated.emit()

func is_layer_registered(layer : NodeCamera2DLayer) -> bool:
	return layer.camera_mask_changed.is_connected(
		_layer_changed_mask
	)
#endregion

# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
