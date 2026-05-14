@tool
class_name NodeCameraMaskProperty extends EditorProperty
## Code copied from [url=https://github.com/godotengine/godot/blob/master/editor/inspector/editor_properties.cpp]
## Godot's Github[/url].

#region Constants
const LAYER_GROUP_SIZE : int = 4
const LAYER_COUNT : int = 32

const BASE_NAME : String = "addons/nodecam/layer_names"
#endregion


#region Private Variables
var _grid: NodeCameraMaskGrid
var _button: TextureButton
var _layers: PopupMenu
#endregion



#region Virtual Methods
func _init() -> void:
	var hb := HBoxContainer.new()
	hb.clip_contents = true
	add_child(hb)
	set_bottom_editor(hb)
	
	_grid = NodeCameraMaskGrid.new()
	_grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_grid.flag_changed.connect(_grid_changed)
	_grid.rename_confirmed.connect(set_layer_name)
	hb.add_child(_grid)
	add_focusable(_grid)
	
	_button = TextureButton.new()
	_button.stretch_mode = TextureButton.STRETCH_KEEP_CENTERED
	_button.toggle_mode = true
	_button.button_pressed = false
	_button.pressed.connect(_button_pressed)
	hb.add_child(_button)
	add_focusable(_button)
	
	_layers = PopupMenu.new()
	add_child(_layers)
	_layers.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
	_layers.hide_on_checkable_item_selection = false
	_layers.id_pressed.connect(_menu_pressed)
	_layers.popup_hide.connect(_on_layers_popup_hide)
	
	if ProjectSettings.settings_changed.is_connected(setup) == false:
		ProjectSettings.settings_changed.connect(setup)
	setup()

func _notification(what: int) -> void:
	if what == NOTIFICATION_THEME_CHANGED:
		_refresh_theme()

func _update_property() -> void:
	var obj := get_edited_object()
	if obj == null:
		return
	_grid.set_flag(int(obj.get(get_edited_property())))
#endregion


#region Private Setter Methods
func _refresh_theme() -> void:
	var theme := EditorInterface.get_editor_theme()
	_button.texture_normal = theme.get_icon("GuiTabMenuHl", "EditorIcons")
	_button.texture_pressed = theme.get_icon("GuiTabMenuHl", "EditorIcons")
	_button.texture_disabled = theme.get_icon("GuiTabMenu", "EditorIcons")

func _set_read_only(p_read_only: bool) -> void:
	_button.disabled = p_read_only
	_grid.set_read_only(p_read_only)
#endregion


#region Private Reaction Methods
func _grid_changed(p_grid: int) -> void:
	emit_changed(get_edited_property(), p_grid)

func _on_layers_popup_hide() -> void:
	_button.button_pressed = false

func _button_pressed() -> void:
	_layers.clear()
	
	for i : int in range(LAYER_COUNT):
		var name := get_layer_name(i)
		if name.is_empty():
			continue
		
		var idx := _layers.get_item_index(i)
		_layers.add_check_item(name, i)
		_layers.set_item_checked(idx, bool(_grid.value & (1 << i)))
	
	if _layers.get_item_count() == 0:
		_layers.add_item(tr("No Named Layers"))
		_layers.set_item_disabled(0, true)
	
	_layers.add_separator()
	_layers.add_icon_item(
		EditorInterface.get_editor_theme().get_icon("Edit", "EditorIcons"),
		tr("Edit Layer Names"),
		LAYER_COUNT
	)
	
	_layers.reset_size()
	var parent_rect := Rect2i(
		Vector2i(_button.get_screen_position()),
		Vector2i(_button.size)
	)
	
	_layers.popup_on_parent(parent_rect)
	_button.button_pressed = true

func _menu_pressed(p_menu: int) -> void:
	if p_menu == LAYER_COUNT:
		push_warning("Godot currently does not have a way to open the ProjectSettings in code. Go to Project > ProjectSettings > Addons > Nodecam")
		return
	
	_grid.value ^= 1 << p_menu
	_grid.value &= 0xffffffff
	_grid.queue_redraw()
	
	var idx := _layers.get_item_index(p_menu)
	if idx != -1:
		_layers.set_item_checked(idx, bool(_grid.value & (1 << p_menu)))
	
	_grid_changed(_grid.value)
#endregion


#region Public Helper Methods
func setup() -> void:
	var names: Array[String] = []
	var tooltips: Array[String] = []
	
	for i : int in range(LAYER_COUNT):
		var name := get_layer_name(i)
		if name.is_empty():
			name = tr("Layer %d") % (i + 1)
		
		names.append(name)
		tooltips.append("%s\n%s" % [
			name, tr("Bit %d, value %d") % [i, 1 << i]
		])
	
	_grid.set_data(names, tooltips, LAYER_GROUP_SIZE, LAYER_COUNT)
	_refresh_theme()
#endregion


#region Layer Name Accessor Methods
func set_layer_name(p_index: int, p_name: String) -> void:
	var property_name := "%s/layer_%d" % [BASE_NAME, p_index + 1]
	ProjectSettings.set_setting(property_name, p_name)
	ProjectSettings.save()
	setup()
func get_layer_name(p_index: int) -> String:
	var property_name := "%s/layer_%d" % [BASE_NAME, p_index + 1]
	if ProjectSettings.has_setting(property_name):
		property_name = str(ProjectSettings.get_setting(property_name))
		if property_name != "Layer %d" % (p_index + 1):
			return property_name
	return ""
#endregion
