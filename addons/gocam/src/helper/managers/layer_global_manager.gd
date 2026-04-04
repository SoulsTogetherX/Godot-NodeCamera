@tool
class_name GoCamera2DLayerGlobalManager extends GoCamera2DLayerManager

#region Signals
signal layer_start(layer : GoCamera2DLayer)
signal layer_end(layer : GoCamera2DLayer)
#endregion


#region Constants
const META_DATA_HAS_STARTED_NAME := &"META_DATA_HAS_STARTED"
#endregion



#region Methods (Subscribe Layer)
func _subscription_changed(layer : GoCamera2DLayer) -> void:
	if !layer.is_in_layer_group():
		if layer.is_running():
			if !layer.get_meta(META_DATA_HAS_STARTED_NAME, false):
				layer_start.emit(layer)
				layer.set_meta(META_DATA_HAS_STARTED_NAME, true)
		elif layer.get_meta(META_DATA_HAS_STARTED_NAME, false):
			layer_end.emit(layer)
			layer.set_meta(META_DATA_HAS_STARTED_NAME, false)
	
	super(layer)
#endregion


#region Methods (Register Layer)
func unregister_layer(layer : GoCamera2DLayer) -> void:
	layer.remove_meta(META_DATA_HAS_STARTED_NAME)
	super(layer)
#endregion


#region Methods (Tick Intermediates)
func layer_tick_start(layer : GoCamera2DLayer, host : GoCamera2DHost) -> void:
	if !(host.camera_flag_mask & camera_flag_mask):
		return
	force_start_layer(
		layer, host.get_target_status(), host.get_current_status()
	)
func layer_tick_end(layer : GoCamera2DLayer, host : GoCamera2DHost) -> void:
	if !(host.camera_flag_mask & camera_flag_mask):
		return
	force_end_layer(
		layer, host.get_target_status(), host.get_current_status()
	)
#endregion


#region Methods (Queue Ticks)
func effect_tick(target_status : GoCameraStateResource) -> void:
	for effect : GoCamera2DLayer in _effects_queue:
		if !(effect.camera_flag_mask & camera_flag_mask):
			return
		effect.effect_tick(target_status)
func transition_tick(
	target_status : GoCameraStateResource, current_status : GoCameraStateResource
) -> void:
	for transition : GoCamera2DLayer in _transitions_queue:
		if !(transition.camera_flag_mask & camera_flag_mask):
			return
		transition.transition_tick(target_status, current_status)
#endregion
