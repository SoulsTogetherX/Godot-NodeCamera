# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
@tool
@icon("uid://gs4cuiaqel64")
class_name NodeCameraGroup extends NodeCameraLayer

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


#region Tick Methods
func _get_tick_mask(param_scope : NodeCameraExecutionScope) -> int:
	var mask := NodeCameraExecutionScope.TICK_TYPE.NONE
	
	if param_scope.has_effects():
		mask |= NodeCameraExecutionScope.TICK_TYPE.EFFECTS
	if param_scope.has_transitions():
		mask |= NodeCameraExecutionScope.TICK_TYPE.TRANSITIONS
	
	return mask
#endregion


#region Virtual Methods (Overwritable)
func process_effect(
	target : NodeCameraState, _stage : LAYER_STAGES
) -> void:
	_scope.run_effects(target)

func process_transition(
	target : NodeCameraState, current : NodeCameraState,
	_stage : LAYER_STAGES
) -> void:
	_scope.run_transitions(target, current)
#endregion


#region Virtual Methods (Register)
func register_layer(layer : NodeCameraLayer) -> void:
	_layer_storage.register_layer(layer)
	if _layer_storage.size() == 1 && !disabled:
		_register()
func unregister_layer(layer : NodeCameraLayer) -> void:
	_layer_storage.unregister_layer(layer)
	if _layer_storage.is_empty() && !disabled:
		_unregister()
#endregion


#region Public Methods (Accessor)
func get_layer_storage() -> NodeCameraLayerStorage:
	return _layer_storage
#endregion

# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
