extends Node3D

const OUTPUT_DIRECTORY := "res://reports/logistics_wing/storage_bridge/initial"
const CAPTURE_SIZE := Vector2i(1920, 1080)
const CONTACT_COLUMNS := 4
const CONTACT_ROWS := 3
const CONTACT_TILE_SIZE := Vector2i(480, 360)
const CONTACT_IMAGE_SIZE := Vector2i(480, 270)

var _prepared_state := "initial"


func _ready() -> void:
	if should_capture(OS.get_cmdline_user_args()):
		_capture_all.call_deferred()


func should_capture(user_arguments: PackedStringArray) -> bool:
	return user_arguments.has("--capture")


func get_output_directory() -> String:
	return OUTPUT_DIRECTORY


func get_view_records() -> Array:
	return [
		_view("Whole continuing wing plan", "whole_wing_plan.png", Vector3(10.0, 70.0, 0.0), Vector3(10.0, 0.0, 0.0), 55.0, false),
		_view("Saved table and loose-loot coverage", "table_loot_coverage.png", Vector3(-9.6, 3.2, -1.4), Vector3(-9.6, 0.95, 2.65)),
		_view("Gallery A metal shelf front", "gallery_a_fixture_front.png", Vector3(-2.28, 1.65, -4.2), Vector3(-2.28, 1.25, -7.2)),
		_view("Gallery A shelf height and ceiling", "gallery_a_fixture_height.png", Vector3(-2.28, 2.45, -5.0), Vector3(-2.28, 2.65, -7.2), 60.0),
		_view("Gallery B metal shelf front", "gallery_b_fixture_front.png", Vector3(14.0, 1.65, -10.6), Vector3(14.0, 1.25, -13.78)),
		_view("Gallery B shelf height and ceiling", "gallery_b_fixture_height.png", Vector3(14.0, 2.45, -11.25), Vector3(14.0, 2.65, -13.78), 60.0),
		_view("Gallery C ventilated locker front", "gallery_c_locker_front.png", Vector3(-1.35, 1.65, 5.9), Vector3(-1.35, 1.25, 9.0)),
		_view("Gallery C locker height and ceiling", "gallery_c_locker_height.png", Vector3(-1.35, 2.45, 6.75), Vector3(-1.35, 2.55, 9.0), 60.0),
		_view("Carried item and HUD", "carrying_hud.png", Vector3(-9.6, 1.72, -0.8), Vector3(-9.6, 1.0, 2.65), 75.0, true, "carrying"),
		_view("Two-item boxed-food stack in Gallery A", "stored_stack_gallery_a.png", Vector3(-2.28, 1.25, -5.0), Vector3(-2.28, 0.75, -7.2), 75.0, true, "stacked"),
		_view("Retrieved item transferred to Gallery B", "retrieval_transfer_gallery_b.png", Vector3(14.0, 1.25, -11.45), Vector3(14.0, 0.75, -13.78), 75.0, true, "transferred"),
	]


func get_manifest_static_fields() -> Dictionary:
	return {
		"scene": "res://gameplay/logistics_wing/review/wing_gameplay_capture.tscn",
		"gameplay_scene": "res://gameplay/logistics_wing/wing_gameplay.tscn",
		"evidence_kind": "continuing-wing-gameplay-foundation-initial",
		"source_hash_paths": PackedStringArray([
			"res://gameplay/logistics_wing/wing_gameplay.gd",
			"res://gameplay/logistics_wing/wing_gameplay.tscn",
			"res://gameplay/logistics_wing/wing_environment.gd",
			"res://gameplay/logistics_wing/wing_environment.tscn",
			"res://gameplay/logistics_wing/functional_fixtures.gd",
			"res://gameplay/logistics_wing/functional_fixtures.tscn",
			"res://gameplay/logistics_wing/development/seeded_storage_setup.tscn",
			"res://tools/asset_pipeline/tests/wing_storage_bridge_interaction_tests.gd",
		]),
	}


func _capture_all() -> void:
	var gameplay := get_node_or_null("Gameplay")
	var camera := get_node_or_null("CaptureCamera") as Camera3D
	var roof := get_node_or_null("Gameplay/Environment/Greybox/RoofVisuals") as Node3D
	if gameplay == null or camera == null or roof == null:
		_fail_capture("missing Gameplay, CaptureCamera, or RoofVisuals")
		return
	var absolute_directory := ProjectSettings.globalize_path(OUTPUT_DIRECTORY)
	var directory_error := DirAccess.make_dir_recursive_absolute(absolute_directory)
	if directory_error != OK:
		_fail_capture("could not create evidence directory: %s" % error_string(directory_error))
		return
	get_window().size = CAPTURE_SIZE
	await get_tree().process_frame
	await get_tree().process_frame
	var captures: Array[Image] = []
	var captured_records: Array = []
	var records := get_view_records()
	for value: Variant in records:
		var record := value as Dictionary
		if not await _prepare_state(String(record["state"])):
			_fail_capture("could not prepare state %s" % record["state"])
			return
		var hud := get_node_or_null("Gameplay/HUD") as CanvasLayer
		if hud != null:
			hud.visible = String(record["state"]) != "initial"
		var resolved := _resolve_camera_record(record)
		roof.visible = bool(resolved["ceiling_on"])
		camera.fov = float(resolved["fov"])
		camera.global_position = resolved["position"] as Vector3
		camera.look_at(resolved["target"] as Vector3, _camera_up(resolved))
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
		captured_records.append(resolved)
		print("GAMEPLAY_CAPTURE view=%s state=%s path=%s" % [record["label"], record["state"], output_path])
	roof.visible = true
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
		_fail_capture("could not save manifest: %s" % error_string(manifest_error))
		return
	print("GAMEPLAY_CAPTURE_COMPLETE views=%d sheets=1 renderer=%s" % [captures.size(), RenderingServer.get_current_rendering_method()])
	get_tree().quit(0)


func _resolve_camera_record(record: Dictionary) -> Dictionary:
	var resolved := record.duplicate(true)
	var state := String(record["state"])
	if state != "stacked" and state != "transferred":
		return resolved
	var surfaces := get_node("Gameplay").call("get_functional_surfaces") as Array
	var surface_index := 0 if state == "stacked" else 4
	var surface := surfaces[surface_index] as StorageSurface
	var stacks := (surface.get("_stacks") as Dictionary).values()
	if stacks.is_empty():
		return resolved
	var stack := stacks[0] as StorageStack
	if stack.entries.is_empty():
		return resolved
	var target := Vector3.ZERO
	for entry in stack.entries:
		target += entry.host.global_position
	target /= float(stack.entries.size())
	target.y += 0.12
	var front := surface.global_transform.basis.z.normalized()
	resolved["target"] = target
	resolved["position"] = target + front * 1.15 + Vector3.UP * 0.38
	resolved["fov"] = 52.0
	return resolved


func _prepare_state(target_state: String) -> bool:
	if target_state == _prepared_state:
		return true
	if _prepared_state == "initial":
		if not _pickup_seed(&"loot_000005"):
			return false
		_prepared_state = "carrying"
		await get_tree().process_frame
	if target_state == "carrying":
		return _prepared_state == "carrying"
	if _prepared_state == "carrying":
		if not _place_selected(0, "Food"):
			return false
		if not _pickup_seed(&"loot_000005"):
			return false
		if not _place_selected(0, "Food"):
			return false
		_prepared_state = "stacked"
		await get_tree().process_frame
	if target_state == "stacked":
		return _prepared_state == "stacked"
	if _prepared_state == "stacked":
		var surfaces := get_node("Gameplay").call("get_functional_surfaces") as Array
		var source := surfaces[0] as StorageSurface
		var stacks := (source.get("_stacks") as Dictionary).values()
		if stacks.size() != 1:
			return false
		var stack := stacks[0] as StorageStack
		if stack.entries.size() != 2:
			return false
		var upper := stack.entries[1].world_item as WorldItem
		var carried := get_node("Gameplay/Player/CarriedItems")
		if not upper.pickup_into(carried):
			return false
		if not _place_selected(4, "Food"):
			return false
		_prepared_state = "transferred"
		await get_tree().process_frame
	return _prepared_state == target_state


func _pickup_seed(item_id: StringName) -> bool:
	var seeds := get_node_or_null("Gameplay/DevelopmentSetup/SeedItems")
	var carried := get_node_or_null("Gameplay/Player/CarriedItems")
	if seeds == null or carried == null:
		return false
	for host: Node in seeds.get_children():
		if host.is_queued_for_deletion() or StringName(host.get("item_id")) != item_id:
			continue
		var world_item := host.get_node_or_null("WorldItem") as WorldItem
		if world_item != null:
			return world_item.pickup_into(carried)
	return false


func _place_selected(surface_index: int, category: String) -> bool:
	var gameplay := get_node("Gameplay")
	var surfaces := gameplay.call("get_functional_surfaces") as Array
	if surface_index < 0 or surface_index >= surfaces.size():
		return false
	var surface := surfaces[surface_index] as StorageSurface
	var carried := get_node("Gameplay/Player/CarriedItems")
	var controller := get_node("Gameplay/Player/StoragePlacementController") as StoragePlacementController
	var item := carried.get_selected_item() as ItemInstance
	if surface == null or controller == null or item == null:
		return false
	surface.set_zone_rect(category, Vector2i.ZERO, surface.get_grid_size() - Vector2i.ONE)
	var orientations := controller.call(
		"_entry_orientations_for_item",
		item,
		surface.get_semantic_orientation_quarter_turns()
	) as Array
	if orientations.is_empty():
		return false
	var fit := surface.find_zone_stack_or_empty_fit(
		item.get_storage_category(),
		orientations[0],
		orientations[1] if orientations.size() > 1 else null
	)
	controller.set("_current_surface", surface)
	controller.set("_current_fit", fit)
	controller.set("_manual_mode", false)
	return controller.place_selected()


func _make_contact_sheet(captures: Array[Image], records: Array) -> Image:
	if captures.size() != records.size() or captures.size() > CONTACT_COLUMNS * CONTACT_ROWS:
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
		caption.position = Vector2(tile_origin + Vector2i(8, CONTACT_IMAGE_SIZE.y))
		caption.size = Vector2(CONTACT_TILE_SIZE.x - 16, CONTACT_TILE_SIZE.y - CONTACT_IMAGE_SIZE.y)
		caption.text = "%02d  %s" % [index + 1, String((records[index] as Dictionary)["label"])]
		caption.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		caption.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		caption.add_theme_color_override("font_color", Color(0.92, 0.94, 0.96, 1.0))
		caption.add_theme_font_size_override("font_size", 18)
		viewport.add_child(caption)
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	var sheet := viewport.get_texture().get_image()
	viewport.queue_free()
	return sheet


func _save_manifest(absolute_directory: String, records: Array) -> Error:
	var serialized: Array = []
	for value: Variant in records:
		var record := value as Dictionary
		serialized.append({
			"label": record["label"],
			"basename": record["basename"],
			"position": _vector(record["position"] as Vector3),
			"target": _vector(record["target"] as Vector3),
			"fov": record["fov"],
			"ceiling_on": record["ceiling_on"],
			"state": record["state"],
		})
	var fields := get_manifest_static_fields()
	var manifest := {
		"scene": fields["scene"],
		"gameplay_scene": fields["gameplay_scene"],
		"evidence_kind": fields["evidence_kind"],
		"code_revision": _git_revision(),
		"renderer": RenderingServer.get_current_rendering_method(),
		"capture_size": {"x": CAPTURE_SIZE.x, "y": CAPTURE_SIZE.y},
		"source_hashes_sha256": _source_hashes(fields["source_hash_paths"] as PackedStringArray),
		"views": serialized,
	}
	var file := FileAccess.open(absolute_directory.path_join("capture_manifest.json"), FileAccess.WRITE)
	if file == null:
		return FileAccess.get_open_error()
	file.store_string(JSON.stringify(manifest, "\t") + "\n")
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
	position: Vector3,
	target: Vector3,
	fov: float = 75.0,
	ceiling_on: bool = true,
	state: String = "initial"
) -> Dictionary:
	return {
		"label": label,
		"basename": basename,
		"position": position,
		"target": target,
		"fov": fov,
		"ceiling_on": ceiling_on,
		"state": state,
	}


func _camera_up(record: Dictionary) -> Vector3:
	var direction := ((record["target"] as Vector3) - (record["position"] as Vector3)).normalized()
	return Vector3(0.0, 0.0, -1.0) if absf(direction.dot(Vector3.UP)) > 0.999 else Vector3.UP


func _vector(value: Vector3) -> Dictionary:
	return {"x": value.x, "y": value.y, "z": value.z}


func _fail_capture(message: String) -> void:
	push_error("GAMEPLAY_CAPTURE_FAILED: %s" % message)
	get_tree().quit(1)
