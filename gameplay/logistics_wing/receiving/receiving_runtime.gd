extends Node3D
class_name ReceivingRuntime

const DeckPlannerScript = preload("res://receiving/receiving_deck_layout_planner.gd")
const LootSourceScript = preload("res://receiving/prototype_loot_source.gd")
const AdmissionScript = preload("res://receiving/awaiting_lift_admission.gd")

const DEFAULT_CONTENT_SEED: int = 1842
const DEFAULT_PRESENTATION_SEED: int = 9001
const DEFAULT_TARGET_BULK: int = 24
const SECOND_CONTENT_SEED: int = 1843
const SECOND_PRESENTATION_SEED: int = 9002

@export var item_catalog: ItemCatalog
@export var prototype_loot_pool: PrototypeLootPool
@export var deck_profile: Resource

@onready var receiving_manager: ReceivingManager = $ReceivingManager
@onready var deck_presenter: Node3D = $ReceivingDeckPresenter
@onready var lift_cycle: Node3D = $ReceivingLiftCycle

var return_admission: Node
var _awaiting_debug_started := false
var _waiting_debug_batch: LootBatch
var _debug_first_batch_id := ""


func _ready() -> void:
	if not deck_presenter.call("configure", receiving_manager, item_catalog, deck_profile):
		push_error("Receiving runtime could not configure its deterministic deck presenter.")
		return
	var installation := get_node_or_null("../ReceivingLiftInstallation") as Node3D
	# Runtime can still be inspected alone; physical deliveries fail closed without art.
	if installation != null and not lift_cycle.configure(
		receiving_manager, deck_presenter, installation,
		get_node_or_null("../Environment/ReceivingLighting/WarningFixtures/W1/Fixture/Mesh"),
		get_node_or_null("../ReceivingLiftMonitor/PhosphorDisplay"),
		get_node_or_null("../Environment/ReceivingReflections")
	):
		push_error("Receiving runtime could not configure its lift installation.")
		return
	return_admission = AdmissionScript.new()
	return_admission.name = "AwaitingLiftAdmission"
	add_child(return_admission)
	if not return_admission.configure(receiving_manager, item_catalog, deck_profile):
		push_error("Receiving runtime could not configure upstream return admission.")
		return
	_run_cli_debug_delivery.call_deferred()


func _run_cli_debug_delivery() -> void:
	var arguments := OS.get_cmdline_user_args()
	if not arguments.has("--receiving-deck-debug"):
		return
	if arguments.has("--receiving-awaiting-lift-debug"):
		if not run_awaiting_lift_debug_delivery(
			_numeric_flag(arguments, "--receiving-target-bulk", DEFAULT_TARGET_BULK),
			_fixture_mode_flag(arguments)
		):
			push_error("Receiving Awaiting Lift debug returns failed before admission.")
		return
	if arguments.has("--receiving-two-batch-debug"):
		if not run_two_batch_debug_delivery(_fixture_mode_flag(arguments)):
			push_error("Receiving two-batch debug delivery failed before admission.")
		return
	var content_seed := _numeric_flag(arguments, "--receiving-content-seed", DEFAULT_CONTENT_SEED)
	var presentation_seed := _numeric_flag(arguments, "--receiving-presentation-seed", DEFAULT_PRESENTATION_SEED)
	var target_bulk := _numeric_flag(arguments, "--receiving-target-bulk", DEFAULT_TARGET_BULK)
	var fixture_mode := _fixture_mode_flag(arguments)
	if fixture_mode < 0:
		push_error("Receiving debug delivery rejected unknown --receiving-fixture-mode value.")
		return
	if not run_debug_delivery(content_seed, presentation_seed, target_bulk, fixture_mode):
		push_error("Receiving debug delivery failed before deposit.")


func run_debug_delivery(
	content_seed: int = DEFAULT_CONTENT_SEED,
	presentation_seed: int = DEFAULT_PRESENTATION_SEED,
	target_bulk: int = DEFAULT_TARGET_BULK,
	fixture_mode: int = DeckPlannerScript.FixtureMode.BARE
) -> bool:
	if item_catalog == null or prototype_loot_pool == null or deck_profile == null or target_bulk <= 0:
		return false
	if fixture_mode < DeckPlannerScript.FixtureMode.BARE or fixture_mode > DeckPlannerScript.FixtureMode.MIXED:
		return false
	if not lift_cycle.is_configured() or lift_cycle.is_busy() or receiving_manager.get_active_batch() != null:
		return false
	var batch := _prepare_debug_batch(content_seed, presentation_seed, target_bulk, fixture_mode)
	if batch == null or not receiving_manager.deposit_batch(batch):
		return false
	return lift_cycle.get_cycle_state() == ReceivingLiftCycle.State.ARRIVAL


## Explicit reproducible demonstration; the single-delivery busy guard stays intact.
## Prepared B owns no queue slot until A is independently OPEN.
func run_two_batch_debug_delivery(
	fixture_mode: int = DeckPlannerScript.FixtureMode.BARE
) -> bool:
	if _waiting_debug_batch != null or not lift_cycle.is_configured() or lift_cycle.is_busy() or receiving_manager.get_active_batch() != null:
		return false
	var second := _prepare_debug_batch(
		SECOND_CONTENT_SEED, SECOND_PRESENTATION_SEED, DEFAULT_TARGET_BULK, fixture_mode
	)
	if second == null:
		return false
	if not run_debug_delivery(DEFAULT_CONTENT_SEED, DEFAULT_PRESENTATION_SEED, DEFAULT_TARGET_BULK, fixture_mode):
		return false
	_waiting_debug_batch = second
	_debug_first_batch_id = receiving_manager.get_active_batch_id()
	lift_cycle.state_changed.connect(_on_debug_first_batch_open)
	return true


func _on_debug_first_batch_open(state: ReceivingLiftCycle.State) -> void:
	if state != ReceivingLiftCycle.State.OPEN or receiving_manager.get_active_batch_id() != _debug_first_batch_id:
		return
	# Disconnect and clear first: a deposit emits synchronous readout signals.
	lift_cycle.state_changed.disconnect(_on_debug_first_batch_open)
	var waiting := _waiting_debug_batch
	_waiting_debug_batch = null
	_debug_first_batch_id = ""
	if not receiving_manager.deposit_batch(waiting):
		push_error("Receiving debug queued deposit rejected; committed B was not rerolled.")


## Separate opt-in prototype returns. Prepare all four before any deposit.
## Stable demo IDs are one-shot per runtime; no actual Expedition roster exists.
func run_awaiting_lift_debug_delivery(
	target_bulk: int = DEFAULT_TARGET_BULK,
	fixture_mode: int = DeckPlannerScript.FixtureMode.BARE
) -> bool:
	if _awaiting_debug_started or return_admission == null or _waiting_debug_batch != null:
		return false
	if not lift_cycle.is_configured() or lift_cycle.is_busy() or receiving_manager.get_active_batch() != null or not return_admission.get_awaiting_returns().is_empty():
		return false
	var batches: Array[LootBatch] = []
	for index in 4:
		var batch := _prepare_debug_batch(DEFAULT_CONTENT_SEED + index, DEFAULT_PRESENTATION_SEED + index, target_bulk, fixture_mode)
		if batch == null:
			return false
		batches.append(batch)
	_awaiting_debug_started = true
	for signal_name: String in ["return_admitted", "return_awaiting_lift", "return_admitted_after_waiting", "return_forfeited_at_midnight"]:
		return_admission.connect(signal_name, _log_debug_return_event.bind(signal_name))
	for index in batches.size():
		var team_id := "prototype_team_%s" % ["A", "B", "C", "D"][index]
		var definitions: Array[String] = []
		for entry: LootBatchEntry in batches[index].entries:
			definitions.append(String(entry.definition_id))
		print("AWAITING_MANIFEST team=", team_id, " batch=", batches[index].batch_id, " definitions=", definitions)
		if return_admission.submit_return(team_id, batches[index]) == AdmissionScript.ReturnResult.INVALID:
			push_error("Receiving prepared prototype return unexpectedly rejected for " + team_id)
			return false
	return true


func _log_debug_return_event(team_id: String, batch_id: String, event_name: String) -> void:
	print("AWAITING_RETURN event=", event_name, " team=", team_id, " batch=", batch_id,
		" status=", return_admission.get_return_status(team_id),
		" active=", receiving_manager.get_active_batch_id(), " queue=", receiving_manager.get_queued_batch_ids(),
		" awaiting=", return_admission.get_awaiting_returns())


func _prepare_debug_batch(content_seed: int, presentation_seed: int, target_bulk: int, fixture_mode: int) -> LootBatch:
	if item_catalog == null or prototype_loot_pool == null or deck_profile == null or target_bulk <= 0:
		return null
	if fixture_mode < DeckPlannerScript.FixtureMode.BARE or fixture_mode > DeckPlannerScript.FixtureMode.MIXED:
		return null
	var batch_id := "receiving_debug_%d_%d_%d" % [content_seed, presentation_seed, target_bulk]
	var batch: LootBatch = LootSourceScript.new().generate_committed_batch(
		item_catalog,
		prototype_loot_pool,
		batch_id,
		content_seed,
		presentation_seed,
		target_bulk,
		&"prototype",
		"cli_debug"
	)
	if batch == null:
		return null
	var diagnostics = DeckPlannerScript.new().prepare(
		batch, item_catalog, deck_profile, fixture_mode
	)
	if not diagnostics.succeeded:
		push_error("Receiving deck preparation failed: %s" % String(diagnostics.failure_reason))
		return null
	return batch


func _numeric_flag(arguments: PackedStringArray, flag_name: String, fallback: int) -> int:
	var prefix := "%s=" % flag_name
	for argument: String in arguments:
		if not argument.begins_with(prefix):
			continue
		var value_text := argument.trim_prefix(prefix)
		if value_text.is_valid_int():
			return int(value_text)
	return fallback


func _fixture_mode_flag(arguments: PackedStringArray) -> int:
	var prefix := "--receiving-fixture-mode="
	for argument: String in arguments:
		if not argument.begins_with(prefix):
			continue
		match argument.trim_prefix(prefix).to_lower():
			"bare":
				return DeckPlannerScript.FixtureMode.BARE
			"crates":
				return DeckPlannerScript.FixtureMode.CRATES_ALLOWED
			"pallets":
				return DeckPlannerScript.FixtureMode.PALLETS_ALLOWED
			"mixed":
				return DeckPlannerScript.FixtureMode.MIXED
			_:
				return -1
	return DeckPlannerScript.FixtureMode.BARE
