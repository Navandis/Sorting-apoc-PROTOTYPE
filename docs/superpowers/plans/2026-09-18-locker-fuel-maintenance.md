# Locker Level-2 / Fuel Canister Maintenance Implementation Plan

> **For Codex:** Execute this plan with `superpowers:subagent-driven-development`. Give each task a fresh implementer, then a spec review and code-quality review before proceeding.

**Goal:** Repair the ventilated-locker level-2 rear-row contradiction and reconcile `loot_000015` against its current local source without changing the accepted scene, gameplay rules, item design, default entry, F6, geometry, palette, heights, or Receiving.

**Architecture:** Keep the shared `StoragePrototypeManager` as the sole locker-profile owner so the wing and both legacy instances inherit one calibration. Keep `ItemDefinition` as gameplay truth and `seed_or_sync_item_authoring_review.gd` as the sole durable authoring-manifest writer; add one explicit, guarded Fuel maintenance apply path rather than weakening freshness checks or broadly resnapshotting the catalogue.

**Tech Stack:** Godot 4.7/GDScript, Godot headless test scripts, JSON authoring manifest, PowerShell verification, Git.

**Authoritative specification:** `D:\Codex Handoffs\Sorting_Apocalypse_Locker_Fuel_Maintenance\01_MAINTENANCE_HANDOFF.md`, with verification contract in sibling `04_VERIFICATION_AND_HUMAN_REVIEW.md`. The user explicitly authorized execution and confirmed the default-entry transition closed; no additional repository spec is needed for this bounded maintenance task.

**Measured source basis:**

- Locker GLB SHA-256: `0d1c9a54532ca71ebba71c3b05fa31980a03c7f43c18189720cd3c9de7159c6e`.
- Aggregate locker bounds: `P(-0.422524,-0.000346,-0.731492)`, `S(0.857411,2.758472,1.463009)`.
- The asset's physical front-to-back axis is local X, not the profile field's colloquial width label. The solid inner back-panel plane is local `X=-0.390274`; level-2 shelf support top is local `Y=1.116512` and spans approximately `X=-0.390274..0.367064`, `Z=-0.718901..0.718882`.
- Baseline level-2 profile `(0.390,0.94,0.92,-0.10,-0.03)` produces identity-scale `8x13` and legacy 0.655-scale `5x8` grids. A canonical 1x1 Soda Can on either end of the rear row penetrates the panel by `0.066426 m` at identity scale and `0.023622 m` at 0.655 scale.
- Moving only level-2 X offset from `-0.10` to `0.00` preserves both quantized capacities and leaves the representative Soda Can in front of the measured panel at both scales. All other profile fields remain unchanged.
- Fuel current source SHA-256: `f095c1ee2eb407ced7214686ba599207d3cbcae8cfbbb61ff0cf06242f54ef85`; retained reviewed fingerprint: `e3cbd7d3dd60c9fde76fe92df640aaf62091c9e6c9b6491ee548b0ac1cf10698`.
- Current Fuel canonical bounds: `P(-0.157827,-0.000053,-0.075644)`, `S(0.315692,0.428463,0.150775)`; seated aligned bounds `P(-0.157846,0.006000,-0.075388)`, same size. Zero storage rotation still derives the authored `4x2x1` footprint. Existing roles remain `can_be_stacked=true`, `can_support_stack=false`, Auto Group explicit None.
- The old Fuel binary and old bounds are not retained. Current compatibility can be established against the retained choices and footprint derivation, but byte- or full-topology equivalence to the old export must not be claimed.

---

## Task 1: Checkpoint transition acceptance and immutable baseline

**Files:**
- Modify: `docs/testing/wing-gameplay-foundation-acceptance-2026-09-18.md`
- Create: ignored evidence under `reports/logistics_wing/content_maintenance/locker_fuel/initial/`

- [ ] Append the supplied final default-entry human confirmation without rewriting the earlier review chronology.
- [ ] Record branch/base/remote ancestry, protected tracked blobs and working hashes, ignored asset/import/evidence inventory, actual 39-test baseline, scene smokes, and the 25-second legacy-audit diagnostic stacks.
- [ ] Explicitly distinguish the accepted Git blob/raw LF scene hash from checkout EOL representation.
- [ ] Verify `project.godot`, the fourteen-host wing scene, accepted geometry, F6 owner, player/HUD, Receiving pool, catalogue definitions, and six exact ignored `.import` sidecars before implementation.
- [ ] Commit only the appended acceptance record and this plan as a documentation checkpoint.

## Task 2: Repair M01 with a geometry-bound failing regression

**Files:**
- Create: `tools/asset_pipeline/tests/locker_level2_calibration_tests.gd`
- Modify: `storage_prototype_manager.gd`
- Create/modify: a bounded maintenance review/capture helper under `gameplay/logistics_wing/review/` if needed for matched evidence
- Create: ignored M01 measurement/log/image evidence under `reports/logistics_wing/content_maintenance/locker_fuel/initial/m01/`

- [ ] Write a RED test that binds the measured plane/support coordinates to the exact local locker fingerprint and uses real `StorageVisualPose` bounds plus real installed `StorageSurface` placement transforms.
- [ ] Assert both rear-row ends on level 2 contain the representative 1x1 item at identity scale and 0.655 legacy scale; assert native/90-degree representative manual placements, nearest legal rear placement, all four levels, exact grid capacities, existing fixture transforms/scales, and unchanged metal-shelf profiles.
- [ ] Run the new test before implementation and retain the physical-containment failure output.
- [ ] Capture the pre-fix real F6 grid and two actual rear-row items from the ordinary player-eye view plus one clearly labelled diagnostic view.
- [ ] Change only the second locker level's X offset fraction from `-0.10` to `0.00`; do not change height, width/depth fractions, Z offset, cell size, item bounds/scale, collision, fixtures, or any other level/family.
- [ ] Re-run the focused test, `storage_stack_clearance_tests.gd`, wing bridge/composition/F6 tests, and legacy/wing smokes. Capture matched post-fix views and report old/new world/grid extents and unchanged capacities.
- [ ] Commit M01 source, its focused test/capture source, and any M01-specific durable documentation as one independent commit.

## Task 3: Reconcile M02 through the sole authoring writer

**Files:**
- Modify: `tools/asset_pipeline/authoring_review_manifest.gd`
- Modify: `tools/asset_pipeline/seed_or_sync_item_authoring_review.gd`
- Modify: `tools/asset_pipeline/tests/authoring_review_manifest_tests.gd`
- Create: `tools/asset_pipeline/tests/fuel_canister_maintenance_tests.gd`
- Modify through the writer only: `tools/asset_pipeline/item_authoring_review.json`
- Create/modify: bounded Fuel maintenance review/capture source under `gameplay/logistics_wing/review/` if shared with Task 2
- Create: ignored M02 audit/log/image evidence under `reports/logistics_wing/content_maintenance/locker_fuel/initial/m02/`

- [ ] First preserve the exact RED output from `storage_pose_content_tests.gd` and the Fuel dependency-block in the legacy audit.
- [ ] Add unit tests for a narrow source-refresh helper: it must refuse wrong item/path, unexpected old/current fingerprint, changed rotation/footprint/roles/group, non-current prior decision shapes, or mutation of any non-Fuel record.
- [ ] Add an explicit `--reconcile-fuel-canister-maintenance` apply route to the existing sole writer. It may update only Fuel's top-level source fingerprint and the dependent reviewed source snapshots necessary to carry forward the already approved zero pose, 4x2x1 footprint, stack roles, and explicit None Auto Group. Notes must cite technical maintenance reconciliation and prior decisions without naming a fictitious reviewer or claiming the pending human check passed.
- [ ] Run the apply command once, inspect the semantic JSON diff, and prove every non-Fuel record is byte/semantic equivalent after normalization.
- [ ] Exercise the current local Fuel source through actual catalogue `ItemInstance`, `WorldItem`, carried-items, `StoragePlacementController`, and `StorageSurface` paths on a suitably large legal surface: pickup/carry, native and 90-degree packing, automatic/manual placement, ghost/final pose agreement, retrieval/re-store, identity conservation, and role-appropriate acceptance/rejection. Do not add Fuel to the normal fourteen-host seed or alter the Receiving pool.
- [ ] Re-run `storage_pose_content_tests.gd`, manifest/stack role/Auto Group tests, catalogue/pool/seed guards, and the legacy audit. The Fuel freshness assertion/dependency block must disappear; unrelated diagnostics remain disclosed.
- [ ] Capture current Fuel appearance, held state, native/rotated stored poses and retrieval path in a labelled maintenance-only review scene/fixture that leaves ordinary state unchanged on exit.
- [ ] Commit M02 writer/helper/tests, targeted manifest record and M02-specific durable evidence as one independent commit.

## Task 4: Integrated verification, preservation, and review bundle

**Files:**
- Create: `docs/testing/locker-fuel-maintenance-validation.md`
- Modify: `docs/CURRENT_STATE.md`
- Modify: `docs/README.md`
- Create: ignored final logs/manifests/contact sheet/ZIP under `reports/logistics_wing/content_maintenance/locker_fuel/initial/final/`

- [ ] Discover the actual non-hanging suite again and run all scripts with strict exit/PASS/assertion/diagnostic accounting; include the new focused tests.
- [ ] Re-run normal default, explicit `main.tscn`, neutral `wing_review.tscn`, parser/editor initialization, M01/M02 capture scenes, and the 25-second bounded legacy audit.
- [ ] Compare protected pre/post blobs and hashes. Expected tracked differences are only the plan/acceptance/current records, M01 owner/test/review helpers, M02 writer/helper/test/targeted manifest record, and final validation/index/status documents.
- [ ] Verify default UID/path, fourteen live seed hosts and authored transforms, F6 default-OFF/F7-disabled behavior, accepted geometry, player/HUD, fixture transforms/heights, other locker levels, metal profiles, all other item definitions/manifest records, Gloves/Pants blocks, Receiving pool, ignored assets/imports, and local branch ancestry.
- [ ] Write separate M01 and M02 technical results and separate human PROMOTE/REVISE questions. State that both human decisions remain pending and that Fuel remains blocked from the normal seed until later approval.
- [ ] Build a compact review ZIP with changed source/tests/docs, measurement JSON/log summaries, full-resolution images/contact sheet and SHA manifest; exclude raw GLBs, `.godot`, broad historical reports and private/licensed content.
- [ ] Commit final documentation only. Do not merge, push, change default entry, remove branches, start palette/height work, or begin Receiving.

## Verification command pattern

Use the authoritative executable and project path for every Godot invocation:

```powershell
& 'D:\AI Tools\Godot-4.7-Codex\Godot_v4.7-stable_win64_console.exe' --headless --path . --script 'res://tools/asset_pipeline/tests/<test>.gd'
```

Rendered capture commands use `--rendering-method gl_compatibility` and an explicit maintenance review scene/flag; normal/default launch remains untouched. Treat any `SCRIPT ERROR`, assertion, parse/resource failure, missing PASS marker, timeout or unexpected diagnostic as failure even when the process exits zero.
