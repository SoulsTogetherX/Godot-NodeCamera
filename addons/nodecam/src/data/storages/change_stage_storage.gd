# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
@tool
class_name NodeCameraStageChangeStorage extends Object
## Stores a buffer of requests to change layer's stages, and provides a method
## to flush/handle those requests.

#region Private Variables
var _records : Array[ChangeStageRecord] = []
#endregion



#region Private Methods
func _sort_helper(
	ncs1 : ChangeStageRecord, ncs2 : ChangeStageRecord
) -> bool:
	return	(ncs1.type < ncs2.type || (ncs1.type == ncs2.type &&
				(ncs1.stage > ncs2.stage || (ncs1.stage == ncs2.stage &&
					ncs1.layer.priority > ncs2.layer.priority
				))
			))
#endregion


#region Public Methods
## Requests a [param layer] node to change to stage [param stage], to be handled
## later.
## [br][br]
## Also see [method flush].
func add_to_queue(
	layer : NodeCameraStaged,
	stage : NodeCameraUtility.LAYER_STAGES
) -> void:
	var record := ChangeStageRecord.new()
	record.layer = layer
	record.stage = stage
	record.type = (
		NodeCameraExecutionScope.TICK_TYPE.EFFECTS if layer is NodeCameraEffect
		else NodeCameraExecutionScope.TICK_TYPE.TRANSITIONS
	)
	_records.append(record)

## Handles and clears all previous stage change requests.
## [br][br]
## Also see [method add_to_queue].
func flush(
	target : NodeCameraState, current : NodeCameraState
) -> void:
	if _records.size() > 1:
		_records.sort_custom(_sort_helper)
	
	var ret : PackedStringArray = []
	for record : ChangeStageRecord in _records:
		ret.append(record.layer.name)
		
		if record.type == NodeCameraExecutionScope.TICK_TYPE.EFFECTS:
			record.layer.effect_stage_changed(
				target, record.stage
			)
			continue
		record.layer.transition_stage_changed(
			target, current, record.stage
		)
	
	_records.clear()
#endregion

# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
