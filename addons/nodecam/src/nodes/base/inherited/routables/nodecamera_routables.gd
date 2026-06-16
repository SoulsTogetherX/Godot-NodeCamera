# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
@tool
@abstract
class_name NodeCameraRoutable extends NodeCameraGroup
## An abstract [NodeCameraGroup] layer class used for selectively
## deactivating and reactivating child layers, via manipulating their stages.

#region External Variables
## The stage any layer will be overwriten as if routed to.
## [br][br]
## Also see [method NodeCameraExecutionScope.flag_overwrite_stage].
@export 
var start_stage : LAYER_STAGES = LAYER_STAGES.STARTING
## The stage any layer will be advanced to if routed away from.
## [br][br]
## Also see [method NodeCameraExecutionScope.flag_advance_to_stage].
@export 
var end_stage : LAYER_STAGES = LAYER_STAGES.ENDING
#endregion


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


#region Private Routing Methods
func _direct_route_changed() -> void:
	var new_layers := _route_to_layers()
	var implemented_scopes : Array[NodeCameraExecutionScope]
	
	for scope : NodeCameraExecutionScope in _parent_scopes:
		var record := scope.get_record(self)
		if record == null:
			scope.flag_overwrite_stage(self, start_stage)
			continue
		implemented_scopes.append(record.scope)
	
	if implemented_scopes.is_empty():
		_cached_routed_layers = new_layers
		return
	
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
			scope.flag_advance_to_stage(old, end_stage)
		for new : NodeCameraLayer in unique_new:
			scope.flag_overwrite_stage(new, start_stage)
#endregion


#region Routing Methods
## Implement this method to return a list of vaild [NodeCameraLayer]
## (children of the current node) that should be activated.
## [br][br]
## This will not be updated automatically. If changed, use
## [method flag_route_layers_changed] to flag this layer as dirty.
func _route_to_layers() -> Array[NodeCameraLayer]:
	return []

## Flags this [NodeCameraRoutable] to update the layers it's routing to.
## Only call if the layers returned by [method _route_to_layers] is
## expected to be different.
func flag_route_layers_changed() -> void:
	if !is_node_ready():
		push_warning("Calling 'flag_route_layers_changed' before ready can cause issues. Try call_deffered instead.")
	
	var layers := get_closest_active_layer_list()
	if layers.is_empty():
		return
	
	var layer := layers.back()
	if layer == self:
		_direct_route_changed()
		return
	for scope : NodeCameraExecutionScope in layer._parent_scopes:
		scope.flag_overwrite_stage(layer, start_stage)
#endregion

# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
