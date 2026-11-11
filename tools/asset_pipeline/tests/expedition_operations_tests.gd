extends SceneTree

const WingScene = preload("res://gameplay/logistics_wing/wing_gameplay.tscn")
const Config = preload("res://gameplay/expeditions/expedition_test_config.gd")
const Snapshot = preload("res://gameplay/run/run_snapshot.gd")

var failures := 0
var wing: Node3D
var carry: CarriedItems

func _initialize() -> void:
	create_timer(120).timeout.connect(func(): quit(3))
	run.call_deferred()

func run() -> void:
	wing = WingScene.instantiate()
	wing.configure_new_run()
	wing.get_node("Player").enable_held_item_view = false
	root.add_child(wing)
	wing.set_process(false)
	carry = wing.get_node("Player/CarriedItems")
	if not check("expeditions" in wing and wing.expeditions != null, "normal New Run owns an expedition preparation"):
		finish()
		return
	var ops: RefCounted = wing.expeditions
	var runtime: ReceivingRuntime = wing.get_node("ReceivingRuntime")
	check_sampler(runtime.item_catalog)
	check(wing.get_initialization_error().is_empty(), "asset-equipped expedition run initializes")
	check(ops.ready_count == 8 and ops.members == 1 and ops.affinities.is_empty(), "fresh draft has one unreserved member and no affinities")
	for count in range(1, 5):
		check(ops.set_members(count) and ops.return_capacity() == 8 * count, "draft count scales raw Bulk")
	check(not ops.set_members(5) and not ops.set_members(0) and ops.ready_count == 8, "invalid counts cannot change the roster")
	ops.set_members(1)
	check(not ops.dispatch(ops.revision).ok, "no affinity cannot dispatch")
	check(ops.toggle_affinity("Food") and not ops.dispatch(ops.revision).ok, "one affinity cannot dispatch")
	check(ops.toggle_affinity("Electronics"), "distinct second affinity is selectable")
	var pair: String = ops.selected_destination()
	check(ops.toggle_affinity("Food") and ops.toggle_affinity("Electronics"), "selected buttons deselect even with a complete pair")
	check(ops.toggle_affinity("Electronics") and ops.toggle_affinity("Food") and ops.selected_destination() == pair, "swapped click order identifies the same destination")
	check(ops.toggle_affinity("Food"), "formed crew can have a partial destination later")

	var mouse := take_seed("Electronics_Mouse")
	if mouse == null:
		mouse = take_definition("loot_000001")
	check(mouse != null and not ops.contribute(carry).ok and not ops.is_formed() and ops.ready_count == 8 and carry.get_items().has(mouse), "wrong-category first supply spends nothing and does not form")
	var bulky := take_definition("loot_000011")
	check(bulky != null and not ops.contribute(carry).ok and not ops.is_formed() and ops.return_capacity() == 8, "over-capacity first supply spends nothing")
	var cereal := take_definition("loot_000007")
	var preview: Dictionary = ops.preview(cereal)
	check(preview.applied == 5 and preview.wasted == 7 and preview.bulk == 2 and ops.ready_count == 8, "preview shows capped credit, waste and full Bulk without formation")
	var receipt_seen := [false]
	carry.item_removed.connect(func(item: ItemInstance):
		receipt_seen[0] = item == cereal and ops.ready_count == 7 and ops.is_formed() and ops.loadout.spent.size() == 1,
		CONNECT_ONE_SHOT)
	check(ops.contribute(carry).ok and receipt_seen[0] and ops.return_capacity() == 6, "first receipt and crew formation precede carry notifications")
	var locked_id: String = ops.loadout.request_id
	check(not ops.set_members(2) and ops.members == 1 and ops.loadout.request_id == locked_id, "formed count and identity stay locked")
	var potato := take_definition("loot_000008")
	check(not ops.contribute(carry).ok and carry.get_items().has(potato) and ops.loadout.spent.size() == 1, "full lane rejects a whole item without spending")
	carry.remove_item(bulky)
	for id in ["loot_000019", "loot_000025", "loot_000039", "loot_000033"]:
		take_definition(id)
		check(ops.contribute(carry).ok and ops.loadout.request_id == locked_id, "accepted supply reuses the same formed crew")
	check(ops.return_capacity() == 0 and ops.loadout.closed and ops.journeys.is_empty() and ops.is_formed(), "fully supplied crew remains editable before dispatch")
	check(ops.toggle_affinity("Weapons") and ops.selected_destination() != pair, "destination remains editable after formation")
	var revision: int = ops.revision
	var warning: Dictionary = ops.dispatch(revision)
	check(warning.get("confirm", false) and ops.journeys.is_empty() and ops.ready_count == 7, "zero capacity asks for confirmation without sending")
	check(ops.toggle_affinity("Weapons") and not ops.dispatch(revision, true).ok, "stale confirmation cannot send an edited draft")
	check(ops.toggle_affinity("Weapons"), "reselect second affinity")
	revision = ops.revision
	var sent: Dictionary = ops.dispatch(revision, true)
	check(sent.ok and sent.get("id") == locked_id and ops.ready_count == 7 and not ops.is_formed(), "confirmed departure neither reforms nor spends twice")
	check(not ops.dispatch(revision, true).ok and ops.journeys.size() == 1, "repeated confirmed dispatch is inert")
	check(ops.set_members(4) and ops.toggle_affinity("Food") and ops.toggle_affinity("Hydration"), "next crew can be drafted immediately")
	ops.rng.seed = 4127
	var second: Dictionary = ops.dispatch(ops.revision)
	check(second.ok and ops.ready_count == 3 and not ops.set_members(4), "zero-loadout dispatch forms once and next draft cannot select unavailable count")
	if second.ok:
		var trip: Dictionary = ops.journeys[second.id]
		check(trip.duration >= 90.0 and trip.duration <= 180.0 and trip.return_at == trip.departed_at + trip.duration, "successful dispatch commits an exact return deadline")
		check(trip.manifest.size() <= 16 and not trip.manifest.is_empty(), "four-member manifest fits bounded pool")
	check(ops.set_members(3), "the remaining three Ready can form a crew")
	carry.select_index(carry.get_slots().find(potato))
	check(ops.contribute(carry).ok and ops.ready_count == 0 and ops.is_formed(), "accepted supply reserves the last Ready members")
	check(ops.toggle_affinity("Medical") and ops.toggle_affinity("Morale"), "formed crew keeps a valid destination at zero Ready")
	var before: Dictionary = ops.capture_state()
	var sequence: int = wing.run_identity.next_sequence
	var profile := runtime.deck_profile
	runtime.deck_profile = null
	var rejected: Dictionary = ops.dispatch(ops.revision)
	runtime.deck_profile = profile
	check(not rejected.ok and rejected.error.contains("Cargo could not be prepared") and ops.capture_state() == before
		and wing.run_identity.next_sequence == sequence, "presentation failure preserves the committed draft and draw without publishing Away")
	check(ops.dispatch(ops.revision).ok and ops.ready_count == 0, "formed crew dispatches without requiring its members twice")
	check(not ops.set_members(1) and not ops.dispatch(ops.revision).ok, "fresh preparation cannot reserve unavailable crew")
	var empty: Dictionary = ops.capture_state()
	revision = ops.revision
	var editable: bool = ops.can_toggle_affinity("Fuel")
	var toggled: bool = ops.toggle_affinity("Fuel")
	check(not editable and not toggled and ops.capture_state() == empty and ops.revision == revision,
		"empty preparation rejects affinity edits at the operation boundary")
	var malformed := Snapshot.new().capture(wing)
	var batch: Dictionary = malformed.expeditions.away_cargo.values()[0]
	var group: String = batch.entries[0].presentation_stack_group_id
	for entry: Dictionary in batch.entries:
		if entry.presentation_stack_group_id == group:
			entry.presentation_cell_origin = Vector2i(999, 999)
	check(Snapshot.new().validate(malformed).contains("deck"), "an Away commitment outside the deck is rejected before restore")
	var observed: Array[int] = []
	runtime.receiving_manager.contents_changed.connect(func():
		observed.append(ops.ready_count)
		for active_id: String in ops.active_ids():
			check(runtime.return_admission.get_return_status(active_id) != AwaitingLiftAdmission.ADMITTED_RETURNED,
				"deposit notification sees coherent cargo and personnel ownership"))
	wing.run_timeline.advance(220.0)
	check(observed.size() == 2 and ops.ready_count == 8, "two cargo deposits and an empty return settle the whole roster")
	finish()

func check_sampler(catalog: ItemCatalog) -> void:
	var destinations := {}
	for first: String in Config.CATEGORIES:
		for second: String in Config.CATEGORIES:
			var pair := Config.pair_id(first, second)
			if first == second:
				check(pair.is_empty(), "an affinity cannot pair with itself")
			else:
				check(pair == Config.pair_id(second, first) and Config.valid_destination(pair), "unordered canonical pair")
				destinations[pair] = true
	check(destinations.size() == 28, "exactly 28 destinations")
	var affinities := ["Electronics", "Food"]
	var weights := Config.category_weights(affinities)
	check(weights == {"Electronics": 9, "Food": 9, "Fuel": 7, "Hydration": 7,
		"Medical": 7, "Morale": 7, "Protection": 7, "Weapons": 7},
		"exact 9/60, 9/60 and six 7/60 category weights")
	check(Config.category_weights(affinities, ["Food", "Fuel"]) == {"Food": 9, "Fuel": 7},
		"fit masking leaves the relative weights unchanged")
	var pool := Config.build_pool(catalog)
	var rng := RandomNumberGenerator.new()
	var independent := RandomNumberGenerator.new()
	for seed_value in 16:
		rng.seed = 1000 + seed_value
		independent.seed = rng.seed
		var ticket := independent.randi_range(0, 50) # 9 + 6 × 7. Electronics cannot fit B2.
		var fitting := ["Food", "Fuel", "Hydration", "Medical", "Morale", "Protection", "Weapons"]
		var category: String = "Food" if ticket < 9 else fitting[1 + floori(float(ticket - 9) / 7.0)]
		var choices: Array = pool[category].filter(func(item: ItemDefinition): return item.bulk == 2)
		var wanted: String = String(choices[independent.randi_range(0, choices.size() - 1)].item_id)
		check(Config.sample_manifest(2, affinities, rng, pool) == [wanted], "category-first fitting draw and uniform item index")
	check(Config.sample_manifest(1, affinities, rng, pool).is_empty(), "positive unfillable residual stops cleanly")

func take_seed(host: String) -> ItemInstance:
	var world: Node = wing.get_node_or_null("DevelopmentSetup/SeedItems/" + host + "/WorldItem")
	if world == null:
		return null
	var item: ItemInstance = world.get_item_instance()
	if world.pickup_into(carry):
		carry.select_index(carry.get_slots().find(item))
		return item
	return null

func take_definition(id: String) -> ItemInstance:
	var definition := PrototypeItemCatalog.get_definition_by_id(StringName(id))
	for host: Node in wing.get_node("DevelopmentSetup/SeedItems").get_children():
		if host.get("item_id") == definition.item_id and host.has_node("WorldItem"):
			return take_seed(host.name)
	check(false, "required authored seed is available: " + id)
	return null

func check(ok: bool, message: String) -> bool:
	if not ok:
		failures += 1
		printerr("FAIL: " + message)
	return ok

func finish() -> void:
	wing.free()
	print("expedition_operations_tests: ", "PASS" if failures == 0 else "FAIL", " failures=", failures)
	quit(0 if failures == 0 else 1)
