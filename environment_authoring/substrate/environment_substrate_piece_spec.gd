class_name EnvironmentSubstratePieceSpec
extends Resource

const Registry = preload("res://environment_authoring/substrate/environment_substrate_recipe_registry.gd")
const EPSILON_M := 0.0001

enum CollisionPolicy { NONE, SIMPLE }

@export var piece_id := ""
@export var recipe_id := "rect_solid"
@export var semantic_role := ""
@export var dimensions_m := Vector3.ONE
@export var bevel_width_m := 0.0
@export_range(0, 3, 1) var uv_quarter_turns := 0
@export var uv_origin_m := Vector2.ZERO
@export var collision_policy: CollisionPolicy = CollisionPolicy.NONE
@export var material_spec: EnvironmentSurfaceMaterialSpec
@export var generation_revision := 1
@export_multiline var authoring_notes := ""

# Controlled parameters for the first wall opening.
@export_group("First opening")
@export var opening_width_m := 0.0
@export var opening_height_m := 0.0
@export var opening_offset_x_m := 0.0
@export var opening_bottom_m := 0.0

# Extension parameters for the second opening. Ignored by initial recipes.
@export_group("Second opening")
@export var second_opening_width_m := 0.0
@export var second_opening_height_m := 0.0
@export var second_opening_offset_x_m := 0.0
@export var second_opening_bottom_m := 0.0


func validate() -> PackedStringArray:
	var errors := PackedStringArray()
	if piece_id.strip_edges().is_empty():
		errors.append("piece_id is required")
	if semantic_role.strip_edges().is_empty():
		errors.append("semantic_role is required")
	var recipe := Registry.new().metadata(recipe_id)
	if recipe_id.strip_edges().is_empty() or recipe.is_empty():
		errors.append("unknown recipe_id")
	if not _positive(dimensions_m.x) or not _positive(dimensions_m.y) or not _positive(dimensions_m.z):
		errors.append("dimensions_m must contain finite positive metres")
	if not is_finite(bevel_width_m) or bevel_width_m < 0.0:
		errors.append("bevel_width_m must be finite and nonnegative")
	elif recipe_id == "rect_solid" and bevel_width_m * 2.0 >= minf(dimensions_m.x, minf(dimensions_m.y, dimensions_m.z)) - EPSILON_M:
		errors.append("bevel_width_m consumes the solid")
	elif recipe_id == "rect_solid" and bevel_width_m > minf(0.10, minf(dimensions_m.x, minf(dimensions_m.y, dimensions_m.z)) * 0.25):
		errors.append("bevel_width_m exceeds conservative edge limit")
	elif recipe_id != "rect_solid" and bevel_width_m != 0.0:
		errors.append("wall opening recipes do not support bevel")
	if uv_quarter_turns < 0 or uv_quarter_turns > 3:
		errors.append("uv_quarter_turns must be 0..3")
	if not is_finite(uv_origin_m.x) or not is_finite(uv_origin_m.y):
		errors.append("uv_origin_m must be finite")
	if collision_policy < CollisionPolicy.NONE or collision_policy > CollisionPolicy.SIMPLE:
		errors.append("invalid collision_policy")
	if generation_revision < 1:
		errors.append("generation_revision must be positive")
	if material_spec == null or not material_spec.validate().is_empty():
		errors.append("valid EAF1 material_spec is required")
	if recipe_id == "wall_with_rect_opening" or recipe_id == "wall_with_two_rect_openings":
		_validate_opening(errors, opening_width_m, opening_height_m, opening_offset_x_m, opening_bottom_m, "first")
	if recipe_id == "wall_with_two_rect_openings":
		_validate_opening(errors, second_opening_width_m, second_opening_height_m, second_opening_offset_x_m, second_opening_bottom_m, "second")
		var first_right := opening_offset_x_m + opening_width_m * 0.5
		var first_left := opening_offset_x_m - opening_width_m * 0.5
		var second_right := second_opening_offset_x_m + second_opening_width_m * 0.5
		var second_left := second_opening_offset_x_m - second_opening_width_m * 0.5
		var overlap_m := minf(first_right, second_right) - maxf(first_left, second_left)
		if overlap_m > EPSILON_M:
			errors.append("openings overlap horizontally")
		elif overlap_m >= -EPSILON_M:
			errors.append("openings need a positive central pier")
	return errors


func exact_parameters() -> Dictionary:
	var values := {
		"dimensions_m": [dimensions_m.x, dimensions_m.y, dimensions_m.z],
		"bevel_width_m": bevel_width_m,
	}
	if recipe_id != "rect_solid":
		values["opening_width_m"] = opening_width_m
		values["opening_height_m"] = opening_height_m
		values["opening_offset_x_m"] = opening_offset_x_m
		values["opening_bottom_m"] = opening_bottom_m
	if recipe_id == "wall_with_two_rect_openings":
		values["second_opening_width_m"] = second_opening_width_m
		values["second_opening_height_m"] = second_opening_height_m
		values["second_opening_offset_x_m"] = second_opening_offset_x_m
		values["second_opening_bottom_m"] = second_opening_bottom_m
	return values


func opening_rectangles() -> Array[Rect2]:
	var result: Array[Rect2] = []
	if recipe_id == "wall_with_rect_opening" or recipe_id == "wall_with_two_rect_openings":
		result.append(Rect2(Vector2(opening_offset_x_m - opening_width_m * 0.5, -dimensions_m.y * 0.5 + opening_bottom_m), Vector2(opening_width_m, opening_height_m)))
	if recipe_id == "wall_with_two_rect_openings":
		result.append(Rect2(Vector2(second_opening_offset_x_m - second_opening_width_m * 0.5, -dimensions_m.y * 0.5 + second_opening_bottom_m), Vector2(second_opening_width_m, second_opening_height_m)))
	return result


func _validate_opening(errors: PackedStringArray, width: float, height: float, offset_x: float, bottom: float, label: String) -> void:
	if not _positive(width) or not _positive(height) or not is_finite(offset_x) or not is_finite(bottom):
		errors.append("%s opening parameters must be finite and positive" % label)
		return
	if absf(offset_x) + width * 0.5 >= dimensions_m.x * 0.5 - EPSILON_M:
		errors.append("%s opening needs left and right piers" % label)
	if bottom < 0.0 or bottom + height >= dimensions_m.y - EPSILON_M:
		errors.append("%s opening needs a header and nonnegative sill" % label)


func _positive(value: float) -> bool:
	return is_finite(value) and value > 0.0
