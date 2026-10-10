extends Node3D

const Query = preload("res://environment_authoring/environment_material_catalog_query.gd")
const WearQuery = preload("res://environment_authoring/wear/environment_wear_catalog_query.gd")
const WEAR_PROOF := "res://data/environment/receiving_proof/eaf5_receiving_wear_proof_01.json"
const WEAR_CALIBRATION := "res://data/environment/receiving_proof/eaf5_receiving_wear_calibration_01.json"
const PALETTE_SELECTION := "res://data/environment/receiving_proof/eaf5_receiving_palette_selection_01.json"
const PASS6B_DECISIONS := "res://data/environment/receiving_proof/decisions/eaf5_applied_finish_layouts_01_human_review_01.json"

const CAPTURE_SIZE := Vector2i(1920, 1080)
const OUTPUT := "res://reports/environment_receiving_proof/eaf5"
const ACCEPTED_SHELL_ZIP_SHA256 := "5b2d343a3b80689364fe087e528fd2eba3d6983efa3d5426509b8460217ebd2e"
const ACCEPTED_COMPOSITION_SHA256 := "8361ed7d1d211f40c253cc7bf76821b9d141ab303b0fe7a6573208216f05339d"
const ACCEPTED_SOURCE_SHA256 := "12cf8f93024e833f5c16932a1d963b3986258a7661cff3e246a2db525d4d4fc9"
const SHELL_VIEWS := ["EastApproachOverview", "FreightAperture", "FreightRecess", "EastOpening", "DispatchOpening", "UpperCeilingContext", "JoinAudit_Apron", "JoinAudit_Dispatch"]
const DEBUG_VIEWS := ["JoinAudit_Apron", "JoinAudit_Freight", "JoinAudit_Dispatch", "FreightAperture", "UpperCeilingContext", "DispatchOpening"]
const ROLES := ["WALL_PRIMARY", "FLOOR_PRIMARY", "CEILING_PRIMARY"]
const ROLE_VIEW := {"WALL_PRIMARY": "WallDominant", "FLOOR_PRIMARY": "FloorRead", "CEILING_PRIMARY": "CeilingRead"}
const LIGHT_MODES := ["NEUTRAL_ARCHITECTURAL", "RECEIVING_TARGET"]
const PAIR_WALL_IDS := ["eaf3b_d335d94fd85c2c95c26b6b8b", "eaf3b_20c61bd1c85420be2f71a090", "eaf3b_5a797fbdc766d7e3dc475abf", "eaf3b_6bcd8f817ca2993433e217cc", "eaf3b_2dc87647fd382ad8287a0280"]
const PAIR_FLOOR_IDS := ["eaf3b_f10d218d1e8b7f09b7c2689c", "eaf3b_bb32071987faae156ff2d4e8", "eaf3b_20e1005f19f39efb82251916"]
const PAIR_SANITY_IDS := ["W01_F01", "W03_F02", "W05_F03"]
const PALETTE_PAIRS := ["W01_F02", "W01_F03", "W02_F02", "W03_F01", "W03_F02", "W04_F01", "W04_F02"]
const PALETTE_CEILING_IDS := ["eaf3b_2dc87647fd382ad8287a0280", "eaf3b_6bcd8f817ca2993433e217cc", "eaf3b_71edb3fc983ed8f7655d9523", "eaf3b_d335d94fd85c2c95c26b6b8b", "eaf3b_800060297ab83f24c0fb0d75"]
const PALETTE_SANITY_IDS := ["P01_C03", "P04_C01", "P07_C02"]
const PAIR_DECISIONS := "res://data/environment/receiving_proof/decisions/eaf5_wall_floor_pairs_01_human_review_01.json"
const PAIR_PACKAGE_SHA256 := "fa32ebd095eddf14a3218740b089f61b8c83db8ae73a3b266e1fe1194e3f6353"
const FINALIST_PALETTE_IDS := ["P01_C02", "P05_C02", "P04_C02", "P05_C03", "P01_C01", "P01_C05"]
const FINISH_IDS := ["", "eaf3b_7b12b8b3a2e05c502801d22f", "eaf3b_8d5f0cf5add98dfe0a58f18a", "eaf3b_9297ffec71774317b0627951", "eaf3b_b395eb3943870fbfd262e8ce", "eaf3b_c29826cd934f1534ecfb48c5"]
const FINISH_SANITY_IDS := ["S01_A00", "S01_A02", "S02_A03", "S04_A04"]
const PASS5_DECISIONS := "res://data/environment/receiving_proof/decisions/eaf5_structural_palettes_01_human_review_01.json"
const PASS5_PACKAGE_SHA256 := "97034dbad91328f1d53531e3cf2b1816ac63ccf33d14a8e033495aaec61ba748"
const PASS5_MANIFEST := OUTPUT + "/structural_palettes_01/manifest.json"
const FINISH_REGION := "FINISH_SOUTH_WALL_FIELD"
const PASS6A_PACKAGE_SHA256 := "e8bfa330e836687b2fe869a938bf7ed3181ca1a0f076d0d531a32293e6bda66b"
const PASS6A_MANIFEST := OUTPUT + "/applied_finish_screen_01/manifest.json"
const PASS6A_DECISIONS := "res://data/environment/receiving_proof/decisions/eaf5_applied_finish_screen_01_human_review_01.json"
const LAYOUT_CASES := [
    ["S01_L00", 0, 0, "L00"], ["S05_L00", 4, 0, "L00"], ["S06_L00", 5, 0, "L00"],
    ["V01_L01", 0, 1, "L01"], ["V01_L02", 0, 1, "L02"],
    ["V02_L01", 4, 4, "L01"], ["V02_L02", 4, 4, "L02"],
    ["V03_L01", 5, 1, "L01"], ["V03_L02", 5, 1, "L02"],
    ["V04_L01", 5, 5, "L01"], ["V04_L02", 5, 5, "L02"],
    ["Q01_L02", 0, 2, "L02"], ["Q02_L02", 0, 3, "L02"],
]
const LAYOUT_SANITY_IDS := ["S01_L00", "V01_L01", "V01_L02", "Q01_L02", "Q02_L02"]
const LAYOUT_SCALE_IDS := ["V01_L01", "V01_L02"]
const ROLE_DECISIONS := "res://data/environment/receiving_proof/decisions/eaf5_role_isolation_02_human_review_01.json"
const ROLE_PACKAGE_HASHES := {"wall": "2fbb4a646b2e48c742a901c0e650178ebb5e89e2c39bd3c964fcc32566946dcb", "floor": "75ccd8600d1f15e9030b87284bbda0bae1f3f5c362dfe35be02d3c0f80df538e", "ceiling": "a666f59876a6b35112803f9c8a30995aac06cc9da81f4fe3f1a42c53c5e57c37"}

func _ready() -> void:
    var args := OS.get_cmdline_user_args()
    if args.has("--eaf5-capture-wear-calibration"):
        _capture_wear_calibration.call_deferred()
    elif args.has("--eaf5-capture-wear-sanity"):
        _capture_wear.call_deferred(true)
    elif args.has("--eaf5-capture-wear"):
        _capture_wear.call_deferred(false)
    elif args.has("--eaf5-capture-shell"):
        _capture_shell.call_deferred()
    elif args.has("--eaf5-capture-joins"):
        _capture_join_debug.call_deferred()
    elif args.has("--eaf5-capture-roles-sanity"):
        _capture_roles.call_deferred(true)
    elif args.has("--eaf5-capture-roles"):
        _capture_roles.call_deferred(false)
    elif args.has("--eaf5-capture-pairs-sanity"):
        _capture_pairs.call_deferred(true)
    elif args.has("--eaf5-capture-layout-scale"):
        _capture_layouts.call_deferred(false, true)
    elif args.has("--eaf5-capture-layouts-sanity"):
        _capture_layouts.call_deferred(true, false)
    elif args.has("--eaf5-capture-layouts"):
        _capture_layouts.call_deferred(false, false)
    elif args.has("--eaf5-capture-finishes-sanity"):
        _capture_finishes.call_deferred(true)
    elif args.has("--eaf5-capture-finishes"):
        _capture_finishes.call_deferred(false)
    elif args.has("--eaf5-capture-palettes-sanity"):
        _capture_palettes.call_deferred(true)
    elif args.has("--eaf5-capture-palettes"):
        _capture_palettes.call_deferred(false)
    elif args.has("--eaf5-capture-pairs"):
        _capture_pairs.call_deferred(false)

func shell_capture_records() -> Array:
    var records := []
    for index in SHELL_VIEWS.size():
        records.append({"camera": SHELL_VIEWS[index], "light_mode": LIGHT_MODES[0], "filename": "%02d_%s.png" % [index + 1, SHELL_VIEWS[index]]})
    return records

func role_capture_records(sample_only: bool = false) -> Array:
    var records := []
    var proof := get_node("Proof")
    var sets: Dictionary = proof.call("role_candidates")
    for role in ROLES:
        var candidates: Array = sets[role]
        if sample_only:
            candidates = candidates.slice(0, 1)
        for candidate in candidates:
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

func role_capture_directory(sample_only: bool = false) -> String:
    return OUTPUT + ("/role_isolation_02/sanity" if sample_only else "/role_isolation_02")

func pair_capture_records(sample_only: bool = false) -> Array:
    var records := []
    for wi in PAIR_WALL_IDS.size():
        for fi in PAIR_FLOOR_IDS.size():
            var pair_id := "W%02d_F%02d" % [wi + 1, fi + 1]
            if sample_only and not PAIR_SANITY_IDS.has(pair_id):
                continue
            for view in [
                {"light_mode": "NEUTRAL_ARCHITECTURAL", "camera": "EastApproachOverview"},
                {"light_mode": "RECEIVING_TARGET", "camera": "EastApproachOverview"},
                {"light_mode": "NEUTRAL_ARCHITECTURAL", "camera": "WallDominant"},
                {"light_mode": "NEUTRAL_ARCHITECTURAL", "camera": "FloorRead"}
            ]:
                records.append({
                    "pair_id": pair_id,
                    "wall_catalog_material_id": PAIR_WALL_IDS[wi],
                    "floor_catalog_material_id": PAIR_FLOOR_IDS[fi],
                    "light_mode": view["light_mode"],
                    "camera": view["camera"],
                    "filename": "%s__%s__%s.png" % [pair_id, String(view["light_mode"]).to_lower(), view["camera"]]
                })
    return records

func validate_pair_source() -> bool:
    if not validate_role_candidates() or not validate_accepted_shell():
        return false
    var decisions := _json_file(ROLE_DECISIONS)
    if decisions.get("accepted_composition_sha256") != ACCEPTED_COMPOSITION_SHA256:
        return false
    var counts := {"WALL_PRIMARY": {"KEEP": 0, "HOLD": 0, "DROP_FOR_RECEIVING": 0}, "FLOOR_PRIMARY": {"KEEP": 0, "HOLD": 0, "DROP_FOR_RECEIVING": 0}, "CEILING_PRIMARY": {"KEEP": 0, "HOLD": 0, "DROP_FOR_RECEIVING": 0}}
    var kept := {"WALL_PRIMARY": [], "FLOOR_PRIMARY": [], "CEILING_PRIMARY": []}
    var seen := {}
    var proof := get_node("Proof")
    var sets: Dictionary = proof.call("role_candidates")
    for folder in ROLE_PACKAGE_HASHES:
        var path := ProjectSettings.globalize_path(OUTPUT + "/eaf5_" + folder + "_role_review_02.zip")
        if not FileAccess.file_exists(path) or FileAccess.get_sha256(path) != ROLE_PACKAGE_HASHES[folder]:
            return false
    for entry in decisions.get("decisions", []):
        var role: String = entry.get("role", "")
        var material_id: String = entry.get("catalog_material_id", "")
        var decision: String = entry.get("decision", "")
        var key := role + "/" + material_id
        if not counts.has(role) or not counts[role].has(decision) or seen.has(key):
            return false
        var evidence_folder := role.to_lower().trim_suffix("_primary")
        if entry.get("review_package_sha256") != ROLE_PACKAGE_HASHES[evidence_folder] or entry.get("review_package") != "reports/environment_receiving_proof/eaf5/eaf5_" + evidence_folder + "_role_review_02.zip":
            return false
        seen[key] = true
        counts[role][decision] += 1
        var matching: Dictionary = {}
        for candidate in sets[role]:
            if candidate["catalog_material_id"] == material_id:
                matching = candidate
                break
        if matching.is_empty() or matching["display_name"] != entry.get("display_name"):
            return false
        if decision == "KEEP":
            if matching["mapping_mode"] != "UV":
                return false
            kept[role].append(material_id)
    if seen.size() != 33 or counts["WALL_PRIMARY"] != {"KEEP": 5, "HOLD": 7, "DROP_FOR_RECEIVING": 2} or counts["FLOOR_PRIMARY"] != {"KEEP": 3, "HOLD": 3, "DROP_FOR_RECEIVING": 2} or counts["CEILING_PRIMARY"] != {"KEEP": 5, "HOLD": 3, "DROP_FOR_RECEIVING": 3}:
        return false
    if kept["WALL_PRIMARY"].size() != 5 or kept["FLOOR_PRIMARY"].size() != 3:
        return false
    for material_id in PAIR_WALL_IDS:
        if not kept["WALL_PRIMARY"].has(material_id):
            return false
    for material_id in PAIR_FLOOR_IDS:
        if not kept["FLOOR_PRIMARY"].has(material_id):
            return false
    for wall_id in PAIR_WALL_IDS:
        if PAIR_FLOOR_IDS.has(wall_id):
            return false
    return pair_capture_records(false).size() == 60 and pair_capture_records(true).size() == 12

func _capture_pairs(sample_only: bool) -> void:
    var proof := get_node("Proof")
    if not validate_pair_source():
        _fail("pair source differs from approved role decisions, live catalog, or accepted shell")
        return
    var folder := ProjectSettings.globalize_path(OUTPUT + ("/wall_floor_pairs_01/sanity" if sample_only else "/wall_floor_pairs_01"))
    if not _make_directory(folder):
        return
    get_window().size = CAPTURE_SIZE
    await get_tree().process_frame
    await get_tree().process_frame
    var records := []
    var fingerprints := _piece_fingerprints(proof)
    var sets: Dictionary = proof.call("role_candidates")
    for planned in pair_capture_records(sample_only):
        var wall_id: String = planned["wall_catalog_material_id"]
        var floor_id: String = planned["floor_catalog_material_id"]
        if not proof.call("set_wall_floor_pair", wall_id, floor_id):
            _fail("could not apply pair " + String(planned["pair_id"]))
            return
        proof.call("set_light_mode", String(planned["light_mode"]))
        proof.call("set_camera", String(planned["camera"]))
        await _settle_frame()
        var record: Dictionary = planned.duplicate(true)
        var wall: Dictionary = {}
        var floor: Dictionary = {}
        for candidate in sets["WALL_PRIMARY"]:
            if candidate["catalog_material_id"] == wall_id:
                wall = candidate
                break
        for candidate in sets["FLOOR_PRIMARY"]:
            if candidate["catalog_material_id"] == floor_id:
                floor = candidate
                break
        record["wall_display_name"] = wall["display_name"]
        record["floor_display_name"] = floor["display_name"]
        record["wall_source_fingerprint"] = wall["reviewed_source_fingerprint"]
        record["floor_source_fingerprint"] = floor["reviewed_source_fingerprint"]
        record["wall_reveal_uses_candidate"] = "opening_reveal" in wall["approved_roles"]
        record["east_opening_wall_controlled_for_unapproved_reveal"] = not record["wall_reveal_uses_candidate"]
        record["effective_mapping"] = {"wall": "UV", "floor": "UV"}
        record["material_parameters"] = {"wall": _pair_parameters(wall), "floor": _pair_parameters(floor)}
        record["ceiling_material"] = "eaf5_review_control_only"
        record["review_context_material"] = "eaf5_review_control_only"
        record.merge(_camera_metadata(proof, String(record["camera"])))
        record["light_settings"] = proof.call("light_settings")
        record["shell_source_sha256"] = proof.call("shell_source_sha256")
        record["proof_composition_sha256"] = proof.call("proof_composition_sha256")
        record["piece_geometry_fingerprints"] = fingerprints
        if not _save_image(folder.path_join(String(record["filename"]))):
            return
        records.append(record)
        print("EAF5_PAIR_CAPTURE pair=%s mode=%s camera=%s" % [record["pair_id"], record["light_mode"], record["camera"]])
    var manifest := _base_manifest(proof)
    manifest["capture_type"] = "WALL_FLOOR_PAIR_SANITY" if sample_only else "WALL_FLOOR_PAIR"
    manifest["palette_pairs_generated"] = true
    manifest["control_material"] = "eaf5_review_control_only"
    manifest["role_decision_source"] = ROLE_DECISIONS
    manifest["role_decision_sha256"] = FileAccess.get_sha256(ROLE_DECISIONS)
    manifest["pair_ids"] = PAIR_SANITY_IDS if sample_only else _pair_ids()
    manifest["ceiling_survivor_ids_for_later"] = _kept_ceiling_ids()
    var by_pair := {}
    for record in records:
        var pair_id: String = record["pair_id"]
        if not by_pair.has(pair_id):
            by_pair[pair_id] = {
                "pair_id": pair_id,
                "wall_catalog_material_id": record["wall_catalog_material_id"],
                "wall_display_name": record["wall_display_name"],
                "floor_catalog_material_id": record["floor_catalog_material_id"],
                "floor_display_name": record["floor_display_name"],
                "accepted_shell_composition_sha256": record["proof_composition_sha256"],
                "effective_uv_mapping": record["effective_mapping"],
                "material_parameters": record["material_parameters"]
            }
    manifest["pairs"] = []
    for pair_id in manifest["pair_ids"]:
        manifest["pairs"].append(by_pair[pair_id])
    manifest["records"] = records
    if not _write_json(folder.path_join("manifest.json"), manifest):
        return
    print("EAF5_PAIR_CAPTURE_COMPLETE records=", records.size(), " sample=", sample_only)
    get_tree().quit(0)

func palette_capture_records(sample_only: bool = false) -> Array:
    var records := []
    for pair_index in PALETTE_PAIRS.size():
        var source_pair: String = PALETTE_PAIRS[pair_index]
        var parts := source_pair.split("_")
        var wi := int(parts[0].trim_prefix("W")) - 1
        var fi := int(parts[1].trim_prefix("F")) - 1
        for ceiling_index in PALETTE_CEILING_IDS.size():
            var palette_id := "P%02d_C%02d" % [pair_index + 1, ceiling_index + 1]
            if sample_only and not PALETTE_SANITY_IDS.has(palette_id):
                continue
            for view in [
                {"light_mode": "NEUTRAL_ARCHITECTURAL", "camera": "EastApproachOverview"},
                {"light_mode": "RECEIVING_TARGET", "camera": "EastApproachOverview"},
                {"light_mode": "NEUTRAL_ARCHITECTURAL", "camera": "CeilingRead"},
                {"light_mode": "RECEIVING_TARGET", "camera": "CeilingRead"}
            ]:
                records.append({
                    "structural_palette_id": palette_id,
                    "source_pair_id": source_pair,
                    "wall_catalog_material_id": PAIR_WALL_IDS[wi],
                    "floor_catalog_material_id": PAIR_FLOOR_IDS[fi],
                    "ceiling_catalog_material_id": PALETTE_CEILING_IDS[ceiling_index],
                    "same_wall_ceiling_material": PAIR_WALL_IDS[wi] == PALETTE_CEILING_IDS[ceiling_index],
                    "light_mode": view["light_mode"],
                    "camera": view["camera"],
                    "filename": "%s__%s__%s.png" % [palette_id, String(view["light_mode"]).to_lower(), view["camera"]]
                })
    return records

func validate_palette_source() -> bool:
    if not validate_pair_source() or not validate_accepted_shell():
        return false
    var pair_zip := ProjectSettings.globalize_path(OUTPUT + "/eaf5_wall_floor_pair_review_01.zip")
    if not FileAccess.file_exists(pair_zip) or FileAccess.get_sha256(pair_zip) != PAIR_PACKAGE_SHA256:
        return false
    var source := _json_file(PAIR_DECISIONS)
    if source.get("accepted_shell_composition_sha256") != ACCEPTED_COMPOSITION_SHA256 or source.get("pair_review_package_sha256") != PAIR_PACKAGE_SHA256:
        return false
    var counts := {"KEEP_PAIR": 0, "HOLD_PAIR": 0, "DROP_PAIR": 0}
    var seen := {}
    var kept := []
    for entry in source.get("pairs", []):
        var pair_id: String = entry.get("pair_id", "")
        var decision: String = entry.get("decision", "")
        if seen.has(pair_id) or not _pair_ids().has(pair_id) or not counts.has(decision):
            return false
        seen[pair_id] = true
        counts[decision] += 1
        if decision == "KEEP_PAIR":
            kept.append(pair_id)
    if seen.size() != 15 or counts != {"KEEP_PAIR": 7, "HOLD_PAIR": 2, "DROP_PAIR": 6} or kept != PALETTE_PAIRS:
        return false
    var ceilings := _kept_ceiling_ids()
    if ceilings.size() != 5:
        return false
    for ceiling_id in PALETTE_CEILING_IDS:
        if not ceilings.has(ceiling_id):
            return false
    var sets: Dictionary = get_node("Proof").call("role_candidates")
    for role in ROLES:
        for material_id in (PAIR_WALL_IDS if role == "WALL_PRIMARY" else PAIR_FLOOR_IDS if role == "FLOOR_PRIMARY" else PALETTE_CEILING_IDS):
            var matching: Dictionary = {}
            for candidate in sets[role]:
                if candidate["catalog_material_id"] == material_id:
                    matching = candidate
                    break
            if matching.is_empty() or matching["effective_status"] != "APPROVED" or matching["mapping_mode"] != "UV":
                return false
            var spec := load("res://data/environment/material_catalog/approved_specs/" + material_id + ".tres") as EnvironmentSurfaceMaterialSpec
            if not catalog_spec_matches(matching, spec):
                return false
    return palette_capture_records().size() == 140 and palette_capture_records(true).size() == 12

func _capture_palettes(sample_only: bool) -> void:
    var proof := get_node("Proof")
    if not validate_palette_source():
        _fail("palette source differs from human pair decisions, approved UV specs, or accepted shell")
        return
    var folder := ProjectSettings.globalize_path(OUTPUT + ("/structural_palettes_01/sanity" if sample_only else "/structural_palettes_01"))
    if not _make_directory(folder):
        return
    get_window().size = CAPTURE_SIZE
    await get_tree().process_frame
    await get_tree().process_frame
    var records := []
    var fingerprints := _piece_fingerprints(proof)
    var sets: Dictionary = proof.call("role_candidates")
    for planned in palette_capture_records(sample_only):
        var wall_id: String = planned["wall_catalog_material_id"]
        var floor_id: String = planned["floor_catalog_material_id"]
        var ceiling_id: String = planned["ceiling_catalog_material_id"]
        if not proof.call("set_structural_palette", wall_id, floor_id, ceiling_id):
            _fail("could not apply palette " + String(planned["structural_palette_id"]))
            return
        proof.call("set_light_mode", String(planned["light_mode"]))
        proof.call("set_camera", String(planned["camera"]))
        await _settle_frame()
        var record: Dictionary = planned.duplicate(true)
        var ingredients := {}
        for role in ROLES:
            var material_id: String = wall_id if role == "WALL_PRIMARY" else floor_id if role == "FLOOR_PRIMARY" else ceiling_id
            for candidate in sets[role]:
                if candidate["catalog_material_id"] == material_id:
                    ingredients[role.to_lower().trim_suffix("_primary")] = candidate
                    break
        record["wall"] = {"catalog_material_id": wall_id, "display_name": ingredients["wall"]["display_name"]}
        record["floor"] = {"catalog_material_id": floor_id, "display_name": ingredients["floor"]["display_name"]}
        record["ceiling"] = {"catalog_material_id": ceiling_id, "display_name": ingredients["ceiling"]["display_name"]}
        record["material_parameters"] = {"wall": _pair_parameters(ingredients["wall"]), "floor": _pair_parameters(ingredients["floor"]), "ceiling": _pair_parameters(ingredients["ceiling"])}
        record["effective_mapping"] = {"wall": "UV", "floor": "UV", "ceiling": "UV"}
        record["transient_uv_review_override"] = false
        record["wall_reveal_uses_candidate"] = "opening_reveal" in ingredients["wall"]["approved_roles"]
        record["east_opening_wall_controlled_for_unapproved_reveal"] = not record["wall_reveal_uses_candidate"]
        record["review_context_material"] = "eaf5_review_control_only"
        record.merge(_camera_metadata(proof, String(record["camera"])))
        record["light_settings"] = proof.call("light_settings")
        record["shell_source_sha256"] = proof.call("shell_source_sha256")
        record["proof_composition_sha256"] = proof.call("proof_composition_sha256")
        record["piece_geometry_fingerprints"] = fingerprints
        if not _save_image(folder.path_join(String(record["filename"]))):
            return
        records.append(record)
        print("EAF5_PALETTE_CAPTURE palette=%s mode=%s camera=%s" % [record["structural_palette_id"], record["light_mode"], record["camera"]])
    var manifest := _base_manifest(proof)
    manifest["capture_type"] = "STRUCTURAL_PALETTE_SANITY" if sample_only else "STRUCTURAL_PALETTE"
    manifest["control_material"] = "eaf5_review_control_only"
    manifest["pair_decision_source"] = PAIR_DECISIONS
    manifest["pair_decision_sha256"] = FileAccess.get_sha256(PAIR_DECISIONS)
    manifest["pair_review_package_sha256"] = PAIR_PACKAGE_SHA256
    manifest["source_pair_ids"] = PALETTE_PAIRS
    manifest["ceiling_survivor_ids"] = PALETTE_CEILING_IDS
    manifest["structural_palette_ids"] = PALETTE_SANITY_IDS if sample_only else _palette_ids()
    manifest["structural_secondary_enabled"] = false
    manifest["transient_uv_override_count"] = 0
    manifest["records"] = records
    manifest["palettes"] = []
    var seen := {}
    for record in records:
        var palette_id: String = record["structural_palette_id"]
        if seen.has(palette_id):
            continue
        seen[palette_id] = true
        manifest["palettes"].append({
            "structural_palette_id": palette_id,
            "source_pair_id": record["source_pair_id"],
            "wall": record["wall"], "floor": record["floor"], "ceiling": record["ceiling"],
            "same_wall_ceiling_material": record["same_wall_ceiling_material"],
            "accepted_shell_composition_sha256": record["proof_composition_sha256"],
            "material_parameters": record["material_parameters"],
            "effective_mapping": record["effective_mapping"]
        })
    if not _write_json(folder.path_join("manifest.json"), manifest):
        return
    print("EAF5_PALETTE_CAPTURE_COMPLETE records=", records.size(), " sample=", sample_only)
    get_tree().quit(0)

func _palette_ids() -> Array:
    var ids := []
    for pair_index in PALETTE_PAIRS.size():
        for ceiling_index in PALETTE_CEILING_IDS.size():
            ids.append("P%02d_C%02d" % [pair_index + 1, ceiling_index + 1])
    return ids
func finish_capture_records(sample_only: bool = false) -> Array:
    var records := []
    var selected := _selected_finalists()
    var aft_spec := load("res://data/environment/material_catalog/approved_specs/" + FINISH_IDS[2] + ".tres") as EnvironmentSurfaceMaterialSpec
    var aft_override := aft_spec != null and aft_spec.mapping_mode == EnvironmentSurfaceMaterialSpec.MappingMode.TRIPLANAR
    for finalist_index in selected.size():
        var palette: Dictionary = selected[finalist_index]
        var structural_id := "S%02d" % [finalist_index + 1]
        for finish_index in FINISH_IDS.size():
            var finish_id := "A%02d" % finish_index
            var configuration_id := structural_id + "_" + finish_id
            if sample_only and not FINISH_SANITY_IDS.has(configuration_id):
                continue
            for view in [
                {"light_mode": "NEUTRAL_ARCHITECTURAL", "camera": "EastApproachOverview"},
                {"light_mode": "RECEIVING_TARGET", "camera": "EastApproachOverview"},
                {"light_mode": "NEUTRAL_ARCHITECTURAL", "camera": "FinishField"},
                {"light_mode": "RECEIVING_TARGET", "camera": "FinishField"}
            ]:
                records.append({
                    "configuration_id": configuration_id,
                    "structural_finalist_id": structural_id,
                    "structural_palette_id": palette["structural_palette_id"],
                    "finish_id": finish_id,
                    "wall_material_id": palette["wall"]["catalog_material_id"],
                    "floor_material_id": palette["floor"]["catalog_material_id"],
                    "ceiling_material_id": palette["ceiling"]["catalog_material_id"],
                    "finish_material_id": null if finish_index == 0 else FINISH_IDS[finish_index],
                    "finish_region": FINISH_REGION,
                    "finish_piece": "ReceivingSouth",
                    "applied_finish_enabled": finish_index != 0,
                    "transient_uv_override": finish_index == 2 and aft_override,
                    "light_mode": view["light_mode"],
                    "camera": view["camera"],
                    "filename": "%s__%s__%s.png" % [configuration_id, String(view["light_mode"]).to_lower(), view["camera"]]
                })
    return records

func _selected_finalists() -> Array:
    var by_id := {}
    for palette in _json_file(PASS5_MANIFEST).get("palettes", []):
        by_id[palette["structural_palette_id"]] = palette
    var selected := []
    for palette_id in FINALIST_PALETTE_IDS:
        if not by_id.has(palette_id):
            return []
        selected.append(by_id[palette_id])
    return selected

func validate_finish_source() -> bool:
    if not validate_palette_source():
        return false
    var pass5_zip := ProjectSettings.globalize_path(OUTPUT + "/eaf5_structural_palette_review_01.zip")
    if not FileAccess.file_exists(pass5_zip) or FileAccess.get_sha256(pass5_zip) != PASS5_PACKAGE_SHA256:
        return false
    var archive := ZIPReader.new()
    if archive.open(pass5_zip) != OK:
        return false
    var accepted_bytes := archive.read_file("manifest.json")
    archive.close()
    if accepted_bytes.is_empty() or accepted_bytes != FileAccess.get_file_as_bytes(ProjectSettings.globalize_path(PASS5_MANIFEST)):
        return false
    var manifest := _json_file(PASS5_MANIFEST)
    if manifest.get("proof_composition_sha256") != ACCEPTED_COMPOSITION_SHA256 or manifest.get("capture_type") != "STRUCTURAL_PALETTE" or manifest.get("palettes", []).size() != 35:
        return false
    var decisions := _json_file(PASS5_DECISIONS)
    if decisions.get("accepted_shell_composition_sha256") != ACCEPTED_COMPOSITION_SHA256 or decisions.get("structural_palette_review_package_sha256") != PASS5_PACKAGE_SHA256:
        return false
    var by_id := {}
    for palette in manifest["palettes"]:
        by_id[palette["structural_palette_id"]] = palette
    var seen := {}
    var kept := {}
    var counts := {"KEEP_PALETTE": 0, "HOLD_PALETTE": 0, "DROP_PALETTE": 0}
    for entry in decisions.get("palettes", []):
        var palette_id: String = entry.get("structural_palette_id", "")
        var decision: String = entry.get("decision", "")
        if seen.has(palette_id) or not by_id.has(palette_id) or not counts.has(decision):
            return false
        var palette: Dictionary = by_id[palette_id]
        if entry.get("source_pair_id") != palette["source_pair_id"] or entry.get("wall_catalog_material_id") != palette["wall"]["catalog_material_id"] or entry.get("floor_catalog_material_id") != palette["floor"]["catalog_material_id"] or entry.get("ceiling_catalog_material_id") != palette["ceiling"]["catalog_material_id"]:
            return false
        seen[palette_id] = true
        counts[decision] += 1
        if decision == "KEEP_PALETTE":
            kept[palette_id] = true
    if seen.size() != 35 or counts != {"KEEP_PALETTE": 6, "HOLD_PALETTE": 9, "DROP_PALETTE": 20} or kept.size() != 6:
        return false
    for palette_id in FINALIST_PALETTE_IDS:
        if not kept.has(palette_id):
            return false
    var available := {}
    for record in Query.query("", "applied_finish", "wall"):
        available[record["catalog_material_id"]] = record
    for index in range(1, FINISH_IDS.size()):
        var material_id: String = FINISH_IDS[index]
        if not available.has(material_id):
            return false
        var record: Dictionary = available[material_id]
        if record.get("effective_status") != "APPROVED" or record.get("surface_family") not in ["cement_render", "applied_paint"] or not record.get("current_source_matches_review", false):
            return false
        var spec := load("res://data/environment/material_catalog/approved_specs/" + material_id + ".tres") as EnvironmentSurfaceMaterialSpec
        if not catalog_spec_matches(record, spec):
            return false
        if index == 2:
            if record["mapping_mode"] not in ["TRIPLANAR", "UV"]:
                return false
        elif record["mapping_mode"] != "UV":
            return false
    var records := finish_capture_records()
    return _selected_finalists().size() == 6 and records.size() == 144 and finish_capture_records(true).size() == 16

func _capture_finishes(sample_only: bool) -> void:
    var proof := get_node("Proof")
    if not validate_finish_source():
        _fail("finish source differs from human structural decisions, approved material specs, or accepted shell")
        return
    var folder := ProjectSettings.globalize_path(OUTPUT + ("/applied_finish_screen_01/sanity" if sample_only else "/applied_finish_screen_01"))
    if not _make_directory(folder):
        return
    get_window().size = CAPTURE_SIZE
    await get_tree().process_frame
    await get_tree().process_frame
    var records := []
    var fingerprints := _piece_fingerprints(proof)
    var palette_by_id := {}
    for palette in _selected_finalists():
        palette_by_id[palette["structural_palette_id"]] = palette
    var finish_by_id := {}
    for candidate in Query.query("", "applied_finish", "wall"):
        if FINISH_IDS.has(candidate["catalog_material_id"]):
            finish_by_id[candidate["catalog_material_id"]] = candidate
    for planned in finish_capture_records(sample_only):
        var wall_id: String = planned["wall_material_id"]
        var floor_id: String = planned["floor_material_id"]
        var ceiling_id: String = planned["ceiling_material_id"]
        var finish_material_id := "" if planned["finish_material_id"] == null else String(planned["finish_material_id"])
        if not proof.call("set_finish_screen", wall_id, floor_id, ceiling_id, finish_material_id):
            _fail("could not apply finish screen " + String(planned["configuration_id"]))
            return
        proof.call("set_light_mode", String(planned["light_mode"]))
        proof.call("set_camera", String(planned["camera"]))
        await _settle_frame()
        var record: Dictionary = planned.duplicate(true)
        var palette: Dictionary = palette_by_id[record["structural_palette_id"]]
        record["wall"] = palette["wall"]
        record["floor"] = palette["floor"]
        record["ceiling"] = palette["ceiling"]
        record["finish_display_name"] = "NO_FINISH"
        record["finish_source_fingerprint"] = null
        record["material_parameters"] = palette["material_parameters"].duplicate(true)
        record["effective_mapping"] = {"wall": "UV", "floor": "UV", "ceiling": "UV", "finish": null}
        if not finish_material_id.is_empty():
            var finish: Dictionary = finish_by_id[finish_material_id]
            record["finish_display_name"] = finish["display_name"]
            record["finish_source_fingerprint"] = finish["reviewed_source_fingerprint"]
            record["material_parameters"]["finish"] = _pair_parameters(finish)
            record["effective_mapping"]["finish"] = "UV"
        record["review_context_material"] = "eaf5_review_control_only"
        record.merge(_camera_metadata(proof, String(record["camera"])))
        record["light_settings"] = proof.call("light_settings")
        record["shell_source_sha256"] = proof.call("shell_source_sha256")
        record["proof_composition_sha256"] = proof.call("proof_composition_sha256")
        record["piece_geometry_fingerprints"] = fingerprints
        if not _save_image(folder.path_join(String(record["filename"]))):
            return
        records.append(record)
        print("EAF5_FINISH_CAPTURE configuration=%s mode=%s camera=%s" % [record["configuration_id"], record["light_mode"], record["camera"]])
    var manifest := _base_manifest(proof)
    manifest["capture_type"] = "APPLIED_FINISH_SCREEN_SANITY" if sample_only else "APPLIED_FINISH_SCREEN"
    manifest.erase("applied_finish_enabled")
    manifest["applied_finish_mode"] = "PER_CONFIGURATION"
    manifest["control_material"] = "eaf5_review_control_only"
    manifest["pass5_decision_source"] = PASS5_DECISIONS
    manifest["pass5_decision_sha256"] = FileAccess.get_sha256(PASS5_DECISIONS)
    manifest["pass5_review_package_sha256"] = PASS5_PACKAGE_SHA256
    manifest["structural_finalist_palette_ids"] = FINALIST_PALETTE_IDS
    manifest["finish_material_ids"] = FINISH_IDS.slice(1)
    manifest["finish_region"] = FINISH_REGION
    manifest["finish_piece"] = "ReceivingSouth"
    manifest["structural_secondary_enabled"] = false
    manifest["eaf4_wear_enabled"] = false
    manifest["transient_uv_finish_ids"] = [FINISH_IDS[2]] if records.any(func(record): return record["transient_uv_override"]) else []
    manifest["transient_uv_override_configuration_count"] = 6 if not manifest["transient_uv_finish_ids"].is_empty() else 0
    manifest["configuration_ids"] = FINISH_SANITY_IDS if sample_only else _finish_configuration_ids()
    manifest["records"] = records
    manifest["configurations"] = []
    var seen := {}
    for record in records:
        var configuration_id: String = record["configuration_id"]
        if seen.has(configuration_id):
            continue
        seen[configuration_id] = true
        manifest["configurations"].append({
            "configuration_id": configuration_id,
            "structural_finalist_id": record["structural_finalist_id"],
            "structural_palette_id": record["structural_palette_id"],
            "finish_id": record["finish_id"],
            "wall_material_id": record["wall_material_id"],
            "floor_material_id": record["floor_material_id"],
            "ceiling_material_id": record["ceiling_material_id"],
            "finish_material_id": record["finish_material_id"],
            "finish_display_name": record["finish_display_name"],
            "finish_region": FINISH_REGION,
            "finish_piece": "ReceivingSouth",
            "applied_finish_enabled": record["applied_finish_enabled"],
            "transient_uv_override": record["transient_uv_override"],
            "material_parameters": record["material_parameters"],
            "effective_mapping": record["effective_mapping"],
            "accepted_shell_composition_sha256": record["proof_composition_sha256"]
        })
    if not _write_json(folder.path_join("manifest.json"), manifest):
        return
    print("EAF5_FINISH_CAPTURE_COMPLETE records=", records.size(), " sample=", sample_only)
    get_tree().quit(0)

func _finish_configuration_ids() -> Array:
    var ids := []
    for finalist_index in FINALIST_PALETTE_IDS.size():
        for finish_index in FINISH_IDS.size():
            ids.append("S%02d_A%02d" % [finalist_index + 1, finish_index])
    return ids

func layout_capture_records(sample_only: bool = false, scale_only: bool = false) -> Array:
    var records := []
    var selected := _selected_finalists()
    if selected.size() != 6:
        return records
    for case in LAYOUT_CASES:
        var configuration_id: String = case[0]
        if sample_only and not LAYOUT_SANITY_IDS.has(configuration_id):
            continue
        if scale_only and not LAYOUT_SCALE_IDS.has(configuration_id):
            continue
        var index: int = case[1]
        var finish_index: int = case[2]
        var layout_id: String = case[3]
        var palette: Dictionary = selected[index]
        var size: Variant = null
        var wall_position: Variant = null
        if layout_id == "L01":
            size = [4.2, 2.4]
            wall_position = {"offset_x_from_wall_center_m": 0.0, "center_y_m": 2.1, "world_center_m": [5.1, 2.1, 4.85]}
        elif layout_id == "L02":
            size = [1.8, 1.2]
            wall_position = {"offset_x_from_wall_center_m": -2.0, "center_y_m": 1.55, "world_center_m": [3.1, 1.55, 4.85]}
        var views := [
            ["NEUTRAL_ARCHITECTURAL", "EastApproachOverview"],
            ["RECEIVING_TARGET", "EastApproachOverview"],
            ["NEUTRAL_ARCHITECTURAL", "FinishPatch" if layout_id == "L02" else "FinishField"],
            ["RECEIVING_TARGET", "FinishPatch" if layout_id == "L02" else "FinishField"],
        ]
        if scale_only:
            views = [["NEUTRAL_ARCHITECTURAL", "FinishPatch" if layout_id == "L02" else "FinishField"]]
        for view in views:
            records.append({
                "configuration_id": configuration_id,
                "source_screen_configuration_id": "S%02d_A%02d" % [index + 1, finish_index],
                "structural_finalist_id": "S%02d" % [index + 1],
                "structural_palette_id": palette["structural_palette_id"],
                "wall_material_id": palette["wall"]["catalog_material_id"],
                "floor_material_id": palette["floor"]["catalog_material_id"],
                "ceiling_material_id": palette["ceiling"]["catalog_material_id"],
                "finish_id": "A%02d" % finish_index,
                "finish_material_id": null if finish_index == 0 else FINISH_IDS[finish_index],
                "layout_id": layout_id,
                "layout_name": "L00_NO_FINISH" if layout_id == "L00" else "L01_INHERITED_FIELD" if layout_id == "L01" else "L02_LOCAL_PATCH",
                "finish_piece": "ReceivingSouth",
                "physical_size_m": size,
                "wall_local_position": wall_position,
                "surface_offset_m": null if layout_id == "L00" else 0.002,
                "approved_finish_mapping": null if finish_index == 0 else "TRIPLANAR" if finish_index == 2 else "UV",
                "effective_finish_mapping": null if finish_index == 0 else "UV",
                "transient_uv_override": finish_index == 2,
                "light_mode": view[0],
                "camera": view[1],
                "filename": "%s__%s__%s.png" % [configuration_id, String(view[0]).to_lower(), view[1]],
            })
    return records

func validate_layout_source() -> bool:
    if not validate_finish_source():
        return false
    var package := ProjectSettings.globalize_path(OUTPUT + "/eaf5_applied_finish_screen_01_review.zip")
    if not FileAccess.file_exists(package) or FileAccess.get_sha256(package) != PASS6A_PACKAGE_SHA256:
        return false
    var archive := ZIPReader.new()
    if archive.open(package) != OK:
        return false
    var manifest_bytes := archive.read_file("manifest.json")
    archive.close()
    if manifest_bytes != FileAccess.get_file_as_bytes(ProjectSettings.globalize_path(PASS6A_MANIFEST)):
        return false
    var source := _json_file(PASS6A_MANIFEST)
    var decisions := _json_file(PASS6A_DECISIONS)
    if source.get("capture_type") != "APPLIED_FINISH_SCREEN" or source.get("configurations", []).size() != 36:
        return false
    if decisions.get("pass6a_review_package_sha256") != PASS6A_PACKAGE_SHA256 or decisions.get("accepted_shell_composition_sha256") != ACCEPTED_COMPOSITION_SHA256:
        return false
    var source_by_id := {}
    for entry in source["configurations"]:
        source_by_id[entry["configuration_id"]] = entry
    var seen := {}
    var counts := {"CONTROL_NO_FINISH": 0, "KEEP_FINISH_VARIANT": 0, "HOLD_FINISH_VARIANT": 0, "DROP_FINISH_VARIANT": 0}
    var by_id := {}
    for entry in decisions.get("configurations", []):
        var cid: String = entry.get("configuration_id", "")
        var decision: String = entry.get("decision", "")
        if seen.has(cid) or not source_by_id.has(cid) or not counts.has(decision):
            return false
        var original: Dictionary = source_by_id[cid]
        if entry.get("structural_palette_id") != original["structural_palette_id"] or entry.get("finish_material_id") != original["finish_material_id"] or entry.get("finish_id") != original["finish_id"]:
            return false
        seen[cid] = true
        by_id[cid] = decision
        counts[decision] += 1
    if seen.size() != 36 or counts != {"CONTROL_NO_FINISH": 6, "KEEP_FINISH_VARIANT": 4, "HOLD_FINISH_VARIANT": 7, "DROP_FINISH_VARIANT": 19}:
        return false
    for cid in ["S01_A01", "S05_A04", "S06_A01", "S06_A05"]:
        if by_id.get(cid) != "KEEP_FINISH_VARIANT":
            return false
    for cid in ["S01_A02", "S01_A03"]:
        if by_id.get(cid) != "HOLD_FINISH_VARIANT":
            return false
    var records := layout_capture_records()
    if records.size() != 52 or layout_capture_records(true).size() != 20 or layout_capture_records(false, true).size() != 2:
        return false
    var config_seen := {}
    for record in records:
        var cid: String = record["source_screen_configuration_id"]
        if by_id.get(cid) != ("CONTROL_NO_FINISH" if record["layout_id"] == "L00" else "HOLD_FINISH_VARIANT" if record["configuration_id"].begins_with("Q") else "KEEP_FINISH_VARIANT"):
            return false
        config_seen[record["configuration_id"]] = true
        if record["finish_material_id"] != null:
            var material_id: String = record["finish_material_id"]
            var spec := load("res://data/environment/material_catalog/approved_specs/" + material_id + ".tres") as EnvironmentSurfaceMaterialSpec
            if spec == null or spec.mapping_name() != record["approved_finish_mapping"]:
                return false
    return config_seen.size() == 13

func _capture_layouts(sample_only: bool, scale_only: bool) -> void:
    var proof := get_node("Proof")
    if not validate_layout_source():
        _fail("layout source differs from Pass 6A decisions, approved specs or accepted shell")
        return
    var suffix := "/scale_sanity" if scale_only else "/sanity" if sample_only else ""
    var folder := ProjectSettings.globalize_path(OUTPUT + "/applied_finish_layouts_01" + suffix)
    if not _make_directory(folder):
        return
    get_window().size = CAPTURE_SIZE
    await get_tree().process_frame
    await get_tree().process_frame
    var records := []
    var fingerprints := _piece_fingerprints(proof)
    var palette_by_id := {}
    for palette in _selected_finalists():
        palette_by_id[palette["structural_palette_id"]] = palette
    var finish_by_id := {}
    for candidate in Query.query("", "applied_finish", "wall"):
        finish_by_id[candidate["catalog_material_id"]] = candidate
    for planned in layout_capture_records(sample_only, scale_only):
        var wall_id: String = planned["wall_material_id"]
        var floor_id: String = planned["floor_material_id"]
        var ceiling_id: String = planned["ceiling_material_id"]
        var finish_id := "" if planned["finish_material_id"] == null else String(planned["finish_material_id"])
        if not proof.call("set_finish_layout", wall_id, floor_id, ceiling_id, finish_id, String(planned["layout_id"])):
            _fail("could not apply layout " + String(planned["configuration_id"]))
            return
        proof.call("set_light_mode", String(planned["light_mode"]))
        proof.call("set_camera", String(planned["camera"]))
        await _settle_frame()
        var record: Dictionary = planned.duplicate(true)
        var palette: Dictionary = palette_by_id[record["structural_palette_id"]]
        record["wall"] = palette["wall"]
        record["floor"] = palette["floor"]
        record["ceiling"] = palette["ceiling"]
        record["material_parameters"] = palette["material_parameters"].duplicate(true)
        record["finish_display_name"] = "NO_FINISH"
        record["finish_source_fingerprint"] = null
        record["effective_mapping"] = {"wall": "UV", "floor": "UV", "ceiling": "UV", "finish": null}
        record["patch_mesh_uv_extent_m"] = null
        record["patch_root_scale"] = null
        record["patch_mesh_size_m"] = null
        record["expected_source_repeats"] = null
        if not finish_id.is_empty():
            var finish: Dictionary = finish_by_id[finish_id]
            record["finish_display_name"] = finish["display_name"]
            record["finish_source_fingerprint"] = finish["reviewed_source_fingerprint"]
            record["material_parameters"]["finish"] = _pair_parameters(finish)
            record["effective_mapping"]["finish"] = "UV"
            var patch := proof.get_node("FinishPatches").get_child(0) as EnvironmentMaterialPatch
            var quad := patch.get_node("PatchQuad") as MeshInstance3D
            var arrays := quad.mesh.surface_get_arrays(0)
            var uv: PackedVector2Array = arrays[Mesh.ARRAY_TEX_UV]
            var vertices: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
            var uv_min := Vector2(INF, INF)
            var uv_max := Vector2(-INF, -INF)
            var mesh_min := Vector2(INF, INF)
            var mesh_max := Vector2(-INF, -INF)
            for index in uv.size():
                uv_min = uv_min.min(uv[index])
                uv_max = uv_max.max(uv[index])
                mesh_min = mesh_min.min(Vector2(vertices[index].x, vertices[index].y))
                mesh_max = mesh_max.max(Vector2(vertices[index].x, vertices[index].y))
            var span := uv_max - uv_min
            var size := mesh_max - mesh_min
            if patch.mode != EnvironmentMaterialPatch.Mode.EAF3_MATERIAL or patch.scale != Vector3.ONE or not span.is_equal_approx(patch.physical_size_m) or not size.is_equal_approx(patch.physical_size_m):
                _fail("physical patch scale mismatch " + String(record["configuration_id"]))
                return
            record["patch_mesh_uv_extent_m"] = _v2(span)
            record["patch_root_scale"] = _v3(patch.scale)
            record["patch_mesh_size_m"] = _v2(size)
            record["expected_source_repeats"] = _v2(size / float(finish["meters_per_repeat"]))
        record["review_context_material"] = "eaf5_review_control_only"
        record.merge(_camera_metadata(proof, String(record["camera"])))
        record["light_settings"] = proof.call("light_settings")
        record["shell_source_sha256"] = proof.call("shell_source_sha256")
        record["proof_composition_sha256"] = proof.call("proof_composition_sha256")
        record["piece_geometry_fingerprints"] = fingerprints
        if not _save_image(folder.path_join(String(record["filename"]))):
            return
        records.append(record)
        print("EAF5_LAYOUT_CAPTURE configuration=%s mode=%s camera=%s" % [record["configuration_id"], record["light_mode"], record["camera"]])
    var manifest := _base_manifest(proof)
    manifest["capture_type"] = "APPLIED_FINISH_LAYOUT_SCALE" if scale_only else "APPLIED_FINISH_LAYOUT_SANITY" if sample_only else "APPLIED_FINISH_LAYOUT"
    manifest.erase("applied_finish_enabled")
    manifest["applied_finish_mode"] = "BOUNDED_EAF3_MATERIAL_PATCH"
    manifest["pass6a_decision_source"] = PASS6A_DECISIONS
    manifest["pass6a_decision_sha256"] = FileAccess.get_sha256(PASS6A_DECISIONS)
    manifest["pass6a_review_package_sha256"] = PASS6A_PACKAGE_SHA256
    manifest["structural_palette_ids"] = ["P01_C02", "P01_C01", "P01_C05"]
    manifest["finish_piece"] = "ReceivingSouth"
    manifest["structural_secondary_enabled"] = false
    manifest["eaf4_wear_enabled"] = false
    manifest["configuration_ids"] = []
    manifest["records"] = records
    manifest["configurations"] = []
    var seen := {}
    for record in records:
        var configuration_id: String = record["configuration_id"]
        if seen.has(configuration_id):
            continue
        seen[configuration_id] = true
        manifest["configuration_ids"].append(configuration_id)
        var configuration: Dictionary = record.duplicate(true)
        for field in ["filename", "light_mode", "camera", "camera_transform", "camera_fov", "light_settings", "shell_source_sha256", "proof_composition_sha256", "piece_geometry_fingerprints"]:
            configuration.erase(field)
        configuration["accepted_shell_composition_sha256"] = ACCEPTED_COMPOSITION_SHA256
        manifest["configurations"].append(configuration)
    var transient_count := 0
    for configuration in manifest["configurations"]:
        if configuration["transient_uv_override"]:
            transient_count += 1
    manifest["transient_uv_override_configuration_count"] = transient_count
    if not _write_json(folder.path_join("manifest.json"), manifest):
        return
    print("EAF5_LAYOUT_CAPTURE_COMPLETE records=", records.size(), " sample=", sample_only, " scale=", scale_only)
    get_tree().quit(0)

func wear_capture_records(sample_only: bool = false) -> Array:
    var selection := _json_file(PALETTE_SELECTION)
    var palettes: Array = selection.get("palettes", [])
    if sample_only:
        palettes = palettes.slice(0, 1)
    var records := []
    for palette in palettes:
        for camera in ["EastApproachOverview", "WallCausalDetail", "FreightFloorDetail"]:
            for mode in (["NEUTRAL_ARCHITECTURAL"] if sample_only else LIGHT_MODES):
                for state in ["WEAR_OFF", "WEAR_ON"]:
                    var palette_id := String(palette["structural_palette_id"])
                    records.append({
                        "selection_role": palette["selection_role"],
                        "structural_palette_id": palette_id,
                        "wall": palette["wall"], "floor": palette["floor"], "ceiling": palette["ceiling"],
                        "applied_finish": "NONE", "structural_secondary": "NONE",
                        "camera": camera, "light_mode": mode, "wear_state": state,
                        "filename": "%s__%s__%s__%s.png" % [palette_id, camera, mode.to_lower(), state.to_lower()],
                    })
    return records

func wear_calibration_records() -> Array:
    var selection := _json_file(PALETTE_SELECTION)
    var records := []
    for palette in selection.get("palettes", []):
        var role := String(palette["selection_role"])
        var palette_id := String(palette["structural_palette_id"])
        var states := ["WEAR_OFF", "L0", "L1", "L2", "D0", "D1", "D2", "R0", "R1", "R2"] if role == "PRIMARY" else ["WEAR_OFF", "L2", "D2", "R2"]
        for state in states:
            var cameras := ["WallCausalDetail", "FreightFloorDetail"] if state == "WEAR_OFF" else ["WallCausalDetail" if state.begins_with("L") else "FreightFloorDetail"]
            for camera in cameras:
                for mode in LIGHT_MODES:
                    records.append({
                        "selection_role": role, "structural_palette_id": palette_id,
                        "wall": palette["wall"], "floor": palette["floor"], "ceiling": palette["ceiling"],
                        "applied_finish": "NONE", "structural_secondary": "NONE",
                        "wear_state": state, "camera": camera, "light_mode": mode,
                        "filename": "%s__%s__%s__%s.png" % [palette_id, camera, mode.to_lower(), state.to_lower()],
                    })
    return records

func _capture_wear_calibration() -> void:
    if not validate_wear_source():
        _fail("wear calibration preflight failed")
        return
    var source := _json_file(WEAR_CALIBRATION)
    var prior := _json_file(WEAR_PROOF)
    var expected := []
    for item in prior["instances"]:
        if item["instance_id"] != "WEA02":
            expected.append(item)
    if source.get("instances") != expected or source.get("accepted_shell_composition_sha256") != ACCEPTED_COMPOSITION_SHA256:
        _fail("wear calibration source drift")
        return
    var proof := get_node("Proof")
    var folder := ProjectSettings.globalize_path(OUTPUT + "/wear_calibration_01")
    if not _make_directory(folder):
        return
    get_window().size = CAPTURE_SIZE
    await get_tree().process_frame
    await get_tree().process_frame
    var records := []
    var fingerprints := _piece_fingerprints(proof)
    for planned in wear_calibration_records():
        var state := String(planned["wear_state"])
        var instance_id := "WEAR_OFF"
        var variant := -1
        if state != "WEAR_OFF":
            instance_id = {"L": "WEA01", "D": "WEA03", "R": "WEA04"}[state.substr(0, 1)]
            variant = int(state.substr(1, 1))
        if not proof.call("set_wear_calibration", String(planned["structural_palette_id"]), instance_id, variant):
            _fail("cannot apply wear calibration " + state)
            return
        proof.call("set_light_mode", String(planned["light_mode"]))
        proof.call("set_camera", String(planned["camera"]))
        await _settle_frame()
        var record: Dictionary = planned.duplicate(true)
        record.merge(_camera_metadata(proof, String(record["camera"])))
        record["light_settings"] = proof.call("light_settings")
        record["cause_proxies"] = proof.call("cause_proxy_inventory")
        record["wear_instances"] = proof.call("wear_instance_inventory")
        record["visible_wear_overlays"] = proof.call("visible_wear_count")
        record["piece_geometry_fingerprints"] = fingerprints
        record["proof_composition_sha256"] = proof.call("proof_composition_sha256")
        if record["visible_wear_overlays"] != (0 if state == "WEAR_OFF" else 1) or record["wear_instances"].size() != 3 or record["cause_proxies"].size() != 2:
            _fail("calibration inventory mismatch " + state)
            return
        if not _save_image(folder.path_join(String(record["filename"]))):
            return
        records.append(record)
        print("EAF5_WEAR_CALIBRATION_CAPTURE ", record["filename"])
    var manifest := _base_manifest(proof)
    manifest.erase("wear_enabled")
    manifest.erase("palette_pairs_generated")
    manifest["capture_type"] = "WEAR_CALIBRATION_01"
    manifest["palette_selection"] = _json_file(PALETTE_SELECTION)
    manifest["wear_calibration"] = source
    manifest["wear_calibration_sha256"] = FileAccess.get_sha256(WEAR_CALIBRATION)
    manifest["pass7_wear_proof_sha256"] = FileAccess.get_sha256(WEAR_PROOF)
    manifest["records"] = records
    if records.size() != 32 or not _write_json(folder.path_join("manifest.json"), manifest):
        _fail("wear calibration manifest failed")
        return
    print("EAF5_WEAR_CALIBRATION_COMPLETE records=", records.size())
    get_tree().quit(0)

func validate_wear_source() -> bool:
    if not validate_accepted_shell():
        return false
    var selection := _json_file(PALETTE_SELECTION)
    var decisions := _json_file(PASS6B_DECISIONS)
    var manifest := _json_file(WEAR_PROOF)
    if selection.get("base_applied_finish") != "NONE" or selection.get("structural_secondary") != "NONE" or manifest.get("accepted_shell_composition_sha256") != ACCEPTED_COMPOSITION_SHA256:
        return false
    if decisions.get("base_applied_finish_direction") != "NO_FINISH" or int(decisions.get("decision_counts", {}).get("KEEP_LAYOUT_VARIANT", -1)) != 0 or int(decisions.get("decision_counts", {}).get("HOLD_LAYOUT_VARIANT", -1)) != 5 or int(decisions.get("decision_counts", {}).get("DROP_LAYOUT_VARIANT", -1)) != 5 or int(decisions.get("decision_counts", {}).get("CONTROL_NO_FINISH", -1)) != 3:
        return false
    if selection.get("pass5_human_decision_sha256") != FileAccess.get_sha256(PASS5_DECISIONS):
        return false
    var palettes: Array = selection.get("palettes", [])
    if palettes.size() != 2 or palettes[0].get("selection_role") != "PRIMARY" or palettes[0].get("structural_palette_id") != "P01_C02" or palettes[1].get("selection_role") != "ALTERNATE" or palettes[1].get("structural_palette_id") != "P05_C03":
        return false
    for palette in palettes:
        if palette.get("applied_finish") != "NONE" or palette.get("structural_secondary") != "NONE":
            return false
    var catalog := WearQuery.load_catalog()
    var approved := {}
    var status_counts := {"APPROVED": 0, "DEFERRED": 0}
    for record in catalog:
        var status := String(record.get("effective_status", ""))
        if status_counts.has(status):
            status_counts[status] += 1
        if status == "APPROVED":
            approved[record["catalog_wear_id"]] = record
    if status_counts != {"APPROVED": 27, "DEFERRED": 1}:
        return false
    var instances: Array = manifest.get("instances", [])
    if instances.size() != 4:
        return false
    var seen := {}
    for item in instances:
        var wear_id := String(item.get("catalog_wear_id", ""))
        if seen.has(wear_id) or not approved.has(wear_id):
            return false
        seen[wear_id] = true
        var record: Dictionary = approved[wear_id]
        if record.get("reviewed_source_fingerprint") != record.get("current_source_fingerprint") or record.get("reviewed_source_fingerprint") != item.get("approved_source_fingerprint"):
            return false
        var mask: Dictionary = record.get("imperfection", {})
        if not mask.is_empty() and record.get("current_imperfection_fingerprint") != mask.get("source_fingerprint"):
            return false
        var path := String(item.get("approved_spec_path", ""))
        if path != "res://data/environment/wear_catalog/approved_specs/" + wear_id + ".tres":
            return false
        var spec := load(path) as EnvironmentWearOverlaySpec
        if spec == null or not spec.validate().is_empty() or spec.overlay_id != wear_id or spec.source_fingerprint != record["reviewed_source_fingerprint"]:
            return false
        if not spec.physical_size_m.is_equal_approx(Vector2(float(record["default_size"][0]), float(record["default_size"][1]))) or not is_equal_approx(spec.surface_offset_m, float(record["surface_offset"])):
            return false
    return true

func _capture_wear(sample_only: bool) -> void:
    if not validate_wear_source():
        _fail("wear proof preflight failed")
        return
    var proof := get_node("Proof")
    var relative := OUTPUT + "/final_wear_proof_01" + ("/sanity" if sample_only else "")
    var folder := ProjectSettings.globalize_path(relative)
    if not _make_directory(folder):
        return
    get_window().size = CAPTURE_SIZE
    await get_tree().process_frame
    await get_tree().process_frame
    var records := []
    var fingerprints := _piece_fingerprints(proof)
    for planned in wear_capture_records(sample_only):
        var state_on: bool = planned["wear_state"] == "WEAR_ON"
        if not proof.call("set_wear_proof", String(planned["structural_palette_id"]), state_on):
            _fail("cannot apply wear proof " + String(planned["structural_palette_id"]))
            return
        proof.call("set_light_mode", String(planned["light_mode"]))
        proof.call("set_camera", String(planned["camera"]))
        await _settle_frame()
        var record: Dictionary = planned.duplicate(true)
        record.merge(_camera_metadata(proof, String(record["camera"])))
        record["light_settings"] = proof.call("light_settings")
        record["cause_proxies"] = proof.call("cause_proxy_inventory")
        record["wear_instances"] = proof.call("wear_instance_inventory")
        record["visible_wear_overlays"] = proof.call("visible_wear_count")
        record["piece_geometry_fingerprints"] = fingerprints
        record["proof_composition_sha256"] = proof.call("proof_composition_sha256")
        if record["visible_wear_overlays"] != (4 if state_on else 0) or record["cause_proxies"].size() != 2 or record["wear_instances"].size() != 4:
            _fail("OFF/ON inventory mismatch " + String(record["filename"]))
            return
        if not _save_image(folder.path_join(String(record["filename"]))):
            return
        records.append(record)
        print("EAF5_WEAR_CAPTURE ", record["filename"])
    var manifest := _base_manifest(proof)
    manifest.erase("wear_enabled")
    manifest.erase("palette_pairs_generated")
    manifest["capture_type"] = "CAUSAL_WEAR_SANITY" if sample_only else "CAUSAL_WEAR_FINAL"
    manifest["palette_selection"] = _json_file(PALETTE_SELECTION)
    manifest["wear_composition"] = _json_file(WEAR_PROOF)
    manifest["wear_composition_sha256"] = FileAccess.get_sha256(WEAR_PROOF)
    manifest["pass6b_decisions_sha256"] = FileAccess.get_sha256(PASS6B_DECISIONS)
    manifest["applied_finish"] = "NONE"
    manifest["structural_secondary"] = "NONE"
    manifest["records"] = records
    if not _write_json(folder.path_join("manifest.json"), manifest):
        return
    print("EAF5_WEAR_CAPTURE_COMPLETE records=", records.size(), " sanity=", sample_only)
    get_tree().quit(0)

func _v2(value: Vector2) -> Array:
    return [value.x, value.y]

func _pair_parameters(candidate: Dictionary) -> Dictionary:
    var result := {}
    for field in ["meters_per_repeat", "normal_y_flip", "normal_strength", "roughness_multiplier", "metallic_multiplier", "albedo_multiplier"]:
        result[field] = candidate[field]
    return result

func _pair_ids() -> Array:
    var result := []
    for wi in PAIR_WALL_IDS.size():
        for fi in PAIR_FLOOR_IDS.size():
            result.append("W%02d_F%02d" % [wi + 1, fi + 1])
    return result

func _kept_ceiling_ids() -> Array:
    var result := []
    for entry in _json_file(ROLE_DECISIONS).get("decisions", []):
        if entry["role"] == "CEILING_PRIMARY" and entry["decision"] == "KEEP":
            result.append(entry["catalog_material_id"])
    return result

func _json_file(path: String) -> Dictionary:
    var content := FileAccess.get_file_as_string(ProjectSettings.globalize_path(path))
    var parsed: Variant = JSON.parse_string(content)
    return parsed if parsed is Dictionary else {}

func validate_role_candidates() -> bool:
    var proof := get_node("Proof")
    var sets: Dictionary = proof.call("role_candidates")
    for role in ROLES:
        var folder: String = role.to_lower().trim_suffix("_primary")
        var old := _json_file(OUTPUT + "/role_isolation_01/" + folder + "/manifest.json")
        if old.is_empty() or not old.has("candidate_ids"):
            return false
        var ids := _ids(sets[role])
        if ids != old["candidate_ids"]:
            return false
        for candidate in sets[role]:
            if candidate.get("effective_status") != "APPROVED" or not candidate.get("current_source_matches_review", false):
                return false
            var material_id := String(candidate["catalog_material_id"])
            var spec := load("res://data/environment/material_catalog/approved_specs/" + material_id + ".tres") as EnvironmentSurfaceMaterialSpec
            if not catalog_spec_matches(candidate, spec):
                return false
    return true

func catalog_spec_matches(record: Dictionary, spec: EnvironmentSurfaceMaterialSpec) -> bool:
    if spec == null or spec.material_id != record.get("catalog_material_id") or not spec.validate().is_empty():
        return false
    if spec.surface_family != record.get("surface_family") or spec.vdd_layer != record.get("vdd_layer") or spec.mapping_name() != record.get("mapping_mode") or spec.normal_y_flip != record.get("normal_y_flip"):
        return false
    for field in ["meters_per_repeat", "normal_strength", "roughness_multiplier", "metallic_multiplier", "albedo_multiplier"]:
        if not is_equal_approx(float(spec.get(field)), float(record.get(field, -1000.0))):
            return false
    return true

func validate_accepted_shell(package_path: String = OUTPUT + "/eaf5_shell_review_02.zip") -> bool:
    var proof := get_node("Proof")
    var absolute := ProjectSettings.globalize_path(package_path)
    if not FileAccess.file_exists(absolute) or FileAccess.get_sha256(absolute) != ACCEPTED_SHELL_ZIP_SHA256:
        return false
    var archive := ZIPReader.new()
    if archive.open(absolute) != OK:
        return false
    var manifest_bytes := archive.read_file("manifest.json")
    archive.close()
    var parsed: Variant = JSON.parse_string(manifest_bytes.get_string_from_utf8())
    if not parsed is Dictionary:
        return false
    var accepted: Dictionary = parsed
    if accepted.get("proof_composition_sha256") != ACCEPTED_COMPOSITION_SHA256 or accepted.get("shell_source_sha256") != ACCEPTED_SOURCE_SHA256:
        return false
    if proof.call("proof_composition_sha256") != ACCEPTED_COMPOSITION_SHA256 or proof.call("shell_source_sha256") != ACCEPTED_SOURCE_SHA256:
        return false
    var pieces: Array = accepted.get("pieces", [])
    if pieces.size() != 14:
        return false
    var expected := {}
    for piece in pieces:
        expected[piece["piece_id"]] = piece["geometry_fingerprint"]
    return expected == _piece_fingerprints(proof)

func _capture_roles(sample_only: bool) -> void:
    var proof := get_node("Proof")
    if not validate_role_candidates() or not validate_accepted_shell():
        _fail("v2 role capture preflight differs from accepted catalog or shell")
        return
    var output := ProjectSettings.globalize_path(role_capture_directory(sample_only))
    if not _make_directory(output):
        return
    get_window().size = CAPTURE_SIZE
    await get_tree().process_frame
    await get_tree().process_frame
    var sets: Dictionary = proof.call("role_candidates")
    var grouped := {"WALL_PRIMARY": [], "FLOOR_PRIMARY": [], "CEILING_PRIMARY": []}
    var fingerprints := _piece_fingerprints(proof)
    for planned in role_capture_records(sample_only):
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
        manifest["candidate_ids"] = _ids(sets[role].slice(0, 1) if sample_only else sets[role])
        manifest["records"] = grouped[role]
        if not _write_json(folder.path_join("manifest.json"), manifest):
            return
    print("EAF5_ROLE_CAPTURE_COMPLETE records=", role_capture_records(sample_only).size(), " sample=", sample_only)
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
