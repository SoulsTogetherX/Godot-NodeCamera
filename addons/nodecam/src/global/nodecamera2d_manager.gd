# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
@tool
extends Node

#region Private Variables
var _top_level_layers : Array[NodeCamera2DLayer] = []
var _mask_by_layer: Dictionary[NodeCamera2DLayer, int]

var _process_hosts : Array[NodeCamera2DHostContext]
var _physics_hosts : Array[NodeCamera2DHostContext]

var _context_array_by_host : Dictionary[NodeCamera2DHost, Array]
#endregion



#region Private Methods (Tick Hosts)
func _process_tick() -> void:
	for ctx : NodeCamera2DHostContext in _process_hosts:
		ctx.run_tick()
func _physics_tick() -> void:
	for ctx : NodeCamera2DHostContext in _physics_hosts:
		ctx.run_tick()

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
		NodeCamera2DConstants.CALLBACK_MODES.PHYSICS:
			_context_array_by_host[host] = _physics_hosts
			_physics_hosts.append(host._context)
		NodeCamera2DConstants.CALLBACK_MODES.IDLE:
			_context_array_by_host[host] = _process_hosts
			_process_hosts.append(host._context)

func _host_update_callback(host : NodeCamera2DHost) -> void:
	if host._context in _context_array_by_host:
		_context_array_by_host[host].erase(host._context)
	_insert_host_callback(host)
func _host_update_mask(host : NodeCamera2DHost) -> void:
	host.get_scope().flag_structure_changed()
#endregion


#region Private Methods (Updating Layers)
func _layer_changed_mask(layer : NodeCamera2DLayer) -> void:
	var old_mask := _mask_by_layer[layer]
	var new_mask := layer.camera_mask
	var mask_diff := old_mask ^ new_mask
	_mask_by_layer[layer] = layer.camera_mask
	
	for host : NodeCamera2DHost in _context_array_by_host.keys():
		if mask_diff & host.camera_mask:
			if new_mask & host.camera_mask:
				host.get_scope().flag_layer_add(layer)
				continue
			host.get_scope().flag_layer_remove(layer)

func _layer_changed_add(layer : NodeCamera2DLayer) -> void:
	for host : NodeCamera2DHost in _context_array_by_host.keys():
		if layer.camera_mask & host.camera_mask:
			host.get_scope().flag_layer_add(layer)
func _layer_changed_remove(layer : NodeCamera2DLayer) -> void:
	for host : NodeCamera2DHost in _context_array_by_host.keys():
		if layer.camera_mask & host.camera_mask:
			host.get_scope().flag_layer_remove(layer)
func _layer_changed_priority(layer : NodeCamera2DLayer) -> void:
	for host : NodeCamera2DHost in _context_array_by_host.keys():
		if layer.camera_mask & host.camera_mask:
			host.get_scope().flag_layer_reorder(layer)
#endregion


#region Public Methods (Register Layer)
func register_layer(layer : NodeCamera2DLayer) -> void:
	if is_layer_registered(layer):
		return
	
	layer.camera_mask_changed.connect(
		_layer_changed_mask, CONNECT_APPEND_SOURCE_OBJECT
	)
	layer.priority_changed.connect(
		_layer_changed_priority, CONNECT_APPEND_SOURCE_OBJECT
	)
	
	_layer_changed_add(layer)
	_top_level_layers.append(layer)
	
	_mask_by_layer[layer] = layer.camera_mask
	layer.activated.emit()
func unregister_layer(layer : NodeCamera2DLayer) -> void:
	if !is_layer_registered(layer):
		return
	
	layer.camera_mask_changed.disconnect(
		_layer_changed_mask
	)
	layer.priority_changed.disconnect(
		_layer_changed_priority
	)
	
	_layer_changed_remove(layer)
	# Removes the layer, without preserving order.
	var idx := _top_level_layers.find(layer)
	var val := _top_level_layers.pop_back()
	if idx != _top_level_layers.size():
		_top_level_layers[idx] = val
	
	_mask_by_layer.erase(layer)
	layer.deactivated.emit()

func is_layer_registered(layer : NodeCamera2DLayer) -> bool:
	return layer.camera_mask_changed.is_connected(
		_layer_changed_mask
	)
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
	
	host.get_scope().flag_structure_changed()
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
	if host in _context_array_by_host:
		_context_array_by_host[host].erase(host._context)
		_context_array_by_host.erase(host)
	
	host.get_scope().flag_clear_layers()
	_update_ticks()
	host.deactivate.emit()

func is_host_registered(host : NodeCamera2DHost) -> bool:
	return host.callback_mode_changed.is_connected(
		_host_update_callback
	)
#endregion


#region Public Methods (Accessor)
func get_top_level_layers() -> Array[NodeCamera2DLayer]:
	return _top_level_layers
func get_hosts() -> Array[NodeCamera2DHost]:
	return _context_array_by_host.keys()
#endregion

# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
