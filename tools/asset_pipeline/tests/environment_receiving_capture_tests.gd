extends SceneTree
const SCENE := "res://gameplay/dev/environment_receiving_proof/environment_receiving_proof_capture.tscn"
var failures: Array[String] = []

func _initialize() -> void:
    _run.call_deferred()

func _run() -> void:
    var packed := load(SCENE) as PackedScene
    _check(packed != null, "capture scene loads")
    if packed == null:
        _finish()
        return
    var capture := packed.instantiate() as Node3D
    root.add_child(capture)
    await process_frame
    var shell: Array = capture.call("shell_capture_records")
    _check(shell.size() == 8, "six principal and two join shell views")
    var roles: Array = capture.call("role_capture_records")
    _check(roles.size() == 132, "four records per 33 current role candidates")
    var keys := {}
    for record in roles:
        keys["%s/%s/%s/%s" % [record["role"], record["catalog_material_id"], record["light_mode"], record["camera"]]] = true
    _check(keys.size() == roles.size(), "capture matrix has no duplicates")
    _check(roles[0]["role"] == "WALL_PRIMARY" and roles[0]["light_mode"] == "NEUTRAL_ARCHITECTURAL", "deterministic first record")
    var sample: Array = capture.call("role_capture_records", true)
    _check(sample.size() == 12, "one candidate per role uses four fixed views")
    _check(capture.call("role_capture_directory", true).ends_with("/role_isolation_02/sanity"), "sanity capture has v2 folder")
    _check(capture.call("role_capture_directory", false).ends_with("/role_isolation_02"), "full capture has v2 folder")
    _check(capture.call("validate_role_candidates"), "live approved role IDs match v1 evidence")
    var catalog_record: Dictionary = capture.get_node("Proof").call("role_candidates")["WALL_PRIMARY"][0]
    var approved_spec := load("res://data/environment/material_catalog/approved_specs/" + String(catalog_record["catalog_material_id"]) + ".tres") as EnvironmentSurfaceMaterialSpec
    _check(capture.call("catalog_spec_matches", catalog_record, approved_spec), "approved spec matches current catalog parameters")
    var altered_spec := approved_spec.duplicate(false) as EnvironmentSurfaceMaterialSpec
    altered_spec.meters_per_repeat += 0.5
    _check(not capture.call("catalog_spec_matches", catalog_record, altered_spec), "parameter drift fails role preflight")
    _check(capture.call("validate_accepted_shell"), "current shell matches accepted v2 manifest")
    _check(not capture.call("validate_accepted_shell", "res://reports/environment_receiving_proof/eaf5/eaf5_shell_review_01.zip"), "rejected v1 ZIP cannot authorize role capture")
    _finish()

func _check(condition: bool, label: String) -> void:
    if not condition:
        failures.append(label)

func _finish() -> void:
    for failure in failures:
        push_error("EAF5_CAPTURE_FAIL " + failure)
    print("EAF5_CAPTURE_TESTS failures=", failures.size())
    quit(0 if failures.is_empty() else 1)
