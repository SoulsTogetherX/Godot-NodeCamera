@tool
class_name GoCamera2DLayerManager extends RefCounted

#region Signals
signal queues_changed
#endregion


#region Constants
const CONSTANTS := preload("uid://b8t21yw0evfx")
#endregion


#region External Variables
@export var camera_flag_mask : int = -1
#endregion


#region Private Variables
var _effects_queue : Array[GoCamera2DLayer]
var _transitions_queue : Array[GoCamera2DLayer]
#endregion



#region Methods (Queue)
func _update_layer_priority(layer : GoCamera2DLayer) -> void:
	if layer is GoCamera2DEffect || layer is GoCamera2DGroup:
		_effects_queue.erase(layer)
		if layer.effect_tick_needed() && is_layer_subscribed(layer):
			_insert_layer_in_queue(layer, _effects_queue)
	if layer is GoCamera2DTransition || layer is GoCamera2DGroup:
		_transitions_queue.erase(layer)
		if layer.transition_tick_needed() && is_layer_subscribed(layer):
			_insert_layer_in_queue(layer, _transitions_queue)
func _insert_layer_in_queue(layer : GoCamera2DLayer, queue : Array[GoCamera2DLayer]) -> void:
	queue.insert(
		queue.bsearch_custom(layer, _priority_comparison, false), layer
	)

func _priority_comparison(l1 : GoCamera2DLayer, l2 : GoCamera2DLayer) -> bool:
	return l1.priority < l2.priority
#endregion


#region Methods (Queue Ticks)
func effect_tick(target_status : GoCameraStateResource) -> void:
	for effect : GoCamera2DLayer in _effects_queue:
		effect.effect_tick(target_status)
func transition_tick(
	target_status : GoCameraStateResource, current_status : GoCameraStateResource
) -> void:
	for transition : GoCamera2DLayer in _transitions_queue:
		transition.transition_tick(target_status, current_status)
#endregion


#region Methods (Subscribe Layer)
func _subscription_changed(layer : GoCamera2DLayer) -> void:
	if !is_layer_registered(layer) || !layer.is_running():
		_unsubscribe_layer(layer)
		return
	
	if layer is GoCamera2DEffect || layer is GoCamera2DGroup:
		if layer.effect_tick_needed():
			_subscribe_layer(layer)
		else:
			_unsubscribe_layer(layer)
	if layer is GoCamera2DTransition || layer is GoCamera2DGroup:
		if layer.transition_tick_needed():
			_subscribe_layer(layer)
		else:
			_unsubscribe_layer(layer)

func _subscribe_layer(layer : GoCamera2DLayer) -> void:
	if is_layer_subscribed(layer):
		return
	
	layer.connect(
		CONSTANTS.INTERAL_PRIORITY_CHANGED,
		_update_layer_priority
	)
	_update_layer_priority(layer)
	queues_changed.emit()
func _unsubscribe_layer(layer : GoCamera2DLayer) -> void:
	if !is_layer_subscribed(layer):
		return
	
	layer.disconnect(
		CONSTANTS.INTERAL_PRIORITY_CHANGED,
		_update_layer_priority
	)
	_update_layer_priority(layer)
	queues_changed.emit()

func is_layer_subscribed(layer : GoCamera2DLayer) -> bool:
	return layer.is_connected(
		CONSTANTS.INTERAL_PRIORITY_CHANGED,
		_update_layer_priority
	)
#endregion


#region Methods (Register Layer)
func register_layer(layer : GoCamera2DLayer) -> void:
	if is_layer_registered(layer):
		return
	
	layer.connect(
		CONSTANTS.INTERAL_TICK_CHANGED,
		_subscription_changed,
		CONNECT_DEFERRED
	)
	_subscription_changed(layer)
func unregister_layer(layer : GoCamera2DLayer) -> void:
	if !is_layer_registered(layer):
		return
	
	layer.disconnect(
		CONSTANTS.INTERAL_TICK_CHANGED,
		_subscription_changed
	)
	_subscription_changed(layer)

func is_layer_registered(layer : GoCamera2DLayer) -> bool:
	return layer.is_connected(
		CONSTANTS.INTERAL_TICK_CHANGED,
		_subscription_changed
	)
#endregion


#region Methods (Accessor)
func without_queued_effects() -> bool:
	return _effects_queue.is_empty()
func without_queued_transitions() -> bool:
	return _transitions_queue.is_empty()
#endregion


#region Public Methods (Force Layer)
func force_start_layer(
	layer : GoCamera2DLayer,
	target : GoCameraStateResource, current : GoCameraStateResource
) -> void:
	if layer is GoCamera2DGroup:
		layer.start_group(target, current)
		return
	if layer is GoCamera2DEffect:
		layer.start_effect(target)
		return
	if layer is GoCamera2DTransition:
		layer.start_transition(target, current)
		return
func force_end_layer(
	layer : GoCamera2DLayer,
	target : GoCameraStateResource, current : GoCameraStateResource
) -> void:
	if layer is GoCamera2DGroup:
		layer.end_group(target, current)
		return
	if layer is GoCamera2DEffect:
		layer.end_effect(target)
		return
	if layer is GoCamera2DTransition:
		layer.end_transition(target, current)
		return
#endregion
