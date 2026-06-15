# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
@tool
class_name NodeCameraEffectRotate extends NodeCameraEffect
## An effect that sets a camera's rotation.

#region External Variables
@export_group("2D")
## The static [member Camera2D.rotation] value for [Camera2D] nodes.
## [br][br]
## [b]NOTE[/b]: This property is edited in degrees in the inspector.
@export_range(0.0, 360.0, 0.1, "radians_as_degrees") var rotation_2D : float = 0.0:
	set = set_rotation_2D,
	get = get_rotation_2D

@export_group("3D")
## The static [member Camera3D.rotation] value for [Camera3D] nodes.
## [br][br]
## [b]NOTE[/b]: This property is edited in degrees in the inspector.
@export_custom(
	PROPERTY_HINT_NONE, "radians"
) var rotation_3D : Vector3 = Vector3.ZERO:
	set = set_rotation_3D,
	get = get_rotation_3D

@export_group("Settings")
## If [code]true[/code], this effect will compile with previous effects
## that changes the camera's rotation.
@export var incremental : bool = false

## If [code]true[/code], the layer will only set the effect's zoom
## for one frame in [method effect_stage_changed]'s starting stage.
@export var one_shot : bool = false:
	set = set_one_shot,
	get = get_one_shot
#endregion



#region Private Methods
func _handle_rotate(target : NodeCameraState) -> void:
	if incremental:
		if target is NodeCamera2DState:
			target.rotation += rotation_2D
			return
		target.rotation += rotation_3D
		return
	if target is NodeCamera2DState:
		target.rotation = rotation_2D
		return
	target.rotation = rotation_3D
#endregion


#region Virtual Methods (User Overwrite)
## Implements the [method NodeCameraEffect.process_effect] method.
func process_effect(
	_delta : float, target : NodeCameraState, _stage : LAYER_STAGES
) -> void:
	_handle_rotate(target)

## Implements the [method NodeCameraEffect.effect_stage_changed] method.
func effect_stage_changed(
	target : NodeCameraState, _stage : LAYER_STAGES
) -> void:
	_handle_rotate(target)
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
func set_rotation_2D(val : float) -> void:
	rotation_2D = val
func get_rotation_2D() -> float:
	return rotation_2D

func set_rotation_3D(val : Vector3) -> void:
	if val == rotation_3D:
		return
	
	rotation_3D = val
func get_rotation_3D() -> Vector3:
	return rotation_3D


func set_one_shot(val : bool) -> void:
	if val == one_shot:
		return
	one_shot = val
	notify_stage_masks_changed()
func get_one_shot() -> bool:
	return one_shot
#endregion

# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
