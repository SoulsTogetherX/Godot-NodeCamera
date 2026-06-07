# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
@tool
class_name NodeCameraEffectShake extends NodeCameraEffect
## An effect for camera shake.

#region External Variables
@export_group("Base Effect")
## The amplitude multiplier for the shake.
@export var amplitude : float = 20.0:
	set = set_amplitude,
	get = get_amplitude
## How often the shake will occur (Bigger numbers means faster).
@export_range(0.001, 100.0, 0.001, "or_greater")
var frequency : float = 20:
	set = set_frequency,
	get = get_frequency

@export_group("Baises")
## How much in the x axis will the camera shake.
@export_range(0.0, 1.0, 0.001, "or_greater")
var h_bias : float = 1.0:
	set = set_h_bias,
	get = get_h_bias
## How much in the y axis will the camera shake.
@export_range(0.0, 1.0, 0.001, "or_greater")
var v_bias : float = 1.0:
	set = set_v_bias,
	get = get_v_bias
## Rotates the coordinate plane for shake calculations. Also see
## [member h_bias] and [member v_bias].
@export_range(0.0, 360, 0.001, "or_less", "or_greater")
var angle : float = 0.0:
	set = set_angle,
	get = get_angle

@export_group("Timeline")
## If [code]true[/code], the shake effect will last until
## deactivated.
@export var continuous : bool = true:
	set = set_continuous,
	get = get_continuous
@export_subgroup("Grow Ease")
## The curve used for shake growth.
## [br][br]
## Also see [member grow_duration].
@export var grow_curve : Curve:
	set = set_grow_curve,
	get = get_grow_curve
## The duration until the growth phase of shaking is finished.
## [br][br]
## Also see [member grow_curve].
@export_range(0, 1.0, 0.001, "or_greater")
var grow_duration : float = 0.0:
	set = set_grow_duration,
	get = get_grow_duration

@export_subgroup("Decay Ease")
## The curve used for shake decay.
## [br][br]
## Also see [member decay_duration].
@export var decay_curve : Curve:
	set = set_decay_curve,
	get = get_decay_curve
## The duration until the decay phase of shaking is finished.
## [br][br]
## Also see [member decay_duration].
@export_range(0, 1.0, 0.001, "or_greater")
var decay_duration : float = 0.0:
	set = set_decay_duration,
	get = get_decay_duration

@export_group("Extra Settings")
## If [code]true[/code], this effect will compile with previous effects
## that changes the camera's offset.
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
	if stage == LAYER_STAGES.HALTED:
		_delta_time = 0.0
#endregion


#region Public Methods (Stages)
func get_needed_process_stages() -> PackedInt32Array:
	var ret : PackedInt32Array = []
	if grow_curve != null && !is_zero_approx(grow_duration):
		ret.append(LAYER_STAGES.STARTING)
	if decay_curve != null && !is_zero_approx(decay_duration):
		ret.append(LAYER_STAGES.ENDING)
	if continuous:
		ret.append(LAYER_STAGES.RUNNING)
	
	return ret
func get_needed_change_stages() -> PackedInt32Array:
	var ret : PackedInt32Array = []
	if grow_curve != null && !is_zero_approx(grow_duration):
		ret.append(LAYER_STAGES.STARTING)
		ret.append(LAYER_STAGES.RUNNING)
	if decay_curve != null && !is_zero_approx(decay_duration):
		ret.append(LAYER_STAGES.ENDING)
		ret.append(LAYER_STAGES.HALTED)
	
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

func set_continuous(val : bool) -> void:
	if val == continuous:
		return
	continuous = val
	notify_stage_masks_changed()
func get_continuous() -> bool:
	return continuous

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
