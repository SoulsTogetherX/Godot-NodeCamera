@tool
class_name GoCamera2DLayerGlobalManager extends GoCamera2DLayerManager

#region Signals
signal layer_start(layer : GoCamera2DLayer)
signal layer_end(layer : GoCamera2DLayer)
#endregion



#region Methods (Subscribe Layer)
func _subscription_changed(layer : GoCamera2DLayer) -> void:
	if layer.is_running():
		if !layer._is_ticking:
			layer_start.emit(layer)
			layer._is_ticking = true
	elif layer._is_ticking:
		layer_end.emit(layer)
		layer._is_ticking = false
	
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
