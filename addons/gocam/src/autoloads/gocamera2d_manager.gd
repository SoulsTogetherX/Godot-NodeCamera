extends Node


#region Private Variables
var _effects : Array[GoCamera2DEffect] = []
var _global_effects : Array[GoCamera2DEffect] = []

var _hosts : Array[GoCamera2DHost] = []
#endregion



#region Public Methods (Layer Registers)
func register_effect(layer : GoCamera2DEffect) -> void:
	if _effects.find(layer) != -1:
		push_warning("Attempted to register an effect stack already registered.")
		return
	_effects.append(layer)
func unregister_effect(layer : GoCamera2DEffect) -> void:
	var idx := _effects.find(layer)
	if idx == -1:
		push_warning("Attempted to unregister an effect stack not registered.")
		return
	_effects.remove_at(idx)
#endregion


#region Public Methods (Host Registers)
func register_host(host : GoCamera2DHost) -> void:
	if _hosts.find(host) != -1:
		push_warning("Attempted to register a camera host already registered.")
		return
	_hosts.append(host)
func unregister_host(host : GoCamera2DHost) -> void:
	var idx := _hosts.find(host)
	if idx == -1:
		push_warning("Attempted to unregister a camera host not registered.")
		return
	_hosts.remove_at(idx)
#endregion



func _ready() -> void:
	get_tree().physics_frame.connect(_update_cam, CONNECT_DEFERRED)

func _update_cam() -> void:
	for host : GoCamera2DHost in _hosts:
		var cam := host.get_camera()
		var state := host.get_camera_state()
		
		for effect : GoCamera2DEffect in _effects:
			effect.run_effect(state)
		
		cam.position = state.position
		cam.offset = state.offset
		cam.zoom = state.zoom
		cam.rotation = state.rotation
