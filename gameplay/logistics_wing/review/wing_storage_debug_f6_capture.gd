extends Node3D

const OUTPUT_DIRECTORY := "res://reports/logistics_wing/storage_bridge/f6_followup"
const CAPTURE_SIZE := Vector2i(1920, 1080)
const CONTACT_COLUMNS := 3
const CONTACT_ROWS := 2
const CONTACT_TILE_SIZE := Vector2i(640, 540)
const CONTACT_IMAGE_SIZE := Vector2i(640, 360)

var _transition_sequence: Array[Dictionary] = []


func _ready() -> void:
	if should_capture(OS.get_cmdline_user_args()):
		_capture_all.call_deferred()


func should_capture(user_arguments: PackedStringArray) -> bool:
	return user_arguments.has("--capture-f6")


func get_output_directory() -> String:
	return OUTPUT_DIRECTORY


func get_view_records() -> Array:
	return [
		_view(
			"Gallery A shelf — F6 OFF",
			"gallery_a_f6_off.png",
			"gallery_a",
			"off",
			Vector3(-2.28, 1.72, -4.2),
			Vector3(-2.28, 1.25, -7.2)
		),
		_view(
			"Gallery B shelf — F6 OFF",
			"gallery_b_f6_off.png",
			"gallery_b",
			"off",
			Vector3(14.0, 1.72, -10.6),
			Vector3(14.0, 1.25, -13.78)
		),
		_view(
			"Gallery C locker — F6 OFF",
			"gallery_c_f6_off.png",
			"gallery_c",
			"off",
			Vector3(-1.35, 1.72, 5.9),
			Vector3(-1.35, 1.25, 9.0)
		),
		_view(
			"Gallery A shelf — F6 ON",
			"gallery_a_f6_on.png",
			"gallery_a",
			"on",
			Vector3(-2.28, 1.72, -4.2),
			Vector3(-2.28, 1.25, -7.2)
		),
		_view(
			"Gallery B shelf — F6 ON",
			"gallery_b_f6_on.png",
			"gallery_b",
			"on",
			Vector3(14.0, 1.72, -10.6),
			Vector3(14.0, 1.25, -13.78)
		),
		_view(
			"Gallery C locker — F6 ON",
			"gallery_c_f6_on.png",
			"gallery_c",
			"on",
			Vector3(-1.35, 1.72, 5.9),
			Vector3(-1.35, 1.25, 9.0)
		),
	]


func get_manifest_static_fields() -> Dictionary:
	return {
		"scene": "res://gameplay/logistics_wing/review/wing_storage_debug_f6_capture.tscn",
		"gameplay_scene": "res://gameplay/logistics_wing/wing_gameplay.tscn",
		"evidence_kind": "continuing-wing-storage-debug-f6-follow-up",
		"player_eye_reference": {
			"camera_height_m": 1.72,
			"fov_degrees": 75.0,
		},
		"source_hash_paths": PackedStringArray([
			"res://storage_surface.gd",
			"res://gameplay/logistics_wing/functional_storage_manager.gd",
			"res://gameplay/logistics_wing/functional_fixtures.gd",
			"res://gameplay/logistics_wing/wing_gameplay.tscn",
			"res://gameplay/logistics_wing/review/wing_storage_debug_f6_capture.gd",
			"res://tools/asset_pipeline/tests/wing_storage_debug_f6_tests.gd",
		]),
	}


func _capture_all() -> void:
	var gameplay := get_node_or_null("Gameplay")
	var camera := get_node_or_null("CaptureCamera") as Camera3D
	var manager := get_node_or_null("Gameplay/FunctionalFixtures/StoragePrototypeManager")
	if gameplay == null or camera == null or manager == null:
		_fail_capture("missing Gameplay, CaptureCamera, or StoragePrototypeManager")
		return
	var surfaces := gameplay.call("get_functional_surfaces") as Array
	if surfaces.size() != 12:
		_fail_capture("expected 12 storage surfaces, found %d" % surfaces.size())
		return
	var absolute_directory := ProjectSettings.globalize_path(OUTPUT_DIRECTORY)
	var directory_error := DirAccess.make_dir_recursive_absolute(absolute_directory)
	if directory_error != OK:
		_fail_capture("could not create evidence directory: %s" % error_string(directory_error))
		return
	get_window().size = CAPTURE_SIZE
	await get_tree().process_frame
	await get_tree().process_frame
	_transition_sequence.clear()
	_append_transition("startup", "none", manager, surfaces)
	if bool(manager.call("is_developer_grid_visible")):
		await _send_key(KEY_F6, true, false)
		_append_transition("normalize_off", "F6 key-down", manager, surfaces)
	if not _validate_grid_state(false, manager, surfaces):
		_fail_capture("developer grids did not start OFF")
		return

	var captures: Array[Image] = []
	var captured_records: Array[Dictionary] = []
	var records := get_view_records()
	for index: int in records.size():
		var record := records[index] as Dictionary
		if index == 3:
			await _send_key(KEY_F6, true, false)
			_append_transition("enable", "F6 key-down", manager, surfaces)
			if not _validate_grid_state(true, manager, surfaces):
				_fail_capture("F6 did not enable all 12 developer grids")
				return
		var expected_visible := String(record["state"]) == "on"
		if not _validate_grid_state(expected_visible, manager, surfaces):
			_fail_capture("grid state does not match %s" % record["basename"])
			return
		camera.fov = float(record["fov"])
		camera.global_position = record["position"] as Vector3
		camera.look_at(record["target"] as Vector3, Vector3.UP)
		camera.make_current()
		await get_tree().process_frame
		await get_tree().process_frame
		await RenderingServer.frame_post_draw
		var image := get_viewport().get_texture().get_image()
		if image == null or image.is_empty():
			_fail_capture("renderer returned no image for %s" % record["basename"])
			return
		if image.get_size() != CAPTURE_SIZE:
			image.resize(CAPTURE_SIZE.x, CAPTURE_SIZE.y, Image.INTERPOLATE_LANCZOS)
		var output_path := absolute_directory.path_join(String(record["basename"]))
		var save_error := image.save_png(output_path)
		if save_error != OK:
			_fail_capture("could not save %s: %s" % [output_path, error_string(save_error)])
			return
		captures.append(image)
		captured_records.append(record)
		print("F6_CAPTURE view=%s state=%s path=%s" % [record["label"], record["state"], output_path])

	await _send_key(KEY_F6, true, true)
	_append_transition("repeat_ignored", "F6 repeat", manager, surfaces)
	await _send_key(KEY_F6, false, false)
	_append_transition("release_ignored", "F6 key-up", manager, surfaces)
	await _send_key(KEY_F7, true, false)
	_append_transition("f7_ignored", "F7 key-down", manager, surfaces)
	if not _validate_grid_state(true, manager, surfaces):
		_fail_capture("repeat, key-up, or F7 changed the enabled F6 state")
		return
	await _send_key(KEY_F6, true, false)
	_append_transition("restore_off", "F6 key-down", manager, surfaces)
	if not _validate_grid_state(false, manager, surfaces):
		_fail_capture("final F6 did not restore the default OFF state")
		return

	var sheet := await _make_contact_sheet(captures, records)
	if sheet == null or sheet.is_empty():
		_fail_capture("could not render contact sheet")
		return
	var sheet_error := sheet.save_png(absolute_directory.path_join("contact_sheet.png"))
	if sheet_error != OK:
		_fail_capture("could not save contact sheet: %s" % error_string(sheet_error))
		return
	var manifest_error := _save_manifest(absolute_directory, captured_records)
	if manifest_error != OK:
		_fail_capture("could not save capture manifest: %s" % error_string(manifest_error))
		return
	var sequence_error := _save_transition_sequence(absolute_directory)
	if sequence_error != OK:
		_fail_capture("could not save transition sequence: %s" % error_string(sequence_error))
		return
	print("F6_CAPTURE_COMPLETE views=%d sheets=1 renderer=%s" % [captures.size(), RenderingServer.get_current_rendering_method()])
	get_tree().quit(0)


func _send_key(keycode: Key, pressed: bool, echo: bool) -> void:
	var event := InputEventKey.new()
	event.keycode = keycode
	event.pressed = pressed
	event.echo = echo
	Input.parse_input_event(event)
	await get_tree().process_frame
	await get_tree().physics_frame


func _append_transition(label: String, event: String, manager: Node, surfaces: Array) -> void:
	var visible_count := 0
	for value: Variant in surfaces:
		var surface := value as StorageSurface
		if surface != null and surface.is_developer_debug_visible():
			visible_count += 1
	_transition_sequence.append({
		"step": _transition_sequence.size(),
		"label": label,
		"event": event,
		"developer_override": bool(manager.call("is_developer_grid_visible")),
		"developer_visible_surface_count": visible_count,
		"surface_count": surfaces.size(),
	})


func _validate_grid_state(expected_visible: bool, manager: Node, surfaces: Array) -> bool:
	if bool(manager.call("is_developer_grid_visible")) != expected_visible:
		return false
	for value: Variant in surfaces:
		var surface := value as StorageSurface
		if surface == null or surface.is_developer_debug_visible() != expected_visible:
			return false
		var grid := surface.get_node_or_null("StorageDebugGrid") as MeshInstance3D
		var occupancy := surface.get_node_or_null("StorageDebugOccupancy") as Node3D
		if grid == null or occupancy == null:
			return false
		if grid.visible != expected_visible or occupancy.visible != expected_visible:
			return false
	return true


func _make_contact_sheet(captures: Array[Image], records: Array) -> Image:
	if captures.size() != records.size() or captures.size() != CONTACT_COLUMNS * CONTACT_ROWS:
		return null
	var viewport := SubViewport.new()
	viewport.size = CAPTURE_SIZE
	viewport.transparent_bg = false
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	add_child(viewport)
	var background := ColorRect.new()
	background.color = Color(0.025, 0.025, 0.025, 1.0)
	background.size = Vector2(CAPTURE_SIZE)
	viewport.add_child(background)
	for index: int in captures.size():
		var tile_origin := Vector2i(index % CONTACT_COLUMNS, index / CONTACT_COLUMNS) * CONTACT_TILE_SIZE
		var texture_rect := TextureRect.new()
		texture_rect.position = Vector2(tile_origin)
		texture_rect.size = Vector2(CONTACT_IMAGE_SIZE)
		texture_rect.texture = ImageTexture.create_from_image(captures[index])
		texture_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		viewport.add_child(texture_rect)
		var caption := Label.new()
		caption.position = Vector2(tile_origin + Vector2i(12, CONTACT_IMAGE_SIZE.y))
		caption.size = Vector2(CONTACT_TILE_SIZE.x - 24, CONTACT_TILE_SIZE.y - CONTACT_IMAGE_SIZE.y)
		caption.text = String((records[index] as Dictionary)["label"])
		caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		caption.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		caption.add_theme_color_override("font_color", Color(0.92, 0.94, 0.96, 1.0))
		caption.add_theme_font_size_override("font_size", 24)
		viewport.add_child(caption)
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	var sheet := viewport.get_texture().get_image()
	viewport.queue_free()
	return sheet


func _save_manifest(absolute_directory: String, records: Array[Dictionary]) -> Error:
	var serialized: Array[Dictionary] = []
	for record: Dictionary in records:
		serialized.append({
			"label": record["label"],
			"basename": record["basename"],
			"fixture": record["fixture"],
			"state": record["state"],
			"position": _vector(record["position"] as Vector3),
			"target": _vector(record["target"] as Vector3),
			"fov": record["fov"],
		})
	var fields := get_manifest_static_fields()
	var manifest := {
		"scene": fields["scene"],
		"gameplay_scene": fields["gameplay_scene"],
		"evidence_kind": fields["evidence_kind"],
		"code_revision": _git_revision(),
		"renderer": RenderingServer.get_current_rendering_method(),
		"capture_size": {"x": CAPTURE_SIZE.x, "y": CAPTURE_SIZE.y},
		"player_eye_reference": fields["player_eye_reference"],
		"source_hashes_sha256": _source_hashes(fields["source_hash_paths"] as PackedStringArray),
		"transition_sequence": _transition_sequence,
		"views": serialized,
	}
	return _write_json(absolute_directory.path_join("capture_manifest.json"), manifest)


func _save_transition_sequence(absolute_directory: String) -> Error:
	return _write_json(absolute_directory.path_join("transition_sequence.json"), {
		"description": "F6 OFF -> ON -> repeat/key-up/F7 ignored -> OFF",
		"steps": _transition_sequence,
	})


func _write_json(path: String, value: Variant) -> Error:
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return FileAccess.get_open_error()
	file.store_string(JSON.stringify(value, "\t") + "\n")
	file.close()
	return OK


func _source_hashes(paths: PackedStringArray) -> Dictionary:
	var result := {}
	for resource_path: String in paths:
		result[resource_path] = FileAccess.get_sha256(ProjectSettings.globalize_path(resource_path))
	return result


func _git_revision() -> String:
	var output: Array = []
	var exit_code := OS.execute("git", PackedStringArray(["rev-parse", "HEAD"]), output, true)
	return String(output[0]).strip_edges() if exit_code == 0 and not output.is_empty() else "unavailable"


func _view(
	label: String,
	basename: String,
	fixture: String,
	state: String,
	position: Vector3,
	target: Vector3
) -> Dictionary:
	return {
		"label": label,
		"basename": basename,
		"fixture": fixture,
		"state": state,
		"position": position,
		"target": target,
		"fov": 75.0,
	}


func _vector(value: Vector3) -> Dictionary:
	return {"x": value.x, "y": value.y, "z": value.z}


func _fail_capture(message: String) -> void:
	push_error("F6_CAPTURE_FAILED: %s" % message)
	get_tree().quit(1)
