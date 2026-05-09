# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
@tool
class_name NodeCameraLayerStorage extends Object
## Stores and orders [NodeCameraLayer]s, in order of priority, via a flat array.
## Emits signals when an operation of interest is performed by stored layers,
## or when a layer is added/removed.

#region Signals
## Emitted when a layer is added to this [NodeCameraLayerStorage].
signal layer_added(layer : NodeCameraLayer)
## Emitted when a layer is removed to this [NodeCameraLayerStorage].
signal layer_removed(layer : NodeCameraLayer)
#endregion


#region Private Variables
var _layers : Array[NodeCameraLayer]

var _priority_by_layer : Dictionary[NodeCameraLayer, int]
var _masks_by_layer : Dictionary[NodeCameraLayer, int]
#endregion



#region Private Helper Methods
func _priority_check(l1 : NodeCameraLayer, l2 : NodeCameraLayer) -> bool:
	return l1.priority > l2.priority
#endregion


#region Public Methods (Register Layer)
## Registers a layer into this [NodeCameraLayerStorage] according to it's priority.
func register_layer(layer : NodeCameraLayer) -> void:
	if is_layer_registered(layer):
		return
	
	_layers.insert(_layers.bsearch_custom(layer, _priority_check), layer)
	
	_masks_by_layer[layer] = layer.camera_mask
	_priority_by_layer[layer] = layer.priority
	
	layer_added.emit(layer)
	layer.activated.emit()
## Unregisters a layer from this [NodeCameraLayerStorage].
func unregister_layer(layer : NodeCameraLayer) -> void:
	if !is_layer_registered(layer):
		return
	
	_layers.remove_at(_layers.bsearch_custom(layer, _priority_check))
	_masks_by_layer.erase(layer)
	_priority_by_layer.erase(layer)
	
	layer_removed.emit(layer)
	layer.deactivated.emit()

## Returns if a layer is registered in this [NodeCameraLayerStorage].
func is_layer_registered(layer : NodeCameraLayer) -> bool:
	return _masks_by_layer.has(layer)
#endregion


#region Accessor Methods
## Returns all registed layers directly.
## [br][br]
## [b]NOTE[/b]: Editing this array directly may cause an engine crash.
func get_registered() -> Array[NodeCameraLayer]:
	return _layers
## Return the [NodeCameraLayer] registered at the array index [param idx].
func get_registered_at(idx : int) -> NodeCameraLayer:
	return _layers[idx]

## Returns the number of [NodeCameraLayer] stored.
func size() -> int:
	return _layers.size()
## Returns if there are no [NodeCameraLayer]s stored.
func is_empty() -> bool:
	return _layers.is_empty()
#endregion

# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
