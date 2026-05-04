# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
@tool
extends Node

#region Private Variables
var _top_level_storage := NodeCameraLayerStorage.new()

var _process_hosts : Array[NodeCameraHostExecutionScope]
var _physics_hosts : Array[NodeCameraHostExecutionScope]

#		Dictionary[NodeCameraHost, Array[NodeCamera2DstExecutionScope]
var _scope_array_by_host : Dictionary[NodeCameraHost, Array]
#endregion



#region Virtual Methods (Engine)
func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		_top_level_storage.free()
#endregion


#region Private Methods (Tick Hosts)
func _process_tick() -> void:
	for scope : NodeCameraHostExecutionScope in _process_hosts:
		scope.run_tick()
func _physics_tick() -> void:
	for scope : NodeCameraHostExecutionScope in _physics_hosts:
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
func _insert_host_callback(host : NodeCameraHost) -> void:
	if host.callback_mode == NodeCameraHost.CALLBACK_MODES.MANUAL:
		return
	
	var queue : Array[NodeCameraHostExecutionScope]
	match host.callback_mode:
		NodeCameraHost.CALLBACK_MODES.PHYSICS:
			queue = _physics_hosts
		NodeCameraHost.CALLBACK_MODES.IDLE:
			queue = _process_hosts
		NodeCameraHost.CALLBACK_MODES.MANUAL:
			var cam := host.get_camera()
			if cam is Camera2D:
				match (cam as Camera2D).process_callback:
					Camera2D.Camera2DProcessCallback.CAMERA2D_PROCESS_PHYSICS:
						queue = _physics_hosts
					Camera2D.Camera2DProcessCallback.CAMERA2D_PROCESS_IDLE:
						queue = _process_hosts
			else:
				queue = _physics_hosts
	
	_scope_array_by_host[host] = queue
	queue.append(host._scope)

func _host_update_callback(host : NodeCameraHost) -> void:
	if host._scope in _scope_array_by_host:
		_scope_array_by_host[host].erase(host._scope)
	_insert_host_callback(host)
func _host_update_mask(host : NodeCameraHost) -> void:
	host.get_scope().flag_structure_changed()
#endregion


#region Public Methods (Register Host)
func register_host(host : NodeCameraHost) -> void:
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
func unregister_host(host : NodeCameraHost) -> void:
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

func is_host_registered(host : NodeCameraHost) -> bool:
	return host.callback_mode_changed.is_connected(
		_host_update_callback
	)
#endregion


#region Public Methods (Register Host)
func register_layer(layer : NodeCameraLayer) -> void:
	_top_level_storage.register_layer(layer)
func unregister_layer(layer : NodeCameraLayer) -> void:
	_top_level_storage.unregister_layer(layer)
#endregion


#region Public Methods (Tick Host)
func tick_host_scope(scope : NodeCameraHostExecutionScope) -> void:
	scope.run_tick()
#endregion


#region Public Methods (Accessor)
func get_hosts() -> Array[NodeCameraHost]:
	return _scope_array_by_host.keys()
func get_layer_storage() -> NodeCameraLayerStorage:
	return _top_level_storage
#endregion

# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
