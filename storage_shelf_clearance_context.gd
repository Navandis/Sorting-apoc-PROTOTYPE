extends Node
class_name StorageShelfClearanceContext

## Per-placement world context for a runtime-generated shelf profile.
## This is deliberately a world-metre distance above the open top surface and
## is never multiplied by the furniture's visual scale.

@export_range(0.001, 100.0, 0.001, "or_greater") var open_top_clearance_world_m: float = 1.0
