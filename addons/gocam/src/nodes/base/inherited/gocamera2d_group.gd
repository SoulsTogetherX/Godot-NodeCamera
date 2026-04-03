@tool
class_name GoCamera2DGroup extends GoCamera2DLayer


#region Private Variables
var _layers : Array[GoCamera2DLayer]
var _layer_manager := GoCamera2DLayerManager.new()

var _tick_state : int
#endregion



#region Private Virtual Methods
func _init() -> void:
	super()
	_settup_private_signals()
	
	child_entered_tree.connect(_child_entered)
	child_exiting_tree.connect(_child_exited)
	_layer_manager.queues_changed.connect(_confirm_tick_changed)
	_confirm_tick_changed()
#endregion


#region Private Methods (Helper)
func _child_entered(child : Node) -> void:
	if child is GoCamera2DLayer:
		child.active = active
		child.camera_flag_mask = camera_flag_mask
		_layers.append(child)
func _child_exited(child : Node) -> void:
	if child is GoCamera2DLayer:
		_layers.erase(child)

func _confirm_tick_changed() -> void:
	var new_state := (
		int(_layer_manager.without_queued_effects()) |
		(int(_layer_manager.without_queued_transitions()) << 1)
	)
	
	if new_state != _tick_state:
		notify_tick_changed()
	_tick_state = new_state
#endregion


#region Public Virtual Methods (Toggle)
func start_group(
	target : GoCameraStateResource, current : GoCameraStateResource
) -> void:
	for layer : GoCamera2DLayer in _layers:
		_layer_manager.force_start_layer(
			layer, target, current
		)
func end_group(
	target : GoCameraStateResource, current : GoCameraStateResource
) -> void:
	for layer : GoCamera2DLayer in _layers:
		_layer_manager.force_end_layer(
			layer, target, current
		)
#endregion


#region Public Virtual Methods (Effect)
func effect_tick(target : GoCameraStateResource) -> void:
	_layer_manager.effect_tick(target)
func effect_tick_needed() -> bool:
	return !_layer_manager.without_queued_effects()
#endregion


#region Public Virtual Methods (Transition)
func transition_tick(
	target : GoCameraStateResource, current : GoCameraStateResource
) -> void:
	_layer_manager.transition_tick(target, current)
func transition_tick_needed() -> bool:
	return !_layer_manager.without_queued_transitions()
#endregion


#region Public Methods (Accessor)
func get_layer_manager() -> GoCamera2DLayerManager:
	return _layer_manager
#endregion


#region Public Methods (Accessor)
func set_active(val : bool) -> void:
	if val == active:
		return
	super(val)
	
	get_children().map(
		func(layer : GoCamera2DLayer): layer.active = active
	)

func set_camera_flag_mask(val : int) -> void:
	if val == camera_flag_mask:
		return
	super(val)
	
	_layer_manager.camera_flag_mask = camera_flag_mask
	get_children().map(
		func(layer : GoCamera2DLayer): layer.camera_flag_mask = camera_flag_mask
	)
#endregion
