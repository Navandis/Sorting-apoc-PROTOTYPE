# Authored Storage Pose and Posed-Bounds Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make stored visuals and placement ghosts share deterministic authored-pose-first alignment, persist reviewed pose decisions, and publish contributor-accurate posed geometry evidence in audit schema 1.3.

**Architecture:** A focused `StorageVisualPose` helper owns only visual hierarchy construction, rotation, contributor bounds, centering, and shelf clearance. `StoragePlacementController` retains reservation, zoning, fits, placement modes, and item transfer. The audit separately composes `authored_pose * contributor_to_asset_root` for each contributor while preserving canonical measurements.

**Tech Stack:** Godot 4.7, typed GDScript, `.tres` ItemDefinition resources, JSON authoring manifest, headless SceneTree tests.

**Spec:** `docs/superpowers/specs/2026-08-26-authored-storage-pose-and-posed-bounds.md`

## Global Constraints

- Transform hierarchy is packing yaw root → seating/centering root → authored storage-pose root → canonical visual.
- `StorageVisualPose` must not own reservation, zoning, fit selection, placement mode, or inventory transfer.
- Shelf clearance has one source of truth and remains exactly `0.006` m.
- Packing yaw is the existing optional +90° Y rotation and never counter-rotates label-facing authored poses.
- Manual placement cannot add pitch or roll.
- Posed audit composition is `authored_pose * contributor_to_asset_root` per contributor.
- Canonical audit data and all existing `storage_footprint`, Bulk, Utility, held-item/HUD, Receiving, zoning, and source assets remain unchanged.
- Semantic candidates are explicit authored data; ambiguity stops that item for manual tuning and never triggers heuristic auto-orientation.
- GDScript warnings are errors.

---

### Task 1: Shared runtime visual pose and alignment contract

**Files:**
- Create: `storage_visual_pose.gd`
- Create: `tools/asset_pipeline/tests/storage_visual_pose_tests.gd`
- Modify: `storage_placement_controller.gd`

**Interfaces:**
- Produces: `StorageVisualPose.build_visual(packing_root: Node3D, visual: Node, storage_rotation_degrees: Vector3, packing_rotated: bool) -> Dictionary`.
- Produces evidence keys `valid`, `posed_bounds`, `seating_offset`, `packing_basis`, and node references `seating_root`, `pose_root`.
- Consumes no `StorageSurface`, reservation, zoning, carried-item, or fit objects.

- [ ] **Step 1: Write failing synthetic-geometry tests**

Create asymmetric BoxMesh contributors with translated child roots and assert hand-derived outcomes for:

```gdscript
var result := StorageVisualPoseScript.build_visual(
    packing_root, visual, Vector3(0.0, 0.0, 90.0), false
)
assert(is_equal_approx(float(result["posed_bounds"].size.x), 2.0))
assert(is_equal_approx(float(result["posed_bounds"].size.y), 1.0))
assert(is_equal_approx(float(result["seating_offset"].y), expected_offset))
```

Cover zero-pose compatibility, post-X/Z-rotation seating, posed min-Y equal to `0.006`, centered X/Z, packing-yaw preservation of seating, complete-object X/Z swap, and authored basis unaffected by packing yaw. Mutate the source host transform between two builds and assert identical pose-root basis and local posed bounds.

- [ ] **Step 2: Run the new test and verify RED**

Run:

```powershell
& 'D:\AI Tools\Godot-4.7-Codex\Godot_v4.7-stable_win64_console.exe' --headless --path 'D:\Godot Projects\Sorting-apoc-PROTOTYPE' --script 'res://tools/asset_pipeline/tests/storage_visual_pose_tests.gd'
```

Expected: failure because `res://storage_visual_pose.gd` and `build_visual` do not exist.

- [ ] **Step 3: Implement the minimal helper**

Implement `SHELF_CLEARANCE_M := 0.006`, the four-node contract beneath the caller-owned packing root, explicit Euler-to-Basis conversion, recursive contributor collection, eight-corner transformed aggregation, and seating-root translation:

```gdscript
seating_root.position = Vector3(
    -posed_center.x,
    -posed_bounds.position.y + SHELF_CLEARANCE_M,
    -posed_center.z
)
packing_root.rotation = Vector3(0.0, deg_to_rad(90.0) if packing_rotated else 0.0, 0.0)
```

Do not accept or import storage-placement policy types.

- [ ] **Step 4: Refactor final and ghost construction to the helper**

Keep `_spawn_stored_world_item`, `_update_ghost`, `_selected_footprint`, reservations, and fits in `StoragePlacementController`. Replace `_apply_storage_rotation` plus `_align_visual_to_plane` with helper calls for both final and ghost visuals. Rebuild the ghost hierarchy through the same helper and apply ghost material only after construction.

- [ ] **Step 5: Add controller-level equivalence tests and verify GREEN**

Extend the test fixture with a minimal item exposing `get_visual_scene`, `get_storage_rotation_degrees`, and `get_storage_footprint`. Assert final and ghost helper evidence match, zone-auto and manual use the same base authored basis, manual R changes only outer Y packing yaw, and no source world-instance transform is consumed.

Run the focused test until it passes without warnings, then commit runtime helper, controller, and tests.

---

### Task 2: Status-specific manifest freshness and unresolved-pose Footprint gate

**Files:**
- Modify: `tools/asset_pipeline/authoring_review_manifest.gd`
- Modify: `tools/asset_pipeline/tests/authoring_review_manifest_tests.gd`

**Interfaces:**
- `review_evidence(record, current_asset)` keeps its current result keys.
- `CUSTOM_POSE_REQUIRED` currentness depends only on completed status plus matching source fingerprint.
- Footprint currentness additionally requires a current approved pose status (`DEFAULT_POSE_APPROVED` or `CUSTOM_POSE_APPROVED`).

- [ ] **Step 1: Replace the obsolete pose test with failing status-table tests**

Use literal records to prove:

```gdscript
DEFAULT_POSE_APPROVED + changed rotation => stale
CUSTOM_POSE_APPROVED + changed rotation => stale
CUSTOM_POSE_REQUIRED + changed rotation + same fingerprint => current
each completed pose status + changed fingerprint => stale
CUSTOM_POSE_REQUIRED + GEOMETRY_APPROVED footprint => footprint not current
```

- [ ] **Step 2: Run manifest tests and verify RED**

Expected failures: `CUSTOM_POSE_REQUIRED` is currently rotation-sensitive and footprint evidence currently ignores unresolved pose status.

- [ ] **Step 3: Implement minimal status branching**

Compute fingerprint currentness once. For `CUSTOM_POSE_REQUIRED`, use it directly. For the two approved statuses, additionally compare reviewed and current rotations. Gate completed Footprint evidence on an approved/current pose decision while leaving UNREVIEWED behavior unchanged. Keep manifest schema `1.0`.

- [ ] **Step 4: Run manifest tests and verify GREEN**

Run `authoring_review_manifest_tests.gd`; confirm every status/fingerprint/rotation case passes without warnings, then commit manifest logic and tests.

---

### Task 3: Contributor-accurate posed audit schema 1.3

**Files:**
- Modify: `tools/asset_pipeline/loot_audit_core.gd`
- Modify: `tools/asset_pipeline/run_main_scene_loot_audit.gd`
- Modify: `tools/asset_pipeline/item_definition_seeder.gd`
- Modify: `tools/asset_pipeline/tests/loot_audit_core_tests.gd`
- Modify: `tools/asset_pipeline/tests/main_scene_loot_audit_integration_tests.gd`
- Modify: `tools/asset_pipeline/tests/item_definition_seeder_tests.gd`

**Interfaces:**
- Add `aggregate_posed_contributors(contributors: Array[Dictionary], authored_pose: Transform3D) -> Dictionary` or an equivalent explicit API.
- Per-asset report adds `posed_effective_bounds`, `posed_width_m`, `posed_height_m`, `posed_depth_m`, `posed_raw_width_cells`, `posed_raw_depth_cells`, `posed_raw_orientation_a`, and `posed_raw_orientation_b` while retaining `storage_rotation_degrees` and every canonical field.
- Audit schema becomes `1.3`; authoring manifest remains `1.0`.

- [ ] **Step 1: Write failing composition and schema tests**

Use a contributor with non-identity child translation/rotation and a non-zero authored pose. Hand-calculate expected bounds from:

```gdscript
var expected_transform := authored_pose * contributor_to_asset_root
```

Assert the result differs from `contributor_to_asset_root * authored_pose`. Also assert canonical aggregation is unchanged, a known 90° X/Z pose changes posed dimensions, posed raw cells use posed X/Z, and integration schema/fields are exactly 1.3/current.

- [ ] **Step 2: Run audit and seeder tests and verify RED**

Run `loot_audit_core_tests.gd`, `main_scene_loot_audit_integration_tests.gd`, and `item_definition_seeder_tests.gd`. Expected failures are missing posed API/fields and obsolete schema 1.2 expectations.

- [ ] **Step 3: Implement posed contributor aggregation**

For each existing contributor dictionary, compose:

```gdscript
var posed_transform: Transform3D = authored_pose * contributor["transform"]
var posed_bounds: AABB = transform_bounds(contributor["bounds"], posed_transform)
```

Merge those results directly. Do not rotate `effective_canonical_bounds`.

- [ ] **Step 4: Emit schema 1.3 JSON and CSV evidence**

Build `authored_pose` from current definition Euler degrees, calculate posed bounds/raw footprint, add all required JSON and CSV fields, and preserve canonical values/flags. Update the seeder's accepted audit schema and exact error text to 1.3.

- [ ] **Step 5: Run focused audit tests and verify GREEN**

Re-run all three suites and the audit generator. Inspect one zero-pose and one synthetic/custom-pose record to prove canonical/posed separation, then commit audit code and tests.

---

### Task 4: Inspect and persist explicit candidate content

**Files:**
- Modify: the 13 matching files under `data/items/definitions/loot_*.tres`
- Modify: `tools/asset_pipeline/item_authoring_review.json`
- Modify: `tools/asset_pipeline/tests/item_catalog_tests.gd` or create `tools/asset_pipeline/tests/storage_pose_content_tests.gd`

**Interfaces:**
- Explicit yaw map: Milk `Y +90`, Orange Juice `Y +90`, Metal Can `Y +130`, Cough Syrup `Y -120`, pill bottle `Y +90`, Computer Tower `Y +90`, Phone `Y +90`, Electronic Device `Y +90`.
- Semantic candidates are explicit Euler values derived per canonical asset, never runtime heuristics.

- [ ] **Step 1: Inspect canonical firearm/gloves/hammer axes**

Generate orthographic front/side/top inspection renders and contributor-axis/bounds dumps for Assault Rifle, Pistol, Shotgun, Gloves 02, and Hammer 3. For each candidate, require a visible result matching the human semantic target and choose the smallest explicit Euler correction. If any result remains ambiguous, stop that item, leave its definition rotation unchanged, and report it for manual tuning.

- [ ] **Step 2: Write failing content tests with the chosen literal table**

Assert all eight supplied yaw values, each confidently derived semantic value, unchanged Pants rotation/Footprint, unchanged Footprints for every definition, exactly 28 default approvals, exactly 14 custom-required decisions including Pants, 13 achievable custom candidates, current fingerprints, zero reviewed snapshots for defaults, no candidate-as-approved snapshot for custom-required records, Pants unresolved note, Pants Footprint ineligibility, and all Footprint statuses `UNREVIEWED`.

- [ ] **Step 3: Run content tests and verify RED**

Expected: current definitions are all zero rotation and pose reviews are unreviewed.

- [ ] **Step 4: Apply content-only resource and manifest edits**

Add only `storage_rotation_degrees` lines required for the 13 candidates. Update pose review status/fingerprint/notes/snapshots according to the approved semantics. Do not edit any `storage_footprint`, Bulk, Utility, display name, visual scene, GLB, texture, `.import`, or `.godot` content.

- [ ] **Step 5: Run content, catalogue, category, manifest, and audit tests**

Verify the literal authoring table and unchanged Footprints pass, generate schema 1.3 reports, and record canonical vs posed measurements plus posed raw Footprints for the 13 candidates. Commit definitions, manifest, and tests.

---

### Task 5: Representative runtime interaction coverage

**Files:**
- Modify: `tools/asset_pipeline/tests/item_interaction_reviewability_tests.gd`
- Modify: `storage_placement_controller.gd` (add one deterministic visual-construction entry point that delegates directly to `StorageVisualPose`)

**Interfaces:**
- Exercises real `ItemDefinition`, `ItemInstance`, `StorageSurface`, `StoragePlacementController`, `WorldItem`, and `CarriedItems` behavior.

- [ ] **Step 1: Write failing representative placement smoke assertions**

Cover a default upright item, Metal Can explicit yaw, Assault Rifle, Pistol, Shotgun, Gloves, Hammer 3, and unresolved Pants. For each: TAKE → carried → zone-auto placement → stored visual → retrieval. For manual: TAKE → manual ghost → optional R → place → compare final stored pose → retrieval.

- [ ] **Step 2: Run smoke test and verify RED**

Expected: the existing smoke test bypasses placement-controller pose construction and therefore cannot establish the required equivalence.

- [ ] **Step 3: Add the focused visual-construction entry point**

Add `build_visual_pose_for_item(packing_root: Node3D, visual: Node, item, packing_rotated: bool) -> Dictionary`, which reads `item.get_storage_rotation_degrees()` and delegates directly to `StorageVisualPose.build_visual`. Do not expose or move zoning/reservation policy and do not add player controls.

- [ ] **Step 4: Run smoke and placement suites and verify GREEN**

Assert ghost/final local bases and seated bounds agree, manual/auto authored pose roots agree, optional R changes only packing yaw/reservation orientation, Pants remains default/unresolved, and every stored item can be retrieved with reservation release. Commit smoke coverage.

---

### Task 6: Full validation and review handoff

**Files:**
- Generated/ignored only: `reports/asset_pipeline/main_scene_loot_audit.json`, `reports/asset_pipeline/main_scene_loot_audit.csv`

- [ ] **Step 1: Run every focused and integration suite**

Run storage visual pose, interaction reviewability, item catalogue, initial seed, coverage, seeder, storage category, audit core, authoring manifest, and main-scene audit integration tests with the Godot 4.7 console executable.

- [ ] **Step 2: Run generator and editor/parser scan**

```powershell
& 'D:\AI Tools\Godot-4.7-Codex\Godot_v4.7-stable_win64_console.exe' --headless --path 'D:\Godot Projects\Sorting-apoc-PROTOTYPE' --script 'res://tools/asset_pipeline/run_main_scene_loot_audit.gd'
& 'D:\AI Tools\Godot-4.7-Codex\Godot_v4.7-stable_win64_console.exe' --headless --editor --path 'D:\Godot Projects\Sorting-apoc-PROTOTYPE' --quit
```

- [ ] **Step 3: Inspect scope and repository integrity**

Run `git diff --check`, `git status --short`, and targeted diffs. Confirm no Footprints, Bulk, Utility, held/HUD presentation, source assets, `.import`, `.godot`, `main.tscn`, Receiving, zoning, or reservation semantics changed.

- [ ] **Step 4: Prepare the completion report and manual validation list**

Report exact files, runtime ordering, shared ghost/final behavior, orientation-independence result, 28 defaults, 13 candidates and rotations, Pants note, any ambiguity, schema 1.3 fields, canonical/posed examples, posed raw Footprint changes, manifest rule, all test/smoke results, final git status, and a 13-item pose-only playtest procedure requesting `CUSTOM_POSE_APPROVED` or `ADJUST — <issue>`. Explicitly do not request Footprint approval.
