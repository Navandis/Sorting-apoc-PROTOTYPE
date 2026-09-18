extends SceneTree

const SETUP_PATH := "res://gameplay/logistics_wing/development/seeded_storage_setup.tscn"
const CATALOGUE_PATH := "res://data/items/item_catalog.tres"
const FIXTURE_NAMESPACE := "wing_seed_v1"
const TEMP_ROUND_TRIP_PATH := "user://wing_seed_fixture_transform_test.tscn"
const EXPECTED_MULTISET := {
	"loot_000005": 2,
	"loot_000007": 1,
	"loot_000022": 2,
	"loot_000023": 1,
	"loot_000028": 2,
	"loot_000030": 1,
	"loot_000031": 2,
	"loot_000037": 1,
}

var _failed: bool = false
var _catalogue: Resource = null


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	_catalogue = load(CATALOGUE_PATH)
	_check(_catalogue != null, "persistent item catalogue loads")
	if not _check(ResourceLoader.exists(SETUP_PATH), "editor-authored seed setup exists"):
		_finish()
		return

	var packed := load(SETUP_PATH) as PackedScene
	if not _check(packed != null, "editor-authored seed setup loads"):
		_finish()
		return

	var first_ids: Array[String] = await _test_baseline_and_idempotence(packed)
	await _test_fresh_instance_reproduces_ids(packed, first_ids)
	await _test_transform_round_trip(packed)
	await _test_editor_style_duplicate(packed, first_ids)
	await _test_invalid_declaration(packed, "unknown", &"loot_999999", "unknown item ID")
	await _test_invalid_declaration(packed, "blocked_000015", &"loot_000015", "blocked item ID")
	await _test_invalid_declaration(packed, "blocked_000034", &"loot_000034", "blocked item ID")
	await _test_invalid_declaration(packed, "blocked_000036", &"loot_000036", "blocked item ID")
	await _test_invalid_declaration(packed, "missing_visual", &"", "missing authored visual")
	await _test_invalid_declaration(packed, "mismatched_visual", &"", "visual mismatch")
	_test_duplicate_derived_identity(packed)
	_finish()


func _test_baseline_and_idempotence(packed: PackedScene) -> Array[String]:
	var setup := packed.instantiate()
	root.add_child(setup)
	await process_frame
	await physics_frame

	var tables := setup.get_node_or_null("Tables")
	var seeds := setup.get_node_or_null("SeedItems")
	var registrar := setup.get_node_or_null("SeedRegistrar")
	_check(tables != null, "development setup owns Tables")
	_check(seeds != null, "development setup owns SeedItems")
	_check(registrar != null, "development setup owns one SeedRegistrar")
	if tables == null or seeds == null or registrar == null:
		setup.free()
		return []

	_check(seeds.get_child_count() == 12, "baseline fixture has twelve authored hosts")
	_check(
		tables.find_children("*", "StaticBody3D", true, false).size() > 0,
		"table furniture receives movement collision"
	)
	_check(
		tables.find_children("*", "StorageSurface", true, false).is_empty(),
		"tables never receive storage surfaces"
	)
	_check(
		seeds.find_children("*", "StorageSurface", true, false).is_empty(),
		"seed hosts never receive storage surfaces"
	)

	var actual_multiset: Dictionary = {}
	var instance_ids: Array[String] = []
	var instance_refs: Dictionary = {}
	for host: Node in seeds.get_children():
		_check(host is Node3D, "%s is an editor-movable Node3D host" % host.name)
		if not (host is Node3D):
			continue
		var host_3d := host as Node3D
		_check(host_3d.scale.is_equal_approx(Vector3.ONE), "%s uses identity scale" % host.name)
		var item_id := StringName(host.get("item_id"))
		var id_text := String(item_id)
		actual_multiset[id_text] = int(actual_multiset.get(id_text, 0)) + 1
		var definition := _catalogue.call("get_definition_by_id", item_id) as ItemDefinition
		_check(definition != null, "%s resolves catalogue definition" % host.name)
		var visual := host.call("get_authored_visual") as Node3D
		_check(visual != null, "%s has one editor-visible authored visual" % host.name)
		if definition != null and visual != null:
			_check(
				visual.scene_file_path == definition.visual_scene.resource_path,
				"%s authored visual matches catalogue" % host.name
			)
		var world_item := host.get_node_or_null("WorldItem") as WorldItem
		_check(world_item != null, "%s receives one WorldItem" % host.name)
		if world_item == null:
			continue
		var item: ItemInstance = world_item.get_item_instance()
		_check(item != null, "%s owns one ItemInstance" % host.name)
		if item == null:
			continue
		var expected_id := "%s:%s" % [FIXTURE_NAMESPACE, host.name]
		_check(item.instance_id == expected_id, "%s identity derives from host name" % host.name)
		_check(not instance_ids.has(item.instance_id), "%s identity is unique" % host.name)
		_check(not instance_refs.has(item), "%s ItemInstance reference is unique" % host.name)
		instance_ids.append(item.instance_id)
		instance_refs[item] = true

	_check(actual_multiset == EXPECTED_MULTISET, "baseline seed multiset matches approved sample")
	_check(instance_ids.size() == 12, "baseline registers twelve distinct identities")
	instance_ids.sort()
	_check(
		(registrar.call("get_registered_instance_ids") as Array).size() == 12,
		"registrar reports twelve registered identities"
	)
	_check(registrar.call("register_existing_hosts"), "second registration call is idempotent")
	_check(
		seeds.find_children("WorldItem", "WorldItem", true, false).size() == 12,
		"second registration creates no duplicate WorldItems"
	)

	var taken_host := seeds.get_child(0)
	var taken_world := taken_host.get_node("WorldItem") as WorldItem
	var carried: Node = (load("res://carried_items.gd") as Script).new()
	carried.set("max_bulk", 999)
	root.add_child(carried)
	_check(taken_world.pickup_into(carried), "ordinary pickup removes one authored host")
	_check(registrar.call("register_existing_hosts"), "registration remains idempotent after pickup")
	await process_frame
	_check(seeds.get_child_count() == 11, "picked host is removed once")
	_check(
		seeds.find_children("WorldItem", "WorldItem", true, false).size() == 11,
		"picked host is not resurrected"
	)
	_check(
		(registrar.call("get_registered_instance_ids") as Array).size() == 12,
		"registrar keeps the immutable one-shot census"
	)
	carried.free()
	setup.free()
	return instance_ids


func _test_fresh_instance_reproduces_ids(packed: PackedScene, expected_ids: Array[String]) -> void:
	var setup := packed.instantiate()
	root.add_child(setup)
	await process_frame
	var registrar := setup.get_node("SeedRegistrar")
	var actual_ids: Array[String] = []
	for value: Variant in registrar.call("get_registered_instance_ids") as Array:
		actual_ids.append(String(value))
	actual_ids.sort()
	_check(actual_ids == expected_ids, "fresh fixture reproduces the same twelve identities")
	setup.free()


func _test_transform_round_trip(packed: PackedScene) -> void:
	var setup := packed.instantiate()
	var host := setup.get_node("SeedItems").get_child(0) as Node3D
	var moved := host.transform.translated_local(Vector3(0.07, 0.02, -0.04))
	moved = moved.rotated_local(Vector3.UP, deg_to_rad(11.0))
	host.transform = moved

	var temporary := PackedScene.new()
	_check(temporary.pack(setup) == OK, "temporary fixture copy packs")
	_check(
		ResourceSaver.save(temporary, TEMP_ROUND_TRIP_PATH) == OK,
		"temporary fixture copy saves"
	)
	setup.free()

	var reloaded_packed := ResourceLoader.load(
		TEMP_ROUND_TRIP_PATH,
		"PackedScene",
		ResourceLoader.CACHE_MODE_IGNORE
	) as PackedScene
	if not _check(reloaded_packed != null, "temporary fixture copy reloads"):
		return
	var reloaded := reloaded_packed.instantiate()
	root.add_child(reloaded)
	await process_frame
	var reloaded_host := reloaded.get_node("SeedItems").get_child(0) as Node3D
	_check(
		reloaded_host.transform.is_equal_approx(moved),
		"saved host translation/rotation survives reload and registration"
	)
	reloaded.free()
	DirAccess.remove_absolute(ProjectSettings.globalize_path(TEMP_ROUND_TRIP_PATH))


func _test_editor_style_duplicate(packed: PackedScene, original_ids: Array[String]) -> void:
	var setup := packed.instantiate()
	var seeds := setup.get_node("SeedItems")
	var original := seeds.get_child(0)
	var duplicate := original.duplicate()
	duplicate.name = "CerealBox_A_Copy"
	seeds.add_child(duplicate)
	root.add_child(setup)
	await process_frame
	await physics_frame

	var registrar := setup.get_node("SeedRegistrar")
	var duplicate_ids: Array[String] = []
	for value: Variant in registrar.call("get_registered_instance_ids") as Array:
		duplicate_ids.append(String(value))
	duplicate_ids.sort()
	_check(duplicate_ids.size() == 13, "ordinary host duplication registers a thirteenth item")
	_check(
		duplicate_ids.has("%s:CerealBox_A_Copy" % FIXTURE_NAMESPACE),
		"duplicated host receives identity from its new name"
	)
	for original_id: String in original_ids:
		_check(duplicate_ids.has(original_id), "duplication preserves original identity %s" % original_id)

	var duplicate_world := duplicate.get_node_or_null("WorldItem") as WorldItem
	var original_world := original.get_node_or_null("WorldItem") as WorldItem
	_check(duplicate_world != null and original_world != null, "original and duplicate are independently targetable")
	if duplicate_world != null and original_world != null:
		_check(
			duplicate_world.get_item_instance() != original_world.get_item_instance(),
			"original and duplicate own distinct ItemInstance references"
		)
	setup.free()


func _test_invalid_declaration(
	packed: PackedScene,
	case_name: String,
	replacement_id: StringName,
	expected_failure_fragment: String
) -> void:
	var setup := packed.instantiate()
	var seeds := setup.get_node("SeedItems")
	var host := seeds.get_child(0)
	if case_name == "unknown" or case_name.begins_with("blocked_"):
		host.set("item_id", replacement_id)
	elif case_name == "missing_visual":
		var visual := host.call("get_authored_visual") as Node3D
		host.remove_child(visual)
		visual.free()
	elif case_name == "mismatched_visual":
		var original_visual := host.call("get_authored_visual") as Node3D
		host.remove_child(original_visual)
		original_visual.free()
		var different_host := seeds.get_child(2)
		var different_visual := (different_host.call("get_authored_visual") as Node3D).duplicate()
		host.add_child(different_visual)

	root.add_child(setup)
	await process_frame
	var registrar := setup.get_node("SeedRegistrar")
	var failures := registrar.call("get_validation_failures") as Array
	var joined := "\n".join(failures)
	_check(
		joined.contains(expected_failure_fragment),
		"%s declaration reports named failure" % case_name
	)
	_check(
		seeds.find_children("WorldItem", "WorldItem", true, false).is_empty(),
		"%s declaration creates no partial runtime ownership" % case_name
	)
	_check(
		(registrar.call("get_registered_instance_ids") as Array).is_empty(),
		"%s declaration leaves registrar census empty" % case_name
	)
	setup.free()


func _test_duplicate_derived_identity(packed: PackedScene) -> void:
	var setup := packed.instantiate()
	var seeds := setup.get_node("SeedItems")
	var registrar := setup.get_node("SeedRegistrar")
	var host := seeds.get_child(0)
	var declarations: Array[Dictionary] = []
	var seen_instance_ids: Dictionary = {}

	registrar.call("_validate_host", host, declarations, seen_instance_ids)
	registrar.call("_validate_host", host, declarations, seen_instance_ids)
	var failures := registrar.call("get_validation_failures") as Array
	_check(
		"\n".join(failures).contains("duplicate seed identity"),
		"duplicate derived identity reports named failure"
	)
	_check(declarations.size() == 1, "duplicate derived identity is not added to declarations")
	_check(
		seeds.find_children("WorldItem", "WorldItem", true, false).is_empty(),
		"duplicate derived identity creates no runtime ownership"
	)
	registrar.call("_report_failures")
	setup.free()


func _finish() -> void:
	if _failed:
		push_error("FAIL: wing seed fixture tests")
		quit(1)
		return
	print("PASS: wing seed fixture tests")
	quit(0)


func _check(condition: bool, message: String) -> bool:
	if condition:
		return true
	_failed = true
	push_error("ASSERTION FAILED: %s" % message)
	return false
