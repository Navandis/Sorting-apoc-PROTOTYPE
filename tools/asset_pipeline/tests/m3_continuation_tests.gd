extends "res://tools/asset_pipeline/tests/m2_continuation_tests.gd"

func run() -> void:
	create_timer(90).timeout.connect(func():
		push_error("M3 continuation helper aborted; completion missing")
		quit(3))
	var mode := ""
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--m3-save-dir="): external_dir = arg.trim_prefix("--m3-save-dir=")
		if arg.begins_with("--m3-mode="): mode = arg.trim_prefix("--m3-mode=")
	if not check(external_dir.is_absolute_path() and not external_dir.begins_with(ProjectSettings.globalize_path("res://")) and mode in ["write-partial","read-partial","write-report","read-report"], "explicit external save directory/mode required"):
		finish()
		return
	var shell := HeadlessShell.new()
	shell.save_service = Service.new(external_dir.path_join("slot"))
	root.add_child(shell)
	var snapshots := Snapshots.new()
	var codec = load("res://gameplay/run/state_codec.gd").new()
	var expected_path := external_dir.path_join("expected.json")
	if mode.begins_with("write"):
		if not check(shell.start_new_run(), "writer uses production fresh M3 New Run"):
			shell.free()
			finish()
			return
		var wing = shell.wing
		wing.set_process(false)
		await populate_physical_fixture(wing,false)
		wing.run_schedule.advance(300.0-wing.run_schedule.clock.elapsed)
		var carry = wing.get_node("Player/CarriedItems")
		var kitchen = wing.run_schedule.active_request("kitchen")
		print("M3_PARTIAL_CLOCK ",wing.run_schedule.clock.capture_state()," phase=",wing.run_schedule.phase," error=",wing.run_schedule.error," issued=",wing.run_schedule.issued)
		if not check(kitchen != null,"breakfast opened before continuation fixture"):
			shell.free()
			finish()
			return
		for id: String in ["loot_000007","loot_000019"]:
			var host = wing.get_node("DevelopmentSetup/SeedItems").get_children().filter(func(h): return String(h.item_id)==id)[0]
			var item: ItemInstance = host.get_node("WorldItem").get_item_instance()
			check(host.get_node("WorldItem").pickup_into(carry), "actual seed TAKE for partial Kitchen")
			carry.select_index(carry.get_slots().find(item))
			check(kitchen.submit(carry).ok,"actual partial Kitchen contribution")
		var runtime = wing.get_node("ReceivingRuntime")
		for index: int in 2:
			check(runtime.deck_presenter.get_materialized_world_items()[0].pickup_into(carry), "partly unload real larger cargo before save")
		check(wing.medical_request.credited.Medical == 3 and kitchen.credited == {"Food":5,"Hydration":3}, "writer has two independent partially supplied destinations")
		if mode == "write-report": wing.run_schedule.advance(2250.0)
		var expected := snapshots.capture(wing)
		var file := FileAccess.open(expected_path,FileAccess.WRITE)
		file.store_string(codec.stringify(expected))
		file.close()
		check(shell.save_and_exit() and shell.save_service.load_snapshot().snapshot == expected, "writer same service saves complete exact state")
	else:
		var expected: Dictionary = codec.parse(FileAccess.get_file_as_string(expected_path))
		if not check(shell.continue_run(), "separate reader Continues production M3 slot"):
			shell.free()
			finish()
			return
		var wing = shell.wing
		wing.set_process(false)
		wing.get_node("Player").set_physics_process(false)
		check(snapshots.capture(wing) == expected, "exact cross-process clock, both histories, cargo, storage, carrying and ladder")
		check(paused == (mode == "read-report"), "reader restores report hold before gameplay")
		await process_frame
		await process_frame
		check(snapshots.capture(wing) == expected, "callbacks do not replay occurrences or spent items")
		if mode == "read-report":
			check(wing.run_schedule.report == expected.schedule.report and wing.run_schedule.report.meals.size() == 3, "old-day six-lane report restored exactly")
			shell.begin_next_day()
		else:
			check(wing.get_node("MedicalContribution").request.credited.Medical == 3 and wing.get_node("KitchenContribution").request.credited.Food == 5, "both active stations correctly rebound after restart")
		await exercise_restored_owners(wing)
		var runtime = wing.get_node("ReceivingRuntime")
		check(runtime.lift_cycle.can_take_receiving() and runtime.deck_presenter.get_materialized_world_items()[0].pickup_into(wing.get_node("Player/CarriedItems")), "restored partially unloaded larger cargo operates through actual TAKE")
		var fresh: LootBatch = runtime.prepare_manifest(["loot_000019"],"after_restart",9999)
		check(fresh != null and not expected.items.has(fresh.entries[0].item_instance_id), "restored allocator issues fresh cargo identity")
	shell.free()
	finish()

func finish() -> void:
	paused = false
	check(_pending_helpers == 0,"all physical continuation helpers completed")
	print("M3_CONTINUATION_COMPLETE checks=",checks," failures=",failures)
	quit(1 if failures else 0)
