@tool
class_name GoCamera2DLayerManager


#region Signals Variables
signal layer_tick_changed
#endregion


#region Constants
const CONSTANTS := preload("uid://b8t21yw0evfx")
#endregion


#region Private Variables
var _running_effects : Array[GoCamera2DLayer] = []
var _running_transitions : Array[GoCamera2DLayer] = []
#endregion



#region Private Methods (Priority Update)
func _update_priority(layer : GoCamera2DLayer) -> void:
	if layer is GoCamera2DEffect || layer is GoCamera2DGroup:
		if _running_effects.has(layer):
			_running_effects.erase(layer)
			_sorted_layer_append(layer, _running_effects)
	if layer is GoCamera2DTransition || layer is GoCamera2DGroup:
		if _running_transitions.has(layer):
			_running_transitions.erase(layer)
			_sorted_layer_append(layer, _running_transitions)

func _sorted_layer_append(layer : GoCamera2DLayer, cache : Array) -> void:
	var idx := cache.bsearch_custom(layer, _priority_comparison, false)
	cache.insert(idx, layer)
func _priority_comparison(l1 : GoCamera2DLayer, l2 : GoCamera2DLayer) -> bool:
	return l1.priority < l2.priority
#endregion


#region Public Methods (Layer Subscribes)
func _subscribe_layer(layer : GoCamera2DLayer) -> void:
	if is_layer_subscribed(layer):
		return
	
	layer.connect(
		CONSTANTS.INTERAL_TICK_CHANGED, _update_layer_running_mode
	)
	_update_layer_running_mode(layer)
func _unsubscribe_layer(layer : GoCamera2DLayer) -> void:
	if !is_layer_subscribed(layer):
		return
	
	layer.disconnect(
		CONSTANTS.INTERAL_TICK_CHANGED, _update_layer_running_mode
	)
	_update_layer_running_mode(layer)
#endregion


#region Public Methods (Updaters)
func _update_layer_running_mode(layer : GoCamera2DLayer) -> void:
	if layer is GoCamera2DEffect:
		if !(layer.process_tick_needed() && layer.is_subscribed()):
			_running_effects.erase(layer)
		elif !_running_effects.has(layer):
			_sorted_layer_append(layer, _running_effects)
	
	elif layer is GoCamera2DTransition:
		if !(layer.transition_tick_needed() && layer.is_subscribed()):
			_running_transitions.erase(layer)
		elif !_running_transitions.has(layer):
			_sorted_layer_append(layer, _running_transitions)
	
	elif layer is GoCamera2DGroup:
		if !layer.is_subscribed():
			_running_effects.erase(layer)
			_running_transitions.erase(layer)
		else:
			if !layer.process_tick_needed():
				_running_effects.erase(layer)
			elif !_running_effects.has(layer):
				_sorted_layer_append(layer, _running_effects)
			
			if !layer.transition_tick_needed():
				_running_transitions.erase(layer)
			elif !_running_transitions.has(layer):
				_sorted_layer_append(layer, _running_transitions)
	
	layer_tick_changed.emit()
#endregion


#region Public Methods (Layer Ticks)
func tick_effect(target_state : CameraStateResource) -> void:
	target_state._read_only = false
	for layer : GoCamera2DLayer in _running_effects:
		layer.process_tick(target_state)
func tick_transition(
	target_state : CameraStateResource,
	current_state : CameraStateResource
) -> void:
	target_state._read_only = true
	for layer : GoCamera2DLayer in _running_transitions:
		layer.transition_tick(target_state, current_state)
#endregion


#region Public Methods (Layer Registers)
func register_layer(layer : GoCamera2DLayer) -> void:
	if is_layer_registered(layer):
		return
	
	layer.connect(
			CONSTANTS.INTERAL_SUBSCRIBE, _subscribe_layer
		)
	layer.connect(
		CONSTANTS.INTERAL_UNSUBSCRIBE, _unsubscribe_layer
	)
func unregister_layer(layer : GoCamera2DLayer) -> void:
	if !is_layer_registered(layer):
		return
	if is_layer_subscribed(layer):
		_unsubscribe_layer(layer)
	
	layer.disconnect(
		CONSTANTS.INTERAL_SUBSCRIBE, _subscribe_layer
	)
	layer.disconnect(
		CONSTANTS.INTERAL_UNSUBSCRIBE, _unsubscribe_layer
	)

func is_layer_registered(layer : GoCamera2DLayer) -> bool:
	return layer.is_connected(
		CONSTANTS.INTERAL_TICK_CHANGED, _update_layer_running_mode
	)
func is_layer_subscribed(layer : GoCamera2DLayer) -> bool:
	return layer.is_connected(
		CONSTANTS.INTERAL_TICK_CHANGED, _update_layer_running_mode
	)
#endregion


#region Public Methods (Accessors)
func get_running_effects() -> Array[GoCamera2DLayer]:
	return _running_effects
func without_running_effects() -> bool:
	return _running_effects.is_empty()

func get_running_transitions() -> Array[GoCamera2DLayer]:
	return _running_transitions
func without_running_transitions() -> bool:
	return _running_transitions.is_empty()
#endregion


#region Public Methods (Helper)
func clear_effects() -> void:
	for layer : GoCamera2DLayer in _running_effects:
		unregister_layer(layer)
func clear_transitions() -> void:
	for layer : GoCamera2DLayer in _running_transitions:
		unregister_layer(layer)

func clear_all() -> void:
	clear_effects()
	clear_transitions()
#endregion
