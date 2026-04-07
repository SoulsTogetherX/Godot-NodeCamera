# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
@tool
@icon("uid://dcxauqphisp2y")
class_name NodeCamera2DTransition extends NodeCamera2DStaged
## The base [NodeCamera2DLayer] node for all camera effects, reliant on
## easing the current [GoCameraStateResource] resource into the target
## [GoCameraStateResource] resource of hosts.


#region Private Virtual Methods
func start_layer(
	target : GoCameraStateResource, current : GoCameraStateResource
) -> void:
	pass
func end_layer(
	target : GoCameraStateResource, current : GoCameraStateResource
) -> void:
	pass

func process_tick(
	target : GoCameraStateResource, current : GoCameraStateResource
) -> void:
	pass

func advance_stage() -> void:
	pass
func get_needed_stages() -> PackedInt32Array:
	return []
#endregion

# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
