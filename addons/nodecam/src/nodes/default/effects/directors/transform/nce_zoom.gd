# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
@tool
class_name NodeCameraEffectZoom extends NodeCameraEffect
## An effect for camera zoom.

#region External Variables
@export_group("2D")
## The static [member Camera2D.zoom] value for [Camera2D] nodes.
@export_custom(PROPERTY_HINT_LINK, "") var zoom := Vector2(1.0, 1.0):
	set = set_zoom,
	get = get_zoom

@export_group("3D")
## The static [member Camera3D.fov] value for [Camera3D] nodes.
@export var fov : float = 75.0:
	set = set_fov,
	get = get_fov
## The static [member Camera3D.fov] value for [Camera3D] nodes.
@export var size : float = 1.0:
	set = set_size,
	get = get_size

@export_group("Settings")
## If [code]true[/code], this effect will compile with previous effects
## that changes the camera's zoom.
@export var incremental : bool = false
## If [code]true[/code], the layer will only set the effect's zoom
## for one frame in [method effect_stage_changed]'s starting stage.
@export var one_shot : bool = false:
	set = set_one_shot,
	get = get_one_shot
#endregion



#region Private Methods
func _handle_zoom(target : NodeCameraState) -> void:
	if incremental:
		if target is NodeCamera2DState:
			target.zoom =+ zoom
			return
		target.fov += fov
		target.size += size
		return
	if target is NodeCamera2DState:
		target.zoom = zoom
		return
	target.fov = fov
	target.size = size
#endregion


#region Virtual Methods (User Overwrite)
func process_effect(
	delta : float, target : NodeCameraState, stage : LAYER_STAGES
) -> void:
	_handle_zoom(target)

func effect_stage_changed(
	target : NodeCameraState, stage : LAYER_STAGES
) -> void:
	_handle_zoom(target)
#endregion


#region Public Methods (Stages)
func get_needed_process_stages() -> PackedInt32Array:
	if !one_shot:
		return [LAYER_STAGES.RUNNING]
	return []
func get_needed_change_stages() -> PackedInt32Array:
	return [LAYER_STAGES.STARTING]
#endregion


#region Accessor Methods
func set_zoom(val : Vector2) -> void:
	zoom = val
func get_zoom() -> Vector2:
	return zoom


func set_fov(val : float) -> void:
	fov = clampf(val, 1.0, 179.0)
func get_fov() -> float:
	return fov

func set_size(val : float) -> void:
	size = maxf(val, 1.0)
func get_size() -> float:
	return size


func set_one_shot(val : bool) -> void:
	if val == one_shot:
		return
	one_shot = val
	notify_stage_masks_changed()
func get_one_shot() -> bool:
	return one_shot
#endregion

# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
