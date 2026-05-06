# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
class_name StagedLayerRecord extends LayerRecord

#region Public Variables
var packed_masks : int
#endregion



#region Accessor Methods
func set_masks(process : int, linger : int, changed : int) -> void:
	packed_masks = (process << 8) | (process << 4) | (linger << 4) | changed

func get_process_mask() -> int:
	return (packed_masks >> 8) & 0b1111
func get_linger_mask() -> int:
	return (packed_masks >> 4) & 0b1111
func get_changed_mask() -> int:
	return packed_masks & 0b1111
#endregion

# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
