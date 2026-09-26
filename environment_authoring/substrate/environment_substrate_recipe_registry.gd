class_name EnvironmentSubstrateRecipeRegistry
extends RefCounted

# Canonical local axes for every recipe: X width, Y height, Z depth.
# A wall's authored Front normal is +Z.
const RECIPES := {
	"rect_solid": {
		"purpose": "Closed rectangular structural prism for walls, slabs, beams, columns, thresholds, ledges and returns.",
		"canonical_axes": "X width; Y height; Z depth; wall Front +Z; pivot at outer AABB centre",
		"parameters": ["dimensions_m", "bevel_width_m"],
		"limitations": "All twelve edges share one small optional rounded bevel. No exposure solver.",
		"revision": 1,
	},
	"wall_with_rect_opening": {
		"purpose": "One thick continuous wall with a bounded rectangular through-opening and real reveals.",
		"canonical_axes": "X width; Y height; Z thickness; Front +Z; pivot at outer AABB centre",
		"parameters": ["dimensions_m", "opening_width_m", "opening_height_m", "opening_offset_x_m", "opening_bottom_m"],
		"limitations": "One axis-aligned through-opening; no bevel. Bottom may be zero for a doorway.",
		"revision": 1,
	},
	"wall_with_two_rect_openings": {
		"purpose": "Continuous thick wall with two separated through-openings and independent sill heights.",
		"canonical_axes": "X width; Y height; Z thickness; Front +Z; pivot at outer AABB centre",
		"parameters": ["dimensions_m", "opening_width_m", "opening_height_m", "opening_offset_x_m", "opening_bottom_m", "second_opening_width_m", "second_opening_height_m", "second_opening_offset_x_m", "second_opening_bottom_m"],
		"limitations": "Two horizontally separated axis-aligned openings; no bevel; not an arbitrary polygon cutter.",
		"revision": 1,
	},
}


func recipe_ids() -> PackedStringArray:
	return PackedStringArray(RECIPES.keys())


func metadata(recipe_id: String) -> Dictionary:
	return (RECIPES.get(recipe_id, {}) as Dictionary).duplicate(true)
