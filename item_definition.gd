extends Resource
class_name ItemDefinition

## Static, shareable data for a loot item type.
## Runtime state belongs in ItemInstance; WorldItem (Step 3) will point at one
## of these definitions and create/own an ItemInstance when needed.

@export var item_id: StringName = &"item"
@export var display_name: String = "Item"

# Player-facing primary utility. This is what the generic inspection/HUD can
# show without knowing which request destination is being targeted.
@export var utility_id: StringName = &"None"
@export_range(0, 999, 1) var utility_value: int = 0

# Optional destination-specific overrides for the confirmed multi-purpose-item
# rule. Example value:
# { &"medical_bay": {"utility_id": &"Medical", "value": 2} }
# A request system can ask for its own context without adding an allocation UI.
@export var context_utility_overrides: Dictionary = {}

# The same Bulk value is used for player carry capacity, scavenger loadouts,
# and generated haul budgets.
@export_range(1, 999, 1) var bulk: int = 1

# Abstract storage footprint for deterministic storage later. This is not a
# literal geometric volume; it is the item's authored storage footprint.
@export var storage_footprint: Vector3i = Vector3i.ONE
@export var stackable: bool = false

@export_range(0, 999, 1) var salvage_yield: int = 0

# Deferred contamination system data. Harmless to carry in the definition now
# and avoids having to change the item schema later.
@export var can_be_contaminated: bool = false
@export var can_contaminate: bool = false

# The same PackedScene can later be instantiated in the world, as the selected
# held-item viewmodel, and here in a HUD preview viewport.
@export var visual_scene: PackedScene
@export var icon: Texture2D

# Per-item corrections for live 3D HUD previews. Defaults work for ordinary
# upright props; irregular/source assets can override these without changing
# the preview renderer.
@export var preview_rotation_degrees: Vector3 = Vector3(-15.0, 35.0, 0.0)
@export_range(0.25, 2.0, 0.05) var preview_zoom: float = 1.0


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
