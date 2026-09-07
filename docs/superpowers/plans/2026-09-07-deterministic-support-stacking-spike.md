# Deterministic Support Stacking Spike Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add deterministic single-column support stacking over one existing two-dimensional `StorageSurface` reservation and stop at a technically verified playtest handoff.

**Architecture:** A focused `StorageStack` record owns ordered entry state and pure support/insertion calculations; each `StorageSurface` owns the records whose base reservations occupy its cells. `StoragePlacementController` measures and constructs authored poses, resolves manual or tiered stack-first placement, and commits through the surface, while `WorldItem` routes arbitrary visible-member retrieval back through stack state.

**Tech Stack:** Godot 4.7 stable, typed GDScript, `.tres` `ItemDefinition` resources, headless `SceneTree` test scripts.

**Spec:** `docs/superpowers/specs/2026-09-07-deterministic-support-stacking-spike-design.md`

## Global Constraints

- Keep `StorageSurface` a deterministic 2D cell reservation system; only the base reserves cells.
- Implement centered linear columns only; no upper-layer grids, branches, physics, overhang, pitch/roll, or save serialization.
- Preserve all 42 approved footprints and all approved storage poses; Gloves and Pants remain untouched.
- Author support metadata only for the nine named spike definitions.
- Use actual aligned posed bounds and enforce `MAX_USED_STACK_FRACTION = 0.95` without an item-count cap.
- Test native orientation before the existing optional 90-degree packing orientation; never rotate existing entries.
- Treat GDScript warnings as errors and keep every existing headless suite passing.
- The real Tower/MedKit pair is a dual footprint-and-clearance rejection on the configured compact shelf, not the synthetic clearance-only proof.
- A non-stack-enabled one-entry stack must be observationally identical to the pre-spike storage path.

---

### Task 1: Item support metadata and representative content

**Files:**
- Modify: `item_definition.gd`
- Modify: `item_instance.gd`
- Modify: `data/items/definitions/loot_000002.tres`
- Modify: `data/items/definitions/loot_000005.tres`
- Modify: `data/items/definitions/loot_000006.tres`
- Modify: `data/items/definitions/loot_000009.tres`
- Modify: `data/items/definitions/loot_000019.tres`
- Modify: `data/items/definitions/loot_000028.tres`
- Modify: `data/items/definitions/loot_000030.tres`
- Modify: `data/items/definitions/loot_000031.tres`
- Modify: `data/items/definitions/loot_000039.tres`
- Create: `tools/asset_pipeline/tests/support_stacking_metadata_tests.gd`

**Interfaces:**
- Produces: `ItemInstance.can_be_stacked() -> bool`
- Produces: `ItemInstance.can_support_stack() -> bool`
- Produces: `ItemInstance.get_auto_stack_group() -> StringName`
- Preserves: `ItemDefinition.stackable` without using it for support stacking.

- [ ] **Step 1: Write the failing metadata/content suite**

Create a `SceneTree` suite that loads the catalogue, asserts the four role combinations through real `ItemInstance` getters, asserts the exact nine `(can_be_stacked, can_support_stack, auto_stack_group)` triples, and iterates the other 33 definitions to assert false/false/empty defaults. Include this literal expectation table:

```gdscript
const EXPECTED: Dictionary = {
	"loot_000002": [false, true, &""],
	"loot_000005": [true, true, &"boxed_food"],
	"loot_000006": [true, false, &""],
	"loot_000009": [true, true, &"round_cans"],
	"loot_000019": [true, true, &"round_cans"],
	"loot_000028": [true, true, &"medical_boxes"],
	"loot_000030": [true, true, &"flat_media"],
	"loot_000031": [true, true, &"flat_media"],
	"loot_000039": [true, false, &""]
}
```

- [ ] **Step 2: Run the suite and verify RED**

Run:

```powershell
& 'D:\AI Tools\Godot-4.7-Codex\Godot_v4.7-stable_win64_console.exe' --headless --path 'D:\Godot Projects\Sorting-apoc-PROTOTYPE' --script 'res://tools/asset_pipeline/tests/support_stacking_metadata_tests.gd'
```

Expected: nonzero exit because the new properties/getters do not exist.

- [ ] **Step 3: Add the minimal metadata and getters**

Add these exports beside storage footprint data and null-safe forwarding getters on `ItemInstance`:

```gdscript
@export var can_be_stacked: bool = false
@export var can_support_stack: bool = false
@export var auto_stack_group: StringName = &""
```

Author only the nine literal triples above in their existing `.tres` resources.

- [ ] **Step 4: Run the metadata suite and content regressions**

Run the new suite plus `item_catalog_coverage_tests.gd`, `storage_pose_content_tests.gd`, and `footprint_review_content_tests.gd`. Expected: all exit 0 without changed footprint or pose expectations.

- [ ] **Step 5: Commit the metadata slice**

```powershell
git add -- item_definition.gd item_instance.gd data/items/definitions tools/asset_pipeline/tests/support_stacking_metadata_tests.gd
git commit -m "feat: author support stacking metadata spike"
```

### Task 2: Explicit linear stack record and deterministic algorithms

**Files:**
- Create: `storage_stack.gd`
- Create: `tools/asset_pipeline/tests/storage_stack_rules_tests.gd`

**Interfaces:**
- Produces: `StorageStack.Entry` with `item`, `item_key`, `footprint`, `packing_rotated`, `aligned_bounds`, `posed_height_m`, `can_be_stacked`, `can_support_stack`, `auto_stack_group`, `host`, and `world_item`.
- Produces: `StorageStack.create_entry(item, footprint: Vector2i, packing_rotated: bool, aligned_bounds: AABB) -> Entry`
- Produces: `StorageStack.footprint_fits(incoming: Vector2i, below: Vector2i) -> bool`
- Produces: `StorageStack.find_manual_append(entry: Entry, maximum_top_y_m: float, base_host_y_m: float) -> Dictionary`
- Produces: `StorageStack.find_auto_insertion(orientation_entries: Array[Entry], maximum_top_y_m: float, base_host_y_m: float) -> Dictionary`
- Produces: `StorageStack.is_auto_coherent() -> bool`
- Produces: `StorageStack.entry_host_y(index: int, base_host_y_m: float) -> float`
- Produces: `StorageStack.resulting_top_y_with(entry: Entry, insertion_index: int, base_host_y_m: float) -> float`
- Produces: `StorageStack.centered_shrink_origin(old_origin: Vector2i, old_size: Vector2i, new_size: Vector2i) -> Vector2i`

- [ ] **Step 1: Write failing synthetic rule tests**

Use literal synthetic entries so production metadata is not distorted. Cover immediate-lower fit, swapped incoming orientation, oversized rejection, terminal support rejection, base-only role semantics, coherent and mixed groups, exact 95% below/above boundaries, highest insertion, unchanged existing order/orientations, and lower-index parity bias.

The smart insertion fixture must assert these literal bottom-to-top widths/depths after each insertion:

```gdscript
assert(_footprints(stack) == [Vector2i(5, 5), Vector2i(1, 1)])
assert(_footprints(stack) == [Vector2i(5, 5), Vector2i(2, 3), Vector2i(1, 1)])
assert(_footprints(stack) == [
	Vector2i(5, 5), Vector2i(4, 4), Vector2i(2, 3), Vector2i(1, 1)
])
```

For the threshold, use base host `0.0`, aligned bottom `0.0`, clearance `1.0`, and literal total heights `0.9499` and `0.9501`.

- [ ] **Step 2: Run the rule suite and verify RED**

Run the suite directly. Expected: parser/load failure because `res://storage_stack.gd` is absent.

- [ ] **Step 3: Implement the minimal stack record**

Implement one `RefCounted` class with the nested typed entry and an ordered `Array[Entry]`. Use `const STACK_CONTACT_GAP_M: float = 0.0005` only if a posed-contact integration test demonstrates intersection; otherwise use exactly `0.0`.

`find_auto_insertion` loops orientation entries in native/rotated order and insertion indices from `entries.size()` down to `1`, records the highest valid index, and uses orientation order only to break equivalent-index ties. It never returns index `0`, so smart insertion cannot replace the base.

- [ ] **Step 4: Run the rule suite and verify GREEN**

Expected: `PASS: storage stack rules tests`, exit 0, no warnings.

- [ ] **Step 5: Commit the algorithm slice**

```powershell
git add -- storage_stack.gd storage_stack.gd.uid tools/asset_pipeline/tests/storage_stack_rules_tests.gd tools/asset_pipeline/tests/storage_stack_rules_tests.gd.uid
git commit -m "feat: add deterministic linear stack rules"
```

### Task 3: Surface-owned stack state, zone tiers, and reservation compression

**Files:**
- Modify: `storage_surface.gd`
- Create: `tools/asset_pipeline/tests/storage_stack_surface_tests.gd`

**Interfaces:**
- Consumes: Task 2 `StorageStack` and `StorageStack.Entry`.
- Produces: `StorageSurface.get_stack_count() -> int`
- Produces: `StorageSurface.get_stack(stack_id: String) -> StorageStack`
- Produces: `StorageSurface.get_stack_id_for_item(item_key: String) -> String`
- Produces: `StorageSurface.find_zone_stack_or_empty_fit(storage_category: String, native_entry: StorageStack.Entry, rotated_entry: StorageStack.Entry = null) -> Dictionary`
- Produces: `StorageSurface.find_manual_stack_fit(stack_id: String, entry: StorageStack.Entry) -> Dictionary`
- Produces: `StorageSurface.commit_stack_entry(entry: StorageStack.Entry, fit: Dictionary) -> bool`
- Produces: `StorageSurface.remove_stack_entry(stack_id: String, item_key: String) -> bool`
- Produces: `StorageSurface.get_stack_candidate_transform(fit: Dictionary) -> Transform3D`
- Preserves: `find_zone_auto_fit`, `reserve_at`, `release`, and existing reservation query behavior for non-stack callers.

- [ ] **Step 1: Write failing surface behavior tests**

Construct real `StorageSurface` nodes and synthetic stack entries. Assert:

- one base reservation regardless of upper entry count;
- stack-first before empty placement inside each zone tier;
- matching, General, and unassigned tier order;
- mismatched specific zone exclusion;
- native-before-rotated tie-breaking;
- stable base-origin scan order across multiple compatible stacks;
- invalid insertion falls back first to the next stack, then empty space;
- General cross-category coherent group succeeds;
- specific-zone cross-category routing fails;
- removing top preserves base and transforms;
- removing middle preserves order and recomputes upper Y;
- removing base shrinks the reservation within old cells and recenters survivors;
- parity mismatch uses `floor(delta / 2)`;
- final removal clears reservation, stack record, item lookup, and occupancy.

- [ ] **Step 2: Run the surface suite and verify RED**

Expected: failure because the stack registry and methods are absent.

- [ ] **Step 3: Add the surface registry and six-step search**

Add `_stacks: Dictionary` and `_item_to_stack: Dictionary`. Clear both in `configure()` and `clear_all()`.

Return placement dictionaries with these exact keys:

```gdscript
{
	"valid": true,
	"placement_kind": "stack", # or "empty"
	"stack_id": stack_id,
	"insertion_index": insertion_index,
	"origin": origin,
	"footprint": incoming_footprint,
	"rotated": incoming_rotated,
	"zone_kind": zone_kind,
	"zone_category": zone_category,
	"host_y_m": host_y_m
}
```

For each tier, sort eligible stacks by `(surface_origin.y, surface_origin.x)`, test stack candidates, then call the existing empty-zone scan. Verify the complete base footprint is still inside the current tier before considering a stack.

- [ ] **Step 4: Implement atomic removal and compression**

On base removal, compute the new biased origin, clear only the old reservation cells, install the smaller reservation under the unchanged stack ID, update stack base fields, and recenter/reposition live survivor hosts. Because the new rectangle is wholly inside the old rectangle, no unrelated occupied cell may be touched.

- [ ] **Step 5: Run surface and existing reservation/category suites**

Run `storage_stack_surface_tests.gd`, `storage_category_semantics_tests.gd`, and `item_interaction_reviewability_tests.gd`. Expected: all exit 0.

- [ ] **Step 6: Commit the surface slice**

```powershell
git add -- storage_surface.gd tools/asset_pipeline/tests/storage_stack_surface_tests.gd tools/asset_pipeline/tests/storage_stack_surface_tests.gd.uid
git commit -m "feat: own deterministic stacks on storage surfaces"
```

### Task 4: Explicit surface clearance and posed-height evidence

**Files:**
- Modify: `storage_surface.gd`
- Modify: `storage_prototype_manager.gd`
- Modify: `storage_visual_pose.gd`
- Create: `tools/asset_pipeline/tests/storage_stack_clearance_tests.gd`

**Interfaces:**
- Produces: `StorageSurface.stack_clearance_m: float`
- Produces: `StorageSurface.get_maximum_stack_top_y_m() -> float`
- Produces: `StorageVisualPose.measure_item(item, packing_rotated: bool) -> Dictionary`
- Consumes: Task 3 placement fit methods.

- [ ] **Step 1: Write failing clearance and real-content tests**

Assert `0.95` acceptance/rejection with synthetic entries independently of real content. Load the actual Tower, Book, and MedKit definitions and assert measured heights approximately equal the reviewed baseline probe values `0.45806125`, `0.03608704`, and `0.14315775` metres.

Instantiate `main.tscn`, locate `SM_MetalShelves2_level_1`, and assert:

- its explicit world clearance is approximately `0.55077` metres;
- Tower plus Book is under the 95% maximum when support footprints are evaluated separately;
- Tower plus MedKit is over the 95% maximum;
- the real Tower/MedKit footprint check also fails in both incoming orientations.

- [ ] **Step 2: Run the clearance suite and verify RED**

Expected: missing clearance/measurement APIs.

- [ ] **Step 3: Add explicit profile values and measurement caching support**

Extend `_make_level_profile` with a local-metre `stack_clearance_m` argument and pass it through `StorageSurface.configure`, where parent Y scale converts it to world metres before the surface becomes top-level.

Use these authored local values, derived from current level spacing:

```gdscript
# Metal shelves, bottom to top
[0.822, 0.843, 0.919, 0.919]
# Ventilated locker, bottom to top
[0.952, 0.640, 0.519, 0.519]
```

The top level repeats its family's last representative bay clearance as an explicit prototype cap because it has no next authored shelf plane. Document this limitation in code and the playtest handoff.

`get_maximum_stack_top_y_m()` returns `stack_clearance_m * 0.95`. `measure_item` instantiates the real visual, applies the existing authored pose and packing yaw, returns aligned bounds, and frees the temporary hierarchy; the placement controller will cache this immutable definition/orientation result rather than instantiate each frame.

- [ ] **Step 4: Run clearance, pose, footprint, and parser suites**

Run the new suite, `storage_visual_pose_tests.gd`, `storage_pose_content_tests.gd`, `footprint_review_content_tests.gd`, and a headless editor scan. Expected: all exit 0; the real dual-rejection facts are explicit.

- [ ] **Step 5: Commit the clearance slice**

```powershell
git add -- storage_surface.gd storage_prototype_manager.gd storage_visual_pose.gd tools/asset_pipeline/tests/storage_stack_clearance_tests.gd tools/asset_pipeline/tests/storage_stack_clearance_tests.gd.uid
git commit -m "feat: enforce authored stack clearance"
```

### Task 5: Manual/automatic placement, ghost parity, and targetable members

**Files:**
- Modify: `storage_placement_controller.gd`
- Modify: `world_item.gd`
- Modify: `player_controller.gd`
- Create: `tools/asset_pipeline/tests/storage_stacking_interaction_tests.gd`

**Interfaces:**
- Consumes: Tasks 1-4 metadata, entries, surface fits, and pose measurements.
- Produces: `WorldItem.get_storage_surface() -> Node`
- Produces: `WorldItem.get_storage_stack_id() -> String`
- Produces: `WorldItem.get_storage_item_key() -> String`
- Changes: `WorldItem.configure_existing(host, item_instance, storage_surface, stack_id, item_key)`
- Produces: placement-controller pose cache keyed by definition ID and packing-rotation flag.

- [ ] **Step 1: Write failing interaction tests**

Use real catalogue definitions and real visuals to assert:

- Book/CD automatic coherent stacking and orientation selection;
- repeated Metal Can/Dry Goods stacking, accumulated posed contact, and General cross-category policy;
- MedKit-to-Pistol and MedKit-to-Bread manual appends ignore group and produce terminal caps;
- every stored entry has its own enabled pickup `Area3D` and stable `WorldItem` identity;
- a manual stack ghost's transform, packing basis, authored-pose basis, and selected footprint equal the committed incoming host;
- rotating with `R` changes only incoming packing yaw/footprint and final placement matches it;
- automatic placement is stack-first while manual surface targeting still performs ordinary empty placement;
- pose measurement is cached and not rebuilt on every `update_target()` frame.

- [ ] **Step 2: Run interaction tests and verify RED**

Expected: missing stack-aware controller and `WorldItem` APIs.

- [ ] **Step 3: Implement stack-aware target resolution and placement**

Keep the auto surface ray unchanged. In manual mode, cast a separate pickup-layer ray; when it finds any stored member, resolve its stack and append to the current top. If no stored member is hit, retain the existing nearest-free-cell surface path.

Build native and rotated `StorageStack.Entry` descriptors from cached posed bounds. Auto mode calls `find_zone_stack_or_empty_fit`; manual stack mode calls `find_manual_stack_fit`; manual surface mode retains nearest-cell fitting. Store the chosen `placement_kind`, orientation, insertion index, and host Y in `_current_fit`.

- [ ] **Step 4: Make ghost and final construction share resolved fit data**

Both `_update_ghost` and final spawn use `get_stack_candidate_transform(_current_fit)` and the fit's `rotated` value. Actual visual construction records the returned aligned bounds in the committed entry. A mismatch between measured and actual bounds aborts and returns the item to carry state.

- [ ] **Step 5: Route retrieval through stack state with rollback**

After `carried_items.add_item` succeeds, call `remove_stack_entry(stack_id, item_key)`. If removal fails, immediately call `carried_items.remove_item(_item_instance)` and leave the host/collider active. On success, clear storage identity, disable only this member's collider, and queue only this host for deletion.

- [ ] **Step 6: Run interaction, rule, surface, and existing smoke suites**

Expected: new interaction suite and `item_interaction_reviewability_tests.gd` both exit 0, with independently targetable upper members and deterministic compression.

- [ ] **Step 7: Commit the runtime integration slice**

```powershell
git add -- storage_placement_controller.gd world_item.gd player_controller.gd tools/asset_pipeline/tests/storage_stacking_interaction_tests.gd tools/asset_pipeline/tests/storage_stacking_interaction_tests.gd.uid
git commit -m "feat: integrate deterministic support stacking"
```

### Task 6: Observational-equivalence regression and playtest handoff

**Files:**
- Modify: `tools/asset_pipeline/tests/item_interaction_reviewability_tests.gd`
- Create: `tools/asset_pipeline/tests/storage_unstacked_equivalence_tests.gd`
- Create: `docs/testing/deterministic-support-stacking-playtest.md`

**Interfaces:**
- Consumes: completed stacking implementation.
- Produces: repeatable technical playtest procedure with no production GUI.

- [ ] **Step 1: Write the failing equivalence regression**

Select a definition outside the nine-item spike set and place/retrieve it through the completed real controller path. Compare against literal pre-spike observables:

```gdscript
assert(surface.get_reservation_count() == 1)
assert(surface.get_stack_count() == 1)
assert(stack.entries.size() == 1)
assert(reservation["origin"] == requested_origin)
assert(reservation["footprint"] == requested_footprint)
assert(reservation["rotated"] == requested_rotated)
assert(stored_host.transform.is_equal_approx(expected_transform))
assert(stored_world_item.is_stored_item())
assert(stored_world_item.pickup_into(carried_items))
assert(carried_items.get_selected_item() == original_item)
assert(surface.get_reservation_count() == 0)
assert(surface.get_stack_count() == 0)
assert(is_zero_approx(surface.get_occupancy_ratio()))
```

Also assert the authored pose hierarchy and packing basis match the existing `StoredPackingYaw/StorageSeating/AuthoredStoragePose` contract.

- [ ] **Step 2: Run the equivalence suite and verify RED if any observable drift exists**

Expected initial outcome: the suite catches any changed reservation key, transform, targetability, carry identity, or cleanup behavior. If it passes immediately, mutate the production reservation key or base transform locally to prove the assertion fails, then restore that mutation before continuing.

- [ ] **Step 3: Make the smallest compatibility fixes**

Keep internal stack state invisible at the existing public reservation and interaction boundaries. Do not add special cases to production code that bypass stack cleanup; correct the shared one-entry path.

- [ ] **Step 4: Write the playtest handoff**

Document controls and setup for Flat Media, Manual Mixed, PC Tower, Round Cans, Smart Insertion evidence, top/middle/base retrieval, and ordinary-item regression. State that the compact Metal Shelves level 1 supplies the Tower clearance scenario, Tower/MedKit is also footprint-invalid, and top-level clearance is a provisional authored cap. Include the ten success questions verbatim from the project brief and leave them unanswered.

- [ ] **Step 5: Run the equivalence and complete focused stack suites**

Expected: every focused suite exits 0 and no production metadata outside the nine definitions changed.

- [ ] **Step 6: Commit the regression and handoff slice**

```powershell
git add -- tools/asset_pipeline/tests/item_interaction_reviewability_tests.gd tools/asset_pipeline/tests/storage_unstacked_equivalence_tests.gd tools/asset_pipeline/tests/storage_unstacked_equivalence_tests.gd.uid docs/testing/deterministic-support-stacking-playtest.md
git commit -m "test: verify stacking spike and playtest handoff"
```

### Task 7: Full verification and completion evidence

**Files:**
- Verify all changed files from Tasks 1-6.

**Interfaces:**
- Produces: final evidence for completion-report sections A-Q without promoting the design.

- [ ] **Step 1: Run every new focused suite**

Run the six new scripts individually and record their pass lines and exit codes:

```text
support_stacking_metadata_tests.gd
storage_stack_rules_tests.gd
storage_stack_surface_tests.gd
storage_stack_clearance_tests.gd
storage_stacking_interaction_tests.gd
storage_unstacked_equivalence_tests.gd
```

- [ ] **Step 2: Run the complete existing regression matrix**

Run all twelve baseline scripts recorded before implementation: authoring review, catalogue, initial seed, catalogue coverage, seeder, categories, visual pose, pose content, footprint content, audit core, audit integration, and interaction reviewability. Require exit 0 from each.

- [ ] **Step 3: Run audit, parser/editor, and whitespace verification**

```powershell
& 'D:\AI Tools\Godot-4.7-Codex\Godot_v4.7-stable_win64_console.exe' --headless --path 'D:\Godot Projects\Sorting-apoc-PROTOTYPE' --script 'res://tools/asset_pipeline/run_main_scene_loot_audit.gd'
& 'D:\AI Tools\Godot-4.7-Codex\Godot_v4.7-stable_win64_console.exe' --headless --editor --path 'D:\Godot Projects\Sorting-apoc-PROTOTYPE' --quit
git diff --check e24967a..HEAD
```

Expected: audit success, editor exit 0 with no parser errors or GDScript warnings, and no whitespace errors.

- [ ] **Step 4: Inspect final repository state**

Run `git status --short --branch`, `git diff --stat e24967a..HEAD`, and `git log -8 --oneline`. Confirm ignored `assets/` and `.godot/` remain authoritative and unmodified by Git operations.

- [ ] **Step 5: Produce the A-Q completion report**

List exact files, architecture, metadata, clearance, manual/automatic rules, coherence, insertion tie-breaks, retrieval, real can/Tower evidence, focused and regression results, the playtest document, limitations, and final status. End explicitly at the stacking playtest handoff and state that the design remains a prototype hypothesis.
