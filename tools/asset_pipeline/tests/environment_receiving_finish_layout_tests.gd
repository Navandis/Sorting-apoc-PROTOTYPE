extends SceneTree

const PROOF_SCENE := preload("res://gameplay/dev/environment_receiving_proof/environment_receiving_proof.tscn")
const CAPTURE_SCENE := preload("res://gameplay/dev/environment_receiving_proof/environment_receiving_proof_capture.tscn")
const WALL := "eaf3b_d335d94fd85c2c95c26b6b8b"
const FLOOR := "eaf3b_bb32071987faae156ff2d4e8"
const CEILING := "eaf3b_6bcd8f817ca2993433e217cc"
const FINISH := "eaf3b_7b12b8b3a2e05c502801d22f"
const AFT := "eaf3b_8d5f0cf5add98dfe0a58f18a"
var failures: Array[String] = []

func _initialize() -> void:
    _run.call_deferred()

func _run() -> void:
    var proof := PROOF_SCENE.instantiate()
    root.add_child(proof)
    await process_frame
    _check(proof.has_method("set_finish_layout"), "proof has bounded finish composition")
    if not proof.has_method("set_finish_layout"):
        _finish()
        return
    var baseline := {}
    for piece in proof.get_node("Shell").get_children():
        baseline[piece.name] = piece.generation_metadata["geometry_fingerprint"]
    _check(proof.call("set_finish_layout", WALL, FLOOR, CEILING, "", "L00"), "L00 control applies")
    _check(proof.get_node("FinishPatches").get_child_count() == 0, "control has no patch")
    var structural_materials := {}
    for piece in proof.get_node("Shell").get_children():
        structural_materials[piece.name] = (piece.get_node("GeneratedMesh") as MeshInstance3D).material_override.resource_name
    var substrate := (proof.get_node("Shell/ReceivingSouth/GeneratedMesh") as MeshInstance3D).material_override
    _check(proof.call("set_finish_layout", WALL, FLOOR, CEILING, FINISH, "L01"), "L01 finish applies")
    var patch := proof.get_node("FinishPatches").get_child(0) as EnvironmentMaterialPatch
    _check(patch != null and patch.mode == EnvironmentMaterialPatch.Mode.EAF3_MATERIAL, "uses EAF3 owner patch")
    _check(patch.scale == Vector3.ONE and patch.physical_size_m.is_equal_approx(Vector2(4.2, 2.4)), "L01 size and scale")
    _check(patch.position.is_equal_approx(Vector3(5.1, 2.1, 4.85)), "L01 wall face placement")
    _check(patch.global_transform.basis.z.normalized().is_equal_approx(Vector3(0, 0, -1)), "faces occupied room")
    _check((proof.get_node("Shell/ReceivingSouth/GeneratedMesh") as MeshInstance3D).material_override.resource_name == substrate.resource_name, "structural material preserved")
    _check(proof.call("set_finish_layout", WALL, FLOOR, CEILING, FINISH, "L02"), "L02 finish applies")
    patch = proof.get_node("FinishPatches").get_child(0) as EnvironmentMaterialPatch
    _check(patch.physical_size_m.is_equal_approx(Vector2(1.8, 1.2)), "L02 size")
    _check(patch.position.is_equal_approx(Vector3(3.1, 1.55, 4.85)), "L02 wall face placement")
    _check(proof.call("set_finish_layout", WALL, FLOOR, CEILING, AFT, "L02"), "AFT localized UV applies")
    patch = proof.get_node("FinishPatches").get_child(0) as EnvironmentMaterialPatch
    var review_material := (patch.get_node("PatchQuad") as MeshInstance3D).material_override as StandardMaterial3D
    _check(not review_material.uv1_triplanar, "AFT patch uses transient UV")
    var approved := load("res://data/environment/material_catalog/approved_specs/" + AFT + ".tres") as EnvironmentSurfaceMaterialSpec
    _check(approved.mapping_name() == "TRIPLANAR", "AFT approval unchanged")
    _check(proof.get_node("FinishPatches").get_child_count() == 1, "only one patch exists")
    for piece in proof.get_node("Shell").get_children():
        _check(piece.generation_metadata["geometry_fingerprint"] == baseline[piece.name], "geometry unchanged " + piece.name)
        _check((piece.get_node("GeneratedMesh") as MeshInstance3D).material_override.resource_name == structural_materials[piece.name], "structural material unchanged " + piece.name)
    var capture := CAPTURE_SCENE.instantiate()
    root.add_child(capture)
    await process_frame
    _check(capture.has_method("layout_capture_records"), "capture has layout matrix")
    if capture.has_method("layout_capture_records"):
        var records: Array = capture.call("layout_capture_records")
        var sanity: Array = capture.call("layout_capture_records", true)
        _check(records.size() == 52 and sanity.size() == 20, "52 final and 20 sanity captures")
        var expected := ["S01_L00", "S05_L00", "S06_L00", "V01_L01", "V01_L02", "V02_L01", "V02_L02", "V03_L01", "V03_L02", "V04_L01", "V04_L02", "Q01_L02", "Q02_L02"]
        var seen := {}
        for record in records:
            seen[record["configuration_id"]] = true
        _check(seen.keys().size() == 13, "13 configurations")
        for cid in expected:
            _check(seen.has(cid), "expected " + cid)
        _check(capture.call("validate_layout_source"), "human decisions and approved specs authorize layouts")
    _finish()

func _check(condition: bool, label: String) -> void:
    if not condition:
        failures.append(label)

func _finish() -> void:
    for failure in failures:
        push_error("EAF5_LAYOUT_FAIL " + failure)
    print("EAF5_LAYOUT_TEST failures=", failures.size())
    quit(0 if failures.is_empty() else 1)
