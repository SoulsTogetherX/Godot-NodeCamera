# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
@tool
@abstract
class_name NodeCameraGeneralTransition extends NodeCameraTransition
## An abstract base for general transitions, which may affect any
## property in [NodeCamera2DState] and [NodeCamera3DState] objects.
## [br][br]
## [b]NOTE[/b]: For efficiency reasons, you may want to create your own
## transition that's more selective in what properties it affects.

#region Enums
## A bitmask for all possible properties [NodeCamera2DState]
## and [NodeCamera3DState] objects can have.
enum CAMERA_PROPERTY {
	POSITION	= 1 << 1, ## Position property.
	ROTATION	= 1 << 2, ## Rotation property.
	OFFSET		= 1 << 3, ## Offset property.
	ZOOM		= 1 << 4, ## Zoom Property.
	H_OFFSET	= 1 << 5, ## H_Offset Property.
	V_OFFSET	= 1 << 6, ## V_Offset Property.
	FOV			= 1 << 7, ## FOV Property.
	NEAR		= 1 << 8, ## Near Property.
	FAR			= 1 << 9, ## Far Property.
}
#endregion


#region External Variables
@export_group("Shared")
## If [code]true[/code], this transition is expected to transition
## the position property.
@export_custom(PROPERTY_HINT_NONE, "", PROPERTY_USAGE_EDITOR)
var global_position : bool = true:
	set(val):
		_op_mask &= ~CAMERA_PROPERTY.POSITION
		_op_mask |= int(val) * CAMERA_PROPERTY.POSITION
	get():
		return _op_mask & CAMERA_PROPERTY.POSITION
## If [code]true[/code], this transition is expected to transition
## the rotation property.
@export_custom(PROPERTY_HINT_NONE, "", PROPERTY_USAGE_EDITOR)
var rotation : bool = true:
	set(val):
		_op_mask &= ~CAMERA_PROPERTY.ROTATION
		_op_mask |= int(val) * CAMERA_PROPERTY.ROTATION
	get():
		return _op_mask & CAMERA_PROPERTY.ROTATION

@export_group("Camera2D")
## If [code]true[/code], this transition is expected to transition
## the offset property.
@export_custom(PROPERTY_HINT_NONE, "", PROPERTY_USAGE_EDITOR)
var offset : bool:
	set(val):
		_op_mask &= ~CAMERA_PROPERTY.OFFSET
		_op_mask |= int(val) * CAMERA_PROPERTY.OFFSET
	get():
		return _op_mask & CAMERA_PROPERTY.OFFSET
## If [code]true[/code], this transition is expected to transition
## the zoom property.
@export_custom(PROPERTY_HINT_NONE, "", PROPERTY_USAGE_EDITOR)
var zoom : bool:
	set(val):
		_op_mask &= ~CAMERA_PROPERTY.ZOOM
		_op_mask |= int(val) * CAMERA_PROPERTY.ZOOM
	get():
		return _op_mask & CAMERA_PROPERTY.ZOOM

@export_group("Camera3D")
## If [code]true[/code], this transition is expected to transition
## the h_offset property.
@export_custom(PROPERTY_HINT_NONE, "", PROPERTY_USAGE_EDITOR)
var h_offset : bool:
	set(val):
		_op_mask &= ~CAMERA_PROPERTY.H_OFFSET
		_op_mask |= int(val) * CAMERA_PROPERTY.H_OFFSET
	get():
		return _op_mask & CAMERA_PROPERTY.H_OFFSET
## If [code]true[/code], this transition is expected to transition
## the v_offset property.
@export_custom(PROPERTY_HINT_NONE, "", PROPERTY_USAGE_EDITOR)
var v_offset : bool:
	set(val):
		_op_mask &= ~CAMERA_PROPERTY.V_OFFSET
		_op_mask |= int(val) * CAMERA_PROPERTY.V_OFFSET
	get():
		return _op_mask & CAMERA_PROPERTY.V_OFFSET

## If [code]true[/code], this transition is expected to transition
## the fov property.
@export_custom(PROPERTY_HINT_NONE, "", PROPERTY_USAGE_EDITOR)
var fov : bool:
	set(val):
		_op_mask &= ~CAMERA_PROPERTY.FOV
		_op_mask |= int(val) * CAMERA_PROPERTY.FOV
	get():
		return _op_mask & CAMERA_PROPERTY.FOV
## If [code]true[/code], this transition is expected to transition
## the near property.
@export_custom(PROPERTY_HINT_NONE, "", PROPERTY_USAGE_EDITOR)
var near : bool:
	set(val):
		_op_mask &= ~CAMERA_PROPERTY.NEAR
		_op_mask |= int(val) * CAMERA_PROPERTY.NEAR
	get():
		return _op_mask & CAMERA_PROPERTY.NEAR
## If [code]true[/code], this transition is expected to transition
## the far property.
@export_custom(PROPERTY_HINT_NONE, "", PROPERTY_USAGE_EDITOR)
var far : bool:
	set(val):
		_op_mask &= ~CAMERA_PROPERTY.FAR
		_op_mask |= int(val) * CAMERA_PROPERTY.FAR
	get():
		return bool(_op_mask & CAMERA_PROPERTY.FAR)
#endregion


#region Private Variables
@export_storage var _op_mask : int = CAMERA_PROPERTY.POSITION
#endregion

# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
