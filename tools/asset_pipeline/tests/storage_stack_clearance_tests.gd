extends SceneTree

const ItemInstanceScript = preload("res://item_instance.gd")
const StorageStackScript = preload("res://storage_stack.gd")
const StorageSurfaceScript = preload("res://storage_surface.gd")
const StorageVisualPoseScript = preload("res://storage_visual_pose.gd")
const StoragePrototypeManagerScript = preload("res://storage_prototype_manager.gd")
const StorageShelfClearanceContextScript = preload("res://storage_shelf_clearance_context.gd")

const CATALOG_PATH: String = "res://data/items/item_catalog.tres"
const MAIN_SCENE_PATH: String = "res://main.tscn"
const HEIGHT_TOLERANCE_M: float = 0.00001

var _failed: bool = false


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var surface_probe: StorageSurface = StorageSurfaceScript.new()
	if not surface_probe.has_method(&"get_maximum_stack_top_y_m"):
		push_error("StorageSurface.get_maximum_stack_top_y_m is missing")
		surface_probe.free()
		quit(1)
		return
	surface_probe.free()
	_test_synthetic_clearance_boundary()
	_test_real_tower_book_and_medkit_evidence()
	_test_axis_scale_and_spacing_derivation()
	_test_missing_open_top_context_is_surfaced()
	await _test_authored_surface_profile()
	if _failed:
		quit(1)
		return
	print("PASS: storage stack clearance tests")
	quit(0)


func _test_synthetic_clearance_boundary() -> void:
	var surface: StorageSurface = StorageSurfaceScript.new()
	root.add_child(surface)
	surface.call("configure", &"clearance", 0.401, 0.401, 0.10, 1.0)
	var base = _synthetic_entry("base", Vector2i(2, 2), 0.50, false, true)
	_check(surface.commit_stack_entry(base, _empty_fit(base)), "synthetic base committed")
	# The existing normal shelf candidate transform starts at local Y 0.012.
	# These literal heights therefore produce actual tops 0.9499 and 0.9501.
	var below = _synthetic_entry("below", Vector2i.ONE, 0.4379, true, true)
	var above = _synthetic_entry("above", Vector2i.ONE, 0.4381, true, true)
	var accepted: Dictionary = surface.find_manual_stack_fit("base", below)
	var rejected: Dictionary = surface.find_manual_stack_fit("base", above)
	_check(bool(accepted.get("valid", false)), "0.9499 used height accepted")
	_check(not bool(rejected.get("valid", true)), "0.9501 used height rejected")
	_check(not bool(rejected.get("clearance_ok", true)), "rejection reports clearance cause")
	surface.free()


func _test_real_tower_book_and_medkit_evidence() -> void:
	var definitions: Dictionary = _definitions_by_id()
	var tower: ItemInstance = ItemInstanceScript.new(definitions["loot_000002"] as ItemDefinition)
	var book: ItemInstance = ItemInstanceScript.new(definitions["loot_000030"] as ItemDefinition)
	var medkit: ItemInstance = ItemInstanceScript.new(definitions["loot_000028"] as ItemDefinition)
	var tower_bounds: AABB = _measured_bounds(tower)
	var book_bounds: AABB = _measured_bounds(book)
	var medkit_bounds: AABB = _measured_bounds(medkit)
	_check(absf(tower_bounds.size.y - 0.45806125) <= HEIGHT_TOLERANCE_M, "Tower posed height remains reviewed value")
	_check(absf(book_bounds.size.y - 0.03608704) <= HEIGHT_TOLERANCE_M, "Book posed height remains reviewed value")
	_check(absf(medkit_bounds.size.y - 0.14315775) <= HEIGHT_TOLERANCE_M, "MedKit posed height remains reviewed value")

	var stack: StorageStack = StorageStackScript.new()
	var tower_entry = StorageStackScript.create_entry(tower, Vector2i(5, 3), false, tower_bounds)
	stack.entries.append(tower_entry)
	var book_entry = StorageStackScript.create_entry(book, Vector2i(3, 2), false, book_bounds)
	var medkit_entry = StorageStackScript.create_entry(medkit, Vector2i(5, 4), false, medkit_bounds)
	var compact_maximum_top_y_m: float = 0.822 * 0.67 * 0.95
	var book_fit: Dictionary = stack.find_manual_append(book_entry, compact_maximum_top_y_m, 0.012)
	var medkit_fit: Dictionary = stack.find_manual_append(medkit_entry, compact_maximum_top_y_m, 0.012)
	_check(bool(book_fit.get("footprint_ok", false)), "real Tower contains real Book footprint")
	_check(bool(book_fit.get("clearance_ok", false)), "real Tower plus Book clears compact shelf")
	_check(bool(book_fit.get("valid", false)), "real Tower plus Book is valid")
	_check(not bool(medkit_fit.get("footprint_ok", true)), "real Tower does not contain real MedKit footprint")
	_check(not bool(medkit_fit.get("clearance_ok", true)), "real Tower plus MedKit also exceeds compact clearance")
	_check(not bool(medkit_fit.get("valid", true)), "real Tower plus MedKit is dual-rejected")
	var rotated_medkit_entry = StorageStackScript.create_entry(medkit, Vector2i(4, 5), true, medkit_bounds)
	var rotated_fit: Dictionary = stack.find_manual_append(rotated_medkit_entry, compact_maximum_top_y_m, 0.012)
	_check(not bool(rotated_fit.get("footprint_ok", true)), "rotated real MedKit also exceeds Tower footprint")


func _test_axis_scale_and_spacing_derivation() -> void:
	var manager: StoragePrototypeManager = StoragePrototypeManagerScript.new()
	var baseline: float = float(manager.call(
		"_derive_closed_level_clearance_world_m",
		2.0,
		0.10,
		0.25,
		Vector3(1.0, 1.0, 1.0)
	))
	var x_scaled: float = float(manager.call(
		"_derive_closed_level_clearance_world_m",
		2.0,
		0.10,
		0.25,
		Vector3(4.0, 1.0, 1.0)
	))
	var z_scaled: float = float(manager.call(
		"_derive_closed_level_clearance_world_m",
		2.0,
		0.10,
		0.25,
		Vector3(1.0, 1.0, 5.0)
	))
	var y_scaled: float = float(manager.call(
		"_derive_closed_level_clearance_world_m",
		2.0,
		0.10,
		0.25,
		Vector3(1.0, 2.0, 1.0)
	))
	var wider_spacing: float = float(manager.call(
		"_derive_closed_level_clearance_world_m",
		2.0,
		0.10,
		0.30,
		Vector3.ONE
	))
	_check(is_equal_approx(baseline, 0.30), "adjacent level spacing derives physical clearance")
	_check(is_equal_approx(x_scaled, 0.30), "X-only furniture scale does not change vertical clearance")
	_check(is_equal_approx(z_scaled, 0.30), "Z-only furniture scale does not change vertical clearance")
	_check(is_equal_approx(y_scaled, 0.60), "Y-only furniture scale changes closed-level clearance")
	_check(is_equal_approx(wider_spacing, 0.40), "changed authored level spacing changes clearance automatically")
	var surface: StorageSurface = StorageSurfaceScript.new()
	root.add_child(surface)
	surface.configure(&"single_fraction", 0.401, 0.401, 0.10, 0.80)
	_check(is_equal_approx(surface.stack_clearance_m, 0.80), "surface stores physical world clearance without tuning")
	_check(is_equal_approx(surface.get_maximum_stack_top_y_m(), 0.76), "95-percent usable fraction is applied exactly once")
	surface.free()
	manager.free()


func _test_missing_open_top_context_is_surfaced() -> void:
	var manager: StoragePrototypeManager = StoragePrototypeManagerScript.new()
	var shelf: Node3D = Node3D.new()
	shelf.name = "MissingContextShelf"
	var fallback: float = float(manager.call(
		"_resolve_open_top_clearance_world_m",
		shelf,
		0.75
	))
	_check(is_equal_approx(fallback, 0.75), "family open-top fallback remains usable")
	_check(manager.get_missing_top_clearance_contexts() == ["MissingContextShelf"], "missing explicit top context is surfaced for diagnostics")
	shelf.free()
	manager.free()


func _test_authored_surface_profile() -> void:
	var packed: PackedScene = load(MAIN_SCENE_PATH) as PackedScene
	_check(packed != null, "main scene loads")
	if packed == null:
		return
	var scene: Node = packed.instantiate()
	root.add_child(scene)
	await process_frame
	await process_frame
	var surfaces: Array[StorageSurface] = []
	_collect_surfaces(scene, surfaces)
	_check(surfaces.size() == 16, "all current authored surfaces load")
	var expected_clearances: Dictionary = {
		"SM_MetalShelves_level_1": 0.822046,
		"SM_MetalShelves_level_2": 0.842597,
		"SM_MetalShelves_level_3": 0.918930,
		"SM_MetalShelves_level_4": 0.919000,
		"SM_MetalShelves2_level_1": 0.550771,
		"SM_MetalShelves2_level_2": 0.564540,
		"SM_MetalShelves2_level_3": 0.615683,
		"SM_MetalShelves2_level_4": 0.615730,
		"SM_ventilated_locker2_level_1": 0.951673,
		"SM_ventilated_locker2_level_2": 0.639966,
		"SM_ventilated_locker2_level_3": 0.518593,
		"SM_ventilated_locker2_level_4": 0.519000,
		"SM_ventilated_locker_level_1": 0.623346,
		"SM_ventilated_locker_level_2": 0.419177,
		"SM_ventilated_locker_level_3": 0.339678,
		"SM_ventilated_locker_level_4": 0.339945,
	}
	for surface: StorageSurface in surfaces:
		var key: String = String(surface.surface_id)
		_check(expected_clearances.has(key), "%s has migration evidence" % key)
		_check(absf(surface.stack_clearance_m - float(expected_clearances.get(key, -1.0))) <= 0.00001, "%s derives expected physical clearance" % key)
		_check(is_equal_approx(surface.get_maximum_stack_top_y_m(), surface.stack_clearance_m * 0.95), "%s applies one usable fraction" % key)

	var explicit_context_values: Dictionary = {
		"SM_MetalShelves": 0.919000,
		"SM_MetalShelves2": 0.615730,
		"SM_ventilated_locker2": 0.519000,
		"SM_ventilated_locker": 0.339945,
	}
	for shelf_name: String in explicit_context_values:
		var shelf: Node = scene.get_node_or_null(shelf_name)
		_check(shelf != null, "%s placed shelf exists" % shelf_name)
		if shelf == null:
			continue
		var context: Node = shelf.get_node_or_null("StorageShelfClearanceContext")
		_check(context != null and context.get_script() == StorageShelfClearanceContextScript, "%s has explicit open-top context" % shelf_name)
		if context != null and context.get_script() == StorageShelfClearanceContextScript:
			_check(absf(float(context.get("open_top_clearance_world_m")) - float(explicit_context_values[shelf_name])) <= 0.000001, "%s stores explicit world-metre top cap" % shelf_name)
	_check(float(explicit_context_values["SM_MetalShelves"]) != float(explicit_context_values["SM_MetalShelves2"]), "identical metal shelf models can use different open-top caps")
	scene.queue_free()


func _definitions_by_id() -> Dictionary:
	var catalogue: Resource = load(CATALOG_PATH)
	var result: Dictionary = {}
	for value: Variant in catalogue.get("definitions") as Array:
		var definition: ItemDefinition = value as ItemDefinition
		result[String(definition.item_id)] = definition
	return result


func _measured_bounds(item: ItemInstance) -> AABB:
	var result: Dictionary = StorageVisualPoseScript.measure_item(item, false)
	_check(bool(result.get("valid", false)), "%s pose measures" % item.get_display_name())
	return result.get("aligned_bounds", AABB()) as AABB


func _synthetic_entry(key: String, footprint: Vector2i, height_m: float, stacked: bool, supports: bool):
	var entry = StorageStackScript.Entry.new()
	entry.item_key = key
	entry.footprint = footprint
	entry.aligned_bounds = AABB(Vector3.ZERO, Vector3(0.1, height_m, 0.1))
	entry.posed_height_m = height_m
	entry.can_be_stacked = stacked
	entry.can_support_stack = supports
	return entry


func _empty_fit(entry) -> Dictionary:
	return {
		"valid": true,
		"placement_kind": "empty",
		"stack_id": entry.item_key,
		"insertion_index": 0,
		"origin": Vector2i.ZERO,
		"footprint": entry.footprint,
		"base_footprint": entry.footprint,
		"rotated": false,
		"zone_kind": "fixture",
		"zone_category": "",
		"host_y_m": 0.012
	}


func _collect_surfaces(node: Node, output: Array[StorageSurface]) -> void:
	if node is StorageSurface:
		output.append(node as StorageSurface)
	for child: Node in node.get_children():
		_collect_surfaces(child, output)


func _check(condition: bool, message: String) -> void:
	if condition:
		return
	_failed = true
	push_error("ASSERTION FAILED: %s" % message)
