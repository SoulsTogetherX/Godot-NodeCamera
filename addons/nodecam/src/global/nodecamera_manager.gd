# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
@tool
extends Node
## The main singleton in charge of registering [NodeCameraHost]s, storing
## top-level [NodeCameraLayer]s, and executing/clearing
## [NodeCameraHostExecutionScope]s.

#region Private Variables
var _top_level_storage := NodeCameraLayerStorage.new()

var _process_hosts : Array[NodeCameraHostExecutionScope]
var _physics_hosts : Array[NodeCameraHostExecutionScope]

#		Dictionary[NodeCameraHost, Array[NodeCamera2DstExecutionScope]
var _scope_array_by_host : Dictionary[NodeCameraHost, Array]
#endregion



#region Virtual Methods (Engine)
func _init() -> void:
	process_priority = 99999999999
	process_physics_priority = 99999999999

func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		_top_level_storage.free()
#endregion


#region Global Methods (Helper)
## Returns if [param parent_layer] is currently routing to the child
## layer [param layer]. Only works for direct pairings. Used internally.
func vaild_route(
	parent_layer : NodeCameraGroup, layer : NodeCameraLayer
) -> bool:
	return (
		(layer.camera_mask & parent_layer.camera_mask) &&
		layer._parent_group == parent_layer &&
		(
			!(parent_layer is NodeCameraRoutable) ||
			parent_layer._route_to_layers().has(layer)
		)
	)
#endregion


#region Private Methods (Tick Hosts)
func _process_tick() -> void:
	var delta := get_process_delta_time()
	for scope : NodeCameraHostExecutionScope in _process_hosts:
		scope.run_tick(delta)
		scope.run_defered_methods()
func _physics_tick() -> void:
	var delta := get_physics_process_delta_time()
	for scope : NodeCameraHostExecutionScope in _physics_hosts:
		scope.run_tick(delta)
		scope.run_defered_methods()

func _update_ticks() -> void:
	var process := get_tree().process_frame
	var physics := get_tree().physics_frame
	
	if _process_hosts.is_empty():
		if process.is_connected(_process_tick):
			process.disconnect(_process_tick)
	elif !process.is_connected(_process_tick):
		process.connect(_process_tick, CONNECT_DEFERRED)
	
	if _physics_hosts.is_empty():
		if physics.is_connected(_physics_tick):
			physics.disconnect(_physics_tick)
	elif !physics.is_connected(_physics_tick):
		physics.connect(_physics_tick, CONNECT_DEFERRED)
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
	_update_ticks()

func _host_update_callback(host : NodeCameraHost) -> void:
	if _scope_array_by_host.has(host):
		_scope_array_by_host[host].erase(host._scope)
	_insert_host_callback(host)
func _host_update_mask(host : NodeCameraHost) -> void:
	host.get_scope().flag_construct_scope()
#endregion


#region Public Methods (Register Host)
## Registers and sets up [param host] to be processed according to
## the available top-level [NodeCameraLayer]s.
func register_host(host : NodeCameraHost) -> void:
	if is_host_registered(host):
		return
	
	host.callback_mode_changed.connect(
		_host_update_callback, CONNECT_APPEND_SOURCE_OBJECT | CONNECT_DEFERRED
	)
	host.camera_mask_changed.connect(
		_host_update_mask, CONNECT_APPEND_SOURCE_OBJECT
	)
	
	host.get_scope().flag_construct_scope()
	_insert_host_callback(host)
	host.activate.emit()
## Unregisters [param host] and clears their [NodeCameraHostExecutionScope].
func unregister_host(host : NodeCameraHost) -> void:
	if !is_host_registered(host):
		return
	
	host.callback_mode_changed.disconnect(
		_host_update_callback
	)
	host.camera_mask_changed.disconnect(
		_host_update_mask
	)
	if _scope_array_by_host.has(host):
		_scope_array_by_host[host].erase(host._scope)
		_scope_array_by_host.erase(host)
	
	host.get_scope().flag_clear_scope()
	_update_ticks()
	host.deactivate.emit()

## Returns if [param host] has been registered.
func is_host_registered(host : NodeCameraHost) -> bool:
	return _scope_array_by_host.has(host)
#endregion


#region Public Methods (Register Host)
## Registers [param layer] has a top-level layer.
## [br][br]
## [b]NOTE[/b]: Attempting to register a non-top level layer as one can
## cause an infinite loop.
func register_layer(layer : NodeCameraLayer) -> void:
	_top_level_storage.register_layer(layer)
## Unregisters [param layer] has a top-level layer.
func unregister_layer(layer : NodeCameraLayer) -> void:
	_top_level_storage.unregister_layer(layer)

## Returns if [param layer] has been registered as top-level.
func is_layer_registered(layer : NodeCameraLayer) -> bool:
	return _top_level_storage.is_layer_registered(layer)
#endregion


#region Accessor Methods
## Returns an array of all registered [NodeCameraHost]s.
func get_hosts() -> Array[NodeCameraHost]:
	return _scope_array_by_host.keys()

## Returns the [NodeCameraLayerStorage] holding on top-level layers.
## [br][br]
## [b]NOTE[/b]: Freeing this may cause an engine crash.
func get_layer_storage() -> NodeCameraLayerStorage:
	return _top_level_storage
#endregion

# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
