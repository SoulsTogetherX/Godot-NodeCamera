# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
@tool
class_name NodeCameraEffect2DFrame extends NodeCameraEffect
## An effect that applies a deadzone on a frame, only following
## the target when it tries to leave.

#region External Variables
## The deadzone this transition uses. Each coordinate uses a ratio
## from 0-1 to calculate the frame's width and height, depending
## on the current viewport of the camera.
@export var dead_zone := Vector2(0.2, 0.2)
#endregion



#region Virtual Methods (User Overwrite)
func process_effect(
	delta : float, target : NodeCameraState, stage : LAYER_STAGES
) -> void:
	if !(target is NodeCamera2DState):
		return
	
	var viewport_target_offset := Vector2.ZERO
	var cam : Camera2D = target.get_camera()
	var view_size : Vector2 = (
		cam.get_viewport_rect().size / target.zoom.abs()
	)
	
	## Dead Zone
	var viewport_dead_zone := Vector2(
		view_size.x * dead_zone.x, view_size.y * dead_zone.y
	) * 0.5
	var dead_zone := Vector4(
		cam.global_position.x - viewport_dead_zone.x,
		cam.global_position.x + viewport_dead_zone.x,
		cam.global_position.y - viewport_dead_zone.y,
		cam.global_position.y + viewport_dead_zone.y,
	)
	
	## Horizontal Dead Zone
	if dead_zone.x > target.global_position.x:
		viewport_target_offset.x = dead_zone.x - target.global_position.x
	elif dead_zone.y < target.global_position.x:
		viewport_target_offset.x = dead_zone.y - target.global_position.x
	
	## Vertical Dead Zone
	if dead_zone.z > target.global_position.y:
		viewport_target_offset.y = dead_zone.z - target.global_position.y
	elif dead_zone.w < target.global_position.y:
		viewport_target_offset.y = dead_zone.w - target.global_position.y
	
	var current : Vector2 = target.get_var(
		self, Vector2.ZERO
	) - viewport_target_offset
	target.set_var(self, current)
	target.global_position = current

func effect_stage_changed(
	target : NodeCameraState, stage : LAYER_STAGES
) -> void:
	if !(target is NodeCamera2DState):
		return
	if stage == LAYER_STAGES.STARTING:
		target.set_var(self, target.global_position)
	elif stage == LAYER_STAGES.HALTED:
		target.clear_var(self)
#endregion


#region Public Methods (Stages)
func get_needed_process_stages() -> PackedInt32Array:
	return [LAYER_STAGES.RUNNING]
func get_needed_change_stages() -> PackedInt32Array:
	return [LAYER_STAGES.STARTING, LAYER_STAGES.HALTED]
#endregion

# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
