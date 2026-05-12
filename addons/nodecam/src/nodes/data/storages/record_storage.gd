# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
@tool
class_name NodeCameraRecordStorage extends Object
## Stores and orders [LayerRecord]s, in order of priority, with the use of priority
## buckets. Using the available methods, you can use the priority buckets to
## construct an iterable and cache-friendly flatlist.

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

func _check_if_paused(record : LayerRecord) -> bool:
	return record.paused
#endregion


#endregion Public Access Methods
## Clears all data. Does not free the stored [LayerRecord]s' memory.
func clear() -> void:
	_priority_buckets.clear()
	_priority_record.clear()
	_flat_layer_list.clear()
## Rebuilds the flatlist according to the data already stored.
func rebuild() -> void:
	_flat_layer_list.clear()
	for priority : int in _priority_record:
		var bucket: Array = _priority_buckets[priority]
		for record: LayerRecord in bucket:
			if !record.paused:
				_flat_layer_list.append(record)

## Add [param record], with [param priority], to the [NodeCameraRecordStorage].
func add(record: LayerRecord, priority : int) -> void:
	_insert_into_bucket(record, priority)
## Removes [param record], with [param priority], if found inside
## the [NodeCameraRecordStorage].
func remove(record: LayerRecord, priority : int) -> void:
	_remove_from_bucket(record, priority)
## Changes the priority of [param record], with [param old_priority],
## to [param new_priority], if found inside the [NodeCameraRecordStorage].
func reorder(
	record: LayerRecord, new_priority : int, old_priority : int
) -> void:
	if old_priority == new_priority:
		return
	_remove_from_bucket(record, old_priority)
	_insert_into_bucket(record, new_priority)

## Returns the previously-constructed of this [NodeCameraRecordStorage].
func get_flat_list() -> Array[LayerRecord]:
	return _flat_layer_list
## Returns if there are no stored records in this [NodeCameraRecordStorage].
## [br][br]
## [b]NOTE[/b]: This is different from the size of [method get_flat_list].
func is_empty() -> bool:
	return _priority_record.is_empty()
#endregion

# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
