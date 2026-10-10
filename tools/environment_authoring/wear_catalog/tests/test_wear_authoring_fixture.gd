extends SceneTree

const FIXTURE = preload("res://environment_authoring/wear/fixtures/wear_authoring_validation.tscn")
const FINISH = preload("res://gameplay/logistics_wing/receiving/receiving_finish_pass.tscn")
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
    var finish := FINISH.instantiate()
    var authored_transforms := {}
    for helper in finish.find_children("*", "EnvironmentWearOverlay", true, false):
        authored_transforms[helper.name] = helper.transform
    root.add_child(finish)
    await process_frame
    await process_frame
    var overlays := finish.find_children("*", "EnvironmentWearOverlay", true, false)
    _check(overlays.size() == 7, "existing Receiving seven overlays retained")
    for helper in overlays:
        var quad := helper.get_node("Quad") as MeshInstance3D
        _check(helper.get_child_count() == 1 and quad.visible, helper.name + " legacy initializes once")
        _check(helper.scale.is_equal_approx(Vector3.ONE), helper.name + " existing unit scale unchanged")
        _check(helper.transform == authored_transforms[helper.name], helper.name + " serialized transform retained exactly")
        _check(helper.get_mesh_size().is_equal_approx(helper.spec.physical_size_m), helper.name + " legacy physical size unchanged")
        _check(is_equal_approx(quad.material_override.get_shader_parameter("opacity_multiplier"), helper.spec.opacity_multiplier), helper.name + " legacy opacity retained")
    fixture.free()
    finish.free()
    for failure in failures:
        push_error("WEAR_FIXTURE_FAIL " + failure)
    print("WEAR_FIXTURE_TEST editor_hint=", Engine.is_editor_hint(), " failures=", failures.size())
    quit(0 if failures.is_empty() else 1)

func _check(condition: bool, label: String) -> void:
    if not condition:
        failures.append(label)
