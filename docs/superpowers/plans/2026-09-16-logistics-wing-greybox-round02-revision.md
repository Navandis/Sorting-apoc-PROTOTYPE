# Logistics-Wing Greybox Round-02 Revision Plan

> **Execution:** Use `superpowers:executing-plans`, `superpowers:test-driven-development`, `superpowers:systematic-debugging`, and `superpowers:verification-before-completion`. Work in the existing checkout because the authoritative untracked evidence must be preserved in place.

**Goal:** Correct the bounded round-two structural register for the whole logistics wing, delete the abandoned Workshop continuation at every layer, and deliver source, traversal, measurements, and visual evidence for human review without merging or pushing.

**Architecture:** Keep `greybox/logistics_wing/build_wing_geometry.gd` as the sole coordinate authority. Add behavior-focused RED contracts against the saved scene and evidence manifests, implement each coordinate group in dependency order, regenerate `wing_geometry.tscn`, then synchronize capture, traversal, review labels/lights, and validation. All new evidence is untracked below `reports/logistics_wing/greybox/revision_02/`.

**Spec:** `docs/superpowers/specs/2026-09-16-logistics-wing-greybox-round02-design.md`

## Preservation gates

- Verified start is `add47716a125f3fc035e10d50fdb11a15836659b` on `codex/logistics-wing-greybox`; do not reset.
- Preserve all user and historical untracked files. Do not clean the parent reports tree.
- Preserve rejected branch `codex/receiving-elevator-stage-b-pass1-shell` at `c9752c8c68cd55b950dd588542ea271e1acc0aab`.
- Do not modify `main.tscn`, `project.godot`, `player_controller.gd`, `camera_movement.gd`, gameplay/catalogue data, imported assets, or the default main-scene UID.
- Do not add freight lining, furnishing, production art, physical Receiving, facility gameplay, delivery choreography, NPCs, or balance changes.

## Task 1: Lock the round-two structural contract

**Files:**
- Modify `tools/asset_pipeline/tests/logistics_wing_geometry_tests.gd`
- Modify `tools/asset_pipeline/tests/logistics_wing_capture_tests.gd`
- Modify `tools/asset_pipeline/tests/logistics_wing_traversal_tests.gd`

- [x] Add saved-scene checks for exact key rectangles/openings, the non-overlapping ceiling transition, floor/ceiling ownership, joined corners, A/B/Medical skin removal, C irregular mass, E ratio, Kitchen route, Deeper run ratio, and the Sorting-eye freight ray.
- [x] Replace every stub expectation with absence checks against observable manifests and scene behavior. Require a Workshop south-wall boundary probe instead of grepping production source.
- [x] Require Dispatch traversal, revision-02 paths, sequential ceiling/turn views, honest Salvager approach coverage, manifest revision/hash fields, and no removed stub capture/route/boundary.
- [x] Run all three focused suites and capture their expected RED failures against `add47716`.
- [x] Commit the failing contracts and this design/plan as `test: lock logistics wing round-two contract`.

## Task 2: Correct junction foundation and northern service routes

**Files:**
- Modify `greybox/logistics_wing/build_wing_geometry.gd`
- Regenerate `greybox/logistics_wing/wing_geometry.tscn`

- [ ] Introduce explicit joined-end wall helpers and use them at representative and exposed perpendicular junctions while preserving literal doorway widths.
- [ ] Move A-east/B-west openings north, give their walls sole ownership, extend the shared junction, elongate A to the north-west, and move Medical north without any floor/ceiling overlap.
- [ ] Replace the Kitchen zigzag with the B-east east leg followed by the north leg; close the former missing spans and retain the service-room boundary.
- [ ] Regenerate and run the geometry suite. Diagnose any failure before another structural change.

## Task 3: Correct southern Storage, Workshop, and Salvager

**Files:** same builder and generated scene.

- [ ] Keep C north at `Z=5.5`, move D/E south, broaden the spine, delete `GalleryCDividerSouth`, and make `GalleryCIrregularSouthMass` the southern separator.
- [ ] Give Gallery E a 5.6 m southern projection within a 14.0 m final length (40%) while retaining one entry and no Deeper bypass.
- [ ] Extend Workshop approach to 10 m and translate the room/spur coherently.
- [ ] Delete the continuation floor, ceiling, side/rear walls, blocker, debris, anchor, and topology edge. Author one continuous Workshop south wall.
- [ ] Move the Salvager assembly toward the revised approach, reduce rear clearance to about 1.35 m, and preserve restricted side/rear access.
- [ ] Regenerate and run geometry RED/GREEN checks after each dependency group.

## Task 4: Correct western core and eastern approach

**Files:** same builder and generated scene.

- [ ] Shorten Receiving east-west without touching the freight cage; frame Dispatch as an outside 9.5 x 3.5 m annex with one doorless opening.
- [ ] Narrow Receiving/Backlog to 3.84 m and place the height strip wholly on the Receiving side of the ceiling seam.
- [ ] Move the Backlog/Sorting boundary west to `X=-21`, keep its north opening edge at `Z=-2.4`, and extend only the south return to `Z=1.44`. Confirm the exact Sorting-eye ray reaches the freight barrier through both openings.
- [ ] Redistribute Deeper to 16 m pre-bend and 16 m post-bend authored runs; move Ops/door east as one terminal assembly and retain Incinerator separation.
- [ ] Regenerate; run the geometry suite to GREEN.
- [ ] Commit structural source, saved scene, and tests as `fix: correct logistics wing round-two geometry`.

## Task 5: Synchronize controller traversal and review evidence

**Files:**
- Modify `greybox/logistics_wing/wing_capture.gd`
- Modify `greybox/logistics_wing/wing_traversal.gd`
- Modify `greybox/logistics_wing/wing_review.tscn`
- Modify the three wing test suites as required by real behavior
- Generate only `reports/logistics_wing/greybox/revision_02/*`

- [ ] Retarget every affected route, boundary probe, label, light, camera, and anchor. Add Dispatch traversal and replace the stub route/probe with Workshop south-wall collision evidence.
- [ ] Add ceiling approach/threshold/departure frames, Backlog/Sorting turn frames, the Sorting desk-to-lift proof, whole-wing views, and an honest Salvager reveal from the Workshop-room approach.
- [ ] Extend the capture manifest with source revision, evidence revision, scene/script hashes, renderer, dimensions, camera positions/targets/FOV, and the final-commit relationship field. If evidence precedes the final documentation commit, state that relation explicitly rather than implying identical hashes.
- [ ] Run capture and traversal contracts to GREEN, generate evidence, and inspect every full-resolution image and contact sheet. Any reproduced structural defect gets a failing contract before a builder change.
- [ ] Commit coordinated evidence tooling as `test: coordinate round-two wing evidence`.

## Task 6: Whole-wing verification and handoff

**Files:**
- Create `docs/testing/logistics-wing-greybox-round02-revision-validation.md`

- [ ] Rebuild deterministically and run all three focused suites.
- [ ] Run the editor/parser scan, review-scene smoke, unchanged default-main smoke, and every existing non-hanging `tools/asset_pipeline/tests/*_tests.gd` script. Bound the known hanging integration script and compare diagnostics with the documented baseline.
- [ ] Verify changed `.gd`/`.tscn` source outside the engine where applicable, diff protected files, confirm the rejected branch, and verify evidence exists only in `revision_02` without cleaning any prior report.
- [ ] Record every R02 item with disposition, geometry/measurement, runtime/evidence, and remaining human question. Record exact branch/start/source/evidence/final revisions, hashes, renderer, test commands/results, route timings, Deeper ratio, C/D comparison, self-inspection/rework, and known baseline diagnostics.
- [ ] Run documentation-sensitive focused checks and `git diff --check`, then commit as `docs: validate logistics wing round-two revision`.
- [ ] Stop on the local branch for human review. Do not merge, push, furnish, add art, implement physical Receiving, or promote the workflow.
