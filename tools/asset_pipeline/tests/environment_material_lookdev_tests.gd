extends SceneTree

const SPEC_PATH := "res://environment_authoring/environment_surface_material_spec.gd"
const BUILDER_PATH := "res://environment_authoring/environment_material_builder.gd"
const SET_PATH := "res://data/environment/lookdev/eaf1_review_set.tres"
const SCENE_PATH := "res://gameplay/dev/environment_lookdev/environment_material_lookdev.tscn"
const CAPTURE_PATH := "res://gameplay/dev/environment_lookdev/environment_material_lookdev_capture.gd"

var failures: Array[String] = []


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var spec_script := load(SPEC_PATH) as GDScript
	_check(spec_script != null, "material spec script exists")
	if spec_script == null:
		_finish()
		return
	_test_spec(spec_script)
	_test_builder(spec_script)
	await _test_review_and_scene()
	_test_capture_contract()
	_finish()


func _test_spec(spec_script: GDScript) -> void:
	var spec: Resource = spec_script.new()
	spec.set("material_id", "sample")
	spec.set("base_color_texture", _solid_texture(Color(0.5, 0.5, 0.5)))
	_check((spec.call("validate") as PackedStringArray).is_empty(), "valid spec passes")
	spec.set("material_id", "")
	_check(not (spec.call("validate") as PackedStringArray).is_empty(), "empty ID rejected")
	spec.set("material_id", "sample")
	spec.set("base_color_texture", null)
	_check(not (spec.call("validate") as PackedStringArray).is_empty(), "missing base color rejected")
	spec.set("base_color_texture", _solid_texture(Color.WHITE))
	spec.set("meters_per_repeat", 0.0)
	_check(not (spec.call("validate") as PackedStringArray).is_empty(), "nonpositive scale rejected")
	spec.set("meters_per_repeat", 1.0)
	spec.set("mapping_mode", 99)
	_check(not (spec.call("validate") as PackedStringArray).is_empty(), "unknown mapping mode rejected")
	spec.set("mapping_mode", 0)
	spec.set("roughness_multiplier", -0.1)
	_check(not (spec.call("validate") as PackedStringArray).is_empty(), "bad multiplier rejected")
	spec.set("roughness_multiplier", 1.0)
	_check((spec.call("validate") as PackedStringArray).is_empty(), "optional maps may be absent")


func _test_builder(spec_script: GDScript) -> void:
	var builder_script := load(BUILDER_PATH) as GDScript
	_check(builder_script != null and builder_script.can_instantiate(), "material builder instantiates")
	if builder_script == null or not builder_script.can_instantiate():
		return
	var builder: RefCounted = builder_script.new()
	var spec: Resource = spec_script.new()
	spec.set("material_id", "builder_probe")
	var color := _solid_texture(Color(0.4, 0.4, 0.4))
	var normal := _solid_texture(Color(0.5, 0.2, 1.0))
	var rough := _solid_texture(Color(0.7, 0.7, 0.7))
	var metal := _solid_texture(Color(0.8, 0.8, 0.8))
	var ao := _solid_texture(Color(0.9, 0.9, 0.9))
	spec.set("base_color_texture", color)
	spec.set("normal_texture", normal)
	spec.set("roughness_texture", rough)
	spec.set("metallic_texture", metal)
	spec.set("ao_texture", ao)
	spec.set("height_texture", _solid_texture(Color.WHITE))
	spec.set("meters_per_repeat", 0.5)
	spec.set("normal_strength", 1.5)
	spec.set("roughness_multiplier", 0.8)
	spec.set("metallic_multiplier", 0.6)
	spec.set("albedo_multiplier", 0.75)
	var material := builder.call("build", spec) as StandardMaterial3D
	_check(material != null, "builder returns native material")
	if material == null:
		return
	_check(material.albedo_texture == color and material.normal_texture == normal and material.roughness_texture == rough and material.metallic_texture == metal and material.ao_texture == ao, "PBR maps bind")
	_check(not material.heightmap_enabled, "height does not enable displacement")
	_check(is_equal_approx(material.normal_scale, 1.5) and is_equal_approx(material.roughness, 0.8) and is_equal_approx(material.metallic, 0.6) and is_equal_approx(material.albedo_color.r, 0.75), "multipliers propagate")
	_check(material.uv1_scale.is_equal_approx(Vector3(2.0, 2.0, 2.0)) and not material.uv1_triplanar, "UV uses reciprocal metre scale")
	spec.set("mapping_mode", 1)
	material = builder.call("build", spec) as StandardMaterial3D
	_check(material.uv1_triplanar and not material.uv1_world_triplanar, "local triplanar selected")
	spec.set("mapping_mode", 2)
	material = builder.call("build", spec) as StandardMaterial3D
	_check(material.uv1_triplanar and material.uv1_world_triplanar, "world triplanar selected")
	var original_green := normal.get_image().get_pixel(0, 0).g
	spec.set("normal_y_flip", true)
	material = builder.call("build", spec) as StandardMaterial3D
	_check(material.normal_texture != normal, "normal Y helper creates separate texture")
	var flipped_green := material.normal_texture.get_image().get_pixel(0, 0).g
	_check(is_equal_approx(flipped_green, 1.0 - original_green), "normal Y inverted without changing source")
	_check(is_equal_approx(normal.get_image().get_pixel(0, 0).g, original_green), "source normal is unchanged")


func _test_review_and_scene() -> void:
	var review_set := load(SET_PATH) as Resource
	_check(review_set != null, "review set loads")
	if review_set == null:
		return
	_check((review_set.call("validate") as PackedStringArray).is_empty(), "review set validates")
	var specs := review_set.get("specs") as Array
	_check(specs.size() == 4, "three samples and one diagnostic")
	var mapping_modes := {}
	for spec in specs:
		mapping_modes[spec.mapping_mode] = true
	_check(mapping_modes.size() == 3, "review set visibly exercises all mapping modes")
	_check(int(review_set.call("wrapped_index", 4)) == 0 and int(review_set.call("wrapped_index", -1)) == 3, "review order wraps")
	var packed := load(SCENE_PATH) as PackedScene
	_check(packed != null, "lookdev scene loads")
	if packed == null:
		return
	var scene := packed.instantiate() as Node3D
	root.add_child(scene)
	await process_frame
	var neutral := scene.get_node_or_null("NeutralLightingRig") as Node3D
	var receiving := scene.get_node_or_null("ReceivingTargetLightingRig") as Node3D
	var environment := scene.get_node_or_null("WorldEnvironment") as WorldEnvironment
	_check(neutral != null and receiving != null and environment != null, "both rigs and one environment exist")
	_check(neutral.visible != receiving.visible, "exactly one rig active")
	var light_settings := scene.call("light_settings") as Array
	_check(light_settings.size() == 3 and (light_settings[0] as Dictionary).get("direction", []).size() == 3, "light manifest settings include direction")
	var camera := scene.call("get_active_camera") as Camera3D
	var transform_before := camera.transform
	var fov_before := camera.fov
	var material_before := scene.call("get_active_material") as Material
	_check(material_before != null, "review material actually assigned")
	var environment_before := environment.environment
	_check(scene.find_children("*", "WorldEnvironment", true, false).size() == 1, "one shared WorldEnvironment")
	var geometry_before := scene.call("geometry_snapshot") as Dictionary
	scene.call("toggle_light_mode")
	_check(neutral.visible != receiving.visible, "toggle keeps exactly one rig active")
	_check(camera.transform.is_equal_approx(transform_before) and is_equal_approx(camera.fov, fov_before), "toggle preserves camera transform and FOV")
	_check(scene.call("get_active_material") == material_before and scene.call("geometry_snapshot") == geometry_before, "toggle preserves material and geometry")
	_check(environment.environment == environment_before, "toggle shares environment, exposure and tonemap")
	scene.call("toggle_light_mode")
	_check(neutral.visible and not receiving.visible, "toggle reversible")
	var reviewed := scene.call("get_active_material") as Material
	var references := scene.get_node("ReviewGeometry/ReferenceObjects")
	var references_clean := true
	for child in references.get_children():
		if child is MeshInstance3D and (child as MeshInstance3D).material_override == reviewed:
			references_clean = false
	_check(references_clean, "reference objects never use review material")
	scene.call("previous_material")
	_check(int(scene.get("material_index")) == 3, "previous wraps to last")
	scene.call("next_material")
	_check(int(scene.get("material_index")) == 0, "next wraps to first")
	scene.call("next_camera")
	_check(String(scene.call("get_camera_name")) == "WallGrazing", "camera order deterministic")
	scene.call("reset_review")
	_check(int(scene.get("material_index")) == 0 and int(scene.get("light_mode")) == 0 and String(scene.call("get_camera_name")) == "Hero", "reset canonical")
	scene.queue_free()


func _test_capture_contract() -> void:
	var capture_script := load(CAPTURE_PATH) as GDScript
	_check(capture_script != null, "capture script exists")
	if capture_script == null:
		return
	var capture: Node = capture_script.new()
	var records := capture.call("get_capture_records") as Array
	_check(records.size() == 16, "four capture records per material")
	var paths := {}
	var stable := true
	for index in records.size():
		var record := records[index] as Dictionary
		var filename := String(record.get("filename", ""))
		paths[filename] = true
		if not filename.ends_with(".png") or not record.has("material_id") or not record.has("light_mode") or not record.has("camera"):
			stable = false
	_check(stable and paths.size() == records.size(), "filenames unique and records complete")
	var fields := capture.call("get_manifest_static_fields") as Dictionary
	_check(fields.has("scene") and fields.has("engine_version") and fields.has("renderer") and fields.has("exposure") and fields.has("tonemap"), "manifest static fields present")
	capture.free()


func _solid_texture(color: Color) -> ImageTexture:
	var image := Image.create(2, 2, false, Image.FORMAT_RGBA8)
	image.fill(color)
	return ImageTexture.create_from_image(image)


func _check(condition: bool, label: String) -> void:
	if condition:
		print("PASS: ", label)
	else:
		print("FAIL: ", label)
		failures.append(label)


func _finish() -> void:
	print("EAF1_TESTS failures=", failures.size())
	quit(0 if failures.is_empty() else 1)
