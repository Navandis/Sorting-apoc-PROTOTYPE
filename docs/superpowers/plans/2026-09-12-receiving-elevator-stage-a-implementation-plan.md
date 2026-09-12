# Receiving / Elevator MVP — Stage A Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build the non-visual Receiving/Elevator data foundation: durable item identity, committed `LootBatch` data, the explicit 40-item prototype generation pool, deterministic Bulk-budget batch generation, preparation contracts/diagnostics, and the full one-active/two-queued `ReceivingManager` lifecycle.

**Architecture:** Stage A implements only data and lifecycle contracts from the approved Receiving/Elevator architecture spec. `LootBatch` owns immutable committed content plus atomically committed presentation transforms; `PrototypeLootSource` is a temporary seeded upstream producer; `ReceivingManager` owns deposited capacity and FIFO promotion. No freight-bay scene, rigid-body settling, player interaction, shutter/presenter logic, or Stage B asset work is allowed in this plan.

**Tech Stack:** Godot 4.7 stable, typed GDScript, Godot `Resource`/`RefCounted`/`Node` classes, `.tres` resources, existing persistent `ItemCatalog`, existing headless `SceneTree` test style.

**Spec:** `docs/superpowers/specs/2026-09-12-receiving-elevator-mvp-design.md`

## Global Constraints

- `Sorting Apocalypse — Preliminary GDD v0.4` remains design authority.
- `Sorting Apocalypse — Prototype Findings v0.4` remains the prototype evidence baseline.
- Work in the authoritative local project at `D:\Godot Projects\Sorting-apoc-PROTOTYPE`; Stage A tests resolve persistent item visuals under ignored `/assets`, so do not move execution to a clone/worktree that lacks those local ignored assets/import state.
- Godot version is 4.7 stable; GDScript warnings are treated as errors.
- `ItemDefinition` remains runtime gameplay truth. Runtime Receiving code must never read `tools/asset_pipeline/item_authoring_review.json` or `authoring_review_manifest.gd`.
- Persistent catalogue size remains 42 definitions. Prototype generation pool is exactly 40 stable IDs and excludes `loot_000034` (Gloves) and `loot_000036` (Pants).
- Stage A models the full Receiving capacity immediately: one active deposited batch plus two FIFO queued deposited batches.
- PREPARED-but-undelivered batches consume zero Receiving slots.
- Batch content is immutable after `CONTENT_COMMITTED`; presentation preparation may retry without changing batch/item identity.
- Item identity starts at batch content commitment and must survive reconstruction. Legacy pre-seeded prototype items may continue using the existing auto-generated `ItemInstance` ID path until they are migrated later.
- No generic loose-floor `WorldItem` state is introduced.
- No `WorldItem`, `player_controller.gd`, storage, stacking, zoning, `main.tscn`, elevator/freight-bay scene, RigidBody, shutter, audio/light cue, or player-facing interaction change belongs in Stage A.
- No full save-slot system is added. Stage A proves batch snapshot serialization/reconstruction using Godot Variant-safe data.
- Stage B must not begin at the end of this plan. The required next action after Stage A PASS is human provisioning of freight-bay building-block assets, followed by a separate read-only asset preflight.

## Test command setup

Use PowerShell from the authoritative project root. Resolve the current Godot console executable once per Codex session:

```powershell
$GODOT = (Get-Command godot -ErrorAction SilentlyContinue).Source
if (-not $GODOT -and (Test-Path 'D:\Godot_v4.7-stable_win64.exe\Godot_v4.7-stable_win64_console.exe')) {
    $GODOT = 'D:\Godot_v4.7-stable_win64.exe\Godot_v4.7-stable_win64_console.exe'
}
if (-not $GODOT) { throw 'Godot console executable not found; inspect the current local Godot 4.7 installation before continuing.' }
```

Run an individual headless suite with:

```powershell
& $GODOT --headless --path . --script res://tools/asset_pipeline/tests/<test_file>.gd
if ($LASTEXITCODE -ne 0) { throw 'Headless test failed.' }
```

The literal `<test_file>` token above is descriptive only; every task below provides the exact test filename and command to execute.

---

## File Structure

Create a focused `receiving/` subsystem rather than adding Stage A responsibilities to storage/player scripts.

**Create:**

- `receiving/loot_batch_entry.gd` — one committed physical item record and snapshot conversion.
- `receiving/loot_batch.gd` — immutable committed batch content, atomic arrangement commit, released-entry accounting, snapshot conversion.
- `receiving/prototype_loot_pool.gd` — prototype-only list of eligible stable `ItemDefinition` IDs and catalogue validation.
- `data/receiving/prototype_loot_pool.tres` — the exact 40-ID current prototype pool.
- `receiving/prototype_loot_source.gd` — deterministic seeded Bulk-budget content generator.
- `receiving/freight_bay_presentation_profile.gd` — Stage A schema/validation contract only; no physical bay data authored yet.
- `receiving/pile_preparation_diagnostics.gd` — one preparation job's structured evidence.
- `receiving/pile_preparation_metrics.gd` — aggregate session evidence.
- `receiving/pile_preparation_job.gd` — transient preparation-job lifecycle contract; no physics implementation.
- `receiving/receiving_manager.gd` — one-active/two-queued deposited lifecycle and active-entry release.
- `tools/asset_pipeline/tests/receiving_item_identity_tests.gd`
- `tools/asset_pipeline/tests/receiving_loot_batch_tests.gd`
- `tools/asset_pipeline/tests/receiving_prototype_loot_pool_tests.gd`
- `tools/asset_pipeline/tests/receiving_prototype_loot_source_tests.gd`
- `tools/asset_pipeline/tests/receiving_preparation_contract_tests.gd`
- `tools/asset_pipeline/tests/receiving_manager_tests.gd`
- `tools/asset_pipeline/tests/receiving_stage_a_integration_tests.gd`
- `docs/testing/receiving-elevator-stage-a-validation.md`

**Modify:**

- `item_instance.gd` — allow an externally supplied durable ID while preserving the legacy constructor path.

Do not manually author `.gd.uid` values. Run the Godot parser/editor scan after creating scripts and include any UID sidecars Godot generates.

---

### Task 1: Durable `ItemInstance` Identity

**Files:**
- Modify: `item_instance.gd`
- Create: `tools/asset_pipeline/tests/receiving_item_identity_tests.gd`

**Interfaces:**
- Produces: `ItemInstance._init(item_definition: ItemDefinition = null, explicit_instance_id: String = "")`
- Guarantee: a non-empty `explicit_instance_id` is copied byte-for-byte into `instance_id`; empty explicit ID retains the legacy generated-ID path.

- [ ] **Step 1: Write the failing identity tests**

Create `tools/asset_pipeline/tests/receiving_item_identity_tests.gd`:

```gdscript
extends SceneTree

const ItemInstanceScript = preload("res://item_instance.gd")
const PersistentItemCatalog = preload("res://data/items/item_catalog.tres")

func _init() -> void:
    _test_explicit_identity_is_preserved()
    _test_legacy_identity_path_remains_non_empty()
    _test_two_explicit_instances_of_same_definition_remain_distinct()
    print("PASS: receiving item identity tests")
    quit(0)

func _definition() -> ItemDefinition:
    return PersistentItemCatalog.get_definition_by_id(&"loot_000001")

func _test_explicit_identity_is_preserved() -> void:
    var instance: ItemInstance = ItemInstanceScript.new(
        _definition(),
        "batch_alpha:item_0000"
    )
    assert(instance.instance_id == "batch_alpha:item_0000")
    assert(instance.definition == _definition())

func _test_legacy_identity_path_remains_non_empty() -> void:
    var first: ItemInstance = ItemInstanceScript.new(_definition())
    var second: ItemInstance = ItemInstanceScript.new(_definition())
    assert(not first.instance_id.is_empty())
    assert(not second.instance_id.is_empty())
    assert(first.instance_id != second.instance_id)

func _test_two_explicit_instances_of_same_definition_remain_distinct() -> void:
    var first: ItemInstance = ItemInstanceScript.new(_definition(), "batch_a:item_0000")
    var second: ItemInstance = ItemInstanceScript.new(_definition(), "batch_b:item_0000")
    assert(first.definition == second.definition)
    assert(first.instance_id != second.instance_id)
```

- [ ] **Step 2: Run the test and verify it fails on the current one-argument constructor**

```powershell
& $GODOT --headless --path . --script res://tools/asset_pipeline/tests/receiving_item_identity_tests.gd
if ($LASTEXITCODE -eq 0) { throw 'Expected receiving_item_identity_tests.gd to fail before implementation.' }
```

Expected failure: constructor does not yet accept the explicit durable ID.

- [ ] **Step 3: Implement the minimal backward-compatible constructor**

Change `item_instance.gd` initialization to:

```gdscript
func _init(
    item_definition: ItemDefinition = null,
    explicit_instance_id: String = ""
) -> void:
    definition = item_definition
    if not explicit_instance_id.is_empty():
        instance_id = explicit_instance_id
        return
    instance_id = "%s-%s" % [
        String(definition.item_id) if definition != null else "item",
        str(Time.get_ticks_usec())
    ]
```

Do not add a second identity property or alias.

- [ ] **Step 4: Run the new identity test and adjacent interaction/storage tests**

```powershell
& $GODOT --headless --path . --script res://tools/asset_pipeline/tests/receiving_item_identity_tests.gd
if ($LASTEXITCODE -ne 0) { throw 'receiving_item_identity_tests.gd failed.' }
& $GODOT --headless --path . --script res://tools/asset_pipeline/tests/storage_unstacked_equivalence_tests.gd
if ($LASTEXITCODE -ne 0) { throw 'storage_unstacked_equivalence_tests.gd failed.' }
& $GODOT --headless --path . --script res://tools/asset_pipeline/tests/item_interaction_reviewability_tests.gd
if ($LASTEXITCODE -ne 0) { throw 'item_interaction_reviewability_tests.gd failed.' }
```

Expected: all PASS.

- [ ] **Step 5: Commit**

```powershell
git add item_instance.gd tools/asset_pipeline/tests/receiving_item_identity_tests.gd
git add receiving_item_identity_tests.gd.uid 2>$null
git commit -m "feat: support durable item instance identity"
```

---

### Task 2: `LootBatchEntry` and Atomic `LootBatch` Snapshots

**Files:**
- Create: `receiving/loot_batch_entry.gd`
- Create: `receiving/loot_batch.gd`
- Create: `tools/asset_pipeline/tests/receiving_loot_batch_tests.gd`

**Interfaces:**
- Produces: `LootBatchEntry.new(entry_id: String, item_instance_id: String, definition_id: StringName)`
- Produces: `LootBatch.create_committed(...) -> LootBatch`
- Produces: `LootBatch.commit_arrangement(transforms_by_entry_id: Dictionary, profile_id: StringName, profile_revision: int) -> bool`
- Produces: `LootBatch.create_item_instance(entry_id: String, catalog: ItemCatalog) -> ItemInstance`
- Produces: `LootBatch.mark_entry_released(entry_id: String, item_instance_id: String) -> bool`
- Produces: `LootBatch.to_snapshot() -> Dictionary`
- Produces: `LootBatch.from_snapshot(snapshot: Dictionary) -> LootBatch`

- [ ] **Step 1: Write failing batch tests**

Create tests that assert all of the following in `receiving_loot_batch_tests.gd`:

```gdscript
extends SceneTree

const LootBatchEntryScript = preload("res://receiving/loot_batch_entry.gd")
const LootBatchScript = preload("res://receiving/loot_batch.gd")
const PersistentItemCatalog = preload("res://data/items/item_catalog.tres")

func _init() -> void:
    _test_committed_content_is_immutable_from_arrangement_retries()
    _test_arrangement_commit_is_atomic()
    _test_snapshot_round_trip_preserves_identity_state_and_transform()
    _test_item_instance_reconstruction_preserves_durable_identity()
    _test_release_requires_matching_entry_and_identity()
    print("PASS: receiving loot batch tests")
    quit(0)
```

Use two entries:

```gdscript
func _entries() -> Array[LootBatchEntry]:
    return [
        LootBatchEntryScript.new("entry_0000", "batch_a:item_0000", &"loot_000001"),
        LootBatchEntryScript.new("entry_0001", "batch_a:item_0001", &"loot_000002"),
    ]
```

The atomic arrangement test must call `commit_arrangement()` with only one of two transforms and assert:

```gdscript
assert(not batch.commit_arrangement(incomplete, &"profile_test", 1))
assert(batch.preparation_state == LootBatchScript.STATE_CONTENT_COMMITTED)
assert(batch.presentation_profile_id == &"")
assert(not batch.entries[0].has_frozen_transform)
assert(not batch.entries[1].has_frozen_transform)
```

Then commit an exact two-entry transform dictionary and assert both transforms plus profile ID/revision are committed together and state becomes `PREPARED`.

For serialization, round-trip through Godot Variant bytes:

```gdscript
var bytes: PackedByteArray = var_to_bytes(batch.to_snapshot())
var restored_snapshot: Variant = bytes_to_var(bytes)
var restored: LootBatch = LootBatchScript.from_snapshot(restored_snapshot as Dictionary)
```

- [ ] **Step 2: Run and verify failure because the batch classes do not exist**

```powershell
& $GODOT --headless --path . --script res://tools/asset_pipeline/tests/receiving_loot_batch_tests.gd
if ($LASTEXITCODE -eq 0) { throw 'Expected receiving_loot_batch_tests.gd to fail before implementation.' }
```

- [ ] **Step 3: Implement `LootBatchEntry`**

Create `receiving/loot_batch_entry.gd` with one physical item per entry:

```gdscript
extends RefCounted
class_name LootBatchEntry

var entry_id: String = ""
var item_instance_id: String = ""
var definition_id: StringName = &""
var frozen_transform: Transform3D = Transform3D.IDENTITY
var has_frozen_transform: bool = false
var remaining_in_batch: bool = true

func _init(
    new_entry_id: String = "",
    new_item_instance_id: String = "",
    new_definition_id: StringName = &""
) -> void:
    entry_id = new_entry_id
    item_instance_id = new_item_instance_id
    definition_id = new_definition_id

func to_snapshot() -> Dictionary:
    return {
        "entry_id": entry_id,
        "item_instance_id": item_instance_id,
        "definition_id": definition_id,
        "frozen_transform": frozen_transform,
        "has_frozen_transform": has_frozen_transform,
        "remaining_in_batch": remaining_in_batch,
    }

static func from_snapshot(snapshot: Dictionary) -> LootBatchEntry:
    var entry: LootBatchEntry = LootBatchEntry.new(
        String(snapshot.get("entry_id", "")),
        String(snapshot.get("item_instance_id", "")),
        StringName(snapshot.get("definition_id", &""))
    )
    entry.frozen_transform = snapshot.get("frozen_transform", Transform3D.IDENTITY) as Transform3D
    entry.has_frozen_transform = bool(snapshot.get("has_frozen_transform", false))
    entry.remaining_in_batch = bool(snapshot.get("remaining_in_batch", true))
    return entry
```

- [ ] **Step 4: Implement `LootBatch` content and arrangement invariants**

Create `receiving/loot_batch.gd` with constants:

```gdscript
extends RefCounted
class_name LootBatch

const ItemInstanceScript = preload("res://item_instance.gd")
const LootBatchEntryScript = preload("res://receiving/loot_batch_entry.gd")

const STATE_CONTENT_COMMITTED: StringName = &"CONTENT_COMMITTED"
const STATE_PREPARED: StringName = &"PREPARED"
```

Use fields from the approved spec and an `Array[LootBatchEntry]`. `create_committed()` must validate non-empty batch ID, unique non-empty entry IDs, unique non-empty item IDs, non-empty definition IDs, positive `actual_bulk`, and `target_bulk > 0`. Return `null` on malformed content before any committed object escapes.

`commit_arrangement()` must:

1. require current state `CONTENT_COMMITTED`;
2. require non-empty `profile_id` and `profile_revision > 0`;
3. require exactly one finite `Transform3D` for every `remaining_in_batch` entry and no unknown entry key;
4. perform all validation before writing any entry transform;
5. write all transforms, profile ID/revision, then set `STATE_PREPARED`.

`create_item_instance()` resolves `definition_id` through the passed `ItemCatalog` and calls:

```gdscript
return ItemInstanceScript.new(definition, entry.item_instance_id)
```

`mark_entry_released()` must require matching `entry_id` + `item_instance_id`, refuse a second release, and set only `remaining_in_batch = false`.

- [ ] **Step 5: Implement snapshot round-trip**

`to_snapshot()` must contain only durable fields and entry snapshots. Do not serialize transient preparation-job state.

`from_snapshot()` must reject malformed state/duplicate identity and reconstruct exact durable values without generating new IDs.

- [ ] **Step 6: Run tests**

```powershell
& $GODOT --headless --path . --script res://tools/asset_pipeline/tests/receiving_loot_batch_tests.gd
if ($LASTEXITCODE -ne 0) { throw 'receiving_loot_batch_tests.gd failed.' }
```

Expected: PASS.

- [ ] **Step 7: Commit**

```powershell
git add receiving/loot_batch_entry.gd receiving/loot_batch.gd tools/asset_pipeline/tests/receiving_loot_batch_tests.gd
git add receiving/*.gd.uid tools/asset_pipeline/tests/receiving_loot_batch_tests.gd.uid 2>$null
git commit -m "feat: add committed loot batch model"
```

---

### Task 3: Explicit 40-Item `PrototypeLootPool`

**Files:**
- Create: `receiving/prototype_loot_pool.gd`
- Create: `data/receiving/prototype_loot_pool.tres`
- Create: `tools/asset_pipeline/tests/receiving_prototype_loot_pool_tests.gd`

**Interfaces:**
- Produces: `PrototypeLootPool.validate_against_catalog(catalog: ItemCatalog) -> PackedStringArray`
- Produces: `PrototypeLootPool.resolve_definitions(catalog: ItemCatalog) -> Array[ItemDefinition]`
- Produces data: `pool_id = &"prototype_receiving_pool"`, `revision = 1`, exactly 40 stable IDs.

- [ ] **Step 1: Write the pool-content tests first**

The test must load both persistent resources and assert exact boundaries:

```gdscript
extends SceneTree

const PersistentItemCatalog = preload("res://data/items/item_catalog.tres")
const PrototypePool = preload("res://data/receiving/prototype_loot_pool.tres")

func _init() -> void:
    assert(PrototypePool.pool_id == &"prototype_receiving_pool")
    assert(PrototypePool.revision == 1)
    assert(PrototypePool.item_definition_ids.size() == 40)
    assert(not PrototypePool.item_definition_ids.has(&"loot_000034"))
    assert(not PrototypePool.item_definition_ids.has(&"loot_000036"))
    assert(PrototypePool.validate_against_catalog(PersistentItemCatalog).is_empty())
    assert(PrototypePool.resolve_definitions(PersistentItemCatalog).size() == 40)
    assert((PersistentItemCatalog.get("definitions") as Array).size() == 42)
    _assert_exact_expected_ids()
    print("PASS: receiving prototype loot pool tests")
    quit(0)
```

`_assert_exact_expected_ids()` must compare against `loot_000001` through `loot_000042` excluding only `loot_000034` and `loot_000036`, so accidental additions/removals are visible.

- [ ] **Step 2: Run and verify failure because the resource does not exist**

```powershell
& $GODOT --headless --path . --script res://tools/asset_pipeline/tests/receiving_prototype_loot_pool_tests.gd
if ($LASTEXITCODE -eq 0) { throw 'Expected receiving_prototype_loot_pool_tests.gd to fail before implementation.' }
```

- [ ] **Step 3: Implement the pool resource class**

Create `receiving/prototype_loot_pool.gd`:

```gdscript
extends Resource
class_name PrototypeLootPool

@export var pool_id: StringName = &"prototype_receiving_pool"
@export_range(1, 9999, 1) var revision: int = 1
@export var item_definition_ids: Array[StringName] = []

func validate_against_catalog(catalog: ItemCatalog) -> PackedStringArray:
    var errors := PackedStringArray()
    if catalog == null:
        errors.append("PrototypeLootPool requires an ItemCatalog.")
        return errors
    var seen: Dictionary = {}
    for item_id: StringName in item_definition_ids:
        if String(item_id).is_empty():
            errors.append("PrototypeLootPool contains an empty item ID.")
        elif seen.has(item_id):
            errors.append("PrototypeLootPool contains duplicate item ID '%s'." % String(item_id))
        elif catalog.get_definition_by_id(item_id) == null:
            errors.append("PrototypeLootPool item ID '%s' does not resolve." % String(item_id))
        seen[item_id] = true
    return errors

func resolve_definitions(catalog: ItemCatalog) -> Array[ItemDefinition]:
    if not validate_against_catalog(catalog).is_empty():
        return []
    var result: Array[ItemDefinition] = []
    for item_id: StringName in item_definition_ids:
        result.append(catalog.get_definition_by_id(item_id))
    return result
```

- [ ] **Step 4: Author the exact 40-ID `.tres`**

Create `data/receiving/prototype_loot_pool.tres` with `PrototypeLootPool` as its script and this exact ID sequence:

```text
loot_000001, loot_000002, loot_000003, loot_000004, loot_000005, loot_000006,
loot_000007, loot_000008, loot_000009, loot_000010, loot_000011, loot_000012,
loot_000013, loot_000014, loot_000015, loot_000016, loot_000017, loot_000018,
loot_000019, loot_000020, loot_000021, loot_000022, loot_000023, loot_000024,
loot_000025, loot_000026, loot_000027, loot_000028, loot_000029, loot_000030,
loot_000031, loot_000032, loot_000033, loot_000035, loot_000037, loot_000038,
loot_000039, loot_000040, loot_000041, loot_000042
```

Do not derive this runtime resource from the authoring-review manifest at launch or test time.

- [ ] **Step 5: Run the pool test and existing catalogue tests**

```powershell
& $GODOT --headless --path . --script res://tools/asset_pipeline/tests/receiving_prototype_loot_pool_tests.gd
if ($LASTEXITCODE -ne 0) { throw 'receiving_prototype_loot_pool_tests.gd failed.' }
& $GODOT --headless --path . --script res://tools/asset_pipeline/tests/item_catalog_tests.gd
if ($LASTEXITCODE -ne 0) { throw 'item_catalog_tests.gd failed.' }
```

- [ ] **Step 6: Commit**

```powershell
git add receiving/prototype_loot_pool.gd data/receiving/prototype_loot_pool.tres tools/asset_pipeline/tests/receiving_prototype_loot_pool_tests.gd
git add receiving/prototype_loot_pool.gd.uid tools/asset_pipeline/tests/receiving_prototype_loot_pool_tests.gd.uid 2>$null
git commit -m "feat: add prototype receiving loot pool"
```

---

### Task 4: Seeded Bulk-Budget `PrototypeLootSource`

**Files:**
- Create: `receiving/prototype_loot_source.gd`
- Create: `tools/asset_pipeline/tests/receiving_prototype_loot_source_tests.gd`

**Interfaces:**
- Consumes: `ItemCatalog`, `PrototypeLootPool`, `LootBatch`, `LootBatchEntry`.
- Produces:

```gdscript
func generate_committed_batch(
    catalog: ItemCatalog,
    pool: PrototypeLootPool,
    batch_id: String,
    content_seed: int,
    presentation_seed: int,
    target_bulk: int,
    source_kind: StringName = &"prototype",
    source_ref: String = "debug"
) -> LootBatch
```

- [ ] **Step 1: Write deterministic-generation tests**

Tests must prove:

1. same pool + seed + target Bulk produces the same ordered definition IDs and actual Bulk;
2. a different `batch_id` with the same generation inputs produces the same definition sequence but distinct `item_instance_id`s;
3. generated `actual_bulk >= target_bulk` and overshoot is less than the maximum single item Bulk in the pool;
4. every generated definition comes from the explicit 40-item pool;
5. entry IDs are ordered `entry_0000`, `entry_0001`, ... and item IDs are `<batch_id>:item_0000`, ...;
6. invalid target Bulk, invalid pool, missing batch ID, or unresolved catalogue input returns `null` before commitment.

Representative assertion:

```gdscript
var first: LootBatch = source.generate_committed_batch(
    PersistentItemCatalog, PrototypePool, "batch_a", 1842, 9001, 24
)
var second: LootBatch = source.generate_committed_batch(
    PersistentItemCatalog, PrototypePool, "batch_b", 1842, 9001, 24
)
assert(_definition_sequence(first) == _definition_sequence(second))
assert(first.actual_bulk == second.actual_bulk)
assert(first.entries[0].item_instance_id != second.entries[0].item_instance_id)
assert(first.preparation_state == LootBatchScript.STATE_CONTENT_COMMITTED)
```

- [ ] **Step 2: Run and verify failure**

```powershell
& $GODOT --headless --path . --script res://tools/asset_pipeline/tests/receiving_prototype_loot_source_tests.gd
if ($LASTEXITCODE -eq 0) { throw 'Expected receiving_prototype_loot_source_tests.gd to fail before implementation.' }
```

- [ ] **Step 3: Implement the deterministic source**

Create `receiving/prototype_loot_source.gd` with a local `RandomNumberGenerator` whose `seed` is exactly `content_seed`. Resolve the pool once, then repeatedly sample with replacement until `actual_bulk >= target_bulk`.

Use:

```gdscript
var rng := RandomNumberGenerator.new()
rng.seed = content_seed
var definitions: Array[ItemDefinition] = pool.resolve_definitions(catalog)
var entries: Array[LootBatchEntry] = []
var actual_bulk: int = 0
var ordinal: int = 0
while actual_bulk < target_bulk:
    var definition: ItemDefinition = definitions[rng.randi_range(0, definitions.size() - 1)]
    var entry_id := "entry_%04d" % ordinal
    var item_id := "%s:item_%04d" % [batch_id, ordinal]
    entries.append(LootBatchEntryScript.new(entry_id, item_id, definition.item_id))
    actual_bulk += definition.bulk
    ordinal += 1
```

Add a defensive maximum ordinal based on `target_bulk + max_bulk` rather than an arbitrary gameplay limit; with positive Bulk values the loop must terminate.

Set `source_ref` to include the explicit prototype pool identity/revision when the caller passes the default `"debug"`, e.g. `prototype_receiving_pool:1`.

- [ ] **Step 4: Run source, pool, and batch tests**

```powershell
& $GODOT --headless --path . --script res://tools/asset_pipeline/tests/receiving_prototype_loot_source_tests.gd
if ($LASTEXITCODE -ne 0) { throw 'receiving_prototype_loot_source_tests.gd failed.' }
& $GODOT --headless --path . --script res://tools/asset_pipeline/tests/receiving_prototype_loot_pool_tests.gd
if ($LASTEXITCODE -ne 0) { throw 'receiving_prototype_loot_pool_tests.gd failed.' }
& $GODOT --headless --path . --script res://tools/asset_pipeline/tests/receiving_loot_batch_tests.gd
if ($LASTEXITCODE -ne 0) { throw 'receiving_loot_batch_tests.gd failed.' }
```

- [ ] **Step 5: Commit**

```powershell
git add receiving/prototype_loot_source.gd tools/asset_pipeline/tests/receiving_prototype_loot_source_tests.gd
git add receiving/prototype_loot_source.gd.uid tools/asset_pipeline/tests/receiving_prototype_loot_source_tests.gd.uid 2>$null
git commit -m "feat: add deterministic prototype loot source"
```

---

### Task 5: Presentation Profile Schema and Preparation Evidence Contracts

**Files:**
- Create: `receiving/freight_bay_presentation_profile.gd`
- Create: `receiving/pile_preparation_diagnostics.gd`
- Create: `receiving/pile_preparation_metrics.gd`
- Create: `receiving/pile_preparation_job.gd`
- Create: `tools/asset_pipeline/tests/receiving_preparation_contract_tests.gd`

**Interfaces:**
- Produces Stage B schema: `FreightBayPresentationProfile`.
- Produces transient job states: `PENDING`, `RUNNING`, `SUCCEEDED`, `FAILED`.
- Produces `PilePreparationDiagnostics.to_snapshot() -> Dictionary`.
- Produces `PilePreparationMetrics.record(diagnostics)` and `snapshot() -> Dictionary`.
- Does not implement physics, drainability, fallback layout, or a concrete prepared pile.

- [ ] **Step 1: Write the contract tests**

Tests must assert:

- profile ID/revision are required before a profile is considered valid;
- geometry fields can remain default/empty during Stage A because no bay assets exist yet;
- job lifecycle cannot skip directly from `PENDING` to `SUCCEEDED` without `begin()`;
- beginning a job does not mutate a `LootBatch` from `CONTENT_COMMITTED`;
- failed jobs do not mutate batch content or state;
- diagnostics store every approved Stage A field;
- aggregate metrics report batch count, physics/fallback rates, mean attempts, p95 duration, and rejection reason totals;
- recording diagnostics has no effect on batch gameplay state.

- [ ] **Step 2: Run and verify failure**

```powershell
& $GODOT --headless --path . --script res://tools/asset_pipeline/tests/receiving_preparation_contract_tests.gd
if ($LASTEXITCODE -eq 0) { throw 'Expected receiving_preparation_contract_tests.gd to fail before implementation.' }
```

- [ ] **Step 3: Implement `FreightBayPresentationProfile` schema only**

Create exported fields matching the approved spec:

```gdscript
extends Resource
class_name FreightBayPresentationProfile

@export var profile_id: StringName = &""
@export_range(1, 9999, 1) var revision: int = 1
@export var pile_bounds: AABB = AABB()
@export var deck_support_y_m: float = 0.0
@export var settle_spawn_volume: AABB = AABB()
@export var temporary_proxy_collision_envelope: AABB = AABB()
@export var barrier_side_reach_envelope: AABB = AABB()
@export var drainability_viewpoints: Array[Vector3] = []
@export var containment_tolerance_m: float = 0.01
@export var penetration_tolerance_m: float = 0.01
@export var fallback_layout_version: int = 1

func validate_identity() -> PackedStringArray:
    var errors := PackedStringArray()
    if String(profile_id).is_empty():
        errors.append("FreightBayPresentationProfile requires profile_id.")
    if revision <= 0:
        errors.append("FreightBayPresentationProfile revision must be positive.")
    return errors
```

Do not author a profile `.tres` yet.

- [ ] **Step 4: Implement diagnostics and aggregator**

`PilePreparationDiagnostics` fields must include:

```text
batch_id, content_seed, presentation_seed, target_bulk, actual_bulk, item_count,
attempts_used, accepted_via_physics, fallback_used, preparation_duration_ms,
rejection_counts_by_reason, accepted_drain_iterations, accepted_profile_revision
```

`PilePreparationMetrics.snapshot()` must calculate p95 from sorted recorded durations without introducing a hard pass/fail threshold.

- [ ] **Step 5: Implement transient `PilePreparationJob` contract**

Use:

```gdscript
enum JobState { PENDING, RUNNING, SUCCEEDED, FAILED }
```

Store a batch reference, profile reference, state, and diagnostics. `begin()` requires a `CONTENT_COMMITTED` batch and valid profile identity. `mark_failed(reason)` records diagnostics but never mutates the batch. `mark_succeeded()` only changes transient job state; Stage B's concrete preparation implementation will be responsible for invoking `LootBatch.commit_arrangement()` before success.

- [ ] **Step 6: Run contract tests**

```powershell
& $GODOT --headless --path . --script res://tools/asset_pipeline/tests/receiving_preparation_contract_tests.gd
if ($LASTEXITCODE -ne 0) { throw 'receiving_preparation_contract_tests.gd failed.' }
```

- [ ] **Step 7: Commit**

```powershell
git add receiving/freight_bay_presentation_profile.gd receiving/pile_preparation_diagnostics.gd receiving/pile_preparation_metrics.gd receiving/pile_preparation_job.gd tools/asset_pipeline/tests/receiving_preparation_contract_tests.gd
git add receiving/*.gd.uid tools/asset_pipeline/tests/receiving_preparation_contract_tests.gd.uid 2>$null
git commit -m "feat: define receiving preparation contracts"
```

---

### Task 6: Three-Slot `ReceivingManager`

**Files:**
- Create: `receiving/receiving_manager.gd`
- Create: `tools/asset_pipeline/tests/receiving_manager_tests.gd`

**Interfaces:**
- Produces:

```gdscript
func deposit_batch(batch: LootBatch) -> bool
func get_active_batch_id() -> String
func get_queued_batch_ids() -> PackedStringArray
func get_active_batch() -> LootBatch
func get_deposited_batch(batch_id: String) -> LootBatch
func release_entry(batch_id: String, entry_id: String, item_instance_id: String) -> bool
func retire_drained_active_after_close() -> String
```

- Signals:

```gdscript
signal active_batch_changed(batch_id: String)
signal active_batch_drained(batch_id: String)
signal deposit_rejected(batch_id: String)
```

- [ ] **Step 1: Write manager tests first**

Test exact lifecycle:

1. `CONTENT_COMMITTED` batch is rejected because physical deposit requires PREPARED.
2. PREPARED-but-undelivered batch is not counted by a fresh manager.
3. first prepared deposit becomes active;
4. second and third append FIFO;
5. fourth prepared deposit returns false and leaves active/queue state byte-semantically unchanged;
6. duplicate deposited `batch_id` is rejected;
7. `release_entry()` rejects queued batch, unknown entry, mismatched item identity, and already-released entry;
8. releasing the final active entry emits `active_batch_drained` but does not promote the queue;
9. `retire_drained_active_after_close()` removes the drained active batch and promotes the first queued ID only then;
10. second retirement preserves FIFO order.

Use tiny PREPARED batch fixtures by calling `commit_arrangement()` with synthetic transforms and a synthetic profile identity. Do not create a physical freight-bay profile resource.

- [ ] **Step 2: Run and verify failure**

```powershell
& $GODOT --headless --path . --script res://tools/asset_pipeline/tests/receiving_manager_tests.gd
if ($LASTEXITCODE -eq 0) { throw 'Expected receiving_manager_tests.gd to fail before implementation.' }
```

- [ ] **Step 3: Implement `ReceivingManager`**

Use a `Node` so Stage B can connect signals without replacing the manager type later:

```gdscript
extends Node
class_name ReceivingManager

const MAX_QUEUED_BATCHES: int = 2

signal active_batch_changed(batch_id: String)
signal active_batch_drained(batch_id: String)
signal deposit_rejected(batch_id: String)

var _active_batch_id: String = ""
var _queued_batch_ids: Array[String] = []
var _deposited_batches: Dictionary = {}
```

`deposit_batch()` must validate the batch fully before mutation, including `STATE_PREPARED`, non-empty ID, no duplicate deposited ID, and capacity. On capacity rejection emit `deposit_rejected` without modifying the queue dictionary or arrays.

`release_entry()` must only delegate to the active batch's matching entry. When that call causes `is_drained()` to become true, emit `active_batch_drained` once.

`retire_drained_active_after_close()` must fail with `""` unless the current active batch is drained. On success remove it, shift FIFO queue if present, emit `active_batch_changed`, and return the new active ID or `""`.

- [ ] **Step 4: Run manager and batch tests**

```powershell
& $GODOT --headless --path . --script res://tools/asset_pipeline/tests/receiving_manager_tests.gd
if ($LASTEXITCODE -ne 0) { throw 'receiving_manager_tests.gd failed.' }
& $GODOT --headless --path . --script res://tools/asset_pipeline/tests/receiving_loot_batch_tests.gd
if ($LASTEXITCODE -ne 0) { throw 'receiving_loot_batch_tests.gd failed.' }
```

- [ ] **Step 5: Commit**

```powershell
git add receiving/receiving_manager.gd tools/asset_pipeline/tests/receiving_manager_tests.gd
git add receiving/receiving_manager.gd.uid tools/asset_pipeline/tests/receiving_manager_tests.gd.uid 2>$null
git commit -m "feat: add three-slot receiving lifecycle"
```

---

### Task 7: Stage A End-to-End Reconstruction and Boundary Test

**Files:**
- Create: `tools/asset_pipeline/tests/receiving_stage_a_integration_tests.gd`
- Modify only if a defect is exposed: files created in Tasks 1–6.

**Interfaces:**
- Consumes every Stage A public interface.
- Produces no new gameplay API unless the integration test exposes a missing boundary required by the approved spec.

- [ ] **Step 1: Write the Stage A integration suite**

The suite must run this end-to-end data path using real catalogue/pool resources:

```text
40-ID pool
→ seeded PrototypeLootSource
→ CONTENT_COMMITTED LootBatch
→ snapshot byte round-trip
→ atomic synthetic arrangement commit
→ PREPARED batch
→ ItemInstance reconstruction with same durable identity
→ ReceivingManager deposit
→ exact active-entry release
→ drained signal
→ post-close FIFO promotion
```

Also create three additional PREPARED batches and verify the fourth physical deposit is rejected while one separate PREPARED-but-undelivered batch remains completely outside manager capacity.

- [ ] **Step 2: Add an explicit runtime-manifest boundary assertion**

In the same test, read every `.gd` file directly under `res://receiving/` and fail if the source contains either runtime-forbidden string:

```gdscript
assert(not source.contains("item_authoring_review.json"))
assert(not source.contains("authoring_review_manifest"))
```

This is a narrow architecture guard for the approved authoring/runtime separation, not a general style test.

- [ ] **Step 3: Assert transient preparation state is disposable**

Create a `PilePreparationJob`, begin it against a committed batch, record a failure, then serialize and reconstruct only the batch. Assert the reconstructed batch is still `CONTENT_COMMITTED`, identities/content are unchanged, and no job state appears in the batch snapshot.

- [ ] **Step 4: Run the integration suite**

```powershell
& $GODOT --headless --path . --script res://tools/asset_pipeline/tests/receiving_stage_a_integration_tests.gd
if ($LASTEXITCODE -ne 0) { throw 'receiving_stage_a_integration_tests.gd failed.' }
```

- [ ] **Step 5: Run all new Receiving suites together**

```powershell
$receivingSuites = @(
    'receiving_item_identity_tests.gd',
    'receiving_loot_batch_tests.gd',
    'receiving_prototype_loot_pool_tests.gd',
    'receiving_prototype_loot_source_tests.gd',
    'receiving_preparation_contract_tests.gd',
    'receiving_manager_tests.gd',
    'receiving_stage_a_integration_tests.gd'
)
foreach ($suite in $receivingSuites) {
    & $GODOT --headless --path . --script ("res://tools/asset_pipeline/tests/" + $suite)
    if ($LASTEXITCODE -ne 0) { throw "Receiving suite failed: $suite" }
}
```

Expected: all seven PASS.

- [ ] **Step 6: Commit**

```powershell
git add tools/asset_pipeline/tests/receiving_stage_a_integration_tests.gd
git add tools/asset_pipeline/tests/receiving_stage_a_integration_tests.gd.uid 2>$null
git commit -m "test: verify receiving stage a lifecycle"
```

---

### Task 8: Full Regression, Audit, and Stage A Validation Record

**Files:**
- Create: `docs/testing/receiving-elevator-stage-a-validation.md`
- Modify only if verification finds a real defect: Stage A implementation/test files.

**Interfaces:**
- Produces evidence only. No Stage B code, scene, asset, presenter, physics, or player interaction.

- [ ] **Step 1: Run every headless test suite in the established test directory**

```powershell
$testFiles = Get-ChildItem 'tools/asset_pipeline/tests/*_tests.gd' | Sort-Object Name
foreach ($test in $testFiles) {
    & $GODOT --headless --path . --script $test.FullName
    if ($LASTEXITCODE -ne 0) { throw "Headless suite failed: $($test.Name)" }
}
```

Expected: every existing suite plus the seven new Receiving suites exits 0.

- [ ] **Step 2: Run the fresh main-scene loot audit read-only**

```powershell
& $GODOT --headless --path . --script res://tools/asset_pipeline/run_main_scene_loot_audit.gd
if ($LASTEXITCODE -ne 0) { throw 'Main-scene loot audit failed.' }
```

Expected catalogue evidence remains 42 definitions with the existing two downstream-blocked content cases; the audit must not rewrite gameplay definitions or Receiving data.

- [ ] **Step 3: Run parser/editor scan and diff checks**

```powershell
& $GODOT --headless --editor --path . --quit
if ($LASTEXITCODE -ne 0) { throw 'Godot editor/parser scan failed.' }
git diff --check
if ($LASTEXITCODE -ne 0) { throw 'git diff --check failed.' }
```

- [ ] **Step 4: Create the Stage A validation record**

Create `docs/testing/receiving-elevator-stage-a-validation.md` with these exact sections:

```markdown
# Receiving / Elevator MVP — Stage A Validation

## Status
`STAGE A — TECHNICALLY VERIFIED; CLOSED`

## Implemented boundary
- Durable externally supplied ItemInstance identity.
- LootBatch/LootBatchEntry content and atomic arrangement commitment.
- Exact 40-ID prototype pool; Gloves/Pants excluded.
- Seeded Bulk-budget PrototypeLootSource.
- FreightBayPresentationProfile schema only; no bay asset authored.
- Transient preparation job/diagnostic contracts only; no physics.
- ReceivingManager one-active/two-queued FIFO lifecycle.
- Variant-safe snapshot/reconstruction evidence.

## Explicitly not started
- Freight-bay scene/architecture assets.
- Hidden rigid-body settling.
- WorldItem materialization/Receiving pickup.
- FreightBayPresenter/shutter/cues.
- Stage B debug delivery UI.
- Stage C physical queue playtest.

## Verification
[record exact suite count and exit results]

## Stage A exit decision
`PASS`

## Mandatory next checkpoint
Developer provisions candidate freight-bay building-block assets in the authoritative local project. Only then perform the read-only Stage A → Stage B asset preflight from the architecture spec. Do not begin Stage B before that checkpoint.
```

Also record:
- exact commit range implementing Stage A;
- pool ID/revision;
- fixed content seed/target Bulk used by integration evidence;
- proof that same generation inputs reproduce content while distinct batch IDs produce distinct item identities;
- proof that PREPARED-undelivered batches consume zero Receiving slots;
- proof that fourth deposited batch rejection is atomic.

- [ ] **Step 5: Confirm working-tree scope before final Stage A commit**

```powershell
git status --short
git diff --stat
git diff --check
```

Do not include unrelated lock files, generated Office files, ignored assets, or Stage B work.

- [ ] **Step 6: Commit Stage A validation evidence**

```powershell
git add docs/testing/receiving-elevator-stage-a-validation.md
git commit -m "docs: close receiving stage a gate"
```

- [ ] **Step 7: Stop**

Do not inspect or assemble freight-bay assets as part of this plan. Report Stage A as:

- implemented;
- technically verified;
- not a player-facing/human gameplay gate;
- Stage B not started;
- awaiting developer asset provisioning before the Stage A → Stage B read-only preflight.

---

## Plan Self-Review

### Spec coverage

This Stage A plan covers every requirement in spec section 21 / Stage A:

- durable item identity → Task 1;
- `LootBatch` / `LootBatchEntry`, two-phase commitment, snapshots → Task 2;
- explicit 40-ID pool / catalogue-only runtime resolution → Task 3;
- seeded Bulk-budget source → Task 4;
- presentation-profile schema, job interface, diagnostics → Task 5;
- complete three-slot Receiving model → Task 6;
- reconstruction, prepared-undelivered capacity boundary, disposable transient preparation state, runtime/manifest separation → Task 7;
- full regression/audit and Stage A STOP gate → Task 8.

No Stage B requirement is implemented early. In particular, this plan does not create the freight-bay scene, presenter state machine, isolated physics world, settle proxies, drainability simulation, deterministic fallback arrangement, contextual Receiving pickup reach, or debug delivery controls.

### Type consistency

- `LootBatchEntry.entry_id` is the Receiving-local stable entry selector.
- `LootBatchEntry.item_instance_id` is the durable physical item identity.
- `LootBatch.batch_id` is unique per committed batch even for repeated content seeds.
- `LootBatch.preparation_state` owns only `CONTENT_COMMITTED` / `PREPARED`.
- `PilePreparationJob.JobState` is transient and never serialized into `LootBatch`.
- `ReceivingManager` accepts only PREPARED batches and owns deposited capacity independently of preparation.

### Scope check

Stage A is independently testable and reviewable. It deliberately stops before the asset-sensitive Stage B work, matching the approved requirement that the developer provision building blocks after Stage A closes.

---

## Execution Recommendation

- **Session:** fresh Codex session.
- **Model:** Sol.
- **Effort:** High.
- **Why:** Stage A is a new multi-file subsystem with durable identity, immutable/random-outcome commitment, serialization, and atomic FIFO lifecycle invariants. The code itself is moderate, but cross-task contract consistency and regression design justify high reasoning effort.
- **Token efficiency:** Astra 6 would be wasteful unless implementation exposes a genuinely difficult cross-system identity/save-integrity defect. Luna/Terra would save tokens but offer less margin on the lifecycle/serialization invariants.
- **Execution style:** plan-driven, task-by-task TDD with a review checkpoint after each task/commit. Use the authoritative local project; do not create an asset-blind worktree.
- **Required stop:** after Task 8 PASS, stop and return results. Do not begin the Stage A → Stage B asset preflight until the developer has provisioned the candidate building-block assets.
