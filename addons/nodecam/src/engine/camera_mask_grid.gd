@tool
class_name NodeCameraMaskGrid extends Control
## Code copied from [url=https://github.com/godotengine/godot/blob/master/editor/inspector/editor_properties.cpp]
## Godot's Github[/url].

#region Signals
## Emitted when a flag changes.
signal flag_changed(flag: int)
## Emitted when a layer name has been changed.
signal rename_confirmed(layer_id: int, new_name: String)
#endregion


#region Constants
## The index of a default empty hover.
const HOVERED_INDEX_NONE := -1
## Invaild characters to check.
const INVALID_NAME_CHARS := ["/", "\\", ":"]
#endregion


#region Private Variables
var _flag_rects: Array[Rect2] = []
var _expand_rect: Rect2 = Rect2()

var _hovered_index: int = HOVERED_INDEX_NONE
var _expand_hovered: bool = false
var _dragging: bool = false
var _dragging_value_to_set: bool = false

var _renamed_layer_index: int = -1

var _rename_dialog: ConfirmationDialog
var _rename_text: LineEdit
var _layer_rename: PopupMenu
#endregion


#region Public Variables
## If [code]true[/code], this property is read only.
var read_only: bool = false
## Signifies this grid should expand itself next redraw.
var expanded: bool = false
## The current value of the property.
var value: int = 0

## The stored names of every layers.
var names: Array[String] = []
## The stored tooltips of every layers.
var tooltips: Array[String] = []

## Number of horizontal buttons for each layer group.
var layer_group_size: int = 4
## The number of layers allowed for each camera mask.
var layer_count: int = 32

## The number of rows currently expanded.
var expansion_rows: int = 0
#endregion



#region Virtual Methods
func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	clip_contents = true
	_build_popups()
	queue_redraw()

func _get_minimum_size() -> Vector2:
	var min_size := get_grid_size()
	
	if expanded:
		var bsize := int((min_size.y * 80 / 100) / 2)
		for _i : int in range(expansion_rows):
			min_size.y += 2 * (bsize + 1) + 3
	return min_size

func _get_tooltip(at_position: Vector2) -> String:
	for i : int in range(_flag_rects.size()):
		if i < tooltips.size() && _flag_rects[i].has_point(at_position):
			return tooltips[i]
	return ""

func _gui_input(event: InputEvent) -> void:
	if read_only:
		return
	
	if event is InputEventMouseMotion:
		var mm := event as InputEventMouseMotion
		_update_hovered(mm.position)
		
		if _dragging && _hovered_index != HOVERED_INDEX_NONE:
			var target_value := bool(value & (1 << _hovered_index))
			if _dragging_value_to_set != target_value:
				value ^= 1 << _hovered_index
				value &= 0xffffffff
				flag_changed.emit(value)
				queue_redraw()
		accept_event()
		return
	
	if event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		
		if mb.button_index == MOUSE_BUTTON_LEFT && mb.pressed:
			_update_hovered(mb.position)
			var replace_mode := mb.is_command_or_control_pressed()
			_update_flag(replace_mode)
			
			if !replace_mode && _hovered_index != HOVERED_INDEX_NONE:
				_dragging = true
				_dragging_value_to_set = bool(value & (1 << _hovered_index))
			
			accept_event()
			return
		
		if mb.button_index == MOUSE_BUTTON_LEFT && !mb.pressed:
			_dragging = false
			accept_event()
			return
		
		if mb.button_index == MOUSE_BUTTON_RIGHT && mb.pressed:
			if _hovered_index != HOVERED_INDEX_NONE:
				_renamed_layer_index = _hovered_index
				_layer_rename.position = get_screen_position() + mb.position
				_layer_rename.reset_size()
				_layer_rename.popup()
			accept_event()
			return

func _notification(what: int) -> void:
	if what == NOTIFICATION_MOUSE_EXIT:
		_on_hover_exit()
	elif what == NOTIFICATION_THEME_CHANGED:
		queue_redraw()

func _draw() -> void:
	var theme := EditorInterface.get_editor_theme()
	var grid_size := get_grid_size()
	grid_size.x = size.x
	
	_flag_rects.clear()
	
	var prev_expansion_rows := expansion_rows
	expansion_rows = 0
	
	var bsize := int((grid_size.y * 80 / 100) / 2)
	var h := bsize * 2 + 1
	
	var color := theme.get_color(
		 "highlight_disabled_color" if read_only else "highlight_color",
		"Editor"
	)
	
	var text_color := theme.get_color(
		"font_disabled_color" if read_only else "font_color",
		"Editor"
	)
	text_color.a *= 0.5
	
	var text_color_on := theme.get_color(
		"font_disabled_color" if read_only else "font_hover_color",
		"Editor"
	)
	text_color_on.a *= 0.7
	
	var font: Font = theme.get_font("font", "Label")
	var font_size: int = theme.get_font_size("font_size", "Label")
	
	var vofs := (grid_size.y - h) / 2.0
	var layer_index := 0
	
	var block_ofs := Vector2(4, vofs)
	var arrow_pos := Vector2.ZERO
	
	while true:
		var ofs := block_ofs
		
		for _row : int in range(2):
			for _col : int in range(layer_group_size):
				if layer_index >= layer_count:
					break
				
				var on := bool(value & (1 << layer_index))
				var rect2 := Rect2(ofs, Vector2(bsize, bsize))
				
				color.a = 0.6 if on else 0.2
				if layer_index == _hovered_index:
					color.a += 0.15
				
				draw_rect(rect2, color)
				_flag_rects.append(rect2)
				
				var offset := Vector2(0, rect2.size.y * 0.75)
				draw_string(
					font,
					rect2.position + offset,
					str(layer_index + 1),
					HORIZONTAL_ALIGNMENT_CENTER,
					rect2.size.x,
					font_size,
					text_color_on if on else text_color
				)
				
				ofs.x += bsize + 1
				layer_index += 1
			
			if layer_index >= layer_count:
				break
			
			ofs.x = block_ofs.x
			ofs.y += bsize + 1
		
		if layer_index >= layer_count:
			if !_flag_rects.is_empty() && expansion_rows == 0:
				arrow_pos = _flag_rects.back().end
			break
		
		var block_size_x := layer_group_size * (bsize + 1)
		block_ofs.x += block_size_x + 3
		
		if block_ofs.x + block_size_x + 12 > grid_size.x:
			if !_flag_rects.is_empty() && expansion_rows == 0:
				arrow_pos = _flag_rects.back().end
			
			expansion_rows += 1
			
			if expanded:
				block_ofs.x = 4
				block_ofs.y += 2 * (bsize + 1) + 3
			else:
				break
	
	if expanded && prev_expansion_rows != expansion_rows:
		update_minimum_size()
	
	if expansion_rows == 0 && layer_index == layer_count:
		return
	
	var arrow := theme.get_icon("arrow", "Tree")
	if arrow:
		var arrow_color := theme.get_color("highlight_color", "Editor")
		arrow_color.a = 1.0 if _expand_hovered else 0.6
		
		arrow_pos.x += 2.0
		arrow_pos.y -= arrow.get_height()
		
		var arrow_rect := Rect2(arrow_pos, arrow.get_size())
		if expanded:
			arrow_rect.size.y *= -1.0
		
		_expand_rect = arrow_rect.abs()
		draw_texture_rect(arrow, arrow_rect, false, arrow_color)
#endregion


#region Private Tooltip Methods
func _refresh_tooltips() -> void:
	if tooltips.size() == layer_count:
		return
	
	tooltips.clear()
	for i : int in range(layer_count):
		var layer_name := ""
		if i < names.size():
			layer_name = names[i]
		if layer_name.is_empty():
			layer_name = tr("Layer %d") % (i + 1)
		tooltips.append("%s\n%s" % [
			layer_name,
			tr("Bit %d, value %d") % [i, 1 << i]
		])
#endregion


#region Private Popup Methods
func _build_popups() -> void:
	_rename_dialog = ConfirmationDialog.new()
	_rename_dialog.dialog_hide_on_ok = false
	_rename_dialog.ok_button_text = tr("Rename")
	add_child(_rename_dialog)
	
	var rename_vb := VBoxContainer.new()
	_rename_dialog.add_child(rename_vb)
	
	var rename_row := HBoxContainer.new()
	rename_vb.add_child(rename_row)
	
	var rename_label := Label.new()
	rename_label.text = tr("Name:")
	rename_row.add_child(rename_label)
	
	_rename_text = LineEdit.new()
	_rename_text.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	rename_row.add_child(_rename_text)
	
	_rename_dialog.register_text_enter(_rename_text)
	_rename_dialog.confirmed.connect(_rename_operation_confirm)
	
	_layer_rename = PopupMenu.new()
	add_child(_layer_rename)
	_layer_rename.add_item(tr("Rename Layer"), 0)
	_layer_rename.id_pressed.connect(_rename_pressed)

func _rename_pressed(menu_id: int) -> void:
	if menu_id != 0:
		return
	
	if _renamed_layer_index < 0 || _renamed_layer_index >= layer_count:
		return
	
	var current_name := ""
	if _renamed_layer_index < names.size():
		current_name = names[_renamed_layer_index]
	
	_rename_dialog.title = tr("Renaming Layer %d:") % (_renamed_layer_index + 1)
	_rename_text.text = current_name
	_rename_text.placeholder_text = tr("Layer %d") % (_renamed_layer_index + 1)
	_rename_text.select(0, current_name.length())
	_rename_dialog.popup_centered_clamped(Vector2i(300, 80))
	_rename_text.grab_focus()


func _rename_operation_confirm() -> void:
	var new_name := _rename_text.text.strip_edges()
	
	for ch : String in INVALID_NAME_CHARS:
		if new_name.contains(ch):
			push_warning(tr("Name contains invalid characters."))
			return
	
	if _renamed_layer_index >= names.size():
		names.resize(_renamed_layer_index + 1)
	
	names[_renamed_layer_index] = new_name
	
	var tooltip_name := new_name
	if tooltip_name.is_empty():
		tooltip_name = tr("Layer %d") % (_renamed_layer_index + 1)
	
	if _renamed_layer_index >= tooltips.size():
		tooltips.resize(_renamed_layer_index + 1)
	
	tooltips[_renamed_layer_index] = "%s\n%s" % [
		tooltip_name,
		tr("Bit %d, value %d") % [_renamed_layer_index, 1 << _renamed_layer_index]
	]
	
	rename_confirmed.emit(_renamed_layer_index, new_name)
	_rename_dialog.hide()
	queue_redraw()
#endregion


#region Private Hovered Methods
func _update_hovered(position: Vector2) -> void:
	var expand_was_hovered := _expand_hovered
	_expand_hovered = _expand_rect.has_point(position)
	
	if _expand_hovered != expand_was_hovered:
		queue_redraw()
	
	if !_expand_hovered:
		for i : int in range(_flag_rects.size()):
			if _flag_rects[i].has_point(position):
				if _hovered_index != i:
					_hovered_index = i
					queue_redraw()
				return
	
	if _hovered_index != HOVERED_INDEX_NONE:
		_hovered_index = HOVERED_INDEX_NONE
		queue_redraw()

func _on_hover_exit() -> void:
	if _expand_hovered:
		_expand_hovered = false
		queue_redraw()
	
	if _hovered_index != HOVERED_INDEX_NONE:
		_hovered_index = HOVERED_INDEX_NONE
		queue_redraw()
	
	if _dragging:
		_dragging = false
#endregion


#region Private Flag Methods
func _update_flag(p_replace: bool) -> void:
	if read_only:
		return
	
	if _hovered_index != HOVERED_INDEX_NONE:
		if p_replace:
			if value == (1 << _hovered_index):
				value = (~value) & 0xffffffff
			else:
				value = 1 << _hovered_index
		else:
			value ^= 1 << _hovered_index
		
		value &= 0xffffffff
		flag_changed.emit(value)
		queue_redraw()
	elif _expand_hovered:
		expanded = !expanded
		update_minimum_size()
		queue_redraw()
#endregion


#region Accessor Methods
## Sets the inital data of this grid.
func set_data(
	p_names: Array[String], p_tooltips: Array[String],
	p_layer_group_size: int, p_layer_count: int
) -> void:
	names = p_names
	tooltips = p_tooltips
	layer_group_size = p_layer_group_size
	layer_count = p_layer_count
	_refresh_tooltips()
	update_minimum_size()
	queue_redraw()

## Sets the [member read_only] property of the grid.
func set_read_only(p_read_only: bool) -> void:
	read_only = p_read_only
	queue_redraw()
## Sets a flag value of the grid.
func set_flag(p_flag: int) -> void:
	value = p_flag & 0xffffffff
	queue_redraw()

## Gets the current grid size.
func get_grid_size() -> Vector2:
	var theme := EditorInterface.get_editor_theme()
	var font: Font = theme.get_font("font", "Label")
	var font_size: int = theme.get_font_size("font_size", "Label")
	return Vector2(0.0, font.get_height(font_size) * 3.0)
#endregion
