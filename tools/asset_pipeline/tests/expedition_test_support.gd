extends RefCounted

const Acquisition = preload("res://gameplay/expeditions/expedition_acquisition.gd")
const Outcomes = preload("res://gameplay/expeditions/expedition_outcomes.gd")

static func seeded_outcome(ops: RefCounted, pool: Dictionary, seed_value: int) -> Dictionary:
	var random := RandomNumberGenerator.new()
	random.seed = seed_value
	return Outcomes.resolve(ops.members, ops.loadout.credited, ops.return_capacity(), ops.affinities,
		Outcomes.draw_seeds(random), pool)

## Chooses a reproducible input for a particular regression. The real dispatch
## still generates and prepares the exact haul through its production owners.
static func find_seed(ops: RefCounted, runtime: ReceivingRuntime, matches: Callable, first: int = 0) -> int:
	var pool := Acquisition.build_pool(runtime.item_catalog)
	for seed_value in range(first, first + 2000):
		var outcome := seeded_outcome(ops, pool, seed_value)
		if not matches.call(outcome):
			continue
		if outcome.manifest.is_empty() or runtime.can_prepare_manifest(outcome.manifest, "expedition-test", outcome.presentation_seed):
			return seed_value
	return -1

static func all_healthy(outcome: Dictionary) -> bool:
	return outcome.originals.all(func(member: Dictionary): return member.health == Outcomes.HEALTHY)
