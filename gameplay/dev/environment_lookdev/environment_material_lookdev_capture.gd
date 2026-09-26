extends Node3D

const REVIEW_SET = preload("res://data/environment/lookdev/eaf1_review_set.tres")
const OUTPUT_DIRECTORY := "res://reports/environment_lookdev/eaf1"
const CAPTURE_SIZE := Vector2i(1920, 1080)
const LOOKDEV_SCENE := "res://gameplay/dev/environment_lookdev/environment_material_lookdev.tscn"
const CAPTURE_SCENE := "res://gameplay/dev/environment_lookdev/environment_material_lookdev_capture.tscn"

var _review_set: Resource = REVIEW_SET
var _output_directory := OUTPUT_DIRECTORY
var _batch_id := ""


func _ready() -> void:
	var args := OS.get_cmdline_user_args()
	var batch_at := args.find("--eaf3b-batch")
	if batch_at >= 0:
		if batch_at + 1 >= args.size() or not _safe_batch_id(args[batch_at + 1]):
			_fail("invalid EAF3B batch ID")
			return
		_batch_id = args[batch_at + 1]
		var path := "res://data/environment/material_catalog/review_batches/%s/review_set.tres" % _batch_id
		var selected := load(path) as Resource
		if selected == null or not selected.validate().is_empty():
			_fail("invalid EAF3B review set: %s" % path)
			return
		set_review_set(selected)
		(get_node("Lookdev") as Node3D).call("set_review_set", selected)
		_output_directory = "res://reports/environment_material_catalog/reviews/%s" % _batch_id
	if args.has("--capture"):
		_capture_all.call_deferred()


func _safe_batch_id(value: String) -> bool:
	return value.is_valid_identifier() and value == value.to_lower() and value.length() <= 64


func set_review_set(review_set: Resource) -> void:
	_review_set = review_set if review_set != null else REVIEW_SET


func get_capture_records() -> Array:
	var records := []
	for spec in _review_set.specs:
		for mode in ["neutral", "receiving"]:
			for view in ["hero", "grazing"]:
				records.append({
					"material_id": spec.material_id,
					"light_mode": mode,
					"camera": "Hero" if view == "hero" else "WallGrazing",
					"filename": "%s__%s__%s.png" % [spec.material_id, mode, view],
				})
	return records


func get_manifest_static_fields() -> Dictionary:
	return {
		"scene": CAPTURE_SCENE,
		"lookdev_scene": LOOKDEV_SCENE,
		"engine_version": Engine.get_version_info().string,
		"renderer": RenderingServer.get_current_rendering_method(),
		"capture_size": [CAPTURE_SIZE.x, CAPTURE_SIZE.y],
		"exposure": 1.0,
		"tonemap": "FILMIC",
	}


func _capture_all() -> void:
	var lookdev := get_node_or_null("Lookdev") as Node3D
	if lookdev == null:
		_fail("missing Lookdev scene")
		return
	var output := ProjectSettings.globalize_path(_output_directory)
	var error := DirAccess.make_dir_recursive_absolute(output)
	if error != OK:
		_fail("could not create output: %s" % error_string(error))
		return
	get_window().size = CAPTURE_SIZE
	await get_tree().process_frame
	await get_tree().process_frame
	var manifest := get_manifest_static_fields()
	var captured := []
	for value in get_capture_records():
		var record: Dictionary = value
		var spec_index := _spec_index(String(record["material_id"]))
		if spec_index < 0:
			_fail("unknown material ID: %s" % record["material_id"])
			return
		lookdev.call("set_material_index", spec_index)
		lookdev.call("set_light_mode", 0 if record["light_mode"] == "neutral" else 1)
		lookdev.call("set_camera_index", 0 if record["camera"] == "Hero" else 1)
		var camera := lookdev.call("get_active_camera") as Camera3D
		camera.make_current()
		await get_tree().process_frame
		await get_tree().process_frame
		await RenderingServer.frame_post_draw
		var image := get_viewport().get_texture().get_image()
		if image == null or image.is_empty():
			_fail("renderer returned no image for %s" % record["filename"])
			return
		if image.get_size() != CAPTURE_SIZE:
			image.resize(CAPTURE_SIZE.x, CAPTURE_SIZE.y, Image.INTERPOLATE_LANCZOS)
		var filename := output.path_join(String(record["filename"]))
		error = image.save_png(filename)
		if error != OK:
			_fail("could not save %s: %s" % [filename, error_string(error)])
			return
		var spec: Resource = _review_set.specs[spec_index]
		var transform := camera.global_transform
		var item := record.duplicate()
		item["source_label"] = spec.source_label
		item["source_path"] = spec.source_path
		item["mapping_mode"] = spec.mapping_name()
		item["meters_per_repeat"] = spec.meters_per_repeat
		item["normal_y_flip"] = spec.normal_y_flip
		item["camera_transform"] = {
			"origin": _vec3(transform.origin),
			"basis_x": _vec3(transform.basis.x),
			"basis_y": _vec3(transform.basis.y),
			"basis_z": _vec3(transform.basis.z),
		}
		item["camera_fov"] = camera.fov
		item["light_settings"] = lookdev.call("light_settings")
		captured.append(item)
		print("EAF1_CAPTURE material=%s mode=%s camera=%s path=%s" % [record["material_id"], record["light_mode"], record["camera"], filename])
	var environment := (lookdev.get_node("WorldEnvironment") as WorldEnvironment).environment
	manifest["exposure"] = environment.tonemap_exposure
	manifest["tonemap"] = environment.tonemap_mode
	manifest["tonemap_name"] = "FILMIC"
	manifest["background_color"] = environment.background_color.to_html()
	manifest["ambient_light_color"] = environment.ambient_light_color.to_html()
	manifest["ambient_light_energy"] = environment.ambient_light_energy
	manifest["records"] = captured
	if not _batch_id.is_empty():
		manifest["batch_id"] = _batch_id
	var manifest_path := output.path_join("manifest.json")
	var file := FileAccess.open(manifest_path, FileAccess.WRITE)
	if file == null:
		_fail("could not write manifest: %s" % error_string(FileAccess.get_open_error()))
		return
	file.store_string(JSON.stringify(manifest, "\t"))
	file.close()
	print("EAF1_CAPTURE_COMPLETE records=%d manifest=%s" % [captured.size(), manifest_path])
	get_tree().quit(0)


func _spec_index(material_id: String) -> int:
	for index in _review_set.specs.size():
		if _review_set.specs[index].material_id == material_id:
			return index
	return -1


func _vec3(vector: Vector3) -> Array:
	return [vector.x, vector.y, vector.z]


func _fail(message: String) -> void:
	push_error("EAF1_CAPTURE_FAIL: %s" % message)
	get_tree().quit(1)
