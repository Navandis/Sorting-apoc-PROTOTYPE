# Compact bunker layout result

**15 November 2026. Compact bunker layout — HUMAN-ACCEPTED / PUBLISHED / CLOSED IN ITS BOUNDED SCOPE.** The developer accepted all nine slices and closed the major rebuild in its bounded scope. [Acceptance and main verification](../design_history/2026-11-15-compact-bunker-layout-acceptance-and-publication.md) · [Roof-off north-up overview](../design_history/media/2026-11-15-compact-bunker-layout-north-up.png)

## Slice 1 · Backlog and Receiving/Dispatch · 14 November 2026

**The developer completed the walkthrough and reported zero issues.** Base `4e12a235d858e7357b931813a61b51d9356e8d34` on `main` in `D:/Godot Projects/Sorting-apoc-PROTOTYPE`. [Recoverable Slice 1 patch](<C:/Users/Boschetar/.codex/attachments/Sorting_Apocalypse_Assessments/2026-11-14-compact-bunker-layout/slice-1.patch>)

The authoring checkout started clean and matched the tracked GitHub `main`. The desktop inventory showed no open Godot editor holding an unsaved buffer. The supplied north-up image matched the saved layout. The changes were staged and verified from a workspace-local checkout of the same revision using the existing asset and import directories. `Expedition` is a separate older checkout at `86dbe3d` with a junction to the authoring project's assets. Validation ran on Godot `4.7.stable.official.5b4e0cb0f`, Compatibility and Jolt. Codex ran as one implementer. The exact model variant and effort were unavailable.

### Measured geometry

Positions are in metres. East is +X, south is +Z and floor level is Y 0. Length and width use the nominal floor extents. Clear passage width uses the wall faces.

| Dimension | Baseline | Slice 1 target | Actual |
| --- | ---: | ---: | ---: |
| Backlog east–west | 13.50, X −28.50…−15.00 | 6.75, 50% | 6.75, X −21.75…−15.00 |
| Backlog north–south | 7.60, Z −3.80…+3.80 | 5.70, 75% | 5.70, Z −3.80…+1.90 |
| Backlog wall-to-wall width | 7.30 | 5.40 | 5.40, Z −3.65…+1.75 |
| Backlog between the two inside jamb faces along X | 13.20 | 6.45 | 6.45, X −21.60…−15.15 |
| Common Receiving/Dispatch translation | 0 | +6.75 X | (+6.75, 0, 0) |

| Junction | Wall axis | Clear horizontal faces | Clear height | Owners |
| --- | --- | --- | ---: | --- |
| Receiving to Backlog | X −21.75 | Z −1.42…+1.42, 2.84 m | 3.40 | Receiving sill, authored opening wall and greybox jamb/header collision. Both Backlog runs butt against its east face at X −21.60. |
| Backlog to Sorting | X −15.00 | Z −0.85…+1.60, 2.45 m | 3.40 | Backlog east jambs occupy X −15.15…−14.85. The coplanar Backlog and Sorting slabs form the head. Sorting owns the west returns beyond the side walls. |
| Receiving to Dispatch | Z −4.00 | X −26.164…−23.764, 2.40 m | 4.20 | Existing Receiving/Dispatch walls, floors and ceilings translated together. |

Keep the 2.45 × 3.40 m Sorting opening for Slice 2. The future north inside face is Z −0.85 when the north wall axis moves to −1.00. The +1.60 south jamb leaves a 0.15 m nib inside Backlog. Slice 2 retires `SortingWestNorthShoulder` from Z −5.00…−3.80 and joins the new north wall to the retained jamb. The south return closes from Z +1.90 to Sorting’s fixed +5.00 axis. The baseline Sorting body is Z −5…+5, the pocket reaches −7.2 and the southern Workshop approach starts at +5.

The north-jamb sightline trial was reverted. Recheck the view from south of the desk after the Slice 2 layout is in place and adjust the jamb if needed.

### Saved owners and preservation

- `build_wing_geometry.gd` produces the new Backlog floor, slab, side runs, and east jambs with their primitive colliders. `wing_geometry.tscn` takes the affected generated transforms and dimensions and keeps the existing IDs and adjoining scene overrides. Sorting’s west south shoulder closes the resized seam. Both nonfunctional Backlog blocks and their colliders were removed.
- `wing_environment.tscn` and `wing_gameplay.tscn` translate the shell, lighting and probe, lift and pose markers, runtime and preserved nonuniform basis, set dressing and movement proxies, Fuel cabinet, monitor, independent chains and glass, Receiving wear and the 11 owned experimental placements. The Dispatch counter and approach anchors move with its annex. The arithmetic changes only the saved positions of those owners. Existing runtime scripts, bindings and deck profile are used directly.
- The initialized comparison covered 556 translated Node3D poses and 1,248 stationary poses outside the edited Backlog/seam groups. Maximum measured translation error was 0.000002 m. Bases, checked mesh/shape bounds, resource paths, visibility, light and collision properties matched. The exact retained inventory includes four Sorting tables, 44 seed hosts, four qualifying storage units, one fixed ladder and 16 registered storage surfaces. [Comparison log](<C:/Users/Boschetar/.codex/attachments/Sorting_Apocalypse_Assessments/2026-11-14-compact-bunker-layout/logs/preservation-comparison.txt>) · [Retained inventory](<C:/Users/Boschetar/.codex/attachments/Sorting_Apocalypse_Assessments/2026-11-14-compact-bunker-layout/retained-inventory.json>)
- The Receiving lighting review spawn, greybox review spawn and western capture/traversal records follow the new layout. New greybox evidence uses `compact_layout_slice_1`. Selected test expectations now point at the moved geometry and retain physical pose, separation, movement and interaction assertions.

### Focused checks

Headless checks ran via `--headless --path <project> --script res://tools/asset_pipeline/tests/<name>.gd`, with an external save directory for startup parity. [Logs](<C:/Users/Boschetar/.codex/attachments/Sorting_Apocalypse_Assessments/2026-11-14-compact-bunker-layout/logs>)

| Result | Existing check |
| --- | --- |
| Pass | `receiving_lift_installation_tests`, `receiving_deck_metric_tests`, `receiving_lift_cycle_tests`, `receiving_freight_reach_tests` |
| Pass | `wing_startup_parity_tests`, `logistics_wing_capture_tests`, `logistics_wing_traversal_tests` (capture and traversal manifests) |
| Same two baseline failures | `logistics_wing_geometry_tests` expects the old direct wing launch UID and a 46-host palette. Its changed layout assertions pass. |
| Same four baseline failures | `receiving_set_dressing_collision_tests` has four DeskMovement rendered-bounds assertions. Its translated proxy and circulation sweeps pass. |
| Same Gallery A baseline failure | `wing_gameplay_navigation_tests` stalls at `gallery_a_fixture_front`. The updated Receiving → Backlog → Sorting route reaches its destination. |

The Windows certificate-store diagnostic appeared in headless and native logs. Compatibility printed the previously recorded CF-07 null-material diagnostics on held-item transitions. Those diagnostics also occur on the accepted baseline. [Current state](../CURRENT_STATE.md)

### Native New Run

The 1280×720 Windows witness used the configured F5 shell and a fresh isolated profile. It clicked New Run, then drove the production walk controller with W and aimed via scripted yaw and reticle inputs. It selected Food and Fuel at the moved Dispatch counter and dispatched one crew using the live UI. Seed 1 produced four items. The active clock advanced to the return time. Lift arrival, opening, closing and departure then used the ordinary timeline. [Native log](<C:/Users/Boschetar/.codex/attachments/Sorting_Apocalypse_Assessments/2026-11-14-compact-bunker-layout/logs/native-slice1.log>)

- Walked Sorting ↔ Backlog ↔ Receiving and Receiving ↔ Dispatch, including both Backlog junctions with a 12-Bulk cylinder. The barrier stopped the controller at X −28.845 with the shutter closed and fully open.
- Confirmed the closed/open shutter endpoints, cargo seating, W1 off/amber/green, CRT IDLE/INCOMING/OPEN and a return to IDLE after the last TAKE and departure. The arrival cue played at the translated emitter. Closing/departure were observed through runtime state and audio playback flags. Listening by ear is part of the human walkthrough.
- Took all four items with ordinary reticle clicks. The longest recorded TAKE was 1.313 m. The relocated probe issued ten refreshes through the cycle, including after TAKE.
- Reached the moved Fuel cabinet normally, opened it with F and credited generated Fuel with E. The first contribution raised reserve from about 44.5 to 60.0. The witness finished with zero failed assertions.

[Northern plan view, roofs hidden for inspection](<C:/Users/Boschetar/.codex/attachments/Sorting_Apocalypse_Assessments/2026-11-14-compact-bunker-layout/north-up.png>) · [Backlog and both junctions](<C:/Users/Boschetar/.codex/attachments/Sorting_Apocalypse_Assessments/2026-11-14-compact-bunker-layout/north-up-slice.png>) · [Baseline Receiving, closed](<C:/Users/Boschetar/.codex/attachments/Sorting_Apocalypse_Assessments/2026-11-14-compact-bunker-layout/receiving-baseline-closed.png>) · [Slice 1 Receiving, closed](<C:/Users/Boschetar/.codex/attachments/Sorting_Apocalypse_Assessments/2026-11-14-compact-bunker-layout/receiving-closed.png>) · [Fully open](<C:/Users/Boschetar/.codex/attachments/Sorting_Apocalypse_Assessments/2026-11-14-compact-bunker-layout/receiving-open.png>) · [After turnaround](<C:/Users/Boschetar/.codex/attachments/Sorting_Apocalypse_Assessments/2026-11-14-compact-bunker-layout/receiving-after-turnaround.png>) · [Dispatch](<C:/Users/Boschetar/.codex/attachments/Sorting_Apocalypse_Assessments/2026-11-14-compact-bunker-layout/dispatch.png>) · [Fuel](<C:/Users/Boschetar/.codex/attachments/Sorting_Apocalypse_Assessments/2026-11-14-compact-bunker-layout/fuel.png>) · [Carried load in Sorting](<C:/Users/Boschetar/.codex/attachments/Sorting_Apocalypse_Assessments/2026-11-14-compact-bunker-layout/sorting-carried.png>)

The matched Receiving views use the same room-relative camera and ordinary visibility. The overall plan is north-up with −Z at the top.

### Developer walkthrough

1. Open the authoring project in Godot, run F5 and choose **New Run**. Walk west from Sorting through both jambs. Turn back while carrying an ordinary load and assess the shorter corridor and the offset between the two openings.
2. In Receiving, compare the shutter, cage, floor, ceiling, desk lighting, CRT and barrier with the matched images. Observe a complete delivery and listen from the apron and the Backlog mouth.
3. Walk into Dispatch and open the counter with F. Return to Receiving and use F at the Fuel cabinet to the right of the shutter. With Fuel selected, press E to contribute it.

## Slice 2 · Sorting / Quartermaster Central · 14 November 2026

**Playable in the authoring checkout. Developer walkthrough pending.** `D:/Godot Projects/Sorting-apoc-PROTOTYPE` remains on `main` at `4e12a235d858e7357b931813a61b51d9356e8d34` with the local Slice 1 and Slice 2 edits uncommitted. The preflight matched all 17 edited tracked files and the result record to the local Slice 1 checkpoint. Validation used Godot `4.7.stable.official.5b4e0cb0f`, Compatibility and Jolt, from a local validation copy of that checkpoint. [Recoverable Slice 2 patch](<C:/Users/Boschetar/.codex/attachments/Sorting_Apocalypse_Assessments/2026-11-14-compact-bunker-layout/slice-2/slice-2.patch>)

### Measured geometry

Dimensions are in metres with −Z north. X extents and floor level stayed fixed. The floor, ceiling, wall meshes and primitive colliders follow the same dimensions.

| Element | Accepted Slice 1 | Slice 2 saved |
| --- | --- | --- |
| Sorting main body | X −15…−5, Z −5…+5, 10 × 10 | X −15…−5, Z −1…+5, 10 × 6 |
| North pocket | X −14…−6, Z −7.20…−5, 8 × 2.20 | X −14…−6, Z −2.32…−1, 8 × 1.32 |
| Overall Sorting N–S depth | 12.20 | 7.32, 40% shorter |
| Backlog and Sorting opening | Backlog 6.75 × 5.70. West opening at X −15, Z −0.85…+1.60, 2.45 × 3.40 clear | Same. The new north shoulder meets the retained north jamb at X −14.85, and the south return still spans Z +1.90…+5 |
| Storage opening | X −5, Z +1…+4.20, 3.20 × 3.40 clear | Same. The shortened east wall meets the existing Storage spine at Z −1.35 |
| Workshop approach | Sorting's south wall at Z +5, corridor floor X −12…−8 | Same, with 3.70 m clear between the approach walls |

The old `SortingWestNorthShoulder` was retired. The main north wall's inside face is Z −0.85. The new player spawn is `(−10, 0.05, +1)` and the review work anchor is `(−10, 0.05, +0.10)`. The brown desk aid is now 1.60 × 0.90 × 0.65 m at `(−10, 0.45, −1.80)`. The saved Receiving/Dispatch, lift, Fuel, Storage and Workshop definitions match the accepted Slice 1 checkpoint.

### Table and seed placement

| Table instance | Hosts | Slice 1 → Slice 2 center X, Z (m) |
| --- | ---: | --- |
| `SM_Table_SeedWest` | 16 | (−13.4185, +3.8246), retained |
| `SM_Table_Palette_Hydration` | 4 | (−13.4674, −3.9500) → (−12.4800, −1.2800) |
| `SM_Table_SeedEast` | 13 | (−6.0698, −3.3859) → (−7.0000, −0.6500) |
| `SM_Table_Palette_Food` | 11 | (−6.6327, +3.9566), retained |

Rendered mesh and pickup positions mapped all 44 hosts to their original tables. The two moved groups retain their table-relative X/Z positions. Fifteen existing intersections or large vertical gaps were corrected along Y. The measured item bottoms finish 4.31–11.36 mm above their tabletops, and pickup shapes maintain their relative offsets. All host names, item IDs, visual scenes, orientations/scales and 44 registration IDs match the baseline. The four qualifying storage units, fixed ladder and 16 registered surfaces also match. [Placement comparison](<C:/Users/Boschetar/.codex/attachments/Sorting_Apocalypse_Assessments/2026-11-14-compact-bunker-layout/slice-2/logs/placement-comparison.log>) · [Host-by-host moves](<C:/Users/Boschetar/.codex/attachments/Sorting_Apocalypse_Assessments/2026-11-14-compact-bunker-layout/slice-2/table-ownership.json>) · [Baseline inventory](<C:/Users/Boschetar/.codex/attachments/Sorting_Apocalypse_Assessments/2026-11-14-compact-bunker-layout/slice-2/baseline-placement.json>) · [Slice 2 inventory](<C:/Users/Boschetar/.codex/attachments/Sorting_Apocalypse_Assessments/2026-11-14-compact-bunker-layout/slice-2/candidate-placement.json>)

### Files changed in Slice 2

- `greybox/logistics_wing/` — `build_wing_geometry.gd`, `wing_geometry.tscn`, `wing_capture.gd`, `wing_traversal.gd`.
- `gameplay/logistics_wing/wing_gameplay.tscn` — spawn, two table transforms and 21 host transforms.
- `tools/asset_pipeline/tests/` — `logistics_wing_geometry_tests.gd`, `logistics_wing_capture_tests.gd`, `logistics_wing_traversal_tests.gd`, `wing_gameplay_navigation_tests.gd`.
- `docs/testing/2026-11-14-compact-bunker-layout-result.md` — appended this result.

### Focused verification

Headless suites used `Godot_v4.7-stable_win64_console.exe --headless --path <project> --script res://tools/asset_pipeline/tests/<name>.gd`. Startup parity also used `-- --m1-save-dir=<isolated-directory>`. The direct scene smoke used `--headless --path <project> --quit-after 120 res://gameplay/logistics_wing/wing_gameplay.tscn`. [Logs](<C:/Users/Boschetar/.codex/attachments/Sorting_Apocalypse_Assessments/2026-11-14-compact-bunker-layout/slice-2/logs>)

| Check | Exit | Result |
| --- | ---: | --- |
| `logistics_wing_geometry_tests` | 1 | All Slice 2 assertions passed, including 19 that failed against the old Sorting geometry. The same two baseline assertions failed for the old direct-wing launch UID and 46-host count. |
| `wing_gameplay_navigation_tests` | 1 | 7 routes passed, including 4 around Sorting. `gallery_a_fixture_front` alone failed, with the same timeout and 4.067 m end error as the baseline. |
| `wing_startup_parity_tests` | 0 | PASS. The configured F5 run shell resolves the direct gameplay composition. |
| `wing_seed_fixture_tests` | 0 | PASS, including seven expected invalid-seed and duplicate-namespace rejections. |
| `wing_storage_bridge_interaction_tests` | 0 | PASS. Existing storage placement, retrieval and ladder interactions. |
| `logistics_wing_capture_tests`, `logistics_wing_traversal_tests` | 0 each | Both manifest contracts passed. |
| Direct gameplay scene and current inventory | 0 each | Direct scene launched and the separate live census reported 4 tables, 44 hosts and registrations, and 16 surfaces. |
| Native New Run | 0 | Four pickups, all three entrances and the W1 sightline observed. Zero witness assertion failures. |

The Windows root-certificate diagnostic recurred. The native Compatibility renderer logged the four previously recorded held-item null-material diagnostics (`material_casts_shadows`, `material_is_animated`, `material_get_instance_shader_parameters`, `material_update_dependency`). The unchanged DeskMovement bounds suite was outside this verification sweep. [Native log](<C:/Users/Boschetar/.codex/attachments/Sorting_Apocalypse_Assessments/2026-11-14-compact-bunker-layout/slice-2/logs/native.log>)

### Walkthrough proof

The 1600 × 900 native witness requested New Run through the configured F5 shell with an isolated save profile. The player settled on the Sorting floor. Scripted yaw steered the regular walk controller and left-click reticle pickup. It took a milk carton, pistol, book and canned food from the four tables at distances of 1.03–1.17 m, then walked Sorting ↔ Backlog, Sorting ↔ Storage and Sorting ↔ Workshop with all four items (6 Bulk). The recorded walk was 56.16 m.

Near `(−10, 0, −0.35)` just south of the desk aid, the eye-height ray to the W1 lens was clear through Backlog. The amber W1 lens and part of the lift shutter were visible. The witness used the existing debug delivery to light W1 for that image. The plan views hide the roof and use diagnostic ambient light. The first-person views use the normal scene lighting and camera. [Overall north-up](<C:/Users/Boschetar/.codex/attachments/Sorting_Apocalypse_Assessments/2026-11-14-compact-bunker-layout/slice-2/north-up.png>) · [Sorting north-up](<C:/Users/Boschetar/.codex/attachments/Sorting_Apocalypse_Assessments/2026-11-14-compact-bunker-layout/slice-2/sorting-north-up.png>) · [Toward Storage](<C:/Users/Boschetar/.codex/attachments/Sorting_Apocalypse_Assessments/2026-11-14-compact-bunker-layout/slice-2/sorting-toward-storage.png>) · [Toward Workshop](<C:/Users/Boschetar/.codex/attachments/Sorting_Apocalypse_Assessments/2026-11-14-compact-bunker-layout/slice-2/sorting-toward-workshop.png>) · [Toward the lift](<C:/Users/Boschetar/.codex/attachments/Sorting_Apocalypse_Assessments/2026-11-14-compact-bunker-layout/slice-2/sorting-toward-lift.png>)

Run the authoring project and choose **New Run**. The local launcher gives the walkthrough its own save profile. Walk the three entrances while carrying a load, and check the amber lift light from just south of the desk when a delivery is incoming. [Isolated walkthrough launcher](<C:/Users/Boschetar/.codex/attachments/Sorting_Apocalypse_Assessments/2026-11-14-compact-bunker-layout/slice-2/Play-Slice-2.ps1>)

Does the new table placement leave enough room to turn toward Storage and Workshop with a load?

### Walkthrough refinement · Sorting north wall

The developer requested one metre more depth at the north side. The main north wall moved from Z −1.00 to −2.00, and the pocket’s rear wall moved from Z −2.32 to −3.32. The 10 × 7 m main body floor and ceiling meet the 8 × 1.32 m pocket slabs at Z −2.00. The full north–south depth is 8.32 m. The desk proxy moved to Z −2.80 with the same 45 mm gap to the pocket wall.

The west shoulder meets the existing Backlog jamb. The Sorting east wall closes the new corner, and the first Storage wall segment butts into its east face. The 2.45 × 3.40 m Backlog opening, 3.20 m Storage opening and Z +5.00 Workshop threshold keep their previous clearances. The four table instances and 44 seed hosts keep their previous placements.

Native New Run replay picked up one item per table and walked all three entrances with 6 Bulk. The player reached Z −1.74 on the expanded floor and hit the ceiling above with an upward physics ray. Separate floor and ceiling probes hit their intended slabs at both sides of the expanded floor and shifted pocket. The amber W1 alert was visible from the work area, and a closer eye-height ray at X −10, Z −1.55 also reached the lens. The capture contract passed. Geometry and navigation repeated only the two legacy geometry assertions and the Gallery A route timeout reported above. The Windows native run used dummy audio after WASAPI initialization failed. [North-up view](<C:/Users/Boschetar/.codex/attachments/Sorting_Apocalypse_Assessments/2026-11-14-compact-bunker-layout/slice-2/north-refinement/sorting-north-up.png>) · [Lift view](<C:/Users/Boschetar/.codex/attachments/Sorting_Apocalypse_Assessments/2026-11-14-compact-bunker-layout/slice-2/north-refinement/sorting-toward-lift.png>) · [Logs](<C:/Users/Boschetar/.codex/attachments/Sorting_Apocalypse_Assessments/2026-11-14-compact-bunker-layout/slice-2/north-refinement/logs>) · [Refinement patch](<C:/Users/Boschetar/.codex/attachments/Sorting_Apocalypse_Assessments/2026-11-14-compact-bunker-layout/slice-2/north-refinement/north-refinement.patch>)

### Slice 2 developer acceptance

The developer completed the walkthrough after the 1 m northward refinement and reported no missing walls, ceilings, floors, assets or collision boxes and no in-game issues. The accepted Sorting envelope is 10 × 7 m with an 8 × 1.32 m north pocket, for 8.32 m total depth. This is the baseline for Slice 3.

## Slice 3 · Main Storage · 14 November 2026

**Playable candidate for the developer walkthrough.** Authoring checkout `D:/Godot Projects/Sorting-apoc-PROTOTYPE`, `main` at `4e12a235d858e7357b931813a61b51d9356e8d34`, with the compact-layout edits uncommitted. The 17 modified tracked files and cumulative report matched the accepted post-refinement baseline. No Godot editor or import job was observed on the authoring project during preflight. Validation used Godot `4.7.stable.official.5b4e0cb0f` with Compatibility and Jolt. [Accepted Slice 1–2 checkpoint patch](<C:/Users/Boschetar/.codex/attachments/Sorting_Apocalypse_Assessments/2026-11-14-compact-bunker-layout/slice-3/accepted-slices-1-2.patch>) · [Slice 3 delta](<C:/Users/Boschetar/.codex/attachments/Sorting_Apocalypse_Assessments/2026-11-14-compact-bunker-layout/slice-3/slice-3.patch>)

### Measured layout

| Section | X span (m) | Before Z span / nominal width (m) | After Z span / nominal width (m) | Clear between opposite wall faces (m) |
| --- | --- | --- | --- | ---: |
| West | −5…+4.5 | −1.50…+5.50 / 7.00 | −0.30…+4.30 / 4.60 | 4.30 |
| East | +4.5…+26 | −1.50…+7.00 / 8.50 | −0.30…+5.80 / 6.10 | 5.80 |

The two hall floor rectangles total 174.85 m², down from 249.25 m² (29.85%). Their midlines remain Z +2.00 and +2.75. A/B, shared A/B circulation, Medical and Kitchen translated +1.20 m Z. C/D/E and the C↔D link translated −1.20 m Z. Seventeen floor zones and their corresponding ceilings retained their dimensions. The fixed floors include Sorting, Backlog, Receiving/Dispatch, the Workshop/Salvager branch and Deeper Approach.

The Sorting doorway at X −5 retains 3.20 m clear at Z +0.95…+4.15. Its two jambs moved their opening faces 5 cm north, and the first west spine wall runs butt into the east jamb faces. The old south return was retired because the narrowed hall ends inside Sorting’s south axis. At X +3.80, paired wall faces give 4.30 m clear on approach to the hall step. At X +16.0 the same measurement gives 5.80 m in the east section. At X +26, the Deeper doorway stays 3.00 m clear at Z +0.80…+3.80, with shorter Storage-side returns.

### Retained inventory

| Unit | Before Z (m) | After Z (m) | Surfaces | Grid cells |
| --- | ---: | ---: | ---: | ---: |
| Gallery A west metal shelf | −3.8162 | −2.6162 | 4 | 1,160 |
| Gallery B north metal shelf | −13.7800 | −12.5800 | 4 | 1,160 |
| Gallery C west locker | +9.0000 | +7.8000 | 4 | 403 |
| Modular rack on the A side | −8.5201 | −7.3201 | 4 | 740 |
| Fixed ladder at that rack | −8.6651 | −7.4651 | — | — |

Initialized comparison matched all four qualifying unit references, 16 surface paths and IDs, their grid dimensions and clearances, and 3,463 total cells. Fixture-relative mesh bounds, collision shapes, surface poses and the ladder’s climbing markers matched. The four Sorting tables, 44 hosts and 44 registrations also matched, including the accepted seating heights. Review and gameplay service lights follow Medical and Kitchen with their existing settings. [Comparison](<C:/Users/Boschetar/.codex/attachments/Sorting_Apocalypse_Assessments/2026-11-14-compact-bunker-layout/slice-3/logs/preservation.log>) · [Baseline census](<C:/Users/Boschetar/.codex/attachments/Sorting_Apocalypse_Assessments/2026-11-14-compact-bunker-layout/slice-3/baseline-census.json>) · [Candidate census](<C:/Users/Boschetar/.codex/attachments/Sorting_Apocalypse_Assessments/2026-11-14-compact-bunker-layout/slice-3/candidate-census.json>)

### Changed files

- `greybox/logistics_wing/` — `build_wing_geometry.gd`, `wing_geometry.tscn`, `wing_review.tscn`, `wing_capture.gd`, `wing_traversal.gd`.
- `gameplay/logistics_wing/` — `wing_gameplay.tscn`, `wing_environment.tscn`, and `review/wing_gameplay_capture.gd`.
- `tools/asset_pipeline/tests/` — `logistics_wing_geometry_tests.gd`, `logistics_wing_capture_tests.gd`, `logistics_wing_traversal_tests.gd`, `wing_gameplay_capture_tests.gd`, `wing_gameplay_navigation_tests.gd`.
- `docs/testing/2026-11-14-compact-bunker-layout-result.md` — appended the Slice 2 acceptance and this result.

### Verification

Headless suites used `Godot_v4.7-stable_win64_console.exe --headless --path <project> --script res://tools/asset_pipeline/tests/<suite>.gd`. Startup parity used `-- --m1-save-dir=<isolated-directory>`. [Logs](<C:/Users/Boschetar/.codex/attachments/Sorting_Apocalypse_Assessments/2026-11-14-compact-bunker-layout/slice-3/logs>)

| Check | Exit | Result |
| --- | ---: | --- |
| `logistics_wing_geometry_tests` | 1 | All Slice 3 dimensions, box and junction checks passed. Two inherited assertions failed for the former direct launch UID and 46-host expectation. |
| `wing_gameplay_navigation_tests` | 0 | All nine routes passed. Gallery A’s old diagonal ran into the rack. The route now follows the floor around its south end and approaches the actual metal shelf, using the existing controller and tolerances. |
| `wing_storage_bridge_interaction_tests`, `wing_seed_fixture_tests`, `wing_startup_parity_tests` | 0 each | Storage and ladder interaction, seed checks and configured F5/direct F6 composition passed. Seven seed errors are intentional invalid-declaration and namespace cases. |
| `logistics_wing_capture_tests`, `logistics_wing_traversal_tests`, `wing_gameplay_capture_tests` | 0 each | Current capture and traversal contracts passed. |
| Native New Run and Continue | 0 | All walked routes, four storage actions, ladder, both moved service panels and the current-build continuation passed. |

The Windows root-certificate diagnostic and the previously recorded held-item null-material diagnostics appeared. The witness used the configured audio path for this spatial check. The regression sweep reused the accepted Receiving evidence.

### Native walkthrough

On Windows at 1600 × 900, an isolated New Run walked 283.48 m through the recorded routes with ordinary W/S movement and scripted camera steering. It picked up one item from each Sorting table, checked the north floor and ceiling and the W1 lens ray, and walked through Backlog, Workshop, all five galleries, the shared A/B junction, C↔D, Medical, Kitchen and both sides of the Deeper doorway. The load was 6 Bulk until one item was left in Gallery C.

At the A and B shelves and the C locker, first E opened zoning with General, second E stored, and ordinary reticle TAKE retrieved the item. At the rack, the player attached by walking forward, climbed to player-root Y 1.18 m, placed and retrieved a pistol on `Shelf_04` in manual placement mode, then descended and released onto the floor with the carried bundle intact. Each storage action changed the correct collection score and each retrieval restored the previous score. Medical’s read-only view and Kitchen both opened with F at their relocated frontages.

Save & Exit and Continue restored schema 11, the three carried item IDs, the same canned-food item on the same C locker surface at the saved pose, the `Food = 3` score, rack alignment and the player position. [Native log](<C:/Users/Boschetar/.codex/attachments/Sorting_Apocalypse_Assessments/2026-11-14-compact-bunker-layout/slice-3/logs/native.log>)

Both north-up views show roofs hidden with diagnostic ambient. The first-person views use ordinary lighting, ceilings and collisions. [Whole wing](<C:/Users/Boschetar/.codex/attachments/Sorting_Apocalypse_Assessments/2026-11-14-compact-bunker-layout/slice-3/north-up.png>) · [Storage and galleries](<C:/Users/Boschetar/.codex/attachments/Sorting_Apocalypse_Assessments/2026-11-14-compact-bunker-layout/slice-3/storage-north-up.png>) · [Sorting doorway](<C:/Users/Boschetar/.codex/attachments/Sorting_Apocalypse_Assessments/2026-11-14-compact-bunker-layout/slice-3/sorting-to-storage.png>) · [West hall](<C:/Users/Boschetar/.codex/attachments/Sorting_Apocalypse_Assessments/2026-11-14-compact-bunker-layout/slice-3/west-hall.png>) · [East hall](<C:/Users/Boschetar/.codex/attachments/Sorting_Apocalypse_Assessments/2026-11-14-compact-bunker-layout/slice-3/east-hall.png>) · [Rack and ladder](<C:/Users/Boschetar/.codex/attachments/Sorting_Apocalypse_Assessments/2026-11-14-compact-bunker-layout/slice-3/rack-and-ladder.png>)

### Developer walkthrough

1. Launch a fresh New Run. Take a few items in Sorting and walk through the west hall into Gallery A. Try the west shelf and the fixed ladder beside the rack.
2. Use the shared A/B junction to reach Medical, then turn through Gallery B and the elbow into Kitchen. Check the turn at both service frontages and open them with F.
3. Cross C→D through its side opening, return to the hall, and walk into E and on through the Deeper doorway. Check whether the new west and east widths leave enough turning room with a load.

[Isolated walkthrough launcher](<C:/Users/Boschetar/.codex/attachments/Sorting_Apocalypse_Assessments/2026-11-14-compact-bunker-layout/slice-3/Play-Slice-3.ps1>)

### Slice 3 developer acceptance

The developer completed the in-game walkthrough and reported no issues. The Storage resize matched the guidance. The accepted Slice 3 geometry and placements are the baseline for the Workshop and Salvager refit.

## Slice 4 · Workshop and Salvager · 15 November 2026

**Playable candidate for the developer walkthrough.** `D:/Godot Projects/Sorting-apoc-PROTOTYPE`, `main` at `4e12a235d858e7357b931813a61b51d9356e8d34`, with the four compact-layout slices local and uncommitted. All 20 saved checkpoint paths matched the accepted Slice 3 state before work. No Godot editor or import process was open on the authoring project at preflight. Validation used Godot `4.7.stable.official.5b4e0cb0f`, Compatibility and Jolt. [Accepted Slice 1–3 checkpoint](<C:/Users/Boschetar/.codex/attachments/Sorting_Apocalypse_Assessments/2026-11-14-compact-bunker-layout/slice-4/accepted-slices-1-3.patch>) · [Slice 4 delta](<C:/Users/Boschetar/.codex/attachments/Sorting_Apocalypse_Assessments/2026-11-14-compact-bunker-layout/slice-4/slice-4.patch>)

### Measured layout

| Zone | Accepted Slice 3 nominal | Slice 4 nominal | Slice 4 clear measurement |
| --- | --- | --- | --- |
| Sorting → Workshop approach | 4.00 × 10.00 m. Z +5…+15 | 4.00 × 5.00 m. X −12…−8, Z +5…+10 | 3.70 m wide between the walls at both openings |
| Workshop room | 12.00 × 10.00 m, 120 m² | 10.03992 × 8.36660 m, 84 m². X −17.01996…−6.98004, Z +10…+18.36660 | 9.74 × 8.07 m between opposite inside wall faces |
| Straight Salvager neck | 8.00 × 4.00 m, east of Workshop | 5.60 × 4.00 m, west of Workshop. X −22.61996…−17.01996, Z +13.36660…+17.36660 | 3.70 m between wall faces and at the Workshop exit |
| Terminal turn and pocket | 6.00 × 3.50 m turn and 6.00 × 5.00 m pocket | Same sizes. X −28.61996…−22.61996, with a southward turn into the pocket at Z +16.86660 | Pocket side walls 5.70 m apart. Machine rear gap 0.35 m and side gaps 0.15 m each |

The finished floor is Y 0 and clear height is 3.40 m. The Workshop floor area fell 30% by applying √0.70 to both horizontal dimensions. Existing mesh and collider dimensions were refreshed from the same builder output. The staffed-core boundary moved to the east wall at X −6.98004. Its collisionless interface envelope is on the playable side. The existing Workshop light moved to `(−13, 2.7, 14.1833)` with the same color, range and energy. The terminal remains dim in the ordinary lighting.

The existing node paths stay valid. `SalvagerCrossLegWest` now forms the straight neck and `SalvagerCrossLegEast` the terminal turn. `WorkshopRoomEastNorth/South` flank the new west exit. `SalvagerPocketWest` is the inside wall on the east side of the bend and `SalvagerEast` is the outside wall to the west. The previous east-side footprint has no remaining branch floors, ceilings or collisions.

Initialized mesh and collision bounds, including both branches’ roofs and the Receiving installation’s protruding beams, found no intersections. The smallest horizontal separation to Gallery C/D was 4.68 m. The smallest to Receiving/Backlog was 4.05 m, between the Salvager north wall and `SM_MetalBeam15`. [Candidate branch measurements](<C:/Users/Boschetar/.codex/attachments/Sorting_Apocalypse_Assessments/2026-11-14-compact-bunker-layout/slice-4/logs/candidate-branch.log>)

### Preservation and changed files

Compared 845 protected scene node blocks and 32 stationary floor zones. Initialized transforms, dimensions, IDs, grids and clearances match for all four qualifying storage units, 16 surfaces, 3,463 cells and the fixed ladder. The four Sorting tables and all 44 seed hosts and registration IDs match the accepted poses and definitions. The only change in each of the two production gameplay scene files is the Workshop light pose. [Preservation comparison](<C:/Users/Boschetar/.codex/attachments/Sorting_Apocalypse_Assessments/2026-11-14-compact-bunker-layout/slice-4/logs/preservation.log>)

- `greybox/logistics_wing/` — `build_wing_geometry.gd`, `wing_geometry.tscn`, `wing_review.tscn`, `wing_capture.gd`, `wing_traversal.gd`.
- `gameplay/logistics_wing/` — `wing_environment.tscn`, `wing_gameplay.tscn`, `review/wing_gameplay_capture.gd`.
- `tools/asset_pipeline/tests/` — `logistics_wing_geometry_tests.gd`, `logistics_wing_capture_tests.gd`, `logistics_wing_traversal_tests.gd`, `wing_gameplay_capture_tests.gd`, `wing_gameplay_navigation_tests.gd`.
- `docs/testing/2026-11-14-compact-bunker-layout-result.md` — appended Slice 3 acceptance and this result.

### Ordinary walk comparison

Both headless probes used the production player with an empty carry bundle and the same 60 Hz input replay. The start was the settled player at the Sorting threshold `(−10, 0, +5)`. Distance is measured along the walked path. Time includes the brief stops at route waypoints. The Workshop target kept its 2.50 m offset from the staffed-core axis, and the Salvager target kept its 0.50 m standoff from the machine front. [Accepted branch probe](<C:/Users/Boschetar/.codex/attachments/Sorting_Apocalypse_Assessments/2026-11-14-compact-bunker-layout/slice-4/logs/accepted-branch.log>) · [Slice 4 branch probe](<C:/Users/Boschetar/.codex/attachments/Sorting_Apocalypse_Assessments/2026-11-14-compact-bunker-layout/slice-4/logs/candidate-branch.log>)

| From the Sorting threshold | Accepted Slice 3 | Slice 4 |
| --- | --- | --- |
| To Workshop interface | 18.14 m / 4.83 s | 9.39 m / 2.63 s |
| To Salvager front | 32.55 m / 9.00 s | 26.55 m / 7.50 s |

### Technical verification

Headless suites used `Godot_v4.7-stable_win64_console.exe --headless --path <project> --script res://tools/asset_pipeline/tests/<suite>.gd`. Startup parity added `-- --m1-save-dir=<isolated-directory>`. [Raw logs](<C:/Users/Boschetar/.codex/attachments/Sorting_Apocalypse_Assessments/2026-11-14-compact-bunker-layout/slice-4/logs>)

| Check | Exit | Result |
| --- | ---: | --- |
| `logistics_wing_geometry_tests` | 1 | All branch and protected-layout checks passed after 39 new checks rejected the old layout. The two inherited checks still expect the former direct launch UID and 46 seed hosts. |
| `wing_gameplay_navigation_tests` | 0 | All 12 routes passed, including all nine accepted routes and three Workshop/Salvager routes. |
| `logistics_wing_capture_tests`, `logistics_wing_traversal_tests`, `wing_gameplay_capture_tests` | 0 each | Current capture and traversal contracts passed. |
| `wing_startup_parity_tests` and initialized census | 0 each | F5 shell, direct gameplay composition and unchanged storage and seed ownership verified. |
| Native New Run and Continue | 0 | No walkthrough assertion failures. |

The Windows root-certificate and known held-item null-material diagnostics recurred. This run used the configured Windows audio path. The verification reused the accepted Slice 3 storage/ladder and Receiving behavior evidence.

### Native proof and developer walkthrough

The 1600 × 900 fresh run used regular movement and pickups with scripted steering. It took one item from each Sorting table and carried 6 Bulk through the shortened approach, to the Workshop interface, and through the west exit and southward turn. Twelve vertical physics probes verified floor and ceiling coverage. Walking into the east staffed-core wall and the Salvager machine stopped the player at the expected owners. The rear wall blocked the narrow side gap. The old east neck was clear of structural collision in the retired footprint.

Save & Exit in the Salvager pocket and Continue restored the schema-11 player pose, facing and all four carried item IDs. The player then walked back to Sorting and the eye-height ray to the lift alert was still clear. [Native log](<C:/Users/Boschetar/.codex/attachments/Sorting_Apocalypse_Assessments/2026-11-14-compact-bunker-layout/slice-4/logs/native.log>)

The north-up views hide roofs and use diagnostic ambient light. First-person views retain the ordinary lighting, ceilings and collisions. [Whole wing](<C:/Users/Boschetar/.codex/attachments/Sorting_Apocalypse_Assessments/2026-11-14-compact-bunker-layout/slice-4/north-up.png>) · [Workshop and Salvager plan](<C:/Users/Boschetar/.codex/attachments/Sorting_Apocalypse_Assessments/2026-11-14-compact-bunker-layout/slice-4/workshop-salvager-north-up.png>) · [Workshop entrance](<C:/Users/Boschetar/.codex/attachments/Sorting_Apocalypse_Assessments/2026-11-14-compact-bunker-layout/slice-4/workshop-entrance.png>) · [Interface](<C:/Users/Boschetar/.codex/attachments/Sorting_Apocalypse_Assessments/2026-11-14-compact-bunker-layout/slice-4/workshop-interface.png>) · [West exit](<C:/Users/Boschetar/.codex/attachments/Sorting_Apocalypse_Assessments/2026-11-14-compact-bunker-layout/slice-4/workshop-west-exit.png>) · [Salvager approach](<C:/Users/Boschetar/.codex/attachments/Sorting_Apocalypse_Assessments/2026-11-14-compact-bunker-layout/slice-4/salvager-approach.png>)

Choose **New Run** in the isolated launcher. Carry a load south from Sorting, check the east interface and wall, then turn west through the neck and south at the machine bay. Turn back toward Sorting and judge how readily the new route and room joins read while carrying. [Walkthrough launcher](<C:/Users/Boschetar/.codex/attachments/Sorting_Apocalypse_Assessments/2026-11-14-compact-bunker-layout/slice-4/Play-Slice-4.ps1>)

### Slice 4 developer acceptance

The developer accepted Slice 4 after an issue-free in-game walkthrough, as recorded in the 15 November Slice 5 handoff. The entries above retain the original candidate measurements and results.

## Slice 5 · Northern galleries · 15 November 2026

**Local walkthrough candidate.** Authoring checkout `D:/Godot Projects/Sorting-apoc-PROTOTYPE`, `main` at `4e12a235d858e7357b931813a61b51d9356e8d34`, with the accepted Slices 1–4 working tree as its base. All 20 existing dirty paths matched the Slice 4 record. No Godot editor or import process was active at preflight. Validation used the asset-equipped copy with Godot `4.7.stable.official.5b4e0cb0f`, Compatibility and Jolt. [Accepted Slices 1–4 checkpoint](<C:/Users/Boschetar/.codex/attachments/Sorting_Apocalypse_Assessments/2026-11-14-compact-bunker-layout/slice-5/accepted-slices-1-4.patch>) · [Slice 5 delta](<C:/Users/Boschetar/.codex/attachments/Sorting_Apocalypse_Assessments/2026-11-14-compact-bunker-layout/slice-5/slice-5.patch>)

### Measured structure

| Floor and ceiling | X bounds (m) | Z bounds (m) | N–S depth (m) |
| --- | --- | --- | --- |
| Gallery A main | −5.00…+2.50 | −9.50…−0.30 | 9.20 |
| Gallery A northwest alcove | −7.00…−1.00 | −11.90…−9.50 | 2.40 |
| Shared A/B junction | +2.50…+7.00 | −9.50…−0.30 | 9.20 |
| Gallery B main | +7.00…+14.50 | −9.50…−0.30 | 9.20 |
| Gallery B north bump | +10.00…+14.50 | −10.70…−9.50 | 1.20 |

The northern bank moved 2.00 m west. The main bodies and junction went from 11.50 m to 9.20 m deep, with the fixed south frontage at Z −0.30. Gallery A is 11.60 m deep including its alcove and Gallery B is 10.40 m deep including its bump. Floor level is Y 0, ceilings have 3.40 m clear height, and structural slabs are 0.30 m thick.

At X −5.00, `GalleryAWest` covers Z −9.35…−2.15 and butts into `SortingEastNorth`, which covers Z −2.15…+0.95. The wall faces share a plane and each span has one collider owner. The Gallery A and Sorting floor and roof slabs meet at X −5.00 over their common Z span. Sorting retains its 3.20 m clear east opening at Z +0.95…+4.15, its 2.45 × 3.40 m Backlog opening and its accepted pocket and desk.

A east and B west have 2.40 m clear openings, with faces at Z −6.10 and −3.70. From the hall, A opens at X −2.00…+1.00 and B at X +9.00…+12.00. The shared junction opens at X +2.65…+6.85 clear, across the floor break at X +4.50. Main Storage remains 4.60/6.10 m nominal, 4.30/5.80 m clear, ending at X +26.00. [Northern rooms, roof off](<C:/Users/Boschetar/.codex/attachments/Sorting_Apocalypse_Assessments/2026-11-14-compact-bunker-layout/slice-5/northern-galleries-north-up.png>) · [Whole wing, roof off](<C:/Users/Boschetar/.codex/attachments/Sorting_Apocalypse_Assessments/2026-11-14-compact-bunker-layout/slice-5/north-up.png>)

### Live services and Kitchen fit

| Retained branch element | X bounds (m) | Z bounds (m) |
| --- | --- | --- |
| Medical corridor | +3.80…+6.20 | −19.50…−9.50 |
| Medical room | −1.60…+6.20 | −26.50…−19.50 |
| Kitchen east leg | +14.50…+24.40 | −9.20…−6.40 |
| Kitchen north leg | +21.60…+24.40 | −19.00…−9.20 |
| Kitchen room | +19.40…+29.90 | −26.00…−19.00 |

Medical moved (−2.00, 0, +2.30) m as a unit. The corridor is still 10.00 × 2.40 m nominal with 2.10 m clear between its walls. Kitchen moved (−2.00, 0, −2.20) m as a unit. Its elbow and room orientation are retained. The B-east attachment is Z −7.80, with 2.50 m clear between Z −9.05 and −6.55 inside the 2.80 m nominal corridor. Closures, roof pieces, interface targets, lights and markers follow their respective branches. Runtime targets remain on the authored collisionless proxies, with collision used for interaction rays only.

The clockwise Kitchen rotation would put the old entrance 3.60 m south of the new north wall and 6.90 m north of the new south wall. Keeping the portal centered at Z −4.90 would put the rotated room's south outer wall face at Z +2.15, past the hall's north outer face at Z −0.45. I used one wall thickness of free separation between the two outer faces. Z −7.80 is the closest portal position to the center that provides that separation, a 2.90 m northward adjustment from center.

| Future fit sketch | Floor and roof bounds (m) | Outer wall and collision bounds (m) |
| --- | --- | --- |
| 6.035 m Kitchen connector | X +14.50…+20.535, Z −9.20…−6.40 | X +14.35…+20.685 including junction allowances, Z −9.35…−6.25 |
| Rotated Kitchen | X +20.535…+27.535, Z −11.40…−0.90 | X +20.385…+27.685, Z −11.55…−0.75 |
| Ops link, using the current threshold for the fit sketch | X +26.00…+29.00, Z +0.65…+3.95 | Z +0.50…+4.10 with 3.00 m clear passage |
| Future Ops room west edge | X +29.00 | West face X +28.85 |

At this attachment the proposed room clears the hall by 0.30 m wall to wall and 0.60 m slab to slab. Its west wall is 5.735 m east of B's outer wall across the connecting passage. Medical's easternmost wall is 8.00 m west of the eventual Kitchen connector, which is the closest part of the future Kitchen footprint. The Ops room has 1.165 m of lateral wall clearance, and the link at the existing threshold has 1.25 m of N–S clearance from the Kitchen room. The current Kitchen east-leg south face has 5.80 m of clearance from the hall's outer north face. [Saved geometry and fit measurement](<C:/Users/Boschetar/.codex/attachments/Sorting_Apocalypse_Assessments/2026-11-14-compact-bunker-layout/slice-5/logs/structure-and-fit.log>)

### Installations and scope

| Initialized unit | Candidate X/Z (m) | Translation X/Z (m) | Cells |
| --- | --- | --- | --- |
| A west metal shelf | −4.2800 / −2.6162 | −2.00 / 0 | 1,160 |
| B north metal shelf | +12.0000 / −9.9800 | −2.00 / +2.60 | 1,160 |
| Modular rack in A | −1.3993 / −5.9161 | −2.00 / +1.4040 | 740 |
| Independent fixed ladder | −0.9564 / −6.0611 | −2.00 / +1.4040 | — |
| C ventilated locker | −1.3500 / +7.8000 | 0 / 0 | 403 |

Four qualifying units initialize 16 surfaces and 3,463 cells. The local mesh bounds, shape transforms, grids, surface IDs, stack clearances and orientation metadata match the accepted census. The rack and ladder keep the same relative pose and climb markers. All four Sorting tables and all 44 seed hosts and registrations matched their prior pose and definitions. The geometry comparison found 696 out-of-scope nodes and their referenced resources unchanged. The initialized census also matched all 27 protected floor pieces. [Candidate census](<C:/Users/Boschetar/.codex/attachments/Sorting_Apocalypse_Assessments/2026-11-14-compact-bunker-layout/slice-5/candidate-census.json>) · [Preservation log](<C:/Users/Boschetar/.codex/attachments/Sorting_Apocalypse_Assessments/2026-11-14-compact-bunker-layout/slice-5/logs/preservation.log>)

Changed `build_wing_geometry.gd` and the effective `wing_geometry.tscn`, `wing_environment.tscn`, `wing_gameplay.tscn`, `wing_review.tscn`, the greybox and gameplay capture definitions, review traversal and the five matching geometry, capture, traversal and navigation suites. The authored changes are geometry, translation and review data. Receiving/Dispatch, Backlog, Sorting, C/D/E, Workshop/Salvager and Incinerator/Deeper/Ops retain their accepted geometry and bindings. Save schema and service rules remain at their accepted settings.

### Technical verification

| Check | Result |
| --- | --- |
| `logistics_wing_geometry_tests` | New Slice 5 assertions failed against the accepted scene and passed after the edit. Exit 1 still reports two inherited assertions for a former direct-wing launch UID and the old 46-host fixture. |
| `wing_gameplay_navigation_tests` | 12/12 routes, including the A shelf path around the rack's south end. Exit 0. |
| `wing_storage_bridge_interaction_tests` | Storage identity, transfer, orientation and attached upper-shelf interaction checks passed. Exit 0. |
| `wing_startup_parity_tests` | Configured F5 shell resolved the continuing wing and its current declarations and storage. Exit 0 with isolated saves. |
| `logistics_wing_capture_tests`, `logistics_wing_traversal_tests`, `wing_gameplay_capture_tests` | Capture and traversal definition suites passed. Exit 0 each. |
| Greybox physical traversal replay | 23/23 routes and 13/14 boundary drives. All northern drives passed, including the shared Sorting wall, two staffed-core closures and Kitchen turn. Exit 1 for the inherited Salvager probe below. |

The extended replay's `salvager_machine_end` drive started at Z +17.8666 and collided after 0.16 m in both the accepted live checkout and the candidate. It reached only Z +18.027 against the +18.2166 limit. The existing probe requires more than 0.40 m of travel before the collision, so it reports failure in both states. The authoring geometry and that probe were left as accepted. Headless runs also emitted the inherited Windows `Failed to read the root certificate store` diagnostic. Native pickup and Continue repeated the inherited Compatibility `Parameter "material" is null` messages at `material_casts_shadows`, `material_is_animated`, `material_get_instance_shader_parameters` and `material_update_dependency`. [Raw logs](<C:/Users/Boschetar/.codex/attachments/Sorting_Apocalypse_Assessments/2026-11-14-compact-bunker-layout/slice-5/logs>) · [Greybox traversal results](<C:/Users/Boschetar/.codex/attachments/Sorting_Apocalypse_Assessments/2026-11-14-compact-bunker-layout/slice-5/traversal_results.json>)

The headless checks used the executable `D:/AI Tools/Godot-4.7-Codex/Godot_v4.7-stable_win64_console.exe` against `C:/Users/Boschetar/Documents/ChatGPT/Sorting Apocalypse - Prototype/.slice2-work/authoring`. The two variables in these commands refer to those paths. The first form was used for each named suite above. Startup parity also received the isolated save argument shown. The native command used an isolated profile and Dummy audio. The first wall ray hit the installed A shelf. The final run sampled above the shelf at Y 3.15 and hit the east face of both structural owners at X −4.85.

```powershell
& $Godot --headless --path $ValidationProject --script res://tools/asset_pipeline/tests/<suite>.gd
& $Godot --headless --path $ValidationProject --script res://tools/asset_pipeline/tests/wing_startup_parity_tests.gd -- '--m1-save-dir=C:/Users/Boschetar/.codex/attachments/Sorting_Apocalypse_Assessments/2026-11-14-compact-bunker-layout/slice-5/verification-profile/startup-parity'
& $Godot --headless --fixed-fps 60 --path $ValidationProject res://greybox/logistics_wing/wing_traversal.tscn -- --traversal-evidence
& $Godot --path $ValidationProject --rendering-method gl_compatibility --resolution 1600x900 --single-window --audio-driver Dummy --script 'C:/Users/Boschetar/Documents/ChatGPT/Sorting Apocalypse - Prototype/.slice5-work/walkthrough.gd'
```

### Native walkthrough evidence

The configured F5 shell started a fresh run. Four normal pickups brought the load to 6 Bulk. The player walked 214.83 m through Sorting's entrances, A's hall mouth, the south end of the rack, both side openings, the Medical approach and the Kitchen elbow. The eye-height W1 ray was clear from the Sorting work area both before and after Continue. Native views included the roofs and ordinary lighting. [Lift alert](<C:/Users/Boschetar/.codex/attachments/Sorting_Apocalypse_Assessments/2026-11-14-compact-bunker-layout/slice-5/sorting-lift-alert.png>) · [A to B](<C:/Users/Boschetar/.codex/attachments/Sorting_Apocalypse_Assessments/2026-11-14-compact-bunker-layout/slice-5/gallery-a-to-b.png>) · [Medical approach](<C:/Users/Boschetar/.codex/attachments/Sorting_Apocalypse_Assessments/2026-11-14-compact-bunker-layout/slice-5/medical-approach.png>) · [Kitchen from B](<C:/Users/Boschetar/.codex/attachments/Sorting_Apocalypse_Assessments/2026-11-14-compact-bunker-layout/slice-5/kitchen-from-gallery-b.png>)

Ordinary placement and pickup changed and restored the collection total at A's shelf, the upper rack and B's shelf while retaining exact identities. The player attached to the independent ladder with 6 Bulk, climbed to Y 1.18 for the top shelf, then descended and released onto A's floor. [A shelf](<C:/Users/Boschetar/.codex/attachments/Sorting_Apocalypse_Assessments/2026-11-14-compact-bunker-layout/slice-5/gallery-a-west-shelf.png>) · [Rack and ladder](<C:/Users/Boschetar/.codex/attachments/Sorting_Apocalypse_Assessments/2026-11-14-compact-bunker-layout/slice-5/gallery-a-rack-ladder.png>) · [B shelf](<C:/Users/Boschetar/.codex/attachments/Sorting_Apocalypse_Assessments/2026-11-14-compact-bunker-layout/slice-5/gallery-b-north-shelf.png>)

F opened the real read-only Medical panel and the Kitchen service panel. The witness advanced the existing timeline to the run's first scheduled Kitchen demand at 210 active seconds. A normal E submission consumed the selected Canned Potatoes, credited 3 Food with 0 waste, and changed the outstanding lanes from 40 Food / 32 Hydration to 37 / 32. The test used the current Kitchen coefficients. [Medical panel](<C:/Users/Boschetar/.codex/attachments/Sorting_Apocalypse_Assessments/2026-11-14-compact-bunker-layout/slice-5/medical-panel.png>) · [Kitchen receipt](<C:/Users/Boschetar/.codex/attachments/Sorting_Apocalypse_Assessments/2026-11-14-compact-bunker-layout/slice-5/kitchen-contribution.png>)

Save & Exit in Gallery B and Continue restored the schema-11 pose and facing, both carried identities and 4 Bulk, the Book 01 item on B's second shelf with its exact placement and Morale total of 8, and the Kitchen receipt. The player then crossed the B hall mouth and the shared floor seam and walked back into Sorting. [Native log](<C:/Users/Boschetar/.codex/attachments/Sorting_Apocalypse_Assessments/2026-11-14-compact-bunker-layout/slice-5/logs/native.log>)

The centered A/B apertures give a clear eye-height line to B. The retained Kitchen elbow reads as an end wall from B under ordinary lighting. Its north leg comes into view at the turn. The Medical corridor reveals part of the frontage and the rest comes into view on entering the room.

### Developer walkthrough

1. Start a New Run with the isolated launcher and pick up a few items in Sorting. Look west from just south of the desk toward the lift alert. Use Sorting's east doorway into the hall.
2. Enter A through the new mouth. Follow the common wall toward A's west shelf, take the route around the rack's south end and use the independent ladder from its east side. Store and retrieve something from the rack before descending.
3. Cross the centered A/B apertures and try B's north shelf. Walk north out of the shared junction to Medical. From B's east opening follow the elbow to Kitchen. Press F at each frontage.
4. Save & Exit in B with one item on a shelf and other items carried. Continue and return through B's hall mouth to Sorting. Review the new room proportions and sightlines in ordinary lighting.

[Isolated walkthrough launcher](<C:/Users/Boschetar/.codex/attachments/Sorting_Apocalypse_Assessments/2026-11-14-compact-bunker-layout/slice-5/Play-Slice-5.ps1>) · [Slice 5-only patch](<C:/Users/Boschetar/.codex/attachments/Sorting_Apocalypse_Assessments/2026-11-14-compact-bunker-layout/slice-5/slice-5.patch>)

### Slice 5 developer acceptance

The developer completed an issue-free Slice 5 walkthrough and confirmed conformance with the approved brief. Slices 1–5 are the accepted local baseline. The preceding entries retain the technical results recorded before that walkthrough.

## Slice 6 · Medical approach · 15 November 2026

**Local walkthrough candidate.** Authoring project `D:/Godot Projects/Sorting-apoc-PROTOTYPE`, on `main` at `4e12a235d858e7357b931813a61b51d9356e8d34`. All 20 existing dirty paths in the live checkout and asset-equipped validation copy matched the accepted Slice 5 postimages. No Godot editor or importer was active at preflight. Godot `4.7.stable.official.5b4e0cb0f`, Compatibility and Jolt. Execution used the existing Codex GPT-6 session. Exact model variant and reasoning effort were not exposed. [Accepted Slices 1–5 checkpoint](<C:/Users/Boschetar/.codex/attachments/Sorting_Apocalypse_Assessments/2026-11-14-compact-bunker-layout/slice-6/accepted-slices-1-5.patch>) · [Slice 6-only delta](<C:/Users/Boschetar/.codex/attachments/Sorting_Apocalypse_Assessments/2026-11-14-compact-bunker-layout/slice-6/slice-6.patch>)

### Measured Medical geometry

| Element | X bounds (m) | Slice 5 Z (m) | Slice 6 Z (m) |
| --- | --- | --- | --- |
| Corridor floor and roof | +3.80…+6.20 | −19.50…−9.50 | −14.50…−9.50 |
| Support-room floor and roof | −1.60…+6.20 | −26.50…−19.50 | −21.50…−14.50 |
| Staffed-core wall axis | −1.60…+6.20 | −26.50 | −21.50 |
| Interface and inherited target center | +2.30 | −25.65 | −20.65 |
| MedicalTuning light center | +2.30 | −23.00 | −18.00 |

The corridor is **5.00 × 2.40 m nominal**, with its shared-junction mouth fixed at Z −9.50. The corridor and both mouths measure **2.10 m clear**, from X +3.95 to +6.05. The room retains its **7.80 × 7.00 m** footprint, southeast entry, westward widening and east wall axis at X +6.20. Finished floor is Y 0, with 3.40 m clear height and 0.30 m structure.

The corridor walls butt into the fixed shared shoulders at Z −9.65. At the new room end, the west corridor wall butts into the room shoulder at Z −14.35. The east segments meet face-to-face at Z −14.50. The room shoulder also butts into the room west wall. Floor and roof meet the room at Z −14.50. The old corridor divider inside the widening and the retired north-only footprint cleared the collision probes.

The room floor, roof, side walls, staffed-core closure, interface, Medical anchors and labels, and MedicalTuning light move 5.00 m south. The shoulder is refitted at its new seam. The runtime interaction target inherits its placement from the visual proxy. The shared MedicalKitchen light retains its accepted settings and pose. Verification matched 903 protected scene nodes and their resources, all 35 non-Medical floor positions, Kitchen's Z −7.80 attachment, all four qualifying storage installations, 16 surfaces, 3,463 cells, the independent ladder, four tables and 44 seed hosts and registrations. [Saved geometry measurements](<C:/Users/Boschetar/.codex/attachments/Sorting_Apocalypse_Assessments/2026-11-14-compact-bunker-layout/slice-6/logs/structure.log>) · [Census comparison](<C:/Users/Boschetar/.codex/attachments/Sorting_Apocalypse_Assessments/2026-11-14-compact-bunker-layout/slice-6/logs/preservation.log>)

### Comparable loaded walk and native proof

Both fresh runs used the same four pickups, 6 Bulk, and ordinary W input without sprint. The measured start was (4.9928, 0.0009, −8.2643) in the shared junction in both runs. The interface stance ended 2.1304 m south of the room's north wall, with X +2.2955 in both runs. Distance accumulated on walking physics steps. Elapsed physics time includes the same waypoint settling.

| Shared stance to interface | Distance | Physics time |
| --- | --- | --- |
| Accepted Slice 5 | 16.51 m | 4.90 s |
| Slice 6 candidate | 11.51 m | 3.65 s |

All ten floor and ceiling samples hit their intended owners, including both mouths, the former divider and the room corners. The actual staffed-core collider stopped the player at Z −21.0091. F opened the read-only Medical panel and Escape closed it with all carried identities intact. Save & Exit inside Medical followed by schema-11 Continue restored position, body and camera facing, collection totals and the exact four carried identities. F reopened Medical after Continue and the player walked out to the shared junction. The frontage is partly visible from the approach. Its interaction prompt is readable from inside the room. [Before walk](<C:/Users/Boschetar/.codex/attachments/Sorting_Apocalypse_Assessments/2026-11-14-compact-bunker-layout/slice-6/logs/native-before.log>) · [Candidate walk](<C:/Users/Boschetar/.codex/attachments/Sorting_Apocalypse_Assessments/2026-11-14-compact-bunker-layout/slice-6/logs/native.log>) · [North-up](<C:/Users/Boschetar/.codex/attachments/Sorting_Apocalypse_Assessments/2026-11-14-compact-bunker-layout/slice-6/medical-north-up.png>) · [Approach](<C:/Users/Boschetar/.codex/attachments/Sorting_Apocalypse_Assessments/2026-11-14-compact-bunker-layout/slice-6/medical-approach.png>) · [Room frontage](<C:/Users/Boschetar/.codex/attachments/Sorting_Apocalypse_Assessments/2026-11-14-compact-bunker-layout/slice-6/medical-room.png>) · [Medical panel](<C:/Users/Boschetar/.codex/attachments/Sorting_Apocalypse_Assessments/2026-11-14-compact-bunker-layout/slice-6/medical-panel.png>)

### Verification

- Geometry exit 1. The new Medical assertions failed on the accepted layout and passed on the candidate. The two inherited assertions concern the former direct-wing launch UID and the former 46-host fixture.
- Gameplay navigation exit 0 with 12/12 routes. Startup parity, the greybox capture contract and the traversal contract each returned 0. The startup check used an isolated save directory.
- The review replay returned 1 with 23/23 routes and 13/14 boundary drives. Both Medical routes and the staffed-core drive passed. The inherited Salvager probe again stopped after about 0.16 m against its greater-than-0.40 m travel requirement.
- The native before and candidate witnesses both returned 0. Windows repeated the inherited root certificate store message. Native pickup and Continue emitted the inherited Compatibility null-material messages from `material_casts_shadows`, `material_is_animated`, `material_get_instance_shader_parameters` and `material_update_dependency`. [Raw logs](<C:/Users/Boschetar/.codex/attachments/Sorting_Apocalypse_Assessments/2026-11-14-compact-bunker-layout/slice-6/logs>)

The measured runs and headless sweep used `D:/AI Tools/Godot-4.7-Codex/Godot_v4.7-stable_win64_console.exe` as `$Godot` and `C:/Users/Boschetar/Documents/ChatGPT/Sorting Apocalypse - Prototype/.slice2-work/authoring` as `$Project`. `$Suite` selected each named geometry, navigation, startup, capture or traversal script. The native witness used separate `accepted` and `candidate` values for `SA_SLICE6_STATE` and isolated profiles.

```powershell
& $Godot --headless --path $Project --script "res://tools/asset_pipeline/tests/$Suite.gd"
& $Godot --headless --path $Project --script res://tools/asset_pipeline/tests/wing_startup_parity_tests.gd -- '--m1-save-dir=C:/Users/Boschetar/.codex/attachments/Sorting_Apocalypse_Assessments/2026-11-14-compact-bunker-layout/slice-6/validation-profile/startup-parity'
& $Godot --headless --fixed-fps 60 --path $Project res://greybox/logistics_wing/wing_traversal.tscn -- --traversal-evidence
& $Godot --path $Project --rendering-method gl_compatibility --resolution 1600x900 --single-window --audio-driver Dummy --script 'C:/Users/Boschetar/Documents/ChatGPT/Sorting Apocalypse - Prototype/.slice6-work/walkthrough.gd'
```

### Developer walkthrough

Start a New Run with a few items carried. Enter Medical from the shared A/B junction. Cross both ends of the shorter corridor, turn west into the room and check its floor, ceiling and wall joins. Open Medical with F. Save & Exit in the room, Continue, reopen Medical and walk back to the galleries. [Isolated PowerShell launcher](<C:/Users/Boschetar/.codex/attachments/Sorting_Apocalypse_Assessments/2026-11-14-compact-bunker-layout/slice-6/Play-Slice-6.ps1>)

### Slice 6 developer acceptance

The developer completed an issue-free Slice 6 walkthrough and confirmed conformance with its brief. Slices 1–6 are the accepted local baseline. The earlier candidate entries preserve the technical results recorded before human acceptance.

## Slice 7 · Straight Kitchen approach · 15 November 2026

**Local walkthrough candidate.** Authoring project `D:/Godot Projects/Sorting-apoc-PROTOTYPE`, `main` at `4e12a235d858e7357b931813a61b51d9356e8d34`. All 20 previously dirty paths matched the accepted Slice 6 state in the live checkout and asset-equipped validation copy. No editor or import process was active at preflight. Godot `4.7.stable.official.5b4e0cb0f`, Compatibility and Jolt. [Accepted Slices 1–6 checkpoint](<C:/Users/Boschetar/.codex/attachments/Sorting_Apocalypse_Assessments/2026-11-14-compact-bunker-layout/slice-7/accepted-slices-1-6.patch>) · [Slice 7-only delta](<C:/Users/Boschetar/.codex/attachments/Sorting_Apocalypse_Assessments/2026-11-14-compact-bunker-layout/slice-7/slice-7.patch>)

### Geometry and fit

| Element | Accepted Slice 6 | Slice 7 |
| --- | --- | --- |
| B-east attachment axis and center | X +14.50 / Z −7.80 | X +14.50 / Z −7.80 |
| East-going floor and roof | X +14.50…+24.40, Z −9.20…−6.40 | X +14.50…+20.535, Z −9.20…−6.40 |
| North-going leg floor and roof | X +21.60…+24.40, Z −19.00…−9.20 | Retired with its two side walls and colliders |
| Room floor and roof | X +19.40…+29.90, Z −26.00…−19.00 | X +20.535…+27.535, Z −11.40…−0.90 |
| Staffed-core boundary | North at Z −26.00 | East at X +27.535 |

The measured straight-before-elbow length was 7.10 m. The new straight corridor is **6.035 × 2.80 m nominal**, with **2.50 m clear** at both mouths between Z −9.05 and −6.55. It uses the accepted B attachment with **0.00 m additional north shift**. The unchanged **73.50 m²** room rotated 90 degrees clockwise to **7.00 × 10.50 m**. Its west portal center sits 3.60 m from the north wall axis and 6.90 m from the south wall axis. The floor is Y 0, the clear height is 3.40 m and the structure is 0.30 m thick.

The corridor walls own both portals' end caps. B's existing shoulders and the rotated west shoulders meet those caps at their outer faces. The room's north and south walls cap the east closure, which fills the 10.20 m between their inside faces. The old elbow floor, roof and two wall groups, including 16 scene nodes and eight exclusively referenced resources, were removed. New floor and roof cover the parts of the old elbow inside the rotated room.

The room's measured outer wall and collision bounds are X +20.385…+27.685 and Z −11.55…−0.75. There is **0.30 m wall clearance from Main Storage**, 0.60 m between their slabs, and **0.60 m wall clearance from the current Deeper Approach**. B's outer east wall is 5.735 m west of the room across the attached corridor. Medical's east wall is 8.00 m from the nearest Kitchen corridor wall in X. The later Ops fit sketch still has 1.25 m N–S clearance to its proposed straight link and 1.165 m lateral clearance to its room. The mesh and collider bounds were checked against 63 existing neighboring shapes. [Structure and clearances](<C:/Users/Boschetar/.codex/attachments/Sorting_Apocalypse_Assessments/2026-11-14-compact-bunker-layout/slice-7/logs/structure.log>) · [North-up view](<C:/Users/Boschetar/.codex/attachments/Sorting_Apocalypse_Assessments/2026-11-14-compact-bunker-layout/slice-7/kitchen-north-up.png>)

The interface and its inherited runtime target are now at (+26.685, +0.60, −6.15), 0.85 m west of the east closure axis, with the playable face pointing west. Their local 6.00 × 1.20 × 0.60 m envelope retained its scale. The service and safe-side markers and review label follow their room-relative positions. The shared MedicalKitchen fill at (+15, +2.7, −21) also lights Medical, so its accepted pose and settings were retained. The rotated room is within the StorageEast fill. The frontage is visible from B, though the sign is small and the approach is dim at that distance. The prompt is readable at the counter in ordinary lighting. [From B](<C:/Users/Boschetar/.codex/attachments/Sorting_Apocalypse_Assessments/2026-11-14-compact-bunker-layout/slice-7/kitchen-from-b.png>) · [Corridor](<C:/Users/Boschetar/.codex/attachments/Sorting_Apocalypse_Assessments/2026-11-14-compact-bunker-layout/slice-7/kitchen-straight-corridor.png>) · [Frontage](<C:/Users/Boschetar/.codex/attachments/Sorting_Apocalypse_Assessments/2026-11-14-compact-bunker-layout/slice-7/kitchen-frontage.png>)

The comparison matched 883 protected scene nodes and their referenced resources, all 34 non-Kitchen floors, all four storage units, 16 surfaces, 3,463 cells, the independent ladder, four Sorting tables and 44 seed hosts and registrations. The gameplay scene, environment, service binding, Kitchen rules and player controller matched their accepted files. [Census comparison](<C:/Users/Boschetar/.codex/attachments/Sorting_Apocalypse_Assessments/2026-11-14-compact-bunker-layout/slice-7/logs/preservation.log>)

### Comparable native walk and live service

Both runs started at (+12.7993, +0.0009, −7.9608) in B and carried 6 Bulk from the same four pickup definitions. Ordinary W input drove the player without sprint. Distance accumulated on walking physics steps and elapsed physics time includes waypoint settling. The target stance was 1.38 m from the interface center in its own local frame in both cases. The actual endpoints were 1.292 m and 1.272 m from their respective frontage planes through the center.

| Walk from Gallery B to Kitchen | Distance | Physics time |
| --- | --- | --- |
| Accepted Slice 6 elbow | 25.72 m | 7.22 s |
| Slice 7 straight approach | 12.34 m | 3.85 s |

The initialized scene had one Kitchen target and an empty ray query at the old target location. F from B left the panel closed. F from the normal frontage stance opened it. Eleven pairs of floor and ceiling samples hit their intended owners at the mouths, corridor and room, including the former elbow wall positions. Native movement stopped on the east staffed-core collider at X +27.0445. The new south wall blocked a shortcut into Main Storage.

The witness advanced the existing run clock to its scheduled demand at 289 active seconds. Normal E consumed the carried Canned Potatoes identity once, credited 3 Food with 0 waste, and changed the lanes from 43 Food / 36 Hydration to 40 / 36. The spent identity and a subsequent pistol submission cleared the existing rejection checks without further credit or consumption. Save & Exit inside Kitchen and schema-11 Continue restored pose, body and camera facing, the other three carried identities and 5 Bulk, collection totals, debt and the exact receipt within the same demand window. F reopened Kitchen and the run walked back to B, visited the accepted Medical frontage normally and returned to the shared junction. [Baseline native log](<C:/Users/Boschetar/.codex/attachments/Sorting_Apocalypse_Assessments/2026-11-14-compact-bunker-layout/slice-7/logs/native-accepted.log>) · [Candidate native log](<C:/Users/Boschetar/.codex/attachments/Sorting_Apocalypse_Assessments/2026-11-14-compact-bunker-layout/slice-7/logs/native.log>) · [Kitchen credit](<C:/Users/Boschetar/.codex/attachments/Sorting_Apocalypse_Assessments/2026-11-14-compact-bunker-layout/slice-7/kitchen-contribution.png>)

### Verification

- Geometry exit 1. The new Kitchen assertions rejected the accepted elbow layout and passed on the candidate. The former direct-wing launch UID and old 46-host expectation remain the two inherited failures.
- Gameplay navigation passed all 12 routes. Startup parity, the greybox capture and traversal contracts, and all 23 headless Kitchen interaction checks returned 0. The Kitchen interaction test now aims and moves in the rotated station's frame.
- The focused physical replay passed six checks using the existing controller, including the B-to-Kitchen approach, both Medical directions, the east Kitchen core and south wall, and the Medical closure. The previously recorded Salvager short-travel probe remains part of the Slice 6 evidence.
- Both native witnesses returned 0. Windows repeated the root certificate store diagnostic. Native pickup and Continue repeated the Compatibility null-material diagnostics from `material_casts_shadows`, `material_is_animated`, `material_get_instance_shader_parameters` and `material_update_dependency`. [Raw logs](<C:/Users/Boschetar/.codex/attachments/Sorting_Apocalypse_Assessments/2026-11-14-compact-bunker-layout/slice-7/logs>)

The headless and native checks used `D:/AI Tools/Godot-4.7-Codex/Godot_v4.7-stable_win64_console.exe` as `$Godot` and the asset-equipped validation path `C:/Users/Boschetar/Documents/ChatGPT/Sorting Apocalypse - Prototype/.slice2-work/authoring` as `$Project`. Native used separate `SA_SLICE7_STATE` values and isolated profiles.

```powershell
& $Godot --headless --path $Project --script "res://tools/asset_pipeline/tests/$Suite.gd"
& $Godot --headless --path $Project --script res://tools/asset_pipeline/tests/wing_startup_parity_tests.gd -- '--m1-save-dir=C:/Users/Boschetar/.codex/attachments/Sorting_Apocalypse_Assessments/2026-11-14-compact-bunker-layout/slice-7/validation-profile/startup-parity'
& $Godot --headless --fixed-fps 60 --path $Project --script 'C:/Users/Boschetar/Documents/ChatGPT/Sorting Apocalypse - Prototype/.slice7-work/focused-traversal.gd'
& $Godot --path $Project --rendering-method gl_compatibility --resolution 1600x900 --single-window --audio-driver Dummy --script 'C:/Users/Boschetar/Documents/ChatGPT/Sorting Apocalypse - Prototype/.slice7-work/walkthrough.gd'
```

### Developer walkthrough

Carry supplies from Gallery B through the straight passage. Judge the doorway joins and sightline from B, then face the east counter and open Kitchen with F. When demand arrives, use E to offer an eligible item. Save & Exit in Kitchen, Continue, reopen the service and walk back through the passage to B. [Isolated PowerShell launcher](<C:/Users/Boschetar/.codex/attachments/Sorting_Apocalypse_Assessments/2026-11-14-compact-bunker-layout/slice-7/Play-Slice-7.ps1>)

### Slice 7 developer acceptance — 15 November 2026

The developer completed the Slice 7 walkthrough, reported no issues, confirmed conformance with the brief, and personally submitted Food and Hydration to an active Kitchen request. Slices 1–7 form the accepted local baseline.

## Slice 8 — Four galleries and relocated Incinerator

**Candidate installed for the developer walkthrough.** The local source reference is `main` at `4e12a235d858e7357b931813a61b51d9356e8d34`, with 21 accepted local paths at the start of the slice. Validation used the asset-equipped copy and Godot `4.7.stable.official.5b4e0cb0f`, Compatibility and Jolt. The session exposed the Codex GPT-6 family. Exact variant and reasoning effort were unavailable. [Accepted baseline checkpoint](<C:/Users/Boschetar/.codex/attachments/Sorting_Apocalypse_Assessments/2026-11-14-compact-bunker-layout/slice-8/accepted-slices-1-7.patch>)

### Saved geometry

| Piece | Accepted Slice 7 | Slice 8 candidate |
| --- | --- | --- |
| Incinerator approach | 4.00 m wide × 5.50 m long from Deeper, at X +34.50…+38.50 and Z +4.50…+10.00 | 4.00 m × 3.00 m directly from Main Storage, at X +19.50…+23.50 and Z +5.80…+8.80. Both mouths and the corridor are 3.70 m clear. |
| Incinerator pocket | 7.00 × 7.00 m at X +33.00…+40.00 and Z +10.00…+17.00 | 7.00 × 7.00 m at X +18.00…+25.00 and Z +8.80…+15.80. The wall faces give 6.70 × 6.70 m. |
| Machine and front marker | Centers (+36.50, +1.45, +14.75) and (+36.50, +0.05, +12.40) | Centers (+21.50, +1.45, +13.55) and (+21.50, +0.05, +11.20). The machine retains its 6.20 × 2.90 × 3.50 m envelope, north-facing front at Z +11.80 and original interaction body. |

The chosen X +21.50 center fits the saved scene. The new branch retains floor Y 0, 3.40 m clear height and 0.30 m structure. The hall stays 5.80 m clear with a 3.00 m eastern opening. Measured outer faces give a 2.20 m gap to Gallery D and 6.40 m on Z to Kitchen. The branch clears current Deeper and Ops geometry. Against the recorded future sketch it has 1.55 m on Z to the link and 3.70 m on X to the Ops room. The former spur now meets a continuous south wall on Z +4.50, spanning X +26.15…+42.85 between the existing returns. [Saved mesh and collider measurements](<C:/Users/Boschetar/.codex/attachments/Sorting_Apocalypse_Assessments/2026-11-14-compact-bunker-layout/slice-8/logs/geometry-measurements.log>)

Removed Gallery E's district, two floors, two ceilings, five walls, anchor and review label. The two E-only shelf envelopes and low island were removed with their meshes and colliders. This retired 50 saved geometry nodes and 24 resources. The old spur wall consolidation retired four further nodes and two resources. The Incinerator target and marker kept their unique IDs. The comparison verified 816 untouched saved node blocks and no positive collision overlap between the new branch and 63 nearby protected shapes. The storage census matched four qualifying units, 16 surfaces, 3,463 cells, one independent ladder, four Sorting tables and 44 seed hosts and registrations, including their identities and poses. [Census comparison](<C:/Users/Boschetar/.codex/attachments/Sorting_Apocalypse_Assessments/2026-11-14-compact-bunker-layout/slice-8/logs/census-preservation.log>)

### Walk and live service

Identical ordinary W walks with four normal pickups and 6 Bulk began after settling at X +18.134, Z +2.500. The accepted route took **7.667 s over 27.60 m** and ended at X +36.500, Z +12.517. The new route took **3.367 s over 10.44 m** and ended at X +21.500, Z +11.288. Those positions put the player 0.483 m and 0.512 m from the corresponding machine face. Both native runs exited 0. [Baseline native log](<C:/Users/Boschetar/.codex/attachments/Sorting_Apocalypse_Assessments/2026-11-14-compact-bunker-layout/slice-8/logs/native-before.log>) · [Candidate native log](<C:/Users/Boschetar/.codex/attachments/Sorting_Apocalypse_Assessments/2026-11-14-compact-bunker-layout/slice-8/logs/native-candidate.log>)

F opened the original service at the new frontage. At the hall mouth F was rejected out of range. The interaction suite confirmed the west wall intercepted a ray whose reach was sufficient to hit the machine. The first E showed the one-time warning. Escape selected Back and spent nothing. The next deliberate E spent only the selected Canned Potatoes identity, reducing 6 Bulk to 5 and recording one receipt. Held and repeated input left the other three identities intact. The captured item map and collection state verified zero output and zero goal credit or deduction. Schema-11 Save & Exit and Continue restored the pose, facing, retained identities, warning, receipt and collection state. The player reopened the panel, walked out, entered Gallery D, and went to Ops and back with the remaining 5 Bulk. A ray from D hit its existing east wall.

The normal-light corridor and machine are dim. The opening, machine silhouette and F prompt are visible in sequence and the warning is legible. The north-up view uses a roof-off diagnostic camera. [North-up plan](<C:/Users/Boschetar/.codex/attachments/Sorting_Apocalypse_Assessments/2026-11-14-compact-bunker-layout/slice-8/incinerator-north-up.png>) · [Hall mouth](<C:/Users/Boschetar/.codex/attachments/Sorting_Apocalypse_Assessments/2026-11-14-compact-bunker-layout/slice-8/incinerator-from-storage.png>) · [Corridor](<C:/Users/Boschetar/.codex/attachments/Sorting_Apocalypse_Assessments/2026-11-14-compact-bunker-layout/slice-8/incinerator-corridor.png>) · [F prompt](<C:/Users/Boschetar/.codex/attachments/Sorting_Apocalypse_Assessments/2026-11-14-compact-bunker-layout/slice-8/incinerator-frontage.png>) · [Warning](<C:/Users/Boschetar/.codex/attachments/Sorting_Apocalypse_Assessments/2026-11-14-compact-bunker-layout/slice-8/incinerator-warning.png>) · [Closed Deeper spur](<C:/Users/Boschetar/.codex/attachments/Sorting_Apocalypse_Assessments/2026-11-14-compact-bunker-layout/slice-8/closed-deeper-spur.png>)

### Verification and walkthrough files

| Validation | Result |
| --- | --- |
| `logistics_wing_geometry_tests.gd` | Target checks rejected the old scene. The candidate exited 1 with exactly two inherited assertions, `project default launch resolves through the wing gameplay UID` and `promoted scene keeps all 46 seed hosts from checkpoint a263e24`. |
| Gameplay navigation, capture/traversal contracts and startup parity | Exit 0 for each suite. Navigation passed all 13 routes. |
| Incinerator interaction, continuation and operations | Exit 0 with 37, 115 and 29 checks respectively. |
| Focused controller replay and census | Exit 0. All five route/barrier checks passed. The player stopped at Z +4.009 against the former spur and Z +11.459 against the machine. Census and saved/source comparisons passed. |

The suites used `--headless --path $Project --script` with the existing test scripts and an isolated `--m1-save-dir` for startup parity. The Windows root-certificate error and held-item null-material diagnostics recurred. The extended Salvager minimum-travel failure at approximately 0.16 m against a >0.40 m requirement is from Slice 6. The Receiving desk-bounds failures remain historical evidence. The supporting Downloads reference archive became unavailable during work. Placement measurements and rendered views come from the local Godot scene. [Suite exits](<C:/Users/Boschetar/.codex/attachments/Sorting_Apocalypse_Assessments/2026-11-14-compact-bunker-layout/slice-8/logs/suite-exits.log>) · [Raw logs](<C:/Users/Boschetar/.codex/attachments/Sorting_Apocalypse_Assessments/2026-11-14-compact-bunker-layout/slice-8/logs>)

For the walkthrough, launch the isolated profile and choose **New Run**. Walk east through Main Storage and turn south into the new corridor. At the machine, press F, then E with a disposable item selected. Back leaves the item in hand and a later deliberate E spends it. Save and Continue from the pocket to verify the restored state. [Isolated New Run launcher](<C:/Users/Boschetar/.codex/attachments/Sorting_Apocalypse_Assessments/2026-11-14-compact-bunker-layout/slice-8/Play-Slice-8.ps1>) · [Slice 8-only patch](<C:/Users/Boschetar/.codex/attachments/Sorting_Apocalypse_Assessments/2026-11-14-compact-bunker-layout/slice-8/slice-8.patch>)

### Slice 8 developer acceptance — 15 November 2026

The developer completed the Slice 8 walkthrough, reported no issues, confirmed conformance with the brief, and successfully incinerated items in play. Slices 1–8 form the human-accepted local baseline.

## Slice 9 — Short Deeper link and relocated Bunker Ops

**Candidate for the developer walkthrough.** The working source reference is local `main` at `4e12a235d858e7357b931813a61b51d9356e8d34`. The 22 accepted local paths matched the asset-equipped validation copy before edits. The supplied report and Slice 8 patch match the local historical evidence. Verification used Godot `4.7.stable.official.5b4e0cb0f`, Compatibility and Jolt. The session exposed the Codex GPT-6 family. Exact variant and reasoning effort were unavailable. [Accepted Slices 1–8 checkpoint](<C:/Users/Boschetar/.codex/attachments/Sorting_Apocalypse_Assessments/2026-11-14-compact-bunker-layout/slice-9/accepted-slices-1-8.patch>)

### Geometry and lighting

| Owner | Saved and measured result |
| --- | --- |
| Main Storage and link | Storage east doorway stays at X +26.00. The straight floor and roof run X +26.00…+29.00 and Z +0.65…+3.95. The nominal link is 3.00 m long × 3.30 m wide. Both mouths and the entire passage are 3.00 m clear at Z +0.80…+3.80. Floor Y is 0, the ceiling underside is Y +3.40, and side structure is 0.30 m thick. |
| Bunker Ops | The assembly translates (−30.00, 0, +7.80) m. Floor and roof are X +29.00…+36.00, Z −3.20…+5.80. The room retains 7 × 9 m and 63 m² nominal, with 6.70 × 8.70 m between plain inside faces. The offset west doorway aligns with the link. |
| Ops closure owners | The north staffed-core wall is on Z −3.20. The east settlement door has center (+36.00, +1.45, +1.00) and size 0.65 × 2.90 × 2.40 m, with the lintel above it. The 4.00 × 1.20 × 0.60 m Ops placeholder is centered at (+32.50, +0.60, −2.35). Its visual-only behavior, marker facing, component IDs and room-relative positions are retained. |
| Neighbor gaps and footprint | Kitchen to link is 1.25 m on Z, and Kitchen to Ops is 1.165 m on X. The link and Incinerator approach have 1.55 m on Z. The Ops west face and Incinerator pocket east face have 3.70 m on X. The nominal floor footprint is 70.25 × 43.3666 m. The east door projects to X +36.325, beyond the floor edge at +36.00. |

The old wide run, two dog-leg sections and narrow run were replaced by one floor/roof pair and two rails. The Z 0 interior wall, the former spur closure at Z +4.50 and the other old walls are gone. The remote Ops slab, interface and settlement door moved with the assembly. The saved diff retired 44 geometry nodes and 22 resources, retained 772 saved node blocks outside the eastern branch, and verified zero positive volume overlap with 39 protected neighboring shapes. The four new jamb seams meet by face. The centerline audit found 38 remaining wall intersections after six former Deeper intersections were removed. Eleven live floor/roof pairs, both old-wall crossings, three clearance lines and seven retired-footprint samples passed. Rail and west-wall probes confirmed the boundaries toward Kitchen and Incinerator. [Mesh and collider measurements](<C:/Users/Boschetar/.codex/attachments/Sorting_Apocalypse_Assessments/2026-11-14-compact-bunker-layout/slice-9/logs/geometry-measurements.log>) · [Junction comparison](<C:/Users/Boschetar/.codex/attachments/Sorting_Apocalypse_Assessments/2026-11-14-compact-bunker-layout/slice-9/logs/junction-pairs.log>)

The existing `Deeper` fill now serves the link at (+28.00, +2.70, +2.30), with a 3.00 m range. The existing `East` fill serves Ops at (+33.90, +2.70, +1.60), with a 6.50 m range. I reduced those two ranges to contain the moved fills near the eastern branch. Their colors, energy and Fuel bindings are retained. The live scene inherits both moves from the environment, and the review scene matches. StorageEast, MedicalKitchen, MedicalTuning and the other shared lights stayed in place. The Kitchen prompt and Incinerator F prompt are legible under the ordinary lighting. Both frontages remain dim. [Effective lights and service bindings](<C:/Users/Boschetar/.codex/attachments/Sorting_Apocalypse_Assessments/2026-11-14-compact-bunker-layout/slice-9/logs/candidate-census.log>) · [Kitchen](<C:/Users/Boschetar/.codex/attachments/Sorting_Apocalypse_Assessments/2026-11-14-compact-bunker-layout/slice-9/kitchen-frontage.png>) · [Incinerator frontage](<C:/Users/Boschetar/.codex/attachments/Sorting_Apocalypse_Assessments/2026-11-14-compact-bunker-layout/slice-9/incinerator-frontage.png>)

### Loaded walk and continuation

Four ordinary pickups gave 6 Bulk in each run. Both walks began at settled X +18.134, Z +2.500 and used ordinary W with physics timing, including waypoint settling. The accepted route covered **51.81 m in 14.450 s** and ended 1.552 m from the Ops interface center on Z. The short route covered **16.54 m in 4.900 s** and ended 1.519 m from the corresponding center. Both native runs exited 0. [Accepted walk](<C:/Users/Boschetar/.codex/attachments/Sorting_Apocalypse_Assessments/2026-11-14-compact-bunker-layout/slice-9/logs/native-before.log>) · [Candidate walk](<C:/Users/Boschetar/.codex/attachments/Sorting_Apocalypse_Assessments/2026-11-14-compact-bunker-layout/slice-9/logs/native-candidate.log>)

The loaded player stopped against the staffed core at Z −2.709 and the separate settlement door at X +35.333. Save & Exit beside the door and schema-11 Continue restored player and camera facing, position, all four carried identities, 6 Bulk, collection totals and the saved service states. The return passed through the new link and the Incinerator frontage, where F and Escape opened and closed the original panel. The same loaded run traversed C to D, the shared A/B junction, Medical, and Kitchen. From Sorting the eye-height ray reached the W1 lift-alert lens. The census matched four qualifying units, 16 surfaces, 3,463 cells, one ladder, four Sorting tables, and 44 seed hosts and registrations. Comparison also covered 29 protected floor records, including Workshop, Salvager and Receiving/Dispatch. The Fuel target remains on the Receiving cabinet. [Census comparison](<C:/Users/Boschetar/.codex/attachments/Sorting_Apocalypse_Assessments/2026-11-14-compact-bunker-layout/slice-9/logs/census-preservation.log>) · [Sorting lift sightline](<C:/Users/Boschetar/.codex/attachments/Sorting_Apocalypse_Assessments/2026-11-14-compact-bunker-layout/slice-9/sorting-lift-alert.png>)

### Verification and handoff

| Check | Result |
| --- | --- |
| Geometry | The new expectations rejected the accepted dog-leg. The final suite exited 1 with the two inherited assertions `project default launch resolves through the wing gameplay UID` and `promoted scene keeps all 46 seed hosts from checkpoint a263e24`. |
| Gameplay navigation, greybox capture/traversal definitions, gameplay capture definitions, startup parity | Exit 0 for each. Navigation passed all 13 routes. |
| Focused controller replay, initialized census and native New Run/Continue | Exit 0. Seven focused route/barrier checks passed. Same-state saved-scene and census comparisons passed. |

The Windows root-certificate and held-item material diagnostics recurred. The Salvager minimum-travel result of roughly 0.16 m against a >0.40 m requirement dates to Slice 6. The Receiving desk-bounds results remain historical. [Suite exits](<C:/Users/Boschetar/.codex/attachments/Sorting_Apocalypse_Assessments/2026-11-14-compact-bunker-layout/slice-9/logs/suite-exits.log>) · [Raw logs](<C:/Users/Boschetar/.codex/attachments/Sorting_Apocalypse_Assessments/2026-11-14-compact-bunker-layout/slice-9/logs>)

| Location | Changed files |
| --- | --- |
| [Greybox sources](<D:/Godot Projects/Sorting-apoc-PROTOTYPE/greybox/logistics_wing>) | `build_wing_geometry.gd`, `wing_geometry.tscn`, `wing_review.tscn`, `wing_capture.gd`, `wing_traversal.gd` |
| [Gameplay sources](<D:/Godot Projects/Sorting-apoc-PROTOTYPE/gameplay/logistics_wing>) | `wing_environment.tscn`, `wing_gameplay.tscn`, and [gameplay capture](<D:/Godot Projects/Sorting-apoc-PROTOTYPE/gameplay/logistics_wing/review/wing_gameplay_capture.gd>) |
| [Tests](<D:/Godot Projects/Sorting-apoc-PROTOTYPE/tools/asset_pipeline/tests>) | `logistics_wing_geometry_tests.gd`, `logistics_wing_capture_tests.gd`, `logistics_wing_traversal_tests.gd`, `wing_gameplay_capture_tests.gd`, `wing_gameplay_navigation_tests.gd` |
| [Testing record](<D:/Godot Projects/Sorting-apoc-PROTOTYPE/docs/testing/2026-11-14-compact-bunker-layout-result.md>) | `2026-11-14-compact-bunker-layout-result.md` |

[Slice 9-only patch](<C:/Users/Boschetar/.codex/attachments/Sorting_Apocalypse_Assessments/2026-11-14-compact-bunker-layout/slice-9/slice-9.patch>)

Choose **New Run** in the isolated launcher. Carry a load east from Main Storage into Ops, try both barriers, save and continue inside Ops, then turn south to the Incinerator and return to the galleries. [Isolated New Run launcher](<C:/Users/Boschetar/.codex/attachments/Sorting_Apocalypse_Assessments/2026-11-14-compact-bunker-layout/slice-9/Play-Slice-9.ps1>) · [Roof-off north-up plan](<C:/Users/Boschetar/.codex/attachments/Sorting_Apocalypse_Assessments/2026-11-14-compact-bunker-layout/slice-9/slice-9-north-up.png>) · [Short link](<C:/Users/Boschetar/.codex/attachments/Sorting_Apocalypse_Assessments/2026-11-14-compact-bunker-layout/slice-9/ops-short-link.png>) · [Ops frontage and north wall](<C:/Users/Boschetar/.codex/attachments/Sorting_Apocalypse_Assessments/2026-11-14-compact-bunker-layout/slice-9/ops-frontage.png>) · [East closure](<C:/Users/Boschetar/.codex/attachments/Sorting_Apocalypse_Assessments/2026-11-14-compact-bunker-layout/slice-9/ops-east-settlement-door.png>) · [Incinerator junction](<C:/Users/Boschetar/.codex/attachments/Sorting_Apocalypse_Assessments/2026-11-14-compact-bunker-layout/slice-9/incinerator-junction.png>)


### Slice 9 developer acceptance and whole-layout promotion — 15 November 2026

The developer completed the Slice 9 gameplay walkthrough without reporting an issue, confirmed conformance with the plan, and accepted all nine slices as the completed compact bunker rebuild. Later texturing, lighting, furnishing and playtesting may motivate small local changes. The accepted layout is the baseline for that work.

The close-out compared the accepted source and results against the installed Slice 9 postimages and reused the documented gameplay evidence. Documentation alignment and publication to the existing main branch were authorized. [Acceptance and publication record](../design_history/2026-11-15-compact-bunker-layout-acceptance-and-publication.md).
