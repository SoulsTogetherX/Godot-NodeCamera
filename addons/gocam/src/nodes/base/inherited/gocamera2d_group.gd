@tool
class_name GoCamera2DGroup extends GoCamera2DLayer


#region Private Variables
var _layers : Array[GoCamera2DLayer]

var _layer_register_lock : bool = false
#endregion



#region Virtual Methods
func _notification(what: int) -> void:
	super(what)
	match what:
		NOTIFICATION_READY, NOTIFICATION_CHILD_ORDER_CHANGED:
			_queue_register_layers()
#endregion


#region Private Methods (Effect)
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


#region Public Virtual Methods
func layer_start(
	current_state : CameraStateResource, target_state : CameraStateResource
) -> void:
	pass
func layer_end(
	current_state : CameraStateResource, target_state : CameraStateResource
) -> void:
	pass

func process_tick(
	current_state : CameraStateResource, target_state : CameraStateResource
) -> void:
	pass

func transition_tick_needed() -> bool:
	return false
func process_tick_needed() -> bool:
	return false
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
	return false
func has_transitions() -> bool:
	return false
#endregion
