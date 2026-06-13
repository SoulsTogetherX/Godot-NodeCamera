# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
@tool
class_name NodeCameraTransitionInstant extends NodeCameraTransitionGeneral
## A general transition that sets transition property values directly
## to their expected values.

#region External Variables
@export_group("Settings")
## If [code]true[/code], the layer will only set the transition's
## properties for one frame in [method transition_stage_changed]'s
## starting stage.
@export var one_shot : bool = false:
	set = set_one_shot,
	get = get_one_shot
#endregion



#region Private Methods
func _handle_transition(
	target : NodeCameraState, current : NodeCameraState
) -> void:
	# BOTH
	if _op_mask & CAMERA_PROPERTY.POSITION:
		current.global_position = target.global_position
	
	# 2D
	if current is NodeCamera2DState:
		if _op_mask & CAMERA_PROPERTY.ROTATION:
			current.rotation = target.rotation
		
		
		if _op_mask & CAMERA_PROPERTY.OFFSET:
			current.offset = target.offset
		
		if _op_mask & CAMERA_PROPERTY.ZOOM:
			current.zoom = target.zoom
	
	# 3D
	if current is NodeCamera3DState:
		if _op_mask & CAMERA_PROPERTY.ROTATION:
			current.rotation = target.rotation
		
		
		if _op_mask & CAMERA_PROPERTY.H_OFFSET:
			current.h_offset = target.h_offset
		
		if _op_mask & CAMERA_PROPERTY.V_OFFSET:
			current.v_offset = target.v_offset
		
		
		if _op_mask & CAMERA_PROPERTY.FOV:
			current.fov = target.fov
		
		if _op_mask & CAMERA_PROPERTY.NEAR:
			current.near = target.near
		
		if _op_mask & CAMERA_PROPERTY.FAR:
			current.far = target.far
#endregion


#region Virtual Methods (User Overwrite)
func process_transition(
	delta : float, target : NodeCameraState, current : NodeCameraState,
	_stage : LAYER_STAGES
) -> void:
	_handle_transition(target, current)
func transition_stage_changed(
	target : NodeCameraState, current : NodeCameraState,
	_stage : LAYER_STAGES
) -> void:
	_handle_transition(target, current)
#endregion


#region Public Methods (Stages)
func get_needed_process_stages() -> PackedInt32Array:
	if one_shot:
		return []
	return [LAYER_STAGES.RUNNING]
func get_needed_linger_stages() -> PackedInt32Array:
	return [LAYER_STAGES.RUNNING]
func get_needed_change_stages() -> PackedInt32Array:
	return [LAYER_STAGES.STARTING]
#endregion


#region Accessor Methods
func set_one_shot(val : bool) -> void:
	if val == one_shot:
		return
	one_shot = val
	notify_stage_masks_changed()
func get_one_shot() -> bool:
	return one_shot
#endregion

# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
