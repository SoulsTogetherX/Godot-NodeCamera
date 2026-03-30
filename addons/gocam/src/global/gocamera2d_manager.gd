@tool
extends Node


#region Constants
const CONSTANTS := preload("uid://b8t21yw0evfx")
#endregion


#region Private Variables
var _running_effects : Array[GoCamera2DEffect] = []
var _running_transitions : Array[GoCamera2DTransition] = []

var _idle_hosts : Array[GoCamera2DHost] = []
var _physics_hosts : Array[GoCamera2DHost] = []
var _manual_hosts : Array[GoCamera2DHost] = []
#endregion



#region Private Methods (Priority Update)
func _effect_priority_changed(effect : GoCamera2DEffect) -> void:
	_running_effects.erase(effect)
	_sorted_layer_append(effect, _running_effects)
func _transition_priority_changed(effect : GoCamera2DEffect) -> void:
	_running_transitions.erase(effect)
	_sorted_layer_append(effect, _running_transitions)

func _sorted_layer_append(layer : GoCamera2DLayer, cache : Array) -> void:
	var idx := cache.bsearch_custom(layer, _priority_comparison, false)
	cache.insert(idx, layer)

func _priority_comparison(l1 : GoCamera2DLayer, l2 : GoCamera2DLayer) -> bool:
	return l1.priority < l2.priority
#endregion


#region Private Methods (Process Update)
func _host_callback_change(
	host : GoCamera2DHost,
	old : CONSTANTS.PROCESS_CALLBACK
) -> void:
	var old_cache := _get_cache(old)
	var new_cache := _get_cache(host.process_callback)
	
	old_cache.erase(host)
	new_cache.append(host)
	_update_process_modes()

func _update_process_modes() -> void:
	var tree_process := get_tree().process_frame
	var tree_physics := get_tree().physics_frame
	
	if _idle_hosts.is_empty():
		if tree_process.is_connected(_on_idle):
			tree_process.disconnect(_on_idle)
	else:
		if !tree_process.is_connected(_on_idle):
			tree_process.connect(_on_idle, CONNECT_DEFERRED)
	
	if _physics_hosts.is_empty():
		if tree_physics.is_connected(_on_physics_process):
			tree_physics.disconnect(_on_physics_process)
	else:
		if !tree_physics.is_connected(_on_physics_process):
			tree_physics.connect(_on_physics_process, CONNECT_DEFERRED)

func _refresh_effect_updating(layer : GoCamera2DEffect) -> void:
	_refresh_layer_updating(layer, _effect_priority_changed, _running_effects)
func _refresh_transition_updating(layer : GoCamera2DTransition) -> void:
	_refresh_layer_updating(layer, _transition_priority_changed, _running_transitions)
func _refresh_layer_updating(
	layer : GoCamera2DLayer, priority_change : Callable, cache : Array
) -> void:
	if layer.is_registered() && layer.process_tick_needed():
		if !cache.has(layer):
			if !layer.is_connected(
				CONSTANTS.INTERAL_PRIORITY_CHANGED, priority_change
			):
				layer.connect(
					CONSTANTS.INTERAL_PRIORITY_CHANGED, priority_change
				)
			_sorted_layer_append(layer, cache)
		return
	
	if layer.is_connected(
		CONSTANTS.INTERAL_PRIORITY_CHANGED, priority_change
	):
		layer.disconnect(
			CONSTANTS.INTERAL_PRIORITY_CHANGED, priority_change
		)
	cache.erase(layer)
#endregion


#region Private Methods (Helper)
func _get_cache(mode : CONSTANTS.PROCESS_CALLBACK) -> Array[GoCamera2DHost]:
	match mode:
		CONSTANTS.PROCESS_CALLBACK.IDLE:
			return _idle_hosts
		CONSTANTS.PROCESS_CALLBACK.PHYSICS:
			return _physics_hosts
		CONSTANTS.PROCESS_CALLBACK.MANUAL:
			return _manual_hosts
	return []
#endregion


#region Methods (Process Callbacks)
func _on_idle() -> void:
	for host : GoCamera2DHost in _idle_hosts:
		_tick_effect(host)
	for host : GoCamera2DHost in _idle_hosts:
		_tick_transition(host)
func _on_physics_process() -> void:
	for host : GoCamera2DHost in _physics_hosts:
		_tick_effect(host)
	for host : GoCamera2DHost in _physics_hosts:
		_tick_transition(host)
func tick_all_manual_hosts() -> void:
	for host : GoCamera2DHost in _manual_hosts:
		_tick_effect(host)
	for host : GoCamera2DHost in _manual_hosts:
		_tick_transition(host)

func _tick_effect(host : GoCamera2DHost) -> void:
	var current_state := host.get_target_camera_state()
	for effect : GoCamera2DEffect in _running_effects:
		effect.process_tick(current_state)
func _tick_transition(host : GoCamera2DHost) -> void:
	var cam := host.get_camera()
	var current_state := host.get_current_camera_state()
	var target_state := host.get_target_camera_state()
	
	for transition : GoCamera2DTransition in _running_transitions:
		transition.process_tick(current_state, target_state)
	
	cam.position = current_state.position
	cam.offset = current_state.offset
	cam.zoom = current_state.zoom
	cam.rotation = current_state.rotation
#endregion


#region Public Methods (Effect Register)
func register_layer(layer : GoCamera2DLayer) -> void:
	if is_layer_registered(layer):
		return
	var refresh_foo : Callable
	var toggle_foo : Callable
	
	if layer is GoCamera2DEffect:
		refresh_foo = _refresh_effect_updating
		toggle_foo = _effect_toggle
	elif layer is GoCamera2DTransition:
		refresh_foo = _refresh_transition_updating
		toggle_foo = _transition_toggle
	
	layer.connect(
		CONSTANTS.INTERAL_TICK_CHANGED, refresh_foo
	)
	toggle_foo.call(layer, true)
	refresh_foo.call(layer)
func unregister_layer(layer : GoCamera2DLayer) -> void:
	if !is_layer_registered(layer):
		return
	var refresh_foo : Callable
	var toggle_foo : Callable
	
	if layer is GoCamera2DEffect:
		refresh_foo = _refresh_effect_updating
		toggle_foo = _effect_toggle
	elif layer is GoCamera2DTransition:
		refresh_foo = _refresh_transition_updating
		toggle_foo = _transition_toggle
	
	layer.disconnect(
		CONSTANTS.INTERAL_TICK_CHANGED, refresh_foo
	)
	toggle_foo.call(layer, false)
	refresh_foo.call(layer)

func is_layer_registered(layer : GoCamera2DLayer) -> bool:
	var refresh_foo : Callable
	if layer is GoCamera2DEffect:
		refresh_foo = _refresh_effect_updating
	elif layer is GoCamera2DTransition:
		refresh_foo = _refresh_transition_updating
	
	return layer.is_connected(
		CONSTANTS.INTERAL_TICK_CHANGED, refresh_foo
	)

func _effect_toggle(effect : GoCamera2DEffect, start : bool) -> void:
	if !is_layer_registered(effect):
		return
	var foo : Callable = effect.effect_start if start else effect.effect_end
	
	for host : GoCamera2DHost in _idle_hosts:
		foo.call(host.get_current_camera_state())
	for host : GoCamera2DHost in _physics_hosts:
		foo.call(host.get_current_camera_state())
	for host : GoCamera2DHost in _manual_hosts:
		foo.call(host.get_current_camera_state())
func _transition_toggle(transition : GoCamera2DTransition, start : bool) -> void:
	if !is_layer_registered(transition):
		return
	var foo : Callable = transition.transition_start if start else transition.transition_end
	
	for host : GoCamera2DHost in _idle_hosts:
		foo.call(host.get_current_camera_state(), host.get_target_camera_state())
	for host : GoCamera2DHost in _physics_hosts:
		foo.call(host.get_current_camera_state(), host.get_target_camera_state())
	for host : GoCamera2DHost in _manual_hosts:
		foo.call(host.get_current_camera_state(), host.get_target_camera_state())
#endregion

#region Public Methods (Host Registers)
func register_host(host : GoCamera2DHost) -> void:
	if is_host_registered(host):
		return
	host.connect(
		CONSTANTS.INTERAL_CALLBACK_CHANGED,
		_host_callback_change
	)
	
	var cache := _get_cache(host.process_callback)
	cache.append(host)
	_update_process_modes()
func unregister_host(host : GoCamera2DHost) -> void:
	if !is_host_registered(host):
		return
	host.disconnect(
		CONSTANTS.INTERAL_CALLBACK_CHANGED,
		_host_callback_change
	)
	
	var cache := _get_cache(host.process_callback)
	cache.erase(host)
	_update_process_modes()

func is_host_registered(host : GoCamera2DHost) -> bool:
	return host.is_connected(
		CONSTANTS.INTERAL_CALLBACK_CHANGED,
		_host_callback_change
	)
#endregion
