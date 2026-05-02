class_name NodeCamera2DConstants

# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
## The script containing all shared constants used by the NodeCamera2D addon.

#region Enums
## An enum used to denote at what times layers will run for
## each [NodeCamera2DHost].
enum CALLBACK_MODES {
	AUTO,
	IDLE, ## Layers will run on process frames.
	PHYSICS, ## Layers will run on physics frames.
	MANUAL ## Layers will run when manually requested to run. See [method NodeCamera2DHost.manual_tick]
}


enum DIRTY_FLAGS {
	STRUCTURE_CHANGED = 1 << 0,
	CLEAR_LAYERS = 1 << 1,
	LAYER_REMOVE = 1 << 2,
	LAYER_REORDER = 1 << 3,
	LAYER_ADD = 1 << 4,
	LAYER_STAGE_CHANGED = 1 << 5,
	LAYER_STAGE_MASK_CHANGED = 1 << 6,
}


enum LAYER_STAGES {
	HAULTED = 1 << 0,
	ENDING = 1 << 1,
	RUNNING = 1 << 2,
	STARTING = 1 << 3,
}
#endregion

# Made by Xavier Alvarez. A part of the "NodeCam" Godot addon.
