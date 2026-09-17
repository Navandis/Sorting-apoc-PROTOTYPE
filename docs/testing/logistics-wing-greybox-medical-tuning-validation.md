# Logistics wing Medical tuning validation

**Date:** 17 September 2026
**Branch:** `codex/logistics-wing-greybox`
**Round-three baseline:** `f2fb9b090b39ac6cfdc136ab68e1269c3c4a204a`
**Source and evidence checkpoint:** `aeb1ef27671f2f07d651e5064b00c3c77a06600b`
**Layout:** `logistics-wing-greybox-medical-tuning-revision-04`
**Evidence:** `reports/logistics_wing/greybox/revision_04/`

## Outcome

The two requested Medical-only tuning changes are implemented in the complete
wing:

1. The exclusive Medical corridor retains X `5.8..8.2` and grows from Z
   `-18..-13` (5.0 m) to Z `-23..-13` (10.0 m).
2. The unchanged `7.8 × 7.0 × 3.4 m` Medical anteroom translates `2.6 m` west
   and `5.0 m` north to X `0.4..8.2`, Z `-30..-23`. Its east wall is now
   collinear with the corridor east wall at X `8.2`; the entrance is at the
   south-east and the obsolete south-east shoulder is absent.

Wall-face measurements remain approximately `2.1 m` clear corridor width and
`7.5 × 6.7 m` clear room plan. The opaque staffed-core boundary, provisional
interface and two Medical anchors moved with the room. The corridor did not
move sideways, and the shared A/B connector remains Main Storage.

This is technical completion only. Human spatial judgment on the tuned
Medical arrangement is pending the developer's localized walkthrough.

## Test-first correction record

The three focused suites were updated before production geometry. Against the
round-three scene, the new specification produced 19 geometry, 17 capture and
6 traversal failures. The implementation then made all three suites pass.

Independent review subsequently found three evidence weaknesses: the initial
vertical plan framing, absence of a return replay, and stale junction-baseline
metadata. Tests were strengthened and all three were corrected. A final review
found that the first east-wall camera crossed the solid west shoulder; a new
sightline assertion failed three checks before the camera was moved beside the
east wall. The final ray crosses the room threshold at X `6.94`, inside the
clear entrance X `5.95..8.05`. The regenerated image now shows the open
corridor and continuous east wall. The final independent re-review reported
no remaining findings.

## Geometry and preservation evidence

The authoritative builder regenerated `wing_geometry.tscn` with 964 nodes.
Exact saved BoxMesh/BoxShape, anchor, proxy, route and boundary expectations
are exercised by the focused tests; all generated solid boxes retain matching
visual and collision transforms/sizes.

`non_medical_semantic_preservation.json` compares the exact saved round-three
scene (968 nodes) to the current scene. It records node path/class, local
transform, visibility, metadata, box mesh/material, collision shape and static
body settings. After excluding the root metadata and the explicitly allowed
Medical floor/roof/wall/proxy/boundary/anchor paths, it reports **zero
non-Medical differences**. Generated unique identifiers are not treated as
spatial changes.

Protected-file diff from project baseline `8ee62bd3` is empty for
`project.godot`, `main.tscn`, `player_controller.gd`, `carried_items.gd`,
`data/` and the authoring review manifest. The default scene remains
`uid://drbkr86g3cxl1`. `review_player.tscn` and its baseline controller values
remain unchanged: 4.0 m/s walk, 2.0 sprint multiplier, 0.34 m capsule radius,
1.75 m capsule height, 1.7162851 m eye height and 75 degree FOV.

The tracked source range from the round-three final changes only:

- the builder and generated wing scene;
- the Medical label/light in the review scene;
- capture and traversal helpers;
- the three focused test sources.

The Workshop stub remains absent, with only negative regression assertions for
its historical node names. No non-Medical geometry, gameplay/data/authoring
system, shared controller, asset or import state was changed.

## Traversal and junction results

The normal-controller replay uses the unchanged player controller and injected
physical W input. It completed **22/22 routes and 12/12 boundary probes with
zero failures**.

| Medical check | Distance | Duration / final position | Result |
| --- | ---: | ---: | --- |
| Shared A/B junction → anteroom | 18.976 m | 4.883 s | PASS |
| Anteroom → shared A/B junction | 19.002 m | 4.833 s | PASS |
| Staffed-core inner boundary | 1.508 m | final Z `-29.508`, stalled | PASS |

The current junction inventory is derived from the current scene and compared
with the exact pre-task round-three scene. It audits 113 current perpendicular
pairs: 111 already covered, 2 corrected/new, 11 separately verified
intentional openings, 4 retired Medical-baseline pairs and **0 unresolved**.
The historical baseline contains 115 audited pairs; the count was not forced
after the shoulder removal/wall translation.

## Rendered review evidence

The OpenGL Compatibility renderer on the NVIDIA GeForce RTX 5060 Ti produced
38 full views and four aspect-preserving contact sheets. All 42 root PNGs are
`1920 × 1080`. Normal views keep ceilings on, eye height 1.7162851 m and 75
degree FOV. The roof-off Medical plan uses a 50 degree FOV, a non-collinear
north-up vector and an explicit `-Z` north label.

The focused comparison is indexed by
`reports/logistics_wing/greybox/revision_04/comparison_index.md`. Required
current views are:

- `medical_plan_roofoff.png` — complete 17 m combined footprint and north;
- `medical_approach.png` — unchanged Storage-side position and doubled run;
- `medical_entrance.png` — arrival at the south-east entrance;
- `medical_east_wall.png` — room-to-corridor continuous east wall;
- `overview_debug_topdown.png` — complete wing and translated north extent.

All four contact sheets and the focused full-resolution images were visually
inspected after the final camera correction.

## Automated verification

| Check | Result |
| --- | --- |
| Branch / ancestry | PASS — requested branch; `f2fb9b0...` is an ancestor; no reset, clean or stash used. |
| Source-range `git diff --check` | PASS. |
| `logistics_wing_geometry_tests.gd` | PASS. |
| `logistics_wing_capture_tests.gd` | PASS. |
| `logistics_wing_traversal_tests.gd` | PASS. |
| Non-Medical semantic comparison | PASS — 0 differences. |
| Capture runtime | PASS — 38 views, 4 sheets, 42/42 at 1920×1080. |
| Capture manifest hashes | PASS — all eight current source/test SHA-256 values match. |
| Traversal runtime | PASS — 22 routes, 12 boundaries, 0 failures. |
| Junction inventory | PASS — 113 current pairs, 11 openings, 0 unresolved. |
| Independent review-scene smoke | PASS. |
| Original default-main smoke | PASS — 31 trimesh meshes, 9 convex meshes, 87 world items. |
| Established non-hanging regressions | PASS — 33/33 scripts exited 0 with exactly one PASS line each. |
| Bounded legacy integration audit | Baseline reproduced at 25 seconds: two `_assert_summary` assertions at line 179 and one `_init` assertion at line 95; no fourth assertion. |
| Independent read-only review | PASS after fixes; no remaining findings. |

The 33-script regression set intentionally emits its established duplicate-ID,
duplicate-path and `loot_000015` test-stimulus diagnostics while the affected
scripts exit 0 with their PASS line. The separate legacy integration audit is
still the same long-running baseline exception and was terminated after the
bounded 25-second reproduction. Neither is attributed to this Medical change.

Godot also emits `Failed to read the root certificate store` on this Windows
host while the relevant commands exit successfully. The greybox uses no
network feature.

## Evidence identity

`capture_manifest.json`, `traversal_results.json`, `junction_inventory.json`
and `non_medical_semantic_preservation.json` identify source/evidence commit
`aeb1ef27671f2f07d651e5064b00c3c77a06600b`. The capture manifest contains
matching SHA-256 hashes for the five wing sources and three focused test
sources. The final handoff commit is a documentation-only descendant of that
checkpoint; its exact hash is reported with delivery. The evidence is
intentionally untracked under the preserved `reports/` tree.

## Status and stop gate

| Category | Status |
| --- | --- |
| Two Medical tuning targets | IMPLEMENTED AND CHECKED |
| Prior round-three corrections | PRESERVED; reported resolved by developer |
| Human Medical walkthrough / spatial promotion | PENDING |
| Production-workflow assessment | NOT PROMOTED; human judgment pending |
| Freight lining and physical Receiving | DEFERRED |
| Furnishing, art and facility gameplay | DEFERRED |
| Integrated balance | DEFERRED; route timings are measurements only |

Stop for the developer's localized review. Nothing was merged or pushed, and
no abandoned stub, physical Receiving work, furnishing or production art was
added.
