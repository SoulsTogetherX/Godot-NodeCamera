# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
@tool
@abstract
class_name NodeCameraStaged extends NodeCameraLayer
## A [NodeCameraLayer] node for any layer affected by stages. Namely
## [NodeCameraEffect] and [NodeCameraTransition].

#region Public Methods (Stage Helpers)
## Flags the current node to have it's stage advanced one forward. Only
## works for the current scope of the [color=#D6D000][b]Runtime Method[/b][/color].
## [br][br]
## [b]Note[/b]: This method can only be called in a [color=#D6D000][b]
## Runtime Method[/b][/color]. Undefined behavior otherwise.
## [br][br]
## Also see: [enum NodeCameraExecutionScope.LAYER_STAGES].
func advance_stage() -> void:
	_scope.flag_advance_stage(self)
## Flags the current node to have it's stage overwritten to [param stage]. Only
## works for the current scope of the [color=#D6D000][b]Runtime Method[/b][/color].
## [br][br]
## [b]Note[/b]: This method can only be called in a [color=#D6D000][b]
## Runtime Method[/b][/color]. Undefined behavior otherwise.
## [br][br]
## Also see: [enum NodeCameraExecutionScope.LAYER_STAGES].
func overwrite_stage(stage : LAYER_STAGES) -> void:
	_scope.flag_overwrite_stage(self, stage)
#endregion


#region Public Methods (Stages)
## Implement to return a list of requested [enum NodeCameraExecutionScope.LAYER_STAGES]
## for the process [color=#D6D000][b]Runtime Method[/b][/color]. All stages returned
## here will also be treated as returned by [method get_needed_linger_stages] as well.
## [br][br]
## [b]NOTE[/b]: This method is called every time the node is freshly added to a scope.
## See [signal NodeCameraLayer.activated] and [method NodeCameraLayer._added_to_scope].
func get_needed_process_stages() -> PackedInt32Array:
	return []

## Implement to return a list of requested [enum NodeCameraExecutionScope.LAYER_STAGES]
## to stall when reached, requiring an external stage change, [method advance_stage],
## or [method overwrite_stage] to be called. All stages returned by
## [method get_needed_process_stages] will also be treated as returned here as well.
## [br][br]
## [b]NOTE[/b]: This method is called every time the node is freshly added to a scope.
## See [signal NodeCameraLayer.activated] and [method NodeCameraLayer._added_to_scope].
func get_needed_linger_stages() -> PackedInt32Array:
	return []
## Implement to return a list of requested [enum NodeCameraExecutionScope.LAYER_STAGES]
## for the state change [color=#D6D000][b]Runtime Method[/b][/color].
## [br][br]
## [b]NOTE[/b]: This method is called every time the node is freshly added to a scope.
## See [signal NodeCameraLayer.activated] and [method NodeCameraLayer._added_to_scope].
func get_needed_change_stages() -> PackedInt32Array:
	return []
#endregion

# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
