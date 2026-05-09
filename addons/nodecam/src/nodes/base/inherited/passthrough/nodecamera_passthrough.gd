# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
@tool
@abstract
class_name NodeCameraPassthrough extends NodeCameraGroup
## A [NodeCameraGroup] node that keeps track of any scope with this node
## registered (not necessarily added to the execution scope loop), allowing
## easy manipulation.

#region Private Variables
var _scopes : Array[NodeCameraExecutionScope]
#endregion



#region Private Scope Methods
## Caches the given [NodeCameraExecutionScope] to be used later. Ensure to call
## [code]super[/code] if overloading.
## [br][br]
## Also see: [method NodeCameraLayer._added_to_scope].
func _added_to_scope(scope : NodeCameraExecutionScope) -> void:
	_scopes.append(scope)
## Uncaches the given [NodeCameraExecutionScope] to be used later. Ensure to call
## [code]super[/code] if overloading.
## [br][br]
## Also see: [method NodeCameraLayer._removed_from_scope].
func _removed_from_scope(scope : NodeCameraExecutionScope) -> void:
	_scopes.erase(scope)
#endregion


#region Public Scope Methods
## Forces all cached [NodeCameraExecutionScope]s to fully rebuild their scopes.
func flag_construct_scope() -> void:
	for scope : NodeCameraExecutionScope in _scopes:
		scope.flag_construct_scope()
#endregion


#region Accessor Methods
## Returns all cached scopes.
## [br][br]
## [b]NOTE[/b]: Freeing any scope returned may cause an engine to crash.
func get_active_scopes() -> Array[NodeCameraExecutionScope]:
	return _scopes
#endregion

# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
