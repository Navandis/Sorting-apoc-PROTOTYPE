extends SceneTree

const PROOF_SCENE := preload("res://gameplay/dev/environment_receiving_proof/environment_receiving_proof.tscn")
const CAPTURE_SCENE := preload("res://gameplay/dev/environment_receiving_proof/environment_receiving_proof_capture.tscn")
var failures: Array[String] = []

func _initialize() -> void:
    _run.call_deferred()

func _run() -> void:
    var proof := PROOF_SCENE.instantiate()
    root.add_child(proof)
    await process_frame
    _check(proof.call("set_wear_calibration", "P01_C02", "WEAR_OFF", -1), "primary OFF")
    var causes: Array = proof.call("cause_proxy_inventory")
    _check(proof.call("wear_instance_inventory").size() == 3, "three active sources")
    _check(not proof.has_node("WearOverlays/WEA02"), "crack absent")
    for item in [["WEA01", [1.0, .45], [.65, .45], [.65, .30]], ["WEA03", [1.0, .40], [.65, .40], [.65, .25]], ["WEA04", [1.0, .75], [.60, .75], [.60, .40]]]:
        for variant in 3:
            _check(proof.call("set_wear_calibration", "P01_C02", item[0], variant), "variant applies")
            _check(proof.call("visible_wear_count") == 1, "one source visible")
            var overlay := proof.get_node("WearOverlays/" + item[0]) as EnvironmentWearOverlay
            var approved := load("res://data/environment/wear_catalog/approved_specs/" + overlay.spec.overlay_id + ".tres") as EnvironmentWearOverlaySpec
            _check(overlay.spec != approved, "instance spec is duplicated")
            for field in ["overlay_id", "display_name", "source_stable_id", "source_fingerprint", "semantic_category", "cause_tags", "surface_capabilities", "render_mode", "physical_size_m", "surface_offset_m", "base_color_texture", "opacity_texture", "normal_texture", "roughness_texture", "metallic_texture", "embedded_alpha", "atlas_region", "albedo_tint", "normal_strength", "normal_y_flip", "roughness_strength", "edge_feather", "imperfection_mask_texture", "imperfection_scale", "imperfection_rotation", "imperfection_contrast", "imperfection_strength", "review_notes"]:
                _check(overlay.spec.get(field) == approved.get(field), "approved field unchanged: " + field)
            _check(is_equal_approx(overlay.spec.opacity_multiplier, item[variant + 1][0]), "opacity")
            _check(is_equal_approx(overlay.spec.albedo_strength, item[variant + 1][1]), "albedo")
    _check(proof.call("set_wear_calibration", "P05_C03", "WEA04", 2), "alternate transfer")
    _check(proof.call("cause_proxy_inventory") == causes, "cause proxies unchanged")
    var capture := CAPTURE_SCENE.instantiate()
    root.add_child(capture)
    await process_frame
    var records: Array = capture.call("wear_calibration_records")
    _check(records.size() == 32, "32 captures")
    var primary := 0
    var alternate := 0
    for record in records:
        if record["selection_role"] == "PRIMARY":
            primary += 1
        else:
            alternate += 1
            _check(record["wear_state"] in ["WEAR_OFF", "L2", "D2", "R2"], "alternate reduced only")
    _check(primary == 22 and alternate == 10, "22/10 matrix")
    for failure in failures:
        push_error("EAF5_WEAR_CALIBRATION_FAIL " + failure)
    print("EAF5_WEAR_CALIBRATION_TEST failures=", failures.size())
    quit(0 if failures.is_empty() else 1)

func _check(condition: bool, label: String) -> void:
    if not condition:
        failures.append(label)