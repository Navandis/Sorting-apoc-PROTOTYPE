extends SceneTree

# Detects legal grid/placements crossing either measured support X edge.
# These mesh-level measurements are valid only for this exact source export;
# they are not aggregate bounds or movement-collider approximations.
const LOCKER_PATH := "res://assets/environment/furniture/storage/SM_ventilated_locker.glb"
const LOCKER_SHA := "0d1c9a54532ca71ebba71c3b05fa31980a03c7f43c18189720cd3c9de7159c6e"
const BACK_X := -0.390274
const SUPPORT_TOP_Y := 1.116512
const SUPPORT_FRONT_X := 0.367064
const SUPPORT_Z := Vector2(-0.718901, 0.718882)
const TOLERANCE := 0.00002
const ITEM_EDGE_TOLERANCE := 0.0005
const LOCKER_Y := [0.141785, 1.093458, 1.733424, 2.224432]
const METAL_Y := [0.311587, 1.133633, 2.005589, 2.851123]
var _failed := false


func _init() -> void:
	_run.call_deferred()


func _run() -> void:
	_check(FileAccess.get_sha256(LOCKER_PATH) == LOCKER_SHA, "measured interior is bound to actual local locker SHA-256")
	await _scene_case("res://gameplay/logistics_wing/wing_gameplay.tscn", true)
	await _scene_case("res://main.tscn", false)
	if not _failed:
		print("PASS: locker level2 calibration tests")
	quit(1 if _failed else 0)


func _scene_case(path: String, wing: bool) -> void:
	var scene := (load(path) as PackedScene).instantiate()
	var player := scene.get_node("Player" if wing else "CharacterBody3D")
	player.set("enable_held_item_view", false)
	root.add_child(scene)
	current_scene = scene
	await process_frame
	await physics_frame
	player.process_mode = Node.PROCESS_MODE_DISABLED
	var carried := player.get_node("CarriedItems") as CarriedItems
	var controller := player.get_node("StoragePlacementController") as StoragePlacementController
	var surfaces: Array[StorageSurface] = []
	_collect(scene, surfaces)
	_check(surfaces.size() == (12 if wing else 16), "installed surface count unchanged")
	for surface: StorageSurface in surfaces:
		_check(surface.global_basis.get_scale().is_equal_approx(Vector3.ONE), "installed surface retains unit world scale")
		_check(absf(surface.cell_size_m - 0.1) < TOLERANCE, "world cell size remains 0.1m")
		var shelf := surface.get_parent() as Node3D
		var level := int(String(surface.surface_id).get_slice("_level_", 1)) - 1
		var shelf_scale := shelf.global_basis.get_scale()
		var local_center := shelf.to_local(surface.global_position)
		if String(shelf.name).begins_with("SM_MetalShelves"):
			_check(surface.get_grid_size() == (Vector2i(4, 29) if shelf.name == &"SM_MetalShelves2" else Vector2i(10, 29)), "metal capacity unchanged")
			_check(absf(local_center.y - (METAL_Y[level] - 0.018 + 0.018 / shelf_scale.y)) < TOLERANCE, "metal level height unchanged")
			continue
		if not String(shelf.name).begins_with("SM_ventilated_locker"):
			continue
		var scaled := shelf.name == &"SM_ventilated_locker"
		var expected_origin := Vector3(-1.35, 0, 9) if wing else (Vector3(0.80279386, 0.074747086, 0.444) if scaled else Vector3(0.80263567, 0.04006219, 2.0317678))
		_check(shelf.global_position.distance_to(expected_origin) < TOLERANCE, "locker fixture position unchanged")
		_check(shelf.global_basis.is_equal_approx(Basis.IDENTITY.scaled(Vector3.ONE * (0.655 if scaled else 1.0))), "locker fixture orientation and scale unchanged")
		var expected_grid := Vector2i(5, 8) if scaled else Vector2i(8, 13)
		if level == 1:
			expected_grid.x -= 1
		_check(surface.get_grid_size() == expected_grid, "level 2 loses only one X cell; other locker capacities unchanged")
		_check(absf(local_center.y - (LOCKER_Y[level] - 0.018 + 0.018 / shelf_scale.y)) < TOLERANCE, "locker level height unchanged")
		_check(absf(local_center.z - (-0.043877 if level in [1, 2] else 0.000013)) < TOLERANCE, "locker Z alignment unchanged")
		if level != 1:
			_check(absf(local_center.x - 0.006182) < TOLERANCE, "other locker level X alignment unchanged")
		print("SURFACE id=%s world=%s local=%s grid=%s usable=%s back_world=%s support_world=%s" % [surface.surface_id, surface.global_position, local_center, surface.grid_size, surface.usable_size_m, shelf.to_global(Vector3(BACK_X, SUPPORT_TOP_Y, 0)), shelf.to_global(Vector3(SUPPORT_FRONT_X, SUPPORT_TOP_Y, 0))])
		# Every level gets a real native placement/retrieval loop. The measured
		# level-2 regression additionally covers rear ends, auto, and R packing.
		if level == 1:
			var rear_grid_world := surface.to_global(Vector3(-surface.usable_size_m.x * 0.5, 0, 0))
			var rear_grid_local := shelf.to_local(rear_grid_world)
			var front_grid_local := shelf.to_local(surface.to_global(Vector3(surface.usable_size_m.x * 0.5, 0, 0)))
			print("GRID_X shelf=%s rear_shelf=%.6f front_shelf=%.6f rear_clearance_world_m=%.6f front_clearance_world_m=%.6f" % [shelf.name, rear_grid_local.x, front_grid_local.x, (rear_grid_local.x - BACK_X) * shelf_scale.x, (SUPPORT_FRONT_X - front_grid_local.x) * shelf_scale.x])
			_check(rear_grid_local.x >= BACK_X - TOLERANCE, "PHYSICAL quantized rear grid boundary must clear measured inner back panel")
			_check(front_grid_local.x <= SUPPORT_FRONT_X + TOLERANCE, "PHYSICAL quantized front grid boundary must remain inside measured support front edge")
			for rotated: bool in [false, true]:
				for far_end: bool in [false, true]:
					await _placement(surface, carried, controller, "loot_000022", rotated, far_end, false, true)
					await _placement(surface, carried, controller, "loot_000022", rotated, far_end, false, true, true)
			for rotated: bool in [false, true]:
				await _placement(surface, carried, controller, "loot_000030", rotated, false, false, true)
				for far_end: bool in [false, true]:
					await _placement(surface, carried, controller, "loot_000030", rotated, far_end, false, true, true)
			await _placement(surface, carried, controller, "loot_000022", false, false, true, true)
		else:
			await _placement(surface, carried, controller, "loot_000022", false, false, false, false)
	scene.free()
	current_scene = null
	await process_frame


func _placement(surface: StorageSurface, carried: CarriedItems, controller: StoragePlacementController, id: String, rotated: bool, far_end: bool, automatic: bool, check_interior: bool, front_row: bool = false) -> void:
	var item := ItemInstance.new(load("res://data/items/definitions/%s.tres" % id) as ItemDefinition)
	var pose := StorageVisualPose.measure_item(item, rotated)
	_check(bool(pose.get("valid", false)), "real asset pose measures")
	var entry := controller.call("_entry_for_item", item, rotated) as StorageStack.Entry
	var point := Vector3(100 if front_row else -100, 0, 100 if far_end else -100)
	var fit := surface.find_manual_empty_fit(point, entry)
	if automatic:
		surface.set_zone_rect(item.get_storage_category(), Vector2i.ZERO, surface.grid_size - Vector2i.ONE)
		fit = surface.find_zone_stack_or_empty_fit(item.get_storage_category(), entry)
	_check(bool(fit.get("valid", false)), "nearest boundary/manual or auto fit is legal")
	_check(fit.get("origin") == Vector2i(surface.grid_size.x - entry.footprint.x if front_row else 0, surface.grid_size.y - entry.footprint.y if far_end else 0), "nearest legal placement reaches requested front/rear-row end")
	if not bool(fit.get("valid", false)):
		return
	_check(carried.add_item(item), "representative item enters carry")
	controller.set("_current_surface", surface)
	controller.set("_current_fit", fit)
	controller.set("_manual_mode", not automatic)
	controller.set("_rotated", rotated)
	_check(controller.place_selected(), "real controller commits placement")
	var stack := surface.get_storage_stack(item.instance_id)
	if stack == null:
		_check(false, "stored stack exists")
		return
	var stored := stack.entries[0]
	_check(stored.item == item and carried.get_item_count() == 0, "exact identity transferred once")
	_check(stored.host.global_basis.get_scale().is_equal_approx(Vector3.ONE), "stored visual keeps canonical world scale")
	_check(stored.packing_rotated == rotated, "packing rotation preserved")
	var packing := stored.host.get_node(
		"StoredUnitOrientationYaw/StoredPackingYaw"
	) as Node3D
	var world_bounds: AABB = packing.global_transform * (pose["aligned_bounds"] as AABB)
	var shelf := surface.get_parent() as Node3D
	var local_bounds: AABB = shelf.global_transform.affine_inverse() * world_bounds
	if check_interior:
		print("PLACED shelf=%s item=%s rotated=%s auto=%s front=%s origin=%s bounds_world=%s bounds_shelf=%s rear_clearance_world_m=%.6f front_clearance_world_m=%.6f support_seating_delta_world_m=%.6f" % [shelf.name, id, rotated, automatic, front_row, fit["origin"], world_bounds, local_bounds, (local_bounds.position.x - BACK_X) * shelf.global_basis.get_scale().x, (SUPPORT_FRONT_X - local_bounds.end.x) * shelf.global_basis.get_scale().x, (local_bounds.position.y - SUPPORT_TOP_Y) * shelf.global_basis.get_scale().y])
		# Human-approved footprint overrides can land within sub-millimetre source-
		# mesh/support measurement noise. Keep fixture calibration strict above,
		# while allowing at most 0.5 mm on placed visual bounds.
		_check(local_bounds.position.x >= BACK_X - ITEM_EDGE_TOLERANCE, "PHYSICAL item must not penetrate measured inner back panel")
		_check(local_bounds.end.x <= SUPPORT_FRONT_X + ITEM_EDGE_TOLERANCE, "PHYSICAL front/rear item must remain inside measured support front edge")
		_check(local_bounds.position.z >= SUPPORT_Z.x - ITEM_EDGE_TOLERANCE and local_bounds.end.z <= SUPPORT_Z.y + ITEM_EDGE_TOLERANCE, "front/rear-row ends remain inside measured side supports")
	_check(stored.world_item.pickup_into(carried), "stored WorldItem retrieves normally")
	_check(carried.get_selected_item() == item and surface.get_stack_count() == 0, "retrieval keeps exact identity and releases reservation")
	controller.set("_current_surface", surface)
	controller.set("_current_fit", fit)
	controller.set("_rotated", rotated)
	_check(controller.place_selected(), "retrieved instance re-stores")
	stack = surface.get_storage_stack(item.instance_id)
	_check(stack != null and stack.entries[0].item == item, "re-store conserves identity")
	if stack != null:
		_check(stack.entries[0].world_item.pickup_into(carried), "cleanup retrieves through production path")
	_check(carried.remove_selected() == item, "cleanup removes only test instance")
	await process_frame


func _collect(node: Node, surfaces: Array[StorageSurface]) -> void:
	if node is StorageSurface:
		surfaces.append(node as StorageSurface)
	for child: Node in node.get_children():
		_collect(child, surfaces)


func _check(condition: bool, message: String) -> void:
	if not condition:
		_failed = true
		push_error("ASSERTION FAILED: %s" % message)
