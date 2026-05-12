# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
@tool
@abstract
class_name NodeCameraGeneralTransition extends NodeCameraTransition
## 

#region Enums
## 
enum CAMERA_PROPERTY {
	POSITION	= 1 << 1, ## 
	ROTATION	= 1 << 2, ## 
	OFFSET		= 1 << 3, ## 
	ZOOM		= 1 << 4, ## 
	H_OFFSET	= 1 << 5, ## 
	V_OFFSET	= 1 << 6, ## 
	FOV			= 1 << 7, ## 
	NEAR		= 1 << 8, ## 
	FAR			= 1 << 9, ## 
}
#endregion


#region External Variables
@export_group("Camera Properties")
@export_subgroup("Both")
## 
@export_custom(PROPERTY_HINT_NONE, "", PROPERTY_USAGE_EDITOR)
var global_position : bool = true:
	set(val):
		_op_mask &= ~CAMERA_PROPERTY.POSITION
		_op_mask |= int(val) * CAMERA_PROPERTY.POSITION
	get():
		return _op_mask & CAMERA_PROPERTY.POSITION
## 
@export_custom(PROPERTY_HINT_NONE, "", PROPERTY_USAGE_EDITOR)
var rotation : bool = true:
	set(val):
		_op_mask &= ~CAMERA_PROPERTY.ROTATION
		_op_mask |= int(val) * CAMERA_PROPERTY.ROTATION
	get():
		return _op_mask & CAMERA_PROPERTY.ROTATION

@export_subgroup("Camera2D")
## 
@export_custom(PROPERTY_HINT_NONE, "", PROPERTY_USAGE_EDITOR)
var offset : bool:
	set(val):
		_op_mask &= ~CAMERA_PROPERTY.OFFSET
		_op_mask |= int(val) * CAMERA_PROPERTY.OFFSET
	get():
		return _op_mask & CAMERA_PROPERTY.OFFSET
## 
@export_custom(PROPERTY_HINT_NONE, "", PROPERTY_USAGE_EDITOR)
var zoom : bool:
	set(val):
		_op_mask &= ~CAMERA_PROPERTY.ZOOM
		_op_mask |= int(val) * CAMERA_PROPERTY.ZOOM
	get():
		return _op_mask & CAMERA_PROPERTY.ZOOM

@export_subgroup("Camera3D")
## 
@export_custom(PROPERTY_HINT_NONE, "", PROPERTY_USAGE_EDITOR)
var h_offset : bool:
	set(val):
		_op_mask &= ~CAMERA_PROPERTY.H_OFFSET
		_op_mask |= int(val) * CAMERA_PROPERTY.H_OFFSET
	get():
		return _op_mask & CAMERA_PROPERTY.H_OFFSET
## 
@export_custom(PROPERTY_HINT_NONE, "", PROPERTY_USAGE_EDITOR)
var v_offset : bool:
	set(val):
		_op_mask &= ~CAMERA_PROPERTY.V_OFFSET
		_op_mask |= int(val) * CAMERA_PROPERTY.V_OFFSET
	get():
		return _op_mask & CAMERA_PROPERTY.V_OFFSET

## 
@export_custom(PROPERTY_HINT_NONE, "", PROPERTY_USAGE_EDITOR)
var fov : bool:
	set(val):
		_op_mask &= ~CAMERA_PROPERTY.FOV
		_op_mask |= int(val) * CAMERA_PROPERTY.FOV
	get():
		return _op_mask & CAMERA_PROPERTY.FOV
## 
@export_custom(PROPERTY_HINT_NONE, "", PROPERTY_USAGE_EDITOR)
var near : bool:
	set(val):
		_op_mask &= ~CAMERA_PROPERTY.NEAR
		_op_mask |= int(val) * CAMERA_PROPERTY.NEAR
	get():
		return _op_mask & CAMERA_PROPERTY.NEAR
## 
@export_custom(PROPERTY_HINT_NONE, "", PROPERTY_USAGE_EDITOR)
var far : bool:
	set(val):
		_op_mask &= ~CAMERA_PROPERTY.FAR
		_op_mask |= int(val) * CAMERA_PROPERTY.FAR
	get():
		return bool(_op_mask & CAMERA_PROPERTY.FAR)
#endregion


#region Private Variables
@export_storage var _op_mask : int = CAMERA_PROPERTY.POSITION | CAMERA_PROPERTY.ROTATION
#endregion

# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
