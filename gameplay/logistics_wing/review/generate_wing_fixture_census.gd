extends SceneTree

const GAMEPLAY_PATH := "res://gameplay/logistics_wing/wing_gameplay.tscn"
const OUTPUT_PATH := "res://reports/logistics_wing/storage_bridge/initial/fixture_census.json"
const CEILING_UNDERSIDE_Y_M := 3.40
const FIXTURE_NAMES := [
	"SM_MetalShelves_GalleryA_West",
	"SM_MetalShelves_GalleryB_North",
	"SM_ventilated_locker_GalleryC_West",
]
const PROXY_NAMES := ["GalleryA_West", "GalleryB_North", "GalleryC_West"]


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var packed := load(GAMEPLAY_PATH) as PackedScene
	if packed == null:
		_fail("continuing gameplay scene could not be loaded")
		return
	var scene := packed.instantiate()
	# The census has no rendering purpose; suppress the viewmodel before the
	# player's ready hook so ownership transitions stay renderer-quiet headlessly.
	scene.get_node("Player").set("enable_held_item_view", false)
	root.add_child(scene)
	current_scene = scene
	await process_frame
	await physics_frame
	var surfaces := scene.call("get_functional_surfaces") as Array
	if surfaces.size() != 12:
		_fail("expected 12 storage surfaces, found %d" % surfaces.size())
		return
	var report := {
		"schema_version": "1.0",
		"scene": GAMEPLAY_PATH,
		"code_revision": _git_revision(),
		"default_scene_uid": String(ProjectSettings.get_setting("application/run/main_scene", "")),
		"development_setup_enabled": bool(scene.get("development_setup_enabled")),
		"ceiling_underside_y_m": CEILING_UNDERSIDE_Y_M,
		"fixture_count": FIXTURE_NAMES.size(),
		"surface_count": surfaces.size(),
		"fixtures": _fixture_records(scene, surfaces),
		"proxies": _proxy_records(scene),
		"tables": _table_records(scene),
		"seed_items": _seed_records(scene),
		"initial_ownership": _owner_census(scene, surfaces),
	}
	var transaction := _exercise_transfer(scene, surfaces)
	if not bool(transaction.get("valid", false)):
		_fail("identity transfer transaction failed")
		return
	report["identity_transfer_transaction"] = transaction
	var absolute_output := ProjectSettings.globalize_path(OUTPUT_PATH)
	var directory_error := DirAccess.make_dir_recursive_absolute(absolute_output.get_base_dir())
	if directory_error != OK:
		_fail("could not create census directory: %s" % error_string(directory_error))
		return
	var file := FileAccess.open(absolute_output, FileAccess.WRITE)
	if file == null:
		_fail("could not open census output: %s" % error_string(FileAccess.get_open_error()))
		return
	file.store_string(JSON.stringify(report, "\t") + "\n")
	file.close()
	print("PASS: wing fixture census generated at %s" % absolute_output)
	scene.free()
	current_scene = null
	quit(0)


func _fixture_records(scene: Node, surfaces: Array) -> Array:
	var records: Array = []
	var root_node := scene.get_node("FunctionalFixtures")
	for fixture_name: String in FIXTURE_NAMES:
		var fixture := root_node.get_node(fixture_name) as Node3D
		var context := fixture.get_node("StorageShelfClearanceContext")
		var own_surfaces: Array = []
		for value: Variant in surfaces:
			var surface := value as StorageSurface
			if surface.get_parent() == fixture:
				own_surfaces.append(surface)
		own_surfaces.sort_custom(
			func(a: StorageSurface, b: StorageSurface) -> bool:
				return a.global_position.y < b.global_position.y
		)
		var serialized_surfaces: Array = []
		for surface: StorageSurface in own_surfaces:
			serialized_surfaces.append({
				"surface_id": String(surface.surface_id),
				"grid_size": _vector2i(surface.get_grid_size()),
				"cell_size_m": surface.get_cell_size_m(),
				"usable_size_m": _vector2(surface.get_usable_size_m()),
				"global_y_m": surface.global_position.y,
				"stack_clearance_m": surface.stack_clearance_m,
				"zones_initialized": surface.are_zones_initialized(),
				"reservation_count": surface.get_reservation_count(),
				"stack_count": surface.get_stack_count(),
			})
		var top_surface := own_surfaces[own_surfaces.size() - 1] as StorageSurface
		var cap := float(context.get("open_top_clearance_world_m"))
		var ceiling_available := CEILING_UNDERSIDE_Y_M - top_surface.global_position.y
		records.append({
			"name": fixture_name,
			"scene_file_path": fixture.scene_file_path,
			"position_m": _vector3(fixture.position),
			"rotation_degrees": _vector3(fixture.rotation_degrees),
			"scale": _vector3(fixture.scale),
			"surface_count": own_surfaces.size(),
			"surfaces": serialized_surfaces,
			"open_top_cap_m": cap,
			"top_surface_global_y_m": top_surface.global_position.y,
			"ceiling_available_m": ceiling_available,
			"construction_margin_m": ceiling_available - cap,
			"cap_within_ceiling": cap <= ceiling_available,
		})
	return records


func _proxy_records(scene: Node) -> Array:
	var records: Array = []
	for proxy_name: String in PROXY_NAMES:
		var mesh_path := "Environment/Greybox/Proxies/%s/Mesh" % proxy_name
		var shape_path := "Environment/Greybox/Proxies/%s/StaticBody3D/CollisionShape3D" % proxy_name
		var mesh := scene.get_node(mesh_path) as MeshInstance3D
		var shape := scene.get_node(shape_path) as CollisionShape3D
		records.append({
			"proxy_name": proxy_name,
			"mesh_path": mesh_path,
			"mesh_visible": mesh.visible,
			"collider_path": shape_path,
			"collider_disabled": shape.disabled,
		})
	return records


func _table_records(scene: Node) -> Array:
	var records: Array = []
	for child: Node in scene.get_node("DevelopmentSetup/Tables").get_children():
		if child is Node3D and String(child.name).begins_with("SM_Table"):
			var table := child as Node3D
			records.append({
				"name": String(table.name),
				"scene_file_path": table.scene_file_path,
				"position_m": _vector3(table.position),
				"rotation_degrees": _vector3(table.rotation_degrees),
				"scale": _vector3(table.scale),
				"storage_surface_descendant_count": _count_type(table, StorageSurface),
			})
	return records


func _seed_records(scene: Node) -> Array:
	var records: Array = []
	for host: Node in scene.get_node("DevelopmentSetup/SeedItems").get_children():
		var visual := host.call("get_authored_visual") as Node3D
		var world_item := host.get_node("WorldItem") as WorldItem
		var item := world_item.get_item_instance() as ItemInstance
		records.append({
			"host_name": String(host.name),
			"item_id": StringName(host.get("item_id")),
			"instance_id": item.instance_id,
			"position_m": _vector3((host as Node3D).position),
			"rotation_degrees": _vector3((host as Node3D).rotation_degrees),
			"scale": _vector3((host as Node3D).scale),
			"visual_scene_path": visual.scene_file_path,
			"runtime_owner": "loose_world_host",
		})
	return records


func _exercise_transfer(scene: Node, surfaces: Array) -> Dictionary:
	var host: Node3D = null
	for child: Node in scene.get_node("DevelopmentSetup/SeedItems").get_children():
		if String(child.name) == "CerealBox_A":
			host = child as Node3D
			break
	if host == null:
		return {"valid": false}
	var carried := scene.get_node("Player/CarriedItems")
	var controller := scene.get_node("Player/StoragePlacementController") as StoragePlacementController
	var source := surfaces[0] as StorageSurface
	var destination := surfaces[4] as StorageSurface
	var world_item := host.get_node("WorldItem") as WorldItem
	var item := world_item.get_item_instance() as ItemInstance
	var identity := item.instance_id
	var snapshots := {"before": _owner_census(scene, surfaces)}
	if not world_item.pickup_into(carried):
		return {"valid": false}
	snapshots["after_pickup"] = _owner_census(scene, surfaces)
	var pickup_identity_same: bool = carried.get_selected_item() == item
	if not _place_selected(controller, carried, source, item):
		return {"valid": false}
	snapshots["after_first_store"] = _owner_census(scene, surfaces)
	var first_stack := source.get_storage_stack(source.get_stack_id_for_item(identity))
	var stored_identity_same := first_stack != null and first_stack.entries[0].item == item
	if first_stack == null or not (first_stack.entries[0].world_item as WorldItem).pickup_into(carried):
		return {"valid": false}
	snapshots["after_retrieval"] = _owner_census(scene, surfaces)
	var retrieved_identity_same: bool = carried.get_selected_item() == item
	if not _place_selected(controller, carried, destination, item):
		return {"valid": false}
	snapshots["after_transfer"] = _owner_census(scene, surfaces)
	var final_stack := destination.get_storage_stack(destination.get_stack_id_for_item(identity))
	var transferred_identity_same := final_stack != null and final_stack.entries[0].item == item
	return {
		"valid": (
			pickup_identity_same
			and stored_identity_same
			and retrieved_identity_same
			and transferred_identity_same
		),
		"instance_id": identity,
		"source_surface_id": String(source.surface_id),
		"destination_surface_id": String(destination.surface_id),
		"pickup_identity_same_reference": pickup_identity_same,
		"stored_identity_same_reference": stored_identity_same,
		"retrieved_identity_same_reference": retrieved_identity_same,
		"transferred_identity_same_reference": transferred_identity_same,
		"snapshots": snapshots,
	}


func _place_selected(
	controller: StoragePlacementController,
	carried: Node,
	surface: StorageSurface,
	item: ItemInstance
) -> bool:
	surface.set_zone_rect(item.get_storage_category(), Vector2i.ZERO, surface.get_grid_size() - Vector2i.ONE)
	var orientations := controller.call(
		"_entry_orientations_for_item",
		item,
		surface.get_semantic_orientation_quarter_turns()
	) as Array
	var fit := surface.find_zone_stack_or_empty_fit(
		item.get_storage_category(),
		orientations[0],
		orientations[1] if orientations.size() > 1 else null
	)
	controller.set("_current_surface", surface)
	controller.set("_current_fit", fit)
	controller.set("_manual_mode", false)
	return controller.place_selected()


func _owner_census(scene: Node, surfaces: Array) -> Dictionary:
	var ids: Dictionary = {}
	var loose := 0
	var carried_count := 0
	var stored := 0
	for host: Node in scene.get_node("DevelopmentSetup/SeedItems").get_children():
		var world_item := host.get_node_or_null("WorldItem") as WorldItem
		if world_item == null or host.is_queued_for_deletion():
			continue
		var item := world_item.get_item_instance() as ItemInstance
		ids[item.instance_id] = true
		loose += 1
	for value: Variant in scene.get_node("Player/CarriedItems").get_items():
		var item := value as ItemInstance
		ids[item.instance_id] = true
		carried_count += 1
	for value: Variant in surfaces:
		var surface := value as StorageSurface
		for stack_value: Variant in (surface.get("_stacks") as Dictionary).values():
			var stack := stack_value as StorageStack
			for entry in stack.entries:
				ids[entry.item.instance_id] = true
				stored += 1
	return {
		"loose": loose,
		"carried": carried_count,
		"stored": stored,
		"total": loose + carried_count + stored,
		"unique_instance_ids": ids.size(),
	}


func _count_type(node: Node, expected_type: Variant) -> int:
	var count := 1 if is_instance_of(node, expected_type) else 0
	for child: Node in node.get_children():
		count += _count_type(child, expected_type)
	return count


func _git_revision() -> String:
	var output: Array = []
	var exit_code := OS.execute("git", PackedStringArray(["rev-parse", "HEAD"]), output, true)
	return String(output[0]).strip_edges() if exit_code == 0 and not output.is_empty() else "unavailable"


func _vector2(value: Vector2) -> Dictionary:
	return {"x": value.x, "y": value.y}


func _vector2i(value: Vector2i) -> Dictionary:
	return {"x": value.x, "y": value.y}


func _vector3(value: Vector3) -> Dictionary:
	return {"x": value.x, "y": value.y, "z": value.z}


func _fail(message: String) -> void:
	push_error("WING_FIXTURE_CENSUS_FAILED: %s" % message)
	quit(1)
