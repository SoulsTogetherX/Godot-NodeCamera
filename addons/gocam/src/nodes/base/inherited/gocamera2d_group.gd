@tool
class_name GoCamera2DGroup extends GoCamera2DEffect


#region Private Variables
var _effects : Array[GoCamera2DEffect]
var _transitions : Array[GoCamera2DTransition]

var _layer_register_lock : bool = false
#endregion



#region Virtual Methods
func _notification(what: int) -> void:
	super(what)
	match what:
		NOTIFICATION_READY, NOTIFICATION_CHILD_ORDER_CHANGED:
			_queue_layer_register()
#endregion


#region Private Methods (Layer)
func _queue_layer_register() -> void:
	if _layer_register_lock:
		return
	_layer_register_lock = true
	_register_layers.call_deferred()

func _register_layers() -> void:
	_effects.clear()
	_transitions.clear()
	
	for node : Node in get_children():
		if node is GoCamera2DEffect:
			_effects.append(node)
		elif node is GoCamera2DTransition:
			_transitions.append(node)
	
	_update_layer_active() 
	
	_layer_register_lock = false
#endregion


#region Private Methods (Update)
func _update_layer_active() -> void:
	for layer : GoCamera2DTransition in _transitions:
		layer.active = active
	for layer : GoCamera2DEffect in _effects:
		layer.active = active
#endregion


#region Abstract Methods
func run_effect(state : CameraStateResource) -> void:
	for effect : GoCamera2DEffect in _effects:
		
		# TODO: Make _effects dynamically add and remove nodes
		# so these checks are not needed.
		if effect.disabled || effect.top_level:
			continue
		effect.run_effect(state)
#endregion


#region Public Methods (Accessor)
func set_active(val : bool) -> void:
	if active == val:
		return
	super(val)
	
	_update_layer_active()
#endregion
