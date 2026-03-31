@tool
extends Node


#region Constants
const CONSTANTS := preload("uid://b8t21yw0evfx")
#endregion


#region Private Variables
var _layer_manager := GoCamera2DLayerManager.new()

var _idle_hosts : Array[GoCamera2DHost] = []
var _physics_hosts : Array[GoCamera2DHost] = []
var _manual_hosts : Array[GoCamera2DHost] = []
#endregion



#region Public Methods (Updaters)
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


#region Private Methods (Callback Updates)
func _on_idle() -> void:
	for host : GoCamera2DHost in _idle_hosts:
		tick_host(host)
func _on_physics_process() -> void:
	for host : GoCamera2DHost in _physics_hosts:
		tick_host(host)
#endregion

#region Public Methods (Callback Updates)
func tick_all_manual_hosts() -> void:
	for host : GoCamera2DHost in _manual_hosts:
		tick_host(host)

func tick_host(host : GoCamera2DHost) -> void:
	_layer_manager.tick_effect(host.get_target_camera_state())
	
	if _layer_manager.get_running_transitions().is_empty():
		host.teleport_camera()
		return
	_layer_manager.tick_transition(
		host.get_target_camera_state(), host.get_current_camera_state()
	)
	host.update_camera()
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
			foo.call(host.get_target_camera_state(), host.get_current_camera_state())
		for host : GoCamera2DHost in _physics_hosts:
			foo.call(host.get_target_camera_state(), host.get_current_camera_state())
		for host : GoCamera2DHost in _manual_hosts:
			foo.call(host.get_target_camera_state(), host.get_current_camera_state())
#endregion


#region Private Methods (Layer Registers)
func _subscribe_layer(layer : GoCamera2DLayer) -> void:
	_toggle_layer(layer, false)
func _unsubscribe_layer(layer : GoCamera2DLayer) -> void:
	_toggle_layer(layer, true)
#endregion


#region Public Methods (Layer Registers)
func register_layer(layer : GoCamera2DLayer) -> void:
	if is_layer_registered(layer):
		return
	_layer_manager.register_layer(layer)
	
	layer.connect(
		CONSTANTS.INTERAL_SUBSCRIBE, _subscribe_layer
	)
	layer.connect(
		CONSTANTS.INTERAL_UNSUBSCRIBE, _unsubscribe_layer
	)
func unregister_layer(layer : GoCamera2DLayer) -> void:
	if !is_layer_registered(layer):
		return
	_layer_manager.unregister_layer(layer)
	
	layer.disconnect(
		CONSTANTS.INTERAL_SUBSCRIBE, _subscribe_layer
	)
	layer.disconnect(
		CONSTANTS.INTERAL_UNSUBSCRIBE, _unsubscribe_layer
	)


func is_layer_subscribed(layer : GoCamera2DLayer) -> bool:
	return _layer_manager.is_layer_subscribed(layer)
func is_layer_registered(layer : GoCamera2DLayer) -> bool:
	return _layer_manager.is_layer_registered(layer)
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


#region Public Methods (Accessors)
func get_running_transitions() -> Array[GoCamera2DLayer]:
	return _layer_manager.get_running_transitions()
func get_running_effects() -> Array[GoCamera2DLayer]:
	return _layer_manager.get_running_effects()

func get_all_hosts() -> Array[GoCamera2DHost]:
	var ret := (_idle_hosts + _physics_hosts)
	ret.append_array(_manual_hosts)
	return ret
#endregion
