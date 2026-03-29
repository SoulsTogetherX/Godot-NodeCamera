@abstract
@tool
class_name GoCamera2DEffect extends GoCamera2DLayer


#region Private Variables
var _group : GoCamera2DGroup
#endregion



#region Virtual Methods
func _notification(what: int) -> void:
	super(what)
	match what:
		NOTIFICATION_READY:
			_check_if_in_group()
			_update_register()
		NOTIFICATION_ENTER_TREE, NOTIFICATION_EXIT_TREE:
			_check_if_in_group()
		NOTIFICATION_PREDELETE:
			if is_top_level() && active && !disabled:
				GoCamera2DManager.unregister_effect(self)

func _validate_property(property: Dictionary) -> void:
	match property.name:
		&"active", &"priority":
			if _group && !top_level:
				property.usage |= PROPERTY_USAGE_READ_ONLY
#endregion


#region Private Methods
func _check_if_in_group() -> void:
	_group = (get_parent() as GoCamera2DGroup)
	
	if _group:
		active = false

func _update_register() -> void:
	if !is_node_ready():
		return
	
	var should_register := (
		is_top_level() && active && !disabled
	)
	
	if should_register:
		GoCamera2DManager.register_effect(self)
		return
	GoCamera2DManager.unregister_effect(self)
#endregion


#region Public Methods (Accessor)
func set_active(val : bool) -> void:
	if active == val:
		return
	super(val)
	_update_register()
func set_disabled(val : bool) -> void:
	if disabled == val:
		return
	super(val)
	_update_register()

func set_top_level(val : bool) -> void:
	if top_level == val:
		return
	top_level = val
	
	notify_property_list_changed()
	_update_register()
#endregion


#region Public Methods (Helper)
func get_layer_group() -> GoCamera2DGroup:
	return _group

func is_in_layer_group() -> bool:
	return _group != null
func is_top_level() -> bool:
	return top_level || !is_in_layer_group()
#endregion
