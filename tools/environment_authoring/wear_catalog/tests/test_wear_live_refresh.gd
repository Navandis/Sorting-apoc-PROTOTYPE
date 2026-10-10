extends SceneTree

const Overlay = preload("res://environment_authoring/wear/environment_wear_overlay.gd")
const Patch = preload("res://environment_authoring/wear/environment_material_patch.gd")
const SOURCE = preload("res://data/environment/wear_catalog/approved_specs/eaf4b_7efdf22029c82320d62147c7.tres")
var failures: Array[String] = []

func _initialize() -> void:
    _run.call_deferred()

func _run() -> void:
    var overlay := Overlay.new()
    overlay.spec = SOURCE.duplicate(false)
    root.add_child(overlay)
    overlay.position = Vector3(2, 3, 4)
    overlay.rotation_degrees = Vector3(-90, 15, 30)
    overlay.scale = Vector3(2, 3, 4)
    var placement := overlay.transform
    overlay.spec.opacity_multiplier = 0.23
    overlay.spec.physical_size_m = Vector2(1.7, 0.4)
    await process_frame
    await process_frame
    _check(overlay.get_mesh_size().is_equal_approx(Vector2(1.7, 0.4)), "nested size updates without regenerate")
    _check(is_equal_approx(overlay.get_node("Quad").material_override.get_shader_parameter("opacity_multiplier"), 0.23), "nested opacity updates without regenerate")
    overlay.mirror_u = true
    await process_frame
    _check(overlay.transform.is_equal_approx(placement), "appearance refresh preserves transform and positive scale")
    var old := overlay.spec
    overlay.spec = SOURCE.duplicate(false)
    await process_frame
    var material: Material = overlay.get_node("Quad").material_override
    old.opacity_multiplier = 0.71
    await process_frame
    _check(overlay.get_node("Quad").material_override == material, "replaced resource disconnected")
    overlay.spec.surface_offset_m = 0.1
    await process_frame
    _check(not overlay.get_node("Quad").visible, "invalid nested input hides visual")
    overlay.spec = null
    await process_frame
    _check(not overlay.get_node("Quad").visible, "missing input hides visual")
    _check(overlay.get_child_count() == 1, "one generated visual")
    var patch := Patch.new()
    patch.mode = Patch.Mode.EAF4_SOURCE
    patch.wear_spec = SOURCE.duplicate(false)
    root.add_child(patch)
    patch.wear_spec.physical_size_m = Vector2(0.6, 0.8)
    patch.scale = Vector3(2, 2, 2)
    await process_frame
    await process_frame
    _check(patch.get_node("PatchQuad").mesh.size.is_equal_approx(Vector2(0.6, 0.8)), "EAF4 material patch nested refresh")
    _check(patch.scale.is_equal_approx(Vector3(2, 2, 2)), "material patch preserves scale")
    patch.free()
    overlay.free()
    for failure in failures:
        push_error("WEAR_LIVE_FAIL " + failure)
    print("WEAR_LIVE_TEST failures=", failures.size())
    quit(0 if failures.is_empty() else 1)

func _check(condition: bool, label: String) -> void:
    if not condition:
        failures.append(label)
