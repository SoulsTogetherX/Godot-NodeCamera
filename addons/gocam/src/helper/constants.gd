## The script containing all shared constants used by the GoCamera2D addon.

#region Enums
## An enum used to denote at what times layers will run for
## each [GoCamera2DHost].
enum CALLBACK_MODES {
	IDLE, ## Layers will run on process frames.
	PHYSICS, ## Layers will run on physics frames.
	MANUAL ## Layers will run when manually requested to run. See [method GoCamera2DHost.manual_tick]
}
#endregion
