# Logistics-Wing Greybox Round-01 Revision Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Correct all 20 round-one geometry observations in the existing logistics-wing greybox, including distinct enterable departmental service spaces, while preserving the approved player contract, original evidence, default game scene, and rejected Receiving branch.

**Architecture:** Keep `build_wing_geometry.gd` as the sole coordinate authority and regenerate the saved scene after every structural change. Extend the existing geometry, capture, and traversal contracts before editing production files so openings, boundary ownership, service-space semantics, enclosure edges, aspect-preserving evidence, and controller routes are executable requirements rather than labels or metadata alone.

**Tech Stack:** Godot 4.7 stable, GDScript, `.tscn` resources, Jolt Physics, GL Compatibility renderer, PowerShell, Git

**Spec:** `D:\Godot Projects\Codex Handoff\First Wing Revision\01_WING_REVISION_BRIEF.md`

## Global Constraints

- Continue `codex/logistics-wing-greybox` from `d81783f00d5debfc44c37346c7acaa074c4e4e82`; do not rebuild from `main`.
- Preserve `codex/receiving-elevator-stage-b-pass1-shell` at `c9752c8c68cd55b950dd588542ea271e1acc0aab`; do not merge or copy its rejected shell.
- Preserve existing untracked `reports/logistics_wing/` and `reports/receiving/`; write new evidence only below `reports/logistics_wing/greybox/revision_01/`.
- Use GDD v0.7, Visual Direction v0.4, Prototype Findings v0.7, and Basic Structural Schematic V2 plus the explicit 16 September amendments as authority. Use Detailed Topology V3 only for circulation and territorial intent.
- Do not modify `main.tscn`, `project.godot`, `player_controller.gd`, shared gameplay/catalogue data, imported environment assets, or the default main-scene UID `uid://drbkr86g3cxl1`.
- Build floors, ceilings, wall thickness, collision, open territorial entrances, neutral material-interface envelopes, and opaque inner staffed-core boundaries only. Do not add furnishing, delivery gameplay, facility interactions, NPCs, production art, physical Receiving, or balance changes.
- Normal captures retain the real `1.7162851 m` eye height and `75°` FOV. Contact-sheet image regions remain 16:9; captions occupy separate bands.
- Human spatial approval, workflow promotion, production-art approval, physical Receiving validation, and integrated balance remain unclaimed.

## Coordinate and boundary decisions

All coordinates use `+X east`, `+Z south`, and `Y=0` finished floor. Ordinary clear height remains `3.40 m`, Receiving remains `4.20 m`, wall thickness remains `0.30 m`, and floor/ceiling thickness remains `0.30 m`.

| Area / boundary | Revised authored decision |
| --- | --- |
| Freight enclosure | Separate `5.0 × 7.0 m` shallow cage, `X -44..-39`, `Z -3.5..3.5`, behind a `5.0 m` flanked aperture in the Apron's west wall. Barrier lies at the aperture; rear wall is at `X=-44`; side walls close all bypasses. |
| Receiving Apron | `12.0 × 10.0 m`, `X -39..-27`, `Z -5..5`; accessible clear plan grows from about `84.3 m²` to about `113.5 m²` after wall faces, roughly +35%. |
| Receiving → Backlog | `4.8 m` opening at `X=-27`, `Z -2.4..2.4`, approximately half the Receiving frontage; full-height returns plus a `0.8 m` upper transition strip close the height step. |
| Dispatch | Shallow east-west alcove `9.5 × 3.5 m`, `X -36.5..-27`, `Z -8.5..-5`. |
| Backlog → Sorting | `4.8 m` opening at `X=-15`, `Z -2.4..2.4`, with substantial returns. |
| Sorting pocket/table | Passage remains `X -15..-5`, `Z -5..5`; a north work pocket extends to `Z=-7.2`. Table becomes `4.8 × 1.74 m`, wall-backed at `Z=-6.18`, with `1.6 m` end clearances and an open front. East threshold shifts to `Z 1.0..4.2` to break the west-east axial sightline. |
| Storage shared circulation | West spine `X -5..4.5`, `Z 0.5..5.5`; east spine `X 4.5..26`, `Z -1.5..4.5`; A/B shared junction `X 4.5..9`, `Z -5..-1.5`. C/D/E north boundaries begin at `Z=4.5` or farther south, broadening the spine and deepening its threshold. |
| Gallery A | Restrained north bump; south primary entrance remains. East opening is `2.4 m` wide at `X=4.5`, `Z -4.8..-2.4`, into the named A/B shared junction. |
| Gallery B | Restrained north bump; south primary entrance remains. West opening is `2.4 m` at `X=9`, `Z -4.8..-2.4`; east Kitchen opening is `2.8 m` at `X=16.5`, `Z -8.2..-5.4`. |
| Galleries C/D/E | C carries the single C↔D shared wall, with a `2.5 m` opening at `X=6`, `Z 9.0..11.5`; D does not duplicate it. C receives a southern solid intrusion and D a shallow southern bump; E remains single-entry and closed to Deeper. |
| Medical | Protected corridor `X 5.4..8.0`, `Z -13..-5` opens into a transverse `7.8 × 7.0 m` Supply Anteroom, `X 2.8..10.6`, `Z -20..-13`. The north wall is the opaque inner boundary; a neutral interface envelope sits on the playable side. |
| Kitchen | Route leaves B-east, turns north/east, and reaches an elongated Service Room `X 21.5..32`, `Z -25..-18`. The room's south opening is territorial; its north wall is the opaque inner boundary. Medical has no connection to this route. |
| Workshop | Branch enters a broad Service Room `X -18..-6`, `Z 13..23`; the north opening is territorial, the west wall is the opaque staffed-core boundary, and a neutral interface envelope stays on the playable side. |
| Salvager / blocked continuation | Bent spur remains east/south of Workshop. Machine front moves to about `Z=23.5` with the back enclosure moving with it; sides/rear stay inaccessible. The separate south continuation retains a visible fixed blocker. |
| Deeper approach | Wide leg `X 26..35`, `Z 0..4.5` turns north through `X 32..36`, `Z -7..4.5`, then east through a `3.0 m` narrow leg `X 36..58`, `Z -7..-4`. This clean dogleg closes the missing return and blocks the Storage→Ops vista. |
| Incinerator | Pocket narrows from `10.0 m` to `7.0 m`, `X 28..35`, while retaining a `4.0 m` approach, `2.9 m` machine height, front clearance, and sub-`0.5 m` side gaps that prevent bypass. |
| Bunker Ops | Open Transfer Landing `X 58..65`, `Z -11..-2`; west opening is territorial. North wall is the separate material/staffed-core boundary. A `2.4 m` personnel-door proxy occupies the east wall at `Z -8.0..-5.6`, with solid wall above/below it. |

Shared collinear wall segments have one owner only. In particular, A owns A-east, B owns B-west and B-east, C owns the C↔D divider, and the Medical/Kitchen approach builders begin beyond those walls without recreating them.

---

### Task 1: Lock the revised structural contract

**Files:**
- Modify: `tools/asset_pipeline/tests/logistics_wing_geometry_tests.gd`
- Test: `tools/asset_pipeline/tests/logistics_wing_geometry_tests.gd`

**Interfaces:**
- Consumes: the coordinate/boundary table above and saved `wing_geometry.tscn`.
- Produces: executable checks for revision metadata, actual box geometry, openings, service-space entrances/boundaries, no collinear duplicate walls, ceiling-step closure, and dimensional changes.

- [ ] **Step 1: Add geometry assertions for the complete correction register**

Add helpers that inspect real `BoxShape3D` sizes/positions, sample doorway points at standing height, and compare every structural wall pair for collinear overlap. Assert `layout_revision == "logistics-wing-greybox-round01-revision-01"`; require `MedicalInnerBoundary`, `KitchenInnerBoundary`, `WorkshopInnerBoundary`, `BunkerOpsInnerBoundary`, `DeeperSettlementDoor`, and four interface proxies; reject all old `*FrontageClosure` nodes.

- [ ] **Step 2: Run the focused contract and verify RED**

Run:

```powershell
& 'D:\AI Tools\Godot-4.7-Codex\Godot_v4.7-stable_win64_console.exe' --headless --path . --script res://tools/asset_pipeline/tests/logistics_wing_geometry_tests.gd
```

Expected: non-zero with failures for v1 metadata, the B→Kitchen forbidden edge, absent service-room boundary names/interfaces, missing ceiling-step strip, wrong Receiving/table/Incinerator measurements, blocked doorway samples, and duplicate collinear wall pairs.

- [ ] **Step 3: Commit the verified failing contract**

```powershell
git add tools/asset_pipeline/tests/logistics_wing_geometry_tests.gd docs/superpowers/plans/2026-09-16-logistics-wing-greybox-round01-revision.md
git commit -m "test: lock logistics wing revision contract"
```

### Task 2: Correct the structural builder and regenerate the saved scene

**Files:**
- Modify: `greybox/logistics_wing/build_wing_geometry.gd`
- Regenerate: `greybox/logistics_wing/wing_geometry.tscn`
- Test: `tools/asset_pipeline/tests/logistics_wing_geometry_tests.gd`

**Interfaces:**
- Consumes: Task 1's real-geometry checks.
- Produces: revision-01 floors, ceilings, single-owner structural walls, open territorial entrances, inner boundaries, neutral interfaces, proxies, and anchors in the generated saved scene.

- [ ] **Step 1: Replace v1 coordinates with the exact floor and wall decisions above**

Update `TOPOLOGY_EDGES` so `GalleryB>KitchenApproach` is required, A/B open to `SharedABJunction`, and Medical enters from that junction. Remove B→Kitchen from `FORBIDDEN_EDGES`; keep direct A→B, Medical→Kitchen, E→Deeper, and all non-C↔D gallery links forbidden.

- [ ] **Step 2: Build the three independent service-space boundaries**

For Workshop, Kitchen, Medical, and Ops, author: (1) an open outer threshold, (2) a non-colliding neutral interface envelope on reachable floor, and (3) a colliding opaque inner boundary. Give each a distinct footprint and do not add interaction code.

- [ ] **Step 3: Regenerate the saved scene and verify GREEN**

```powershell
& 'D:\AI Tools\Godot-4.7-Codex\Godot_v4.7-stable_win64_console.exe' --headless --path . --script res://greybox/logistics_wing/build_wing_geometry.gd
& 'D:\AI Tools\Godot-4.7-Codex\Godot_v4.7-stable_win64_console.exe' --headless --path . --script res://tools/asset_pipeline/tests/logistics_wing_geometry_tests.gd
```

Expected: generator exits 0 with revision-01 metadata and the focused geometry suite exits 0 without duplicate-wall or doorway failures.

- [ ] **Step 4: Commit the structural correction**

```powershell
git add greybox/logistics_wing/build_wing_geometry.gd greybox/logistics_wing/wing_geometry.tscn tools/asset_pipeline/tests/logistics_wing_geometry_tests.gd
git commit -m "fix: revise logistics wing structural geometry"
```

### Task 3: Coordinate traversal and revision evidence

**Files:**
- Modify: `tools/asset_pipeline/tests/logistics_wing_capture_tests.gd`
- Modify: `tools/asset_pipeline/tests/logistics_wing_traversal_tests.gd`
- Modify: `greybox/logistics_wing/wing_capture.gd`
- Modify: `greybox/logistics_wing/wing_traversal.gd`
- Modify: `greybox/logistics_wing/wing_review.tscn`
- Local evidence only: `reports/logistics_wing/greybox/revision_01/*`

**Interfaces:**
- Consumes: Task 2's revised anchors and geometry.
- Produces: matched revision cameras, 16:9 captioned contact sheets, normal-controller routes through A-east/B-west/B-east and all service spaces, boundary drives against inner cores/enclosure edges, and same-endpoint C↔D timings.

- [ ] **Step 1: Add failing capture and traversal assertions**

Require output paths below `revision_01`; require `480 × 270` image rectangles inside `480 × 360` tiles with a separate `90 px` caption band; require before/after-matched view basenames for Receiving, Sorting, Workshop, Salvager, storage network/C↔D, Kitchen return, dogleg, Ops door, and both sightline breaks. Require routes `shared_junction_to_gallery_a_east`, `shared_junction_to_gallery_b_west`, `gallery_b_to_kitchen_service`, `shared_junction_to_medical_anteroom`, `sorting_to_workshop_service`, and `deeper_to_ops_landing`, plus inner-boundary and Kitchen/dogleg/junction enclosure drives.

- [ ] **Step 2: Run both contracts and verify RED**

```powershell
& 'D:\AI Tools\Godot-4.7-Codex\Godot_v4.7-stable_win64_console.exe' --headless --path . --script res://tools/asset_pipeline/tests/logistics_wing_capture_tests.gd
& 'D:\AI Tools\Godot-4.7-Codex\Godot_v4.7-stable_win64_console.exe' --headless --path . --script res://tools/asset_pipeline/tests/logistics_wing_traversal_tests.gd
```

Expected: non-zero because v1 paths, cameras, stretched tiles, routes, and old frontage boundary records remain.

- [ ] **Step 3: Update capture, review labels/lights, routes, and boundaries**

Keep full images at `1920 × 1080`. Render each contact tile's `480 × 270` image above a separate caption band. Retarget all affected anchors/waypoints to revised coordinates; add actual controller routes through the three mandated openings and into all four playable service territories. Drive against every inner core boundary and the new door proxy without treating open entrances as blockers.

- [ ] **Step 4: Verify contracts and run real evidence generation**

```powershell
& 'D:\AI Tools\Godot-4.7-Codex\Godot_v4.7-stable_win64_console.exe' --headless --path . --script res://tools/asset_pipeline/tests/logistics_wing_capture_tests.gd
& 'D:\AI Tools\Godot-4.7-Codex\Godot_v4.7-stable_win64_console.exe' --headless --path . --script res://tools/asset_pipeline/tests/logistics_wing_traversal_tests.gd
& 'D:\AI Tools\Godot-4.7-Codex\Godot_v4.7-stable_win64_console.exe' --path . res://greybox/logistics_wing/wing_capture.tscn -- --capture
& 'D:\AI Tools\Godot-4.7-Codex\Godot_v4.7-stable_win64_console.exe' --headless --path . res://greybox/logistics_wing/wing_traversal.tscn -- --traversal-evidence
```

Expected: both contracts pass; capture prints `CAPTURE_COMPLETE`; traversal reports zero failures and writes only below `revision_01`.

- [ ] **Step 5: Inspect every revised full-resolution view and contact sheet**

Compare matched new frames with the preserved round-one reviewer images. If a structural defect remains, add or strengthen the failing contract before changing the builder, regenerate, and rerun affected evidence.

- [ ] **Step 6: Commit coordinated evidence tooling**

```powershell
git add greybox/logistics_wing/wing_capture.gd greybox/logistics_wing/wing_traversal.gd greybox/logistics_wing/wing_review.tscn tools/asset_pipeline/tests/logistics_wing_capture_tests.gd tools/asset_pipeline/tests/logistics_wing_traversal_tests.gd
git commit -m "test: verify revised wing evidence and traversal"
```

### Task 4: Full verification and human-review handoff

**Files:**
- Create: `docs/testing/logistics-wing-greybox-round01-revision-validation.md`
- Modify only when a newly reproduced defect has a failing test first: files from Tasks 1–3

**Interfaces:**
- Consumes: final saved scene, test output, traversal JSON, matched images, Git preservation checks, and known baseline exception.
- Produces: a per-observation 01–20 outcome record and a stopped, unmerged local branch ready for human walkthrough.

- [ ] **Step 1: Run focused, parser, scene-smoke, and full non-hanging regression verification**

Run all three wing suites, the generated-scene rebuild, editor/parser scan, explicit review-scene smoke, unchanged default-main smoke, and every existing non-hanging `tools/asset_pipeline/tests/*_tests.gd` script. Bound `main_scene_loot_audit_integration_tests.gd` to 25 seconds and compare its exact diagnostics to the retained three-assertion baseline.

- [ ] **Step 2: Verify preservation and diff scope**

```powershell
git diff --check 8ee62bd3bc4f23918717517e066d4c6a8cb565df
git diff --exit-code 8ee62bd3bc4f23918717517e066d4c6a8cb565df -- main.tscn project.godot player_controller.gd camera_movement.gd data tools/asset_pipeline/item_authoring_review.json
git rev-parse codex/receiving-elevator-stage-b-pass1-shell
git status --short --untracked-files=all
```

Expected: protected files unchanged; rejected branch remains `c9752c8...`; original evidence folders remain present and untracked; revision evidence exists only under `revision_01`.

- [ ] **Step 3: Write the validation record**

Record exact branch/base/final commit, Godot/version/renderer, a 01–20 PASS/DEFERRED/FAILED table with evidence paths, shared-wall ownership result, revised dimension/boundary table, before/after view mapping, route/boundary measurements, C↔D same-endpoint comparison, capture aspect result, full test output, baseline exception, self-inspection/rework, and separate technical/human/workflow/revision/art/Receiving/balance statuses.

- [ ] **Step 4: Re-run documentation-sensitive checks and commit**

Run `git diff --check`, all three wing suites, parser scan, and review/default scene smoke after the record. Commit only scoped source/tests/docs; leave reports untracked.

```powershell
git add docs/testing/logistics-wing-greybox-round01-revision-validation.md docs/superpowers/plans/2026-09-16-logistics-wing-greybox-round01-revision.md greybox/logistics_wing tools/asset_pipeline/tests/logistics_wing_geometry_tests.gd tools/asset_pipeline/tests/logistics_wing_capture_tests.gd tools/asset_pipeline/tests/logistics_wing_traversal_tests.gd
git commit -m "docs: validate logistics wing round-one revision"
```

- [ ] **Step 5: Stop for human review**

Report launch command, branch/base/final commit, revised evidence directory, known baseline exception, and the remaining subjective walkthrough questions. Do not push, merge, begin functional Receiving, add furnishings, or start production art.
