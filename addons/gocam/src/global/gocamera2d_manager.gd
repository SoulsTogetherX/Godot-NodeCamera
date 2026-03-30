@tool
extends Node


#region Constants
const CONSTANTS := preload("uid://b8t21yw0evfx")
#endregion


#region Private Variables
var _running_effects : Array[GoCamera2DLayer] = []
var _running_transitions : Array[GoCamera2DLayer] = []

var _idle_hosts : Array[GoCamera2DHost] = []
var _physics_hosts : Array[GoCamera2DHost] = []
var _manual_hosts : Array[GoCamera2DHost] = []
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


#region Public Methods (Updaters)
func _update_layer_running_mode(layer : GoCamera2DLayer) -> void:
	if layer is GoCamera2DEffect:
		if !(layer.process_tick_needed() && layer.is_registered()):
			_running_effects.erase(layer)
			return
		if !_running_effects.has(layer):
			_sorted_layer_append(layer, _running_effects)
		return
	
	if layer is GoCamera2DTransition:
		if !(layer.process_tick_needed() && layer.is_registered()):
			_running_transitions.erase(layer)
			return
		if !_running_transitions.has(layer):
			_sorted_layer_append(layer, _running_transitions)
		return
	
	if layer is GoCamera2DGroup:
		if !layer.is_registered():
			_running_effects.erase(layer)
			_running_transitions.erase(layer)
			return
		
		if !layer.process_tick_needed():
			_running_effects.erase(layer)
		elif !_running_effects.has(layer):
			_sorted_layer_append(layer, _running_effects)
		
		if !layer.process_tick_needed():
			_running_transitions.erase(layer)
		elif !_running_transitions.has(layer):
			_sorted_layer_append(layer, _running_transitions)

func _update_host_callback(
	host : GoCamera2DHost, old : CONSTANTS.PROCESS_CALLBACK
) -> void:
	var old_cache := _get_cache(old)
	var new_cache := _get_cache(host.process_callback)
	
	old_cache.erase(host)
	new_cache.append(host)
	_update_callback_modes()
func _update_callback_modes() -> void:
	var tree_process := get_tree().process_frame
	var tree_physics := get_tree().physics_frame
	
	if _idle_hosts.is_empty():
		if tree_process.is_connected(_on_idle):
			tree_process.disconnect(_on_idle)
	elif !tree_process.is_connected(_on_idle):
		tree_process.connect(_on_idle, CONNECT_DEFERRED)
	
	if _physics_hosts.is_empty():
		if tree_physics.is_connected(_on_physics_process):
			tree_physics.disconnect(_on_physics_process)
	elif !tree_physics.is_connected(_on_physics_process):
		tree_physics.connect(_on_physics_process, CONNECT_DEFERRED)
#endregion


#region Public Methods (Callback Updates)
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
	for layer : GoCamera2DLayer in _running_effects:
		layer.process_tick(current_state)
func _tick_transition(host : GoCamera2DHost) -> void:
	var cam := host.get_camera()
	var current_state := host.get_current_camera_state()
	var target_state := host.get_target_camera_state()
	
	for layer : GoCamera2DLayer in _running_transitions:
		layer.process_tick(current_state, target_state)

	cam.position = current_state.position
	cam.offset = current_state.offset
	cam.zoom = current_state.zoom
	cam.rotation = current_state.rotation
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

func _toggle_layer(layer : GoCamera2DLayer, toggle : bool) -> void:
	if !is_layer_registered(layer):
		return
	
	if layer is GoCamera2DEffect:
		var foo : Callable = layer.layer_start if toggle else layer.layer_end
		
		for host : GoCamera2DHost in _idle_hosts:
			foo.call(host.get_target_camera_state())
		for host : GoCamera2DHost in _physics_hosts:
			foo.call(host.get_target_camera_state())
		for host : GoCamera2DHost in _manual_hosts:
			foo.call(host.get_target_camera_state())
	elif layer is GoCamera2DTransition || layer is GoCamera2DGroup:
		var foo : Callable = layer.layer_start if toggle else layer.layer_end
		
		for host : GoCamera2DHost in _idle_hosts:
			foo.call(host.get_current_camera_state(), host.get_target_camera_state())
		for host : GoCamera2DHost in _physics_hosts:
			foo.call(host.get_current_camera_state(), host.get_target_camera_state())
		for host : GoCamera2DHost in _manual_hosts:
			foo.call(host.get_current_camera_state(), host.get_target_camera_state())
#endregion


#region Public Methods (Layer Registers)
func register_layer(layer : GoCamera2DLayer) -> void:
	if is_layer_registered(layer):
		return
	layer.connect(
		CONSTANTS.INTERAL_TICK_CHANGED, _update_layer_running_mode
	)
	_update_layer_running_mode(layer)
	_toggle_layer(layer, true)
func unregister_layer(layer : GoCamera2DLayer) -> void:
	if !is_layer_registered(layer):
		return
	layer.disconnect(
		CONSTANTS.INTERAL_TICK_CHANGED, _update_layer_running_mode
	)
	_update_layer_running_mode(layer)
	_toggle_layer(layer, false)


func is_layer_registered(layer : GoCamera2DLayer) -> bool:
	return layer.is_connected(
		CONSTANTS.INTERAL_TICK_CHANGED, _update_layer_running_mode
	)
#endregion


#region Public Methods (Host Registers)
func register_host(host : GoCamera2DHost) -> void:
	if is_host_registered(host):
		return
	host.connect(
		CONSTANTS.INTERAL_CALLBACK_CHANGED,
		_update_host_callback
	)
	
	var cache := _get_cache(host.process_callback)
	cache.append(host)
	_update_callback_modes()
func unregister_host(host : GoCamera2DHost) -> void:
	if !is_host_registered(host):
		return
	host.disconnect(
		CONSTANTS.INTERAL_CALLBACK_CHANGED,
		_update_host_callback
	)
	
	var cache := _get_cache(host.process_callback)
	cache.erase(host)
	_update_callback_modes()

func is_host_registered(host : GoCamera2DHost) -> bool:
	return host.is_connected(
		CONSTANTS.INTERAL_CALLBACK_CHANGED,
		_update_host_callback
	)
#endregion
