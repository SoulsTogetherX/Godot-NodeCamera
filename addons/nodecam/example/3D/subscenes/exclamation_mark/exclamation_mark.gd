extends Node3D

#region External Varables
@export var active : bool = false
@export var layer_controlled : NodeCameraLayer

@export var text : String
#endregion


#region OnReady Varables
@onready var _label: Label3D = $Mark/Label3D
#endregion


#region Private Variables
var _shader : ShaderMaterial
#endregion



#region Virtual Methods
func _ready() -> void:
	_shader = $Mark/Point.material
	_label.text = text
	
	_set_active_color()
	_on_interact()
#endregion


#region Interaction Methods
func entered_interaction() -> void:
	_shader.set_shader_parameter(
		"outline_color", Color.RED
	)
	_label.visible = true
func exited_interaction() -> void:
	_set_active_color()
	_label.visible = false

func interact() -> void:
	active = !active
	_on_interact()
func _on_interact() -> void:
	if !layer_controlled:
		return
	
	if layer_controlled is NodeCameraSelector:
		layer_controlled.selection = int(active)
		return
	
	if active:
		layer_controlled.notify_overwrite_stage(NodeCameraUtility.LAYER_STAGES.STARTING)
		return
	layer_controlled.notify_overwrite_stage(NodeCameraUtility.LAYER_STAGES.HALTED)

func _set_active_color() -> void:
	_shader.set_shader_parameter(
		"outline_color", Color.YELLOW if active else Color.WHITE
	)
#endregion
