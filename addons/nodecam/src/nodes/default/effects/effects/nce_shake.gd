# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
@tool
extends NodeCameraEffect

#region External Variables
@export_group("Base Effect")
@export var amplitude : float = 20.0:
	set = set_amplitude,
	get = get_amplitude
@export_range(0.001, 100.0, 0.001, "or_greater")
var frequency : float = 20:
	set = set_frequency,
	get = get_frequency

@export_group("Baises")
@export_range(-1.0, 1.0, 0.001, "or_less", "or_greater")
var h_bias : float = 1.0:
	set = set_h_bias,
	get = get_h_bias
@export_range(-1.0, 1.0, 0.001, "or_less", "or_greater")
var v_bias : float = 1.0:
	set = set_v_bias,
	get = get_v_bias
@export_range(0.0, 360, 0.001, "or_less", "or_greater")
var angle : float = 0.0:
	set = set_angle,
	get = get_angle

@export_group("Easing")
@export_subgroup("Grow Ease")
@export var grow_curve : Curve:
	set = set_grow_curve,
	get = get_grow_curve
@export_range(0, 1.0, 0.001, "or_greater")
var grow_duration : float = 0.0:
	set = set_grow_duration,
	get = get_grow_duration

@export_subgroup("Decay Ease")
@export var decay_curve : Curve:
	set = set_decay_curve,
	get = get_decay_curve
@export_range(0, 1.0, 0.001, "or_greater")
var decay_duration : float = 0.0:
	set = set_decay_duration,
	get = get_decay_duration

@export_group("Extra Settings")
@export var incremental : bool = false
#endregion


#region Private Methods
var _cached_angle : float

var _cached_frequency : float

var _delta_time : float
var _stage_time : float
#endregion



#region Virtual Methods
func _ready() -> void:
	_cal_cached_angle()
	_cal_cached_frequency()
#endregion


#region Private Methods
func _cal_cached_angle() -> void:
	_cached_angle = deg_to_rad(angle)
func _cal_cached_frequency() -> void:
	_cached_frequency = 1 / frequency

func _shake_base() -> Vector2:
	return (Vector2(randf(), randf()) * 2) - Vector2.ONE

func _sample_curve(curve : Curve, pos : float) -> float:
	return curve.sample_baked(
		pos * (curve.max_domain - curve.min_domain)
	)
#endregion


#region Virtual Methods (User Overwrite)
func process_effect(
	delta : float, target : NodeCameraState, stage : LAYER_STAGES
) -> void:
	if _delta_time >= _cached_frequency:
		var amp : float = amplitude
		if stage == LAYER_STAGES.STARTING:
			amp *= _sample_curve(
				grow_curve, _stage_time / grow_duration
			)
			if _stage_time > grow_duration:
				advance_stage()
		elif stage == LAYER_STAGES.ENDING:
			amp *= _sample_curve(
				decay_curve, _stage_time / decay_duration
			)
			if _stage_time > decay_duration:
				advance_stage()
		
		var shake_vec := (
			_shake_base() * Vector2(h_bias, v_bias)
		).rotated(_cached_angle) * amp
		
		if target is NodeCamera2DState:
			if incremental:
				target.offset += shake_vec
			else:
				target.offset = shake_vec
		elif target is NodeCamera3DState:
			if incremental:
				target.h_offset += shake_vec.x
				target.v_offset += shake_vec.y
			else:
				target.h_offset = shake_vec.x
				target.v_offset = shake_vec.y
		_delta_time = 0.0
	
	_delta_time += delta
	_stage_time += delta

func effect_stage_changed(
	target : NodeCameraState, stage : LAYER_STAGES
) -> void:
	_stage_time = 0.0
	if stage == LAYER_STAGES.HAULTED:
		_delta_time = 0.0
#endregion


#region Public Methods (Stages)
func get_needed_process_stages() -> PackedInt32Array:
	var ret : PackedInt32Array = [LAYER_STAGES.RUNNING]
	if grow_curve != null && !is_zero_approx(grow_duration):
		ret.append(LAYER_STAGES.STARTING)
	if decay_curve != null && !is_zero_approx(decay_duration):
		ret.append(LAYER_STAGES.ENDING)
	
	return ret
func get_needed_change_stages() -> PackedInt32Array:
	var ret : PackedInt32Array = [
		LAYER_STAGES.RUNNING, LAYER_STAGES.HAULTED
	]
	if grow_curve != null && !is_zero_approx(grow_duration):
		ret.append(LAYER_STAGES.STARTING)
	if decay_curve != null && !is_zero_approx(decay_duration):
		ret.append(LAYER_STAGES.ENDING)
	
	return ret
#endregion


#region Accessor Methods
func set_amplitude(val : float) -> void:
	if val == amplitude:
		return
	amplitude = val
func get_amplitude() -> float:
	return amplitude
func set_frequency(val : float) -> void:
	if val == frequency || frequency <= 0.0:
		return
	frequency = val
	_cal_cached_frequency()
func get_frequency() -> float:
	return frequency

func set_h_bias(val : float) -> void:
	if val == h_bias:
		return
	h_bias = val
func get_h_bias() -> float:
	return h_bias
func set_v_bias(val : float) -> void:
	if val == v_bias:
		return
	v_bias = val
func get_v_bias() -> float:
	return v_bias

func set_angle(val : float) -> void:
	if val == angle:
		return
	angle = val
	_cal_cached_angle()
func get_angle() -> float:
	return angle

func set_grow_curve(val : Curve) -> void:
	if val == grow_curve:
		return
	grow_curve = val
	notify_stage_masks_changed()
func get_grow_curve() -> Curve:
	return grow_curve
func set_grow_duration(val : float) -> void:
	if val == grow_duration:
		return
	grow_duration = val
	notify_stage_masks_changed()
func get_grow_duration() -> float:
	return grow_duration

func set_decay_curve(val : Curve) -> void:
	if val == decay_curve:
		return
	decay_curve = val
	notify_stage_masks_changed()
func get_decay_curve() -> Curve:
	return decay_curve
func set_decay_duration(val : float) -> void:
	if val == decay_duration:
		return
	decay_duration = val
	notify_stage_masks_changed()
func get_decay_duration() -> float:
	return decay_duration
#endregion

# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
