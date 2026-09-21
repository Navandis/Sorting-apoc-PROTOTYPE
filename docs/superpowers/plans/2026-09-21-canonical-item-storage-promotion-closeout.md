# Canonical Item Storage Promotion Close-out Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Reconcile the 40 human-approved canonical item pose/footprint decisions, preserve the two blocked definitions, record PROMOTE, and fast-forward the verified result to `main`.

**Architecture:** Treat the saved ItemDefinition resources as immutable human content authority. Measure each canonical posed visual through `StorageVisualPose.build_visual(..., false)`, reconcile only review evidence and explicit expected snapshots, then validate downstream Stack Role and Auto Group decisions against refreshed snapshots without changing gameplay classifications. Documentation and promotion follow only after the content gate is green.

**Tech Stack:** Godot 4.7 GDScript/Resource APIs, deterministic JSON manifest serialization, Git fast-forward integration.

**Spec:** `C:/Users/Boschetar/.codex/attachments/07378bc5-8eac-4338-8c39-98b24ac8cda7/Pasted text.txt`

## Global Constraints

- Preserve every local `data/items/definitions/*.tres` value exactly; never stash, reset, checkout, regenerate, seed over, or revert it.
- Keep `loot_000034` and `loot_000036` blocked and outside the 40 promoted approvals.
- Do not rewrite catalogue references, gameplay scenes, seed hosts, shelf/rack definitions, source assets, runtime orientation/zoning, or normal interactions.
- Preserve Stack Role and Auto Group gameplay fields, notes, and flags; refresh snapshots only when the existing decisions remain semantically consistent.
- Stop before merge/push on any genuine stack-role, Auto Group, catalogue-identity, or blocked-item contradiction.
- Merge to `main` only with `--ff-only`; never force-push.

## Review Focus

- Canonical measurement must use posed/aligned X/Z bounds with packing false and 0.10 m ceiling cells; `storage_footprint.z` must remain human-authored.
- Approximately zero rotations must become `DEFAULT_POSE_APPROVED`; every other eligible rotation must become `CUSTOM_POSE_APPROVED` with exact current snapshots.
- Stack Role and Auto Group snapshots must become current without changing `can_be_stacked`, `can_support_stack`, `auto_stack_group`, flags, or meaningful notes.
- Exactly 40 records must carry current pose/footprint evidence while Gloves/Pants retain `CUSTOM_POSE_REQUIRED` and `UNREVIEWED` footprint/downstream states.
- The final promoted commit must include all and only intended content/metadata/test/docs changes; source GLB/FBX files and scale-normalization state must remain untouched.

---

### Task 1: Reconcile promoted content evidence

**Files:**
- Preserve and commit: locally modified `data/items/definitions/loot_*.tres`
- Modify: `tools/asset_pipeline/item_authoring_review.json`
- Modify: `tools/asset_pipeline/tests/storage_pose_content_tests.gd`
- Create for execution only: ignored `.superpowers/sdd/2026-09-21-canonical-item-storage-promotion-closeout/reconcile_promotion.gd`

**Interfaces:**
- Consumes: current ItemDefinition rotations, footprints, visuals, stack roles, groups, and `StorageVisualPose.build_visual()` aligned bounds.
- Produces: 40 current pose/footprint approvals, refreshed current Stack Role/Auto Group snapshots, explicit literal content-test expectations, and approval counts.

- [ ] **Step 1: Capture immutable human-content evidence**

Record `git status --short`, `git diff -- data/items/definitions`, and the exact modified-definition list in the ignored execution workspace. Hash the 26 modified `.tres` files so reconciliation can prove it did not alter them.

- [ ] **Step 2: Run the existing content regression RED**

```powershell
& 'D:\AI Tools\Godot-4.7-Codex\Godot_v4.7-stable_win64_console.exe' --headless --path 'D:\Godot Projects\Sorting-apoc-PROTOTYPE' --script 'res://tools/asset_pipeline/tests/storage_pose_content_tests.gd'
```

Expected: FAIL on an explicit old rotation or footprint snapshot because the human-approved `.tres` values have advanced.

- [ ] **Step 3: Dry-run canonical measurements and contradiction checks**

For each catalogue definition except `loot_000034` and `loot_000036`, instantiate `visual_scene`, call `StorageVisualPose.build_visual(measurement_root, visual, storage_rotation_degrees, false)`, and calculate `Vector2i(maxi(1, ceili(aligned_bounds.size.x / 0.10)), maxi(1, ceili(aligned_bounds.size.z / 0.10)))`. Print item ID, rotation, authored XYZ footprint, suggestion XY, pose status, footprint status, and downstream-currentness. Abort without writes unless there are 42 unique catalogue IDs, 40 eligible measurements, two exact blocked IDs, valid source fingerprints, and no existing Stack Role/Auto Group classification contradiction.

- [ ] **Step 4: Reconcile the manifest without changing gameplay content**

For every eligible record, write the current source fingerprint and rotation into `storage_pose_review`, select default/custom approval from approximate zero, replace stale candidate notes with canonical-fixture human-approval wording, write the current XYZ footprint/rotation into `footprint_review`, and choose geometry/override from authored XY versus the measured suggestion. For existing approved Stack Role records, refresh the source/rotation/footprint/role snapshot only; for existing approved Auto Group records, refresh only `reviewed_stack_role_snapshot`. Preserve statuses, gameplay values, flags, meaningful notes, group references, registry revisions, and footprint Z. Leave Gloves/Pants review records unchanged.

- [ ] **Step 5: Update explicit content expectations**

Replace the hard-coded rotation and footprint dictionaries/status sets in `storage_pose_content_tests.gd` with literal values from the promoted `.tres` resources and measured classification results. Keep 42 explicit footprints, 40 eligible approvals, and two blocked records; do not calculate expected values from the definitions under test.

- [ ] **Step 6: Run reconciliation tests GREEN**

```powershell
& 'D:\AI Tools\Godot-4.7-Codex\Godot_v4.7-stable_win64_console.exe' --headless --path 'D:\Godot Projects\Sorting-apoc-PROTOTYPE' --script 'res://tools/asset_pipeline/tests/storage_pose_content_tests.gd'
& 'D:\AI Tools\Godot-4.7-Codex\Godot_v4.7-stable_win64_console.exe' --headless --path 'D:\Godot Projects\Sorting-apoc-PROTOTYPE' --script 'res://tools/asset_pipeline/tests/authoring_review_manifest_tests.gd'
& 'D:\AI Tools\Godot-4.7-Codex\Godot_v4.7-stable_win64_console.exe' --headless --path 'D:\Godot Projects\Sorting-apoc-PROTOTYPE' --script 'res://tools/asset_pipeline/tests/stack_role_authoring_tests.gd'
& 'D:\AI Tools\Godot-4.7-Codex\Godot_v4.7-stable_win64_console.exe' --headless --path 'D:\Godot Projects\Sorting-apoc-PROTOTYPE' --script 'res://tools/asset_pipeline/tests/auto_stack_group_registry_tests.gd'
```

Expected: all four exit 0; the production content test reports 42 resolved definitions, 40 current pose/footprint approvals, two blocked records, and zero stale downstream approvals.

- [ ] **Step 7: Verify preservation and commit content reconciliation**

Re-hash the 26 `.tres` files and compare with Step 1, confirm no source asset or gameplay scene is staged, then commit the human-authored definitions with the manifest and content snapshots as one practical commit.

### Task 2: Record PROMOTE and advance the gate

**Files:**
- Modify: `docs/testing/canonical-item-storage-pose-validation.md`
- Modify: `docs/CURRENT_STATE.md`
- Include: `docs/superpowers/plans/2026-09-21-canonical-item-storage-promotion-closeout.md`

**Interfaces:**
- Consumes: Task 1 counts, item list, and green reconciliation evidence.
- Produces: authoritative PROMOTE record and fixed-ladder active-gate state.

- [ ] **Step 1: Update validation evidence**

Set status to `IMPLEMENTED / TECHNICALLY VERIFIED / HUMAN PROMOTED`; record all 40 eligible human reviews, saved `.tres` authority, reconciliation completion, two blocked items, the approximately 10-minute versus 2-hour workflow improvement, primary future authoring workflow, save/load orientation restoration, and deferred four-way display rotation.

- [ ] **Step 2: Update current state**

Mark Canonical Item Storage Pose & Shelf-Front Alignment complete/human-promoted, make fixed-ladder proof the active gate, retain Gloves/Pants and four-quarter-turn debt, and state that ladder/Receiving implementation does not begin in this close-out.

- [ ] **Step 3: Commit promotion documentation**

Run `git diff --check`, inspect the exact documentation diff, and commit the validation, current-state, and plan files together.

### Task 3: Verify and promote the branch

**Files:**
- No additional intended modifications.

**Interfaces:**
- Consumes: committed feature branch from Tasks 1–2.
- Produces: verified feature SHA, fast-forwarded/pushed `main`, clean tracked tree, and origin ancestry proof.

- [ ] **Step 1: Run the full requested test matrix**

Run `storage_pose_content_tests.gd`, `authoring_review_manifest_tests.gd`, `stack_role_authoring_tests.gd`, `auto_stack_group_registry_tests.gd`, `storage_item_orientation_tests.gd`, `storage_visual_pose_tests.gd`, `item_storage_pose_authoring_tests.gd`, `wing_storage_bridge_interaction_tests.gd`, `storage_stacking_interaction_tests.gd`, `storage_singleton_clearance_tests.gd`, `storage_stack_clearance_tests.gd`, and `shelf_ergonomics_review_tests.gd`; require exit 0 for each.

- [ ] **Step 2: Run editor and gameplay smokes**

Run the headless editor scan, shelf ergonomics case B with a bounded timeout, and the default project with a bounded timeout. Require clean startup evidence and the expected installed-surface counts; treat a timeout after successful startup as the normal smoke terminator only when no assertion/script error occurred.

- [ ] **Step 3: Audit final scope and content counts**

Confirm 42 catalogue definitions resolve, exactly 40 eligible pose/footprint reviews are current, two blocked definitions remain, source assets and normalization records are unchanged, no runtime orientation/zoning/rack files changed in the close-out, and the tracked feature tree is clean.

- [ ] **Step 4: Fast-forward and push**

Record the feature SHA, check out `main`, run `git merge --ff-only codex/canonical-item-storage-pose`, re-run the key content and editor verification on `main`, push `main` without force, fetch origin, and prove `git rev-parse main` equals `git rev-parse origin/main` and that the feature SHA is an ancestor of both.

- [ ] **Step 5: Report promotion**

Report feature/main/origin SHAs, changed ItemDefinition count/list, default/custom and geometry/override counts, blocked count, test/smoke evidence, remaining warnings/debt, and fixed-ladder proof as the active gate.
