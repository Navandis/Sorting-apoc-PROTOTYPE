# Persistent 42-Item Catalogue Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the 11-entry hard-coded prototype catalogue with 42 persistent `ItemDefinition` resources, an indexed `ItemCatalog`, an explicit non-destructive seed utility, and complete lookup/interaction reviewability coverage.

**Architecture:** `data/items/item_catalog.tres` explicitly owns an array of persistent definitions and `item_catalog.gd` builds ID/path indexes once per loaded resource instance. `prototype_item_catalog.gd` remains the runtime compatibility facade, while a pure seed helper and explicit SceneTree command validate schema-1.2 audit evidence before creating only missing resources.

**Tech Stack:** Godot 4.7, GDScript, `.tres` Resource files, JSON audit/manifest data, headless SceneTree test scripts.

**Spec:** `docs/superpowers/specs/2026-08-26-persistent-item-catalog-design.md`

## Global Constraints

- Preserve LMB TAKE, E PUT, hold-E repeat, zoning fallback, manual placement, 90-degree rotation, retrieval, shelf geometry, carried bundles, zoning UI, and category taxonomy.
- Do not modify `main.tscn`, source assets, `.import`, `.godot`, storage mechanics, or zoning behavior.
- `ItemDefinition.item_id` equals `loot_NNNNNN`; visual paths are compatibility keys only.
- Existing `.tres` files are immutable to seed reruns; only missing definitions and their catalogue membership may be added.
- Initial Footprint is `Vector3i(raw_width_cells, raw_depth_cells, 1)`; Bulk 1 and neutral Utility are review scaffolding.
- The seed/sync path never marks review state complete; all 42 review dimensions remain `UNREVIEWED`.
- Duplicate IDs or visual paths emit a clear validation error and return `null` for the affected key.
- GDScript warnings are errors.

---

### Task 1: Indexed `ItemCatalog` Resource

**Files:**
- Create: `item_catalog.gd`
- Create: `tools/asset_pipeline/tests/item_catalog_tests.gd`

**Interfaces:**
- Produces: `ItemCatalog.set_definitions(value: Array[ItemDefinition])`, `get_definition_by_id(item_id: StringName) -> ItemDefinition`, `get_definition_by_visual_path(path: String) -> ItemDefinition`, `get_validation_errors() -> PackedStringArray`, and `get_index_build_count() -> int`.
- Consumes: existing `ItemDefinition.item_id` and `ItemDefinition.visual_scene.resource_path`.

- [ ] **Step 1: Read the test-quality rules before editing tests**

Read `superpowers/test-driven-development/writing-good-tests.md` completely and name the production behavior each test can break.

- [ ] **Step 2: Write failing registry tests**

Create a self-running `SceneTree` test that constructs real `ItemDefinition` resources and asserts unique lookups, duplicate-key null results, error text, and one index build across repeated queries:

```gdscript
var catalog: ItemCatalog = ItemCatalogScript.new()
catalog.set_definitions([_definition(&"loot_000001", "res://assets/props/Food/cereal_box.glb")])
assert(catalog.get_definition_by_id(&"loot_000001") != null)
assert(catalog.get_definition_by_visual_path("res://assets/props/Food/cereal_box.glb") != null)
assert(catalog.get_index_build_count() == 1)
catalog.get_definition_by_id(&"loot_000001")
assert(catalog.get_index_build_count() == 1)
```

Use two definitions with the same ID and two with the same path; assert each affected lookup is `null` and `get_validation_errors()` names the duplicate value.

- [ ] **Step 3: Run RED**

Run:

```powershell
& 'D:\AI Tools\Godot-4.7-Codex\Godot_v4.7-stable_win64_console.exe' --headless --path 'D:\Godot Projects\Sorting-apoc-PROTOTYPE' --script 'res://tools/asset_pipeline/tests/item_catalog_tests.gd'
```

Expected: failure because `res://item_catalog.gd` does not exist.

- [ ] **Step 4: Implement the minimal cached registry**

Implement exported definitions plus lazy indexes. Build into temporary ID/path maps and conflict sets, erase conflicting keys, record deterministic diagnostics, then commit the maps to fields and set `_indexes_built = true`. `set_definitions()` duplicates the supplied array and invalidates caches. Queries call `_ensure_indexes()` once and return the cached value or `null`.

- [ ] **Step 5: Run GREEN and refactor**

Run the Task 1 command until it exits 0 with `PASS: item catalog tests`, then remove duplication without changing behavior and rerun.

---

### Task 2: Pure Seed Planning and Rerun Safety

**Files:**
- Create: `tools/asset_pipeline/item_definition_seeder.gd`
- Create: `tools/asset_pipeline/tests/item_definition_seeder_tests.gd`

**Interfaces:**
- Produces: `validate_inputs(report, manifest, scene_records, fingerprint_provider) -> PackedStringArray`, `build_seed_record(audit_record, manifest_record) -> Dictionary`, `plan_seed(report, manifest, scene_records, existing_paths, fingerprint_provider) -> Dictionary`, and `provisional_display_name(source_path: String) -> String`.
- The returned plan contains `errors`, `definitions_to_create`, and `catalogue_paths_to_append`; it performs no writes.

- [ ] **Step 1: Write failing validation and planning tests**

Use in-memory schema-1.2 fixtures to assert rejection of a wrong schema, missing authoring key, stale fingerprint, and scene/audit set mismatch. Assert a valid missing record produces exactly:

```gdscript
{
    "item_id": &"loot_000043",
    "visual_scene_path": "res://assets/props/Food/New_Item.glb",
    "bulk": 1,
    "utility_id": &"None",
    "utility_value": 0,
    "storage_footprint": Vector3i(2, 3, 1),
    "storage_rotation_degrees": Vector3.ZERO,
    "storage_category": "Food"
}
```

Pass an existing definition path set containing `loot_000001.tres` and assert no create/update operation is returned for it even when audit values differ. Assert Metal Can becomes `Hydration`, `General` is rejected, and filename label derivation is readable.

- [ ] **Step 2: Run RED**

Run the new seed test script and confirm failure because the seeder helper is absent.

- [ ] **Step 3: Implement the pure planner**

Validate all inputs before producing operations. Match report records to manifest records by `authoring_key`, compare current scene paths as exact sets, obtain current hashes only through the injected callable, normalize folder hints against `StorageCategories.ITEM_CATEGORIES`, and apply only the explicit Metal Can override. Existing definition paths are skipped without synthesizing updates.

- [ ] **Step 4: Run GREEN and existing category tests**

Run the seed tests and `storage_category_semantics_tests.gd`; both must exit 0 without warnings.

---

### Task 3: Explicit Seed Command and Initial 42 Resources

**Files:**
- Create: `tools/asset_pipeline/seed_item_definitions.gd`
- Create: `data/items/definitions/loot_000001.tres` through `loot_000042.tres` by the explicit command
- Create: `data/items/item_catalog.tres` by the explicit command
- Modify: `tools/asset_pipeline/tests/item_definition_seeder_tests.gd`

**Interfaces:**
- Consumes the planner from Task 2, `reports/asset_pipeline/main_scene_loot_audit.json`, `tools/asset_pipeline/item_authoring_review.json`, and fresh `MainSceneLootAdapter` records.
- Produces files only after a complete error-free plan; appends only newly created resources to existing catalogue membership.

- [ ] **Step 1: Add a failing filesystem integration test**

In a `user://` temporary fixture, save one existing definition with deliberately non-default authored values, run a helper method that applies a seed plan containing it plus one missing definition, and assert the existing bytes are identical while only the missing `.tres` and catalogue member are added.

- [ ] **Step 2: Run RED**

Run the seed tests and confirm the apply API is missing.

- [ ] **Step 3: Implement explicit writes**

Load JSON with parse/schema checks, call the pure planner, abort on any error, create directories, instantiate `ItemDefinition`, assign only approved scaffold fields, and save with `ResourceSaver.save()`. Load or create `ItemCatalog`, preserve existing definitions in order, append only newly created resources, and save it once. Exit non-zero on any failed save.

- [ ] **Step 4: Run GREEN**

Run the seed test suite and confirm byte-preserving rerun behavior.

- [ ] **Step 5: Run the current audit then explicit seed**

Run `run_main_scene_loot_audit.gd`, verify schema 1.2 and 42 authoring keys, then run `seed_item_definitions.gd`. Confirm it reports 42 created definitions and one catalogue.

- [ ] **Step 6: Verify initial resources and rerun immutability**

Hash all 42 `.tres` files, rerun the seed command, hash again, and assert no definition hash changes. The second run must report zero definitions created.

---

### Task 4: Migrate the Compatibility Facade

**Files:**
- Modify: `prototype_item_catalog.gd`
- Modify: `tools/asset_pipeline/tests/item_catalog_tests.gd`
- Modify: `tools/asset_pipeline/tests/loot_audit_core_tests.gd`

**Interfaces:**
- Preserves: `create_definition_for_node(node: Node) -> ItemDefinition` and `create_definition_for_scene_path(scene_path: String) -> ItemDefinition`.
- Adds: `get_definition_by_id(item_id: StringName) -> ItemDefinition` for focused registry tests and future callers.
- Consumes: `res://data/items/item_catalog.tres` and the Task 1 lookup API.

- [ ] **Step 1: Write failing facade tests**

Assert all catalogue paths resolve through `create_definition_for_scene_path()`, a `Node3D` with a real `scene_file_path` uses that primary path, a fallback-compatible node name resolves only when the scene path is empty, and unknown paths/names return `null`. Replace legacy-ID assertions with authoring-key expectations.

- [ ] **Step 2: Run RED**

Run catalogue and audit-core tests; confirm the 42-path/facade expectations fail against the 11 hard-coded branches.

- [ ] **Step 3: Replace hard-coded construction with delegation**

Preload/load the persistent catalogue once, delegate path and ID lookup, retain `_scene_path_from_name()` only after an empty scene path, and remove `_make_definition()` plus every legacy match branch. Report catalogue load/type failures and return `null`.

- [ ] **Step 4: Run GREEN**

Run catalogue, seed, audit-core, category, manifest, and audit-integration tests. Confirm no legacy ID literal remains outside historical documentation.

---

### Task 5: Initial Baseline and 42-Path Coverage Tests

**Files:**
- Create: `tools/asset_pipeline/tests/item_catalog_initial_seed_tests.gd`
- Create: `tools/asset_pipeline/tests/item_catalog_coverage_tests.gd`

**Interfaces:**
- Consumes the persistent catalogue, schema-1.2 report, manifest, scene adapter, category taxonomy, and exact `PrototypeItemCatalog.create_definition_for_scene_path()` pickup-registration route.

- [ ] **Step 1: Write initial-baseline assertions**

Assert exactly 42 manifest records and catalogue definitions; every definition ID equals its record key; IDs and visual paths are unique; every ID/path lookup succeeds; categories are valid and not General; every Bulk is 1; Utility is None/0; rotation is zero; and Footprint equals `Vector3i(raw_width_cells, raw_depth_cells, 1)` from the current report. Assert Metal Can is Hydration.

- [ ] **Step 2: Run the initial-baseline test**

Expected: PASS against the freshly seeded resources. Keep this script explicitly named initial-seed so future authored edits can retire/update it without weakening production registry tests.

- [ ] **Step 3: Write and run all-42 interaction-resolution coverage**

For every fresh `MainSceneLootAdapter` record, call the exact facade path and assert non-null definition, matching `visual_scene.resource_path`, positive Footprint x/y/z, Bulk compatible with a fresh `CarriedItems.max_bulk`, and no skipped paths. Expected: all 42 pass.

---

### Task 6: Manifest Association-Only Sync

**Files:**
- Modify: `tools/asset_pipeline/authoring_review_manifest.gd`
- Modify: `tools/asset_pipeline/seed_or_sync_item_authoring_review.gd`
- Modify: `tools/asset_pipeline/tests/authoring_review_manifest_tests.gd`
- Modify: `tools/asset_pipeline/item_authoring_review.json` through the explicit command

**Interfaces:**
- Produces: `sync_item_id_associations(manifest: Dictionary, associations: Dictionary) -> Dictionary`, which changes only `item_id` for existing authoring keys.

- [ ] **Step 1: Write a failing preservation test**

Create a manifest record with non-default status, notes, reviewed fingerprints, rotation, and Footprint snapshots. Sync its item ID and assert the entire before/after record differs only at `item_id`. Also assert unknown keys are reported and not created.

- [ ] **Step 2: Run RED**

Run manifest tests and confirm the association-only API is missing.

- [ ] **Step 3: Implement association-only sync and command mode**

Duplicate/normalize the manifest, replace only `records[key]["item_id"]`, preserve every review dictionary exactly, serialize deterministically, and make the explicit sync command use catalogue-derived authoring-key associations after the audit resolves all definitions.

- [ ] **Step 4: Run GREEN and explicit sync**

Run manifest tests, snapshot all review subtrees, execute the sync command, and assert all 42 `item_id` values equal their keys while the review-subtree snapshot is byte-for-byte unchanged.

---

### Task 7: Representative End-to-End Storage Smoke Tests

**Files:**
- Create: `tools/asset_pipeline/tests/item_interaction_reviewability_tests.gd`

**Interfaces:**
- Uses unchanged `WorldItem`, `ItemInstance`, `CarriedItems`, `StorageSurface`, and existing placement/reservation APIs.
- Representative paths cover a regular can/carton, Medical, pistol, rifle, `SM_Hammer_3`, clothing, Fuel, electronics, and pig carcass.

- [ ] **Step 1: Write the smoke-test harness against existing APIs**

For each representative definition, instantiate its visual host, configure a `WorldItem`, pick it into a sufficiently large `CarriedItems`, reserve it on a test `StorageSurface` large enough for its provisional Footprint, configure a stored `WorldItem` with the same `ItemInstance`, then retrieve it and assert reservation release and carried membership. Do not change storage production code to make the harness convenient.

- [ ] **Step 2: Run RED or characterize existing behavior**

If the test exposes a missing test seam, confirm the exact failure and add only a test-side helper. If it exposes a production defect, switch to systematic debugging and add a focused regression test before any fix.

- [ ] **Step 3: Run GREEN**

Run the smoke suite and confirm every representative completes world -> carried -> reserved/stored -> retrieved. Report any item that cannot use a particular surface without changing its Footprint; enlarge the test surface instead.

---

### Task 8: Refreshed Audit and Full Verification

**Files:**
- Modify: generated ignored reports under `reports/asset_pipeline/`
- Modify tests only if an obsolete legacy assertion conflicts with the approved stable-ID baseline

**Interfaces:**
- Produces final evidence and completion report; no further authored gameplay adjustment.

- [ ] **Step 1: Run all focused test scripts**

Run catalogue, seeder, initial-seed, coverage, interaction, category, audit-core, manifest, and audit-integration scripts individually with the Godot console executable. Require exit 0 and no warnings/errors.

- [ ] **Step 2: Run the audit and inspect acceptance counts**

Run `run_main_scene_loot_audit.gd`. Parse its JSON and verify total 42, defined 42, undefined 0, General categories 0, all authoring keys populated, ambiguous correlations 0, and all three review statuses `UNREVIEWED` for all 42. List—not auto-fix—remaining `CATEGORY_FOLDER_MISMATCH` records.

- [ ] **Step 3: Run parser/editor scan**

Run:

```powershell
& 'D:\AI Tools\Godot-4.7-Codex\Godot_v4.7-stable_win64_console.exe' --headless --editor --path 'D:\Godot Projects\Sorting-apoc-PROTOTYPE' --quit
```

Require exit 0 with no GDScript warnings or parse errors.

- [ ] **Step 4: Check repository integrity**

Run `git diff --check`, inspect `git diff --stat`, `git status --short`, and verify `main.tscn`, source assets, storage mechanics, and zoning behavior were not modified by this pass.

- [ ] **Step 5: Stop at the review boundary**

Do not alter any individual pose, Footprint, Bulk, Utility, review status, or final display name. Return the requested A-P completion report plus the focused manual playtest procedure.
