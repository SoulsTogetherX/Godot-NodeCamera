# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
@tool
class_name NodeCameraRoutable extends NodeCameraGroup
##

#region Private Methods
var _cached_routed_layers : Array[NodeCameraLayer]
#endregion


#region Virtual Methods
func _notification(what: int) -> void:
	if what == NOTIFICATION_READY:
		(func():
			_cached_routed_layers = _route_to_layers()
		).call_deferred()
#endregion


#region Routing Methods
## 
func _route_to_layers() -> Array[NodeCameraLayer]:
	return []

## 
func flag_route_layers_changed() -> void:
	if (
		!without_parent_scopes() &&
		_vaild_route(self, (get_parent() as NodeCameraGroup))
	):
		_direct_route_changed()
		return
	_cached_routed_layers = _route_to_layers()
	
	var parent_layer : NodeCameraGroup = null
	var layer : NodeCameraGroup = self
	while layer != null:
		parent_layer = (layer.get_parent() as NodeCameraGroup)
		if !_vaild_route(layer, parent_layer):
			return
		
		# Always breaks before reaching a host execution scope
		if !layer.without_parent_scopes():
			break
		layer = parent_layer
	
	for scope : NodeCameraExecutionScope in layer._parent_scopes:
		scope.flag_overwrite_stage(layer, LAYER_STAGES.STARTING)

func _direct_route_changed() -> void:
	var implemented_scopes : Array[NodeCameraExecutionScope]
	for scope : NodeCameraExecutionScope in _parent_scopes:
		var record := scope.get_record(self)
		if record == null:
			scope.flag_add_layer(self)
			continue
		implemented_scopes.append(record.scope)
	
	if implemented_scopes.is_empty():
		return
	
	var new_layers := _route_to_layers()
	var unique_old : Array[NodeCameraLayer] = _cached_routed_layers.filter(
		func(l : NodeCameraLayer):
			return !new_layers.has(l)
	)
	var unique_new : Array[NodeCameraLayer] = new_layers.filter(
		func(l : NodeCameraLayer):
			return !_cached_routed_layers.has(l)
	)
	_cached_routed_layers = new_layers
	
	for scope : NodeCameraExecutionScope in implemented_scopes:
		for old : NodeCameraLayer in unique_old:
			var record := scope.get_record(old)
			if record:
				scope.flag_advance_to_stage(old, LAYER_STAGES.ENDING)
		for new : NodeCameraLayer in unique_new:
			scope.flag_overwrite_stage(new, LAYER_STAGES.STARTING)

func _vaild_route(
	layer : NodeCameraLayer, parent_layer : NodeCameraGroup
) -> bool:
	return (
		!(parent_layer is NodeCameraRoutable) ||
		layer in parent_layer._route_to_layers()
	)
#endregion

# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
