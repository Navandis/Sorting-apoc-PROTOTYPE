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
    _check(shell.size() == 6, "six fixed shell views")
    var roles: Array = capture.call("role_capture_records")
    _check(roles.size() == 132, "four records per 33 current role candidates")
    var keys := {}
    for record in roles:
        keys["%s/%s/%s/%s" % [record["role"], record["catalog_material_id"], record["light_mode"], record["camera"]]] = true
    _check(keys.size() == roles.size(), "capture matrix has no duplicates")
    _check(roles[0]["role"] == "WALL_PRIMARY" and roles[0]["light_mode"] == "NEUTRAL_ARCHITECTURAL", "deterministic first record")
    _finish()

func _check(condition: bool, label: String) -> void:
    if not condition:
        failures.append(label)

func _finish() -> void:
    for failure in failures:
        push_error("EAF5_CAPTURE_FAIL " + failure)
    print("EAF5_CAPTURE_TESTS failures=", failures.size())
    quit(0 if failures.is_empty() else 1)
