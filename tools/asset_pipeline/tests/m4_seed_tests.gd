extends SceneTree

var failures := 0
var checks := 0
func _init() -> void:
	create_timer(150).timeout.connect(func():
		push_error("M4 seed helper incomplete")
		quit(3))
	run.call_deferred()

func check(ok: bool, message: String) -> bool:
	checks += 1
	if not ok:
		failures += 1
		push_error("ASSERTION FAILED: " + message)
	return ok

func run() -> void:
	var wing = load("res://gameplay/logistics_wing/wing_gameplay.tscn").instantiate()
	wing.configure_new_run()
	wing.set_process(false)
	wing.get_node("Player").enable_held_item_view = false
	root.add_child(wing)
	await process_frame
	await physics_frame
	var carry: CarriedItems = wing.get_node("Player/CarriedItems")
	wing.get_node("Player").set_physics_process(false)
	check(wing.get_initialization_error().is_empty(), "Seed initializes legally: " + wing.get_initialization_error())
	check(wing.get_node("DevelopmentSetup/SeedItems").get_child_count() == 0, "M4 replaces original loose palette stock")
	var inventory: Array = []
	var actual: Array = []
	var ids: Dictionary = {}
	var bulk := 0
	for surface: StorageSurface in wing.get_functional_surfaces():
		for stack: StorageStack in surface._stacks.values():
			for entry: StorageStack.Entry in stack.entries:
				var item: ItemInstance = entry.item
				check(not ids.has(item.instance_id), "Seed identity occurs once")
				ids[item.instance_id] = true
				actual.append(String(item.definition.item_id))
				bulk += item.get_bulk()
				inventory.append({"id":item.instance_id,"definition":String(item.definition.item_id),"surface":String(wing.get_path_to(surface)),"origin":stack.surface_origin,"footprint":entry.footprint,"host":entry.host.global_transform})
	var baseline: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/scenarios/m4/Sorting_Apocalypse_M4_Locked_Baseline_24Oct2026.json"))
	var expected: Array = baseline.scenario.seed.duplicate()
	actual.sort()
	expected.sort()
	check(actual == expected and ids.size() == 85 and bulk == 240, "Exact complete 85-item / 240-Bulk seed, no extras or omissions")
	if actual == expected:
		for surface: StorageSurface in wing.get_functional_surfaces():
			var stacks: Array = surface._stacks.values().duplicate()
			for stack: StorageStack in stacks:
				var entries: Array = stack.entries.duplicate()
				entries.reverse()
				for entry: StorageStack.Entry in entries:
					check(entry.world_item.pickup_into(carry) and carry.get_selected_item() == entry.item, "Production shelf retrieval retains seeded identity")
					carry.remove_item(entry.item)
	var file := FileAccess.open("C:/Users/Boschetar/.codex/attachments/m4-2026-10-24/seed-inventory.json",FileAccess.WRITE)
	file.store_string(JSON.stringify(inventory,"\t",true))
	file.close()
	wing.free()
	print("M4_SEED_COMPLETE checks=",checks," items=",ids.size()," bulk=",bulk," failures=",failures)
	quit(1 if failures else 0)
