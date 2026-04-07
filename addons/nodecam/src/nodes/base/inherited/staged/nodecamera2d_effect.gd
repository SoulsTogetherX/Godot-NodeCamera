# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
@tool
@icon("uid://82l5l3rm2fkd")
class_name NodeCamera2DEffect extends NodeCamera2DStaged
## The base [NodeCamera2DLayer] node for all camera effects, reliant on
## manipulating the target [GoCameraStateResource] resource of hosts.


#region Private Virtual Methods
func start_layer(target : GoCameraStateResource) -> void:
	pass
func end_layer(target : GoCameraStateResource) -> void:
	pass

func process_tick(target : GoCameraStateResource) -> void:
	pass
#endregion

# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
