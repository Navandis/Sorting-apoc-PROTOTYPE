extends SceneTree

const Query = preload("res://environment_authoring/wear/environment_wear_catalog_query.gd")
const Author = preload("res://environment_authoring/wear/environment_wear_authoring.gd")
const PRESETS = "res://environment_authoring/wear/presets/"
var failures := 0
var checks := 0

func _initialize() -> void:
    run.call_deferred()

func check(ok: bool, message: String) -> void:
    checks += 1
    if not ok:
        failures += 1
        push_error(message)

func run() -> void:
    var eligible: Dictionary = {}
    for entry in Query.query():
        var surfaces: Array = entry["surface_capabilities"]
        if entry["semantic_category"] != "IMPERFECTION_MASK" and ("FLOOR" in surfaces or "WALL" in surfaces or "PLANAR_ANY" in surfaces):
            eligible[entry["catalog_wear_id"]] = entry
    var paths: PackedStringArray = []
    var dir := DirAccess.open(PRESETS)
    if dir != null:
        for file in dir.get_files():
            if file.ends_with(".tscn"):
                paths.append(PRESETS + file)
    check(paths.size() == eligible.size(), "one preset per eligible source (%d vs %d)" % [paths.size(), eligible.size()])
    var covered: Dictionary = {}
    var host := Node3D.new()
    root.add_child(host)
    var helpers: Array[Node] = []
    var wrapper_bytes: Dictionary = {}
    var default_bytes: Dictionary = {}
    for path in paths:
        wrapper_bytes[path] = FileAccess.get_file_as_bytes(path)
        var scene := load(path) as PackedScene
        check(scene != null, path + " loads")
        if scene == null:
            continue
        var node := scene.instantiate()
        host.add_child(node)
        node.owner = host
        helpers.append(node)
        await process_frame
        await process_frame
        check(node.get_script() == Author, path + " uses flat instance-root controls")
        if not node is EnvironmentWearAuthoring:
            continue
        var id: String = node.source_id()
        check(eligible.has(id) and not covered.has(id), path + " unique current mapping")
        if not eligible.has(id):
            continue
        covered[id] = true
        var entry: Dictionary = eligible[id]
        var default_path := "res://data/environment/wear_catalog/approved_specs/%s.tres" % id
        default_bytes[default_path] = FileAccess.get_file_as_bytes(default_path)
        var defaults := load(default_path) as EnvironmentWearOverlaySpec
        check(node.spec != null and node.spec.validate().is_empty(), path + " valid dependency/spec")
        check(node.spec.source_fingerprint == entry["reviewed_source_fingerprint"], path + " approved fingerprint")
        check(node.get_child_count() == 1 and node.get_node("Quad").visible, path + " one visible generated visual")
        check(node.get_node("Quad").owner == null, path + " unsaved geometry")
        check(node.spec.physical_size_m == defaults.physical_size_m, path + " useful approved dimensions")
        check(node.get("approved_usage_notes") == entry["review_notes"], path + " source restrictions visible")
        var surfaces: Array = entry["surface_capabilities"]
        var floor_only := "FLOOR" in surfaces and not ("WALL" in surfaces or "PLANAR_ANY" in surfaces)
        check(node.basis.z.is_equal_approx(Vector3.UP if floor_only else Vector3.BACK), path + " sensible orientation")
        var copy := node.duplicate()
        copy.name = str(node.name) + "Copy"
        host.add_child(copy)
        copy.owner = host
        helpers.append(copy)
        copy.width_m = 0.63
        copy.opacity_multiplier = 0.27
        await process_frame
        await process_frame
        check(copy.get_child_count() == 1, path + " ordinary duplicate one visual")
        check(node.width_m == defaults.physical_size_m.x and node.opacity_multiplier == defaults.opacity_multiplier, path + " sibling/settings independent")
        check(copy.get_node("Quad").material_override != node.get_node("Quad").material_override, path + " independent material")
        copy.approved_source = "Road Dust | eaf4b_7efdf22029c82320d62147c7"
        await process_frame
        await process_frame
        check(is_equal_approx(copy.width_m, 0.63) and is_equal_approx(copy.opacity_multiplier, 0.27), path + " source switch preserves authored settings")
    check(covered.size() == eligible.size(), "complete eligible library coverage")
    var packed := PackedScene.new()
    check(packed.pack(host) == OK, "pack preset instances and overrides")
    var saved := "user://eaf4_presets_roundtrip.tscn"
    check(ResourceSaver.save(packed, saved) == OK, "save preset parent")
    var reopened := (ResourceLoader.load(saved, "PackedScene", ResourceLoader.CACHE_MODE_IGNORE) as PackedScene).instantiate()
    root.add_child(reopened)
    await process_frame
    await process_frame
    for helper in helpers:
        var again := reopened.get_node(NodePath(str(helper.name)))
        check(again.get_child_count() == 1, str(helper.name) + " reopen/runtime one visual")
        check(again.width_m == helper.width_m and again.opacity_multiplier == helper.opacity_multiplier and again.source_id() == helper.source_id(), str(helper.name) + " saved overrides retained")
    for path in wrapper_bytes:
        check(FileAccess.get_file_as_bytes(path) == wrapper_bytes[path], path + " wrapper unchanged")
    for path in default_bytes:
        check(FileAccess.get_file_as_bytes(path) == default_bytes[path], path + " approved defaults unchanged")
    reopened.free()
    host.free()
    DirAccess.remove_absolute(ProjectSettings.globalize_path(saved))
    print("test_wear_presets: %d checks, %d eligible, %d covered, %d failures" % [checks, eligible.size(), covered.size(), failures])
    quit(0 if failures == 0 else 1)
