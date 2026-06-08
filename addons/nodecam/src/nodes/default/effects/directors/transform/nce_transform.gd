# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
@tool
class_name NodeCameraEffectTransform extends NodeCameraEffect
## An effect for arbitrary camera transformations. Also see
## [NodeCameraEffectOffset], [NodeCameraEffectPosition]
## [NodeCameraEffectRotate], and [NodeCameraEffectZoom].

#region External Variables
@export_group("2D")
@export_subgroup("Offset")
## The static [member Camera2D.offset] value for [Camera2D] nodes.
@export var offset := Vector2(0.0, 0.0):
	set = set_offset,
	get = get_offset

@export_subgroup("Position")
## The static [member Camera2D.global_position] value for [Camera2D] nodes.
@export var position_2D := Vector2(0.0, 0.0):
	set = set_position_2D,
	get = get_position_2D
	
@export_subgroup("Rotation")
## The static [member Camera2D.rotation_degrees] value for [Camera2D] nodes.
@export var rotation_2D : float = 1.0:
	set = set_rotation_2D,
	get = get_rotation_2D

@export_subgroup("Zoom")
## The static [member Camera2D.zoom] value for [Camera2D] nodes.
@export_custom(PROPERTY_HINT_LINK, "") var zoom := Vector2(1.0, 1.0):
	set = set_zoom,
	get = get_zoom

@export_group("3D")
@export_subgroup("Offset")
## The static [member Camera3D.h_offset] value for [Camera3D] nodes.
@export var h_offset : float = 0.0:
	set = set_h_offset,
	get = get_h_offset
## The static [member Camera3D.v_offset] value for [Camera3D] nodes.
@export var v_offset : float = 0.0:
	set = set_v_offset,
	get = get_v_offset

@export_subgroup("Position")
## The static [member Camera3D.global_position] value for [Camera3D] nodes.
@export var position_3D := Vector3(0.0, 0.0, 0.0):
	set = set_position_3D,
	get = get_position_3D

@export_subgroup("Rotation")
## The static [member Camera3D.rotation_degrees] value for [Camera3D] nodes.
@export var rotation_3D : Vector3 = Vector3.ZERO:
	set = set_rotation_3D,
	get = get_rotation_3D

@export_subgroup("Zoom")
## The static [member Camera3D.fov] value for [Camera3D] nodes.
@export var fov : float = 75.0:
	set = set_fov,
	get = get_fov
## The static [member Camera3D.near] value for [Camera3D] nodes.
@export var near : float = 0.05:
	set = set_near,
	get = get_near
## The static [member Camera3D.far] value for [Camera3D] nodes.
@export var far : float = 4000.0:
	set = set_far,
	get = get_far

@export_group("Settings")
## If [code]true[/code], the layer will only set the effect's zoom
## for one frame in [method effect_stage_changed]'s starting stage.
@export var one_shot : bool = false:
	set = set_one_shot,
	get = get_one_shot
#endregion



#region Virtual Methods (User Overwrite)
func process_effect(
	delta : float, target : NodeCameraState, stage : LAYER_STAGES
) -> void:
	if target is NodeCamera2DState:
		# Offset
		target.offset = offset
		
		# Position
		target.global_position = position_2D
		
		# Rotation
		target.rotation_degrees = rotation_2D
		
		# Zoom
		target.zoom = zoom
	else:
		# Offset
		target.h_offset = h_offset
		target.v_offset = v_offset
		
		# Position
		target.global_position = position_3D
		
		# Rotation
		target.rotation_degrees = rotation_3D
		
		# Zoom
		target.fov = fov
		target.near = near
		target.far = far

func effect_stage_changed(
	target : NodeCameraState, stage : LAYER_STAGES
) -> void:
	if target is NodeCamera2DState:
		target.offset = offset
		
		target.zoom = zoom
	else:
		target.h_offset = h_offset
		target.v_offset = v_offset
		
		target.fov = fov
		target.near = near
		target.far = far
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
# Offset
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


# Position
func set_position_2D(val : Vector2) -> void:
	position_2D = val
func get_position_2D() -> Vector2:
	return position_2D

func set_position_3D(val : Vector3) -> void:
	position_3D = val
func get_position_3D() -> Vector3:
	return position_3D


# Rotation
func set_rotation_2D(val : float) -> void:
	rotation_2D = val
func get_rotation_2D() -> float:
	return rotation_2D

func set_rotation_3D(val : Vector3) -> void:
	rotation_3D = val
func get_rotation_3D() -> Vector3:
	return rotation_3D


# Zoom
func set_zoom(val : Vector2) -> void:
	zoom = val
func get_zoom() -> Vector2:
	return zoom

func set_fov(val : float) -> void:
	fov = val
func get_fov() -> float:
	return fov

func set_near(val : float) -> void:
	near = val
func get_near() -> float:
	return near

func set_far(val : float) -> void:
	far = val
func get_far() -> float:
	return far


# Settings
func set_one_shot(val : bool) -> void:
	if val == one_shot:
		return
	one_shot = val
	notify_stage_masks_changed()
func get_one_shot() -> bool:
	return one_shot
#endregion

# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
