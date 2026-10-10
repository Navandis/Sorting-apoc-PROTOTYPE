@tool
class_name ImperfectionAudition
extends Node3D
## Visual-only scalar layers. Catalog decisions govern source uses; no substrate edit.
const MANIFEST = "res://environment_authoring/wear/imperfection_experiments/manifest.json"
const SHADER = preload("res://environment_authoring/wear/imperfection_experiments/imperfection_audition.gdshader")
const Overlay = preload("res://environment_authoring/wear/environment_wear_overlay.gd")
const Query = preload("res://environment_authoring/wear/environment_wear_catalog_query.gd")
const EFFECT_IDS = ["eaf4b_e890439d8e117d36ac05e55c", "eaf4b_cd7701bd0cdb622c63628103"]

@export_multiline var experiment_notes: String:
    get:
        var source = selected_candidate()
        var status := "UNREVIEWED"
        var uses: Array = []
        var reviewed_channel := "UNSPECIFIED"
        for record in Query.load_catalog():
            if record.get("source_stable_id") == source_id():
                status = str(record.get("effective_status", "UNKNOWN"))
                uses = record.get("supported_uses", [])
                reviewed_channel = str(record.get("scalar_channel", "UNSPECIFIED"))
        var note := "Catalog source status: " + status + ". Placement acceptance is separate."
        note += "\nReviewed scalar channel: " + reviewed_channel + "; supported uses: " + str(uses)
        note += "\nSample: " + str(source.get("channel", "MISSING")) + ".red (1K); scalar distribution only, not substrate roughness/colour/normal."
        note += "\nSource size estimate: " + str(source.get("physical_size_estimate_m", [])) + " m; practical starting patch 1×1 m."
        note += "\nMode B supports only the two approved soft Leakage overlays, intended for vertical walls. Floor modulation is diagnostic only."
        for effect in effect_sources():
            if effect.id == effect_id(): note += "\nWear restrictions: " + str(effect.record.get("review_notes", ""))
        return note
    set(_value): pass

@export_group("Mask and Mode")
@export var mask_source := "":
    set(value):
        mask_source = value
        request_refresh()
@export_enum("Grayscale Diagnostic", "Tinted Opacity Illustration", "Approved Wear Modulation") var preview_mode := 0:
    set(value):
        preview_mode = value
        request_refresh()
        notify_property_list_changed()

@export_group("Dimensions and Placement")
@export_range(0.001, 8.0, 0.01, "suffix:m") var width_m := 1.0:
    set(value):
        width_m = value
        request_refresh()
@export_range(0.001, 8.0, 0.01, "suffix:m") var height_m := 1.0:
    set(value):
        height_m = value
        request_refresh()
@export_range(0.0005, 0.01, 0.0001, "suffix:m") var surface_offset_m := 0.002:
    set(value):
        surface_offset_m = value
        request_refresh()

@export_group("Appearance")
@export_range(0.0, 1.0) var opacity_multiplier := 0.5:
    set(value):
        opacity_multiplier = value
        request_refresh()
@export var albedo_tint := Color(0.45, 0.45, 0.45):
    set(value):
        albedo_tint = value
        request_refresh()
@export_range(0.0, 1.0) var albedo_strength := 0.5:
    set(value):
        albedo_strength = value
        request_refresh()

@export_group("Scalar Distribution")
@export var mask_repeat := Vector2.ONE:
    set(value):
        mask_repeat = value
        request_refresh()
@export_range(-360.0, 360.0) var mask_rotation_degrees := 0.0:
    set(value):
        mask_rotation_degrees = value
        request_refresh()
@export_range(0.1, 4.0) var scalar_contrast := 1.0:
    set(value):
        scalar_contrast = value
        request_refresh()
@export_range(-1.0, 1.0) var scalar_bias := 0.0:
    set(value):
        scalar_bias = value
        request_refresh()
@export var invert_scalar := false:
    set(value):
        invert_scalar = value
        request_refresh()

@export_group("Approved Wear Comparison")
@export var wear_source := "leakage_skiubhzc | eaf4b_e890439d8e117d36ac05e55c":
    set(value):
        wear_source = value
        request_refresh()
@export var modulation_enabled := true:
    set(value):
        modulation_enabled = value
        request_refresh()
@export_range(0.0, 1.0) var mask_strength := 1.0:
    set(value):
        mask_strength = value
        request_refresh()

var effective_spec: EnvironmentWearOverlaySpec
var _refresh_pending := false
var _resource_error := ""

static func candidates() -> Array:
    var data: Variant = JSON.parse_string(FileAccess.get_file_as_string(MANIFEST))
    return data.get("candidates", []) if data is Dictionary and data.get("schema_version") == 1 else []

static func effect_sources() -> Array[Dictionary]:
    var result: Array[Dictionary] = []
    for record in Query.load_catalog():
        if record.get("catalog_wear_id") not in EFFECT_IDS or record.get("effective_status") != "APPROVED" or record.get("render_mode") != "SOFT_BLEND": continue
        result.append({"id":record.catalog_wear_id, "label":str(record.source_stable_id).get_slice(":",2), "path":"res://data/environment/wear_catalog/approved_specs/" + record.catalog_wear_id + ".tres", "record":record})
    return result

func source_id() -> String:
    return mask_source.get_slice(" | ",1) if " | " in mask_source else mask_source

func effect_id() -> String:
    return wear_source.get_slice(" | ",1) if " | " in wear_source else wear_source

func selected_candidate() -> Dictionary:
    for source in candidates():
        if source.stable_id == source_id(): return source
    return {}

func request_refresh() -> void:
    if is_inside_tree() and not _refresh_pending:
        _refresh_pending = true
        _refresh.call_deferred()

func _refresh() -> void:
    _refresh_pending = false
    if is_inside_tree():
        regenerate()
        if Engine.is_editor_hint(): update_configuration_warnings()

func _ready() -> void: regenerate()

func _get_configuration_warnings() -> PackedStringArray:
    var errors: PackedStringArray = []
    if not _resource_error.is_empty(): errors.append(_resource_error)
    var source := selected_candidate()
    if source.is_empty():
        errors.append("Choose an experimental Mask Source; unknown IDs never fall back.")
    else:
        var path := str(source.get("texture_path", ""))
        if not path.begins_with("res://assets/environment/wear/imperfection_experiments_cache/") or not FileAccess.file_exists(path):
            errors.append("Experimental source map missing. Run the one-shot staging tool; no substitute will render.")
        elif FileAccess.get_sha256(path) != source.get("sha256"):
            errors.append("Experimental cache fingerprint changed. Audit/restage the actual original; no substitute will render.")
    if preview_mode not in [0,1,2]: errors.append("Unsupported preview mode.")
    if not is_finite(width_m) or not is_finite(height_m) or width_m <= 0 or height_m <= 0 or width_m > 8 or height_m > 8: errors.append("Dimensions must be finite metres in (0,8].")
    if not is_finite(surface_offset_m) or surface_offset_m < 0.0005 or surface_offset_m > 0.01: errors.append("Surface offset must be 0.0005–0.01 m.")
    for value in [opacity_multiplier, albedo_strength, mask_strength]:
        if not is_finite(value) or value < 0 or value > 1: errors.append("Appearance and strength must be in [0,1].")
    if not is_finite(scalar_contrast) or scalar_contrast < 0.1 or scalar_contrast > 4 or not is_finite(scalar_bias) or absf(scalar_bias) > 1: errors.append("Scalar contrast/bias outside supported range.")
    if not mask_repeat.is_finite() or mask_repeat.x <= 0 or mask_repeat.y <= 0 or not is_finite(mask_rotation_degrees): errors.append("Mask repeat must be positive and rotation finite.")
    if is_inside_tree():
        var s := global_transform.basis.get_scale()
        if not s.is_finite() or s.x <= 0 or s.y <= 0 or s.z <= 0 or global_transform.basis.determinant() <= 0: errors.append("Use positive node/ancestor scale.")
    if preview_mode == 2:
        var found := false
        for effect in effect_sources():
            if effect.id != effect_id(): continue
            var defaults = load(effect.path) as EnvironmentWearOverlaySpec if ResourceLoader.exists(effect.path) else null
            if defaults != null and defaults.render_mode == EnvironmentWearOverlaySpec.RenderMode.SOFT_BLEND and defaults.overlay_id == effect.id and defaults.source_stable_id == effect.record.source_stable_id and defaults.source_fingerprint == effect.record.current_source_fingerprint and effect.record.current_source_fingerprint == effect.record.reviewed_source_fingerprint and defaults.validate().is_empty(): found = true
        if not found: errors.append("Choose one of the current approved soft Leakage effects; missing/stale/cutout effects are unsupported.")
    return errors

func regenerate() -> void:
    var quad := get_node_or_null("Quad") as MeshInstance3D
    if quad == null:
        quad = MeshInstance3D.new()
        quad.name = "Quad"
        add_child(quad)
    quad.owner = null
    effective_spec = null
    _resource_error = ""
    if not _get_configuration_warnings().is_empty():
        quad.hide()
        quad.mesh = null
        quad.material_override = null
        return
    var source := selected_candidate()
    var texture = load(source.texture_path) as Texture2D
    if texture == null:
        _resource_error = "Experimental source could not load as Texture2D. Import the staged cache in Godot, then edit/reopen this instance."
        quad.hide()
        quad.mesh = null
        quad.material_override = null
        return
    var material := ShaderMaterial.new()
    if preview_mode == 2:
        for effect in effect_sources():
            if effect.id != effect_id(): continue
            effective_spec = (load(effect.path) as EnvironmentWearOverlaySpec).duplicate(false)
            effective_spec.physical_size_m = Vector2(width_m,height_m)
            effective_spec.surface_offset_m = surface_offset_m
            effective_spec.opacity_multiplier = opacity_multiplier
            effective_spec.albedo_tint = albedo_tint
            effective_spec.albedo_strength = albedo_strength
            effective_spec.imperfection_mask_texture = texture
            effective_spec.imperfection_scale = mask_repeat
            effective_spec.imperfection_rotation = mask_rotation_degrees
            effective_spec.imperfection_contrast = scalar_contrast
            effective_spec.imperfection_strength = mask_strength if modulation_enabled else 0.0
            material = Overlay.build_material(effective_spec, false, false, false)
    material.shader = SHADER
    material.set_shader_parameter("preview_mode",preview_mode)
    material.set_shader_parameter("imperfection_texture",texture)
    material.set_shader_parameter("has_imperfection",preview_mode == 2 and modulation_enabled)
    material.set_shader_parameter("imperfection_scale",mask_repeat)
    material.set_shader_parameter("imperfection_rotation",deg_to_rad(mask_rotation_degrees))
    material.set_shader_parameter("imperfection_contrast",scalar_contrast)
    material.set_shader_parameter("scalar_bias",scalar_bias)
    material.set_shader_parameter("invert_scalar",invert_scalar)
    material.set_shader_parameter("imperfection_strength",mask_strength)
    material.set_shader_parameter("opacity_multiplier",opacity_multiplier)
    material.set_shader_parameter("albedo_tint",albedo_tint)
    material.set_shader_parameter("albedo_strength",albedo_strength)
    var mesh := QuadMesh.new()
    mesh.size = Vector2(width_m,height_m)
    quad.mesh = mesh
    quad.position = Vector3(0,0,surface_offset_m)
    quad.material_override = material
    quad.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
    quad.show()

func _validate_property(property: Dictionary) -> void:
    var field: String = property.name
    if field == "experiment_notes": property.usage = PROPERTY_USAGE_EDITOR | PROPERTY_USAGE_READ_ONLY
    elif field == "mask_source":
        var labels: PackedStringArray = [""]
        for source in candidates(): labels.append(source.name + " (" + source.slug + ") | " + source.stable_id)
        property.hint = PROPERTY_HINT_ENUM
        property.hint_string = ",".join(labels)
    elif field == "wear_source":
        var labels: PackedStringArray = []
        for effect in effect_sources(): labels.append(effect.label + " | " + effect.id)
        property.hint = PROPERTY_HINT_ENUM
        property.hint_string = ",".join(labels)
        if preview_mode != 2: property.usage = PROPERTY_USAGE_STORAGE
    elif field in ["modulation_enabled", "mask_strength", "albedo_strength"] and preview_mode != 2: property.usage = PROPERTY_USAGE_STORAGE
    elif field == "albedo_tint" and preview_mode == 0: property.usage = PROPERTY_USAGE_STORAGE
