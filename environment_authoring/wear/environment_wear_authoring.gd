@tool
class_name EnvironmentWearAuthoring
extends EnvironmentWearOverlay

## Place approved EAF4 wear with node-owned settings. No Make Unique step is needed.
## Texture assets and approved default resources remain shared and read-only here.
const Query = preload("res://environment_authoring/wear/environment_wear_catalog_query.gd")
static var _sources: Array[Dictionary] = []
static var _catalog_loaded := false

@export_group("Approved Source")
## Readable dropdown; the suffix is the stable catalog identity, never a list index.
## Explicit source switches retain all authored values, including appearance.
@export var approved_source := "":
    set(value):
        approved_source = value
        _resolve_source()
        request_refresh()
## Current catalog restrictions for this source; source approval is not universal placement approval.
@export_multiline var approved_usage_notes: String:
    get:
        for source in approved_sources():
            if source["id"] == source_id():
                return str(source["record"].get("review_notes", ""))
        return "Choose a current approved source to see its usage restrictions."
    set(_value):
        pass

## Uses the selected source's appearance defaults. Turn off to return to authored values.
## Dimensions, transform, surface offset and mirroring stay authored in either mode.
@export var use_approved_appearance_defaults := false:
    set(value):
        use_approved_appearance_defaults = value
        request_refresh()
        notify_property_list_changed()

@export_group("Dimensions and Placement")
## Local width in metres, before ordinary positive node/ancestor scaling. Valid: (0, 8].
@export_range(0.001, 8.0, 0.01, "suffix:m") var width_m := 1.0:
    set(value):
        width_m = value
        _property_edited("width_m")
## Local height in metres along the quad's local Y axis. Valid: (0, 8].
@export_range(0.001, 8.0, 0.01, "suffix:m") var height_m := 1.0:
    set(value):
        height_m = value
        _property_edited("height_m")
## Offset along local +Z (surface normal); positive Z scale also scales this offset.
@export_range(0.0005, 0.01, 0.0001, "suffix:m") var surface_offset_m := 0.002:
    set(value):
        surface_offset_m = value
        _property_edited("surface_offset_m")

@export_group("Appearance")
## SOFT_BLEND multiplies alpha. CUTOUT also tests the result against the existing 0.28 scissor threshold.
@export_range(0.0, 1.0) var opacity_multiplier := 1.0:
    set(value):
        opacity_multiplier = value
        _property_edited("opacity_multiplier")
## Existing shader: mix(tint.rgb, source.rgb, strength). 0 = tint; 1 = source colour.
## This does not multiply tint by source colour or blend toward the substrate.
@export_range(0.0, 1.0) var albedo_strength := 0.5:
    set(value):
        albedo_strength = value
        _property_edited("albedo_strength")
## Tint contributes at (1 - albedo_strength). Tint alpha is unused by the existing shader.
@export var albedo_tint := Color.WHITE:
    set(value):
        albedo_tint = value
        _property_edited("albedo_tint")
## Normal map depth, shown only when this source has a normal map.
@export_range(0.0, 2.0) var normal_strength := 1.0:
    set(value):
        normal_strength = value
        _property_edited("normal_strength")
## Blend from fixed roughness 0.8 toward the source map, not substrate roughness.
@export_range(0.0, 1.0) var roughness_strength := 1.0:
    set(value):
        roughness_strength = value
        _property_edited("roughness_strength")
## Narrow UV border fade. Available only for SOFT_BLEND sources.
@export_range(0.0, 0.2) var edge_feather := 0.035:
    set(value):
        edge_feather = value
        _property_edited("edge_feather")

@export_group("Advanced Surface")
@export var normal_y_flip := false:
    set(value):
        normal_y_flip = value
        _property_edited("normal_y_flip")
@export_group("Advanced Imperfection")
@export var imperfection_scale := Vector2.ONE:
    set(value):
        imperfection_scale = value
        _property_edited("imperfection_scale")
@export_range(-360.0, 360.0) var imperfection_rotation := 0.0:
    set(value):
        imperfection_rotation = value
        _property_edited("imperfection_rotation")
@export_range(0.1, 4.0) var imperfection_contrast := 1.0:
    set(value):
        imperfection_contrast = value
        _property_edited("imperfection_contrast")
@export_range(0.0, 1.0) var imperfection_strength := 0.0:
    set(value):
        imperfection_strength = value
        _property_edited("imperfection_strength")

# Defaults initialize only in the tree, after deserialization has restored this
# marker and all fields (including deliberate values omitted as script defaults).
# Ordinary refresh never initializes defaults.
@export_storage var _appearance_initialized := false
var _defaults: EnvironmentWearOverlaySpec
var _source_error := "Choose an approved source."
var _building := false
var _pre_tree_authored_fields: PackedStringArray = []
const APPEARANCE_FIELDS = ["opacity_multiplier", "albedo_strength", "albedo_tint",
    "normal_strength", "normal_y_flip", "roughness_strength", "edge_feather",
    "imperfection_scale", "imperfection_rotation", "imperfection_contrast", "imperfection_strength"]

static func approved_sources() -> Array[Dictionary]:
    if not _catalog_loaded:
        _catalog_loaded = true
        for entry in Query.query():
            var surfaces: Array = entry.get("surface_capabilities", [])
            if entry.get("semantic_category") == "IMPERFECTION_MASK" or not ("FLOOR" in surfaces or "WALL" in surfaces or "PLANAR_ANY" in surfaces):
                continue
            # The current catalog's only material-patch entry is DEFERRED. Do not
            # promote it or silently treat a future patch approval as an overlay.
            if not str(entry.get("patch_mode", "")).is_empty():
                continue
            var id := str(entry["catalog_wear_id"])
            var path := "res://data/environment/wear_catalog/approved_specs/%s.tres" % id
            var source := load(path) as EnvironmentWearOverlaySpec if ResourceLoader.exists(path) else null
            var label := source.display_name if source != null else str(entry["source_stable_id"]).get_slice(":", 2).replace("_", " ").capitalize()
            _sources.append({"id": id, "label": label, "path": path, "record": entry})
        _sources.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return a["label"] < b["label"])
    return _sources.duplicate(true)

func source_id() -> String:
    return approved_source.get_slice(" | ", 1) if " | " in approved_source else approved_source

func _resolve_source() -> void:
    _disconnect_defaults()
    _defaults = null
    _source_error = "Choose an approved source."
    for source in approved_sources():
        if source["id"] != source_id():
            continue
        _defaults = load(source["path"]) as EnvironmentWearOverlaySpec if ResourceLoader.exists(source["path"]) else null
        if _defaults == null:
            _source_error = "Approved source resource is missing; restage the approved cache."
            break
        var record: Dictionary = source["record"]
        if _defaults.overlay_id != source["id"] or _defaults.source_stable_id != record["source_stable_id"] or _defaults.source_fingerprint != record["current_source_fingerprint"] or record["current_source_fingerprint"] != record["reviewed_source_fingerprint"]:
            _defaults = null
            _source_error = "Approved resource identity/fingerprint does not match the current catalog."
            break
        _source_error = ""
        _defaults.changed.connect(_on_defaults_changed)
        if is_inside_tree() and not _appearance_initialized:
            _appearance_initialized = true
            if "width_m" not in _pre_tree_authored_fields:
                width_m = _defaults.physical_size_m.x
            if "height_m" not in _pre_tree_authored_fields:
                height_m = _defaults.physical_size_m.y
            if "surface_offset_m" not in _pre_tree_authored_fields:
                surface_offset_m = _defaults.surface_offset_m
            for field in APPEARANCE_FIELDS:
                if field not in _pre_tree_authored_fields:
                    set(field, _defaults.get(field))
            _pre_tree_authored_fields.clear()
        break
    if _defaults == null and not approved_source.is_empty() and _source_error == "Choose an approved source.":
        _source_error = "Source is not a current approved floor/wall overlay."
    notify_property_list_changed()

func _disconnect_defaults() -> void:
    if _defaults != null and _defaults.changed.is_connected(_on_defaults_changed):
        _defaults.changed.disconnect(_on_defaults_changed)

func _on_defaults_changed() -> void:
    _resolve_source()
    request_refresh()

func _enter_tree() -> void:
    _resolve_source()
    super._enter_tree()

func _exit_tree() -> void:
    _disconnect_defaults()
    super._exit_tree()

func _property_edited(field: String) -> void:
    # Explicit .tscn/programmatic values before first tree entry take precedence
    # over approved defaults, even if equal to the script default.
    if not is_inside_tree() and not _appearance_initialized and field not in _pre_tree_authored_fields:
        _pre_tree_authored_fields.append(field)
    request_refresh()

func request_refresh() -> void:
    if not _building:
        super.request_refresh()

func regenerate() -> void:
    _building = true
    var effective := _defaults.duplicate(false) as EnvironmentWearOverlaySpec if _defaults != null else null
    if effective != null:
        effective.physical_size_m = Vector2(width_m, height_m)
        effective.surface_offset_m = surface_offset_m
        if not use_approved_appearance_defaults:
            for field in APPEARANCE_FIELDS:
                effective.set(field, get(field))
    spec = effective
    super.regenerate()
    _building = false

func uses_imperfection() -> bool:
    return use_approved_appearance_defaults or imperfection_enabled

func _get_configuration_warnings() -> PackedStringArray:
    if not _source_error.is_empty():
        return PackedStringArray([_source_error])
    return super._get_configuration_warnings()

func _validate_property(property: Dictionary) -> void:
    var field: String = property["name"]
    if field == "approved_usage_notes":
        property["usage"] = PROPERTY_USAGE_EDITOR | PROPERTY_USAGE_READ_ONLY
    elif field == "spec":
        property["usage"] = PROPERTY_USAGE_NONE
    elif field == "approved_source":
        var labels: PackedStringArray = [""]
        for source in approved_sources():
            labels.append("%s | %s" % [source["label"], source["id"]])
        property["hint"] = PROPERTY_HINT_ENUM
        property["hint_string"] = ",".join(labels)
    elif (field in ["normal_strength", "normal_y_flip"] and (_defaults == null or _defaults.normal_texture == null)) or (field == "roughness_strength" and (_defaults == null or _defaults.roughness_texture == null)) or (field == "edge_feather" and (_defaults == null or _defaults.render_mode != Spec.RenderMode.SOFT_BLEND)) or (field.begins_with("imperfection_") and (_defaults == null or _defaults.imperfection_mask_texture == null)):
        property["usage"] &= ~PROPERTY_USAGE_EDITOR
    elif use_approved_appearance_defaults and (field in APPEARANCE_FIELDS or field == "imperfection_enabled"):
        property["usage"] &= ~PROPERTY_USAGE_EDITOR
