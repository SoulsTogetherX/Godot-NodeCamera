# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
@tool
@abstract
class_name NodeCamera2DStaged extends NodeCamera2DLayer

#region Enums
const LAYER_STAGES = NodeCamera2DConstants.LAYER_STAGES
#endregion


#region Private Variables
var _host_context : NodeCamera2DHostContext
#endregion



#region Public Methods (During-Layer Helper)
func advance_stage() -> void:
	_host_context.flag_layer_stage_advance(self)
func set_stage(stage : NodeCamera2DConstants.LAYER_STAGES) -> void:
	_host_context.flag_layer_direct_stage_change(self, stage)
#endregion


#region Public Methods (Force-Layer Helper)
func force_advance_stage(host : NodeCamera2DHost) -> void:
	host._host_context.flag_layer_stage_advance(self)

func force_start(host : NodeCamera2DHost) -> void:
	force_stage(host, NodeCamera2DConstants.LAYER_STAGES.STARTING)
func force_hault(host : NodeCamera2DHost) -> void:
	force_stage(host, NodeCamera2DConstants.LAYER_STAGES.HAULTED)
func force_stage(
	host : NodeCamera2DHost, stage : NodeCamera2DConstants.LAYER_STAGES
) -> void:
	host._context.flag_layer_direct_stage_change(self, stage)
#endregion


#region Public Methods (Stages)
func get_needed_process_stages() -> PackedInt32Array:
	return []
func get_needed_change_stages() -> PackedInt32Array:
	return [
		LAYER_STAGES.STARTING,
		LAYER_STAGES.HAULTED
	]
#endregion


# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
