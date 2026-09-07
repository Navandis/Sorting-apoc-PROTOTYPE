# Stacking Stabilization Pass Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Correct promoted-base ownership, contextual manual stack orientation, and disabled erased-cell behavior without expanding stacking scope.

**Architecture:** `StorageSurface` remains the owner of stack, reservation, occupied-cell, and item-to-stack consistency. `WorldItem` exposes one narrow storage-stack rebind operation for surviving entries. `StoragePlacementController` supplies preferred and alternate manual entries while keeping `_rotated` unchanged, and the existing zone-initialized flag distinguishes untouched from deliberately erased cells.

**Tech Stack:** Godot 4.7 stable, typed GDScript, headless `SceneTree` regression scripts.

**Spec:** `docs/superpowers/specs/2026-09-07-stacking-stabilization-pass-design.md`

## Global Constraints

- Preserve the pre-existing uncommitted `main.tscn` changes and do not stage them.
- Do not implement larger-item base promotion/insertion, reservation expansion, stack movement, or smart-insertion reordering.
- Do not change mixed-stack auto-coherence or shelf-clearance behavior.
- Do not change item footprints, storage poses, stack groups, save serialization, held/HUD presentation, Receiving, Bulk, Utility, source assets, 95% clearance, or multi-column packing.
- Every production change follows an observed failing focused regression.

---

### Task 1: Atomic promoted-base ownership rekey

**Files:**
- Modify: `storage_surface.gd`
- Modify: `world_item.gd`
- Test: `tools/asset_pipeline/tests/storage_stack_surface_tests.gd`
- Test: `tools/asset_pipeline/tests/storage_stacking_interaction_tests.gd`

**Interfaces:**
- Produces: `WorldItem.rebind_storage_stack(new_stack_id: String) -> bool`
- Produces: an internal `StorageSurface` promoted-base transition that validates before mutation and rekeys every active ownership structure.

- [ ] **Step 1: Write failing registry-complete promotion tests**

Extend the stack-surface base-removal case so promotion expects the stack and reservation under the promoted entry ID, expects all survivors to map to that ID, scans copied occupancy/reservation state through public query methods, and expects the old base ID to return no stack, no reservation, and no item lookup. Add real `WorldItem` components to survivors and assert their reported stack ID changes.

- [ ] **Step 2: Write failing removed-base placement regressions**

Build a real three-entry stack through `StoragePlacementController`, retrieve its base through `WorldItem.pickup_into()`, and assert: immediate manual empty placement works; auto placement can use a valid empty destination; return to the same surface works while the promoted stack exists; one-carried success empties the carried strip; and multi-carried success removes only the selected base without unexpected pre-placement selection mutation.

- [ ] **Step 3: Run focused tests and verify RED**

Run:

```powershell
& 'D:\AI Tools\Godot-4.7-Codex\Godot_v4.7-stable_win64_console.exe' --headless --path 'D:\Godot Projects\Sorting-apoc-PROTOTYPE' --script 'res://tools/asset_pipeline/tests/storage_stack_surface_tests.gd'
& 'D:\AI Tools\Godot-4.7-Codex\Godot_v4.7-stable_win64_console.exe' --headless --path 'D:\Godot Projects\Sorting-apoc-PROTOTYPE' --script 'res://tools/asset_pipeline/tests/storage_stacking_interaction_tests.gd'
```

Expected: failures specifically report the old base still owns the stack/reservation or blocks ordinary placement.

- [ ] **Step 4: Implement the validated atomic rekey**

Add the narrow `WorldItem` rebind method. In `StorageSurface`, validate the promoted ID, existing ownership, destination-key availability, centered-shrink bounds, and old-cell ownership before modifying `stack.entries` or registries. After validation, perform only dictionary/array assignments that cannot fail: move stack and reservation keys, rewrite occupied cells and survivor lookups, update survivor world metadata, then reposition entries.

- [ ] **Step 5: Run focused tests and verify GREEN**

Re-run both commands from Step 3 and require exit 0 with no assertion failures.

### Task 2: Preferred-first contextual manual stack orientation

**Files:**
- Modify: `storage_surface.gd`
- Modify: `storage_placement_controller.gd`
- Test: `tools/asset_pipeline/tests/storage_stack_surface_tests.gd`
- Test: `tools/asset_pipeline/tests/storage_stacking_interaction_tests.gd`

**Interfaces:**
- Produces: `StorageSurface.find_manual_stack_fit(stack_id: String, preferred_entry: StorageStack.Entry, alternate_entry: StorageStack.Entry = null) -> Dictionary`
- Consumes: controller `_rotated` only as the preferred-orientation input; the effective orientation remains in the returned fit.

- [ ] **Step 1: Write failing orientation-resolution tests**

Use asymmetric literal footprints to assert preferred-invalid/alternate-valid selects alternate, both-valid selects preferred, and neither-valid returns invalid. Add a controller integration case that records `_rotated`, computes a targeted fit, updates the ghost, commits it, and asserts `_rotated` was not changed by fit resolution while ghost and committed packing yaw match the fit's `rotated` value.

- [ ] **Step 2: Run focused tests and verify RED**

Run the two focused test scripts from Task 1. Expected: the preferred-invalid/alternate-valid case remains invalid because only one manual entry is currently evaluated.

- [ ] **Step 3: Implement preferred-first selection**

Update `find_manual_stack_fit` to evaluate the preferred entry first and return immediately when valid; otherwise evaluate the optional alternate. In the controller's targeted-stack branch, construct the preferred entry from `_rotated`, construct only the opposite 90-degree entry for a non-square footprint, and pass both without assigning to `_rotated`.

- [ ] **Step 4: Run focused tests and verify GREEN**

Re-run both focused scripts and require exit 0 with the effective `fit["rotated"]` shared by ghost and final placement.

### Task 3: Disabled erased-cell semantics

**Files:**
- Modify: `storage_surface.gd`
- Test: `tools/asset_pipeline/tests/storage_category_semantics_tests.gd`
- Test: `tools/asset_pipeline/tests/storage_stack_surface_tests.gd`
- Test: `tools/asset_pipeline/tests/storage_stacking_interaction_tests.gd`
- Test: `tools/asset_pipeline/tests/storage_unstacked_equivalence_tests.gd`

**Interfaces:**
- Produces: internal footprint-enabled policy based on `_zones_initialized` and non-empty zone cells.
- Preserves: `initialize_zones_if_needed(StorageCategories.GENERAL)` first-use behavior.

- [ ] **Step 1: Write failing category and disabled-cell tests**

Replace unassigned-fallback expectations with literal invalid results after zones are initialized. Assert matching specific and General success, mismatched specific failure, automatic stacking rejection when a base footprint is erased, manual category-mismatch success on enabled cells, manual empty and manual stack rejection on erased cells, and first-use initialization to General across the complete grid.

- [ ] **Step 2: Run focused tests and verify RED**

Run category semantics, stack surface, stacking interaction, and unstacked-equivalence scripts. Expected: initialized blank cells are still selected as automatic fallback and manual nearest-fit still accepts them.

- [ ] **Step 3: Implement the minimal enabled-cell policy**

Remove `""` from both automatic tier builders. Gate manual nearest-fit candidates and manual stack targets through one footprint-enabled helper that returns true on untouched surfaces and otherwise requires every covered zone category to be non-empty. Keep specific-category matching and General behavior unchanged.

- [ ] **Step 4: Run focused tests and verify GREEN**

Re-run the four scripts and require exit 0 with all disabled-cell assertions passing.

### Task 4: Scope records, full verification, and manual handoff

**Files:**
- Create: `docs/testing/stacking-stabilization-pass-playtest.md`
- Verify only: all production and regression files from Tasks 1-3

**Interfaces:**
- Produces: manual procedures for base retrieval, same-stack return, MedKit orientation, and erased-cell behavior.
- Records: the two explicitly deferred future refinements without implementing them.

- [ ] **Step 1: Write the focused manual validation handoff**

Document the four requested playtest sequences and record exactly:

```text
BASE_PROMOTION_SMART_INSERTION — PROTOTYPE REFINEMENT PENDING DESIGN
MIXED_STACK_AUTO_COHERENCE — REQUIRES BROADER CONTENT PLAYTEST
```

- [ ] **Step 2: Run every requested headless suite**

Run all `tools/asset_pipeline/tests/*.gd` scripts individually with Godot 4.7, then run `res://tools/asset_pipeline/run_main_scene_loot_audit.gd`. Require every process to exit 0 and inspect output for parser errors or assertion failures.

- [ ] **Step 3: Run parser/editor and whitespace verification**

Run:

```powershell
& 'D:\AI Tools\Godot-4.7-Codex\Godot_v4.7-stable_win64_console.exe' --headless --editor --path 'D:\Godot Projects\Sorting-apoc-PROTOTYPE' --quit
git diff --check
git status --short --branch
```

Require Godot exit 0, `git diff --check` exit 0, and confirm `main.tscn` remains a separate pre-existing modification.

- [ ] **Step 4: Review the final diff against every scope boundary**

Confirm no item definition, pose, stack-rule ordering, clearance, mixed-stack coherence, save, scene, source-asset, HUD, Receiving, Bulk, Utility, or multi-column behavior changed. Report exact files, red/green evidence, full verification, manual validation, deferred features, and final git status.
