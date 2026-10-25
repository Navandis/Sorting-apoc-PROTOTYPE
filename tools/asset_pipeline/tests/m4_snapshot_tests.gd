extends SceneTree

var checks := 0
var failures := 0
var output := ""

func _init() -> void:
	create_timer(240).timeout.connect(func():
		push_error("M4 snapshot helper incomplete")
		quit(3))
	run.call_deferred()

func check(ok: bool, message: String) -> bool:
	checks += 1
	if not ok:
		failures += 1
		push_error("ASSERTION FAILED: " + message)
	return ok

func create_wing(state: Dictionary = {}) -> Node:
	var wing = load("res://gameplay/logistics_wing/wing_gameplay.tscn").instantiate()
	if state.is_empty(): wing.configure_new_run()
	else: wing.configure_continue(state)
	wing.set_process(false)
	wing.get_node("Player").enable_held_item_view = false
	root.add_child(wing)
	wing.get_node("Player").set_physics_process(false)
	return wing

func take(wing: Node, lane: String) -> ItemInstance:
	for surface: StorageSurface in wing.get_functional_surfaces():
		for stack: StorageStack in surface._stacks.values():
			var entry: StorageStack.Entry = stack.entries[-1]
			if String(entry.item.definition.utility_id) == lane:
				var item := entry.item
				check(entry.world_item.pickup_into(wing.get_node("Player/CarriedItems")), "Real seeded supply retrieved: " + lane)
				return item
	check(false,"No accessible seeded supply for " + lane)
	return null

func save_phase(wing: Node, name: String) -> void:
	var snapshot = load("res://gameplay/run/run_snapshot.gd").new()
	var state: Dictionary = snapshot.capture(wing)
	check(snapshot.validate(state).is_empty(),name+" snapshot validates: "+snapshot.validate(state))
	var service = load("res://gameplay/run/run_save_service.gd").new(output.path_join(name))
	check(service.save_snapshot(state).ok, "Production single-slot service saves isolated " + name)

func run() -> void:
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--m4-save-dir="): output = arg.trim_prefix("--m4-save-dir=")
	if not check(output.is_absolute_path() and not output.begins_with(ProjectSettings.globalize_path("res://")),"Explicit external continuation directory required"):
		finish()
		return
	var snapshot = load("res://gameplay/run/run_snapshot.gd").new()
	if OS.get_cmdline_user_args().has("--read"):
		for name: String in ["partial","mixed","cutoff","report"]:
			var service = load("res://gameplay/run/run_save_service.gd").new(output.path_join(name))
			var loaded: Dictionary = service.load_snapshot()
			if not check(loaded.ok,"Separate process reads " + name): continue
			var wing := create_wing(loaded.snapshot)
			check(snapshot.restore(wing,loaded.snapshot).is_empty(), "Staged restore succeeds: " + name)
			var restored: Dictionary = snapshot.capture(wing)
			check(restored == loaded.snapshot,"Exact physical/request/clock/velocity continuation: " + name)
			var before: Dictionary = wing.run_schedule.capture_state()
			wing.run_schedule.advance(0.0)
			check(wing.run_schedule.capture_state() == before,"No reactivation or redispatch on Continue: " + name)
			if name in ["mixed","cutoff","report"]: check(wing.get_node("Player").is_ladder_attached(),"Exact same-ladder attachment restored: " + name)
			if name == "report":
				check(wing.run_schedule.phase == "REPORT_PENDING" and wing.run_schedule.report.dispatch.size() == 4,"Completed-day facts restored under report hold")
				wing.run_schedule.begin_day()
				check(wing.run_schedule.requests.size() == before.requests.size(),"Report acceptance does not instantiate teams again")
			wing.free()
		finish()
		return
	var wing := create_wing()
	var state: Dictionary = snapshot.capture(wing)
	if not check(state.get("schema") == 4,"M4 snapshot schema covers concurrent loadouts"):
		wing.free()
		finish()
		return
	check(snapshot.validate(state).is_empty(),"Initial 85-item/four-team snapshot validates: "+snapshot.validate(state))
	var team: RefCounted = wing.run_schedule.dispatch_requests()[0]
	var carry: CarriedItems = wing.get_node("Player/CarriedItems")
	take(wing,"Food")
	check(team.submit(carry).ok,"Real supply provisioned irreversibly")
	wing.get_node("Player").velocity = Vector3(0.5,0,-0.25)
	save_phase(wing,"partial")
	check(wing.run_schedule.dispatch_requests()[1].dispatch_underprepared(),"Empty team deliberately dispatches before save")
	var surface = wing.get_functional_surfaces()[0]
	surface.set_custom_display_name("Continuing M4 supplies")
	surface.clear_all_zones()
	var player = wing.get_node("Player")
	var ladder: Node3D = get_nodes_in_group("fixed_ladders").filter(wing.is_ancestor_of)[0]
	var anchor: Vector3 = ladder.get_climb_anchor_world_position()
	player.global_position = Vector3(anchor.x,ladder.global_position.y+0.8,anchor.z)
	player.rotation.y = ladder.get_ladder_yaw_world()
	player._attached_ladder = ladder
	player._movement_state = 1
	player._ladder_anchor_xz = Vector2(anchor.x,anchor.z)
	player._ladder_yaw_center = ladder.get_ladder_yaw_world()
	player._pitch = -0.22
	player.camera.rotation.x = -0.22
	player.velocity = Vector3.ZERO
	save_phase(wing,"mixed")
	state = snapshot.capture(wing)
	for mutation: String in ["members","bulk","credit","result","identity","duplicate"]:
		var corrupt: Dictionary = state.duplicate(true)
		match mutation:
			"members": corrupt.schedule.requests[0].members = 3
			"bulk": corrupt.schedule.requests[0].outgoing_bulk -= 1
			"credit": corrupt.schedule.requests[0].credited.Food += 1
			"result": corrupt.schedule.requests[1].dispatch_result.return_capacity -= 1
			"identity": corrupt.schedule.requests[1].id = corrupt.schedule.requests[0].id
			"duplicate": corrupt.schedule.requests[1].spent = corrupt.schedule.requests[0].spent.duplicate(true)
		check(not snapshot.validate(corrupt).is_empty(),"Reject inconsistent " + mutation + " before live replacement")
	var old: Dictionary = state.duplicate(true)
	old.schema = 3
	check(snapshot.validate(old).contains("M4"),"Prior schema rejects explainably without migration")
	wing.run_schedule.advance(150.0)
	var already_spent: String = team.spent[0].item_id
	var medical_duplicate := ItemInstance.new(load("res://data/items/definitions/loot_000025.tres"),already_spent)
	carry.add_item(medical_duplicate)
	check(not wing.run_schedule.active_request("medical_bay").submit(carry).ok and carry.get_selected_item() == medical_duplicate,"Global spent identity cannot be resubmitted to Medical")
	carry.remove_item(medical_duplicate)
	wing.run_schedule.advance(450.0)
	var kitchen_duplicate := ItemInstance.new(load("res://data/items/definitions/loot_000006.tres"),already_spent)
	carry.add_item(kitchen_duplicate)
	check(not wing.run_schedule.active_request("kitchen").submit(carry).ok and carry.get_selected_item() == kitchen_duplicate,"Global spent identity cannot be resubmitted to Kitchen")
	carry.remove_item(kitchen_duplicate)
	var runtime = wing.get_node("ReceivingRuntime")
	var small: Array = runtime.deck_presenter.get_materialized_world_items().filter(func(w): return w.get_item_instance().get_bulk() <= 2)
	check(small.size() >= 2,"Real OPEN delivery contains two legal small continuation items")
	for index: int in mini(2,small.size()): check(small[index].pickup_into(carry),"Partially unload exact Receiving cargo before continuation")
	save_phase(wing,"cutoff")
	var teams: Array = wing.run_schedule.dispatch_requests()
	check(teams.all(func(t): return t.closed),"All cutoff teams terminal")
	wing.run_schedule.advance(2100.0)
	save_phase(wing,"report")
	check(wing.run_schedule.report.dispatch.size() == 4 and wing.run_schedule.dispatch_requests().size() == 4,"Report and next-day teams remain separate")
	wing.free()
	finish()

func finish() -> void:
	print("M4_SNAPSHOT_COMPLETE mode=","read" if OS.get_cmdline_user_args().has("--read") else "write"," checks=",checks," failures=",failures)
	quit(1 if failures else 0)
