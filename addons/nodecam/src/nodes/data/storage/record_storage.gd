# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
@tool
class_name NodeCamera2DRecordStorage extends Object

#region Private Variables
var _priority_buckets: Dictionary[int, Array] = {}
var _priority_record: Array[int] = []

var _flat_layer_list: Array[LayerRecord] = []
#endregion



#region Private Helper Methods
func _insert_priority_sorted(priority: int) -> void:
	var idx := _priority_record.bsearch(priority)
	if idx < _priority_record.size() && _priority_record[idx] == priority:
		return
	_priority_record.insert(idx, priority)

func _insert_into_bucket(record: LayerRecord, priority : int) -> void:
	if !_priority_buckets.has(priority):
		_priority_buckets[priority] = []
		_insert_priority_sorted(priority)
	_priority_buckets[priority].append(record)

func _remove_from_bucket(record: LayerRecord, priority : int) -> void:
	if !_priority_buckets.has(priority):
		return
	
	var bucket: Array = _priority_buckets[priority]
	bucket.erase(record)
	
	if bucket.is_empty():
		_priority_buckets.erase(priority)
		_priority_record.erase(priority)
#endregion


#endregion Public Access Methods
func clear() -> void:
	_priority_buckets.clear()
	_priority_record.clear()
	_flat_layer_list.clear()
func rebuild() -> void:
	_flat_layer_list.clear()
	for priority : int in _priority_record:
		_flat_layer_list.append_array(_priority_buckets[priority])

func add(record: LayerRecord, priority : int) -> void:
	_insert_into_bucket(record, priority)
func remove(record: LayerRecord, priority : int) -> void:
	_remove_from_bucket(record, priority)
func reorder(
	record: LayerRecord, new_priority : int, old_priority : int
) -> void:
	if old_priority == new_priority:
		return
	_remove_from_bucket(record, old_priority)
	_insert_into_bucket(record, new_priority)

func get_flat_list() -> Array[LayerRecord]:
	return _flat_layer_list
func is_empty() -> bool:
	return _flat_layer_list.is_empty()
#endregion

# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
