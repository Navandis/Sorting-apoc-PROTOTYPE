@tool
class_name EnvironmentWearOverlay
extends Node3D

const Spec = preload("res://environment_authoring/wear/environment_wear_overlay_spec.gd")
const CUTOUT = preload("res://environment_authoring/wear/shaders/wear_overlay_cutout.gdshader")
const SOFT = preload("res://environment_authoring/wear/shaders/wear_overlay_soft.gdshader")

@export var spec: EnvironmentWearOverlaySpec:
    set(value):
        spec = value
        if is_inside_tree():
            regenerate()
@export var mirror_u := false:
    set(value):
        mirror_u = value
        if is_inside_tree():
            regenerate()
@export var mirror_v := false:
    set(value):
        mirror_v = value
        if is_inside_tree():
            regenerate()
@export var imperfection_enabled := true:
    set(value):
        imperfection_enabled = value
        if is_inside_tree():
            regenerate()

func _ready() -> void:
    regenerate()

func get_mesh_size() -> Vector2:
    var quad := get_node_or_null("Quad") as MeshInstance3D
    if quad == null or not quad.mesh is QuadMesh:
        return Vector2.ZERO
    return (quad.mesh as QuadMesh).size

func regenerate() -> void:
    scale = Vector3.ONE
    var quad := get_node_or_null("Quad") as MeshInstance3D
    if quad == null:
        quad = MeshInstance3D.new()
        quad.name = "Quad"
        add_child(quad)
        if Engine.is_editor_hint():
            quad.owner = get_tree().edited_scene_root
    if spec == null or not spec.validate().is_empty():
        quad.visible = false
        return
    quad.visible = true
    quad.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
    var mesh := QuadMesh.new()
    mesh.size = spec.physical_size_m
    quad.mesh = mesh
    quad.position = Vector3(0.0, 0.0, spec.surface_offset_m)
    quad.material_override = build_material(spec, mirror_u, mirror_v, imperfection_enabled)

static func build_material(wear_spec: EnvironmentWearOverlaySpec, flip_u := false, flip_v := false, use_imperfection := true) -> ShaderMaterial:
    if wear_spec == null or not wear_spec.validate().is_empty():
        return null
    var material := ShaderMaterial.new()
    material.shader = CUTOUT if wear_spec.render_mode == Spec.RenderMode.CUTOUT else SOFT
    material.set_shader_parameter("base_color_texture", wear_spec.base_color_texture)
    material.set_shader_parameter("opacity_texture", wear_spec.opacity_texture)
    material.set_shader_parameter("normal_texture", wear_spec.normal_texture)
    material.set_shader_parameter("roughness_texture", wear_spec.roughness_texture)
    material.set_shader_parameter("metallic_texture", wear_spec.metallic_texture)
    material.set_shader_parameter("imperfection_texture", wear_spec.imperfection_mask_texture)
    material.set_shader_parameter("has_color", wear_spec.base_color_texture != null)
    material.set_shader_parameter("has_opacity", wear_spec.opacity_texture != null)
    material.set_shader_parameter("has_normal", wear_spec.normal_texture != null)
    material.set_shader_parameter("has_roughness", wear_spec.roughness_texture != null)
    material.set_shader_parameter("has_metallic", wear_spec.metallic_texture != null)
    material.set_shader_parameter("has_imperfection", use_imperfection and wear_spec.imperfection_mask_texture != null)
    material.set_shader_parameter("embedded_alpha", wear_spec.embedded_alpha)
    material.set_shader_parameter("atlas_region", wear_spec.atlas_region)
    material.set_shader_parameter("mirror_uv", Vector2(float(flip_u), float(flip_v)))
    material.set_shader_parameter("opacity_multiplier", wear_spec.opacity_multiplier)
    material.set_shader_parameter("albedo_strength", wear_spec.albedo_strength)
    material.set_shader_parameter("albedo_tint", wear_spec.albedo_tint)
    material.set_shader_parameter("normal_strength", wear_spec.normal_strength)
    material.set_shader_parameter("normal_y_flip", wear_spec.normal_y_flip)
    material.set_shader_parameter("roughness_strength", wear_spec.roughness_strength)
    if wear_spec.render_mode == Spec.RenderMode.SOFT_BLEND:
        material.set_shader_parameter("edge_feather", wear_spec.edge_feather)
    material.set_shader_parameter("imperfection_scale", wear_spec.imperfection_scale)
    material.set_shader_parameter("imperfection_rotation", deg_to_rad(wear_spec.imperfection_rotation))
    material.set_shader_parameter("imperfection_contrast", wear_spec.imperfection_contrast)
    material.set_shader_parameter("imperfection_strength", wear_spec.imperfection_strength)
    return material
