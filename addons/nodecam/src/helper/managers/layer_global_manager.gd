# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
@tool
class_name NodeCamera2DLayerGlobalManager extends NodeCamera2DLayerManager
## A specialized extensions of [NodeCamera2DLayerManager], used to filter
## [NodeCamera2DLayer] by the [member NodeCamera2DHost.camera_flag_mask]
## of [NodeCamera2DHost], and to automatically call the appropriate
## 'layer_start' and 'layer_end' methods on [NodeCamera2DLayer]s. 


#region Signals
## This signal emits, requesting the provided layer to have it's appropriate
## 'layer_start' method ([method NodeCamera2DEffect.start_effect],
## [method NodeCamera2DTransition.start_transition], or
## [method NodeCamera2DGroup.start_group]) called.
signal layer_start(layer : NodeCamera2DLayer)
## This signal emits, requesting the provided layer to have it's appropriate
## 'layer_end' method ([method NodeCamera2DEffect.end_effect],
## [method NodeCamera2DTransition.end_transition], or
## [method NodeCamera2DGroup.end_group]) called.
signal layer_end(layer : NodeCamera2DLayer)

## This signal emits, requesting the provided layer to have it's appropriate
## 'layer_start' and 'layer_end' methods to be called when it's mask is changed.
signal layer_mask_changed(layer : NodeCamera2DLayer)
#endregion


#region Constants
## An internal constant used for metadata marking a node's state.
const META_DATA_HAS_STARTED_NAME := &"META_DATA_HAS_STARTED"
#endregion


#region Private Variables
var _active_layers : Array[NodeCamera2DLayer]
#endregion



#region Methods (Queue)
func _update_layer_priority(layer : NodeCamera2DLayer) -> void:
	_active_layers.erase(layer)
	_insert_layer_in_queue(layer, _active_layers)
	super(layer)
func _activate_layer(layer : NodeCamera2DLayer) -> void:
	_insert_layer_in_queue(layer, _active_layers)
	layer_start.emit(layer)
func _deactivate_layer(layer : NodeCamera2DLayer) -> void:
	_active_layers.erase(layer)
	layer_end.emit(layer)
#endregion


#region Methods (Register Layer)
## Registers the given [param layer] into this object.
## [br][br]
## Overloaded only to ensure unneeded metadata is cleared upon register.
func register_layer(layer : NodeCamera2DLayer) -> void:
	super(layer)
	layer.activated.connect(
		_activate_layer, CONNECT_APPEND_SOURCE_OBJECT
	)
	layer.deactivated.connect(
		_deactivate_layer, CONNECT_APPEND_SOURCE_OBJECT
	)
	layer.camera_mask_changed.connect(
		layer_mask_changed.emit, CONNECT_APPEND_SOURCE_OBJECT
	)
	
	if layer.is_running():
		_activate_layer(layer)
## Unregisters the given [param layer] from this object.
## [br][br]
## Overloaded only to ensure unneeded metadata is cleared upon unregister.
func unregister_layer(layer : NodeCamera2DLayer) -> void:
	super(layer)
	layer.activated.disconnect(
		_activate_layer
	)
	layer.deactivated.disconnect(
		_deactivate_layer
	)
	layer.camera_mask_changed.disconnect(
		layer_mask_changed.emit
	)
	
	_deactivate_layer(layer)
#endregion


#region Methods (Queue Ticks)
## Calls the either [NodeCamera2DEffect.effect_tick] or [NodeCamera2DGroup.effect_tick]
## methods, on all layers subscribed to effect ticks, with [param target_status].
func _effect_tick(target_status : GoCameraStateResource, mask : int) -> void:
	for effect : NodeCamera2DLayer in _effects_queue:
		if !(effect.camera_flag_mask & mask):
			return
		effect._effect_tick(target_status)
## Calls the either [NodeCamera2DTransition.transition_tick] or
## [NodeCamera2DGroup.transition_tick] methods, on all layers subscribed to
## transition ticks, with [param target_status] and [param current_status].
func _transition_tick(
	target_status : GoCameraStateResource, current_status : GoCameraStateResource,
	mask : int
) -> void:
	for transition : NodeCamera2DLayer in _transitions_queue:
		if !(transition.camera_flag_mask & mask):
			return
		transition._transition_tick(target_status, current_status)
#endregion


#region Methods (Accessor)
## Returns all registered and active layers within this object, sorted 
## by priority.
func get_active_layers() -> Array[NodeCamera2DLayer]:
	return _active_layers
#endregion

# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
