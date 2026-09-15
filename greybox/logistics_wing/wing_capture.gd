extends Node3D

const OUTPUT_DIRECTORY := "res://reports/logistics_wing/greybox"
const CAPTURE_SIZE := Vector2i(1920, 1080)
const CONTACT_TILE_SIZE := Vector2i(480, 360)
const CONTACT_COLUMNS := 4
const CONTACT_ROWS := 3


func _ready() -> void:
	if not should_capture(OS.get_cmdline_user_args()):
		return
	_capture_all.call_deferred()


func should_capture(user_arguments: PackedStringArray) -> bool:
	return user_arguments.has("--capture")


func get_output_directory() -> String:
	return OUTPUT_DIRECTORY


func get_view_records() -> Array:
	return [
		_view("Full-wing debug overview", "overview_debug_topdown.png", Vector3(10, 62, 2), Vector3(10, 0, 2), 55.0, false, true),
		_view("Receiving apron toward freight barrier", "receiving_freight.png", Vector3(-31.5, 1.7162851, 0), Vector3(-39.0, 1.2, 0), 75.0),
		_view("Receiving toward Backlog", "receiving_core.png", Vector3(-32.0, 1.7162851, 2.0), Vector3(-20.0, 1.4, 0), 75.0),
		_view("Backlog toward Sorting", "backlog_sorting.png", Vector3(-23.0, 1.7162851, 0), Vector3(-10.0, 1.4, 0), 75.0),
		_view("Sorting work position toward table", "sorting_table.png", Vector3(-9.0, 1.7162851, -1.8), Vector3(-9.0, 1.15, -4.1), 75.0),
		_view("Sorting work position toward Receiving", "sorting_receiving.png", Vector3(-9.0, 1.7162851, -1.8), Vector3(-22.0, 1.4, 0), 75.0),
		_view("Sorting work position toward Storage", "sorting_storage.png", Vector3(-9.0, 1.7162851, -1.8), Vector3(-1.0, 1.4, 2.2), 75.0),
		_view("Storage A and B approaches", "storage_ab.png", Vector3(6.0, 1.7162851, 1.8), Vector3(6.0, 1.4, -1.5), 75.0),
		_view("Storage C and D secondary opening", "storage_cd.png", Vector3(9.5, 1.7162851, 9.5), Vector3(6.0, 1.4, 9.5), 75.0),
		_view("Storage E single-entry boundary", "storage_e.png", Vector3(20.5, 1.7162851, 4.5), Vector3(22.0, 1.4, 11.5), 75.0),
		_view("Medical protected approach", "medical_approach.png", Vector3(6.0, 1.7162851, -14.5), Vector3(6.0, 1.4, -22.0), 75.0),
		_view("Kitchen and Mess approach", "kitchen_approach.png", Vector3(24.5, 1.7162851, -15.0), Vector3(25.0, 1.4, -22.0), 75.0),
		_view("Workshop frontage from shared service leg", "workshop_frontage.png", Vector3(-8.5, 1.7162851, 20.0), Vector3(-14.0, 1.4, 20.0), 75.0),
		_view("Salvager spur from shared service leg", "workshop_salvager.png", Vector3(4.5, 1.7162851, 20.0), Vector3(5.5, 1.4, 26.5), 75.0),
		_view("Workshop-side blocked continuation", "workshop_blocked.png", Vector3(-8.5, 1.7162851, 21.0), Vector3(-8.5, 1.3, 25.0), 75.0),
		_view("Wide Deeper-Bunker approach to dog-leg", "deeper_wide.png", Vector3(28.0, 1.7162851, 0.5), Vector3(41.0, 1.4, -4.0), 75.0),
		_view("Incinerator terminal spur", "incinerator.png", Vector3(37.0, 1.7162851, 7.0), Vector3(37.0, 1.4, 14.75), 75.0),
		_view("Narrow dog-leg toward Bunker Ops", "deeper_narrow.png", Vector3(41.0, 1.7162851, -8.5), Vector3(54.0, 1.4, -8.5), 75.0),
		_view("Bunker Ops and deeper-settlement closure", "bunker_ops_closure.png", Vector3(58.7, 1.7162851, -8.2), Vector3(62.0, 1.4, -9.0), 75.0),
	]


func get_capture_basenames() -> Array:
	var basenames: Array = []
	for record: Dictionary in get_view_records():
		basenames.append(String(record["basename"]))
	basenames.append("contact_sheet_01.png")
	basenames.append("contact_sheet_02.png")
	return basenames


func normalize_capture_image(image: Image) -> Image:
	if image.get_size() != CAPTURE_SIZE:
		image.resize(CAPTURE_SIZE.x, CAPTURE_SIZE.y, Image.INTERPOLATE_LANCZOS)
	return image


func make_contact_sheets(captures: Array[Image]) -> Array:
	if captures.size() != get_view_records().size():
		return []
	var sheets: Array = []
	var per_sheet := CONTACT_COLUMNS * CONTACT_ROWS
	for sheet_index: int in ceili(float(captures.size()) / float(per_sheet)):
		var sheet := Image.create_empty(1920, 1080, false, Image.FORMAT_RGBA8)
		sheet.fill(Color(0.025, 0.025, 0.025, 1.0))
		for local_index: int in per_sheet:
			var capture_index := sheet_index * per_sheet + local_index
			if capture_index >= captures.size():
				break
			var tile := captures[capture_index].duplicate()
			tile.resize(CONTACT_TILE_SIZE.x, CONTACT_TILE_SIZE.y, Image.INTERPOLATE_LANCZOS)
			var tile_position := Vector2i(local_index % CONTACT_COLUMNS, local_index / CONTACT_COLUMNS) * CONTACT_TILE_SIZE
			sheet.blit_rect(tile, Rect2i(Vector2i.ZERO, CONTACT_TILE_SIZE), tile_position)
		sheets.append(sheet)
	return sheets


func _capture_all() -> void:
	var roof := get_node_or_null("Review/Geometry/RoofVisuals") as Node3D
	var camera := get_node_or_null("CaptureCamera") as Camera3D
	var orientation_aids := get_node_or_null("Review/OrientationAids") as Node3D
	if roof == null or camera == null or orientation_aids == null:
		_fail_capture("missing RoofVisuals, OrientationAids, or CaptureCamera")
		return
	var interaction_hud := get_node_or_null("Review/ReviewPlayer/InteractionHUD") as CanvasLayer
	if interaction_hud != null:
		interaction_hud.visible = false
	var absolute_directory := ProjectSettings.globalize_path(OUTPUT_DIRECTORY)
	var directory_error := DirAccess.make_dir_recursive_absolute(absolute_directory)
	if directory_error != OK:
		_fail_capture("could not create output directory: " + error_string(directory_error))
		return
	get_window().size = CAPTURE_SIZE
	await get_tree().process_frame
	await get_tree().process_frame
	var records := get_view_records()
	var captures: Array[Image] = []
	for record: Dictionary in records:
		roof.visible = bool(record["ceiling_on"])
		orientation_aids.visible = bool(record["overview"])
		camera.fov = float(record["fov"])
		camera.global_position = record["position"] as Vector3
		var up := Vector3(0, 0, -1) if bool(record["overview"]) else Vector3.UP
		camera.look_at(record["target"] as Vector3, up)
		camera.make_current()
		await get_tree().process_frame
		await get_tree().process_frame
		await RenderingServer.frame_post_draw
		var image := get_viewport().get_texture().get_image()
		if image == null or image.is_empty():
			_fail_capture("renderer returned no image for " + String(record["basename"]))
			return
		image = normalize_capture_image(image)
		var output_path := absolute_directory.path_join(String(record["basename"]))
		var save_error := image.save_png(output_path)
		if save_error != OK:
			_fail_capture("could not save %s: %s" % [output_path, error_string(save_error)])
			return
		captures.append(image)
		print("CAPTURE view=%s path=%s position=%s target=%s fov=%.1f ceiling_on=%s" % [record["label"], output_path, record["position"], record["target"], record["fov"], record["ceiling_on"]])
	roof.visible = true
	orientation_aids.visible = true
	var sheets := make_contact_sheets(captures)
	for index: int in sheets.size():
		var sheet_path := absolute_directory.path_join("contact_sheet_%02d.png" % (index + 1))
		var sheet_error := (sheets[index] as Image).save_png(sheet_path)
		if sheet_error != OK:
			_fail_capture("could not save contact sheet: " + error_string(sheet_error))
			return
		print("CAPTURE contact_sheet=" + sheet_path)
	var manifest_error := _save_manifest(absolute_directory, records)
	if manifest_error != OK:
		_fail_capture("could not save capture manifest: " + error_string(manifest_error))
		return
	print("CAPTURE_COMPLETE views=%d sheets=%d renderer=%s" % [captures.size(), sheets.size(), RenderingServer.get_current_rendering_method()])
	get_tree().quit(0)


func _save_manifest(absolute_directory: String, records: Array) -> Error:
	var serialized_views: Array = []
	for record: Dictionary in records:
		serialized_views.append({
			"label": record["label"],
			"basename": record["basename"],
			"position": _vector(record["position"] as Vector3),
			"target": _vector(record["target"] as Vector3),
			"fov": record["fov"],
			"ceiling_on": record["ceiling_on"],
			"overview": record["overview"],
		})
	var manifest := {
		"scene": "res://greybox/logistics_wing/wing_capture.tscn",
		"review_scene": "res://greybox/logistics_wing/wing_review.tscn",
		"layout_revision": "logistics-wing-greybox-v1",
		"renderer": RenderingServer.get_current_rendering_method(),
		"capture_size": {"x": CAPTURE_SIZE.x, "y": CAPTURE_SIZE.y},
		"views": serialized_views,
	}
	var file := FileAccess.open(absolute_directory.path_join("capture_manifest.json"), FileAccess.WRITE)
	if file == null:
		return FileAccess.get_open_error()
	file.store_string(JSON.stringify(manifest, "\t") + "\n")
	file.close()
	return OK


func _view(label: String, basename: String, position: Vector3, target: Vector3, fov: float, ceiling_on: bool = true, overview: bool = false) -> Dictionary:
	return {
		"label": label,
		"basename": basename,
		"position": position,
		"target": target,
		"fov": fov,
		"ceiling_on": ceiling_on,
		"overview": overview,
	}


func _vector(value: Vector3) -> Dictionary:
	return {"x": value.x, "y": value.y, "z": value.z}


func _fail_capture(message: String) -> void:
	push_error("CAPTURE_FAILED: " + message)
	get_tree().quit(1)
