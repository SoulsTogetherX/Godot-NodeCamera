# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
@tool
class_name NodeCamera2DLayerGroupManager extends NodeCamera2DLayerManager
## A specialized extensions of [NodeCamera2DLayerManager], used by [NodeCamera2DGroup]
## nodes. This signals when subscriptions have been added or removed.


#region Signals
## This signal is emitted when the queue of subscription has been
## added to or removed from.
signal subscriptions_changed
#endregion


#region Private Variables
var _registered_layers : Array[NodeCamera2DLayer]
#endregion



#region Methods (Queue)
func _update_layer_priority(layer : NodeCamera2DLayer) -> void:
	_registered_layers.erase(layer)
	_insert_layer_in_queue(layer, _registered_layers)
	super(layer)
#endregion


#region Methods (Subscribe Layer)
func _subscription_changed(layer : NodeCamera2DLayer) -> void:
	subscriptions_changed.emit()
	super(layer)
#endregion


#region Methods (Register Layer)
## Registers the given [param layer] into this object.
## [br][br]
## Overloaded only to ensure unneeded metadata is cleared upon register.
func register_layer(layer : NodeCamera2DLayer) -> void:
	super(layer)
	_insert_layer_in_queue(layer, _registered_layers)
## Unregisters the given [param layer] from this object.
## [br][br]
## Overloaded only to ensure unneeded metadata is cleared upon unregister.
func unregister_layer(layer : NodeCamera2DLayer) -> void:
	super(layer)
	_registered_layers.erase(layer)
#endregion


#region Methods (Queue Ticks)
## Calls the either [NodeCamera2DEffect.effect_tick] or [NodeCamera2DGroup.effect_tick]
## methods, on all layers subscribed to effect ticks, with [param target_status].
func _effect_tick(target_status : GoCameraStateResource) -> void:
	for effect : NodeCamera2DLayer in _effects_queue:
		effect._effect_tick(target_status)
## Calls the either [NodeCamera2DTransition.transition_tick] or
## [NodeCamera2DGroup.transition_tick] methods, on all layers subscribed to
## transition ticks, with [param target_status] and [param current_status].
func _transition_tick(
	target_status : GoCameraStateResource, current_status : GoCameraStateResource
) -> void:
	for transition : NodeCamera2DLayer in _transitions_queue:
		transition._transition_tick(target_status, current_status)
#endregion


#region Methods (Accessor)
## Returns all registered layers within this object, sorted 
## by priority.
func get_registered_layers() -> Array[NodeCamera2DLayer]:
	return _registered_layers
#endregion

# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
