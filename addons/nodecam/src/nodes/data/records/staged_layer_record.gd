# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
class_name StagedLayerRecord extends LayerRecord

#region Public Variables
var packed_masks : int
#endregion



#region Accessor Methods
func get_process_mask() -> int:
	return (packed_masks >> 8) & 0b1111
func set_process_mask(val : int) -> void:
	packed_masks |= (val << 8)

func get_linger_mask() -> int:
	return (packed_masks >> 4) & 0b1111
func set_linger_mask(val : int) -> void:
	packed_masks |= (val << 4)

func get_changed_mask() -> int:
	return packed_masks & 0b1111
func set_changed_mask(val : int) -> void:
	packed_masks |= val
#endregion

# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
