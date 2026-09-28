extends Node3D

const LOOKDEV = preload("res://gameplay/dev/environment_lookdev/environment_material_lookdev.tscn")
const REVIEW_SET_SCRIPT = preload("res://environment_authoring/environment_material_review_set.gd")
const AFT_SPEC = preload("res://data/environment/material_catalog/review_batches/eaf5_receiving_pbr_01a/eaf3b_ad740710d009de8d795c0d8c.tres")
const FAB_SPEC = preload("res://data/environment/material_catalog/review_batches/eaf5_receiving_pbr_01a/eaf3b_d335d94fd85c2c95c26b6b8b.tres")
const UV_CONTROL_SPEC = preload("res://data/environment/material_catalog/review_batches/eaf5_receiving_pbr_01a/eaf3b_5a797fbdc766d7e3dc475abf.tres")
const OUTPUT = "res://reports/environment_lookdev/eaf5_triplanar_uv_diagnostic"
const SIZE = Vector2i(1920, 1080)

var lookdev: Node3D

func _ready() -> void:
	lookdev = LOOKDEV.instantiate()
	add_child(lookdev)
	var review_set: Resource = REVIEW_SET_SCRIPT.new()
	var specs: Array[Resource] = [AFT_SPEC, FAB_SPEC, UV_CONTROL_SPEC]
	review_set.set("specs", specs)
	lookdev.call("set_review_set", review_set)
	get_window().size = SIZE
	await get_tree().process_frame
	await get_tree().process_frame
	var material := lookdev.call("get_active_material") as StandardMaterial3D
	for property in material.get_property_list():
		if String(property.name).contains("triplanar") or String(property.name).contains("texture_filter") or String(property.name) == "uv1_scale":
			print("PROPERTY ", property.name, " = ", material.get(property.name))
	var output := ProjectSettings.globalize_path(OUTPUT)
	DirAccess.make_dir_recursive_absolute(output)
	for variant in ["uv_full", "tri_full", "world_full", "tri_albedo", "tri_normal_neutral", "tri_mipmap", "tri_sharp8"]:
		await _capture(output, 0, variant)
	for variant in ["uv_full", "tri_full"]:
		await _capture(output, 1, variant)
	await _capture(output, 2, "uv_full")
	print("EAF5_DIAGNOSTIC_COMPLETE count=10")
	get_tree().quit()

func _capture(output: String, index: int, variant: String) -> void:
	lookdev.call("set_material_index", index)
	lookdev.call("set_light_mode", 0)
	lookdev.call("set_camera_index", 1)
	var material := lookdev.call("get_active_material") as StandardMaterial3D
	material.uv1_triplanar = variant != "uv_full"
	material.uv1_world_triplanar = variant == "world_full"
	if variant == "tri_albedo" or variant == "tri_normal_neutral":
		material.roughness_texture = null
		material.roughness = 1.0
		material.metallic_texture = null
		material.metallic = 0.0
		material.ao_enabled = false
		material.ao_texture = null
	if variant == "tri_albedo":
		material.normal_enabled = false
		material.normal_texture = null
	if variant == "tri_sharp8":
		material.uv1_triplanar_sharpness = 8.0
	if variant == "tri_mipmap":
		material.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	var hud := lookdev.get_node("ReviewHUD/Panel/Label") as Label
	hud.text = hud.text.replace("Mapping: TRIPLANAR", "Mapping: " + ("UV" if variant == "uv_full" else "WORLD_TRIPLANAR" if variant == "world_full" else "TRIPLANAR"))
	hud.text = hud.text.replace("EAF1 MATERIAL LOOKDEV", "EAF1 MATERIAL DIAGNOSTIC: " + variant)
	(lookdev.call("get_active_camera") as Camera3D).make_current()
	await get_tree().process_frame
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	var image := get_viewport().get_texture().get_image()
	if image.get_size() != SIZE:
		image.resize(SIZE.x, SIZE.y, Image.INTERPOLATE_LANCZOS)
	var label := "aft" if index == 0 else "fab" if index == 1 else "panel_control"
	var path := output.path_join("%s__%s.png" % [label, variant])
	var error := image.save_png(path)
	if error != OK:
		push_error("Diagnostic capture failed: %s" % path)
		get_tree().quit(1)
	print("EAF5_DIAGNOSTIC_CAPTURE ", path)
