# Logistics Wing Greybox — Round-One Revision Validation

**Date:** 16 September 2026

**Branch:** `codex/logistics-wing-greybox`

**Revision start:** `d81783f00d5debfc44c37346c7acaa074c4e4e82`

**Main/origin base preserved:** `8ee62bd3bc4f23918717517e066d4c6a8cb565df`

**Implementation under validation:** `088bc2d188eded555a1e99259f3f3a600fb8c67b`

**Rejected Receiving branch preserved:** `c9752c8c68cd55b950dd588542ea271e1acc0aab`

**Engine:** Godot `4.7.stable.official.5b4e0cb0f`, Jolt, GL Compatibility

**Evidence renderer:** OpenGL 3.3 Compatibility, NVIDIA GeForce RTX 5060 Ti

## Outcome

The bounded round-one correction is technically complete on the existing wing branch. All 20 observations have corresponding authored geometry, focused contract coverage, controller/collision evidence, and current visual evidence. The revised wing now has a larger enclosed Receiving apron and separate freight cage; corrected core thresholds and sightlines; single-owner shared walls; real A-east, B-west, and B-east openings; distinct enterable Medical, Kitchen, and Workshop service spaces; the retained bent Salvager spur; a clean enclosed dogleg; a narrower Incinerator; and an open Bunker Ops Transfer Landing with a separate personnel-sized deeper-settlement door.

This is a neutral greybox handoff, not human spatial approval. Production art, furnishing, delivery choreography, facility gameplay, physical Receiving, workflow promotion, and integrated balance remain outside this validation.

## Review launch

```powershell
& 'D:\AI Tools\Godot-4.7-Codex\Godot_v4.7-stable_win64.exe' --path 'D:\Godot Projects\Sorting-apoc-PROTOTYPE' 'res://greybox/logistics_wing/wing_review.tscn'
```

The review scene starts on the Receiving apron and retains the project controller: `WASD`, mouse-look, `Shift` sprint, and `Esc` mouse release. Walk speed remains `4.0 m/s`, sprint multiplier `2.0`, capsule radius/height `0.34/1.75 m`, eye height `1.7162851 m`, and FOV `75°`.

## Correction register

`PASS` below means the authored correction is present and its listed technical evidence passed. It does not promote the separate human-review status.

| ID | Status | Result and current evidence |
| --- | --- | --- |
| 01 | PASS | Receiving apron is enlarged and the freight cage is a separate rear/side/ceiling enclosure behind a flanked aperture. `overview_debug_topdown.png`, `receiving_apron.png`, `receiving_freight_aperture.png`; `freight_barrier` collision probe. |
| 02 | PASS | Receiving→Backlog clear opening is `4.8 m` with `2.6 m` wall returns on the `10 m` frontage. `receiving_backlog_threshold.png`; geometry contract. |
| 03 | PASS | Dispatch is a shallow east-west `9.5 × 3.5 m` alcove with a neutral work-surface proxy. `dispatch.png`; geometry contract. |
| 04 | PASS | Sorting extends to `Z=-7.2`; table depth is `1.74 m` (+20% from `1.45 m`) with open front and `1.6 m` end clearances. `sorting_table.png`; geometry contract. |
| 05 | PASS | Backlog→Sorting has a traversable `4.8 m` threshold with separating returns. `backlog_sorting_threshold.png`; `receiving_to_sorting` replay. |
| 06 | PASS | Workshop now ends in a broad positive service-room footprint rather than an inverse nook. `overview_debug_topdown.png`, `workshop_service.png`; geometry contract. |
| 07 | PASS | Medical, Kitchen, and Workshop have open territorial entrances, reachable support floors, neutral non-colliding interfaces, and separate opaque inner core boundaries; Ops has the analogous open landing. Four entry routes and four inner-boundary probes pass. |
| 08 | PASS | Every collinear structural wall pair has a single physical owner. Generic pairwise geometry inspection reports zero overlapping collinear wall runs, reduced from the 25 reproduced first-pass pairs. |
| 09 | PASS | Bent Salvager spur remains; the machine/enclosure moved forward for a partial approach reveal. `workshop_salvager_reveal.png`; `sorting_to_salvager` replay. |
| 10 | PASS | A–E retain distinct restrained outlines; C has the solid southern intrusion, D the shallow bump, and E remains single-entry. `overview_debug_topdown.png`, `storage_cd_south.png`. |
| 11 | PASS | Gallery A east has a real `2.4 m` collision opening into the shared junction. `storage_ab_junction.png`; `shared_junction_to_gallery_a_east` replay. |
| 12 | PASS | Gallery B west has a real `2.4 m` collision opening into the same junction. `storage_ab_junction.png`; `shared_junction_to_gallery_b_west` replay. |
| 13 | PASS | C/D/E begin at `Z=4.5` or farther south, broadening the Storage network and preserving an open Deeper threshold. `storage_network.png`, `storage_cd_south.png`; all five Storage→gallery replays. |
| 14 | PASS | Sorting retains oblique Receiving awareness while the east threshold and coordinated Deeper dogleg break the lift-to-Deeper/Ops axis. `sorting_receiving_partial.png`, `sorting_storage_offset.png`, `deeper_storage_sightline.png`. No prop/FOV workaround was used. |
| 15 | PASS | Kitchen is reached from B east through its `2.8 m` opening; `StorageSpine>KitchenApproach` is forbidden and Medical remains separate. `kitchen_b_east.png`; `gallery_b_to_kitchen_service` replay. |
| 16 | PASS | Incinerator pocket narrows from `10.0 m` to `7.0 m`; machine narrows with it and retains front access with blocked side/rear bypass. `incinerator.png`; `sorting_to_incinerator` replay. |
| 17 | PASS | Deeper wide leg turns through a clean `3.0 m` narrow leg with continuous floor, ceiling, and east return. `deeper_dogleg.png`; `dogleg_return` probe. |
| 18 | PASS | Ops is an open `7 × 9 m` landing with a side interface; the separate east closure is a `2.4 m` door proxy within wall. `bunker_ops_landing.png`, `bunker_ops_door.png`; route and boundary probes. |
| 19 | PASS | B-east approach turns into an enclosed `10.5 × 7 m` Kitchen Service Room; the former exterior void is closed. `kitchen_b_east.png`, `kitchen_service.png`; `kitchen_turn_return` and inner-boundary probes. |
| 20 | PASS | The Receiving/Backlog height step has a `4.8 × 0.8 m` vertical closure strip. `receiving_ceiling_transition.png`; geometry contract. |

## Revised dimensions and boundary ownership

Coordinates use `+X east`, `+Z south`, and `Y=0` finished floor. Ordinary clear height is `3.40 m`, Receiving height `4.20 m`, wall thickness `0.30 m`, and floor/ceiling thickness `0.30 m`.

| Area | Revised authored decision | Boundary / owner |
| --- | --- | --- |
| Freight enclosure | `5.0 × 7.0 m`, `X -44..-39`, `Z -3.5..3.5` | Receiving owns flanking wall, side/rear enclosure, ceiling, and barrier at `X=-39`. |
| Receiving apron | `12.0 × 10.0 m`, `X -39..-27`, `Z -5..5`; usable plan about `84.3→113.5 m²` (~+35%) | Receiving owns perimeter and `4.8 m` Backlog aperture returns. |
| Dispatch | `9.5 × 3.5 m`, `X -36.5..-27`, `Z -8.5..-5` | Receiving district. |
| Sorting | Main `10 × 10 m`, north pocket to `Z=-7.2`; table `4.8 × 1.74 m` | Sorting owns its offset east threshold at `Z 1.0..4.2`. |
| Shared circulation | West spine `X -5..4.5`, east spine `X 4.5..26`; shared A/B junction `X 4.5..9`, `Z -5..-1.5` | Junction is distinct from Medical. |
| Gallery A | East opening `2.4 m`, `X=4.5`, `Z -4.8..-2.4` | A owns A-east; Medical does not duplicate it. |
| Gallery B | West opening `2.4 m`; east Kitchen opening `2.8 m` | B owns B-west and B-east; junction/Kitchen do not duplicate them. |
| Galleries C/D | Secondary opening `2.5 m`, `X=6`, `Z 9.0..11.5` | C alone owns the C↔D divider. |
| Medical Supply Anteroom | `7.8 × 7.0 m`, `X 2.8..10.6`, `Z -20..-13` | Open south entrance; north inner boundary at `Z=-20`; interface on playable side. |
| Kitchen Service Room | `10.5 × 7.0 m`, `X 21.5..32`, `Z -25..-18` | Open south entrance; north inner boundary at `Z=-25`; route only from B-east. |
| Workshop Service Room | `12 × 10 m`, `X -18..-6`, `Z 13..23` | Open north entrance; west inner boundary at `X=-18`; interface on playable side. |
| Salvager | Cross leg `X -6..8`, `Z 18..22`; pocket `X 2..8`, `Z 22..28.5` | Separate from Workshop interface; machine front near `Z=23.5`. |
| Deeper dogleg | Wide `X 26..35`, turn `X 32..36`, narrow `X 36..58`, `Z -7..-4` | Deeper owns the closed dogleg return. |
| Incinerator | Pocket `7.0 m` wide, `X 28..35` (was `10.0 m`) | Machine and pocket narrow together; sub-`0.5 m` side gaps block bypass. |
| Bunker Ops | Landing `7 × 9 m`, `X 58..65`, `Z -11..-2` | Open west arrival; north inner boundary; east `2.4 m` door with surrounding wall. |

The saved scene declares revision `logistics-wing-greybox-round01-revision-01`. The focused geometry contract samples actual collision openings, verifies named interface/boundary nodes, rejects obsolete frontage closures, and compares all structural wall boxes for overlap.

## Before/after visual mapping

Original first-pass files remain untouched in `reports/logistics_wing/greybox/`. Revision files exist only in `reports/logistics_wing/greybox/revision_01/`.

| First-pass view | Revision evidence |
| --- | --- |
| `overview_debug_topdown.png` | `revision_01/overview_debug_topdown.png` |
| `receiving_freight.png`, `receiving_core.png` | `receiving_freight_aperture.png`, `receiving_apron.png`, `receiving_backlog_threshold.png`, `receiving_ceiling_transition.png` |
| `backlog_sorting.png`, `sorting_table.png` | `backlog_sorting_threshold.png`, `sorting_table.png` |
| `sorting_receiving.png`, `sorting_storage.png` | `sorting_receiving_partial.png`, `sorting_storage_offset.png` |
| `storage_ab.png` | `storage_ab_junction.png` |
| `storage_cd.png`, `storage_e.png` | `storage_cd_south.png`, `storage_network.png` |
| `medical_approach.png` | `medical_anteroom.png` |
| `kitchen_approach.png` | `kitchen_b_east.png`, `kitchen_service.png` |
| `workshop_frontage.png` | `workshop_service.png` |
| `workshop_salvager.png`, `workshop_blocked.png` | `workshop_salvager_reveal.png`, `workshop_blocked.png` |
| `deeper_wide.png`, `deeper_narrow.png` | `deeper_storage_sightline.png`, `deeper_dogleg.png` |
| `incinerator.png` | `incinerator.png` |
| `bunker_ops_closure.png` | `bunker_ops_landing.png`, `bunker_ops_door.png` |

The manifest records 24 views at `1920 × 1080`. The two contact sheets use `480 × 360` tiles composed of an aspect-preserving `480 × 270` image and a separate `90 px` caption band. Both `1920 × 1080` and `800 × 600` fit cases are contract-tested; no source image is stretched to 4:3.

## Controller-driven route evidence

The unchanged controller consumed injected physical `W` input at 60 Hz without sprint. Each measurement resets to its named start anchor; no teleport occurs within a route. Yaw follows explicit waypoints, arrival tolerance is `0.45 m`, and all endpoint errors are `0.318–0.380 m`. The machine-readable record is `reports/logistics_wing/greybox/revision_01/traversal_results.json`.

| Route | Start → end anchor | Walk | Time | End error |
| --- | --- | ---: | ---: | ---: |
| Receiving→Sorting | ReceivingApron→SortingWork | 23.903 m | 6.167 s | 0.380 m |
| Receiving→near Storage | ReceivingApron→StorageNear | 30.701 m | 7.800 s | 0.367 m |
| Sorting→shared A/B junction | SortingWork→SharedABJunction | 26.764 m | 6.867 s | 0.335 m |
| Junction→A east | SharedABJunction→GalleryA | 6.621 m | 1.800 s | 0.364 m |
| Junction→B west | SharedABJunction→GalleryB | 5.233 m | 1.433 s | 0.328 m |
| Junction→Medical | SharedABJunction→MedicalAnteroom | 12.988 m | 3.367 s | 0.345 m |
| B east→Kitchen | GalleryB→KitchenService | 26.369 m | 6.783 s | 0.356 m |
| Sorting→Workshop | SortingWork→WorkshopService | 21.118 m | 5.400 s | 0.347 m |
| Sorting→Salvager | SortingWork→SalvagerFront | 37.220 m | 9.500 s | 0.357 m |
| Sorting→Incinerator | SortingWork→IncineratorFront | 55.884 m | 14.150 s | 0.323 m |
| Sorting→Bunker Ops inner side | SortingWork→BunkerOpsSafeSide | 86.435 m | 21.883 s | 0.369 m |
| Deeper→Ops landing | IncineratorFront→BunkerOpsLanding | 45.607 m | 11.567 s | 0.318 m |
| Sorting→blocked continuation | SortingWork→BlockedContinuationSafeSide | 28.321 m | 7.200 s | 0.349 m |
| Sorting→deeper door | SortingWork→DeeperClosureSafeSide | 86.836 m | 21.950 s | 0.356 m |
| C→D secondary | GalleryC→GalleryD | 9.687 m | 2.533 s | 0.380 m |
| C→D via spine | GalleryC→GalleryD | 16.254 m | 4.267 s | 0.345 m |
| Storage→A | StorageNear→GalleryA | 11.554 m | 3.050 s | 0.379 m |
| Storage→B | StorageNear→GalleryB | 17.680 m | 4.583 s | 0.327 m |
| Storage→C | StorageNear→GalleryC | 8.463 m | 2.267 s | 0.318 m |
| Storage→D | StorageNear→GalleryD | 15.450 m | 4.017 s | 0.322 m |
| Storage→E | StorageNear→GalleryE | 27.441 m | 7.017 s | 0.330 m |

The C↔D comparison uses the same `GalleryC` and `GalleryD` anchors. The secondary route measured `9.687 m / 2.533 s`; the spine alternative measured `16.254 m / 4.267 s`. These are observations, not a balance promise.

### Sustained-input boundary checks

Each probe drove the normal player into a boundary for 3 simulated seconds and required less than `0.08 m` movement during the final second.

| Boundary | Final blocking coordinate | Displacement | Result |
| --- | ---: | ---: | --- |
| Freight barrier | `X=-38.497` | 1.497 m | PASS |
| Medical inner boundary | `Z=-19.508` | 1.508 m | PASS |
| Kitchen inner boundary | `Z=-24.508` | 2.508 m | PASS |
| Workshop inner boundary | `X=-17.509` | 2.009 m | PASS |
| Blocked continuation | `Z=25.084` | 0.884 m | PASS |
| Bunker Ops inner boundary | `Z=-10.509` | 2.009 m | PASS |
| Deeper-settlement door | `X=64.334` | 0.834 m | PASS |
| Kitchen turn return | `Z=-11.692` | 0.508 m | PASS |
| Dogleg return | `X=35.508` | 0.508 m | PASS |
| Shared-junction return | `Z=-4.508` | 0.508 m | PASS |

Final replay result: **21/21 routes, 10/10 boundaries, 0 failures**.

## Verification record

| Check | Result |
| --- | --- |
| Geometry generation | PASS — `WING_GEOMETRY_GENERATED`, `110×55 m`, 1,015 nodes |
| `logistics_wing_geometry_tests.gd` | PASS |
| `logistics_wing_capture_tests.gd` | PASS |
| `logistics_wing_traversal_tests.gd` | PASS |
| Capture runtime | PASS — 24 views, 2 sheets, `gl_compatibility` |
| Traversal runtime | PASS — 21 routes, 10 boundaries, 0 failures |
| Editor/parser scan | PASS; Windows root-certificate diagnostic only |
| Independent review-scene smoke | PASS |
| Original default-main smoke | PASS; UID remains `uid://drbkr86g3cxl1` |
| Existing non-hanging regression scripts | PASS — 33/33 exited 0 |
| Protected-file diff from `8ee62bd3` | PASS — no changes |
| Revision diff check from `d81783f` | PASS |

The 33 passing scripts were: `authoring_review_manifest`, `auto_stack_group_registry`, `environment_asset_relocation`, `footprint_review_content`, `item_catalog_coverage`, `item_catalog_initial_seed`, `item_catalog`, `item_definition_seeder`, `item_interaction_reviewability`, all three `logistics_wing` suites, `loot_audit_core`, `main_scene_pickup_registration`, all seven `receiving_*` suites, `stack_role_authoring`, `stack_role_batch`, all nine `storage_*` suites, and `support_stacking_metadata`.

The bounded 25-second `main_scene_loot_audit_integration_tests.gd` run reproduced exactly the retained baseline: two assertions at line 179 and one assertion at line 95, then was terminated. No fourth assertion or new wing-related diagnostic appeared. Known deliberate duplicate-ID/path and `loot_000015` stimuli remain outside this geometry revision.

Godot repeatedly emitted `Failed to read the root certificate store` on this Windows host while relevant commands exited successfully. The greybox does not use network features.

The required full-branch `git diff --check 8ee62bd3...` still reports four inherited first-pass formatting diagnostics in `docs/superpowers/specs/2026-09-15-logistics-wing-greybox-design.md` and `greybox/logistics_wing/wing_capture.tscn`. Those files were not modified by this revision. The revision-only `git diff --check d81783f...` passes. This report does not rewrite historical files merely to conceal that baseline.

The final deterministic rebuild changed only Godot-generated `unique_id` values in `wing_geometry.tscn` (`0` non-`unique_id` changed lines); the authored transforms, sizes, metadata, and node structure remained identical and all focused checks passed afterward.

## Preservation and scope

Protected files are byte-diff clean from the verified main base: `main.tscn`, `project.godot`, `player_controller.gd`, `camera_movement.gd`, `data/`, and `tools/asset_pipeline/item_authoring_review.json`. The rejected Receiving branch still resolves to `c9752c8c68cd55b950dd588542ea271e1acc0aab`.

Revision source changes are limited to:

- `docs/superpowers/plans/2026-09-16-logistics-wing-greybox-round01-revision.md`
- `docs/testing/logistics-wing-greybox-round01-revision-validation.md`
- `greybox/logistics_wing/build_wing_geometry.gd`
- `greybox/logistics_wing/wing_geometry.tscn`
- `greybox/logistics_wing/wing_capture.gd`
- `greybox/logistics_wing/wing_review.tscn`
- `greybox/logistics_wing/wing_traversal.gd`
- the three existing `tools/asset_pipeline/tests/logistics_wing_*_tests.gd` suites

Original first-pass and Receiving evidence remain untracked and present. New evidence is also intentionally untracked and isolated below `reports/logistics_wing/greybox/revision_01/`. No parent cleanup was run, no stash was created, and nothing was pushed or merged.

## Self-inspection and correction cycle

- Structural assertions were made RED against the first-pass scene before the builder changed; they reproduced the old revision metadata, 25 overlapping collinear wall pairs, obsolete frontage blocks, missing service spaces/interfaces, wrong B→Kitchen topology, and missing enclosure/dimension changes.
- Capture and traversal contracts were separately made RED against the old evidence paths, stretched contact layout, route set, and frontage-boundary records before their implementations changed.
- The first complete controller run passed all 21 routes and 9/10 boundaries. The shared-junction probe started only `0.309 m` from its wall while evidence requires more than `0.40 m` travel; moving only the probe start back produced a `0.508 m` blocked displacement and the full rerun passed.
- Full-resolution inspection found the first Kitchen-from-B and Salvager-reveal cameras partially occluded. Their cameras were retargeted without changing FOV, eye height, or geometry; the complete evidence set and sheets were regenerated and re-inspected.
- No user intervention or design clarification was needed. No player, gameplay, data, art, or Receiving implementation was altered.

## Status separation and human questions

| Status category | Status | Meaning |
| --- | --- | --- |
| Technical checks | PASS | Focused suites, 33 regressions, scenes, renderer, controller routes, and boundary probes passed. |
| Correction-register fidelity | PASS (technical) | All 20 requested corrections have direct geometry/evidence coverage. |
| Human spatial promotion | DEFERRED | Requires developer walkthrough for feel, legibility, landmarking, and subjective scale. |
| Workflow feasibility | DEFERRED | No delivery choreography or live departmental workflow was authorized or tested. |
| Revision reliability promotion | DEFERRED | The correction cycle is documented and reproducible; human acceptance still gates promotion. |
| Production art | DEFERRED | Neutral geometry and proxy masses only. |
| Physical Receiving | DEFERRED | No live item arrival, piles, or freight gameplay was added. |
| Integrated balance | DEFERRED | Route timings are measurements, not tuning approval. |

Human review should answer:

1. Does Receiving now feel deliberately large enough while the half-frontage Backlog threshold still reads clearly?
2. Do the three service spaces feel distinct and usable without implying unauthorized staffed interiors or treatment/furnishing detail?
3. Does the shared A/B junction read separately from the protected Medical spur, and is the B-east Kitchen route intuitive?
4. Are the retained Salvager reveal, Storage breadth, interrupted vistas, dogleg, narrowed Incinerator, and two-destination Ops terminal convincing at normal mouse-look speed?
5. Are any local proportions worth one more geometry pass before art, gameplay, or workflow design begins?

Stop after that review. Do not merge, push, begin production art, add functional Receiving, or implement facility workflows automatically.
