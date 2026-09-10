# Auto Base Promotion and Robust Stack Clearance Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add automatic-only base promotion with atomic ownership transfer and replace per-level clearance literals with adjacent-plane derivation plus explicit per-instance open-top caps.

**Architecture:** `StorageStack` evaluates pure physical promotion rules, `StorageSurface` evaluates expansion/zone policy and owns one shared base transition, and `StoragePlacementController` preserves the carried-item transaction. `StoragePrototypeManager` converts family-local profile geometry to world clearance while a data-only per-instance context supplies open-top world metres.

**Tech Stack:** Godot 4.7 stable, typed GDScript, headless `SceneTree` regression scripts.

**Spec:** `docs/superpowers/specs/2026-09-08-auto-base-promotion-clearance-design.md`

## Global Constraints

- Manual placement remains top-only.
- Mixed/non-auto-coherent stacks remain ineligible for automatic insertion.
- Preserve matching-category then General tier order and stack-before-empty behavior.
- Erased cells remain disabled; mismatched specific zones remain invalid.
- Do not add multi-column packing, support trees, physics, item metadata, footprints, poses, save data, Bulk/Utility, HUD, or unrelated fixes.
- `MAX_STACK_USED_FRACTION = 0.95` is defined once and applied once.
- All currently placed shelf instances receive explicit open-top world-metre values.

---

### Task 1: Pure base-promotion rules

**Files:**
- Modify: `storage_stack.gd`
- Test: `tools/asset_pipeline/tests/storage_stack_rules_tests.gd`

**Interfaces:**
- Produces: `StorageStack.find_auto_base_promotion(orientation_entries: Array, maximum_top_y_m: float, base_host_y_m: float) -> Dictionary`
- Preserves: `find_auto_insertion()` indices `size ... 1` and manual append behavior.

- [x] **Step 1: Write failing rule tests**

Add literal synthetic entries proving a `4x4` incoming supporter becomes index zero beneath `2x2 -> 1x1`, native wins when both orientations work, rotated works when native cannot, incoming `can_be_stacked` is irrelevant, existing base `can_be_stacked` and incoming `can_support_stack` are required, mixed stacks reject, height rejects, and existing order/rotations remain unchanged after inserting from the returned fit.

- [x] **Step 2: Run the rule suite and verify RED**

Run `storage_stack_rules_tests.gd`. Expected: failure because `find_auto_base_promotion` is missing.

- [x] **Step 3: Implement the pure evaluator**

Add a separate index-zero evaluator using the incoming base aligned lower bound in its resulting-top calculation. Return the same diagnostic fields as ordinary insertion plus `insertion_index = 0`; do not mutate entries.

- [x] **Step 4: Run the rule suite and verify GREEN**

Require `PASS: storage stack rules tests`.

### Task 2: Expansion selection and shared atomic base transition

**Files:**
- Modify: `storage_surface.gd`
- Test: `tools/asset_pipeline/tests/storage_stack_surface_tests.gd`

**Interfaces:**
- Produces: automatic promotion fits with `placement_kind = "base_promotion"`, old `stack_id`, new origin/base footprint, and incoming entry.
- Produces: shared `_can_transition_stack_base(...) -> bool` and `_commit_stack_base_transition(...) -> void` used by removal and insertion.

- [x] **Step 1: Write failing expansion and authority tests**

Cover valid enlargement, native/rotated surface fit, order/rotation retention, edge-offset origin, deterministic row-column tie, old-rectangle containment, unrelated reservation, erased cell, wrong specific zone, General cross-category acceptance, clearance rejection, normal insertion preference, mixed rejection, and exact new-ID authority across registry/reservation/cells/lookups/stack/WorldItems.

- [x] **Step 2: Run surface and rule suites and verify RED**

Expected: promotion candidates fall back to empty placement and no expanded transition exists.

- [x] **Step 3: Implement two-pass stack search and origin enumeration**

For each tier, search ordinary insertions across sorted stacks, then promotions across the same sorted stacks. For each orientation, enumerate containment origins, validate occupancy and exact tier cells, and choose minimum doubled-center distance with row/column ties.

- [x] **Step 4: Generalize and use the base transition**

Validate exact old ownership and mode-specific ID expectations before mutation. Use the common commit for both removal shrink and incoming-base expansion. Revalidate promotion fit at commit and make all post-validation assignments infallible.

- [x] **Step 5: Run surface and rule suites and verify GREEN**

Require both focused suites to pass.

### Task 3: Controller transaction and manual non-regression

**Files:**
- Modify: `storage_placement_controller.gd`
- Modify only if required by the exact rollback contract: `carried_items.gd`
- Test: `tools/asset_pipeline/tests/storage_stacking_interaction_tests.gd`

**Interfaces:**
- Consumes: prepared valid `base_promotion` fit and atomic surface commit.
- Preserves: manual `find_manual_stack_fit` as top append only.

- [x] **Step 1: Write failing controller tests**

Use real controller/carried/surface components to prove successful automatic promotion consumes the selected item, failed commit preserves original stack and exact carried slots/selection, and manual targeting never produces index zero or changes the existing base.

- [x] **Step 2: Run the interaction suite and verify RED**

Expected: automatic placement chooses empty placement or rollback changes the carried selection/slot arrangement.

- [x] **Step 3: Implement prepared promotion placement and exact fallback**

Build and validate the provisional host/entry before taking the selected carried item. Remove it immediately before the infallible surface transition. Retain a defensive exact slot/selection restoration path if the expected invariant is violated.

- [x] **Step 4: Run interaction, surface, and unstacked-equivalence suites and verify GREEN**

Require all three to pass.

### Task 4: Derived closed clearance and explicit open-top context

**Files:**
- Create: `storage_shelf_clearance_context.gd`
- Modify: `storage_prototype_manager.gd`
- Modify: `storage_surface.gd`
- Modify: `main.tscn`
- Test: `tools/asset_pipeline/tests/storage_stack_clearance_tests.gd`

**Interfaces:**
- Produces: `StorageShelfClearanceContext.open_top_clearance_world_m: float`
- Changes: `StorageSurface.configure(..., requested_stack_clearance_world_m: float)` accepts already converted world metres.
- Produces: `StorageSurface.MAX_STACK_USED_FRACTION = 0.95` as the only usable-height authority.

- [x] **Step 1: Write failing clearance tests**

Assert all closed-level derived migration values, X/Z invariance, Y proportionality, changed level-spacing response, exactly-once 95% behavior, explicit open-top values on all four placed shelves, different caps for identical models, top-cap Y-scale independence, and fallback warning behavior.

- [x] **Step 2: Run the clearance suite and verify RED**

Expected: profiles still expose literals and no context component exists.

- [x] **Step 3: Implement derived clearance and context authoring**

Remove closed-level clearance literals. Derive adjacent-plane local gaps, multiply by Y scale once in the manager, pass world metres to surfaces, and read the final level from a direct per-instance context child. Add explicit context children and current migration values to every placed shelf. Warn when the family fallback is used.

- [x] **Step 4: Run clearance, interaction, and pose suites and verify GREEN**

Require clearance, stacking interaction, visual pose, pose content, and footprint content suites to pass.

### Task 5: Full verification and focused playtest handoff

**Files:**
- Modify: `docs/testing/deterministic-support-stacking-playtest.md`
- Verify: all files above

**Interfaces:**
- Produces: focused manual scenarios for successful/blocked base promotion and open-top instance differences.

- [x] **Step 1: Update the playtest handoff**

Add auto-only base promotion, edge expansion, blocked expansion, normal-insertion preference, manual top-only confirmation, and explicit open-top context checks. Retain the prototype gate language.

- [x] **Step 2: Run every headless regression and audit**

Run every `tools/asset_pipeline/tests/*.gd` script individually plus `run_main_scene_loot_audit.gd`; require exit zero.

- [x] **Step 3: Run editor and repository verification**

Run the headless editor scan, `git diff --check`, and inspect `git status`, diff, and recent commits.

- [x] **Step 4: Stop at playtest handoff**

Report exact changes and verification evidence without claiming human playtest success or extending scope.
