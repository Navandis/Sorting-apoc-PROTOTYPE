class_name EnvironmentSurfaceMaterialSpec
extends Resource

enum MappingMode { UV, TRIPLANAR, WORLD_TRIPLANAR }

@export var material_id := ""
@export var display_name := ""
@export var base_color_texture: Texture2D
@export var normal_texture: Texture2D
@export var roughness_texture: Texture2D
@export var metallic_texture: Texture2D
@export var ao_texture: Texture2D
@export var height_texture: Texture2D # Provenance only; EAF1 never binds displacement.
@export var mapping_mode: MappingMode = MappingMode.UV
@export_range(0.01, 100.0, 0.01) var meters_per_repeat := 1.0
@export_range(0.0, 4.0, 0.01) var normal_strength := 1.0
@export_range(0.0, 2.0, 0.01) var roughness_multiplier := 1.0
@export_range(0.0, 2.0, 0.01) var metallic_multiplier := 1.0
@export_range(0.0, 2.0, 0.01) var albedo_multiplier := 1.0
@export var normal_y_flip := false
@export var surface_family := ""
@export var vdd_layer := ""
@export var source_label := ""
@export var source_path := ""
@export_multiline var review_notes := ""


func validate() -> PackedStringArray:
	var errors := PackedStringArray()
	if material_id.strip_edges().is_empty():
		errors.append("material_id is required")
	if base_color_texture == null:
		errors.append("base_color_texture is required")
	if not is_finite(meters_per_repeat) or meters_per_repeat <= 0.0:
		errors.append("meters_per_repeat must be positive")
	if mapping_mode < MappingMode.UV or mapping_mode > MappingMode.WORLD_TRIPLANAR:
		errors.append("unsupported mapping_mode")
	if not _in_range(normal_strength, 0.0, 4.0):
		errors.append("normal_strength must be within 0..4")
	if not _in_range(roughness_multiplier, 0.0, 2.0):
		errors.append("roughness_multiplier must be within 0..2")
	if not _in_range(metallic_multiplier, 0.0, 2.0):
		errors.append("metallic_multiplier must be within 0..2")
	if not _in_range(albedo_multiplier, 0.0, 2.0):
		errors.append("albedo_multiplier must be within 0..2")
	return errors


func mapping_name() -> String:
	return MappingMode.keys()[mapping_mode] if mapping_mode >= MappingMode.UV and mapping_mode <= MappingMode.WORLD_TRIPLANAR else "INVALID"


func _in_range(value: float, minimum: float, maximum: float) -> bool:
	return is_finite(value) and value >= minimum and value <= maximum
