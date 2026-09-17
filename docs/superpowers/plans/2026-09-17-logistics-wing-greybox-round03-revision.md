# Logistics-Wing Greybox Round-03 Revision Plan

> Execute this plan on `codex/logistics-wing-greybox` from verified baseline `66b7c18f54c45c6b682970b1971dd2bc6e5f099a`. Preserve all existing user reports and unrelated work. Do not merge or push.

**Goal:** Apply R03-01–R03-08 to the complete saved wing, update all three focused contracts, produce revision-03 runtime/rendered evidence and an auditable human-review bundle.

**Architecture:** `greybox/logistics_wing/build_wing_geometry.gd` remains the one coordinate source. The generated `wing_geometry.tscn`, capture manifest, traversal replay, review scene, and focused tests must all describe the same coordinates. Endpoint finishing is local through/butt geometry, not a new wall-graph framework.

**Engine:** `D:\AI Tools\Godot-4.7-Codex\Godot_v4.7-stable_win64_console.exe`

## Task 1 — Establish the round-three red contract

**Modify:**

- `tools/asset_pipeline/tests/logistics_wing_geometry_tests.gd`
- `tools/asset_pipeline/tests/logistics_wing_capture_tests.gd`
- `tools/asset_pipeline/tests/logistics_wing_traversal_tests.gd`

Add saved-scene assertions for the round-three revision, exact affected boxes/openings, floor-plan extents, Storage classification, Medical/Kitchen ratios, folded C/D chain, old Incinerator-mouth closure, three-ray freight bundle, and unchanged neighbouring geometry. Add a generic perpendicular-endpoint audit that samples all four wall-thickness quadrants at every true wall-to-wall endpoint join. Preserve explicit absent-stub and protected-route assertions.

Update capture expectations for revision-03 output and affected/additional views. Update traversal expectations for revision-03 output, moved waypoints, and the former Incinerator mouth boundary.

Run each focused suite against the untouched round-two scene and record the expected failures:

```powershell
& 'D:\AI Tools\Godot-4.7-Codex\Godot_v4.7-stable_win64_console.exe' --headless --path . --script res://tools/asset_pipeline/tests/logistics_wing_geometry_tests.gd
& 'D:\AI Tools\Godot-4.7-Codex\Godot_v4.7-stable_win64_console.exe' --headless --path . --script res://tools/asset_pipeline/tests/logistics_wing_capture_tests.gd
& 'D:\AI Tools\Godot-4.7-Codex\Godot_v4.7-stable_win64_console.exe' --headless --path . --script res://tools/asset_pipeline/tests/logistics_wing_traversal_tests.gd
```

Expected: each fails only for new round-three behavior, not parser/runtime instability.

## Task 2 — Correct Receiving, Backlog, and Sorting

**Modify:**

- `greybox/logistics_wing/build_wing_geometry.gd`
- `greybox/logistics_wing/wing_capture.gd`
- `greybox/logistics_wing/wing_traversal.gd`
- `greybox/logistics_wing/wing_review.tscn`

Align the closure at `X=-28.5`; decouple Backlog floor and ceiling west bounds so the lower ceiling starts at `-28.35`. Restore the partition to `X=-15`, Backlog/Sorting spans to `13.5/10`, and opening to `Z -3.4..1.44`. Update ownership, labels, routes, captures, and endpoint joins. Verify the three freight rays and both blocked long vistas.

Regenerate and run the geometry suite. Inspect the roof-off overview plus both threshold sides before continuing.

## Task 3 — Correct Salvager and C/D

**Modify:** the same builder/capture/traversal sources as needed.

Set Salvager pocket back to `Z=28.5`, pocket-west nominal start to `24.0`, and retained machine clearance to `0.35`. Replace the C cube with the folded wall chain through `(2,15)`, `(2,11.5)`, `(6,11.5)`, and `(6,17.5)`. Keep the sole `Z 9..11.5` C/D aperture and both route alternatives.

Regenerate, rerun geometry/traversal tests, and inspect Salvager elbow/rear plus C- and D-side views.

## Task 4 — Correct Storage classification, Medical, and Kitchen

**Modify:** builder, review scene, capture, and traversal sources.

Give the Shared A/B connector the Storage floor material and Main Storage metadata/label. Extend Medical's exclusive corridor to `5 m`, translate its room and dependents two metres north, and preserve the `7.8 x 7 m` room. Move the Kitchen turn centre to `X=25.0`, translate the north leg/room/dependents `+2.4 X`, and preserve corridor/room sizes and B-east-only topology.

Regenerate, rerun all focused tests, and inspect Storage→Medical and B-east→Kitchen sequences.

## Task 5 — Move Incinerator and complete every wall join

**Modify:** builder, capture, traversal, and review scene.

Translate the complete Incinerator spur `+5 X`, close the old mouth, and add a controller boundary probe there. Apply endpoint-specific joins to every actual incomplete perpendicular junction in all districts. Do not extend intentional jambs or add blanket corner pillars.

Run the generic junction test and inspect any reported coordinates. Iterate until every true join covers all four samples, all doorway samples remain clear, no collinear duplicate walls exist, and every slab ownership check remains clean.

## Task 6 — Regenerate and verify the synchronized sources

Run:

```powershell
& 'D:\AI Tools\Godot-4.7-Codex\Godot_v4.7-stable_win64_console.exe' --headless --path . --script res://greybox/logistics_wing/build_wing_geometry.gd
& 'D:\AI Tools\Godot-4.7-Codex\Godot_v4.7-stable_win64_console.exe' --headless --path . --script res://tools/asset_pipeline/tests/logistics_wing_geometry_tests.gd
& 'D:\AI Tools\Godot-4.7-Codex\Godot_v4.7-stable_win64_console.exe' --headless --path . --script res://tools/asset_pipeline/tests/logistics_wing_capture_tests.gd
& 'D:\AI Tools\Godot-4.7-Codex\Godot_v4.7-stable_win64_console.exe' --headless --path . --script res://tools/asset_pipeline/tests/logistics_wing_traversal_tests.gd
```

Then perform a second deterministic rebuild and compare the generated scene semantically. If only generated UIDs churn, normalize exactly as established in the round-two validation and document it; do not hand-edit geometry into the scene.

## Task 7 — Generate revision-03 evidence

**Write only below:** `reports/logistics_wing/greybox/revision_03/`

Run the capture and traversal scenes with explicit flags. Produce full-resolution views, aspect-preserving contact sheets, manifest/source hashes, traversal/boundary JSON, measurements, and a junction inventory. Inspect every affected full-resolution view, not only sheets. Include the five supplied defect images and red overlay by reference in the validation, not by copying them into generated evidence.

## Task 8 — Full regression and preservation audit

Run the repository's applicable non-hanging test set, default-main smoke, review/capture/traversal parser smokes, bounded legacy integration audit, `git diff --check`, protected-file comparison from `8ee62bd3`, ancestry checks, stub-source search, and physical-Receiving-instance search. Reproduce inherited baseline exceptions rather than concealing them.

## Task 9 — Review, validation, and bundle

**Create/update:**

- `docs/testing/logistics-wing-greybox-round03-revision-validation.md`
- revision-03 evidence inventory and review ZIP

Write an eight-row correction record with outcome, exact measurement, test evidence, rendered/runtime references, retained-neighbour checks, and remaining human question. Separate automated checks, observed geometry, correction fidelity, human spatial approval, human–Codex workflow feasibility, revision reliability, and deferred systems.

Bundle only the current `greybox/logistics_wing/`, all three updated focused test sources, round-three spec/plan/validation, and revision-03 evidence/inventory. Exclude `assets/`, `.godot/`, the full project, sibling reports, and historical evidence directories.

Request an independent read-only code review of the final change range. Resolve substantive findings with a new failing test where applicable, rerun fresh verification, commit locally according to project practice, and stop for human review. Do not merge or push.
