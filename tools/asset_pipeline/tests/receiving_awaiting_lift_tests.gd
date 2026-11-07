extends SceneTree

# Catches enlarged occupancy, unfair arrivals and invalid retries.
const Source = preload("res://receiving/prototype_loot_source.gd")
const Planner = preload("res://receiving/receiving_deck_layout_planner.gd")
const Manager = preload("res://receiving/receiving_manager.gd")
const Catalog = preload("res://data/items/item_catalog.tres")
const Pool = preload("res://data/receiving/prototype_loot_pool.tres")
const Profile = preload("res://data/receiving/receiving_deck_stage_b_proof.tres")
const INVALID := 0
const ADMITTED := 1
const AWAITING := 2
var failures := 0
var completed := 0
var owner_script: Script

func _init() -> void:
	run.call_deferred()

func check(ok: bool, message: String) -> void:
	if not ok:
		failures += 1
		push_error("ASSERTION FAILED: " + message)

func run() -> void:
	if ResourceLoader.exists("res://receiving/awaiting_lift_admission.gd"):
		owner_script = load("res://receiving/awaiting_lift_admission.gd")
	check(owner_script != null, "upstream prepared-return admission owner exists")
	if owner_script != null:
		await capacity_and_fairness()
		await invalid_returns()
		await invalid_pending()
		await synchronous_callbacks()
		check(completed == 4, "every test completes without runtime abort")
	print("receiving_awaiting_lift_tests: %s (%d failures)" % ["PASS" if failures == 0 else "FAIL", failures])
	quit(0 if failures == 0 else 1)

func prepared(id: String, seed: int = 1842, profile: Resource = Profile) -> LootBatch:
	var batch: LootBatch = Source.new().generate_committed_batch(Catalog, Pool, id, seed, seed + 7159, 4)
	check(batch != null and Planner.new().prepare(batch, Catalog, profile, 3).succeeded, "deterministic prepared " + id)
	return batch

func setup() -> Dictionary:
	var manager := Manager.new()
	var owner: Node = owner_script.new()
	root.add_child(manager)
	root.add_child(owner)
	check(owner.configure(manager, Catalog, Profile), "configure return owner once")
	check(not owner.configure(manager, Catalog, Profile), "reconfigure cannot discard commitments")
	var events: Array = []
	for signal_name: String in ["return_admitted", "return_awaiting_lift", "return_admitted_after_waiting"]:
		owner.connect(signal_name, func(team: String, batch: String): events.append([signal_name, team, batch]))
	return {"manager": manager, "owner": owner, "events": events}

func fill(f: Dictionary) -> Array[LootBatch]:
	var batches: Array[LootBatch] = []
	f["commitments"] = {}
	for letter: String in ["A", "B", "C", "D", "E"]:
		var batch := prepared(letter, 1842 + batches.size())
		f.commitments[letter] = var_to_bytes(batch.to_snapshot())
		var before := occupancy(f.manager)
		check(f.owner.submit_return("team_" + letter, batch) == (ADMITTED if batches.size() < 3 else AWAITING), "result for team " + letter)
		check(var_to_bytes(batch.to_snapshot()) == f.commitments[letter], "submission preserves original committed layout/content")
		if batches.size() >= 3:
			check(occupancy(f.manager) == before and f.manager.get_deposited_batch(letter) == null, "backpressure leaves manager snapshot/registration untouched")
		batches.append(batch)
	return batches

func occupancy(manager: ReceivingManager) -> PackedByteArray:
	return var_to_bytes({"active": manager.get_active_batch_id(), "queue": manager.get_queued_batch_ids()})

func awaiting_ids(owner: Node) -> Array:
	var result: Array = []
	for record: Dictionary in owner.get_awaiting_returns():
		result.append([record.team_id, record.batch_id, record.status])
	return result

func drain(manager: ReceivingManager) -> void:
	var batch := manager.get_active_batch()
	for entry: LootBatchEntry in batch.entries:
		check(manager.release_entry(batch.batch_id, entry.entry_id, entry.item_instance_id), "active entry releases")

func settle() -> void:
	await process_frame
	await process_frame

func capacity_and_fairness() -> void:
	var f := setup()
	var batches := fill(f)
	var commitment_d := var_to_bytes(batches[3].to_snapshot())
	var commitment_e := var_to_bytes(batches[4].to_snapshot())
	check(f.manager.get_active_batch() == batches[0] and f.manager.get_queued_batch_ids() == PackedStringArray(["B", "C"]), "exactly three deposited slots")
	check(f.manager.get_deposited_batch("D") == null and f.manager.get_deposited_batch("E") == null, "D/E remain outside manager")
	check(awaiting_ids(f.owner) == [["team_D", "D", &"AWAITING_LIFT"], ["team_E", "E", &"AWAITING_LIFT"]], "ordered identity-bearing waitlist")
	var snapshot: Array = f.owner.get_awaiting_returns()
	snapshot[0].batch_id = "changed_copy"
	snapshot.clear()
	check(f.owner.get_return_snapshot("team_D").batch_id == "D", "query copies cannot mutate ownership")
	drain(f.manager)
	await settle()
	check(f.manager.get_active_batch_id() == "A" and f.manager.get_deposited_batch("D") == null, "final TAKE alone does not release occupancy")
	check(f.manager.retire_drained_active_after_close() == "B", "manager promotes B first")
	var sixth := prepared("F", 1847)
	check(f.owner.submit_return("team_F", sixth) == AWAITING, "new F cannot overtake reserved D/E")
	for i in 5:
		f.manager.contents_changed.emit()
	await settle()
	check(f.manager.get_active_batch() == batches[1] and f.manager.get_queued_batch_ids() == PackedStringArray(["C", "D"]), "D enters after C, only one free slot")
	check(f.manager.get_deposited_batch("D") == batches[3] and var_to_bytes(batches[3].to_snapshot()) == commitment_d, "same D object and exact prepared snapshot")
	check(awaiting_ids(f.owner) == [["team_E", "E", &"AWAITING_LIFT"], ["team_F", "F", &"AWAITING_LIFT"]], "E before F")
	drain(f.manager)
	f.manager.retire_drained_active_after_close()
	await settle()
	check(f.manager.get_active_batch() == batches[2] and f.manager.get_queued_batch_ids() == PackedStringArray(["D", "E"]), "successive vacancy admits E after D")
	check(f.manager.get_deposited_batch("E") == batches[4] and var_to_bytes(batches[4].to_snapshot()) == commitment_e, "E commitment survives waiting")
	drain(f.manager)
	f.manager.retire_drained_active_after_close()
	await settle()
	check(f.manager.get_active_batch_id() == "D" and f.manager.get_queued_batch_ids() == PackedStringArray(["E", "F"]), "F follows D/E")
	check(f.owner.get_awaiting_returns().is_empty(), "all waiters admitted")
	var waited_events: Array = f.events.filter(func(e: Array): return e[0] == "return_admitted_after_waiting")
	check(waited_events == [["return_admitted_after_waiting", "team_D", "D"], ["return_admitted_after_waiting", "team_E", "E"], ["return_admitted_after_waiting", "team_F", "F"]], "one admission event per identity in FIFO order")
	check(f.owner.get_return_status("team_D") == &"ADMITTED_RETURNED", "admitted team resolved")
	print("AWAITING_UNIT FIFO A|B,C + D,E -> B|C,D + E,F -> C|D,E + F -> D|E,F")
	f.owner.free()
	f.manager.free()
	completed += 1

func invalid_returns() -> void:
	var f := setup()
	var batches := fill(f)
	var before := occupancy(f.manager)
	var waits := awaiting_ids(f.owner)
	var committed: LootBatch = Source.new().generate_committed_batch(Catalog, Pool, "unprepared", 1, 2, 4)
	var drained := prepared("drained")
	for entry: LootBatchEntry in drained.entries:
		drained.mark_entry_released(entry.entry_id, entry.item_instance_id)
	var foreign := Profile.duplicate(true)
	foreign.profile_id = &"foreign"
	var wrong_revision := Profile.duplicate(true)
	wrong_revision.revision += 1
	var arrangement: LootBatch = Source.new().generate_committed_batch(Catalog, Pool, "arrangement", 1, 2, 4)
	var transforms := {}
	for entry: LootBatchEntry in arrangement.entries:
		transforms[entry.entry_id] = Transform3D.IDENTITY
	check(arrangement.commit_arrangement(transforms, Profile.profile_id, Profile.revision), "arrangement-only prepared test input")
	var invalids: Array = [null, LootBatch.new(), committed, drained, prepared("foreign", 1, foreign), prepared("revision", 1, wrong_revision), arrangement, batches[0], batches[3]]
	for index in invalids.size():
		check(f.owner.submit_return("invalid_%d" % index, invalids[index]) == INVALID, "invalid is not capacity backpressure: %d" % index)
		check(f.owner.get_return_snapshot("invalid_%d" % index).is_empty(), "invalid creates no recurring record")
	check(f.owner.submit_return("team_D", prepared("another")) == INVALID, "duplicate team rejected")
	check(f.owner.submit_return("", prepared("no_team")) == INVALID, "empty team rejected")
	check(occupancy(f.manager) == before and awaiting_ids(f.owner) == waits and f.events.size() == 5, "invalid rejection is atomic and emits no lifecycle success/wait")
	await settle()
	check(occupancy(f.manager) == before and awaiting_ids(f.owner) == waits, "bad inputs never retry")
	f.owner.free()
	f.manager.free()
	completed += 1

func invalid_pending() -> void:
	var f := setup()
	var batches := fill(f)
	var diagnostics: Array = []
	f.owner.return_invalidated.connect(func(team: String, batch: String, reason: String): diagnostics.append([team, batch, reason]))
	var entry: LootBatchEntry = batches[3].entries[0]
	batches[3].mark_entry_released(entry.entry_id, entry.item_instance_id)
	drain(f.manager)
	f.manager.retire_drained_active_after_close()
	await settle()
	check(f.owner.get_return_status("team_D") == &"INVALID_RETURN" and f.manager.get_deposited_batch("D") == null, "unexpected changed commitment fails closed")
	check(diagnostics.size() == 1 and diagnostics[0][0] == "team_D" and diagnostics[0][1] == "D", "one visible identity-bearing diagnostic")
	check(f.manager.get_queued_batch_ids() == PackedStringArray(["C", "E"]), "invalid D cannot spin or wrong-team admit; valid E proceeds")
	f.manager.contents_changed.emit()
	await settle()
	check(diagnostics.size() == 1 and f.owner.get_awaiting_returns().is_empty(), "invalid commitment is never retried")
	f.owner.free()
	f.manager.free()
	completed += 1

func synchronous_callbacks() -> void:
	var f := setup()
	var batches := fill(f)
	drain(f.manager)
	f.manager.retire_drained_active_after_close()
	drain(f.manager)
	f.manager.retire_drained_active_after_close()
	var sixth := prepared("F", 1847)
	var callback_count := [0]
	f.manager.contents_changed.connect(func():
		if f.manager.get_deposited_batch("D") != null and callback_count[0] == 0:
			callback_count[0] += 1
			check(f.owner.submit_return("team_D", batches[3]) == INVALID, "in-flight identity cannot be duplicated")
			check(f.owner.submit_return("team_F", sixth) == AWAITING, "reentrant F stays behind E")
	)
	await settle()
	check(f.manager.get_active_batch_id() == "C" and f.manager.get_queued_batch_ids() == PackedStringArray(["D", "E"]), "coalesced pass fills two real slots without recursion")
	check(awaiting_ids(f.owner) == [["team_F", "F", &"AWAITING_LIFT"]] and callback_count[0] == 1, "synchronous arrival retains FIFO")
	drain(f.manager)
	f.manager.retire_drained_active_after_close()
	await settle()
	check(f.manager.get_queued_batch_ids() == PackedStringArray(["E", "F"]) and f.manager.get_deposited_batch("F") == sixth, "later vacancy admits the exact reentrant F behind E")
	f.owner.free()
	f.manager.free()
	completed += 1
