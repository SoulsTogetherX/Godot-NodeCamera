# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
@tool
@icon("uid://gs4cuiaqel64")
class_name NodeCameraGroup extends NodeCameraLayer
## A [NodeCameraLayer] node able to be registered to by other layers.

#region Private Variables
var _layer_storage : NodeCameraLayerStorage
#endregion



#region Virtual Methods (Engine)
func _init() -> void:
	_layer_storage = NodeCameraLayerStorage.new()
func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		_layer_storage.free()
#endregion


#region Private Methods (Register)
func _register() -> void:
	if _layer_storage.is_empty():
		return
	super()
#endregion


#region Private Scope Methods
## Implement this method to return an array of [NodeCameraLayer] nodes
## that is used when this [NodeCameraGroup]'s [param scope] is first constructed.
func _get_allowed_layers(scope : NodeCameraExecutionScope) -> Array[NodeCameraLayer]:
	return scope.get_registered_layers()

## Implement this method to return if the given [param layer] should be added
## to the [NodeCameraGroup]'s [param scope]. This method is called for every
## addition, 
func _allow_layer(
	layer : NodeCameraLayer, scope : NodeCameraExecutionScope
) -> bool:
	return true

## Implement this method to return if this [NodeCameraGroup]'s [param scope]
## should automatically add new [NodeCameraLayer] when they are registered
## as children to this [NodeCameraGroup] layer. If you return [code]false[/code],
## make sure to use [method NodeCameraExecutionScope.flag_add_layer],
## [method NodeCameraExecutionScope.flag_advance_stage], and
## [method NodeCameraExecutionScope.flag_overwrite_stage] to add the layer.
## [br][br]
## Also see [method _allow_layer] and [method NodeCameraLayer.get_scope].
func _allow_auto_add() -> bool:
	return true
#endregion


#region Private Tick Methods
func _get_tick_mask(param_scope : NodeCameraExecutionScope) -> int:
	var mask := NodeCameraExecutionScope.TICK_TYPE.NONE
	
	if param_scope.has_effects():
		mask |= NodeCameraExecutionScope.TICK_TYPE.EFFECTS
	if param_scope.has_transitions():
		mask |= NodeCameraExecutionScope.TICK_TYPE.TRANSITIONS
	
	return mask
#endregion


#region Virtual Methods (Overwritable)
## This is a [color=#D6D000][b]Runtime Method[/b][/color]. All
## [color=#D6D000][b]Runtime Method[/b][/color] requiring methods can be
## called within this method, if overloaded.
## [br][br]
## This method calls all effects of the [NodeCameraGroup]'s current runtime
## scope.
func process_effect(
	delta : float, target : NodeCameraState, _stage : LAYER_STAGES
) -> void:
	_scope.run_effects(delta, target)

## This is a [color=#D6D000][b]Runtime Method[/b][/color]. All
## [color=#D6D000][b]Runtime Method[/b][/color] requiring methods can be
## called within this method, if overloaded.
## [br][br]
## This method calls all transitions of the [NodeCameraGroup]'s current runtime
## scope.
func process_transition(
	delta : float, target : NodeCameraState, current : NodeCameraState,
	_stage : LAYER_STAGES
) -> void:
	_scope.run_transitions(delta, target, current)
#endregion


#region Virtual Methods (Register)
## Call this method to register [param layer] to this [NodeCameraGroup], later
## attempted to add to all attached scopes for this [NodeCameraGroup].
## [br][br]
## Also see [method get_layer_storage], [method _get_allowed_layers],
## [method _allow_layer], and [method _allow_auto_add].
func register_layer(layer : NodeCameraLayer) -> void:
	_layer_storage.register_layer(layer)
	if _layer_storage.size() == 1 && !disabled:
		_register()
## Call this method to unregister [param layer] to this [NodeCameraGroup], later
## removed from all attached scopes for this [NodeCameraGroup].
## [br][br]
## Also see [method get_layer_storage].
func unregister_layer(layer : NodeCameraLayer) -> void:
	_layer_storage.unregister_layer(layer)
	if _layer_storage.is_empty() && !disabled:
		_unregister()
#endregion


#region Public Methods (Accessor)
## Returns the layer storage used by this node.
## [br][br]
## Also see [method get_layer_storage].
func get_layer_storage() -> NodeCameraLayerStorage:
	return _layer_storage
#endregion

# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
