@tool
class_name GoCamera2DGroup extends GoCamera2DEffect


#region Private Variables
var _effects : Array[GoCamera2DEffect]

var _effect_register_lock : bool = false
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
	if _effect_register_lock:
		return
	_effect_register_lock = true
	_register_layers.call_deferred()

func _register_layers() -> void:
	_effects.clear()
	
	for node : Node in get_children():
		if node is GoCamera2DEffect:
			_effects.append(node)
	
	_update_effect_active()
	_effect_register_lock = false
#endregion


#region Private Methods (Update)
func _update_effect_active() -> void:
	for effect : GoCamera2DEffect in _effects:
		effect.active = active
#endregion


#region Public Virtual Methods
func effect_start(state : CameraStateResource) -> void:
	for effect : GoCamera2DEffect in _effects:
		
		# TODO: Make _effects dynamically add and remove nodes
		# so these checks are not needed.
		if effect.disabled || effect.top_level:
			continue
		effect.effect_start(state)
func effect_end(state : CameraStateResource) -> void:
	for effect : GoCamera2DEffect in _effects:
		
		# TODO: Make _effects dynamically add and remove nodes
		# so these checks are not needed.
		if effect.disabled || effect.top_level:
			continue
		effect.effect_end(state)

func process_tick(state : CameraStateResource) -> void:
	for effect : GoCamera2DEffect in _effects:
		
		# TODO: Make _effects dynamically add and remove nodes
		# so these checks are not needed.
		if effect.disabled || effect.top_level:
			continue
		effect.process_tick(state)
#endregion


#region Public Methods (Accessor)
func set_active(val : bool) -> void:
	if active == val:
		return
	super(val)
	_update_effect_active()
#endregion
