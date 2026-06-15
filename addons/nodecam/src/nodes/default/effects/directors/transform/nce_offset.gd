# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
@tool
class_name NodeCameraEffectOffset extends NodeCameraEffect
## An effect that sets a camera's offset.

#region External Variables
@export_group("2D")
## The static [member Camera2D.offset] value for [Camera2D] nodes.
@export var offset := Vector2(0.0, 0.0):
	set = set_offset,
	get = get_offset

@export_group("3D")
## The static [member Camera3D.h_offset] value for [Camera3D] nodes.
@export var h_offset : float = 0.0:
	set = set_h_offset,
	get = get_h_offset
## The static [member Camera3D.v_offset] value for [Camera3D] nodes.
@export var v_offset : float = 0.0:
	set = set_v_offset,
	get = get_v_offset

@export_group("Settings")
## If [code]true[/code], this effect will compile with previous effects
## that changes the camera's offset.
@export var incremental : bool = false

## If [code]true[/code], the layer will only set the effect's zoom
## for one frame in [method effect_stage_changed]'s starting stage.
@export var one_shot : bool = false:
	set = set_one_shot,
	get = get_one_shot
#endregion



#region Private Methods
func _handle_offset(target : NodeCameraState) -> void:
	if incremental:
		if target is NodeCamera2DState:
			target.offset += offset
			return
		target.h_offset += h_offset
		target.v_offset += v_offset
		return
	if target is NodeCamera2DState:
		target.offset = offset
		return
	target.h_offset = h_offset
	target.v_offset = v_offset
#endregion


#region Virtual Methods (User Overwrite)
## Implements the [method NodeCameraEffectOffset.process_effect] method.
func process_effect(
	_delta : float, target : NodeCameraState, _stage : LAYER_STAGES
) -> void:
	_handle_offset(target)

## Implements the [method NodeCameraEffectOffset.effect_stage_changed] method.
func effect_stage_changed(
	target : NodeCameraState, _stage : LAYER_STAGES
) -> void:
	_handle_offset(target)
#endregion


#region Public Methods (Stages)
## Implements the [method NodeCameraStaged.get_needed_process_stages] method.
func get_needed_process_stages() -> PackedInt32Array:
	if !one_shot:
		return [LAYER_STAGES.RUNNING]
	return []

## Implements the [method NodeCameraStaged.get_needed_change_stages] method.
func get_needed_change_stages() -> PackedInt32Array:
	return [LAYER_STAGES.STARTING]
#endregion


#region Accessor Methods
func set_offset(val : Vector2) -> void:
	offset = val
func get_offset() -> Vector2:
	return offset


func set_h_offset(val : float) -> void:
	h_offset = val
func get_h_offset() -> float:
	return h_offset

func set_v_offset(val : float) -> void:
	v_offset = val
func get_v_offset() -> float:
	return v_offset


func set_one_shot(val : bool) -> void:
	if val == one_shot:
		return
	one_shot = val
	notify_stage_masks_changed()
func get_one_shot() -> bool:
	return one_shot
#endregion

# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
