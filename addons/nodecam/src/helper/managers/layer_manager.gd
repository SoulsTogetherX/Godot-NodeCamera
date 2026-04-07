# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
@tool
class_name NodeCamera2DLayerManager extends RefCounted
## The main object used for general [NodeCamera2DLayer] management.


#region Constants
## The script containing all shared constants used by the NodeCamera2D addon.
const CONSTANTS := preload("uid://b8t21yw0evfx")
#endregion


#region Private Variables
var _effects_queue : Array[NodeCamera2DLayer]
var _transitions_queue : Array[NodeCamera2DLayer]
#endregion



#region Methods (Queue)
func _update_layer_priority(layer : NodeCamera2DLayer) -> void:
	if layer is NodeCamera2DEffect || layer is NodeCamera2DGroup:
		_effects_queue.erase(layer)
		if layer._effect_tick_needed() && is_layer_subscribed(layer):
			_insert_layer_in_queue(layer, _effects_queue)
	if layer is NodeCamera2DTransition || layer is NodeCamera2DGroup:
		_transitions_queue.erase(layer)
		if layer._transition_tick_needed() && is_layer_subscribed(layer):
			_insert_layer_in_queue(layer, _transitions_queue)

func _insert_layer_in_queue(layer : NodeCamera2DLayer, queue : Array[NodeCamera2DLayer]) -> void:
	queue.insert(
		queue.bsearch_custom(layer, _priority_comparison, false), layer
	)

func _priority_comparison(l1 : NodeCamera2DLayer, l2 : NodeCamera2DLayer) -> bool:
	return l1.priority < l2.priority
#endregion


#region Methods (Subscribe Layer)
func _subscription_changed(layer : NodeCamera2DLayer) -> void:
	if !layer.is_running():
		_unsubscribe_layer(layer)
		return
	
	if layer is NodeCamera2DGroup:
		if layer._effect_tick_needed() || layer._transition_tick_needed():
			_subscribe_layer(layer)
		else:
			_unsubscribe_layer(layer)
	elif layer is NodeCamera2DEffect:
		if layer._effect_tick_needed():
			_subscribe_layer(layer)
		else:
			_unsubscribe_layer(layer)
	elif layer is NodeCamera2DTransition:
		if layer._transition_tick_needed():
			_subscribe_layer(layer)
		else:
			_unsubscribe_layer(layer)

func _subscribe_layer(layer : NodeCamera2DLayer) -> void:
	if is_layer_subscribed(layer):
		return
	
	layer.priority_changed.connect(
		_update_layer_priority,
		CONNECT_APPEND_SOURCE_OBJECT | CONNECT_DEFERRED
	)
	_update_layer_priority(layer)
func _unsubscribe_layer(layer : NodeCamera2DLayer) -> void:
	if !is_layer_subscribed(layer):
		return
	
	layer.priority_changed.disconnect(
		_update_layer_priority
	)
	_update_layer_priority(layer)

## Returns if the given [param layer] is subscribed to tick updates or not.
func is_layer_subscribed(layer : NodeCamera2DLayer) -> bool:
	return layer.priority_changed.is_connected(
		_update_layer_priority
	)
#endregion


#region Methods (Register Layer)
## Registers the given [param layer] for updates.
func register_layer(layer : NodeCamera2DLayer) -> void:
	if is_layer_registered(layer):
		return
	
	layer.tick_state_changed.connect(
		_subscription_changed,
		CONNECT_DEFERRED | CONNECT_APPEND_SOURCE_OBJECT
	)
	_subscription_changed.call_deferred(layer)
## Unregisters the given [param layer] from this object.
func unregister_layer(layer : NodeCamera2DLayer) -> void:
	if !is_layer_registered(layer):
		return
	
	layer.tick_state_changed.disconnect(
		_subscription_changed
	)
	_unsubscribe_layer(layer)

## Returns if the given [param layer] has been registered in this Object.
func is_layer_registered(layer : NodeCamera2DLayer) -> bool:
	return layer.tick_state_changed.is_connected(
		_subscription_changed
	)
#endregion


#region Public Methods (Force Layer)
## Calls the appropriate 'layer_start' method ([method NodeCamera2DEffect.start_effect],
## [method NodeCamera2DTransition.start_transition], or
## [method NodeCamera2DGroup.start_group]), with [param target] and [param current]
## as arguments (as needed).
func force_start_layer(
	layer : NodeCamera2DLayer,
	target : GoCameraStateResource, current : GoCameraStateResource
) -> void:
	if layer is NodeCamera2DGroup:
		layer._start_group(target, current)
		return
	if layer is NodeCamera2DEffect:
		layer._start_effect(target)
		return
	if layer is NodeCamera2DTransition:
		layer._start_transition(target, current)
		return
## Calls the appropriate 'layer_end' method ([method NodeCamera2DEffect.end_effect],
## [method NodeCamera2DTransition.end_transition], or
## [method NodeCamera2DGroup.end_group]), with [param target] and [param current]
## as arguments (as needed).
func force_end_layer(
	layer : NodeCamera2DLayer,
	target : GoCameraStateResource, current : GoCameraStateResource
) -> void:
	if layer is NodeCamera2DGroup:
		layer._end_group(target, current)
		return
	if layer is NodeCamera2DEffect:
		layer._end_effect(target)
		return
	if layer is NodeCamera2DTransition:
		layer._end_transition(target, current)
		return
#endregion


#region Methods (Accessor)
## Returns all effect layers that are registered and subscribed
## in this object, sorted  by priority.
func get_queued_effects() -> Array[NodeCamera2DLayer]:
	return _effects_queue
## Returns all transition layers that are registered and subscribed
## in this object, sorted  by priority.
func get_queued_transitions() -> Array[NodeCamera2DLayer]:
	return _transitions_queue
#endregion

# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
