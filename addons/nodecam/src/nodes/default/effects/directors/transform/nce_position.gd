# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
@tool
class_name NodeCameraEffectPosition extends NodeCameraEffect
## An effect for camera position.

#region External Variables
@export_group("2D")
## The static [member Camera2D.global_position] value for [Camera2D] nodes.
@export var position_2D := Vector2(0.0, 0.0):
	set = set_position_2D,
	get = get_position_2D

@export_group("3D")
## The static [member Camera3D.global_position] value for [Camera3D] nodes.
@export var position_3D := Vector3(0.0, 0.0, 0.0):
	set = set_position_3D,
	get = get_position_3D

@export_group("Settings")
## If [code]true[/code], this effect will compile with previous effects
## that changes the camera's position.
@export var incremental : bool = false
## If [code]true[/code], the layer will only set the effect's zoom
## for one frame in [method effect_stage_changed]'s starting stage.
@export var one_shot : bool = false:
	set = set_one_shot,
	get = get_one_shot
#endregion


#region Private Methods
func _handle_position(target : NodeCameraState) -> void:
	if incremental:
		if target is NodeCamera2DState:
			target.global_position += position_2D
			return
		target.global_position += position_3D
		return
	if target is NodeCamera2DState:
		target.global_position = position_2D
		return
	target.global_position = position_3D
#endregion


#region Virtual Methods (User Overwrite)
func process_effect(
	_delta : float, target : NodeCameraState, _stage : LAYER_STAGES
) -> void:
	_handle_position(target)

func effect_stage_changed(
	target : NodeCameraState, _stage : LAYER_STAGES
) -> void:
	_handle_position(target)
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
func set_position_2D(val : Vector2) -> void:
	position_2D = val
func get_position_2D() -> Vector2:
	return position_2D

func set_position_3D(val : Vector3) -> void:
	position_3D = val
func get_position_3D() -> Vector3:
	return position_3D


func set_one_shot(val : bool) -> void:
	if val == one_shot:
		return
	one_shot = val
	notify_stage_masks_changed()
func get_one_shot() -> bool:
	return one_shot
#endregion

# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
