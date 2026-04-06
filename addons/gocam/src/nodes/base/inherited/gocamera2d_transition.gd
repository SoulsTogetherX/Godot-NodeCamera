@tool
@icon("uid://dcxauqphisp2y")
class_name GoCamera2DTransition extends GoCamera2DLayer
## The base [GoCamera2DLayer] node for all camera effects, reliant on
## easing the current [GoCameraStateResource] resource into the target
## [GoCameraStateResource] resource of hosts.


#region Private Virtual Methods
## A method called the moment this transition has started.
## The [param target] and [param current] parameter is provided to
## allow manipulation of the camera's current state.
## [br][br]
## Although possible, it is discouraged to edit the [param target] resource
## in this method.
func _start_transition(
	target : GoCameraStateResource, current : GoCameraStateResource
) -> void:
	pass
## A method called the moment this transition has ended.
## The [param target] and [param current] parameter is provided to
## allow manipulation of the camera's current state.
## [br][br]
## Although possible, it is discouraged to edit the [param target] resource
## in this method.
func _end_transition(
	target : GoCameraStateResource, current : GoCameraStateResource
) -> void:
	pass

## A method called the moment this transition is to be updated.
## The [param target] and [param current] parameter is provided to
## allow manipulation of the camera's current state.
## [br][br]
## Although possible, it is discouraged to edit the [param target] resource
## in this method.
func _transition_tick(
	target : GoCameraStateResource, current : GoCameraStateResource
) -> void:
	pass
## A method should be overloaded.[br]
## If it returns [code]true[/code], this node will receieve updates.
## This method is only considered before [method start_effect] or
## after [method GoCamera2DLayer.notify_tick_changed] is called.
func _transition_tick_needed() -> bool:
	return false
#endregion
