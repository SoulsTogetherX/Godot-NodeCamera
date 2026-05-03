# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
@tool
extends Node

#region Private Variables
var _top_level_storage := NodeCamera2DLayerStorage.new()

var _process_hosts : Array[NodeCamera2DHostExecutionScope]
var _physics_hosts : Array[NodeCamera2DHostExecutionScope]

#		Dictionary[NodeCamera2DHost, Array[NodeCamera2DHostExecutionScope]
var _scope_array_by_host : Dictionary[NodeCamera2DHost, Array]
#endregion



#region Virtual Methods (Engine)
func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		_top_level_storage.free()
#endregion


#region Private Methods (Tick Hosts)
func _process_tick() -> void:
	for scope : NodeCamera2DHostExecutionScope in _process_hosts:
		scope.run_tick()
func _physics_tick() -> void:
	for scope : NodeCamera2DHostExecutionScope in _physics_hosts:
		scope.run_tick()

func _update_ticks() -> void:
	var process := get_tree().process_frame
	var physics := get_tree().physics_frame
	
	if _process_hosts.is_empty():
		if process.is_connected(_process_tick):
			process.disconnect(_process_tick)
	elif !process.is_connected(_process_tick):
		process.connect(_process_tick)
	
	if _physics_hosts.is_empty():
		if physics.is_connected(_physics_tick):
			physics.disconnect(_physics_tick)
	elif !physics.is_connected(_physics_tick):
		physics.connect(_physics_tick)
#endregion


#region Private Methods (Updating Hosts)
func _insert_host_callback(host : NodeCamera2DHost) -> void:
	match host.callback_mode:
		NodeCamera2DHost.CALLBACK_MODES.PHYSICS:
			_scope_array_by_host[host] = _physics_hosts
			_physics_hosts.append(host._scope)
		NodeCamera2DHost.CALLBACK_MODES.IDLE:
			_scope_array_by_host[host] = _process_hosts
			_process_hosts.append(host._scope)

func _host_update_callback(host : NodeCamera2DHost) -> void:
	if host._scope in _scope_array_by_host:
		_scope_array_by_host[host].erase(host._scope)
	_insert_host_callback(host)
func _host_update_mask(host : NodeCamera2DHost) -> void:
	host.get_scope().flag_structure_changed()
#endregion


#region Public Methods (Register Host)
func register_host(host : NodeCamera2DHost) -> void:
	if is_host_registered(host):
		return
	
	host.callback_mode_changed.connect(
		_host_update_callback, CONNECT_APPEND_SOURCE_OBJECT | CONNECT_DEFERRED
	)
	host.camera_mask_changed.connect(
		_host_update_mask, CONNECT_APPEND_SOURCE_OBJECT
	)
	_insert_host_callback(host)
	
	host.get_scope().flag_construct_scope()
	_update_ticks()
	host.activate.emit()
func unregister_host(host : NodeCamera2DHost) -> void:
	if !is_host_registered(host):
		return
	
	host.callback_mode_changed.disconnect(
		_host_update_callback
	)
	host.camera_mask_changed.disconnect(
		_host_update_mask
	)
	if host in _scope_array_by_host:
		_scope_array_by_host[host].erase(host._scope)
		_scope_array_by_host.erase(host)
	
	host.get_scope().flag_clear_scope()
	_update_ticks()
	host.deactivate.emit()

func is_host_registered(host : NodeCamera2DHost) -> bool:
	return host.callback_mode_changed.is_connected(
		_host_update_callback
	)
#endregion


#region Public Methods (Register Host)
func register_layer(layer : NodeCamera2DLayer) -> void:
	_top_level_storage.register_layer(layer)
func unregister_layer(layer : NodeCamera2DLayer) -> void:
	_top_level_storage.unregister_layer(layer)
#endregion


#region Public Methods (Accessor)
func get_hosts() -> Array[NodeCamera2DHost]:
	return _scope_array_by_host.keys()
func get_layer_storage() -> NodeCamera2DLayerStorage:
	return _top_level_storage
#endregion

# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
