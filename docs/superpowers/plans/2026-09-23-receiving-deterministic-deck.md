# Receiving Deterministic Deck Presenter Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implement the approved first functional slice of a deterministic seeded, TAKE-only Receiving Stage B deck that presents the exact Stage A batch on a private 3.00 m × 2.00 m surface.

**Architecture:** Stage A content and identity remain authoritative. A pure deterministic planner computes complete deck metadata against validated profile data and commits it atomically to `LootBatch`; a private `StorageSurface` backend reconstructs those stable stack groups without registering as player storage; a wing presenter materializes the exact durable `ItemInstance`s and releases manager entries only after ordinary pickup succeeds.

**Tech Stack:** Godot 4.7, typed GDScript, `.tres` resources, `.tscn` composition, repository `SceneTree` test harnesses.

**Spec:** Approved user handoff in `C:/Users/Boschetar/.codex/attachments/773cface-88c5-47b4-914e-726f5baf7b57/Pasted text.txt`.

## Global Constraints

- One implementer only; work on `codex/receiving-deterministic-deck`; do not merge or push.
- Preserve exact Stage A definitions, quantities, durable identities, content seed, Bulk/Utility/value, two-phase commitment, manager lifecycle, and ordinary carried-item transfer.
- Receiving owns only presentation profile/seed, surface/cell/orientation, legal stack grouping/order, reveal, TAKE, and drain presentation.
- No filler/removal/replacement/regeneration, no physics pile/support graph, no PUT/zoning/labels/manual placement/visible grid/F6/player entry, and no Stage C theatre.
- Proof profile is `receiving_deck_stage_b_proof`, revision 1, layout version 1, 0.10 m cells, 4 attempts, one `MainDeck` surface at 3.00 m × 2.00 m with 1.50 m stack clearance.
- Local deck frame is +Z front/apron, -Z rear, +X right, +Y up; planner scan is front-to-rear and deterministically left/right.
- Failure after four attempts is `insufficient_layout_capacity`, leaves the batch byte-identical `CONTENT_COMMITTED`, and consumes no manager slot.
- Default project entry, Gallery B installation, all 16 functional surfaces, normal loose reach 1.4 m, and normal storage behavior stay unchanged.

## Review Focus

- Historical entry snapshots without deck keys must restore exact documented defaults rather than fail reconstruction.
- Atomic deck validation must reject malformed/unknown/duplicate/incoherent placements without any partial entry or batch mutation.
- Planner stacking must append only and must never accidentally call core auto-insertion/base-promotion behavior.
- Released-leading-member reconstruction must center-shrink once per new surviving base and compact vertical positions without replanning.
- Successful pickup notification must occur only after carried transfer and private-stack removal both succeed, and duplicate callbacks must not double-release.

---

### Task 1: Durable deck metadata, validated profile, and four-quarter-turn pose

**Files:**
- Modify: `receiving/loot_batch_entry.gd`
- Modify: `receiving/loot_batch.gd`
- Create: `receiving/receiving_deck_profile.gd`
- Create: `receiving/receiving_deck_surface_spec.gd`
- Create: `receiving/receiving_deck_item_pose.gd`
- Create: `data/receiving/receiving_deck_stage_b_proof.tres`
- Create: `tools/asset_pipeline/tests/receiving_deck_layout_tests.gd`

**Interfaces:**
- Produces: `LootBatch.commit_deck_layout(placements_by_entry_id: Dictionary, profile_id: StringName, profile_revision: int) -> bool`.
- Produces: immutable entry accessors for `has_deck_layout`, `presentation_surface_id`, `presentation_cell_origin`, `presentation_quarter_turns`, `presentation_stack_group_id`, and `presentation_stack_index`.
- Produces: `ReceivingDeckProfile.validate()`, `ReceivingDeckSurfaceSpec.validate()`, and pose helpers that normalize quarter turns, derive footprint parity, measure, and build visuals through `StorageVisualPose`.

- [ ] **Step 1: Write failing metadata/commit/profile/pose tests**

  Add hardened pending-helper tests for legacy defaults, new snapshot round-trip, retained generic arrangement, exact 30 × 20 proof profile, four quarter-turn normalization/parity, profile validation, atomic malformed-placement rejection, and unchanged content fields.

- [ ] **Step 2: Run the focused suite and verify RED**

  Run: `Godot_v4.7-stable_win64_console.exe --headless --path . --script res://tools/asset_pipeline/tests/receiving_deck_layout_tests.gd`

  Expected: nonzero with missing preload/class/API/resource failures attributable to this task.

- [ ] **Step 3: Implement minimal durable metadata and atomic commit**

  Validate every record into detached normalized dictionaries before mutation. Require exactly one placement per remaining entry, finite `Transform3D`, nonempty surface/group IDs, nonnegative cell/index, and per-group contiguous unique indices starting at zero; normalize quarter turns with positive modulo. Only after validation, commit each entry’s deck state and frozen transform, then profile identity and `PREPARED`.

- [ ] **Step 4: Implement profile resources and pose helper**

  Validate finite transforms, unique enabled surface IDs, positive dimensions/cell size/attempt count/revisions. Map q0/q2 to native footprint and q1/q3 to transposed footprint; build q0/q1 through `StorageVisualPose(false/true)` and add outer 180° yaw for q2/q3.

- [ ] **Step 5: Run focused and Stage A snapshot regressions GREEN**

  Run the new layout suite plus `receiving_loot_batch_tests.gd` and `receiving_stage_a_integration_tests.gd`; expect exit 0, one PASS per suite, and no `SCRIPT ERROR`/`FAIL:`.

- [ ] **Step 6: Commit**

  Commit message: `feat: add deterministic Receiving deck metadata`

### Task 2: Deterministic front-to-rear planner and append-only stacks

**Files:**
- Create: `receiving/receiving_deck_layout_diagnostics.gd`
- Create: `receiving/receiving_deck_layout_planner.gd`
- Modify: `tools/asset_pipeline/tests/receiving_deck_layout_tests.gd`

**Interfaces:**
- Consumes: Task 1 profile, pose, `StorageStack.Entry`, and atomic commit API.
- Produces: `prepare(batch: LootBatch, catalog: ItemCatalog, profile: ReceivingDeckProfile) -> ReceivingDeckLayoutDiagnostics` and complete committed deck metadata on success.

- [ ] **Step 1: Write failing deterministic planner tests**

  Cover same seed equality, alternate presentation variation with invariant identities/content, front-to-rear scan, deterministic left/right variation, no size sorting, legal append, incompatible/non-supporting fallback, append failure to empty placement, absence of middle insertion/base promotion, stable stack IDs/indices, and byte-equivalent capacity failure.

- [ ] **Step 2: Run suite and verify RED**

  Expected: planner API missing or required behavior assertions fail.

- [ ] **Step 3: Implement bounded attempts and empty placement**

  Derive each attempt solely from `presentation_seed` plus attempt number. Shuffle entries without sorting by size/category, choose parity/visual choices from the attempt RNG, scan candidate origins from row `grid.y - footprint.y` down to zero, and vary column direction deterministically.

- [ ] **Step 4: Add append-only legal stack search**

  Search stable existing stacks in deterministic creation order. Use `StorageStack.find_manual_append`/equivalent append legality only at `entries.size()` with coherent nonempty auto group, support flags, footprint fit, and 95% clearance. Never call automatic insertion or promotion. Allocate new group IDs as `<surface>:stack_%04d`.

- [ ] **Step 5: Commit only a complete attempt**

  Build detached placement records, calculate frozen transforms from surface transform plus stack host positions, call `commit_deck_layout` once, and return success diagnostics. On exhaustion return `insufficient_layout_capacity` without mutation.

- [ ] **Step 6: Run layout and storage-stack regressions GREEN**

  Run layout, `storage_stack_surface_tests.gd`, and `storage_stacking_interaction_tests.gd`.

- [ ] **Step 7: Commit**

  Commit message: `feat: add deterministic Receiving deck layout`

### Task 3: Private Receiving surface and successful-pickup reach contract

**Files:**
- Modify: `storage_surface.gd`
- Modify: `world_item.gd`
- Modify: `player_controller.gd`
- Create: `gameplay/logistics_wing/receiving/receiving_deck_surface.gd`
- Create: `tools/asset_pipeline/tests/receiving_deck_presenter_tests.gd`

**Interfaces:**
- Produces: generic `StorageSurface.set_player_storage_interaction_enabled(bool)` and `is_player_storage_interaction_enabled()`.
- Produces: `WorldItem.PickupReachKind { LOOSE, STORAGE, RECEIVING }`, `get_pickup_reach_kind()`, Receiving configuration, and `picked_up(item_instance)` emitted after full pickup success.
- Produces: private wrapper lookup by profile surface ID and deterministic reconstruction primitives.

- [ ] **Step 1: Write failing private-surface/reach/pickup tests**

  Assert interaction collision is zero when disabled, both debug modes remain false, no zones or registration, loose/storage defaults remain distinct, Receiving stored items use Receiving reach, real ray selection respects each kind, signal fires after successful stack removal, and failure rolls back carried transfer without a signal.

- [ ] **Step 2: Run suite and verify RED**

- [ ] **Step 3: Add generic StorageSurface opt-out**

  Default to enabled; preserve current normal behavior byte-for-byte. Reapply collision-layer/monitorability state whenever the interaction area is rebuilt.

- [ ] **Step 4: Add WorldItem reach kind and success signal**

  `configure()` resets to LOOSE; `configure_existing()` defaults STORAGE; Receiving configuration sets exact existing identity plus private stack metadata and RECEIVING. Emit only after carried add, storage removal, metadata clear, and interaction disable; then queue host removal.

- [ ] **Step 5: Add player Receiving reach selection**

  Export `receiving_interaction_distance`; ray to the max of all three; select actual allowed distance solely from `PickupReachKind`. Keep saved loose 1.4 m and storage 2.3 m overrides unchanged.

- [ ] **Step 6: Run presenter, storage interaction, and proof regressions GREEN**

- [ ] **Step 7: Commit**

  Commit message: `feat: add private Receiving pickup surfaces`

### Task 4: Presenter, reconstruction, runtime composition, and debug delivery

**Files:**
- Create: `gameplay/logistics_wing/receiving/receiving_deck_presenter.gd`
- Create: `gameplay/logistics_wing/receiving/receiving_deck_presenter.tscn`
- Create: `gameplay/logistics_wing/receiving/receiving_runtime.gd`
- Create: `gameplay/logistics_wing/receiving/receiving_runtime.tscn`
- Modify: `gameplay/logistics_wing/wing_gameplay.tscn`
- Modify: `tools/asset_pipeline/tests/receiving_deck_presenter_tests.gd`
- Modify: `tools/asset_pipeline/tests/wing_gameplay_composition_tests.gd`

**Interfaces:**
- Consumes: prepared batch metadata, Task 3 private surfaces/reach signal, real catalogue/pool/source, and `ReceivingManager`.
- Produces: presenter states `HIDDEN`, `AVAILABLE`, `DRAINED_WAITING_CLOSE`; exact materialization; `reveal_active_batch()`; no automatic post-drain retirement.
- Produces: CLI debug flow gated by `--receiving-deck-debug` with seed/Bulk overrides.

- [ ] **Step 1: Write failing materialization/reconstruction/composition tests**

  Cover exact remaining identities, no-released exact transform epsilon, released-leading-member centered shrink and vertical compaction, safe base TAKE/rekey, exactly-once release/drain, HIDDEN/AVAILABLE pickup, explicit close boundary, normal functional count 16, no old proof/A/B/C nodes, and no synthetic batch without the flag.

- [ ] **Step 2: Run presenter and composition suites and verify RED**

- [ ] **Step 3: Implement stable-group reconstruction**

  Group all original entries by stable presentation group, sort by original index, recover original base origin/footprint, skip released leaders, repeatedly apply `StorageStack.centered_shrink_origin` as the surviving base changes, and commit remaining members in compacted order without planner invocation.

- [ ] **Step 4: Implement presenter materialization and pickup accounting**

  Instantiate each exact visual scene and pose; create/commit `StorageStack.Entry` to the private backend; configure `WorldItem` with exact identity/current runtime stack ID/RECEIVING reach; bind callback to exact batch/entry/item IDs. Treat manager release failure after success as an invariant error. Final TAKE changes state only.

- [ ] **Step 5: Compose greybox deck and runtime in the wing**

  Instance at verified bay transform centered near world X -40.705, top Y 0.82, Z span -1.50..+1.50, with local +Z toward the apron. Add only a neutral 3 × 2 m deck visual. Do not expose surfaces through `get_functional_surfaces()`.

- [ ] **Step 6: Add CLI-only synthetic delivery**

  Parse the three optional numeric flags only when `--receiving-deck-debug` exists; defaults 1842/9001/24. Generate exact committed batch, plan, deposit, and reveal. Normal launch does nothing.

- [ ] **Step 7: Run presenter/composition/manager regression suites GREEN**

- [ ] **Step 8: Commit**

  Commit message: `feat: integrate Receiving deck presenter`

### Task 5: Validation record, live reach measurement, and final verification

**Files:**
- Create: `docs/testing/receiving-deterministic-deck-presenter-validation.md`
- Modify tests only if a verified defect requires a RED→GREEN correction.

**Interfaces:**
- Produces: technical status and concise live-review commands for baseline, presentation seeds 9001/9002/9003, and a small alternate content-seed set.

- [ ] **Step 1: Run the debug scene and measure rear exposed-item camera distance**

  Use the intended apron stance and 2.0 m deck. Set the smallest reliable Receiving-only range and record the measured value as provisional.

- [ ] **Step 2: Run all mandated focused/adjacent suites**

  Run the eight exact test commands from the handoff and reject any nonzero exit, `SCRIPT ERROR`, or `FAIL:`.

- [ ] **Step 3: Run editor and default-project smoke**

  Run `--headless --editor --path . --quit` and `--headless --path . --quit-after 120`; inspect outputs and exit codes.

- [ ] **Step 4: Write validation record**

  Record `IMPLEMENTED / TECHNICALLY VERIFIED / HUMAN REVIEW PENDING`, branch/head, profile/version/geometry/world transform, grid/clearance/reach, seeds/Bulk/attempts/failure behavior, exact results, smoke diagnostics, and live commands. Do not modify master/current-state documents.

- [ ] **Step 5: Final whole-branch review and one RED→GREEN fix pass**

  Review against the approved handoff and the five Review Focus risks. Fix Critical/Important findings only with a failing regression test first; ledger deferred minors.

- [ ] **Step 6: Commit**

  Commit message: `test: record deterministic Receiving deck validation`
