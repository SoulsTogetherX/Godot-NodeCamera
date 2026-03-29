@tool
extends Node


#region Constants
const CONSTANTS := preload("uid://b8t21yw0evfx")
#endregion


#region Private Variables
var _running_effects : Array[GoCamera2DEffect] = []

var _idle_hosts : Array[GoCamera2DHost] = []
var _physics_hosts : Array[GoCamera2DHost] = []
var _manual_hosts : Array[GoCamera2DHost] = []
#endregion



#region Private Methods (Priority Update)
func _effect_priority_changed(effect : GoCamera2DEffect) -> void:
	_running_effects.erase(effect)
	_sorted_effect_append(effect)
func _sorted_effect_append(effect : GoCamera2DEffect) -> void:
	var idx := _running_effects.bsearch_custom(effect, _priority_comparison, false)
	_running_effects.insert(idx, effect)
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

func _update_effect_tick(effect : GoCamera2DEffect) -> void:
	if effect.is_registered() && effect.process_tick_needed():
		if !_running_effects.has(effect):
			if !effect.is_connected(
				CONSTANTS.INTERAL_PRIORITY_CHANGED, _effect_priority_changed
			):
				effect.connect(
					CONSTANTS.INTERAL_PRIORITY_CHANGED, _effect_priority_changed
				)
			_sorted_effect_append(effect)
		return
	
	if effect.is_connected(
		CONSTANTS.INTERAL_PRIORITY_CHANGED, _effect_priority_changed
	):
		effect.disconnect(
			CONSTANTS.INTERAL_PRIORITY_CHANGED, _effect_priority_changed
		)
	_running_effects.erase(effect)
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

func _priority_comparison(l1 : GoCamera2DLayer, l2 : GoCamera2DLayer) -> bool:
	return l1.priority < l2.priority
#endregion


#region Methods (Process Callbacks)
func _on_idle() -> void:
	for host : GoCamera2DHost in _idle_hosts:
		_tick_host(host)
func _on_physics_process() -> void:
	for host : GoCamera2DHost in _physics_hosts:
		_tick_host(host)

func _tick_host(host : GoCamera2DHost) -> void:
	var cam := host.get_camera()
	var state := host.get_target_camera_state()
	
	for effect : GoCamera2DEffect in _running_effects:
		effect.process_tick(state)
	
	cam.position = state.position
	cam.offset = state.offset
	cam.zoom = state.zoom
	cam.rotation = state.rotation

func tick_all_manual_hosts() -> void:
	for host : GoCamera2DHost in _manual_hosts:
		_tick_host(host)
#endregion


#region Public Methods (Layer Register)
func register_effect(effect : GoCamera2DEffect) -> void:
	if is_effect_registered(effect):
		return
	effect.connect(
		CONSTANTS.INTERAL_TICK_CHANGED, _update_effect_tick
	)
	_update_effect_tick(effect)
func unregister_effect(effect : GoCamera2DEffect) -> void:
	if !is_effect_registered(effect):
		return
	effect.disconnect(
		CONSTANTS.INTERAL_TICK_CHANGED, _update_effect_tick
	)
	_update_effect_tick(effect)

func is_effect_registered(effect : GoCamera2DEffect) -> bool:
	return effect.is_connected(
		CONSTANTS.INTERAL_TICK_CHANGED, _update_effect_tick
	)
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
