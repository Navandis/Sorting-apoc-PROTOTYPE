# Logistics Wing Greybox — Round-Two Revision Validation

**Date:** 16 September 2026

**Branch:** `codex/logistics-wing-greybox`

**Verified round-one final / revision start:** `add47716a125f3fc035e10d50fdb11a15836659b`

**Main/origin base preserved:** `8ee62bd3bc4f23918717517e066d4c6a8cb565df`

**Source and evidence revision:** `13f45122eaf141cf579fcb35131601181b99ee9e`

**Rejected Receiving branch preserved:** `c9752c8c68cd55b950dd588542ea271e1acc0aab`

**Engine:** Godot `4.7.stable.official.5b4e0cb0f`, Jolt, GL Compatibility

**Evidence renderer:** OpenGL 3.3 Compatibility, NVIDIA GeForce RTX 5060 Ti

## Outcome

The bounded round-two structural correction is technically complete on the existing local wing branch. The whole saved wing, builder, review scene, capture manifest, traversal replay, and three focused contracts are synchronized. R02-02 through R02-18 have direct geometry, collision, route, and/or rendered evidence. R02-01 remains explicitly deferred: the freight cage and its side recesses were preserved without lining or interior redesign.

The Workshop abandoned-continuation stub is gone at every active layer. There is no remaining floor, ceiling, side/rear pocket, blocker, debris, anchor, topology edge, route, probe, label, light, capture, or reserved aperture. Workshop ends at one continuous full-height south perimeter while its service-room size, inner boundary, and Salvager connection remain usable.

This report establishes technical integrity and correction-register fidelity only. Human spatial promotion is still pending. Freight lining, furnishing, production art, physical Receiving, facility interactions, delivery choreography, NPCs, and integrated balance remain deferred.

The final handoff commit is expected to be a documentation-only descendant of the source/evidence revision above. Its exact SHA is reported in the final task response because a Git commit cannot embed its own hash.

## Review launch

```powershell
& 'D:\AI Tools\Godot-4.7-Codex\Godot_v4.7-stable_win64.exe' --path 'D:\Godot Projects\Sorting-apoc-PROTOTYPE' 'res://greybox/logistics_wing/wing_review.tscn'
```

The review scene starts on the Receiving apron and retains the unchanged project controller: `WASD`, mouse-look, `Shift` sprint, and `Esc` mouse release. Walk speed is `4.0 m/s`, sprint multiplier `2.0`, capsule radius/height `0.34/1.75 m`, eye height `1.7162851 m`, and FOV `75°`.

## Correction register

`PASS` means the requested authored correction and its listed technical evidence passed. It does not mean human spatial approval. `DEFER` is the requested disposition for R02-01, not a failure.

| ID | Status | Result and current evidence |
| --- | --- | --- |
| R02-01 | DEFER | Freight enclosure remains `5.0 × 7.0 m` at `X -44..-39`, `Z -3.5..3.5`; barrier, recesses, scale, and inaccessible status are unchanged. No lining was added. Later loot occlusion behind aperture flanks and lining-volume loss remain human/production risks. |
| R02-02 | PASS | Dispatch is a shallow external `9.5 × 3.5 m` annex at `X -38..-28.5`, `Z -8.5..-5`, with a framed `2.4 m` doorless opening and substantial long-side returns. Receiving apron is reduced to `10.5 × 10.0 m` at `X -39..-28.5`, `Z -5..5` without changing the freight assembly. `dispatch_annex.png`, `receiving_apron.png`; `receiving_to_dispatch` replay. |
| R02-03 | PASS | The height strip is wholly on the Receiving side at `X -28.80..-28.50`, `Y 3.40..4.20`, `Z -1.92..1.92`. Saved-scene tests prove no positive-volume overlap with the Backlog ceiling. Three sequential ceiling views show the approach, threshold, and departure without banding, flicker, or a black void. |
| R02-04 | PASS | Receiving→Backlog opening narrows from `4.80 m` to `3.84 m`; on the `10.0 m` Receiving frontage the north and south returns are each `3.08 m`. Normal-controller core routes continue to cross it. |
| R02-05 | PASS | Backlog→Sorting opening is `3.84 m`, `Z -2.40..1.44`. The north return remains `1.40 m`; only the south return grows, to `2.36 m`. The real Sorting work eye at `(-10, 1.7162851, -4.4)` has a clear ray through both thresholds that terminates on the freight barrier's upper rail. Named geometry checks separately prove the lift-to-Deeper vista is blocked by `ReceivingEastSouth` and Storage-to-Ops by `DeeperWideNorth`. `sorting_desk_freight_aperture.png` plus the three Backlog/Sorting turn views. |
| R02-06 | PASS | Perpendicular corners follow one joined-end convention while doorway ends remain literal. Representative solid-corner probes pass, all required openings remain clear, the generic collinear-wall audit reports zero duplicate runs, and a whole-wing audit reports zero positive-area floor or ceiling overlaps. All 33 views were inspected at full resolution during correction; the final contact sheets and affected full-resolution views were re-inspected after the last slab partition. |
| R02-07 | PASS | Every listed stub node and active dependency is absent. Workshop has a continuous joined south wall at `Z=25`, functional span `X -18..-6`; the current south-wall probe blocks at `Z=24.509`. Workshop and Salvager replays pass. `workshop_service.png` shows an ordinary opaque perimeter, not a sealed pocket or reserved frame. |
| R02-08 | PASS | Sorting→Workshop approach grows from `8 m` to `10 m`, `Z 5..15`. The downstream room translates without stretching and remains `12 × 10 m`, `X -18..-6`, `Z 15..25`. Sorting→Workshop measures `23.118 m / 5.900 s`. |
| R02-09 | PASS | Salvager machine center moves `0.5 m` toward the revised approach to `Z=26.5`; front face is `Z=25.0`, rear face `Z=28.0`, and rear-wall inside face `Z=29.35`, reducing rear clearance from about `1.85 m` to `1.35 m`. Pocket floor, ceiling, side walls, and rear wall move coherently. The machine is visible from the Workshop-room approach at `(-8, 1.7162851, 20.5)` before entering the spur; the retained local view remains separate. |
| R02-10 | PASS | `GalleryCDividerSouth` is removed. The full-height irregular mass at `X 2..6`, `Z 11.5..15` performs southern separation. The sole C↔D opening remains `2.5 m`, `X=6`, `Z 9.0..11.5`; direct and spine-alternative routes use identical endpoints. |
| R02-11 | PASS | C's accepted north edge stays at `Z=5.5`; D and E move south to `Z=7.0`. Authored spine breadth is `7.0 m` west and `8.5 m` centre/east (nominal wall-face clear widths `6.7 m` and `8.2 m`). D/E room depths and southern features remain intact, all five gallery routes pass, and the Deeper threshold remains open. |
| R02-12 | PASS | Gallery E runs from `Z=7.0` to `21.0`; its projection is `Z 15.4..21.0`. The consistent face-coordinate ratio is `5.6 / 14.0 = 40%`. E remains single-entry with no Deeper bypass. |
| R02-13 | PASS | A-east and B-west openings move north to `Z -9.4..-7.0`, each `2.4 m` clear. A owns `X=4.5`, B owns `X=9`, and Medical side walls start only beyond the galleries at `Z=-13`; no 0.6–0.7 m parallel skins or direct A↔B shortcut remain. Both normal-controller entry routes pass. |
| R02-14 | PASS | Gallery A and Medical have distinct, non-overlapping floor/ceiling interiors; the whole-wing slab audit covers this generically. A's shelf envelope remains inside A, and Medical walls do not cross the gallery. |
| R02-15 | PASS | Gallery A keeps its main room at `X -3..4.5`, `Z -13..-1.5` and gains the requested north-west extension at `X -5..1`, `Z -16..-13`. Floor, roof, walls, and shelf envelope follow the same restrained outline. |
| R02-16 | PASS | Medical corridor is a distinct `2.4 × 3.0 m` protected spur at `X 5.8..8.2`, `Z -16..-13`, beyond the shared A/B junction. The retained `7.8 × 7.0 m` anteroom moves north to `X 3..10.8`, `Z -23..-16`, remains separate from A/B, and preserves its opaque inner boundary. Junction→Medical measures `10.922 m / 2.850 s`. |
| R02-17 | PASS | Kitchen now leaves B east through `X 16.5..24`, `Z -8.2..-5.4`, then turns north through `X 21.2..24`, `Z -18..-8.2`, into the retained `10.5 × 7.0 m` service room. Outer floor, ceiling, and collision perimeter are closed; there is no redundant internal turn wall, Storage-spine bypass, Medical shortcut, or exterior gap. |
| R02-18 | PASS | Authored pre-/post-bend runs change from about `9/22 m` to `16/16 m`, ratio `1.0`, while widths, Incinerator separation, and long-axis interruption remain. Sorting→Bunker Ops measures `87.435 m / 22.133 s`; Deeper/Incinerator-front→Ops landing `45.538 m / 11.767 s`; Sorting→deeper closure `87.836 m / 22.200 s`. |

## Revised authored dimensions

Coordinates use `+X east`, `+Z south`, and `Y=0` finished floor. Ordinary clear height is `3.40 m`, Receiving height `4.20 m`, and wall/slab thickness `0.30 m`.

| Area | Round-two authored decision |
| --- | --- |
| Freight enclosure | Unchanged `X -44..-39`, `Z -3.5..3.5`; no lining or physical Receiving. |
| Receiving apron | `X -39..-28.5`, `Z -5..5` (`10.5 × 10.0 m`). |
| Dispatch | `X -38..-28.5`, `Z -8.5..-5` (`9.5 × 3.5 m`); opening `X -34.2..-31.8`. |
| Backlog | `X -28.5..-21`, `Z -3.8..3.8`; west opening `3.84 m`, east opening `3.84 m` with asymmetric returns. |
| Sorting | `X -21..-5`, `Z -5..5`; work pocket `X -14..-6`, `Z -7.2..-5`; work eye `(-10, 1.7162851, -4.4)`. |
| Storage spine | West `X -5..4.5`, `Z -1.5..5.5`; east `X 4.5..26`, `Z -1.5..7`. |
| Shared A/B junction | `X 4.5..9`, `Z -13..-1.5`; A/B openings `Z -9.4..-7`. |
| Gallery A | Main `X -3..4.5`, `Z -13..-1.5`; north-west extension `X -5..1`, `Z -16..-13`. |
| Gallery B | Main `X 9..16.5`, `Z -13..-1.5`; retained north-east bump `X 12..16.5`, `Z -14.5..-13`. |
| Medical | Corridor `X 5.8..8.2`, `Z -16..-13`; anteroom `X 3..10.8`, `Z -23..-16`. |
| Kitchen | East leg `X 16.5..24`, `Z -8.2..-5.4`; north leg `X 21.2..24`, `Z -18..-8.2`; room `X 19..29.5`, `Z -25..-18`. |
| Gallery C | Functional main union `X -2..6`, `Z 5.5..11.5`; south-west floor `X -2..2`, `Z 11.5..15`; irregular solid `X 2..6`, `Z 11.5..15`. |
| Gallery D | `X 6..15.5`, `Z 7..17.5`; bump `X 9.5..12.5`, `Z 17.5..19`. |
| Gallery E | Main `X 17.5..25.5`, `Z 7..15.4`; projection `X 19..25.5`, `Z 15.4..21`. |
| Workshop | Approach `X -12..-8`, `Z 5..15`; room `X -18..-6`, `Z 15..25`; no continuation volume south of the room. |
| Salvager | Functional cross-leg union `X -6..8`, `Z 20..24`; pocket `X 2..8`, `Z 23.5..29.5`; machine center `Z=26.5`. |
| Deeper | Functional wide run `X 26..42`, `Z 0..4.5`; dogleg union `X 39..43`, `Z -7..4.5`; narrow run `X 43..59`, `Z -7..-4`. |
| Incinerator | Retained narrowed pocket `X 28..35`, `Z 10..17` with ordinary corridor buffer. |
| Bunker Ops | `X 59..66`, `Z -11..-2`; landing and personnel door move east together by `1 m`. |

Functional unions at Gallery C, Salvager, and the Deeper bend are tessellated into non-overlapping primitives. The saved-scene audit compares every `Floor_*` pair and every `Ceiling_*` pair and reports zero positive-area overlaps.

## Controller-driven route evidence

The unchanged controller consumed injected physical `W` input at 60 Hz without sprint. Each route resets to its named start anchor; no teleport occurs within a measured route. Yaw follows authored waypoints, arrival tolerance is `0.45 m`, and all endpoint errors are `0.318–0.380 m`.

| Route | Start → end anchor | Walk | Time | End error |
| --- | --- | ---: | ---: | ---: |
| Receiving→Sorting | ReceivingApron → SortingWork | 24.496 m | 6.317 s | 0.330 m |
| Receiving→Dispatch | ReceivingApron → Dispatch | 6.322 m | 1.700 s | 0.362 m |
| Receiving→near Storage | ReceivingApron → StorageNear | 31.176 m | 7.917 s | 0.380 m |
| Sorting→shared A/B junction | SortingWork → SharedABJunction | 31.430 m | 8.033 s | 0.330 m |
| Junction→A east | SharedABJunction → GalleryA | 6.633 m | 1.783 s | 0.323 m |
| Junction→B west | SharedABJunction → GalleryB | 6.958 m | 1.867 s | 0.362 m |
| Junction→Medical | SharedABJunction → MedicalAnteroom | 10.922 m | 2.850 s | 0.321 m |
| B east→Kitchen | GalleryB → KitchenService | 25.159 m | 6.433 s | 0.325 m |
| Sorting→Workshop | SortingWork → WorkshopService | 23.118 m | 5.900 s | 0.346 m |
| Sorting→Salvager | SortingWork → SalvagerFront | 39.450 m | 10.050 s | 0.334 m |
| Sorting→Incinerator | SortingWork → IncineratorFront | 55.884 m | 14.150 s | 0.323 m |
| Sorting→Bunker Ops | SortingWork → BunkerOpsSafeSide | 87.435 m | 22.133 s | 0.369 m |
| Deeper→Ops landing | IncineratorFront → BunkerOpsLanding | 45.538 m | 11.767 s | 0.323 m |
| Sorting→deeper closure | SortingWork → DeeperClosureSafeSide | 87.836 m | 22.200 s | 0.355 m |
| C→D secondary | GalleryC → GalleryD | 8.593 m | 2.233 s | 0.374 m |
| C→D via spine | GalleryC → GalleryD | 18.254 m | 4.767 s | 0.345 m |
| Storage→A | StorageNear → GalleryA | 13.253 m | 3.500 s | 0.366 m |
| Storage→B | StorageNear → GalleryB | 23.405 m | 6.033 s | 0.349 m |
| Storage→C | StorageNear → GalleryC | 8.463 m | 2.267 s | 0.318 m |
| Storage→D | StorageNear → GalleryD | 17.450 m | 4.517 s | 0.322 m |
| Storage→E | StorageNear → GalleryE | 29.441 m | 7.517 s | 0.330 m |

The C↔D comparison uses identical `GalleryC` and `GalleryD` endpoints. The secondary route is `8.593 m / 2.233 s`; the spine alternative is `18.254 m / 4.767 s`. These are observations, not balance approval.

### Sustained-input boundary checks

| Boundary | Final blocking coordinate | Displacement | Result |
| --- | ---: | ---: | --- |
| Freight barrier | `X=-38.497` | 1.497 m | PASS |
| Medical inner boundary | `Z=-22.508` | 1.508 m | PASS |
| Kitchen inner boundary | `Z=-24.508` | 2.508 m | PASS |
| Workshop inner boundary | `X=-17.509` | 2.009 m | PASS |
| Workshop south wall | `Z=24.509` | 1.009 m | PASS |
| Bunker Ops inner boundary | `Z=-10.509` | 2.009 m | PASS |
| Deeper-settlement door | `X=65.334` | 0.834 m | PASS |
| Kitchen turn return | `X=21.692` | 0.708 m | PASS |
| Dogleg return | `X=42.508` | 0.508 m | PASS |
| Shared-junction return | `Z=-12.508` | 0.708 m | PASS |

Final replay result: **21/21 routes, 10/10 boundaries, 0 failures**. The machine-readable record is `reports/logistics_wing/greybox/revision_02/traversal_results.json`.

## Visual evidence and hashes

All new evidence is intentionally untracked below `reports/logistics_wing/greybox/revision_02/`. Historical report directories were preserved; no parent cleanup was run. The capture set contains 33 views and three contact sheets, all `1920 × 1080`. Normal views use `1.7162851 m` eye height, `75°` FOV, and visible ceilings; only the debug overview hides the roof.

| Source | SHA-256 recorded in manifest |
| --- | --- |
| `build_wing_geometry.gd` | `bd9e90b5e5e14f996b75b237082890b489b759b4813bdba9cceeca56227164ea` |
| `wing_geometry.tscn` | `f4f451649100bf9553ce04daabd8a983a766ccbee30bd515f4810c1123fe7a55` |
| `wing_capture.gd` | `2704e773e7e8a86a2010f33ff198eb3c8ea37eb7d620b44151aca10159c989a7` |
| `wing_review.tscn` | `98891f3a922af8458c19652374b18a90f33367b01a40b6c81c02ba5d7962ea44` |
| `wing_traversal.gd` | `2716e7a617c879f32ba38d2edfb5712c49768a5cae7c6146b3400c509cbe41fd` |

All five hashes were recomputed after capture and match the manifest. All 33 named files exist; all 36 PNGs have the expected dimensions. The source, evidence, and manifest code revision are all `13f45122eaf141cf579fcb35131601181b99ee9e`.

Primary human-review entry points are `overview_debug_topdown.png`, `contact_sheet_01.png`, `contact_sheet_02.png`, and `contact_sheet_03.png`. Full-resolution checks additionally covered the affected Storage, Salvager, Deeper, Sorting/freight, Workshop, and ceiling-transition views after the final slab partition.

## Verification record

| Check | Result |
| --- | --- |
| Deterministic geometry rebuild | PASS — `110×55 m`, 960 nodes; generated scene had `0` non-`unique_id` changed lines, then node IDs were normalized back to the committed scene. |
| `logistics_wing_geometry_tests.gd` | PASS — includes whole-wing slab ownership and named sightline blockers. |
| `logistics_wing_capture_tests.gd` | PASS. |
| `logistics_wing_traversal_tests.gd` | PASS. |
| Capture runtime | PASS — 33 views, 3 sheets, `gl_compatibility`. |
| Traversal runtime | PASS — 21 routes, 10 boundaries, 0 failures. |
| Editor/parser scan | PASS; Windows root-certificate diagnostic only. |
| Independent review-scene smoke | PASS. |
| Original default-main smoke | PASS; default scene unchanged, 31 trimesh meshes, 9 convex meshes, 87 world items registered. |
| Existing non-hanging regression scripts | PASS — 33/33 exited 0 with exactly one PASS line each. |
| Bounded legacy integration audit | Baseline reproduced — after 25 seconds: exactly two `_assert_summary` assertions at line 179 and one `_init` assertion at line 95; no fourth assertion. |
| Protected-file diff from `8ee62bd3` | PASS — no changes. |
| Round-two `git diff --check` from `add47716` | PASS. |
| Round-one final ancestry | PASS — `add47716` is an ancestor of source/evidence revision. |
| Rejected Receiving branch | PASS — still resolves to `c9752c8...` and is not an ancestor. |
| Workshop-stub runtime-source search | PASS — zero matches across `greybox/logistics_wing`. |
| Physical Receiving instance search | PASS — no `res://receiving/freight_bay_prototype.tscn` instance in the wing. |

The 33 passing scripts were `authoring_review_manifest`, `auto_stack_group_registry`, `environment_asset_relocation`, `footprint_review_content`, `item_catalog_coverage`, `item_catalog_initial_seed`, `item_catalog`, `item_definition_seeder`, `item_interaction_reviewability`, all three `logistics_wing` suites, `loot_audit_core`, `main_scene_pickup_registration`, all seven `receiving_*` suites, `stack_role_authoring`, `stack_role_batch`, all nine `storage_*` suites, and `support_stacking_metadata`.

The full-branch `git diff --check 8ee62bd3...` still reports the same four inherited first-pass formatting diagnostics: two trailing-space lines and a final blank line in `docs/superpowers/specs/2026-09-15-logistics-wing-greybox-design.md`, plus a final blank line in `greybox/logistics_wing/wing_capture.tscn`. Neither historical file was changed in round two. The round-two-only diff check passes.

Godot repeatedly emitted `Failed to read the root certificate store` on this Windows host while all relevant commands exited successfully. The greybox does not use network features.

## Preservation and scope

Protected files are byte-diff clean from the verified main base: `main.tscn`, `project.godot`, `player_controller.gd`, `camera_movement.gd`, `data/`, and `tools/asset_pipeline/item_authoring_review.json`.

Round-two source changes before this validation report are limited to:

- `docs/superpowers/plans/2026-09-16-logistics-wing-greybox-round02-revision.md`
- `docs/superpowers/specs/2026-09-16-logistics-wing-greybox-round02-design.md`
- `greybox/logistics_wing/build_wing_geometry.gd`
- `greybox/logistics_wing/wing_capture.gd`
- `greybox/logistics_wing/wing_geometry.tscn`
- `greybox/logistics_wing/wing_review.tscn`
- `greybox/logistics_wing/wing_traversal.gd`
- the three existing `tools/asset_pipeline/tests/logistics_wing_*_tests.gd` suites

Existing untracked reports under `reports/logistics_wing/` and `reports/receiving/` were preserved. No stash was created. Nothing was merged or pushed.

## Self-inspection and correction cycle

- The three focused suites first failed against `add47716` with 41 geometry, 23 capture, and 5 traversal assertions, establishing the round-two contract before implementation.
- After the first coordinated implementation, full-resolution review corrected three weak evidence poses: the honest Workshop-approach Salvager reveal, the Kitchen north turn, and the Workshop south perimeter view.
- Whole-wing visual review then found a Storage→Deeper exterior seam. A failing exact wall-box assertion was added before extending `SpineEastSouthReturn`; the affected evidence was regenerated and inspected.
- Independent code review found three concealed floor/ceiling overlaps: Storage/C (`1.5 × 1.5 m`), Salvager cross-leg/pocket (`6.0 × 0.5 m`), and Deeper wide/dogleg (`3.0 × 4.5 m`). A generic all-pairs slab test reproduced all six floor/ceiling failures before the functional unions were tessellated. The revised saved scene has zero positive-area slab overlaps without changing approved outlines or route results.
- The same review prompted exact sightline coverage: the Sorting ray now terminates on named freight-barrier geometry, and the two required interrupted long vistas assert their named structural blockers.
- The final deterministic rebuild produced no semantic scene difference. The refreshed traversal replay, 33 views, contact sheets, focused suites, smokes, and 33-script regression set all passed afterward.

## Status separation and human questions

| Status category | Status | Meaning |
| --- | --- | --- |
| Technical checks | PASS | Focused suites, 33 regressions, parser/smokes, renderer, controller routes, boundary probes, hashes, and saved-scene ownership audits passed. |
| Correction-register fidelity | PASS with R02-01 deferred as directed | R02-02–18 are implemented; freight cage local geometry is intentionally unchanged. |
| Human spatial promotion | PENDING | Requires the developer's normal-controller walkthrough for feel, legibility, scale, and landmarking. |
| Workflow feasibility | DEFERRED | No delivery choreography or live departmental workflow was authorized or tested. |
| Production art / furnishing | DEFERRED | Neutral geometry and existing proxy masses only. |
| Freight lining / physical Receiving | DEFERRED | No lining, loot piles, live arrivals, or rejected Receiving implementation was added. |
| Integrated balance | DEFERRED | Route timings are measurements, not tuning approval. |

Human review should answer:

1. Does the shallower Receiving/Dispatch relationship still leave a comfortable apron while making Dispatch read as an external annex?
2. From the actual Sorting work position, is the partial freight-aperture awareness useful without reopening the two long vistas?
3. Do the broader Storage spine, single C↔D connection, 40% E projection, and north-shifted A/B/Medical group read clearly at walking speed?
4. Does Workshop now end unambiguously at a normal solid perimeter, and does the lengthened approach reveal Salvager early enough without making the spur feel exposed?
5. Do the simplified Kitchen route and balanced Deeper dogleg feel proportionate before furnishing, art, workflow, or physical Receiving begins?

Stop after human review. Do not merge, push, furnish, add art, implement physical Receiving, or promote the workflow automatically.
