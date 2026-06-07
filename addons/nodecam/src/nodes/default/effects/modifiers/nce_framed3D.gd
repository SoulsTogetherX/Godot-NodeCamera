@tool
class_name NodeCameraEffect3DFramed extends NodeCameraEffect

@export var framed_target: Node3D:
	set = set_framed_target,
	get = get_framed_target

@export var dead_zone := Vector2(4.0, 2.0)
@export var dead_zone_margin := 0.05 # small hysteresis to stop edge-flip jitter

func process_effect(delta: float, target: NodeCameraState, stage: LAYER_STAGES) -> void:
	if !(target is NodeCamera3DState):
		return
	if framed_target == null:
		return

	var cam: Camera3D = target.get_camera()
	var cam_xform: Transform3D = cam.global_transform

	# Target in camera-local space.
	var framed_local: Vector3 = cam_xform.affine_inverse() * framed_target.global_position

	var half := dead_zone * 0.5
	var local_offset := Vector3.ZERO

	# X axis deadzone with margin.
	if framed_local.x < -half.x - dead_zone_margin:
		local_offset.x = framed_local.x + half.x + dead_zone_margin
	elif framed_local.x > half.x + dead_zone_margin:
		local_offset.x = framed_local.x - half.x - dead_zone_margin

	# Y axis deadzone with margin.
	if framed_local.y < -half.y - dead_zone_margin:
		local_offset.y = framed_local.y + half.y + dead_zone_margin
	elif framed_local.y > half.y + dead_zone_margin:
		local_offset.y = framed_local.y - half.y - dead_zone_margin

	if local_offset == Vector3.ZERO:
		return

	var world_offset := cam_xform.basis * Vector3(local_offset.x, local_offset.y, 0.0)

	var current: Vector3 = target.get_var(self, target.global_position)
	current += world_offset
	target.set_var(self, current)
	target.global_position = current

func effect_stage_changed(target: NodeCameraState, stage: LAYER_STAGES) -> void:
	if !(target is NodeCamera3DState):
		return
	if stage == LAYER_STAGES.STARTING:
		target.set_var(self, target.global_position)
	elif stage == LAYER_STAGES.HALTED:
		target.clear_var(self)

func get_needed_process_stages() -> PackedInt32Array:
	return [LAYER_STAGES.RUNNING] if framed_target != null else []

func get_needed_change_stages() -> PackedInt32Array:
	return  [LAYER_STAGES.STARTING, LAYER_STAGES.HALTED] if framed_target != null else [LAYER_STAGES.HALTED]

func set_framed_target(val: Node3D) -> void:
	if val == framed_target:
		return
	framed_target = val
	notify_stage_masks_changed()

func get_framed_target() -> Node3D:
	return framed_target
