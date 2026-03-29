@tool
extends Node


#region Private Variables
var _effects : Array[GoCamera2DEffect] = []

var _hosts : Array[GoCamera2DHost] = []
#endregion



#region Public Methods (Layer Register)
func register_effect(effect : GoCamera2DEffect) -> void:
	if _effects.find(effect) != -1:
		push_warning("Attempted to register an effect already registered.")
		return
	var idx := _effects.bsearch_custom(effect, priority_comparison, false)
	_effects.insert(idx, effect)
	
	effect.connect(&"_priority_changed", _effect_priority_changed)
func unregister_effect(effect : GoCamera2DEffect) -> void:
	var idx := _effects.find(effect)
	if idx == -1:
		push_warning("Attempted to unregister an effect not registered.")
		return
	_effects.remove_at(idx)
	
	effect.disconnect(&"_priority_changed", _effect_priority_changed)

func _effect_priority_changed(effect : GoCamera2DEffect) -> void:
	var idx := _effects.find(effect)
	_effects.remove_at(idx)
	
	idx = _effects.bsearch_custom(effect, priority_comparison, false)
	_effects.insert(idx, effect)
#endregion


#region Public Methods (Host Registers)
func register_host(host : GoCamera2DHost) -> void:
	if _hosts.find(host) != -1:
		push_warning("Attempted to register a camera host already registered.")
		return
	_hosts.append(host)
func unregister_host(host : GoCamera2DHost) -> void:
	var idx := _hosts.find(host)
	if idx == -1:
		push_warning("Attempted to unregister a camera host not registered.")
		return
	_hosts.remove_at(idx)
#endregion


#region Public Methods (Helper)
func priority_comparison(l1 : GoCamera2DLayer, l2 : GoCamera2DLayer) -> bool:
	return l1.priority < l2.priority
#endregion



func _ready() -> void:
	get_tree().physics_frame.connect(_update_cam, CONNECT_DEFERRED)

func _update_cam() -> void:
	for host : GoCamera2DHost in _hosts:
		var cam := host.get_camera()
		var state := host.get_target_camera_state()
		
		for effect : GoCamera2DEffect in _effects:
			effect.run_effect(state)
		
		cam.position = state.position
		cam.offset = state.offset
		cam.zoom = state.zoom
		cam.rotation = state.rotation
