extends SceneTree

var failures := 0
var checks := 0
var external_dir := ""

func _init() -> void:
	create_timer(45).timeout.connect(func():
		push_error("M1 helper aborted; completion missing" )
		quit(3))
	run.call_deferred()

func check(ok: bool, message: String) -> bool:
	checks += 1
	if not ok:
		failures += 1
		push_error("ASSERTION FAILED: " + message)
	return ok

func run() -> void:
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--m1-save-dir="):
			external_dir = argument.trim_prefix("--m1-save-dir=")
	if not check(not external_dir.is_empty() and external_dir.is_absolute_path() and not external_dir.begins_with(ProjectSettings.globalize_path("res://")), "mandatory external save destination"):
		finish()
		return
	if not check(ResourceLoader.exists("res://gameplay/run/run_snapshot.gd"), "production run snapshot exists"):
		finish()
		return
	var snapshots = load("res://gameplay/run/run_snapshot.gd").new()
	var service = load("res://gameplay/run/run_save_service.gd").new(external_dir)
	check(not service.inspect_slot().ok, "Continue unavailable without a save")
	var wing = load("res://gameplay/logistics_wing/wing_gameplay.tscn").instantiate()
	wing.configure_new_run()
	wing.get_node("Player").enable_held_item_view = false
	root.add_child(wing)
	await physics_frame
	await physics_frame
	wing.set_process(false)
	var player = wing.get_node("Player")
	player.set_physics_process(false)
	var carry = player.carried_items
	carry.max_bulk = 100
	var seed_root = wing.get_node("DevelopmentSetup/SeedItems")
	var bandages = seed_root.get_node("Medical_Bandages/WorldItem")
	var bandage_id: String = bandages.get_item_instance().instance_id
	check(bandages.pickup_into(carry), "real seed TAKE supplies contribution")
	check(wing.medical_request.submit(carry).ok, "real Medical submission succeeds")
	var antibiotic = seed_root.get_node("Medical_Antibiotics/WorldItem")
	check(antibiotic.pickup_into(carry), "second real seed TAKE")
	var kept_id: String = carry.get_selected_item().instance_id
	await process_frame
	var snapshot: Dictionary = snapshots.capture(wing)
	check(not snapshot.is_empty() and snapshots.validate(snapshot).is_empty(), "coherent real-wing snapshot validates")
	check(snapshot.schedule.requests[0].credited.Medical == 3 and snapshot.schedule.requests[0].spent[0].item_id == bandage_id, "partial contribution and exact consumed identity captured")
	var saved: Dictionary = service.save_snapshot(snapshot, {"year":2026,"month":10,"day":16,"hour":12,"minute":34})
	check(saved.ok and saved.path.get_file().begins_with("Save_"), "production save service writes timestamped snapshot")
	var first_path: String = saved.path
	check(service.save_snapshot(snapshot, {"year":2026,"month":10,"day":16,"hour":12,"minute":34}).ok, "same-minute save replaces same slot")
	check(service.inspect_slot().ok, "Continue sees validated single slot")
	var changed: Dictionary = service.save_snapshot(snapshot, {"year":2026,"month":10,"day":16,"hour":12,"minute":35})
	check(changed.ok and changed.path != first_path and not FileAccess.file_exists(first_path), "timestamp change retires only previous active snapshot")
	var loaded: Dictionary = service.load_snapshot()
	if loaded.ok and loaded.snapshot != snapshot:
		diagnose_difference(snapshot, loaded.snapshot, "snapshot")
	check(loaded.ok and loaded.snapshot == snapshot, "JSON decoding preserves exact state and numeric types")
	var malformed := snapshot.duplicate(true)
	malformed.schema = 999
	check(not service.save_snapshot(malformed).ok and service.load_snapshot().snapshot == snapshot, "unsupported schema rejected without replacing previous slot")
	var restore_scene = load("res://gameplay/logistics_wing/wing_gameplay.tscn").instantiate()
	restore_scene.get_node("Player").enable_held_item_view = false
	wing.free()
	restore_scene.configure_continue(snapshot)
	root.add_child(restore_scene)
	check(snapshots.restore(restore_scene, snapshot).is_empty(), "restore publishes validated owners without seeding")
	var restored_carry = restore_scene.get_node("Player/CarriedItems")
	check(restored_carry.get_selected_item().instance_id == kept_id and restored_carry.get_items().size() == 1, "selected carried identity restored once")
	check(restore_scene.get_node_or_null("DevelopmentSetup/SeedItems/Medical_Bandages") == null and restore_scene.get_node_or_null("DevelopmentSetup/SeedItems/Medical_Antibiotics") == null, "spent and taken original hosts never respawn")
	check(restore_scene.medical_request.credited.Medical == 3, "Continue does not recredit or regenerate request")
	var kept_definition: ItemDefinition = restored_carry.get_selected_item().definition
	var original_utility: Dictionary = kept_definition.context_utility_overrides.duplicate(true)
	kept_definition.context_utility_overrides[&"medical_bay"].value = 99
	check(snapshots.validate(snapshot).is_empty() and restore_scene.medical_request.credited.Medical == 3, "Utility retuning never recomputes historical credit or invalidates physical compatibility")
	kept_definition.context_utility_overrides = original_utility
	check(restore_scene.medical_request.submit(restored_carry).ok, "restored partial request accepts one current item")
	check(restore_scene.get_node("DevelopmentSetup/SeedItems/MedKit_A/WorldItem").pickup_into(restored_carry), "remaining original medkit can be taken")
	check(restore_scene.medical_request.submit(restored_carry).ok and restore_scene.medical_request.closed, "partial continuation reaches its one closed result")
	await process_frame
	var closed: Dictionary = snapshots.capture(restore_scene)
	check(service.save_snapshot(closed).ok and service.load_snapshot().snapshot.schedule.requests[0] == closed.schedule.requests[0], "closed request and exact spent receipts survive the same production slot")
	restore_scene.free()
	var closed_scene = load("res://gameplay/logistics_wing/wing_gameplay.tscn").instantiate()
	closed_scene.get_node("Player").enable_held_item_view = false
	closed_scene.configure_continue(closed)
	root.add_child(closed_scene)
	check(snapshots.restore(closed_scene, closed).is_empty() and closed_scene.medical_request.closed and closed_scene.medical_request.spent.size() == 3, "loading closed state never credits or consumes again")
	check(closed_scene.get_node_or_null("DevelopmentSetup/SeedItems/MedKit_A") == null, "closed-state spent medkit original stays absent")
	closed_scene.free()
	var invalid_directory := external_dir.path_join("invalid-load")
	DirAccess.make_dir_recursive_absolute(invalid_directory)
	var invalid_file := FileAccess.open(invalid_directory.path_join("Save_invalid.json"), FileAccess.WRITE)
	invalid_file.store_string("{broken JSON")
	invalid_file.close()
	var pointer := FileAccess.open(invalid_directory.path_join("active-slot.json"), FileAccess.WRITE)
	pointer.store_string('{"snapshot":"Save_invalid.json"}')
	pointer.close()
	var bad_service = load("res://gameplay/run/run_save_service.gd").new(invalid_directory)
	check(not bad_service.load_snapshot().ok and FileAccess.get_file_as_string(invalid_directory.path_join("Save_invalid.json")) == "{broken JSON", "ordinary malformed load is explained and left untouched")
	finish()

func finish() -> void:
	print("M1_PERSISTENCE_COMPLETE checks=", checks, " failures=", failures)
	quit(1 if failures else 0)

func diagnose_difference(expected: Variant, actual: Variant, path: String) -> void:
	if expected is Dictionary and actual is Dictionary:
		for key: Variant in expected:
			if not actual.has(key): print("DIFF missing ", path, ".", key)
			elif expected[key] != actual[key]: diagnose_difference(expected[key], actual[key], path + "." + String(key))
	elif expected is Array and actual is Array:
		if expected.size() != actual.size(): print("DIFF size ", path)
		else:
			for i: int in expected.size():
				if expected[i] != actual[i]: diagnose_difference(expected[i], actual[i], path + "[%d]" % i)
			print("DIFF array types ", path, " ", expected.get_typed_builtin(), " / ", actual.get_typed_builtin())
	else:
		print("DIFF ", path, " types ", typeof(expected), "/", typeof(actual), " expected=", expected, " actual=", actual)
