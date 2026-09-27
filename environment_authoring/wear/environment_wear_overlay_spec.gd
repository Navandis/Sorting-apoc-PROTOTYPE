@tool
class_name EnvironmentWearOverlaySpec
extends Resource

enum RenderMode { CUTOUT, SOFT_BLEND }

@export var overlay_id := ""
@export var display_name := ""
@export var source_stable_id := ""
@export var source_fingerprint := ""
@export var semantic_category := ""
@export var cause_tags: PackedStringArray = []
@export var surface_capabilities: PackedStringArray = []
@export var render_mode: RenderMode = RenderMode.CUTOUT
@export var physical_size_m := Vector2(0.5, 0.5)
@export_range(0.0005, 0.01, 0.0001) var surface_offset_m := 0.002
@export var base_color_texture: Texture2D
@export var opacity_texture: Texture2D
@export var normal_texture: Texture2D
@export var roughness_texture: Texture2D
@export var metallic_texture: Texture2D
@export var embedded_alpha := false
@export var atlas_region := Vector4(0.0, 0.0, 1.0, 1.0)
@export_range(0.0, 1.0) var opacity_multiplier := 1.0
@export_range(0.0, 1.0) var albedo_strength := 0.5
@export var albedo_tint := Color.WHITE
@export_range(0.0, 2.0) var normal_strength := 1.0
@export var normal_y_flip := false
@export_range(0.0, 1.0) var roughness_strength := 1.0
@export_range(0.0, 0.2) var edge_feather := 0.035
@export var imperfection_mask_texture: Texture2D
@export var imperfection_scale := Vector2.ONE
@export_range(-360.0, 360.0) var imperfection_rotation := 0.0
@export_range(0.1, 4.0) var imperfection_contrast := 1.0
@export_range(0.0, 1.0) var imperfection_strength := 0.0
@export_multiline var review_notes := ""

func validate() -> PackedStringArray:
    var errors: PackedStringArray = []
    if overlay_id.is_empty():
        errors.append("overlay_id required")
    if source_stable_id.is_empty():
        errors.append("source_stable_id required")
    if source_fingerprint.length() != 64:
        errors.append("strong source_fingerprint required")
    if not is_finite(physical_size_m.x) or not is_finite(physical_size_m.y) or physical_size_m.x <= 0.0 or physical_size_m.y <= 0.0 or physical_size_m.x > 8.0 or physical_size_m.y > 8.0:
        errors.append("physical_size_m outside (0, 8] metres")
    if not is_finite(surface_offset_m) or surface_offset_m < 0.0005 or surface_offset_m > 0.01:
        errors.append("surface_offset_m outside review bounds")
    if base_color_texture == null and opacity_texture == null:
        errors.append("overlay needs color or opacity texture")
    if opacity_texture == null and not embedded_alpha:
        errors.append("overlay needs separate opacity or embedded alpha")
    if atlas_region.x < 0.0 or atlas_region.y < 0.0 or atlas_region.z <= 0.0 or atlas_region.w <= 0.0 or atlas_region.x + atlas_region.z > 1.0 or atlas_region.y + atlas_region.w > 1.0:
        errors.append("atlas_region must be normalized offset and size")
    if render_mode not in [RenderMode.CUTOUT, RenderMode.SOFT_BLEND]:
        errors.append("unsupported render mode")
    if not is_finite(opacity_multiplier) or opacity_multiplier < 0.0 or opacity_multiplier > 1.0:
        errors.append("opacity_multiplier outside [0, 1]")
    if not is_finite(albedo_strength) or albedo_strength < 0.0 or albedo_strength > 1.0:
        errors.append("albedo_strength outside [0, 1]")
    if not is_finite(normal_strength) or normal_strength < 0.0 or normal_strength > 2.0:
        errors.append("normal_strength outside [0, 2]")
    if not is_finite(roughness_strength) or roughness_strength < 0.0 or roughness_strength > 1.0:
        errors.append("roughness_strength outside [0, 1]")
    if not is_finite(edge_feather) or edge_feather < 0.0 or edge_feather > 0.2:
        errors.append("edge_feather outside [0, 0.2]")
    if not is_finite(imperfection_scale.x) or not is_finite(imperfection_scale.y) or imperfection_scale.x <= 0.0 or imperfection_scale.y <= 0.0:
        errors.append("imperfection scale must be positive")
    if not is_finite(imperfection_rotation) or not is_finite(imperfection_contrast) or imperfection_contrast < 0.1 or imperfection_contrast > 4.0:
        errors.append("invalid imperfection rotation or contrast")
    if not is_finite(imperfection_strength) or imperfection_strength < 0.0 or imperfection_strength > 1.0:
        errors.append("imperfection_strength outside [0, 1]")
    return errors
