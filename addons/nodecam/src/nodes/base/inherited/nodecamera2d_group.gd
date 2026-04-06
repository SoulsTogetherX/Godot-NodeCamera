# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
@tool
@icon("uid://dl0jprapnu02l")
class_name NodeCamera2DGroup extends NodeCamera2DLayer
## The [NodeCamera2DLayer] node used to help sync the activation and filter of
## children [NodeCamera2DLayer], while also boosting performance.


#region Private Variables
var _layer_manager := NodeCamera2DLayerGroupManager.new()

var _tick_state : int
#endregion



#region Private Virtual Methods
func _init() -> void:
	child_entered_tree.connect(_child_entered)
	child_exiting_tree.connect(_child_exited)
	_confirm_tick_changed()
#endregion


#region Private Methods (Helper)
func _child_entered(child : Node) -> void:
	if child is NodeCamera2DLayer:
		if child.active != active:
			if active:
				NodeCamera2DManager.layer_tick_start(child)
			else:
				NodeCamera2DManager.layer_tick_end(child)
		
		child.active = active
		child.camera_flag_mask = camera_flag_mask
		_confirm_tick_changed()
func _child_exited(child : Node) -> void:
	if child is NodeCamera2DLayer:
		_confirm_tick_changed()

func _confirm_tick_changed() -> void:
	var new_state := (
		int(_layer_manager.get_queued_effects().is_empty()) |
		(int(_layer_manager.get_queued_transitions().is_empty()) << 1)
	)
	if new_state != _tick_state:
		notify_tick_changed()
	_tick_state = new_state
#endregion


#region Private Virtual Methods (Toggle)
func _start_group(
	target : GoCameraStateResource, current : GoCameraStateResource
) -> void:
	for layer : NodeCamera2DLayer in _layer_manager.get_registered_layers():
		_layer_manager.force_start_layer(
			layer, target, current
		)
	_layer_manager.subscriptions_changed.connect(_confirm_tick_changed)
func _end_group(
	target : GoCameraStateResource, current : GoCameraStateResource
) -> void:
	for layer : NodeCamera2DLayer in _layer_manager.get_registered_layers():
		_layer_manager.force_end_layer(
			layer, target, current
		)
	_layer_manager.subscriptions_changed.disconnect(_confirm_tick_changed)
#endregion


#region Private Virtual Methods (Effect)
func _effect_tick(target : GoCameraStateResource) -> void:
	_layer_manager._effect_tick(target)
func _effect_tick_needed() -> bool:
	return !_layer_manager.get_queued_effects().is_empty()
#endregion


#region Private Virtual Methods (Transition)
func _transition_tick(
	target : GoCameraStateResource, current : GoCameraStateResource
) -> void:
	_layer_manager._transition_tick(target, current)
func _transition_tick_needed() -> bool:
	return !_layer_manager.get_queued_transitions().is_empty()
#endregion


#region Public Methods (Accessor)
## Gets the current [NodeCamera2DLayerManager] being used.
## [br][br]
## [b]NOTE[/b]: Freeing this object will cause errors.
func get_layer_manager() -> NodeCamera2DLayerManager:
	return _layer_manager
#endregion


#region Public Methods (Accessor)
## Sets the [member active] property of this layer.
func set_active(val : bool) -> void:
	if val == active:
		return
	_layer_manager.get_registered_layers().map(
		func(layer : Node):
			if layer is NodeCamera2DLayer:
				layer.active = val
	)
	super(val)

## Sets the [member set_camera_flag_mask] property of this layer.
func set_camera_flag_mask(val : int) -> void:
	if val == camera_flag_mask:
		return
	_layer_manager.get_registered_layers().map(
		func(layer : Node):
			if layer is NodeCamera2DLayer:
				layer.camera_flag_mask = val
	)
	super(val)
#endregion

# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
