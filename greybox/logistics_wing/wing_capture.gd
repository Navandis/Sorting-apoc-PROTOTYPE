extends Node3D

const OUTPUT_DIRECTORY := "res://reports/logistics_wing/greybox/compact_layout_slice_9"
const CAPTURE_SIZE := Vector2i(1920, 1080)
const CONTACT_TILE_SIZE := Vector2i(480, 360)
const CONTACT_IMAGE_SIZE := Vector2i(480, 270)
const CONTACT_CAPTION_HEIGHT := 90
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
		_view("Roof-off whole-wing overview", "overview_debug_topdown.png", Vector3(0.875, 51, 0.1833), Vector3(0.875, 0, 0.1833), 55.0, false, true),
		_view("Receiving flanked freight aperture and unchanged inset cage", "receiving_freight_aperture.png", Vector3(-24.964285714286, 1.7162851, 0.0), Vector3(-32.25, 1.2, 0.0), 75.0),
		_view("Translated Receiving apron", "receiving_apron.png", Vector3(-23.05, 1.7162851, 2.7), Vector3(-27.45, 1.4, -2.0), 75.0),
		_view("Narrow Receiving to Backlog threshold", "receiving_backlog_threshold.png", Vector3(-25.25, 1.7162851, 2.0), Vector3(-17.25, 1.4, 0.0), 75.0),
		_view("Framed shallow Expedition Dispatch annex", "dispatch_annex.png", Vector3(-24.964285714286, 1.7162851, -2.8), Vector3(-25, 1.0, -6.8), 75.0),
		_view("Backlog to Sorting turn sequence - approach", "backlog_sorting_approach.png", Vector3(-20.15, 1.7162851, 0.375), Vector3(-16.0, 1.4, 0.375), 75.0),
		_view("Backlog to Sorting turn sequence - threshold", "backlog_sorting_threshold.png", Vector3(-17.0, 1.7162851, 0.375), Vector3(-12.0, 1.4, 0.375), 75.0),
		_view("Backlog to Sorting turn sequence - departure", "backlog_sorting_departure.png", Vector3(-13.0, 1.7162851, 0.375), Vector3(-18.0, 1.4, 0.375), 75.0),
		_view("Shallow Sorting pocket and desk aid", "sorting_table.png", Vector3(-10.0, 1.7162851, 1.0), Vector3(-10.0, 1.0, -2.8), 75.0),
		_view("Sorting-side view through both junctions", "sorting_desk_freight_aperture.png", Vector3(-13.0, 1.7162851, 0.375), Vector3(-29.25, 1.2, 0.375), 75.0),
		_view("Sorting turn toward Storage", "sorting_storage_turn.png", Vector3(-10.0, 1.7162851, 1.0), Vector3(-1.0, 1.4, 3.0), 75.0),
		_view("Aligned A-east and B-west openings", "storage_ab_junction.png", Vector3(0.3, 1.7162851, -4.9), Vector3(10.5, 1.4, -4.9), 75.0),
		_view("Gallery A north-west alcove", "gallery_a_northwest.png", Vector3(-1.9, 1.7162851, -8.6), Vector3(-4.0, 1.4, -11.3), 75.0),
		_view("C to D sole secondary link and folded D-side return", "storage_cd_south.png", Vector3(9.0, 1.7162851, 13.3), Vector3(5.5, 1.4, 9.2), 75.0),
		_view("Gallery C side of the folded C/D perimeter", "storage_cd_folded_c.png", Vector3(0.0, 1.7162851, 12.5), Vector3(3.4, 1.4, 9.6), 75.0),
		_view("Roof-off local audit of the folded C/D wall chain", "storage_cd_folded_roofoff.png", Vector3(4.0, 15.0, 17.8), Vector3(4.0, 0.0, 12.8), 50.0, false),
		_view("Contracted main Storage hall", "storage_network.png", Vector3(10.0, 1.7162851, 3.0), Vector3(10.0, 1.4, 8.8), 75.0),
		_view("Main Storage to Incinerator", "incinerator_hall_mouth.png", Vector3(21.5, 1.7162851, 3.15), Vector3(21.5, 1.45, 13.55), 75.0),
		_view("Shared junction looking along the five-metre Medical corridor", "medical_approach.png", Vector3(5.0, 1.7162851, -8.15), Vector3(5.0, 1.4, -16.0), 75.0),
		_view("Roof-off Medical plan showing the five-metre corridor and support room", "medical_plan_roofoff.png", Vector3(2.3, 18.4, -15.5), Vector3(2.3, 0.0, -15.5), 50.0, false, false, true),
		_view("Arrival at the Medical room's south-east entrance", "medical_entrance.png", Vector3(5.0, 1.7162851, -13.25), Vector3(2.3, 1.4, -18.0), 75.0),
		_view("Inside Medical looking back along the continuous east wall", "medical_east_wall.png", Vector3(4.5, 1.7162851, -18.5), Vector3(5.6, 1.4, -11.5), 75.0),
		_view("Kitchen frontage from Gallery B", "kitchen_b_east.png", Vector3(12.8, 1.7162851, -7.8), Vector3(26.685, 1.35, -6.15), 75.0),
		_view("Kitchen straight corridor and west entrance", "kitchen_straight_corridor.png", Vector3(17.6, 1.7162851, -7.8), Vector3(26.685, 1.35, -6.15), 75.0),
		_view("Rotated Kitchen with its east frontage", "kitchen_service.png", Vector3(23.2, 1.7162851, -6.15), Vector3(26.685, 1.1, -6.15), 75.0),
		_view("Shortened Workshop approach", "workshop_approach.png", Vector3(-10.0, 1.7162851, 6.30), Vector3(-10.0, 1.4, 12.8), 75.0),
		_view("Workshop interface and staffed-core boundary", "workshop_service.png", Vector3(-10.5, 1.7162851, 14.1833), Vector3(-7.83, 1.0, 14.1833), 75.0),
		_view("Workshop west exit and Salvager neck", "workshop_salvager_approach_reveal.png", Vector3(-13.5, 1.7162851, 15.10), Vector3(-24.7, 1.4, 15.10), 75.0),
		_view("Salvager machine beyond the southward turn", "salvager_local.png", Vector3(-25.62, 1.7162851, 16.0), Vector3(-25.62, 1.4, 19.1), 75.0),
		_view("Roof-off Salvager enclosure and rear-clearance audit", "salvager_rear_clearance.png", Vector3(-31.0, 10.0, 24.4), Vector3(-25.62, 0.8, 19.8666), 50.0, false),
		_view("Straight link from Main Storage to Ops", "ops_short_link.png", Vector3(24.5, 1.7162851, 2.30), Vector3(32.5, 1.4, 2.30), 75.0),
		_view("Ops west doorway and return to Main Storage", "ops_link_return.png", Vector3(31.3, 1.7162851, 2.30), Vector3(24, 1.4, 2.30), 75.0),
		_view("Relocated Incinerator frontage", "incinerator.png", Vector3(21.5, 1.7162851, 9.4), Vector3(21.5, 1.45, 13.55), 75.0),
		_view("Bunker Ops frontage and north staffed-core boundary", "bunker_ops_landing.png", Vector3(30.35, 1.7162851, 2.30), Vector3(32.5, 1.15, -2.35), 75.0),
		_view("Separate east settlement closure", "bunker_ops_door.png", Vector3(32.5, 1.7162851, 1.0), Vector3(36, 1.45, 1.0), 75.0),
		_view("Ceiling transition sequence - Receiving approach", "ceiling_transition_approach.png", Vector3(-24.964285714286, 1.7162851, 0.0), Vector3(-21.75, 3.8, 0.0), 75.0),
		_view("Ceiling transition sequence - threshold", "ceiling_transition_threshold.png", Vector3(-22.95, 1.7162851, 0.0), Vector3(-21.75, 3.8, 0.0), 75.0),
		_view("Ceiling transition sequence - Backlog departure", "ceiling_transition_departure.png", Vector3(-20.05, 1.7162851, 0.0), Vector3(-21.75, 3.8, 0.0), 75.0),
	]


func get_manifest_static_fields() -> Dictionary:
	return {
		"layout_revision": "logistics-wing-compact-layout-slice-9",
		"source_hash_paths": PackedStringArray([
			"res://greybox/logistics_wing/build_wing_geometry.gd",
			"res://greybox/logistics_wing/wing_geometry.tscn",
			"res://greybox/logistics_wing/wing_capture.gd",
			"res://greybox/logistics_wing/wing_traversal.gd",
			"res://greybox/logistics_wing/wing_review.tscn",
			"res://tools/asset_pipeline/tests/logistics_wing_geometry_tests.gd",
			"res://tools/asset_pipeline/tests/logistics_wing_capture_tests.gd",
			"res://tools/asset_pipeline/tests/logistics_wing_traversal_tests.gd",
		]),
		"final_commit_relation": "Evidence revision is the Git HEAD used for capture; the final validation records whether the handoff commit is identical or a documentation-only descendant.",
	}


func frame_overview_record(record: Dictionary, geometry_aabb: AABB) -> Dictionary:
	var framed := record.duplicate(true)
	var center := geometry_aabb.get_center()
	var vertical_half_angle := deg_to_rad(float(record["fov"]) * 0.5)
	var horizontal_half_angle := atan(tan(vertical_half_angle) * float(CAPTURE_SIZE.x) / float(CAPTURE_SIZE.y))
	var half_width := geometry_aabb.size.x * 0.5 + 2.0
	var half_depth := geometry_aabb.size.z * 0.5 + 2.0
	var required_height := maxf(half_width / tan(horizontal_half_angle), half_depth / tan(vertical_half_angle))
	framed["position"] = Vector3(center.x, geometry_aabb.end.y + required_height + 2.0, center.z)
	framed["target"] = Vector3(center.x, 0.0, center.z)
	return framed


func get_capture_basenames() -> Array:
	var basenames: Array = []
	for record: Dictionary in get_view_records():
		basenames.append(String(record["basename"]))
	var sheet_count := ceili(float(get_view_records().size()) / float(CONTACT_COLUMNS * CONTACT_ROWS))
	for sheet_index: int in sheet_count:
		basenames.append("contact_sheet_%02d.png" % (sheet_index + 1))
	return basenames


func normalize_capture_image(image: Image) -> Image:
	if image.get_size() != CAPTURE_SIZE:
		image.resize(CAPTURE_SIZE.x, CAPTURE_SIZE.y, Image.INTERPOLATE_LANCZOS)
	return image


func get_contact_tile_layout() -> Dictionary:
	return {
		"tile_size": CONTACT_TILE_SIZE,
		"image_size": CONTACT_IMAGE_SIZE,
		"caption_origin_y": CONTACT_IMAGE_SIZE.y,
		"caption_height": CONTACT_CAPTION_HEIGHT,
	}


func get_camera_up_vector(record: Dictionary) -> Vector3:
	var position := record.get("position", Vector3.ZERO) as Vector3
	var target := record.get("target", Vector3.ZERO) as Vector3
	var direction := (target - position).normalized()
	if absf(direction.dot(Vector3.UP)) > 0.999:
		return Vector3(0, 0, -1)
	return Vector3(0, 0, -1) if bool(record.get("overview", false)) else Vector3.UP


func fit_capture_into_contact_image(source_size: Vector2i) -> Rect2i:
	if source_size.x <= 0 or source_size.y <= 0:
		return Rect2i()
	var scale := minf(float(CONTACT_IMAGE_SIZE.x) / float(source_size.x), float(CONTACT_IMAGE_SIZE.y) / float(source_size.y))
	var fitted := Vector2i(roundi(float(source_size.x) * scale), roundi(float(source_size.y) * scale))
	var offset := (CONTACT_IMAGE_SIZE - fitted) / 2
	return Rect2i(offset, fitted)


func make_contact_sheets(captures: Array[Image], records: Array) -> Array:
	if captures.size() != records.size():
		return []
	var sheets: Array[Image] = []
	var per_sheet := CONTACT_COLUMNS * CONTACT_ROWS
	for sheet_index: int in ceili(float(captures.size()) / float(per_sheet)):
		var viewport := SubViewport.new()
		viewport.size = CAPTURE_SIZE
		viewport.transparent_bg = false
		viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
		add_child(viewport)
		var background := ColorRect.new()
		background.color = Color(0.025, 0.025, 0.025, 1.0)
		background.size = Vector2(CAPTURE_SIZE)
		viewport.add_child(background)
		for local_index: int in per_sheet:
			var capture_index := sheet_index * per_sheet + local_index
			if capture_index >= captures.size():
				break
			var tile_origin := Vector2i(local_index % CONTACT_COLUMNS, local_index / CONTACT_COLUMNS) * CONTACT_TILE_SIZE
			var image_rect := fit_capture_into_contact_image((captures[capture_index] as Image).get_size())
			var texture_rect := TextureRect.new()
			texture_rect.position = Vector2(tile_origin + image_rect.position)
			texture_rect.size = Vector2(image_rect.size)
			texture_rect.texture = ImageTexture.create_from_image(captures[capture_index] as Image)
			texture_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			viewport.add_child(texture_rect)
			var caption := Label.new()
			caption.position = Vector2(tile_origin + Vector2i(8, CONTACT_IMAGE_SIZE.y))
			caption.size = Vector2(CONTACT_TILE_SIZE.x - 16, CONTACT_CAPTION_HEIGHT)
			caption.text = "%02d  %s" % [capture_index + 1, String((records[capture_index] as Dictionary)["label"])]
			caption.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			caption.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
			caption.add_theme_color_override("font_color", Color(0.92, 0.94, 0.96, 1.0))
			caption.add_theme_font_size_override("font_size", 18)
			viewport.add_child(caption)
		await get_tree().process_frame
		await RenderingServer.frame_post_draw
		var sheet := viewport.get_texture().get_image()
		sheets.append(sheet)
		viewport.queue_free()
		await get_tree().process_frame
	return sheets


func _capture_all() -> void:
	var roof := get_node_or_null("Review/Geometry/RoofVisuals") as Node3D
	var geometry := get_node_or_null("Review/Geometry") as Node3D
	var camera := get_node_or_null("CaptureCamera") as Camera3D
	var orientation_aids := get_node_or_null("Review/OrientationAids") as Node3D
	if roof == null or geometry == null or camera == null or orientation_aids == null:
		_fail_capture("missing Geometry, RoofVisuals, OrientationAids, or CaptureCamera")
		return
	var geometry_aabb := _compute_geometry_aabb(geometry)
	if geometry_aabb.size == Vector3.ZERO:
		_fail_capture("could not compute geometry bounds")
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
	records[0] = frame_overview_record(records[0] as Dictionary, geometry_aabb)
	var captures: Array[Image] = []
	for record: Dictionary in records:
		roof.visible = bool(record["ceiling_on"])
		orientation_aids.visible = bool(record["overview"]) or bool(record.get("show_orientation_aids", false))
		camera.fov = float(record["fov"])
		camera.global_position = record["position"] as Vector3
		var up := get_camera_up_vector(record)
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
	var sheets := await make_contact_sheets(captures, records)
	for index: int in sheets.size():
		var sheet_path := absolute_directory.path_join("contact_sheet_%02d.png" % (index + 1))
		var sheet_error := (sheets[index] as Image).save_png(sheet_path)
		if sheet_error != OK:
			_fail_capture("could not save contact sheet: " + error_string(sheet_error))
			return
		print("CAPTURE contact_sheet=" + sheet_path)
	var manifest_error := _save_manifest(absolute_directory, records, geometry_aabb)
	if manifest_error != OK:
		_fail_capture("could not save capture manifest: " + error_string(manifest_error))
		return
	print("CAPTURE_COMPLETE views=%d sheets=%d renderer=%s" % [captures.size(), sheets.size(), RenderingServer.get_current_rendering_method()])
	get_tree().quit(0)


func _save_manifest(absolute_directory: String, records: Array, geometry_aabb: AABB) -> Error:
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
			"show_orientation_aids": record.get("show_orientation_aids", false),
		})
	var manifest := {
		"scene": "res://greybox/logistics_wing/wing_capture.tscn",
		"review_scene": "res://greybox/logistics_wing/wing_review.tscn",
		"layout_revision": "logistics-wing-compact-layout-slice-9",
		"code_revision": _git_revision(),
		"evidence_revision": _git_revision(),
		"final_commit_relation": String(get_manifest_static_fields()["final_commit_relation"]),
		"source_hashes_sha256": _source_hashes(),
		"renderer": RenderingServer.get_current_rendering_method(),
		"capture_size": {"x": CAPTURE_SIZE.x, "y": CAPTURE_SIZE.y},
		"contact_tile_size": {"x": CONTACT_TILE_SIZE.x, "y": CONTACT_TILE_SIZE.y},
		"contact_image_size": {"x": CONTACT_IMAGE_SIZE.x, "y": CONTACT_IMAGE_SIZE.y},
		"contact_caption_height": CONTACT_CAPTION_HEIGHT,
		"actual_geometry_aabb_m": {
			"position": _vector(geometry_aabb.position),
			"size": _vector(geometry_aabb.size),
			"end": _vector(geometry_aabb.end),
		},
		"views": serialized_views,
	}
	var file := FileAccess.open(absolute_directory.path_join("capture_manifest.json"), FileAccess.WRITE)
	if file == null:
		return FileAccess.get_open_error()
	file.store_string(JSON.stringify(manifest, "\t") + "\n")
	file.close()
	return OK


func _view(label: String, basename: String, position: Vector3, target: Vector3, fov: float, ceiling_on: bool = true, overview: bool = false, show_orientation_aids: bool = false) -> Dictionary:
	return {
		"label": label,
		"basename": basename,
		"position": position,
		"target": target,
		"fov": fov,
		"ceiling_on": ceiling_on,
		"overview": overview,
		"show_orientation_aids": show_orientation_aids,
	}


func _vector(value: Vector3) -> Dictionary:
	return {"x": value.x, "y": value.y, "z": value.z}


func _git_revision() -> String:
	var output: Array = []
	var exit_code := OS.execute("git", PackedStringArray(["rev-parse", "HEAD"]), output, true)
	if exit_code != 0 or output.is_empty():
		return "unavailable"
	return String(output[0]).strip_edges()


func _source_hashes() -> Dictionary:
	var hashes := {}
	for resource_path: String in get_manifest_static_fields()["source_hash_paths"] as PackedStringArray:
		hashes[resource_path] = FileAccess.get_sha256(ProjectSettings.globalize_path(resource_path))
	return hashes


func _compute_geometry_aabb(root: Node) -> AABB:
	var bounds := AABB()
	var has_bounds := false
	var pending: Array[Node] = [root]
	while not pending.is_empty():
		var node := pending.pop_back() as Node
		if node is MeshInstance3D:
			var mesh_instance := node as MeshInstance3D
			if mesh_instance.mesh != null:
				var mesh_bounds := mesh_instance.global_transform * mesh_instance.mesh.get_aabb()
				if not has_bounds:
					bounds = mesh_bounds
					has_bounds = true
				else:
					bounds = bounds.merge(mesh_bounds)
		for child: Node in node.get_children():
			pending.append(child)
	return bounds


func _fail_capture(message: String) -> void:
	push_error("CAPTURE_FAILED: " + message)
	get_tree().quit(1)
