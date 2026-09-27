extends SceneTree

const REVIEW_SCENE = preload("res://gameplay/dev/environment_wear/environment_wear_review.tscn")

func _initialize() -> void:
    _run.call_deferred()

func _run() -> void:
    var review := REVIEW_SCENE.instantiate() as Node3D
    get_root().add_child(review)
    await process_frame
    var lookdev := review.get_node("Lookdev")
    var wall := lookdev.get_node("ReviewGeometry/Wall_A") as MeshInstance3D
    var floor := lookdev.get_node("ReviewGeometry/Floor") as MeshInstance3D
    var key := lookdev.get_node("NeutralLightingRig/WhiteKey") as Light3D
    var key_transform := key.transform
    var original := wall.material_override
    review.call("set_candidate", 4)
    review.call("set_diagnostic_base")
    var diagnostic := wall.material_override as StandardMaterial3D
    assert(diagnostic != null)
    assert(diagnostic.albedo_texture == null)
    assert(diagnostic.normal_texture == null)
    assert(diagnostic.roughness >= 0.70 and diagnostic.roughness <= 0.80)
    assert(diagnostic == floor.material_override)
    assert(diagnostic != original)
    assert(key.transform == key_transform)
    assert(lookdev.get_node("NeutralLightingRig").visible)
    review.call("set_base", 0)
    assert(wall.material_override != diagnostic)
    review.call("set_candidate", 7)
    review.call("set_diagnostic_base")
    var floor_overlay := review.get_node("WearOverlay") as Node3D
    var block := lookdev.get_node("ReviewGeometry/BeveledBlock") as MeshInstance3D
    var overlay_width: float = floor_overlay.call("get_mesh_size").x
    assert(floor_overlay.position.x + overlay_width * 0.5 < block.position.x - 0.475)
    assert((floor.material_override as StandardMaterial3D).albedo_texture == null)
    assert(review.call("get_review_context") == "WEAR_DIAGNOSTIC_FLOOR")
    review.free()
    print("EAF4B_RERUN_GODOT_TEST_PASS")
    quit(0)
