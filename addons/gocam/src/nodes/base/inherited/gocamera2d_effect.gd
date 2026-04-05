@tool
class_name GoCamera2DEffect extends GoCamera2DLayer
## The base [GoCamera2DLayer] node for all camera effects, reliant on
## manipulating the target [GoCameraStateResource] resource of hosts.


#region Private Virtual Methods
## A method called the moment this effect has started.
## The [param target] parameter is provided to allow manipulation
## of the camera's target state.
func _start_effect(target : GoCameraStateResource) -> void:
	pass
## A method called the moment this effect has ended.
## The [param target] parameter is provided to allow manipulation
## of the camera's target state.
func _end_effect(target : GoCameraStateResource) -> void:
	pass

## A method called the moment this effect is to be updated.
## The [param target] parameter is provided to allow manipulation
## of the camera's target state.
func _effect_tick(target : GoCameraStateResource) -> void:
	pass
## A method should be overloaded.[br]
## If it returns [code]true[/code], this node will receieve updates.
## This method is only considered before [method start_effect] or
## after [method GoCamera2DLayer.notify_tick_changed] is called.
func _effect_tick_needed() -> bool:
	return false
#endregion
