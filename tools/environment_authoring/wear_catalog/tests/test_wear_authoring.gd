extends SceneTree

const Author = preload("res://environment_authoring/wear/environment_wear_authoring.gd")
const Overlay = preload("res://environment_authoring/wear/environment_wear_overlay.gd")
const ROAD := "Road Dust | eaf4b_7efdf22029c82320d62147c7"
const WALL := "Chipped Paint Patch | eaf4b_16c913a6a9cc1926bcc14833"
const LEAK := "Leakage | eaf4b_e890439d8e117d36ac05e55c"
const SOURCE = preload("res://data/environment/wear_catalog/approved_specs/eaf4b_7efdf22029c82320d62147c7.tres")
var failures: Array[String] = []
var checks := 0

func _initialize() -> void:
    _run.call_deferred()

func _settle() -> void:
    await process_frame
    await process_frame

func _material(node: Node) -> ShaderMaterial:
    return node.get_node("Quad").material_override as ShaderMaterial

func _run() -> void:
    var source_bytes := FileAccess.get_file_as_string(SOURCE.resource_path)
    var options := Author.approved_sources()
    _check(options.size() == 11, "all eleven approved overlays, no mask or deferred patch")
    var planar_count := 0
    for option in options:
        if "PLANAR_ANY" in option["record"]["surface_capabilities"]:
            planar_count += 1
    _check(planar_count == 4, "PLANAR_ANY sources included")
    var node := Author.new()
    node.name = "Authored"
    node.approved_source = ROAD
    root.add_child(node)
    await _settle()
    _check(node.get_mesh_size() == Vector2.ONE, "new source approved physical defaults")
    _check(is_equal_approx(_material(node).get_shader_parameter("albedo_strength"), 0.4), "new source approved appearance defaults")
    _check(SOURCE != node.spec, "effective settings separated from approved resource")
    _check(node.spec.base_color_texture == SOURCE.base_color_texture, "textures remain shared")
    node.width_m = 1.6
    node.height_m = 0.7
    node.opacity_multiplier = 0.23
    node.albedo_strength = 0.12
    node.albedo_tint = Color(0.7, 0.4, 0.2, 0.9)
    node.normal_strength = 0.41
    node.roughness_strength = 0.33
    node.edge_feather = 0.08
    node.surface_offset_m = 0.006
    node.mirror_u = true
    node.mirror_v = true
    node.position = Vector3(2, 1, 3)
    node.rotation_degrees = Vector3(-90, 5, 20)
    node.scale = Vector3(2, 3, 4)
    node.visible = false
    var placement := node.transform
    await _settle()
    _check(node.get_mesh_size().is_equal_approx(Vector2(1.6, 0.7)), "flat width and height update live")
    for pair in [["opacity_multiplier", 0.23], ["albedo_strength", 0.12], ["normal_strength", 0.41], ["roughness_strength", 0.33], ["edge_feather", 0.08]]:
        _check(is_equal_approx(_material(node).get_shader_parameter(pair[0]), pair[1]), "live binding " + pair[0])
    _check(_material(node).get_shader_parameter("albedo_tint").is_equal_approx(Color(0.7, 0.4, 0.2, 0.9)), "tint passes unchanged to existing shader")
    _check(_material(node).get_shader_parameter("mirror_uv") == Vector2.ONE, "both mirrors")
    _check(is_equal_approx(node.get_node("Quad").position.z, 0.006), "local normal offset")
    _check(node.transform.is_equal_approx(placement) and not node.visible, "live edits retain transform and visibility")
    var copy := node.duplicate() as Author
    root.add_child(copy)
    await _settle()
    _check(copy.get_child_count() == 1 and node.get_child_count() == 1, "normal Node duplicate has one quad")
    copy.opacity_multiplier = 0.77
    copy.width_m = 0.4
    copy.mirror_u = false
    await _settle()
    _check(is_equal_approx(node.opacity_multiplier, 0.23) and is_equal_approx(_material(node).get_shader_parameter("opacity_multiplier"), 0.23), "duplicate edit leaves original unchanged")
    _check(is_equal_approx(_material(copy).get_shader_parameter("opacity_multiplier"), 0.77), "duplicate material updated")
    _check(_material(copy) != _material(node) and copy.spec != node.spec, "generated spec and material independent")
    _check(SOURCE.physical_size_m == Vector2.ONE and is_equal_approx(SOURCE.opacity_multiplier, 1.0), "approved defaults unchanged")
    node.approved_source = WALL
    await _settle()
    _check(node.source_id() == "eaf4b_16c913a6a9cc1926bcc14833", "stable ID selected from readable label")
    _check(node.transform.is_equal_approx(placement) and not node.visible and node.get_mesh_size().is_equal_approx(Vector2(1.6, 0.7)), "switch preserves placement dimensions scale visibility")
    _check(_material(node).shader.resource_path.ends_with("wear_overlay_cutout.gdshader"), "switch uses existing cutout shader")
    _check(is_equal_approx(_material(node).get_shader_parameter("opacity_multiplier"), 0.23), "switch retains authored appearance")
    _check(not _editor_visible(node, "edge_feather"), "cutout hides unsupported feather")
    node.use_approved_appearance_defaults = true
    await _settle()
    _check(is_equal_approx(_material(node).get_shader_parameter("opacity_multiplier"), 0.85), "restore selected approved appearance")
    _check(is_equal_approx(_material(node).get_shader_parameter("albedo_strength"), 0.35), "restored approved colour blend")
    _check(node.get_mesh_size().is_equal_approx(Vector2(1.6, 0.7)) and node.transform.is_equal_approx(placement), "restore leaves placement intact")
    node.use_approved_appearance_defaults = false
    await _settle()
    _check(is_equal_approx(_material(node).get_shader_parameter("opacity_multiplier"), 0.23), "authored appearance survives defaults toggle")

    # Exercises the public property setters through UndoRedo. This is not the
    # actual editor's Inspector/duplicate/undo workflow, which needs UI validation.
    var undo := UndoRedo.new()
    undo.create_action("source switch")
    undo.add_do_property(node, "approved_source", ROAD)
    undo.add_undo_property(node, "approved_source", WALL)
    undo.commit_action()
    await _settle()
    undo.undo()
    await _settle()
    _check(node.source_id() == "eaf4b_16c913a6a9cc1926bcc14833" and is_equal_approx(node.opacity_multiplier, 0.23), "programmatic undo source switch retains overrides")
    undo.redo()
    await _settle()
    _check(node.source_id() == "eaf4b_7efdf22029c82320d62147c7" and node.transform.is_equal_approx(placement), "programmatic redo source switch retains placement")
    undo.clear_history()
    undo.create_action("opacity edit")
    undo.add_do_property(node, "opacity_multiplier", 0.49)
    undo.add_undo_property(node, "opacity_multiplier", 0.23)
    undo.commit_action()
    await _settle()
    undo.undo()
    await _settle()
    _check(is_equal_approx(_material(node).get_shader_parameter("opacity_multiplier"), 0.23), "programmatic undo appearance refresh")
    undo.redo()
    await _settle()
    _check(is_equal_approx(_material(node).get_shader_parameter("opacity_multiplier"), 0.49), "programmatic redo appearance refresh")
    undo.clear_history()

    var packed := PackedScene.new()
    _check(packed.pack(node) == OK, "pack authored wrapper")
    var path := "user://eaf4_authoring_test.tscn"
    _check(ResourceSaver.save(packed, path) == OK, "save authored wrapper")
    var saved_text := FileAccess.get_file_as_string(path)
    _check(not saved_text.contains('[node name="Quad"'), "generated quad not saved")
    _check(not saved_text.contains("environment_wear_overlay_spec.gd"), "generated settings not saved")
    var reopened := ResourceLoader.load(path, "PackedScene", ResourceLoader.CACHE_MODE_IGNORE) as PackedScene
    var first := reopened.instantiate() as Author
    var second := reopened.instantiate() as Author
    root.add_child(first)
    root.add_child(second)
    await _settle()
    _check(first.transform.is_equal_approx(placement) and not first.visible, "save/reopen placement and visibility")
    _check(first.get_mesh_size().is_equal_approx(Vector2(1.6, 0.7)) and is_equal_approx(_material(first).get_shader_parameter("opacity_multiplier"), 0.49), "save/reopen authored values and visuals agree")
    first.opacity_multiplier = 0.91
    await _settle()
    _check(is_equal_approx(_material(second).get_shader_parameter("opacity_multiplier"), 0.49), "separate PackedScene instances independent")
    _check(first.get_child_count() == 1 and second.get_child_count() == 1, "reopened scenes have no doubled overlays")

    # Godot omits properties equal to script defaults. Loading a source must not
    # overwrite these deliberate values with that source's approved defaults.
    var wall := Author.new()
    wall.approved_source = WALL
    root.add_child(wall)
    wall.opacity_multiplier = 1.0
    wall.albedo_strength = 0.5
    wall.normal_strength = 1.0
    wall.roughness_strength = 1.0
    await _settle()
    var wall_packed := PackedScene.new()
    _check(wall_packed.pack(wall) == OK, "pack values equal to script defaults")
    var wall_reopened := wall_packed.instantiate() as Author
    root.add_child(wall_reopened)
    await _settle()
    _check(is_equal_approx(_material(wall_reopened).get_shader_parameter("opacity_multiplier"), 1.0), "roundtrip deliberate default-valued opacity")
    _check(is_equal_approx(_material(wall_reopened).get_shader_parameter("albedo_strength"), 0.5), "roundtrip deliberate default-valued source blend")
    _check(is_equal_approx(_material(wall_reopened).get_shader_parameter("normal_strength"), 1.0), "roundtrip deliberate default-valued normal")
    _check(is_equal_approx(_material(wall_reopened).get_shader_parameter("roughness_strength"), 1.0), "roundtrip deliberate default-valued roughness")
    wall.free()
    wall_reopened.free()

    var pre_tree := Author.new()
    pre_tree.approved_source = WALL
    pre_tree.width_m = 0.62
    pre_tree.height_m = 0.31
    pre_tree.opacity_multiplier = 1.0
    root.add_child(pre_tree)
    await _settle()
    _check(pre_tree.get_mesh_size().is_equal_approx(Vector2(0.62, 0.31)), "explicit pre-tree dimensions survive first initialization")
    _check(is_equal_approx(_material(pre_tree).get_shader_parameter("opacity_multiplier"), 1.0), "explicit pre-tree script-default opacity survives initialization")
    _check(is_equal_approx(_material(pre_tree).get_shader_parameter("albedo_strength"), 0.35), "unspecified pre-tree appearance uses approved defaults")
    pre_tree.free()

    node.approved_source = LEAK
    await _settle()
    _check(not _editor_visible(node, "normal_strength") and not _editor_visible(node, "roughness_strength"), "map-less source hides unsupported controls")
    _check(_editor_visible(node, "imperfection_strength"), "approved dependent imperfection remains available")
    node.approved_source = "Deferred | eaf4b_dc44a10776bc702874712334"
    await _settle()
    _check(not node.get_node("Quad").visible and not node._get_configuration_warnings().is_empty(), "deferred source rejected with warning")
    node.approved_source = ROAD
    await _settle()
    node.width_m = 8.1
    await _settle()
    _check(not node.get_node("Quad").visible, "physical upper bound enforced")
    node.width_m = 0.0
    await _settle()
    _check(not node.get_node("Quad").visible, "physical zero rejected")
    node.width_m = 1.6
    node.surface_offset_m = 0.01
    await _settle()
    _check(node.get_node("Quad").visible, "offset upper bound accepted")
    node.surface_offset_m = 0.0101
    await _settle()
    _check(not node.get_node("Quad").visible, "offset above bound rejected")
    node.surface_offset_m = 0.0005
    node.opacity_multiplier = 0.0
    await _settle()
    _check(node.get_node("Quad").visible, "offset lower bound and zero opacity accepted")
    node.approved_source = ""
    await _settle()
    _check(not node.get_node("Quad").visible and _material(node) == null, "cleared source has no stale material")
    node.approved_source = ROAD
    await _settle()
    var stable_material := _material(node)
    for frame in range(5):
        await process_frame
    _check(_material(node) == stable_material, "idle frames do not rebuild")
    _check(FileAccess.get_file_as_string(SOURCE.resource_path) == source_bytes, "approved default file byte-identical")

    # Existing serialized overlay consumers also detach shared editable resources
    # at tree entry, including copies; legacy generated visuals are not saved.
    var legacy := Overlay.new()
    legacy.spec = SOURCE
    root.add_child(legacy)
    var legacy_copy := legacy.duplicate() as Overlay
    root.add_child(legacy_copy)
    legacy_copy.spec.opacity_multiplier = 0.17
    await _settle()
    _check(legacy.spec != legacy_copy.spec and is_equal_approx(legacy.spec.opacity_multiplier, 1.0) and is_equal_approx(SOURCE.opacity_multiplier, 1.0), "legacy duplicate resource independent")
    _check(_material(legacy) != _material(legacy_copy), "legacy generated material independent")
    for item in [node, copy, first, second, legacy, legacy_copy]:
        item.free()
    undo.free()
    DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
    for failure in failures:
        push_error("WEAR_AUTHORING_FAIL " + failure)
    print("WEAR_AUTHORING_TEST checks=", checks, " failures=", failures.size())
    quit(0 if failures.is_empty() else 1)

func _editor_visible(node: Object, field: String) -> bool:
    for property in node.get_property_list():
        if property["name"] == field:
            return (property["usage"] & PROPERTY_USAGE_EDITOR) != 0
    return false

func _check(condition: bool, label: String) -> void:
    checks += 1
    if not condition:
        failures.append(label)
