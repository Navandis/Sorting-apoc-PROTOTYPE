extends SceneTree

const Spec = preload("res://environment_authoring/wear/environment_wear_overlay_spec.gd")
const Overlay = preload("res://environment_authoring/wear/environment_wear_overlay.gd")
const Patch = preload("res://environment_authoring/wear/environment_material_patch.gd")
const Query = preload("res://environment_authoring/wear/environment_wear_catalog_query.gd")

func _initialize() -> void:
    var spec = Spec.new()
    spec.overlay_id = "test"
    spec.source_stable_id = "eaf4:test"
    spec.source_fingerprint = "a".repeat(64)
    spec.physical_size_m = Vector2(0.7, 0.3)
    spec.surface_offset_m = 0.002
    var texture := ImageTexture.create_from_image(Image.create_empty(4, 4, false, Image.FORMAT_RGBA8))
    spec.opacity_texture = texture
    spec.base_color_texture = texture
    spec.normal_texture = texture
    spec.roughness_texture = texture
    spec.imperfection_mask_texture = texture
    spec.normal_strength = 0.7
    spec.normal_y_flip = true
    spec.albedo_strength = 0.2
    spec.imperfection_strength = 0.4
    assert(spec.validate().is_empty(), str(spec.validate()))
    var overlay = Overlay.new()
    get_root().add_child(overlay)
    overlay.spec = spec
    overlay.regenerate()
    assert(overlay.scale == Vector3.ONE)
    assert(overlay.get_child_count() == 1)
    assert(overlay.get_mesh_size().is_equal_approx(Vector2(0.7, 0.3)))
    assert(is_equal_approx(overlay.get_node("Quad").position.z, 0.002))
    var cutout := (overlay.get_node("Quad") as MeshInstance3D).material_override as ShaderMaterial
    assert(cutout.shader.resource_path.ends_with("wear_overlay_cutout.gdshader"))
    assert(cutout.get_shader_parameter("has_opacity"))
    assert(cutout.get_shader_parameter("has_normal"))
    assert(cutout.get_shader_parameter("has_roughness"))
    assert(cutout.get_shader_parameter("has_imperfection"))
    assert(is_equal_approx(cutout.get_shader_parameter("albedo_strength"), 0.2))
    assert(is_equal_approx(cutout.get_shader_parameter("normal_strength"), 0.7))
    assert(cutout.get_shader_parameter("normal_y_flip"))
    overlay.mirror_u = true
    overlay.rotation_degrees.z = 30.0
    overlay.regenerate()
    assert(overlay.get_child_count() == 1)
    assert(overlay.get_mesh_size().is_equal_approx(Vector2(0.7, 0.3)))
    assert((overlay.get_node("Quad") as MeshInstance3D).material_override.get_shader_parameter("mirror_uv") == Vector2(1.0, 0.0))
    assert(is_equal_approx(overlay.rotation_degrees.z, 30.0))
    spec.render_mode = Spec.RenderMode.SOFT_BLEND
    overlay.regenerate()
    var soft := (overlay.get_node("Quad") as MeshInstance3D).material_override as ShaderMaterial
    assert(soft.shader.resource_path.ends_with("wear_overlay_soft.gdshader"))
    assert(is_equal_approx(soft.get_shader_parameter("edge_feather"), 0.035))
    overlay.imperfection_enabled = false
    overlay.regenerate()
    assert(not (overlay.get_node("Quad") as MeshInstance3D).material_override.get_shader_parameter("has_imperfection"))
    spec.surface_offset_m = 0.1
    assert(not spec.validate().is_empty())
    spec.surface_offset_m = 0.002
    spec.opacity_texture = null
    spec.embedded_alpha = false
    assert(not spec.validate().is_empty())
    spec.embedded_alpha = true
    assert(spec.validate().is_empty())
    assert(Overlay.build_material(spec).get_shader_parameter("embedded_alpha"))
    spec.physical_size_m = Vector2.ZERO
    assert(not spec.validate().is_empty())
    spec.physical_size_m = Vector2(0.7, 0.3)
    spec.atlas_region = Vector4(0.8, 0.0, 0.5, 1.0)
    assert(not spec.validate().is_empty())
    spec.atlas_region = Vector4(0.0, 0.0, 1.0, 1.0)
    spec.imperfection_scale = Vector2.ZERO
    assert(not spec.validate().is_empty())
    spec.imperfection_scale = Vector2.ONE

    var patch = Patch.new()
    patch.mode = Patch.Mode.EAF3_MATERIAL
    patch.eaf3_material_id = "missing"
    assert(patch.resolve_material() == null)
    patch.eaf3_material_id = "eaf3b_8d5f0cf5add98dfe0a58f18a"
    assert(patch.resolve_material() != null)
    get_root().add_child(patch)
    patch.regenerate()
    assert(patch.scale == Vector3.ONE)
    var patch_bounds := (patch.get_node("PatchQuad") as MeshInstance3D).mesh.get_aabb().size
    assert(Vector2(patch_bounds.x, patch_bounds.y).is_equal_approx(Vector2.ONE))
    patch.mode = Patch.Mode.EAF4_SOURCE
    patch.wear_spec = spec
    patch.regenerate()
    assert((patch.get_node("PatchQuad") as MeshInstance3D).mesh.size == Vector2(0.7, 0.3))

    var approved := {"semantic_category": "water_mineral", "cause_tags": ["leak"],
                    "surface_capabilities": ["WALL"], "render_mode": "SOFT_BLEND",
                    "effective_status": "APPROVED"}
    var stale := approved.duplicate()
    stale["effective_status"] = "STALE"
    assert(Query.query_records([approved, stale], "water_mineral", "leak", "WALL", "SOFT_BLEND").size() == 1)
    var atlas := Image.create_empty(4, 2, false, Image.FORMAT_RGBA8)
    atlas.fill(Color(0.0, 0.0, 0.0, 0.0))
    atlas.set_pixel(0, 0, Color(1.0, 0.0, 0.0, 0.25))
    atlas.set_pixel(3, 0, Color(0.0, 0.0, 1.0, 0.75))
    var atlas_texture := ImageTexture.create_from_image(atlas)
    var first := spec.duplicate(true) as Resource
    first.base_color_texture = atlas_texture
    first.opacity_texture = null
    first.embedded_alpha = true
    first.atlas_region = Vector4(0.0, 0.0, 0.5, 1.0)
    var second := first.duplicate(true) as Resource
    second.atlas_region = Vector4(0.5, 0.0, 0.5, 1.0)
    assert(first.validate().is_empty())
    assert(second.validate().is_empty())
    assert(absf(atlas_texture.get_image().get_pixel(0, 0).a - 0.25) <= 1.0 / 255.0)
    assert(absf(atlas_texture.get_image().get_pixel(3, 0).a - 0.75) <= 1.0 / 255.0)
    assert(Overlay.build_material(first).get_shader_parameter("atlas_region") != Overlay.build_material(second).get_shader_parameter("atlas_region"))
    patch.free()
    overlay.free()
    print("EAF4B_GODOT_TEST_PASS")
    quit(0)
