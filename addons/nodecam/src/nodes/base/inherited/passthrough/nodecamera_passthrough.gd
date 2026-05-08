# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
@tool
@abstract
class_name NodeCameraPassthrough extends NodeCameraGroup

#region Private Variables
var _scopes : Array[NodeCameraExecutionScope]
#endregion



#region Private Scope Methods
@abstract
func _get_active_layers() -> Array[NodeCameraLayer]

func _added_to_scope(scope : NodeCameraExecutionScope) -> void:
	_scopes.append(scope)
func _removed_from_scope(scope : NodeCameraExecutionScope) -> void:
	_scopes.erase(scope)
#endregion


#region Public Scope Methods
func flag_scope_update() -> void:
	for scope : NodeCameraExecutionScope in _scopes:
		scope.flag_construct_scope()
#endregion


#region Accessor Methods
func get_active_scopes() -> Array[NodeCameraExecutionScope]:
	return _scopes
#endregion

# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
