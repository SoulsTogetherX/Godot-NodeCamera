# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
@tool
@abstract
class_name NodeCameraStaged extends NodeCameraLayer

#region Public Methods (During-Layer Helper)
func advance_stage() -> void:
	_scope.flag_layer_stage_advance(self)
func set_stage(stage : LAYER_STAGES) -> void:
	_scope.flag_layer_direct_stage_change(self, stage)
#endregion


#region Public Methods (Force-Layer Helper)
func force_advance_stage(host : NodeCameraHost) -> void:
	host._host_content.flag_layer_stage_advance(self)

func force_start(host : NodeCameraHost) -> void:
	force_stage(host, LAYER_STAGES.STARTING)
func force_hault(host : NodeCameraHost) -> void:
	force_stage(host, LAYER_STAGES.HAULTED)
func force_stage(
	host : NodeCameraHost, stage : LAYER_STAGES
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
