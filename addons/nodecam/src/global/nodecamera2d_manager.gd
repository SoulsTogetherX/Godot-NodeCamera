# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
@tool
extends Node
## The primary singleton for the NodeCamera2D addon, used to manage all top-level
## [NodeCamera2DLayer]s. 


#region Constants
## The script containing all shared constants used by the NodeCamera2D addon.
const CONSTANTS := preload("uid://b8t21yw0evfx")
#endregion


#region Private Variables
var _layer_manager := NodeCamera2DLayerGlobalManager.new()

var _idle_hosts : Array[NodeCamera2DHost]
var _physics_hosts : Array[NodeCamera2DHost]
var _manual_hosts : Array[NodeCamera2DHost]
#endregion



#region Virtual Methods
func _init() -> void:
	_layer_manager.layer_activated.connect(layer_tick_start)
	_layer_manager.layer_deactivated.connect(layer_tick_end)
	
	_layer_manager.layer_mask_changed.connect(_layer_camera_mask_changed)
#endregion


#region Methods (Updaters)
func _layer_camera_mask_changed(
	old : int, layer : NodeCamera2DLayer
) -> void:
	if !layer.is_running():
		return
	
	var new := layer.get_camera_flag_mask()
	var helper := func(host : NodeCamera2DHost):
		if (host.camera_flag_mask & old) && !(host.camera_flag_mask & new):
			_layer_manager.force_end_layer(
				layer, host.get_target_status(), host.get_current_status()
			)
		elif (host.camera_flag_mask & new) && !(host.camera_flag_mask & old):
			_layer_manager.force_start_layer(
				layer, host.get_target_status(), host.get_current_status()
			)
	
	_call_on_all_hosts(helper)
func _host_camera_mask_changed(
	old : int, host : NodeCamera2DHost
) -> void:
	var new := host.get_camera_flag_mask()
	
	for layer : NodeCamera2DLayer in _layer_manager.get_active_layers():
		if (layer.camera_flag_mask & old) && !(layer.camera_flag_mask & new):
			_layer_manager.force_end_layer(
				layer, host.get_target_status(), host.get_current_status()
			)
		elif (layer.camera_flag_mask & new) && !(layer.camera_flag_mask & old):
			_layer_manager.force_start_layer(
				layer, host.get_target_status(), host.get_current_status()
			)

func _host_callback_changed(
	old : CONSTANTS.CALLBACK_MODES, host : NodeCamera2DHost
) -> void:
	_get_cache(old).erase(host)
	_get_cache(host.callback).append(host)
	_update_tick_callbacks()

func _update_tick_callbacks() -> void:
	var process_sig := get_tree().process_frame
	var physics_sig := get_tree().physics_frame
	
	if _layer_manager.get_queued_effects().is_empty():
		if process_sig.is_connected(_idle_tick):
			process_sig.disconnect(_idle_tick)
		if physics_sig.is_connected(_physics_tick):
			physics_sig.disconnect(_physics_tick)
		return
	
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
## Calls the appropriate 'layer_start' method ([method NodeCamera2DEffect.start_effect],
## [method NodeCamera2DTransition.start_transition], or
## [method NodeCamera2DGroup.start_group]), in the given [param layer],
## across all currently registered hosts. 
func layer_tick_start(layer : NodeCamera2DLayer) -> void:
	if _layer_manager.get_queued_effects().is_empty():
		_update_tick_callbacks.call_deferred()
	
	var helper := func(host : NodeCamera2DHost):
		if host.camera_flag_mask & layer.camera_flag_mask:
			_layer_manager.force_start_layer(
				layer, host.get_target_status(), host.get_current_status()
			)
	_call_on_all_hosts(helper)


## Calls the appropriate 'layer_start' method ([method NodeCamera2DEffect.end_effect],
## [method NodeCamera2DTransition.end_transition], or
## [method NodeCamera2DGroup.end_group]), in the given [param layer],
## across all currently registered hosts.
func layer_tick_end(layer : NodeCamera2DLayer) -> void:
	if _layer_manager.get_queued_effects().size() == 1:
		_update_tick_callbacks.call_deferred()
	
	var helper := func(host : NodeCamera2DHost):
		if host.camera_flag_mask & layer.camera_flag_mask:
			_layer_manager.force_end_layer(
				layer, host.get_target_status(), host.get_current_status()
			)
	_call_on_all_hosts(helper)
#endregion


#region Methods (Tick Callbacks)
func _idle_tick() -> void:
	var delta := get_process_delta_time()
	for host : NodeCamera2DHost in _idle_hosts:
		tick_host(host, delta)
func _physics_tick() -> void:
	var delta := get_physics_process_delta_time()
	for host : NodeCamera2DHost in _physics_hosts:
		tick_host(host, delta)

## Ticks all relevant layers with the information of all hosts,
## whose [member NodeCamera2DHost.callback] is set to
## [constant NodeCamera2DHost.CONSTANTS.CALLBACK_MODES.MANUAL].
func manually_tick_hosts() -> void:
	for host : NodeCamera2DHost in _manual_hosts:
		tick_host(host, 0.0)

## Ticks all relevant layers with the information of the given
## [param hosts].
func tick_host(host : NodeCamera2DHost, delta : float) -> void:
	var cam := host.get_camera()
	var target_status := host.get_target_status()
	target_status._cached_delta = delta
	
	_layer_manager._effect_tick(target_status, host.camera_flag_mask)
	if _layer_manager.get_queued_transitions().is_empty():
		target_status.apply_status(cam)
		return
	
	var current_status := host.get_target_status()
	current_status._cached_delta = delta
	_layer_manager._transition_tick(
		target_status, current_status, host.camera_flag_mask
	)
	current_status.apply_status(cam)
#endregion


#region Methods (Register Host)
## Registers the given [param host] into management.
## [br][br]
## [b]NOTE[/b]: Registering a host while a relevant [NodeCamera2DLayer]
## is running will not call the [NodeCamera2DLayer]'s relevant
## 'layer_start' method ([method NodeCamera2DEffect.end_effect],
## [method NodeCamera2DTransition.end_transition], or
## [method NodeCamera2DGroup.end_group]).
func register_host(host : NodeCamera2DHost) -> void:
	if is_host_registered(host):
		return
	host.reset_cam()
	host.camera_mask_changed.connect(
		_host_camera_mask_changed,
		CONNECT_APPEND_SOURCE_OBJECT
	)
	host.callback_changed.connect(
		_host_callback_changed,
		CONNECT_APPEND_SOURCE_OBJECT
	)
	
	_get_cache(host.callback).append(host)
	_update_tick_callbacks()
## Unregisters the given [param host] into management.
## [br][br]
## [b]NOTE[/b]: Registering a host while a relevant [NodeCamera2DLayer]
## is running will not call the [NodeCamera2DLayer]'s relevant
## 'layer_end' method ([method NodeCamera2DEffect.end_effect],
## [method NodeCamera2DTransition.end_transition], or
## [method NodeCamera2DGroup.end_group]).
func unregister_host(host : NodeCamera2DHost) -> void:
	if !is_host_registered(host):
		return
	host.camera_mask_changed.disconnect(
		_host_camera_mask_changed
	)
	host.callback_changed.disconnect(
		_host_callback_changed
	)
	
	_get_cache(host.callback).erase(host)
	_update_tick_callbacks()

## Returns if the given [param host] has been registered.
func is_host_registered(host : NodeCamera2DHost) -> bool:
	return host.callback_changed.is_connected(
		_host_callback_changed
	)
#endregion


#region Methods (Helpers)
func _get_cache(callback : CONSTANTS.CALLBACK_MODES) -> Array[NodeCamera2DHost]:
	match callback:
		CONSTANTS.CALLBACK_MODES.IDLE:
			return _idle_hosts
		CONSTANTS.CALLBACK_MODES.PHYSICS:
			return _physics_hosts
		CONSTANTS.CALLBACK_MODES.MANUAL:
			return _manual_hosts
	return []

func _call_on_all_hosts(foo : Callable) -> void:
	for host : NodeCamera2DHost in _idle_hosts:
		foo.call(host)
	for host : NodeCamera2DHost in _physics_hosts:
		foo.call(host)
	for host : NodeCamera2DHost in _manual_hosts:
		foo.call(host)

## Gets the current [NodeCamera2DLayerManager] being used.
## [br][br]
## [b]NOTE[/b]: Freeing this object will cause errors.
func get_layer_manager() -> NodeCamera2DLayerManager:
	return _layer_manager
#endregion

# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
