# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
@tool
@icon("uid://gs4cuiaqel64")
class_name NodeCameraGroup extends NodeCameraLayer
## A [NodeCameraLayer] node that facilitates a unique [NodeCameraExecutionScope]
## and registers all child [NodeCameraLayer] nodes within it.

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


#region Virtual Methods (Overwritable)
## This is a [color=#D6D000][b]Runtime Method[/b][/color]. All
## [color=#D6D000][b]Runtime Method[/b][/color] requiring methods can be
## called within this method.
## [br][br]
## This method calls all registered effects.
func process_effect(
	delta : float, target : NodeCameraState, _stage : LAYER_STAGES
) -> void:
	_scope.run_effects(delta, target)

## This is a [color=#D6D000][b]Runtime Method[/b][/color]. All
## [color=#D6D000][b]Runtime Method[/b][/color] requiring methods can be
## called within this method.
## [br][br]
## This method calls all registered transitions.
func process_transition(
	delta : float, target : NodeCameraState, current : NodeCameraState,
	_stage : LAYER_STAGES
) -> void:
	_scope.run_transitions(delta, target, current)
#endregion


#region Virtual Methods (Register)
## Call this method to register [param layer] to this [NodeCameraGroup].
## [br][br]
## Also see [method get_layer_storage].
func register_layer(layer : NodeCameraLayer) -> void:
	_layer_storage.register_layer(layer)
	if _layer_storage.size() == 1 && !disabled:
		_register()
## Call this method to unregister [param layer] to this [NodeCameraGroup].
## [br][br]
## Also see [method get_layer_storage].
func unregister_layer(layer : NodeCameraLayer) -> void:
	_layer_storage.unregister_layer(layer)
	if _layer_storage.is_empty() && !disabled:
		_unregister()
#endregion


#region Accessor Methods
## Returns the layer storage used by this node.
## [br][br]
## [b]NOTE[/b]: Freeing this may cause an engine to crash.
## [br][br]
## Also see [method get_layer_storage].
func get_layer_storage() -> NodeCameraLayerStorage:
	return _layer_storage
#endregion

# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
