@tool
class_name GoCamera2DLayerGroupManager extends GoCamera2DLayerManager
## A specialized extensions of [GoCamera2DLayerManager], used by [GoCamera2DGroup]
## nodes. This signals when subscriptions have been added or removed.


#region Signals
## This signal is emitted when the queue of subscription has been
## added to or removed from.
signal subscriptions_changed
#endregion


#region Methods (Subscribe Layer)
func _subscription_changed(layer : GoCamera2DLayer) -> void:
	subscriptions_changed.emit()
	super(layer)
#endregion


#region Methods (Queue Ticks)
## Calls the either [GoCamera2DEffect.effect_tick] or [GoCamera2DGroup.effect_tick]
## methods, on all layers subscribed to effect ticks, with [param target_status].
func _effect_tick(target_status : GoCameraStateResource) -> void:
	for effect : GoCamera2DLayer in _effects_queue:
		effect._effect_tick(target_status)
## Calls the either [GoCamera2DTransition.transition_tick] or
## [GoCamera2DGroup.transition_tick] methods, on all layers subscribed to
## transition ticks, with [param target_status] and [param current_status].
func _transition_tick(
	target_status : GoCameraStateResource, current_status : GoCameraStateResource
) -> void:
	for transition : GoCamera2DLayer in _transitions_queue:
		transition._transition_tick(target_status, current_status)
#endregion
