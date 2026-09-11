extends SceneTree

const CarriedItemsScript = preload("res://carried_items.gd")
const ItemInstanceScript = preload("res://item_instance.gd")
const StoragePlacementControllerScript = preload("res://storage_placement_controller.gd")
const StorageCategoriesScript = preload("res://storage_categories.gd")
const StorageStackScript = preload("res://storage_stack.gd")
const StorageSurfaceScript = preload("res://storage_surface.gd")

const CATALOG_PATH: String = "res://data/items/item_catalog.tres"
const MAIN_SCENE_PATH: String = "res://main.tscn"
const CLOSED_CLEARANCE_M: float = 0.321610
const HEIGHT_TOLERANCE_M: float = 0.00001

var _failed: bool = false


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var definitions: Dictionary = _definitions_by_id()
	_test_closed_surface_causal_fit(definitions)
	_test_nontrivial_authored_pose_uses_seated_end(definitions)
	_test_commit_revalidates_stale_empty_fit(definitions)
	_test_manual_empty_ghost_and_commit_equivalence(definitions)
	_test_manual_horizontal_rejection_remains_authoritative(definitions)
	await _test_authored_open_top_singleton_clearance()
	if _failed:
		quit(1)
		return
	print("PASS: storage singleton clearance tests")
	quit(0)


func _test_closed_surface_causal_fit(definitions: Dictionary) -> void:
	var context: Dictionary = _context(CLOSED_CLEARANCE_M)
	var surface: StorageSurface = context["surface"] as StorageSurface
	var controller: StoragePlacementController = context["controller"] as StoragePlacementController
	surface.set_zone_rect(StorageCategoriesScript.GENERAL, Vector2i.ZERO, surface.grid_size - Vector2i.ONE)
	var short_item: ItemInstance = ItemInstanceScript.new(definitions["loot_000001"] as ItemDefinition)
	var tall_item: ItemInstance = ItemInstanceScript.new(definitions["loot_000017"] as ItemDefinition)
	var posed_item: ItemInstance = ItemInstanceScript.new(definitions["loot_000002"] as ItemDefinition)
	var short_entry: StorageStack.Entry = controller.call("_entry_for_item", short_item, false)
	var tall_native: StorageStack.Entry = controller.call("_entry_for_item", tall_item, false)
	var tall_rotated: StorageStack.Entry = controller.call("_entry_for_item", tall_item, true)
	var posed_entry: StorageStack.Entry = controller.call("_entry_for_item", posed_item, false)

	_check(short_entry != null and tall_native != null and tall_rotated != null, "real short and tall item poses measure")
	_check(posed_entry != null, "authored Tower pose measures")
	if short_entry == null or tall_native == null or tall_rotated == null or posed_entry == null:
		_free_context(context)
		return
	_check(
		absf(posed_entry.aligned_bounds.position.y - 0.006) <= HEIGHT_TOLERANCE_M,
		"nontrivial authored Tower pose is expressed in the authoritative seated frame"
	)
	_check(
		absf(posed_entry.aligned_bounds.size.y - 0.45806125) <= HEIGHT_TOLERANCE_M,
		"nontrivial authored Tower pose retains reviewed seated height"
	)
	_check(
		absf(tall_native.aligned_bounds.end.y - tall_rotated.aligned_bounds.end.y) <= HEIGHT_TOLERANCE_M,
		"90-degree packing yaw does not change seated vertical extent"
	)

	var short_fit: Dictionary = surface.find_zone_stack_or_empty_fit("", short_entry)
	var tall_fit: Dictionary = surface.find_zone_stack_or_empty_fit("", tall_native, tall_rotated)
	print(
		"SINGLETON_CLEARANCE_EVIDENCE surface=%s support_plane_y=0.000000 host_y=%.6f physical_clearance=%.6f short_min_y=%.6f short_max_y=%.6f short_top=%.6f tall_min_y=%.6f tall_max_y=%.6f tall_top=%.6f headroom_fraction=physical_only" % [
			surface.surface_id,
			float(short_fit.get("host_y_m", 0.0)),
			surface.stack_clearance_m,
			short_entry.aligned_bounds.position.y,
			short_entry.aligned_bounds.end.y,
			float(short_fit.get("resulting_top_y_m", INF)),
			tall_native.aligned_bounds.position.y,
			tall_native.aligned_bounds.end.y,
			float(tall_fit.get("resulting_top_y_m", INF)),
		]
	)
	_check(bool(short_fit.get("valid", false)), "short singleton is accepted on the closed surface")
	_check(bool(short_fit.get("clearance_ok", false)), "short singleton reports physical clearance success")
	_check(not bool(tall_fit.get("valid", true)), "too-tall singleton is rejected on the same closed surface")
	_check(not bool(tall_fit.get("clearance_ok", true)), "too-tall singleton reports physical clearance failure")
	_free_context(context)


func _test_nontrivial_authored_pose_uses_seated_end(definitions: Dictionary) -> void:
	# Tower's aligned min Y is 0.006 m. This boundary deliberately falls between
	# host + posed_height and host + aligned_bounds.end.y, so reconstructing the
	# top from height alone would incorrectly accept it.
	var context: Dictionary = _context(0.473)
	var surface: StorageSurface = context["surface"] as StorageSurface
	var controller: StoragePlacementController = context["controller"] as StoragePlacementController
	var tower_item: ItemInstance = ItemInstanceScript.new(definitions["loot_000002"] as ItemDefinition)
	var tower_entry: StorageStack.Entry = controller.call("_entry_for_item", tower_item, false)
	_check(tower_entry != null, "discriminating authored Tower pose measures")
	if tower_entry != null:
		var host_y_m: float = surface.get_local_placement_position(Vector2i.ZERO, tower_entry.footprint).y
		_check(
			host_y_m + tower_entry.posed_height_m < surface.stack_clearance_m,
			"height-only reconstruction would accept the Tower boundary"
		)
		_check(
			host_y_m + tower_entry.aligned_bounds.end.y > surface.stack_clearance_m,
			"authoritative seated Tower end exceeds the same boundary"
		)
		var fit: Dictionary = surface.find_manual_empty_fit(Vector3.ZERO, tower_entry)
		_check(not bool(fit.get("valid", true)), "authored Tower singleton uses seated end rather than raw height")
	_free_context(context)


func _test_commit_revalidates_stale_empty_fit(definitions: Dictionary) -> void:
	var context: Dictionary = _context(CLOSED_CLEARANCE_M)
	var surface: StorageSurface = context["surface"] as StorageSurface
	var controller: StoragePlacementController = context["controller"] as StoragePlacementController
	var tall_item: ItemInstance = ItemInstanceScript.new(definitions["loot_000017"] as ItemDefinition)
	var short_item: ItemInstance = ItemInstanceScript.new(definitions["loot_000001"] as ItemDefinition)
	var tall_entry: StorageStack.Entry = controller.call("_entry_for_item", tall_item, false)
	var short_entry: StorageStack.Entry = controller.call("_entry_for_item", short_item, false)
	_check(tall_entry != null, "commit-time tall pose measures")
	if tall_entry != null:
		var stale_fit: Dictionary = _empty_fit(surface, tall_entry, Vector2i.ZERO, "stale")
		_check(
			not surface.commit_stack_entry(tall_entry, stale_fit),
			"commit rejects a stale valid-looking empty fit that exceeds physical clearance"
		)
		_check(surface.get_reservation_count() == 0, "rejected stale commit leaves no reservation")
		_check(surface.get_stack_count() == 0, "rejected stale commit leaves no singleton record")
		var forged_low_fit: Dictionary = _empty_fit(surface, tall_entry, Vector2i.ZERO, "stale")
		forged_low_fit["host_y_m"] = -1.000
		_check(
			not surface.commit_stack_entry(tall_entry, forged_low_fit),
			"commit rejects a forged low host before canonical final positioning"
		)
		_check(surface.get_reservation_count() == 0, "rejected low-host commit leaves no reservation")
		if surface.get_reservation_count() > 0:
			surface.clear_all()
	_check(short_entry != null, "commit-time short pose measures")
	if short_entry != null:
		var elevated_fit: Dictionary = _empty_fit(surface, short_entry, Vector2i.ZERO, "stale")
		elevated_fit["host_y_m"] = 0.300
		_check(
			not surface.commit_stack_entry(short_entry, elevated_fit),
			"commit checks the exact elevated host transform supplied by a stale fit"
		)
		_check(surface.get_reservation_count() == 0, "rejected elevated-host commit leaves no reservation")
	_free_context(context)


func _test_manual_empty_ghost_and_commit_equivalence(definitions: Dictionary) -> void:
	var context: Dictionary = _context(0.473)
	var surface: StorageSurface = context["surface"] as StorageSurface
	var controller: StoragePlacementController = context["controller"] as StoragePlacementController
	var carried: CarriedItems = context["carried"] as CarriedItems
	var tall_item: ItemInstance = ItemInstanceScript.new(definitions["loot_000002"] as ItemDefinition)
	var tall_entry: StorageStack.Entry = controller.call("_entry_for_item", tall_item, false)
	_check(surface.has_method(&"find_manual_empty_fit"), "shared manual empty-fit API exists")
	if tall_entry == null or not surface.has_method(&"find_manual_empty_fit"):
		_free_context(context)
		return

	var fit: Dictionary = surface.call(
		"find_manual_empty_fit",
		Vector3.ZERO,
		tall_entry
	) as Dictionary
	_check(not bool(fit.get("valid", true)), "manual empty search rejects the too-tall singleton")
	_check(carried.add_item(tall_item), "manual rejection fixture enters carried strip")
	controller.set_manual_mode(true)
	controller.set("_current_surface", surface)
	controller.set("_current_fit", fit)
	controller.call("_update_ghost", tall_item)
	var ghost_host: Node3D = controller.get("_ghost_host") as Node3D
	_check(ghost_host.visible, "manual invalid ghost remains visible as a blocked preview")
	_check(not controller.has_valid_placement(), "manual ghost uses the rejected fit")
	_check(not controller.place_selected(), "manual final placement rejects the same fit")
	_check(carried.get_selected_item() == tall_item, "manual rejection preserves carried ownership")
	_check(surface.get_reservation_count() == 0, "manual rejection commits no reservation")
	_free_context(context)


func _test_manual_horizontal_rejection_remains_authoritative(definitions: Dictionary) -> void:
	var context: Dictionary = _context(1.0)
	var surface: StorageSurface = context["surface"] as StorageSurface
	var controller: StoragePlacementController = context["controller"] as StoragePlacementController
	var short_item: ItemInstance = ItemInstanceScript.new(definitions["loot_000001"] as ItemDefinition)
	var short_entry: StorageStack.Entry = controller.call("_entry_for_item", short_item, false)
	_check(short_entry != null, "blocked-surface short pose measures")
	_check(
		surface.reserve_at("full_surface_blocker", Vector2i.ZERO, surface.grid_size),
		"manual horizontal rejection fixture fills the surface"
	)
	if short_entry != null:
		var fit: Dictionary = surface.find_manual_empty_fit(Vector3.ZERO, short_entry)
		_check(bool(fit.get("clearance_ok", false)), "blocked short item still passes physical clearance")
		_check(not bool(fit.get("valid", true)), "horizontal no-fit remains invalid after clearance decoration")
	_free_context(context)


func _test_authored_open_top_singleton_clearance() -> void:
	var packed: PackedScene = load(MAIN_SCENE_PATH) as PackedScene
	_check(packed != null, "main scene loads for authored open-top evidence")
	if packed == null:
		return
	var scene: Node = packed.instantiate()
	root.add_child(scene)
	await process_frame
	await process_frame
	var surface: StorageSurface = _find_surface(scene, "SM_MetalShelves2_level_4")
	_check(surface != null, "genuine SM_MetalShelves2 open-top surface exists")
	if surface == null:
		scene.queue_free()
		return
	_check(
		absf(surface.stack_clearance_m - 0.615730) <= HEIGHT_TOLERANCE_M,
		"open-top singleton route retains the explicit per-instance physical clearance"
	)
	surface.set_zone_rect(StorageCategoriesScript.GENERAL, Vector2i.ZERO, surface.grid_size - Vector2i.ONE)
	var within_physical_only: StorageStack.Entry = _synthetic_entry("open_fit", 0.600)
	var above_explicit_cap: StorageStack.Entry = _synthetic_entry("open_tall", 0.610)
	var accepted: Dictionary = surface.find_zone_stack_or_empty_fit("", within_physical_only)
	var rejected: Dictionary = surface.find_zone_stack_or_empty_fit("", above_explicit_cap)
	_check(bool(accepted.get("valid", false)), "open-top singleton uses physical clearance without stack-only 95-percent headroom")
	_check(not bool(rejected.get("valid", true)), "open-top singleton cannot exceed its explicit per-instance cap")
	scene.queue_free()


func _context(clearance_m: float) -> Dictionary:
	var surface: StorageSurface = StorageSurfaceScript.new()
	root.add_child(surface)
	surface.configure(&"closed_singleton_fixture", 1.201, 1.201, 0.10, clearance_m)
	var carried: CarriedItems = CarriedItemsScript.new()
	carried.max_bulk = 999
	root.add_child(carried)
	var controller: StoragePlacementController = StoragePlacementControllerScript.new()
	root.add_child(controller)
	controller.configure(null, carried, 1.8)
	return {"surface": surface, "carried": carried, "controller": controller}


func _free_context(context: Dictionary) -> void:
	(context["controller"] as Node).free()
	(context["carried"] as Node).free()
	(context["surface"] as Node).free()


func _empty_fit(
	surface: StorageSurface,
	entry: StorageStack.Entry,
	origin: Vector2i,
	zone_kind: String
) -> Dictionary:
	return {
		"valid": true,
		"placement_kind": "empty",
		"stack_id": entry.item_key,
		"insertion_index": 0,
		"origin": origin,
		"footprint": entry.footprint,
		"base_footprint": entry.footprint,
		"rotated": entry.packing_rotated,
		"zone_kind": zone_kind,
		"zone_category": "",
		"host_y_m": surface.get_local_placement_position(origin, entry.footprint).y,
	}


func _synthetic_entry(key: String, seated_end_y_m: float) -> StorageStack.Entry:
	var entry: StorageStack.Entry = StorageStackScript.Entry.new()
	entry.item_key = key
	entry.footprint = Vector2i.ONE
	entry.aligned_bounds = AABB(
		Vector3(-0.05, 0.006, -0.05),
		Vector3(0.10, seated_end_y_m - 0.006, 0.10)
	)
	entry.posed_height_m = entry.aligned_bounds.size.y
	return entry


func _find_surface(node: Node, requested_id: String) -> StorageSurface:
	if node is StorageSurface and String((node as StorageSurface).surface_id) == requested_id:
		return node as StorageSurface
	for child: Node in node.get_children():
		var found: StorageSurface = _find_surface(child, requested_id)
		if found != null:
			return found
	return null


func _definitions_by_id() -> Dictionary:
	var catalogue: Resource = load(CATALOG_PATH)
	var result: Dictionary = {}
	for value: Variant in catalogue.get("definitions") as Array:
		var definition: ItemDefinition = value as ItemDefinition
		result[String(definition.item_id)] = definition
	return result


func _check(condition: bool, message: String) -> void:
	if condition:
		return
	_failed = true
	push_error("ASSERTION FAILED: %s" % message)
