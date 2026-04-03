@tool
extends Node


#region Constants
const CONSTANTS := preload("uid://b8t21yw0evfx")
#endregion


#region Private Variables
var _layer_manager := GoCamera2DLayerGlobalManager.new()

var _idle_hosts : Array[GoCamera2DHost]
var _physics_hosts : Array[GoCamera2DHost]
var _manual_hosts : Array[GoCamera2DHost]
#endregion



#region Virtual Methods
func _init() -> void:
	_layer_manager.layer_start.connect(_layer_tick_start)
	_layer_manager.layer_end.connect(_layer_tick_end)
#endregion


#region Methods (Updaters)
func _host_callback_changed(
	host : GoCamera2DHost, old : CONSTANTS.CALLBACK_MODES
) -> void:
	_get_cache(old).erase(host)
	_get_cache(host.callback).append(host)
	_update_tick_callbacks()

func _update_tick_callbacks() -> void:
	var process_sig := get_tree().process_frame
	var physics_sig := get_tree().physics_frame
	
	if _idle_hosts.is_empty():
		if process_sig.is_connected(_idle_tick):
			process_sig.disconnect(_idle_tick)
	elif !process_sig.is_connected(_idle_tick):
		process_sig.connect(_idle_tick)
	
	if _physics_hosts.is_empty():
		if physics_sig.is_connected(_physics_tick):
			physics_sig.disconnect(_physics_tick)
	elif !physics_sig.is_connected(_physics_tick):
		physics_sig.connect(_physics_tick)
#endregion


#region Methods (Tick Intermediates)
func _layer_tick_start(layer : GoCamera2DLayer) -> void:
	for host : GoCamera2DHost in _idle_hosts:
		_layer_manager.layer_tick_start(layer, host)
	for host : GoCamera2DHost in _physics_hosts:
		_layer_manager.layer_tick_start(layer, host)
	for host : GoCamera2DHost in _manual_hosts:
		_layer_manager.layer_tick_start(layer, host)

func _layer_tick_end(layer : GoCamera2DLayer) -> void:
	for host : GoCamera2DHost in _idle_hosts:
		_layer_manager.layer_tick_end(layer, host)
	for host : GoCamera2DHost in _physics_hosts:
		_layer_manager.layer_tick_end(layer, host)
	for host : GoCamera2DHost in _manual_hosts:
		_layer_manager.layer_tick_end(layer, host)
#endregion


#region Methods (Tick Callbacks)
func _idle_tick() -> void:
	for host : GoCamera2DHost in _idle_hosts:
		tick_host(host)
func _physics_tick() -> void:
	for host : GoCamera2DHost in _physics_hosts:
		tick_host(host)
func manually_tick_hosts() -> void:
	for host : GoCamera2DHost in _manual_hosts:
		tick_host(host)

func tick_host(host : GoCamera2DHost) -> void:
	var cam := host.get_camera()
	var target_status := host.get_target_status()
	
	_layer_manager.effect_tick(target_status)
	if _layer_manager.without_queued_transitions():
		target_status.apply_status(cam)
		return
	
	var current_status := host.get_target_status()
	_layer_manager.transition_tick(target_status, current_status)
	current_status.apply_status(cam)
#endregion


#region Methods (Register Host)
func register_host(host : GoCamera2DHost) -> void:
	if is_host_registered(host):
		return
	host.connect(
		CONSTANTS.INTERAL_CALLBACK_CHANGED,
		_host_callback_changed
	)
	
	_get_cache(host.callback).append(host)
	_update_tick_callbacks()
func unregister_host(host : GoCamera2DHost) -> void:
	if !is_host_registered(host):
		return
	host.disconnect(
		CONSTANTS.INTERAL_CALLBACK_CHANGED,
		_host_callback_changed
	)
	
	_get_cache(host.callback).erase(host)
	_update_tick_callbacks()

func is_host_registered(host : GoCamera2DHost) -> bool:
	return host.is_connected(
		CONSTANTS.INTERAL_CALLBACK_CHANGED,
		_host_callback_changed
	)
#endregion


#region Methods (Helpers)
func _get_cache(callback : CONSTANTS.CALLBACK_MODES) -> Array[GoCamera2DHost]:
	match callback:
		CONSTANTS.CALLBACK_MODES.IDLE:
			return _idle_hosts
		CONSTANTS.CALLBACK_MODES.PHYSICS:
			return _physics_hosts
		CONSTANTS.CALLBACK_MODES.MANUAL:
			return _manual_hosts
	return []

func get_layer_manager() -> GoCamera2DLayerManager:
	return _layer_manager
#endregion
