extends Node3D

const CAPTURE_SIZE := Vector2i(1920, 1080)
const OUTPUT := "res://reports/environment_receiving_proof/eaf5"
const SHELL_VIEWS := ["EastApproachOverview", "FreightAperture", "FreightRecess", "EastOpening", "DispatchOpening", "UpperCeilingContext", "JoinAudit_Apron", "JoinAudit_Dispatch"]
const DEBUG_VIEWS := ["JoinAudit_Apron", "JoinAudit_Freight", "JoinAudit_Dispatch", "FreightAperture", "UpperCeilingContext", "DispatchOpening"]
const ROLES := ["WALL_PRIMARY", "FLOOR_PRIMARY", "CEILING_PRIMARY"]
const ROLE_VIEW := {"WALL_PRIMARY": "WallDominant", "FLOOR_PRIMARY": "FloorRead", "CEILING_PRIMARY": "CeilingRead"}
const LIGHT_MODES := ["NEUTRAL_ARCHITECTURAL", "RECEIVING_TARGET"]

func _ready() -> void:
    var args := OS.get_cmdline_user_args()
    if args.has("--eaf5-capture-shell"):
        _capture_shell.call_deferred()
    elif args.has("--eaf5-capture-joins"):
        _capture_join_debug.call_deferred()
    elif args.has("--eaf5-capture-roles"):
        _reject_role_recapture.call_deferred()

func shell_capture_records() -> Array:
    var records := []
    for index in SHELL_VIEWS.size():
        records.append({"camera": SHELL_VIEWS[index], "light_mode": LIGHT_MODES[0], "filename": "%02d_%s.png" % [index + 1, SHELL_VIEWS[index]]})
    return records

func role_capture_records() -> Array:
    var records := []
    var proof := get_node("Proof")
    var sets: Dictionary = proof.call("role_candidates")
    for role in ROLES:
        for candidate in sets[role]:
            var material_id := String(candidate["catalog_material_id"])
            for light in LIGHT_MODES:
                for camera in ["EastApproachOverview", ROLE_VIEW[role]]:
                    records.append({
                        "role": role,
                        "catalog_material_id": material_id,
                        "light_mode": light,
                        "camera": camera,
                        "filename": "%s__%s__%s.png" % [material_id, light.to_lower(), camera],
                    })
    return records

func _capture_shell() -> void:
    var proof := get_node("Proof")
    proof.call("set_control")
    proof.call("set_light_mode", LIGHT_MODES[0])
    var folder := ProjectSettings.globalize_path(OUTPUT + "/shell_review_02")
    if not _make_directory(folder):
        return
    get_window().size = CAPTURE_SIZE
    await get_tree().process_frame
    await get_tree().process_frame
    var records := []
    var fingerprints := _piece_fingerprints(proof)
    for planned in shell_capture_records():
        proof.call("set_camera", String(planned["camera"]))
        await _settle_frame()
        var record: Dictionary = planned.duplicate(true)
        record.merge(_camera_metadata(proof, String(record["camera"])))
        record["light_settings"] = proof.call("light_settings")
        record["shell_source_sha256"] = proof.call("shell_source_sha256")
        record["proof_composition_sha256"] = proof.call("proof_composition_sha256")
        record["shell_manifest_version"] = 2
        record["piece_geometry_fingerprints"] = fingerprints
        if not _save_image(folder.path_join(String(record["filename"]))):
            return
        records.append(record)
    var manifest := _base_manifest(proof)
    manifest["capture_type"] = "NEUTRAL_SHELL"
    manifest["control_material"] = "eaf5_review_control_only"
    manifest["records"] = records
    if not _write_json(folder.path_join("manifest.json"), manifest):
        return
    print("EAF5_SHELL_CAPTURE_COMPLETE records=", records.size())
    get_tree().quit(0)

func _reject_role_recapture() -> void:
    _fail("Role recapture is on hold until human acceptance of shell review 02")

func _capture_join_debug() -> void:
    var proof := get_node("Proof")
    proof.call("set_control")
    if not OS.get_cmdline_user_args().has("--eaf5-neutral-debug"):
        proof.call("set_join_debug_colors")
    for argument in OS.get_cmdline_user_args():
        if argument.begins_with("--eaf5-hide-piece="):
            var piece_id: String = argument.trim_prefix("--eaf5-hide-piece=")
            proof.get_node("Shell/" + piece_id + "/GeneratedMesh").visible = false
    proof.call("set_light_mode", LIGHT_MODES[0])
    for light in proof.get_node("NeutralLightingRig").get_children():
        (light as Light3D).shadow_enabled = false
    var folder := ProjectSettings.globalize_path(OUTPUT + "/join_debug_02")
    if not _make_directory(folder):
        return
    get_window().size = CAPTURE_SIZE
    await get_tree().process_frame
    await get_tree().process_frame
    var records := []
    for camera in DEBUG_VIEWS:
        proof.call("set_camera", camera)
        await _settle_frame()
        var filename: String = String(camera) + ".png"
        if not _save_image(folder.path_join(filename)):
            return
        records.append({"camera": camera, "filename": filename, "camera_transform": _camera_metadata(proof, camera)})
    _write_json(folder.path_join("manifest.json"), {"review_only": true, "proof_composition_sha256": proof.call("proof_composition_sha256"), "records": records})
    print("EAF5_JOIN_DEBUG_COMPLETE records=", records.size())
    get_tree().quit(0)

func _capture_roles() -> void:
    var proof := get_node("Proof")
    var output := ProjectSettings.globalize_path(OUTPUT + "/role_isolation_01")
    if not _make_directory(output):
        return
    get_window().size = CAPTURE_SIZE
    await get_tree().process_frame
    await get_tree().process_frame
    var sets: Dictionary = proof.call("role_candidates")
    var grouped := {"WALL_PRIMARY": [], "FLOOR_PRIMARY": [], "CEILING_PRIMARY": []}
    var fingerprints := _piece_fingerprints(proof)
    for planned in role_capture_records():
        var role := String(planned["role"])
        var material_id := String(planned["catalog_material_id"])
        var folder := output.path_join(role.to_lower().trim_suffix("_primary"))
        if not _make_directory(folder):
            return
        if not proof.call("set_review", role, material_id):
            _fail("could not apply current approval " + material_id)
            return
        proof.call("set_light_mode", String(planned["light_mode"]))
        proof.call("set_camera", String(planned["camera"]))
        await _settle_frame()
        var record: Dictionary = planned.duplicate(true)
        var approved_record: Dictionary = proof.call("active_record")
        var spec: EnvironmentSurfaceMaterialSpec = proof.call("active_review_spec")
        record["source_stable_id"] = approved_record["source_stable_id"]
        record["source_fingerprint"] = approved_record["reviewed_source_fingerprint"]
        record["display_name"] = approved_record["display_name"]
        record["surface_family"] = approved_record["surface_family"]
        record["vdd_layer"] = approved_record["vdd_layer"]
        record["approved_roles"] = approved_record["approved_roles"]
        record["approved_catalog_mapping"] = approved_record["mapping_mode"]
        record["effective_review_mapping"] = spec.mapping_name()
        record["transient_uv_review_override"] = approved_record["mapping_mode"] != "UV"
        record["meters_per_repeat"] = spec.meters_per_repeat
        record["normal_y_flip"] = spec.normal_y_flip
        record["normal_strength"] = spec.normal_strength
        record["roughness_multiplier"] = spec.roughness_multiplier
        record["metallic_multiplier"] = spec.metallic_multiplier
        record["albedo_multiplier"] = spec.albedo_multiplier
        record["reveal_uses_candidate"] = role == "WALL_PRIMARY" and "opening_reveal" in approved_record["approved_roles"]
        record["east_opening_wall_controlled_for_unapproved_reveal"] = role == "WALL_PRIMARY" and not record["reveal_uses_candidate"]
        record.merge(_camera_metadata(proof, String(record["camera"])))
        record["light_settings"] = proof.call("light_settings")
        record["shell_source_sha256"] = proof.call("shell_source_sha256")
        record["proof_composition_sha256"] = proof.call("proof_composition_sha256")
        record["shell_manifest_version"] = 2
        record["piece_geometry_fingerprints"] = fingerprints
        if not _save_image(folder.path_join(String(record["filename"]))):
            return
        grouped[role].append(record)
        print("EAF5_ROLE_CAPTURE role=%s material=%s mode=%s camera=%s" % [role, material_id, record["light_mode"], record["camera"]])
    for role in ROLES:
        var folder := output.path_join(role.to_lower().trim_suffix("_primary"))
        var manifest := _base_manifest(proof)
        manifest["capture_type"] = "ROLE_ISOLATION"
        manifest["role"] = role
        manifest["control_material"] = "eaf5_review_control_only"
        manifest["candidate_ids"] = _ids(sets[role])
        manifest["records"] = grouped[role]
        if not _write_json(folder.path_join("manifest.json"), manifest):
            return
    print("EAF5_ROLE_CAPTURE_COMPLETE records=", role_capture_records().size())
    get_tree().quit(0)

func _piece_fingerprints(proof: Node) -> Dictionary:
    var result := {}
    for piece in proof.call("generation_records"):
        result[piece["piece_id"]] = piece["geometry_fingerprint"]
    return result

func _base_manifest(proof: Node) -> Dictionary:
    var environment := (proof.get_node("WorldEnvironment") as WorldEnvironment).environment
    return {
        "schema_version": 2,
        "shell_source": "data/environment/receiving_proof/eaf5_receiving_shell_source.json",
        "shell_source_sha256": proof.call("shell_source_sha256"),
        "proof_composition": "data/environment/receiving_proof/eaf5_receiving_proof_composition_v2.json",
        "proof_composition_sha256": proof.call("proof_composition_sha256"),
        "scene": "res://gameplay/dev/environment_receiving_proof/environment_receiving_proof.tscn",
        "capture_scene": "res://gameplay/dev/environment_receiving_proof/environment_receiving_proof_capture.tscn",
        "engine_version": Engine.get_version_info().string,
        "renderer": RenderingServer.get_current_rendering_method(),
        "capture_size": [CAPTURE_SIZE.x, CAPTURE_SIZE.y],
        "environment": {"background_color": environment.background_color.to_html(), "ambient_color": environment.ambient_light_color.to_html(), "ambient_energy": environment.ambient_light_energy, "exposure": environment.tonemap_exposure, "tonemap": environment.tonemap_mode, "tonemap_name": "FILMIC"},
        "pieces": proof.call("generation_records"),
        "review_context": proof.call("review_context_inventory"),
        "later_inventory": proof.call("later_inventory"),
        "wear_enabled": false,
        "applied_finish_enabled": false,
        "palette_pairs_generated": false,
    }

func _ids(candidates: Array) -> Array:
    var ids := []
    for candidate in candidates:
        ids.append(candidate["catalog_material_id"])
    return ids

func _camera_metadata(proof: Node, camera_name: String) -> Dictionary:
    var camera := proof.call("get_camera", camera_name) as Camera3D
    var transform := camera.global_transform
    return {"camera_transform": {"origin": _v3(transform.origin), "basis_x": _v3(transform.basis.x), "basis_y": _v3(transform.basis.y), "basis_z": _v3(transform.basis.z)}, "camera_fov": camera.fov}

func _v3(value: Vector3) -> Array:
    return [value.x, value.y, value.z]

func _settle_frame() -> void:
    await get_tree().process_frame
    await get_tree().process_frame
    await RenderingServer.frame_post_draw

func _save_image(filename: String) -> bool:
    var image := get_viewport().get_texture().get_image()
    if image == null or image.is_empty():
        _fail("renderer returned no image: " + filename)
        return false
    if image.get_size() != CAPTURE_SIZE:
        image.resize(CAPTURE_SIZE.x, CAPTURE_SIZE.y, Image.INTERPOLATE_LANCZOS)
    var error := image.save_png(filename)
    if error != OK:
        _fail("save failed: " + filename + " " + error_string(error))
        return false
    return true

func _make_directory(path: String) -> bool:
    var error := DirAccess.make_dir_recursive_absolute(path)
    if error != OK:
        _fail("directory failed: " + path)
        return false
    return true

func _write_json(path: String, value: Variant) -> bool:
    var file := FileAccess.open(path, FileAccess.WRITE)
    if file == null:
        _fail("manifest failed: " + path)
        return false
    file.store_string(JSON.stringify(value, "\t"))
    file.close()
    return true

func _fail(message: String) -> void:
    push_error("EAF5_CAPTURE_FAIL " + message)
    get_tree().quit(1)
