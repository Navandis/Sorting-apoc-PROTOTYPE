extends SceneTree

const StorageCategoriesScript = preload("res://storage_categories.gd")
const StoragePrototypeManagerScript = preload("res://storage_prototype_manager.gd")
const StorageShelfClearanceContextScript = preload("res://storage_shelf_clearance_context.gd")
const StorageSurfaceScript = preload("res://storage_surface.gd")
const StorageUnitOrientationScript = preload("res://storage_unit_orientation.gd")
const MetalShelfScene = preload("res://assets/environment/furniture/storage/SM_MetalShelves.glb")
const LockerScene = preload("res://assets/environment/furniture/storage/SM_ventilated_locker.glb")
const FunctionalFixturesScene = preload("res://gameplay/logistics_wing/functional_fixtures.tscn")

var _failed := false
var _zone_signal_count := 0


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	_test_authoring_context()
	_test_manager_orientation_propagation()
	_test_continuing_fixture_contexts()
	var surface := _make_surface()
	var required_methods := [
		"set_semantic_orientation_quarter_turns",
		"get_semantic_orientation_quarter_turns",
		"get_semantic_grid_size",
		"semantic_to_physical_cell",
		"physical_to_semantic_cell",
		"get_semantic_zone_category",
		"set_semantic_zone_rect",
		"clear_semantic_zone_rect",
		"get_semantic_zone_rect_percentage",
	]
	for method_name: String in required_methods:
		_check(surface.has_method(method_name), "StorageSurface exposes %s" % method_name)
	if _failed:
		surface.free()
		_finish()
		return

	_test_dimensions_and_normalization(surface)
	_test_front_left_paint(surface)
	_test_rectangle_erase_and_percentage(surface)
	_test_physical_state_preservation(surface)
	surface.free()
	_finish()


func _test_authoring_context() -> void:
	var context: Node = StorageUnitOrientationScript.new()
	_check(context.call("get_storage_orientation_quarter_turns") == 0, "context defaults to state 0")
	context.call("rotate_storage_directions_cw")
	_check(context.call("get_storage_orientation_quarter_turns") == 1, "CW moves 0 -> 1")
	context.call("rotate_storage_directions_ccw")
	_check(context.call("get_storage_orientation_quarter_turns") == 0, "CCW returns 1 -> 0")
	context.call("rotate_storage_directions_ccw")
	_check(context.call("get_storage_orientation_quarter_turns") == 3, "CCW wraps 0 -> 3")
	var expected_hint := (
		"Front +Z / Right +X:0,Front +X / Right -Z:1,"
		+ "Front -Z / Right -X:2,Front -X / Right +Z:3"
	)
	var enum_hint := ""
	for property: Dictionary in context.get_property_list():
		if String(property.get("name", "")) == "storage_orientation_quarter_turns":
			enum_hint = String(property.get("hint_string", ""))
			break
	_check(enum_hint == expected_hint, "context inspector enum uses the approved state labels")
	context.free()


func _test_manager_orientation_propagation() -> void:
	var fixture := Node3D.new()
	fixture.name = "OrientationFixture"
	root.add_child(fixture)
	var metal_a := MetalShelfScene.instantiate() as Node3D
	var metal_b := MetalShelfScene.instantiate() as Node3D
	var locker := LockerScene.instantiate() as Node3D
	metal_a.name = "SM_MetalShelves_OrientationA"
	metal_b.name = "SM_MetalShelves_OrientationB"
	locker.name = "SM_ventilated_locker_Orientation"
	fixture.add_child(metal_a)
	fixture.add_child(metal_b)
	fixture.add_child(locker)
	_add_orientation_context(metal_a, 2)
	_add_orientation_context(metal_b, 1)
	_add_orientation_context(locker, 3)

	var manager: StoragePrototypeManager = StoragePrototypeManagerScript.new()
	root.add_child(manager)
	manager.install(fixture)
	var surfaces_a := _surfaces_for_parent(manager, metal_a)
	var surfaces_b := _surfaces_for_parent(manager, metal_b)
	var locker_surfaces := _surfaces_for_parent(manager, locker)
	_check(surfaces_a.size() == 4, "first Metal Shelf installs four surfaces")
	_check(surfaces_b.size() == 4, "second Metal Shelf installs four surfaces")
	_check(locker_surfaces.size() == 4, "Locker installs four surfaces")
	for index: int in range(mini(surfaces_a.size(), surfaces_b.size())):
		var surface_a := surfaces_a[index]
		var surface_b := surfaces_b[index]
		_check(surface_a.get_semantic_orientation_quarter_turns() == 2, "every first-unit Metal surface inherits state 2")
		_check(surface_b.get_semantic_orientation_quarter_turns() == 1, "every second-unit Metal surface inherits state 1")
		_check(surface_a.get_grid_size() == surface_b.get_grid_size(), "Metal orientation does not change physical grid size")
		_check(surface_a.global_transform.is_equal_approx(surface_b.global_transform), "Metal orientation does not change physical transform")
	for surface: StorageSurface in locker_surfaces:
		_check(surface.get_semantic_orientation_quarter_turns() == 3, "every Locker surface inherits state 3")
	var context_free_unit := Node3D.new()
	_check(
		manager.call("_resolve_storage_orientation_quarter_turns", context_free_unit) == 0,
		"unit without authoring context resolves to state 0"
	)
	context_free_unit.free()
	manager.free()
	fixture.free()


func _add_orientation_context(unit: Node3D, state: int) -> void:
	var context: Node = StorageUnitOrientationScript.new()
	context.name = "StorageUnitOrientation"
	context.set("storage_orientation_quarter_turns", state)
	unit.add_child(context)
	var clearance: Node = StorageShelfClearanceContextScript.new()
	clearance.name = "StorageShelfClearanceContext"
	clearance.set("open_top_clearance_world_m", 0.9)
	unit.add_child(clearance)


func _test_continuing_fixture_contexts() -> void:
	var fixture := FunctionalFixturesScene.instantiate()
	var unit_paths := [
		"SM_MetalShelves_GalleryA_West",
		"SM_MetalShelves_GalleryB_North",
		"SM_ventilated_locker_GalleryC_West",
	]
	for unit_path: String in unit_paths:
		var context := fixture.get_node_or_null("%s/StorageUnitOrientation" % unit_path)
		_check(context != null, "%s has explicit orientation authoring context" % unit_path)
		if context != null:
			_check(
				context.call("get_storage_orientation_quarter_turns") == 0,
				"%s orientation context defaults to state 0" % unit_path
			)
	fixture.free()


func _surfaces_for_parent(
	manager: StoragePrototypeManager,
	unit: Node3D
) -> Array[StorageSurface]:
	var result: Array[StorageSurface] = []
	for surface_node: Node in manager.get_surfaces():
		if surface_node is StorageSurface and surface_node.get_parent() == unit:
			result.append(surface_node as StorageSurface)
	return result


func _make_surface() -> StorageSurface:
	var surface: StorageSurface = StorageSurfaceScript.new()
	root.add_child(surface)
	# Match established grid fixtures by keeping requested dimensions just over
	# exact cell multiples; configure() floors floating-point world ratios.
	surface.configure(&"semantic_test", 0.401, 0.301, 0.10, 1.0)
	return surface


func _test_dimensions_and_normalization(surface: StorageSurface) -> void:
	_check(surface.get_grid_size() == Vector2i(4, 3), "physical grid is 4x3")
	_check(
		surface.call("get_semantic_orientation_quarter_turns") == 0,
		"default semantic orientation is state 0"
	)
	_check(
		surface.call("get_semantic_grid_size") == Vector2i(4, 3),
		"state 0 semantic size matches physical"
	)
	for state: int in range(4):
		surface.call("set_semantic_orientation_quarter_turns", state)
		var expected := Vector2i(4, 3) if state in [0, 2] else Vector2i(3, 4)
		_check(
			surface.call("get_semantic_grid_size") == expected,
			"state %d semantic dimensions follow orientation" % state
		)
	surface.call("set_semantic_orientation_quarter_turns", -1)
	_check(
		surface.call("get_semantic_orientation_quarter_turns") == 3,
		"surface normalizes negative quarter turns"
	)


func _test_front_left_paint(surface: StorageSurface) -> void:
	var expected_physical := [
		Vector2i(0, 2),
		Vector2i(3, 2),
		Vector2i(3, 0),
		Vector2i(0, 0),
	]
	for state: int in range(4):
		surface.call("set_semantic_orientation_quarter_turns", state)
		var semantic_size: Vector2i = surface.call("get_semantic_grid_size")
		var front_left := Vector2i(0, semantic_size.y - 1)
		surface.clear_all_zones()
		surface.call(
			"set_semantic_zone_rect",
			StorageCategoriesScript.FOOD,
			front_left,
			front_left
		)
		var mapped: Vector2i = surface.call("semantic_to_physical_cell", front_left)
		_check(mapped == expected_physical[state], "state %d front-left maps to its physical corner" % state)
		_check(
			surface.get_zone_category(expected_physical[state]) == StorageCategoriesScript.FOOD,
			"state %d semantic front-left writes expected physical cell" % state
		)
		_check(
			surface.call("get_semantic_zone_category", front_left) == StorageCategoriesScript.FOOD,
			"state %d semantic read returns painted category" % state
		)
		_check(
			surface.call("physical_to_semantic_cell", expected_physical[state]) == front_left,
			"state %d physical corner reads back as semantic front-left" % state
		)
		var zones := surface.get_zone_cells_copy()
		_check(zones.count(StorageCategoriesScript.FOOD) == 1, "state %d changes exactly one physical cell" % state)
		_check(
			surface.call("get_semantic_zone_category", Vector2i(-1, 0)).is_empty(),
			"out-of-range semantic reads are empty"
		)


func _test_rectangle_erase_and_percentage(surface: StorageSurface) -> void:
	surface.clear_all_zones()
	surface.call("set_semantic_orientation_quarter_turns", 1)
	var first := Vector2i(0, 2)
	var second := Vector2i(1, 3)
	_zone_signal_count = 0
	if not surface.zones_changed.is_connected(_on_zones_changed):
		surface.zones_changed.connect(_on_zones_changed)
	surface.call("set_semantic_zone_rect", StorageCategoriesScript.MEDICAL, first, second)
	_check(_zone_signal_count == 1, "semantic rectangle emits zones_changed once")
	var expected_cells := [Vector2i(2, 2), Vector2i(2, 1), Vector2i(3, 2), Vector2i(3, 1)]
	for physical: Vector2i in expected_cells:
		_check(
			surface.get_zone_category(physical) == StorageCategoriesScript.MEDICAL,
			"rotated semantic rectangle paints expected physical cell %s" % physical
		)
	_check(
		surface.get_zone_cells_copy().count(StorageCategoriesScript.MEDICAL) == 4,
		"rotated 2x2 semantic rectangle changes exactly four physical cells"
	)
	_check(
		is_equal_approx(
			float(surface.call("get_semantic_zone_rect_percentage", first, second)),
			4.0 / 12.0
		),
		"semantic percentage uses total physical capacity"
	)
	surface.call("clear_semantic_zone_rect", first, second)
	_check(_zone_signal_count == 2, "semantic erase emits zones_changed once")
	for physical: Vector2i in expected_cells:
		_check(surface.get_zone_category(physical).is_empty(), "semantic erase clears %s" % physical)
	_check(surface.get_zone_cells_copy().count(StorageCategoriesScript.MEDICAL) == 0, "semantic erase clears all selected cells")


func _test_physical_state_preservation(surface: StorageSurface) -> void:
	surface.clear_all_zones()
	surface.set_zone_rect(StorageCategoriesScript.GENERAL, Vector2i(1, 1), Vector2i(2, 2))
	var reservations := surface.get("_reservations") as Dictionary
	reservations["sentinel"] = {"origin": Vector2i(1, 1), "footprint": Vector2i.ONE}
	var stacks := surface.get("_stacks") as Dictionary
	stacks["sentinel"] = RefCounted.new()
	var physical_grid_size := surface.get_grid_size()
	var physical_zones := surface.get_zone_cells_copy()
	var transform_before := surface.global_transform
	var reservations_before := reservations.duplicate(true)
	var stack_keys_before := stacks.keys()
	for state: int in range(4):
		surface.call("set_semantic_orientation_quarter_turns", state)
	_check(surface.get_grid_size() == physical_grid_size, "semantic orientation never changes physical grid")
	_check(surface.get_zone_cells_copy() == physical_zones, "semantic orientation never reorders physical zone data")
	_check(surface.global_transform.is_equal_approx(transform_before), "semantic orientation never rotates physical surface")
	_check((surface.get("_reservations") as Dictionary) == reservations_before, "reservations unchanged")
	_check((surface.get("_stacks") as Dictionary).keys() == stack_keys_before, "stack ownership unchanged")


func _on_zones_changed() -> void:
	_zone_signal_count += 1


func _check(condition: bool, message: String) -> void:
	if condition:
		return
	_failed = true
	push_error("ASSERTION FAILED: %s" % message)


func _finish() -> void:
	if _failed:
		push_error("FAIL: storage semantic zoning tests")
		quit(1)
		return
	print("PASS: storage semantic zoning tests")
	quit(0)
