extends SceneTree
const PATH = "res://environment_authoring/wear/imperfection_experiments/imperfection_audition.gd"
var failures := 0
var checks := 0
func _initialize() -> void: run.call_deferred()
func check(ok: bool, message: String) -> void:
    checks += 1
    if not ok:
        failures += 1
        push_error(message)
func settle() -> void:
    await process_frame
    await process_frame
func run() -> void:
    check(ResourceLoader.exists(PATH), "experimental component exists")
    if not ResourceLoader.exists(PATH):
        quit(1)
        return
    var script = load(PATH)
    var sources = script.candidates()
    check(sources.size() == 16, "all audited source choices")
    var parent := Node3D.new()
    root.add_child(parent)
    var materials := []
    for source in sources:
        var node = load("res://environment_authoring/wear/imperfection_experiments/presets/" + source.slug + ".tscn").instantiate()
        parent.add_child(node)
        await settle()
        check(node.source_id() == source.stable_id, "wrapper uses exact stable ID")
        check(node._get_configuration_warnings().is_empty(), "genuine source valid")
        check(node.experiment_notes.contains("Catalog source status: APPROVED") and node.experiment_notes.contains("Placement acceptance is separate") and node.experiment_notes.contains(source.channel) and node.experiment_notes.contains("TINTED_OPACITY_LAYER") and node.experiment_notes.contains("WEAR_OPACITY_MODULATION"), "honest Inspector channel, source approval and placement scope")
        var quad = node.get_node("Quad")
        check(node.get_child_count() == 1 and quad.owner == null and quad.mesh is QuadMesh, "one unsaved visual")
        var material = quad.material_override
        check(material.get_shader_parameter("imperfection_texture").resource_path == source.texture_path, "exact scalar binding, no fallback")
        check(material not in materials, "per instance material")
        materials.append(material)
        var initial_mesh = quad.mesh
        for i in 5: await process_frame
        check(quad.mesh == initial_mesh, "no per frame regeneration")
        node.free()
    var node = script.new()
    node.mask_source = sources[0].stable_id
    parent.add_child(node)
    await settle()
    var original = node.get_node("Quad").material_override
    var copy = node.duplicate()
    parent.add_child(copy)
    await settle()
    copy.width_m = 1.8
    copy.height_m = 0.9
    copy.surface_offset_m = 0.004
    copy.mask_repeat = Vector2(2, 3)
    copy.mask_rotation_degrees = 37
    copy.scalar_contrast = 2
    copy.scalar_bias = 0.1
    copy.invert_scalar = true
    copy.mask_strength = 0.7
    copy.opacity_multiplier = 0.6
    copy.albedo_tint = Color(0.2, 0.3, 0.4)
    copy.albedo_strength = 0.25
    copy.rotation_degrees = Vector3(-90, 0, 0)
    copy.scale = Vector3(1.2, 1.3, 1.1)
    await settle()
    var quad = copy.get_node("Quad")
    check(quad.mesh.size == Vector2(1.8, 0.9) and is_equal_approx(quad.position.z, 0.004), "live dimensions and offset")
    check(quad.material_override != original and node.width_m == 1.0 and not node.invert_scalar, "duplicate independence")
    var values = {"imperfection_scale":Vector2(2,3), "imperfection_contrast":2.0, "scalar_bias":0.1, "invert_scalar":true, "imperfection_strength":0.7, "opacity_multiplier":0.6, "albedo_strength":0.25, "albedo_tint":Color(0.2,0.3,0.4)}
    for key in values: check(quad.material_override.get_shader_parameter(key) == values[key], "live uniform " + key)
    check(is_equal_approx(quad.material_override.get_shader_parameter("imperfection_rotation"), deg_to_rad(37)), "rotation radians")
    var saved_transform: Transform3D = copy.transform
    copy.mask_source = sources[5].stable_id
    await settle()
    check(copy.transform == saved_transform and copy.width_m == 1.8 and copy.invert_scalar, "source switch retains settings/transform")
    var undo := UndoRedo.new()
    undo.create_action("scalar contrast")
    undo.add_do_property(copy, "scalar_contrast", 3.0)
    undo.add_undo_property(copy, "scalar_contrast", 2.0)
    undo.commit_action()
    await settle()
    check(quad.material_override.get_shader_parameter("imperfection_contrast") == 3.0, "undo commit refresh")
    undo.undo()
    await settle()
    check(quad.material_override.get_shader_parameter("imperfection_contrast") == 2.0, "undo refresh")
    undo.redo()
    await settle()
    check(quad.material_override.get_shader_parameter("imperfection_contrast") == 3.0, "redo refresh")
    for mode in 3:
        copy.preview_mode = mode
        await settle()
        check(quad.material_override.get_shader_parameter("preview_mode") == mode, "mode selector bound")
    for effect in script.effect_sources():
        copy.wear_source = effect.id
        await settle()
        check(copy.effective_spec != null and copy.effective_spec.overlay_id == effect.id, "explicit limited approved wear")
        var defaults = load(effect.path)
        check(copy.effective_spec != defaults and copy.effective_spec.opacity_multiplier == 0.6, "effective spec clone with authored controls")
        check(copy.effective_spec.base_color_texture == defaults.base_color_texture, "approved texture references reused")
        check(copy.effective_spec.imperfection_mask_texture.resource_path == sources[5].texture_path, "effective spec records actual candidate, not default Grunge")
        var default_size: Vector2 = defaults.physical_size_m
        copy.effective_spec.physical_size_m = Vector2(7,7)
        check(defaults.physical_size_m == default_size, "approved defaults independent")
    copy.modulation_enabled = false
    await settle()
    check(not quad.material_override.get_shader_parameter("has_imperfection"), "unmasked comparison toggle")
    copy.modulation_enabled = true
    await settle()
    check(quad.material_override.get_shader_parameter("has_imperfection"), "genuine modulation enabled")
    parent.hide()
    check(not quad.is_visible_in_tree(), "group visibility")
    parent.show()
    check(quad.is_visible_in_tree(), "group restore")
    # Owned experimental cache only: remove/alter the exact source, then restore bytes.
    var texture_path: String = sources[5].texture_path
    var backup_path := texture_path + ".test-backup"
    check(DirAccess.rename_absolute(texture_path, backup_path) == OK, "temporarily remove experimental dependency")
    copy.request_refresh()
    await settle()
    check(not quad.visible and not copy._get_configuration_warnings().is_empty(), "missing real dependency hides even when texture resource was cached")
    check(DirAccess.rename_absolute(backup_path, texture_path) == OK, "restore exact experimental dependency")
    var bytes := FileAccess.get_file_as_bytes(texture_path)
    var file := FileAccess.open(texture_path, FileAccess.WRITE)
    file.store_buffer(bytes)
    file.store_8(0)
    file.close()
    copy.request_refresh()
    await settle()
    check(not quad.visible and not copy._get_configuration_warnings().is_empty(), "changed cache fingerprint hides")
    file = FileAccess.open(texture_path, FileAccess.WRITE)
    file.store_buffer(bytes)
    file.close()
    copy.request_refresh()
    await settle()
    check(quad.visible, "exact source restored")
    copy.mask_source = "unknown"
    await settle()
    check(not quad.visible and quad.material_override == null and not copy._get_configuration_warnings().is_empty(), "missing candidate warns and hides without substitution")
    copy.mask_source = sources[5].stable_id
    copy.width_m = 0
    await settle()
    check(not quad.visible, "invalid dimensions hide")
    copy.width_m = 1.8
    copy.scale.x = -1
    await settle()
    check(not copy._get_configuration_warnings().is_empty(), "negative scale warns")
    copy.scale = Vector3(1.2,1.3,1.1)
    await settle()
    # Genuine parent-scene packing and disk reload, as editor duplication saves root overrides.
    parent.name = "AuthoredFixture"
    node.owner = parent
    copy.owner = parent
    var packed := PackedScene.new()
    check(packed.pack(parent) == OK, "pack authored parent")
    var disk = "user://imperfection_audition_roundtrip.tscn"
    check(ResourceSaver.save(packed, disk) == OK, "save parent scene")
    var reopened = load(disk).instantiate()
    root.add_child(reopened)
    await settle()
    var restored = reopened.get_children()[1]
    check(restored.transform == copy.transform and restored.width_m == 1.8 and restored.scalar_contrast == 3.0 and restored.invert_scalar, "disk reopen authored settings")
    check(restored.get_child_count() == 1 and restored.get_node("Quad").owner == null, "reopen regenerates only one visual")
    check(restored.effective_spec != copy.effective_spec, "reopen spec isolation")
    reopened.free()
    undo.clear_history()
    undo.free()
    parent.free()
    print("IMPERFECTION_AUDITION checks=", checks, " failures=", failures)
    quit(1 if failures else 0)
