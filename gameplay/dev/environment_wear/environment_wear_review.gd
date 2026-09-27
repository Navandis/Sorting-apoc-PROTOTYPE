extends Node3D

const ReviewSet = preload("res://environment_authoring/environment_material_review_set.gd")
const MaterialQuery = preload("res://environment_authoring/environment_material_catalog_query.gd")
const Overlay = preload("res://environment_authoring/wear/environment_wear_overlay.gd")
const Spec = preload("res://environment_authoring/wear/environment_wear_overlay_spec.gd")
const Patch = preload("res://environment_authoring/wear/environment_material_patch.gd")
const BATCH_ID := "wear_foundation_01"
const STAGE_PATH := "res://reports/environment_wear_catalog/reviews/wear_foundation_01/stage_manifest.json"
const SPEC_ROOT := "res://data/environment/wear_catalog/review_batches/wear_foundation_01/"
const CACHE_ROOT := "res://assets/environment/wear/eaf4_cache/"
const BASE_IDS := [
    "eaf3b_39b926e570fb3824019aade2",
    "eaf3b_bd0940113f04f3d3784629e7",
    "eaf3b_20c61bd1c85420be2f71a090",
    "eaf3b_8d5f0cf5add98dfe0a58f18a",
]
const CAMERA_NAMES := ["Hero", "WallGrazing", "FloorGrazing", "Context"]

var candidates: Array = []
var candidate_index := 0
var base_index := 0
var _review_node: Node3D
var _overlay: EnvironmentWearOverlay
var _patch: EnvironmentMaterialPatch
var _spec: EnvironmentWearOverlaySpec
var _base_ids: Array = []
var _imperfection_enabled := true
var _original_opacity := 1.0
var _original_albedo := 0.5
var _original_normal := 1.0
var _capture_running := false

func _ready() -> void:
    _review_node = get_node("Lookdev")
    _review_node.get_node("ReviewHUD").visible = false
    _create_review_cameras()
    var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(STAGE_PATH))
    if not parsed is Dictionary or not parsed.get("candidates") is Array:
        push_error("EAF4B missing stage manifest; run prepare")
        return
    candidates = parsed["candidates"]
    var review_set := ReviewSet.new()
    for base_id in BASE_IDS:
        var found := false
        for entry in MaterialQuery.query():
            if entry.get("catalog_material_id") == base_id:
                found = true
                break
        if not found:
            push_error("EAF4B base material is not current approved EAF3: " + base_id)
            return
        var approved := load("res://data/environment/material_catalog/approved_specs/%s.tres" % base_id) as Resource
        if approved == null:
            push_error("EAF4B missing approved EAF3 spec " + base_id)
            return
        review_set.specs.append(approved)
    _review_node.call("set_review_set", review_set)
    _overlay = Overlay.new()
    _overlay.name = "WearOverlay"
    add_child(_overlay)
    _patch = Patch.new()
    _patch.name = "MaterialPatch"
    add_child(_patch)
    set_candidate(0)
    if OS.get_cmdline_user_args().has("--eaf4b-capture"):
        _capture_running = true
        capture_all.call_deferred()

func _create_review_cameras() -> void:
    for name in ["WearHero", "WearGrazing"]:
        var camera := Camera3D.new()
        camera.name = name
        camera.fov = 43.0 if name == "WearHero" else 48.0
        add_child(camera)

func _wear_camera(index: int) -> Camera3D:
    return get_node("WearHero" if index == 0 else "WearGrazing") as Camera3D

func _position_review_cameras(floor_surface: bool) -> void:
    var target := Vector3(-0.25, 0.0, 0.45) if floor_surface else Vector3(-0.55, 1.45, -2.34)
    var hero := _wear_camera(0)
    var graze := _wear_camera(1)
    hero.position = Vector3(1.0, 1.85, 2.15) if floor_surface else Vector3(1.0, 2.05, 0.7)
    graze.position = Vector3(0.55, 0.55, 1.7) if floor_surface else Vector3(0.85, 1.48, -1.18)
    hero.look_at(target, Vector3.UP)
    graze.look_at(target, Vector3.UP)

func _unhandled_key_input(event: InputEvent) -> void:
    if _capture_running or not event is InputEventKey or not event.pressed or event.echo:
        return
    match event.keycode:
        KEY_N, KEY_BRACKETRIGHT:
            set_candidate(candidate_index + 1)
        KEY_P, KEY_BRACKETLEFT:
            set_candidate(candidate_index - 1)
        KEY_L:
            _review_node.call("toggle_light_mode")
        KEY_C:
            _review_node.call("next_camera")
        KEY_B:
            set_base(base_index + 1)
        KEY_EQUAL, KEY_KP_ADD:
            set_opacity(_spec.opacity_multiplier + 0.1)
        KEY_MINUS, KEY_KP_SUBTRACT:
            set_opacity(_spec.opacity_multiplier - 0.1)
        KEY_A:
            set_albedo(_spec.albedo_strength + 0.1)
        KEY_K:
            set_normal(_spec.normal_strength + 0.2)
        KEY_O:
            _overlay.rotation_degrees.z += 15.0
        KEY_M:
            _overlay.mirror_u = not _overlay.mirror_u
        KEY_I:
            set_imperfection(not _imperfection_enabled)
        KEY_R:
            set_candidate(candidate_index)
        _:
            return
    _update_hud()
    get_viewport().set_input_as_handled()

func set_candidate(index: int) -> void:
    if candidates.is_empty():
        return
    candidate_index = posmod(index, candidates.size())
    var record: Dictionary = candidates[candidate_index]
    var source_id := String(record["source_stable_id"])
    var primitive := String(record["review_primitive"])
    _base_ids = record["base_material_ids"]
    base_index = 0
    var spec_id := String(record["catalog_wear_id"])
    if primitive == "IMPERFECTION":
        var reference := _find_record("leakage_skiubhzc")
        if reference.is_empty():
            push_error("EAF4B imperfection reference stain missing")
            return
        spec_id = String(reference["catalog_wear_id"])
    var loaded := load(SPEC_ROOT + spec_id + ".tres") as EnvironmentWearOverlaySpec
    if loaded == null:
        push_error("EAF4B wear spec missing: " + spec_id)
        return
    _spec = loaded.duplicate(true) as EnvironmentWearOverlaySpec
    if primitive == "IMPERFECTION":
        var map_record: Dictionary = record["maps"].get("opacity", record["maps"].get("roughness", {}))
        _spec.imperfection_mask_texture = load(CACHE_ROOT + String(map_record["cache_relative"])) as Texture2D
        _spec.imperfection_strength = 0.65
        _spec.source_stable_id = source_id
        _spec.source_fingerprint = String(record["source_fingerprint"])
    set_base(0)
    _original_opacity = _spec.opacity_multiplier
    _original_albedo = _spec.albedo_strength
    _original_normal = _spec.normal_strength
    _imperfection_enabled = true
    _overlay.mirror_u = false
    _overlay.mirror_v = false
    _overlay.rotation_degrees = Vector3.ZERO
    _overlay.spec = _spec
    _overlay.imperfection_enabled = true
    var floor_surface: bool = _base_ids.size() == 1 and _base_ids[0] == BASE_IDS[2]
    _overlay.position = Vector3(-0.25, 0.0, 0.45) if floor_surface else Vector3(-0.55, 1.45, -2.34)
    _overlay.rotation_degrees.x = -90.0 if floor_surface else 0.0
    _overlay.regenerate()
    _position_review_cameras(floor_surface)
    _wear_camera(0).make_current()
    _patch.visible = primitive == "EAF4_PATCH"
    _overlay.visible = primitive != "EAF4_PATCH"
    if primitive == "EAF4_PATCH":
        _patch.mode = Patch.Mode.EAF4_SOURCE
        _patch.wear_spec = _spec
        _patch.position = _overlay.position
        _patch.rotation = _overlay.rotation
        _patch.regenerate()
    _update_hud()

func _find_record(fragment: String) -> Dictionary:
    for value in candidates:
        if fragment in String(value["source_stable_id"]):
            return value
    return {}

func set_base(index: int) -> void:
    if _base_ids.is_empty():
        return
    base_index = posmod(index, _base_ids.size())
    var base_id: String = _base_ids[base_index]
    _review_node.call("set_material_index", BASE_IDS.find(base_id))
    if _spec != null:
        var tint := 0.42
        if base_id == BASE_IDS[1]:
            tint = 0.29
        elif base_id == BASE_IDS[2]:
            tint = 0.37
        elif base_id == BASE_IDS[3]:
            tint = 0.52
        _spec.albedo_tint = Color(tint, tint, tint)
        _overlay.regenerate()
        _patch.regenerate()
    _update_hud()

func set_opacity(value: float) -> void:
    _spec.opacity_multiplier = clampf(value, 0.0, 1.0)
    _overlay.regenerate()
    _patch.regenerate()

func set_albedo(value: float) -> void:
    _spec.albedo_strength = clampf(value, 0.0, 1.0)
    _overlay.regenerate()
    _patch.regenerate()

func set_normal(value: float) -> void:
    _spec.normal_strength = clampf(value, 0.0, 2.0)
    _overlay.regenerate()
    _patch.regenerate()

func set_imperfection(enabled: bool) -> void:
    _imperfection_enabled = enabled
    _overlay.imperfection_enabled = enabled
    _overlay.regenerate()

func _update_hud() -> void:
    if _spec == null:
        return
    var record: Dictionary = candidates[candidate_index]
    var label := get_node("ReviewHUD/Panel/Label") as Label
    label.text = "EAF4B WEAR REVIEW (human pending)\n%d/%d %s\n%s / %s\nBase %s | opacity %.2f | color %.2f | normal %.2f\nN/P candidate  L light  C camera  B base  +/- opacity\nA color  K normal  O rotate  M mirror  I imperfection  R reset" % [
        candidate_index + 1, candidates.size(), String(record["source_stable_id"]),
        String(record["review_primitive"]), String(record["selected_resolution"]),
        String(_base_ids[base_index]), _spec.opacity_multiplier, _spec.albedo_strength, _spec.normal_strength]

func _capture_image(filename: String) -> void:
    await get_tree().process_frame
    await get_tree().process_frame
    await RenderingServer.frame_post_draw
    var image := get_viewport().get_texture().get_image()
    if image == null or image.is_empty():
        push_error("EAF4B capture returned no image")
        return
    if image.get_size() != Vector2i(1920, 1080):
        image.resize(1920, 1080, Image.INTERPOLATE_LANCZOS)
    var output := ProjectSettings.globalize_path("res://reports/environment_wear_catalog/reviews/%s/" % BATCH_ID)
    image.save_png(output.path_join(filename))

func _capture_record(record: Dictionary, filename: String, base_id: String, mode: String, camera_name: String, variant: String) -> Dictionary:
    var camera := get_viewport().get_camera_3d()
    return {
        "filename": filename, "wear_source_id": record["source_stable_id"],
        "strong_fingerprint": record["source_fingerprint"],
        "review_primitive": record["review_primitive"],
        "patch_mode": "EAF4_SOURCE" if record["review_primitive"] == "EAF4_PATCH" else "",
        "rendered_overlay_source_id": _find_record("leakage_skiubhzc").get("source_stable_id", "") if record["review_primitive"] == "IMPERFECTION" else record["source_stable_id"],
        "base_eaf3_material_id": base_id, "render_mode": "CUTOUT" if _spec.render_mode == Spec.RenderMode.CUTOUT else "SOFT_BLEND",
        "physical_size_m": [_spec.physical_size_m.x, _spec.physical_size_m.y],
        "surface": "FLOOR" if _overlay.rotation_degrees.x == -90.0 else "WALL",
        "surface_offset_m": _spec.surface_offset_m,
        "rotation_degrees": _overlay.rotation_degrees.z,
        "mirror_u": _overlay.mirror_u, "mirror_v": _overlay.mirror_v,
        "opacity": _spec.opacity_multiplier, "albedo_strength": _spec.albedo_strength,
        "albedo_tint": [_spec.albedo_tint.r, _spec.albedo_tint.g, _spec.albedo_tint.b],
        "normal_strength": _spec.normal_strength, "normal_y_flip": _spec.normal_y_flip,
        "roughness_strength": _spec.roughness_strength, "edge_feather": _spec.edge_feather,
        "imperfection": {"enabled": _imperfection_enabled, "strength": _spec.imperfection_strength,
                         "mask_source_stable_id": record["source_stable_id"] if record["review_primitive"] == "IMPERFECTION" else _find_record("grunge_tedxadjc").get("source_stable_id", "") if _spec.imperfection_mask_texture != null else "",
                         "scale": [_spec.imperfection_scale.x, _spec.imperfection_scale.y],
                         "rotation": _spec.imperfection_rotation, "contrast": _spec.imperfection_contrast},
        "camera": camera_name, "camera_position": [camera.global_position.x, camera.global_position.y, camera.global_position.z],
        "light_mode": mode, "lighting": _review_node.call("light_settings"), "variant": variant,
    }

func capture_all() -> void:
    var output := ProjectSettings.globalize_path("res://reports/environment_wear_catalog/reviews/%s/" % BATCH_ID)
    DirAccess.make_dir_recursive_absolute(output)
    get_window().size = Vector2i(1920, 1080)
    get_node("ReviewHUD").visible = false
    await get_tree().process_frame
    var records := []
    for i in candidates.size():
        set_candidate(i)
        var item: Dictionary = candidates[i]
        var base_id: String = _base_ids[0]
        for light in 2:
            _review_node.call("set_light_mode", light)
            for camera_index in 2:
                _wear_camera(camera_index).make_current()
                var camera_name: String = CAMERA_NAMES[camera_index]
                var filename := "%s__%s__%s.png" % [item["catalog_wear_id"], "neutral" if light == 0 else "receiving", "hero" if camera_index == 0 else "grazing"]
                await _capture_image(filename)
                records.append(_capture_record(item, filename, base_id, "NEUTRAL" if light == 0 else "RECEIVING", camera_name, "default"))
        print("EAF4B_CAPTURE", i + 1, candidates.size(), item["source_stable_id"])
    _overlay.visible = false
    _patch.visible = false
    for base_id in BASE_IDS:
        _review_node.call("set_material_index", BASE_IDS.find(base_id))
        for light in 2:
            _review_node.call("set_light_mode", light)
            for camera_index in 2:
                _review_node.call("set_camera_index", camera_index)
                var filename := "base__%s__%s__%s.png" % [base_id, "neutral" if light == 0 else "receiving", "hero" if camera_index == 0 else "grazing"]
                await _capture_image(filename)
                records.append({"filename": filename, "variant": "BASE_ONLY", "base_eaf3_material_id": base_id,
                                "camera": CAMERA_NAMES[camera_index], "light_mode": "NEUTRAL" if light == 0 else "RECEIVING"})
    await _capture_proofs(records)
    var stage: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(STAGE_PATH))
    var manifest := {"schema_version": 1, "batch_id": BATCH_ID, "scene": "res://gameplay/dev/environment_wear/environment_wear_review.tscn",
                     "eaf1_scene": "res://gameplay/dev/environment_lookdev/environment_material_lookdev.tscn",
                     "renderer": RenderingServer.get_current_rendering_method(), "engine_version": Engine.get_version_info().string,
                     "capture_size": [1920, 1080], "source_index_revision": stage["source_index_revision"],
                     "source_index_fingerprint": stage["source_index_fingerprint"], "records": records}
    var file := FileAccess.open(output.path_join("manifest.json"), FileAccess.WRITE)
    file.store_string(JSON.stringify(manifest, "  "))
    file.close()
    print("EAF4B_CAPTURE_COMPLETE records=%d" % records.size())
    get_tree().quit(0)


func _capture_proofs(records: Array) -> void:
    # The same real crack is reviewed on light and dark approved EAF3 concrete,
    # with full and reduced source color.
    set_candidate(0)
    _review_node.call("set_light_mode", 0)
    _wear_camera(0).make_current()
    for substrate in 2:
        set_base(substrate)
        for strength in [1.0, 0.25]:
            set_albedo(strength)
            var name := "proof_cross_substrate_%s_%s.png" % ["light" if substrate == 0 else "dark", "full" if strength == 1.0 else "reduced"]
            await _capture_image(name)
            records.append(_capture_record(candidates[0], name, _base_ids[base_index], "NEUTRAL", "Hero", "CROSS_SUBSTRATE"))
    # Isolate the actual selected grunge mask on the same real leakage source.
    set_candidate(6)
    _spec.imperfection_strength = 1.0
    _spec.imperfection_contrast = 2.6
    _spec.opacity_multiplier = 1.0
    _spec.albedo_strength = 0.55
    _overlay.regenerate()
    _wear_camera(0).make_current()
    for enabled in [false, true]:
        set_imperfection(enabled)
        var name := "proof_imperfection_%s.png" % ["on" if enabled else "off"]
        await _capture_image(name)
        records.append(_capture_record(candidates[6], name, _base_ids[base_index], "NEUTRAL", "Hero", "IMPERFECTION_AB"))
    # An approved EAF3 material is a distinct patch primitive.
    set_candidate(2)
    _overlay.visible = false
    _patch.visible = true
    _patch.mode = Patch.Mode.EAF3_MATERIAL
    _patch.eaf3_material_id = BASE_IDS[3]
    _patch.physical_size_m = Vector2(0.8, 0.55)
    _patch.position = Vector3(-0.55, 1.45, -2.34)
    _patch.rotation_degrees = Vector3.ZERO
    _patch.regenerate()
    _wear_camera(0).make_current()
    await _capture_image("proof_eaf3_plaster_patch.png")
    records.append({"filename": "proof_eaf3_plaster_patch.png", "variant": "EAF3_MATERIAL_PATCH",
                    "patch_mode": "EAF3_MATERIAL", "eaf3_material_id": BASE_IDS[3],
                    "base_eaf3_material_id": _base_ids[base_index], "physical_size_m": [0.8, 0.55],
                    "surface_offset_m": _patch.surface_offset_m, "camera": "Hero", "light_mode": "NEUTRAL"})
    # Original synthetic RGBA atlas: two logical regions with explicit UVs.
    _patch.visible = false
    var atlas := Image.create_empty(256, 128, false, Image.FORMAT_RGBA8)
    atlas.fill(Color(0.0, 0.0, 0.0, 0.0))
    for y in 128:
        for x in 256:
            if x < 128:
                var radius := Vector2(float(x) - 64.0, float(y) - 64.0).length()
                if radius < 52.0:
                    atlas.set_pixel(x, y, Color(0.68, 0.12, 0.06, clampf((52.0 - radius) / 8.0, 0.0, 1.0)))
            else:
                var diamond: float = abs(float(x) - 192.0) + abs(float(y) - 64.0)
                if diamond < 56.0:
                    atlas.set_pixel(x, y, Color(0.06, 0.19, 0.72, clampf((56.0 - diamond) / 8.0, 0.0, 1.0)))
    var atlas_texture := ImageTexture.create_from_image(atlas)
    var synthetic_nodes: Array[EnvironmentWearOverlay] = []
    for logical in 2:
        var atlas_spec := _spec.duplicate(true) as EnvironmentWearOverlaySpec
        atlas_spec.overlay_id = "synthetic_atlas_%d" % logical
        atlas_spec.source_stable_id = "synthetic:atlas:%d" % logical
        atlas_spec.source_fingerprint = "0".repeat(64)
        atlas_spec.render_mode = Spec.RenderMode.SOFT_BLEND
        atlas_spec.physical_size_m = Vector2(0.7, 0.7)
        atlas_spec.base_color_texture = atlas_texture
        atlas_spec.opacity_texture = null
        atlas_spec.normal_texture = null
        atlas_spec.roughness_texture = null
        atlas_spec.embedded_alpha = true
        atlas_spec.albedo_strength = 1.0
        atlas_spec.albedo_tint = Color.WHITE
        atlas_spec.atlas_region = Vector4(0.5 * logical, 0.0, 0.5, 1.0)
        var logical_node := Overlay.new()
        logical_node.spec = atlas_spec
        logical_node.position = Vector3(-1.15 + 1.2 * logical, 1.45, -2.34)
        add_child(logical_node)
        logical_node.regenerate()
        synthetic_nodes.append(logical_node)
    _wear_camera(0).make_current()
    await _capture_image("proof_synthetic_atlas.png")
    records.append({"filename": "proof_synthetic_atlas.png", "variant": "SYNTHETIC_ATLAS",
                    "regions": [[0.0, 0.0, 0.5, 1.0], [0.5, 0.0, 0.5, 1.0]],
                    "embedded_alpha": true, "independent_logical_overlays": 2,
                    "base_eaf3_material_id": _base_ids[base_index], "camera": "Hero", "light_mode": "NEUTRAL"})
    for logical_node in synthetic_nodes:
        logical_node.queue_free()
    await get_tree().process_frame
    # Sparse non-overlapping soft layers beneath a simple metal service origin.
    set_candidate(6)
    _overlay.position = Vector3(-0.7, 1.17, -2.34)
    _overlay.regenerate()
    var second_spec := load(SPEC_ROOT + String(candidates[5]["catalog_wear_id"]) + ".tres") as EnvironmentWearOverlaySpec
    var second := Overlay.new()
    second.spec = second_spec
    second.position = Vector3(0.55, 1.25, -2.34)
    add_child(second)
    second.regenerate()
    var origin := MeshInstance3D.new()
    var proxy := BoxMesh.new()
    proxy.size = Vector3(0.48, 0.15, 0.10)
    origin.mesh = proxy
    var metal := StandardMaterial3D.new()
    metal.albedo_color = Color(0.16, 0.18, 0.20)
    metal.metallic = 0.75
    origin.material_override = metal
    origin.position = Vector3(-0.7, 1.95, -2.29)
    add_child(origin)
    _review_node.call("set_camera_index", 0)
    await _capture_image("proof_causal_service_leak.png")
    records.append({"filename": "proof_causal_service_leak.png", "variant": "CAUSAL_COMPOSITION",
                    "origin": "simple metal service proxy", "layers": ["leakage_skiubhzc", "leakage_tculfbnc"],
                    "soft_planes_overlap": false, "camera": "EAF1 Hero", "light_mode": "NEUTRAL"})
    second.queue_free()
    origin.queue_free()
