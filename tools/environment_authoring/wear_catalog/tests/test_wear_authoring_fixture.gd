extends SceneTree

const FIXTURE = preload("res://environment_authoring/wear/fixtures/wear_authoring_validation.tscn")
const SIGNAGE = preload("res://gameplay/logistics_wing/receiving/receiving_emergency_stop_signage.tscn")
var failures: Array[String] = []

func _initialize() -> void:
    _run.call_deferred()

func _run() -> void:
    var fixture := FIXTURE.instantiate()
    root.add_child(fixture)
    await process_frame
    await process_frame
    var helpers := ["Floor_Instance_A", "Floor_Instance_B", "Wall_Cutout_Original", "Wall_Cutout_Copy", "Wall_PLANAR_ANY", "Legacy_Default_Floor"]
    for path in helpers:
        var helper := fixture.get_node(path)
        _check(helper.get_child_count() == 1, path + " one visual")
        _check(helper.get_node("Quad").visible, path + " live visual initialized")
        _check(helper.get_node("Quad").owner == null, path + " generated visual unsaved")
    var a := fixture.get_node("Floor_Instance_A")
    var b := fixture.get_node("Floor_Instance_B")
    a.opacity_multiplier = 0.2
    await process_frame
    await process_frame
    _check(is_equal_approx(b.opacity_multiplier, 1.0), "separate fixture scene instances isolated")
    _check(a.get_node("Quad").material_override != b.get_node("Quad").material_override, "fixture materials isolated")
    a.width_m = 0.64
    a.roughness_strength = 1.0
    await process_frame
    await process_frame
    var packed := PackedScene.new()
    _check(packed.pack(fixture) == OK, "pack parent of reusable scene instances")
    var saved_path := "user://eaf4_authoring_parent_test.tscn"
    _check(ResourceSaver.save(packed, saved_path) == OK, "save parent instance overrides")
    var reloaded := ResourceLoader.load(saved_path, "PackedScene", ResourceLoader.CACHE_MODE_IGNORE) as PackedScene
    var reopened := reloaded.instantiate()
    root.add_child(reopened)
    await process_frame
    await process_frame
    var reopened_a := reopened.get_node("Floor_Instance_A")
    var reopened_b := reopened.get_node("Floor_Instance_B")
    _check(is_equal_approx(reopened_a.width_m, 0.64) and is_equal_approx(reopened_a.opacity_multiplier, 0.2), "parent-local instance overrides survive save/reopen")
    _check(is_equal_approx(reopened_a.get_node("Quad").material_override.get_shader_parameter("roughness_strength"), 1.0), "parent-local script-default override survives save/reopen")
    _check(is_equal_approx(reopened_b.width_m, 1.0) and is_equal_approx(reopened_b.opacity_multiplier, 1.0), "saved sibling keeps approved defaults")
    for path in helpers:
        _check(reopened.get_node(path).get_child_count() == 1, path + " reopened one visual")
    reopened.free()
    DirAccess.remove_absolute(ProjectSettings.globalize_path(saved_path))
    var signage := SIGNAGE.instantiate()
    root.add_child(signage)
    var label := signage.get_node("LiftEmergencyStopLabel") as MeshInstance3D
    _check(signage.get_child_count() == 1 and label.is_visible_in_tree(), "standalone accepted plaque visible")
    _check(label.global_transform == Transform3D(Vector3(0,0,-1), Vector3(0,1,0), Vector3(1,0,0), Vector3(-35.8485,2.055,-2.1937)), "original plaque world transform")
    _check(label.mesh.size == Vector2(0.32,0.14), "original plaque mesh size")
    _check(label.get_script() == null and signage.get_script() == null, "signage adds no runtime authority")
    fixture.free()
    signage.free()
    for failure in failures:
        push_error("WEAR_FIXTURE_FAIL " + failure)
    print("WEAR_FIXTURE_TEST editor_hint=", Engine.is_editor_hint(), " failures=", failures.size())
    quit(0 if failures.is_empty() else 1)

func _check(condition: bool, label: String) -> void:
    if not condition:
        failures.append(label)
