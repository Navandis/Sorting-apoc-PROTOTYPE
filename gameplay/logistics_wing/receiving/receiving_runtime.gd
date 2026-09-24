extends Node3D
class_name ReceivingRuntime

const DeckPlannerScript = preload("res://receiving/receiving_deck_layout_planner.gd")
const LootSourceScript = preload("res://receiving/prototype_loot_source.gd")

const DEFAULT_CONTENT_SEED: int = 1842
const DEFAULT_PRESENTATION_SEED: int = 9001
const DEFAULT_TARGET_BULK: int = 24

@export var item_catalog: ItemCatalog
@export var prototype_loot_pool: PrototypeLootPool
@export var deck_profile: Resource

@onready var receiving_manager: ReceivingManager = $ReceivingManager
@onready var deck_presenter: Node3D = $ReceivingDeckPresenter


func _ready() -> void:
	if not deck_presenter.call("configure", receiving_manager, item_catalog, deck_profile):
		push_error("Receiving runtime could not configure its deterministic deck presenter.")
		return
	var arguments := OS.get_cmdline_user_args()
	if not arguments.has("--receiving-deck-debug"):
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
	if receiving_manager.get_active_batch() != null:
		return false
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
		return false
	var diagnostics = DeckPlannerScript.new().prepare(
		batch, item_catalog, deck_profile, fixture_mode
	)
	if not diagnostics.succeeded:
		push_error("Receiving deck preparation failed: %s" % String(diagnostics.failure_reason))
		return false
	if not receiving_manager.deposit_batch(batch):
		return false
	return bool(deck_presenter.call("reveal_active_batch"))


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
