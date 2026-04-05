@tool
class_name GoCamera2DGroup extends GoCamera2DLayer
## The [GoCamera2DLayer] node used to help sync the activation and filter of
## children [GoCamera2DLayer], while also boosting performance.

#region Private Variables
var _layers : Array[GoCamera2DLayer]
var _layer_manager := GoCamera2DLayerGroupManager.new()

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
	if child is GoCamera2DLayer:
		if child.active != active:
			if active:
				GoCamera2DManager.layer_tick_start(child)
			else:
				GoCamera2DManager.layer_tick_end(child)
		
		child.active = active
		child.camera_flag_mask = camera_flag_mask
		_layers.append(child)
func _child_exited(child : Node) -> void:
	if child is GoCamera2DLayer:
		_layers.erase(child)

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
	print("START GROUP")
	for layer : GoCamera2DLayer in _layers:
		_layer_manager.force_start_layer(
			layer, target, current
		)
	_layer_manager.subscriptions_changed.connect(_confirm_tick_changed)
func _end_group(
	target : GoCameraStateResource, current : GoCameraStateResource
) -> void:
	print("END GROUP")
	for layer : GoCamera2DLayer in _layers:
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
## Gets the current [GoCamera2DLayerManager] being used.
## [br][br]
## [b]NOTE[/b]: Freeing this object will cause errors.
func get_layer_manager() -> GoCamera2DLayerManager:
	return _layer_manager
#endregion


#region Public Methods (Accessor)
## Sets the [member active] property of this layer.
func set_active(val : bool) -> void:
	if val == active:
		return
	get_children().map(
		func(layer : Node):
			if layer is GoCamera2DLayer:
				layer.active = val
	)
	super(val)

## Sets the [member set_camera_flag_mask] property of this layer.
func set_camera_flag_mask(val : int) -> void:
	if val == camera_flag_mask:
		return
	get_children().map(
		func(layer : Node):
			if layer is GoCamera2DLayer:
				layer.camera_flag_mask = val
	)
	super(val)
#endregion
