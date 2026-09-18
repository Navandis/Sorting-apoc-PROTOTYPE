extends Node3D

# This separate launch is the only candidate injection. Never writes scene state
# or changes the continuing setup's Fuel/Gloves/Pants eligibility guards.
const Catalog = preload("res://prototype_item_catalog.gd")
const OUTPUT := "res://reports/logistics_wing/content_maintenance/locker_fuel/initial/m02/capture"
var _label: Label
var _camera: Camera3D
var _directory := ""
var _records: Array[Dictionary] = []


func _ready() -> void:
	var args := OS.get_cmdline_user_args()
	if args.has("--capture-fuel") or args.has("--review-fuel"):
		_start.call_deferred(args.has("--capture-fuel"))


func _start(capture: bool) -> void:
	var gameplay := (load("res://gameplay/logistics_wing/wing_gameplay.tscn") as PackedScene).instantiate()
	add_child(gameplay)
	await get_tree().process_frame
	await get_tree().physics_frame
	var player := gameplay.get_node("Player") as Node3D
	var carried := player.get_node("CarriedItems") as CarriedItems
	var controller := player.get_node("StoragePlacementController") as StoragePlacementController
	_camera = player.get_node("Camera3D") as Camera3D
	player.global_position = Vector3(0.10, 0, -7.2)
	_camera.look_at(Vector3(-2.28, 1.30, -7.2), Vector3.UP)
	var surface := gameplay.get_node("FunctionalFixtures/SM_MetalShelves_GalleryA_West/StorageSurface_02") as StorageSurface
	surface.set_zone_rect("Fuel", Vector2i.ZERO, surface.grid_size - Vector2i.ONE)
	var definition := Catalog.get_definition_by_id(&"loot_000015")
	var host := definition.visual_scene.instantiate() as Node3D
	host.name = "PendingFuelMaintenanceCandidate"
	add_child(host)
	host.global_position = surface.global_position + Vector3(0, 0.018, 0)
	var world := WorldItem.new()
	host.add_child(world)
	world.configure(host, definition)
	var item := world.get_item_instance()
	var layer := CanvasLayer.new()
	add_child(layer)
	_label = Label.new()
	layer.add_child(_label)
	_label.position = Vector2(24, 20)
	_label.add_theme_font_size_override("font_size", 24)
	_label.add_theme_color_override("font_shadow_color", Color.BLACK)
	_label.add_theme_constant_override("shadow_offset_x", 2)
	_label.add_theme_constant_override("shadow_offset_y", 2)
	_label.text = "M02 Fuel maintenance candidate — HUMAN REVIEW PENDING\nTemporary review only; normal seed stays blocked. Use normal pickup, M/R/E and retrieval."
	if not capture:
		# Start within the ordinary pickup range and align body movement with
		# the view. These transforms affect this explicit review instance only.
		player.global_position = Vector3(-1.0, 0, -7.2)
		player.look_at(Vector3(-2.28, 0, -7.2), Vector3.UP)
		_camera.look_at(host.global_position + Vector3(0, 0.22, 0), Vector3.UP)
		player.set("_pitch", _camera.rotation.x)
		return
	player.process_mode = Node.PROCESS_MODE_DISABLED
	get_tree().create_timer(45.0).timeout.connect(func(): _fail("45-second capture deadline"))
	_directory = ProjectSettings.globalize_path(OUTPUT)
	var attempt := 1
	while DirAccess.dir_exists_absolute(_directory):
		attempt += 1
		_directory = ProjectSettings.globalize_path(OUTPUT + "_%02d" % attempt)
	if DirAccess.make_dir_recursive_absolute(_directory) != OK:
		_fail("cannot create capture directory")
		return
	get_window().size = Vector2i(1920, 1080)
	var normal_camera := _camera.global_transform
	_close_view(host.global_position)
	await _shot("01_current_source", "Current local source, canonical scale; loose pickup candidate", item)
	_camera.global_transform = normal_camera
	if not world.pickup_into(carried):
		_fail("pickup failed")
		return
	await _shot("02_carried", "Picked up through WorldItem; normal held presentation", item)
	for rotated: bool in [false, true]:
		var entry := controller.call("_entry_for_item", item, rotated) as StorageStack.Entry
		var fit := surface.find_manual_empty_fit(Vector3.ZERO, entry) if rotated else surface.find_zone_stack_or_empty_fit("Fuel", entry)
		controller.set("_current_surface", surface)
		controller.set("_current_fit", fit)
		controller.set("_manual_mode", rotated)
		controller.set("_rotated", rotated)
		if not controller.place_selected():
			_fail("placement failed")
			return
		var stored := surface.get_storage_stack(item.instance_id).entries[0]
		_close_view(stored.host.global_position)
		await _shot("04_manual_R90" if rotated else "03_native_auto", "Manual R90, 2x4 packing" if rotated else "Automatic native, 4x2 packing", item)
		if not stored.world_item.pickup_into(carried):
			_fail("retrieval failed")
			return
		await get_tree().process_frame
	_camera.global_transform = normal_camera
	await _shot("05_retrieved", "Retrieved original instance after both storage orientations", item)
	var manifest := {"human_review": "PENDING", "instance_id": item.instance_id, "source_sha256": FileAccess.get_sha256(definition.visual_scene.resource_path), "definition_sha256": FileAccess.get_sha256(definition.resource_path), "held_count_final": carried.get_item_count(), "stored_count_final": surface.get_stack_count(), "records": _records}
	var file := FileAccess.open(_directory.path_join("manifest.json"), FileAccess.WRITE)
	file.store_string(JSON.stringify(manifest, "\t") + "\n")
	file.close()
	print("PASS: Fuel maintenance capture complete")
	get_tree().quit(0)


func _close_view(position: Vector3) -> void:
	_camera.global_position = position + Vector3(1.25, 0.58, 0.95)
	_camera.look_at(position + Vector3(0, 0.22, 0), Vector3.UP)


func _shot(basename: String, description: String, item: ItemInstance) -> void:
	_label.text = "M02 Fuel maintenance candidate — HUMAN REVIEW PENDING\n" + description
	await get_tree().process_frame
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	var image := get_viewport().get_texture().get_image()
	if image.save_png(_directory.path_join(basename + ".png")) != OK:
		_fail("cannot save image")
		return
	_records.append({"file": basename + ".png", "description": description, "instance_id": item.instance_id, "camera_transform": str(_camera.global_transform), "fov": _camera.fov})
	print("FUEL_CAPTURE " + basename)


func _fail(message: String) -> void:
	push_error("Fuel maintenance review: " + message)
	get_tree().quit(1)
