@tool
class_name GoCamera2DGroup extends GoCamera2DLayer


#region Private Variables
var _layers : Array[GoCamera2DLayer]
var _layer_manager := GoCamera2DLayerManager.new()

var _tick_request : int

var _layer_register_lock : bool = false
var _layer_mode_change_lock : bool = false
#endregion



#region Virtual Methods
func _notification(what: int) -> void:
	super(what)
	match what:
		NOTIFICATION_READY:
			_layer_manager.layer_tick_changed.connect(_queue_layer_mode_change)
			_queue_register_layers()
		NOTIFICATION_CHILD_ORDER_CHANGED:
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
	prints("P-", _layer_manager.without_running_effects())
	return !_layer_manager.without_running_effects()

func transition_tick(
	target_state : CameraStateResource, current_state : CameraStateResource
) -> void:
	_layer_manager.tick_transition(target_state, current_state)
func transition_tick_needed() -> bool:
	prints("T-", _layer_manager.without_running_transitions())
	return !_layer_manager.without_running_transitions()
#endregion


#region Private Methods (Queue)
func _queue_layer_mode_change() -> void:
	if _layer_mode_change_lock:
		return
	_layer_mode_change_lock = true
	
	_layer_mode_change.call_deferred()
func _layer_mode_change() -> void:
	var effect_tick := bool(_tick_request & 0b01)
	var without_effects := _layer_manager.without_running_effects()
	if effect_tick == without_effects:
		_tick_request ^= 0b01
		notify_tick_request_changed.call_deferred()
		return
	
	var transition_tick := bool(_tick_request & 0b10)
	var without_transition := _layer_manager.without_running_effects()
	if effect_tick == without_transition:
		_tick_request ^= 0b10
		notify_tick_request_changed.call_deferred()
		return

func _queue_register_layers() -> void:
	if _layer_register_lock:
		return
	_layer_register_lock = true
	_register_layers.call_deferred()
func _register_layers() -> void:
	_layer_manager.clear_all()
	_layers.clear()
	
	for node : Node in get_children():
		if node is GoCamera2DLayer:
			_layer_manager.register_layer(node)
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
#endregion
