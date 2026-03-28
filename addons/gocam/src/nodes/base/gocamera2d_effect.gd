@abstract
class_name GoCamera2DEffect extends Node


#region External Variables
@export var priority : int

@export var active : bool = false:
	set = set_active,
	get = get_active
#endregion



#region Abstract Methods
@abstract
func run_effect(state : CameraStateResource) -> void
#endregion


#region Public Methods (Accessor)
func set_active(val : bool) -> void:
	active = val
	if val:
		GoCamera2DManager.register_effect(self)
		return
	GoCamera2DManager.unregister_effect(self)
func get_active() -> bool:
	return active
#endregion
