extends Resource
class_name ItemDefinition

## Static, shareable data for a loot item type.
## Runtime state belongs in ItemInstance; world representations reference the
## same definition so HUD previews, held visuals and world visuals stay unified.

@export var item_id: StringName = &"item"
@export var display_name: String = "Item"

# Player-facing primary utility.
@export var utility_id: StringName = &"None"
@export_range(0, 999, 1) var utility_value: int = 0

# Optional destination-specific overrides for the confirmed multi-purpose-item
# rule. Example:
# { &"medical_bay": {"utility_id": &"Medical", "value": 2} }
@export var context_utility_overrides: Dictionary = {}

# Unified Bulk used for player carrying, scavenger loadouts and haul budgets.
@export_range(1, 999, 1) var bulk: int = 1

# Abstract deterministic-storage footprint, not literal geometric volume.
@export var storage_footprint: Vector3i = Vector3i.ONE
@export var stackable: bool = false

@export_range(0, 999, 1) var salvage_yield: int = 0

# Deferred contamination-system data.
@export var can_be_contaminated: bool = false
@export var can_contaminate: bool = false

# The same PackedScene is reused in the world, held-item view and HUD preview.
@export var visual_scene: PackedScene
@export var icon: Texture2D

# Live HUD preview presentation data.
@export var preview_auto_orient: bool = true
@export var preview_rotation_degrees: Vector3 = Vector3(-8.0, 12.0, 0.0)
@export_range(0.25, 2.0, 0.05) var preview_zoom: float = 1.0

# Held-item presentation data. Automatic orientation uses the same broad-side
# heuristic as the HUD. Items are never enlarged beyond their authored world
# scale by the generic viewmodel; oversized items may be shrunk to fit.
@export var held_auto_orient: bool = true
@export var held_rotation_degrees: Vector3 = Vector3(-10.0, -18.0, -8.0)
@export var held_offset: Vector3 = Vector3(0.28, -0.24, -0.58)
@export_range(0.10, 1.50, 0.05) var held_max_dimension: float = 0.55


func get_utility_for_context(context_id: StringName) -> Dictionary:
	if context_utility_overrides.has(context_id):
		var override_value: Variant = context_utility_overrides[context_id]
		if override_value is Dictionary:
			return override_value
	return {"utility_id": utility_id, "value": utility_value}


func utility_text() -> String:
	if utility_value <= 0 or utility_id == &"None":
		return "No utility"
	return "+%d %s" % [utility_value, String(utility_id)]
