extends RefCounted

const Config = preload("res://gameplay/expeditions/expedition_config.gd")
const Loadout = preload("res://gameplay/expeditions/expedition_loadout.gd")
const Acquisition = preload("res://gameplay/expeditions/expedition_acquisition.gd")
const Outcomes = preload("res://gameplay/expeditions/expedition_outcomes.gd")
const Medical = preload("res://gameplay/medical/medical_recovery.gd")
const AWAY := "away"
const WAITING := "awaiting_lift"
const COMPLETE := "complete"
const ID_KIND := "expedition"

signal changed

var ready_count := Config.READY_START
var members := Config.DEFAULT_MEMBERS
var affinities: Array[String] = []
var loadout := Loadout.new(Config.DEFAULT_MEMBERS)
var journeys: Dictionary = {}
var revision := 0
var rng := RandomNumberGenerator.new()
var medical := Medical.new()
var error := ""
var last_empty_return_at := -INF
var other_consumer_has_spent: Callable

var _identity: RefCounted
var _clock: RefCounted
var _runtime: ReceivingRuntime
var _pool: Dictionary
var _away_by_destination: Dictionary = {}
var _active: Dictionary = {}
var _away_cargo: Dictionary = {}
var _spent_ids: Dictionary = {}
var _recent_handovers: Array[String] = []

func has_spent_item(item_id: String) -> bool:
	return _spent_ids.has(item_id)

func _item_is_spent(item_id: String) -> bool:
	return has_spent_item(item_id) or (other_consumer_has_spent.is_valid() and other_consumer_has_spent.call(item_id))

func _init(identity: RefCounted, clock: RefCounted) -> void:
	_identity = identity
	_clock = clock
	rng.randomize()

func bind(runtime: ReceivingRuntime) -> String:
	if runtime.return_admission == null or not runtime.lift_cycle.is_configured():
		return "Receiving failed to initialize"
	_pool = Acquisition.build_pool(runtime.item_catalog)
	if _pool.is_empty():
		return "Expedition could not validate the active item catalogue"
	_runtime = runtime
	runtime.return_admission.commit_handover = _on_handover_committed
	runtime.return_admission.return_admitted.connect(_on_admitted)
	runtime.return_admission.return_admitted_after_waiting.connect(_on_admitted)
	runtime.return_admission.return_invalidated.connect(_on_invalidated)
	return ""

func is_formed() -> bool:
	return not loadout.request_id.is_empty()

func can_prepare_crew() -> bool:
	return is_formed() or ready_count > 0

func set_members(count: int) -> bool:
	if is_formed() or count < 1 or count > mini(Config.MAX_MEMBERS, ready_count):
		return false
	if count != members:
		members = count
		loadout = Loadout.new(members)
		_edited()
	return true

func return_capacity() -> int:
	return loadout.raw_capacity - loadout.submitted_bulk()

func selected_destination() -> String:
	return Config.pair_id(affinities[0], affinities[1]) if affinities.size() == 2 else ""

func destination_busy(id: String) -> bool:
	return _away_by_destination.has(id)

func can_toggle_affinity(category: String) -> bool:
	if not can_prepare_crew() or not Config.CATEGORIES.has(category):
		return false
	if affinities.has(category):
		return true
	if affinities.size() == 2:
		return false
	var partners := Config.CATEGORIES if affinities.is_empty() else affinities
	for partner: String in partners:
		var id := Config.pair_id(partner, category)
		if not id.is_empty() and not destination_busy(id):
			return true
	return false

func toggle_affinity(category: String) -> bool:
	if not can_toggle_affinity(category):
		return false
	if affinities.has(category):
		affinities.erase(category)
	else:
		affinities.append(category)
	_edited()
	return true

func preview(item: ItemInstance) -> Dictionary:
	var proposed := loadout.preview(item)
	if proposed.status == "eligible":
		if _item_is_spent(item.instance_id):
			proposed.status = "ineligible"
			proposed.reason = "spent"
		elif not _crew_available():
			proposed.status = "ineligible"
			proposed.reason = "crew"
	return proposed

func contribute(carry: Node) -> Dictionary:
	var item: ItemInstance = carry.get_selected_item()
	var proposed := preview(item)
	if proposed.status != "eligible":
		return {"ok": false, "reason": proposed.reason}
	var submitted := loadout.submit(carry,
		func(): return _crew_available() and not _item_is_spent(item.instance_id),
		_record_supply)
	if submitted.ok:
		changed.emit()
	return submitted

func _record_supply() -> void:
	var receipt: Dictionary = loadout.spent.back()
	receipt["at"] = _clock.elapsed
	_spent_ids[receipt.item_id] = true
	if not is_formed():
		_form_crew()
	revision += 1

func _form_crew() -> void:
	loadout.request_id = _identity.allocate(ID_KIND)
	ready_count -= members

func _crew_available() -> bool:
	return is_formed() or members <= ready_count

func dispatch_error() -> String:
	if not _crew_available():
		return "Choose a crew from the available Ready scavengers." if can_prepare_crew() else "Wait for a scavenger to become Ready."
	var id := selected_destination()
	if id.is_empty():
		return "Select two distinct supply affinities."
	if destination_busy(id):
		return "This destination has a crew away. Wait for its return or change the pair."
	if loadout.transaction_active:
		return "The current contribution is settling."
	return ""

func dispatch(expected_revision: int, confirm_empty_capacity: bool = false) -> Dictionary:
	if expected_revision != revision:
		return {"ok": false, "error": "Preparation changed. Review it before dispatching."}
	var invalid := dispatch_error()
	if not invalid.is_empty():
		return {"ok": false, "error": invalid}
	if not error.is_empty() or not is_instance_valid(_runtime):
		return {"ok": false, "error": "Expedition operations are unavailable."}
	var capacity := return_capacity()
	if capacity == 0 and not confirm_empty_capacity:
		return {"ok": false, "confirm": true}

	# Stage the outcome and layout before spending a sequence or forming a crew.
	var id: String = loadout.request_id if is_formed() else _identity.next_id(ID_KIND)
	var before_draw := rng.state
	var seeds := Outcomes.draw_seeds(rng)
	var outcome := Outcomes.resolve(members, loadout.credited, capacity, affinities, seeds, _pool)
	var manifest: Array[String] = outcome.manifest
	var batch_id := ""
	if not manifest.is_empty():
		batch_id = cargo_id(id)
		var batch := _runtime.prepare_expedition_manifest(manifest, id, outcome.presentation_seed, batch_id)
		if batch == null:
			rng.state = before_draw
			print("Expedition preparation rejected: ", id, " destination=", selected_destination(),
				" ordinary=", outcome.ordinary_count, " seeds=", seeds, " manifest=", manifest)
			return {"ok": false, "error": "Cargo could not be prepared. Departure did not commit."}
		_away_cargo[batch_id] = batch
	if not is_formed():
		_form_crew()
	var destination := selected_destination()
	var departed_at: float = _clock.elapsed
	var journey := outcome
	journey.merge({"members": members, "destination": destination, "departed_at": departed_at,
		"return_at": departed_at + outcome.duration, "handover_at": -1.0, "status": AWAY,
		"loadout": loadout.capture_state(), "batch_id": batch_id, "seeds": seeds})
	journeys[id] = journey
	_active[id] = journey
	_away_by_destination[destination] = id
	members = Config.DEFAULT_MEMBERS
	affinities.clear()
	loadout = Loadout.new(members)
	_edited()
	return {"ok": true, "id": id}

static func sequence(id: String) -> int:
	return int(id.get_slice(":", 2))

static func cargo_id(id: String) -> String:
	return "%s:cargo:%s" % [id.get_slice(":", 0), id.get_slice(":", 2)]

func next_return_at() -> float:
	var id := _next_away()
	return INF if id.is_empty() else journeys[id].return_at

func _next_away() -> String:
	var next := ""
	var earliest := INF
	for id: String in _away_by_destination.values():
		var at: float = journeys[id].return_at
		if at < earliest or (at == earliest and sequence(id) < sequence(next)):
			next = id
			earliest = at
	return next

func return_due() -> void:
	while error.is_empty():
		var id := _next_away()
		if id.is_empty() or journeys[id].return_at > _clock.elapsed:
			return
		_return_crew(id)

func _return_crew(id: String) -> void:
	var journey: Dictionary = journeys[id]
	_away_by_destination.erase(journey.destination)
	var batch_id: String = journey.batch_id
	if batch_id.is_empty():
		last_empty_return_at = journey.return_at
		_complete(id, journey.return_at)
		changed.emit()
		return
	journey.status = WAITING
	var batch: LootBatch = _away_cargo[batch_id]
	_away_cargo.erase(batch_id)
	var result := _runtime.return_admission.submit_return(id, batch)
	match result:
		AwaitingLiftAdmission.ReturnResult.INVALID:
			# Keep the commitment in the faulted run. The crew remains unavailable.
			_away_cargo[batch_id] = batch
			_on_invalidated(id, batch_id, "Rejected at handover")
		AwaitingLiftAdmission.ReturnResult.AWAITING:
			changed.emit()

func _on_handover_committed(id: String, batch_id: String) -> void:
	var journey: Dictionary = _active.get(id, {})
	if journey.get("status") == WAITING and journey.batch_id == batch_id \
			and _runtime.return_admission.get_return_status(id) == AwaitingLiftAdmission.ADMITTED_RETURNED:
		_complete(id, _clock.elapsed)

func _on_admitted(id: String, batch_id: String) -> void:
	var journey: Dictionary = journeys.get(id, {})
	if journey.get("status") == COMPLETE and journey.batch_id == batch_id:
		changed.emit()

func _complete(id: String, at: float) -> void:
	var journey: Dictionary = journeys[id]
	var totals := Outcomes.summarize(journey.originals)
	for index in journey.originals.size():
		var health: String = journey.originals[index].health
		if health != Outcomes.HEALTHY:
			medical.admit(id, index, health, at)
	ready_count += totals.healthy + totals.recruits
	journey.status = COMPLETE
	journey.handover_at = at
	_active.erase(id)
	_remember_handover(id)

func settle_recovery() -> bool:
	var recovered := medical.settle_due(_clock.elapsed)
	ready_count += recovered
	return recovered > 0

func _on_invalidated(id: String, batch_id: String, reason: String) -> void:
	if error.is_empty() and _active.has(id):
		error = "Expedition %s could not hand over %s. %s" % [id, batch_id, reason]
		push_error(error)

func active_ids() -> Array:
	return _active.keys()

func recent_handover_ids() -> Array[String]:
	return _recent_handovers

func _remember_handover(id: String) -> void:
	_recent_handovers.push_front(id)
	if _recent_handovers.size() > 6:
		_recent_handovers.pop_back()

static func config_signature() -> Dictionary:
	var signature := Config.signature()
	signature.natural_recovery = [Medical.LIGHT_SECONDS, Medical.SEVERE_SECONDS]
	return signature

func _edited() -> void:
	revision += 1
	changed.emit()

func capture_state() -> Dictionary:
	var cargo := {}
	for id: String in _away_cargo:
		cargo[id] = _away_cargo[id].to_snapshot()
	return {"config": config_signature(), "ready": ready_count, "rng_state": rng.state,
		"medical": medical.capture_state(),
		"draft": {"members": members, "affinities": affinities.duplicate(), "loadout": loadout.capture_state()},
		"journeys": journeys.duplicate(true), "away_cargo": cargo}

func restore_state(state: Dictionary) -> void:
	ready_count = state.ready
	rng.state = state.rng_state
	medical.restore_state(state.medical)
	members = state.draft.members
	affinities.assign(state.draft.affinities)
	loadout = Loadout.new(members)
	loadout.restore_state(state.draft.loadout.duplicate(true))
	journeys = state.journeys.duplicate(true)
	var completed: Array[String] = []
	for id: String in journeys:
		var journey: Dictionary = journeys[id]
		if journey.status == AWAY:
			_away_by_destination[journey.destination] = id
		if journey.status != COMPLETE:
			_active[id] = journey
		else:
			completed.append(id)
			if journey.batch_id.is_empty():
				last_empty_return_at = maxf(last_empty_return_at, journey.return_at)
		_index_receipts(journey.loadout.spent)
	completed.sort_custom(func(a: String, b: String):
		var first: Dictionary = journeys[a]
		var second: Dictionary = journeys[b]
		if first.handover_at != second.handover_at:
			return first.handover_at < second.handover_at
		return first.return_at < second.return_at or (first.return_at == second.return_at and sequence(a) < sequence(b)))
	for id: String in completed:
		_remember_handover(id)
	_index_receipts(loadout.spent)
	for batch_id: String in state.away_cargo:
		_away_cargo[batch_id] = LootBatch.from_snapshot(state.away_cargo[batch_id])

func _index_receipts(receipts: Array) -> void:
	for receipt: Dictionary in receipts:
		_spent_ids[receipt.item_id] = true
