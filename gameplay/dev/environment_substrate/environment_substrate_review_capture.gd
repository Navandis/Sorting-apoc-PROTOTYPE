extends Node3D

const OUTPUT_DIRECTORY := "res://reports/environment_substrate/eaf2"
const CAPTURE_SIZE := Vector2i(1600, 900)
const CAPTURE_SCENE := "res://gameplay/dev/environment_substrate/environment_substrate_review_capture.tscn"
const REVIEW_SCENE := "res://gameplay/dev/environment_substrate/environment_substrate_review.tscn"


func _ready() -> void:
	if OS.get_cmdline_user_args().has("--capture"):
		_capture_all.call_deferred()


func get_capture_records() -> Array:
	var review := get_node_or_null("Review")
	if review != null:
		return review.get_capture_records()
	return [
		{"camera_index": 0, "camera": "SeedOverview", "filename": "seed_overview.png"},
		{"camera_index": 1, "camera": "DimensionUVComparison", "filename": "dimension_uv_comparison.png"},
		{"camera_index": 2, "camera": "OpeningDetail_LeftJamb", "filename": "opening_detail_left_jamb.png"},
		{"camera_index": 3, "camera": "OpeningDetail_RightJamb", "filename": "opening_detail_right_jamb.png"},
		{"camera_index": 4, "camera": "Composition", "filename": "composition.png"},
		{"camera_index": 5, "camera": "ExtensibilityProof", "filename": "extensibility_proof.png"},
	]


func _capture_all() -> void:
	var review := get_node_or_null("Review") as Node3D
	if review == null:
		_fail("missing Review scene")
		return
	var output := ProjectSettings.globalize_path(OUTPUT_DIRECTORY)
	var error := DirAccess.make_dir_recursive_absolute(output)
	if error != OK:
		_fail("could not create output: " + error_string(error))
		return
	get_window().size = CAPTURE_SIZE
	await get_tree().process_frame
	await get_tree().process_frame
	var records := []
	for entry in get_capture_records():
		review.set_camera_index(int(entry["camera_index"]))
		var camera := review.get_active_camera() as Camera3D
		camera.make_current()
		await get_tree().process_frame
		await get_tree().process_frame
		await RenderingServer.frame_post_draw
		var image := get_viewport().get_texture().get_image()
		if image == null or image.is_empty():
			_fail("renderer returned no image for " + entry["camera"])
			return
		if image.get_size() != CAPTURE_SIZE:
			image.resize(CAPTURE_SIZE.x, CAPTURE_SIZE.y, Image.INTERPOLATE_LANCZOS)
		var filename := output.path_join(entry["filename"])
		error = image.save_png(filename)
		if error != OK:
			_fail("could not save %s: %s" % [filename, error_string(error)])
			return
		var record: Dictionary = entry.duplicate()
		record["camera_origin"] = _v3(camera.global_position)
		record["camera_basis_x"] = _v3(camera.global_transform.basis.x)
		record["camera_basis_y"] = _v3(camera.global_transform.basis.y)
		record["camera_basis_z"] = _v3(camera.global_transform.basis.z)
		record["camera_fov"] = camera.fov
		records.append(record)
		print("EAF2_CAPTURE camera=%s path=%s" % [entry["camera"], filename])
	var environment := (review.get_node("WorldEnvironment") as WorldEnvironment).environment
	var manifest := {
		"scene": CAPTURE_SCENE,
		"review_scene": REVIEW_SCENE,
		"engine_version": Engine.get_version_info().string,
		"renderer": RenderingServer.get_current_rendering_method(),
		"capture_size": [CAPTURE_SIZE.x, CAPTURE_SIZE.y],
		"environment": {
			"background_color": environment.background_color.to_html(),
			"ambient_color": environment.ambient_light_color.to_html(),
			"ambient_energy": environment.ambient_light_energy,
			"exposure": environment.tonemap_exposure,
			"tonemap": environment.tonemap_mode,
		},
		"pieces": review.generation_records(),
		"records": records,
	}
	var manifest_path := output.path_join("manifest.json")
	var file := FileAccess.open(manifest_path, FileAccess.WRITE)
	if file == null:
		_fail("could not write manifest: " + error_string(FileAccess.get_open_error()))
		return
	file.store_string(JSON.stringify(manifest, "\t"))
	file.close()
	print("EAF2_CAPTURE_COMPLETE records=%d pieces=%d manifest=%s" % [records.size(), manifest["pieces"].size(), manifest_path])
	get_tree().quit(0)


func _v3(value: Vector3) -> Array:
	return [value.x, value.y, value.z]


func _fail(message: String) -> void:
	push_error("EAF2_CAPTURE_FAIL: " + message)
	get_tree().quit(1)
