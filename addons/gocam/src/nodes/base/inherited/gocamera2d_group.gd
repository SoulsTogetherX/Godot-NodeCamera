@tool
class_name GoCamera2DGroup extends GoCamera2DLayer


#region Private Variables
var _layers : Array[GoCamera2DLayer]
var _layer_manager := GoCamera2DLayerManager.new()

var _layer_register_lock : bool = false
#endregion



#region Virtual Methods
func _notification(what: int) -> void:
	match what:
		NOTIFICATION_READY, NOTIFICATION_CHILD_ORDER_CHANGED:
			_queue_register_layers()
#endregion


#region Public Virtual Methods
func layer_start(
	target_state : CameraStateResource, current_state : CameraStateResource
) -> void:
	for layer : GoCamera2DLayer in _layer_manager.get_running_effects():
		layer.layer_start(target_state)
	for layer : GoCamera2DLayer in _layer_manager.get_running_transitions():
		layer.layer_start(target_state, current_state)
func layer_end(
	target_state : CameraStateResource, current_state : CameraStateResource
) -> void:
	for layer : GoCamera2DLayer in _layer_manager.get_running_effects():
		layer.layer_end(target_state)
	for layer : GoCamera2DLayer in _layer_manager.get_running_transitions():
		layer.layer_end(target_state, current_state)

func process_tick(
	target_state : CameraStateResource
) -> void:
	_layer_manager.tick_effect(target_state)
func process_tick_needed() -> bool:
	return !_layer_manager.without_running_effects()

func transition_tick(
	target_state : CameraStateResource, current_state : CameraStateResource
) -> void:
	_layer_manager.tick_transition(target_state, current_state)
func transition_tick_needed() -> bool:
	return !_layer_manager.without_running_transitions()
#endregion


#region Private Methods (Queue)
func _queue_register_layers() -> void:
	if _layer_register_lock:
		return
	_layer_register_lock = true
	_register_layers.call_deferred()
func _register_layers() -> void:
	_layers.clear()
	
	for node : Node in get_children():
		if node is GoCamera2DLayer:
			_layers.append(node)
	
	_update_layers_active()
	_layer_register_lock = false
#endregion


#region Private Methods (Update)
func _update_layers_active() -> void:
	for layer : GoCamera2DLayer in _layers:
		layer.active = active
#endregion


#region Public Methods (Layer Register)
func register_layer(layer : GoCamera2DLayer) -> void:
	_layer_manager.register_layer(layer)
func unregister_layer(layer : GoCamera2DLayer) -> void:
	_layer_manager.unregister_layer(layer)
#endregion


#region Public Methods (Accessor)
func set_active(val : bool) -> void:
	if active == val:
		return
	super(val)
	_update_layers_active()
#endregion


#region Public Methods (Accessor Checks)
func is_empty() -> bool:
	return false

func has_effects() -> bool:
	return !_layer_manager.without_running_effects()
func has_transitions() -> bool:
	return !_layer_manager.without_running_transitions()

func is_layer_registered(layer : GoCamera2DLayer) -> bool:
	return _layer_manager.is_layer_registered(layer)
func is_layer_subscribed(layer : GoCamera2DLayer) -> bool:
	return _layer_manager.is_layer_subscribed(layer)
#endregion
