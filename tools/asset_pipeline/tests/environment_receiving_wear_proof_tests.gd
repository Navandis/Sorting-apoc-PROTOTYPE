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
    _check(proof.has_method("set_wear_proof"), "wear proof API exists")
    if proof.has_method("set_wear_proof"):
        _check(proof.call("set_wear_proof", "P01_C02", false), "primary OFF applies")
        _check(proof.get_node("WearOverlays").get_child_count() == 4, "four overlays loaded")
        _check(proof.call("visible_wear_count") == 0, "OFF hides all overlays")
        var causes: Array = proof.call("cause_proxy_inventory")
        _check(causes.size() == 2, "pipe and plate stay visible")
        _check(proof.call("set_wear_proof", "P01_C02", true), "primary ON applies")
        _check(proof.call("visible_wear_count") == 4, "ON shows four overlays")
        _check(proof.call("cause_proxy_inventory") == causes, "causes unchanged OFF/ON")
        _check(proof.call("set_wear_proof", "P05_C03", true), "alternate ON applies")
        _check(proof.call("visible_wear_count") == 4, "alternate shows same four")
        _check(proof.call("cause_proxy_inventory") == causes, "causes unchanged between palettes")
    var capture := CAPTURE_SCENE.instantiate()
    root.add_child(capture)
    await process_frame
    _check(capture.has_method("wear_capture_records"), "wear matrix API exists")
    if capture.has_method("wear_capture_records"):
        _check(capture.call("wear_capture_records").size() == 24, "full matrix has 24 views")
        _check(capture.call("wear_capture_records", true).size() == 6, "sanity matrix has six views")
        _check(capture.call("validate_wear_source"), "wear preflight passes")
    for failure in failures:
        push_error("EAF5_WEAR_FAIL " + failure)
    print("EAF5_WEAR_TEST failures=", failures.size())
    quit(0 if failures.is_empty() else 1)

func _check(condition: bool, label: String) -> void:
    if not condition:
        failures.append(label)
