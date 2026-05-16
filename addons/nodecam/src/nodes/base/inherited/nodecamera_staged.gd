# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
@tool
@abstract
class_name NodeCameraStaged extends NodeCameraLayer
## A [NodeCameraLayer] node for any layer affected by stages. Namely
## [NodeCameraEffect] and [NodeCameraTransition].


#region External Variables
## The inital stage this layer will start at, if added normally.
## [br][br]
## Use methods like
## [method NodeCameraExecutionScope.flag_overwrite_stage] if you
## want to add this layer with a different starting stage.
@export var inital_stage : LAYER_STAGES = LAYER_STAGES.STARTING
#endregion



#region Public Methods (Stage Helpers)
## Flags the current node to have it's stage advanced one forward. Only
## works for the current scope of the [color=#D6D000][b]Runtime
## Method[/b][/color].
## [br][br]
## [b]Note[/b]: This method can only be called in a [color=#D6D000][b]
## Runtime Method[/b][/color]. Undefined behavior otherwise.
## [br][br]
## Also see: [enum NodeCameraExecutionScope.LAYER_STAGES] and
## [method notify_advance_stage].
func advance_stage() -> void:
	_scope.flag_advance_stage(self)
## Flags the current node to have it's stage overwritten to [param stage],
## if it's current stage is before the given [param stage]. Only
## works for the current scope of the [color=#D6D000][b]Runtime
## Method[/b][/color].
## [br][br]
## [b]Note[/b]: This method can only be called in a [color=#D6D000][b]
## Runtime Method[/b][/color]. Undefined behavior otherwise.
## [br][br]
## Also see: [enum NodeCameraExecutionScope.LAYER_STAGES] and
## [method notify_advance_to_stage].
func advance_to_stage(stage : LAYER_STAGES) -> void:
	_scope.flag_advance_to_stage(self, stage)
## Flags the current node to have it's stage overwritten to [param stage].Only
## works for the current scope of the [color=#D6D000][b]Runtime
## Method[/b][/color].
## [br][br]
## [b]Note[/b]: This method can only be called in a [color=#D6D000][b]
## Runtime Method[/b][/color]. Undefined behavior otherwise.
## [br][br]
## Also see: [enum NodeCameraExecutionScope.LAYER_STAGES] and
## [method notify_overwrite_stage].
func overwrite_stage(stage : LAYER_STAGES) -> void:
	_scope.flag_overwrite_stage(self, stage)
#endregion


#region Public Flag Methods
## Forces all active [NodeCameraExecutionScope]s to advance any [LayerRecord]s,
## featuring this [NodeCameraStaged], one stage forward.
## [br][br]
## Also see: [method NodeCameraLayer.get_parent_scopes],
## [method overwrite_stage], and
## [enum NodeCameraExecutionScope.LAYER_STAGES].
func notify_advance_stage() -> void:
	for scope : NodeCameraExecutionScope in _parent_scopes:
		scope.flag_advance_stage(self)
## Forces all active [NodeCameraExecutionScope]sto overwrite the stage
## of any [LayerRecord]s, featuring this [NodeCameraStaged], assuming
## it's current stage is before the given argument [param stage].
## [br][br]
## Stages go in the order of [code]STARTING > RUNNING > ENDING > HALTED
## [/code][br][br]
## Also see: [method NodeCameraLayer.get_parent_scopes],
## [method overwrite_stage], and
## [enum NodeCameraExecutionScope.LAYER_STAGES].
func notify_advance_to_stage(stage : LAYER_STAGES) -> void:
	for scope : NodeCameraExecutionScope in _parent_scopes:
		scope.flag_advance_to_stage(self, stage)
## Forces all active [NodeCameraExecutionScope]s to overwrite the stage
## of any [LayerRecord]s featuring this [NodeCameraStaged], assuming
## it is possible.
## [br][br]
## Also see: [method NodeCameraLayer.get_parent_scopes],
## [method NodeCameraLayer.get_closest_active_scripts],
## [method overwrite_stage], and
## [enum NodeCameraExecutionScope.LAYER_STAGES].
func notify_overwrite_stage(
	stage : LAYER_STAGES, parent_overwrite : bool = true
) -> void:
	var layers := get_closest_active_layer_list()
	if layers.is_empty():
		return
	
	var l := layers.back()
	if l == self:
		for scope : NodeCameraExecutionScope in _parent_scopes:
			scope.flag_overwrite_stage(self, stage)
		return
	for scope : NodeCameraExecutionScope in l._parent_scopes:
		scope.flag_list_construct(layers, stage)
	

## Forces all active [NodeCameraExecutionScope]s to notify this
## [NodeCameraStaged]'s stage masks have changed.
## [br][br]
## Also see: [method NodeCameraLayer.get_parent_scopes],
## [method get_needed_process_stages], [method get_needed_linger_stages],
## and [method get_needed_change_stages].
func notify_stage_masks_changed() -> void:
	for scope : NodeCameraExecutionScope in _parent_scopes:
		scope.flag_stage_mask_changed(self)
#endregion


#region Public Methods (Stages)
## Implement to return a list of requested [enum NodeCameraExecutionScope.LAYER_STAGES]
## for the process [color=#D6D000][b]Runtime Method[/b][/color]. All stages returned
## here will also be treated as returned by [method get_needed_linger_stages] as well.
## Ignores [code]LAYER_STAGES.HALTED[/code].
## [br][br]
## [b]NOTE[/b]: This will not be updated automatically. If the stages returned are
## expected to change, use [method notify_stage_masks_changed].
## [br][br]
## [b]NOTE[/b]: This method is called every time the node is freshly added to a scope.
## See [signal NodeCameraLayer.activated].
func get_needed_process_stages() -> PackedInt32Array:
	return []
## Implement to return a list of requested [enum NodeCameraExecutionScope.LAYER_STAGES]
## to stall when reached, requiring an external stage change, [method advance_stage],
## or [method overwrite_stage] to be called. All stages returned by
## [method get_needed_process_stages] will also be treated as returned here as well.
## Ignores [code]LAYER_STAGES.HALTED[/code].
## [br][br]
## [b]NOTE[/b]: This will not be updated automatically. If the stages returned are
## expected to change, use [method notify_stage_masks_changed].
## [br][br]
## [b]NOTE[/b]: This method is called every time the node is freshly added to a scope.
## See [signal NodeCameraLayer.activated].
func get_needed_linger_stages() -> PackedInt32Array:
	return []
## Implement to return a list of requested [enum NodeCameraExecutionScope.LAYER_STAGES]
## for the state change [color=#D6D000][b]Runtime Method[/b][/color].
## [br][br]
## [b]NOTE[/b]: This will not be updated automatically. If the stages returned are
## expected to change, use [method notify_stage_masks_changed].
## [br][br]
## [b]NOTE[/b]: This method is called every time the node is freshly added to a scope.
## See [signal NodeCameraLayer.activated].
func get_needed_change_stages() -> PackedInt32Array:
	return []
#endregion

# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
