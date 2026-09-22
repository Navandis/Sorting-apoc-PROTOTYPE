# Fixed-Ladder Proof Validation and Human Playtest Handoff

**Feature:** Single-rack fixed-ladder proof  
**Status:** TECHNICALLY VERIFIED / HUMAN REVIEW PENDING  
**Date:** 22 September 2026  
**Feature branch:** `codex/fixed-ladder-proof`  
**Implementation checkpoint:** `e7e8036e718a477025cce22ea152c91b7ffc27c4`  
**Godot:** `4.7.stable.official.5b4e0cb0f`

This record must not be changed to PROMOTE until the developer completes the human playtest and makes a PROMOTE / REVISE decision.

## Implemented scope

- reusable standalone `FixedLadder`, independent of storage families;
- per-instance `ladder_height_m`, `overhead_limit_local_y_m`, and editor preview control;
- scene-local source-asset normalization beneath a common `0.42 m × 0.14 m` functional envelope, so another normalized skin does not require gameplay-code changes;
- one rectangular movement body and one shallow bottom/front approach area, both separate from item and storage interaction layers;
- bounded player `NORMAL` / `LADDER_ATTACHED` movement branch on the existing `CharacterBody3D` and camera;
- front-side/facing/forward-intent attachment; side crossing and overlap alone do not attach;
- fixed climb line, W/S vertical motion, release-to-hold, no A/D motion, and no sprint modifier while attached;
- retained pitch and wrap-safe ladder-relative yaw clamp;
- body- and eye-derived top stop using the lower of the visual target and authored overhead safety target;
- no top dismount; bottom release resumes normal S movement and suppresses reattachment until approach-area exit;
- carried identity and existing pickup/storage/HUD/zoning paths remain intact; zoning holds exact attached position;
- WorldItem and StorageSurface rays pass through ladder movement collision through existing layer separation;
- separate taller functional `ModularRack_LadderProof` and `FixedLadder_LadderProof` in the retained shelf-ergonomics review scene.

Approved-plan deviations: none.

## Files changed

Implementation checkpoint paths:

```text
gameplay/logistics_wing/review/shelf_ergonomics/shelf_ergonomics_review.tscn
gameplay/traversal/fixed_ladder/fixed_ladder.gd
gameplay/traversal/fixed_ladder/fixed_ladder.gd.uid
gameplay/traversal/fixed_ladder/fixed_ladder.tscn
player_controller.gd
tools/asset_pipeline/tests/fixed_ladder_authoring_tests.gd
tools/asset_pipeline/tests/fixed_ladder_authoring_tests.gd.uid
tools/asset_pipeline/tests/fixed_ladder_player_tests.gd
tools/asset_pipeline/tests/fixed_ladder_player_tests.gd.uid
tools/asset_pipeline/tests/shelf_ergonomics_review_tests.gd
```

Delivery documentation also includes the approved design, approved implementation plan, supplied validation template, and this record. `shelf_ergonomics_review.gd`, `project.godot`, and `wing_gameplay.tscn` did not require changes.

## Proof installation values

| Property | Value |
| --- | ---: |
| Proof rack | `ReviewFixtures/ModularRack_LadderProof` |
| Rack length / depth / frame | `3.60 / 0.82 / 3.00 m` |
| Shelf support Y values | `0.30 / 1.05 / 1.82 / 2.55 m` |
| Ladder | `ReviewFixtures/FixedLadder_LadderProof` |
| Ladder height | `2.85 m` |
| Common functional width / depth | `0.42 / 0.14 m` |
| Ladder placement relative to rack | local `+Z 0.52 m`; world `+X 0.52 m`, same Z |
| Player standoff | `0.46 m` |
| Approach width / depth / height | `0.90 / 0.62 / 1.85 m` |
| Climb speed | `1.65 m/s` |
| Yaw clamp | `±80°` |
| Top-view margin | `0.10 m` |
| Ceiling-safety margin | `0.04 m` |
| Authored overhead limit | `3.40 m` |

These are proof values and tuning handles, not promoted production constants.

## Automated verification

The final bounded sweep ran from repository root with:

```powershell
$godot = 'D:\AI Tools\Godot-4.7-Codex\Godot_v4.7-stable_win64_console.exe'
& $godot --headless --path . --script res://tools/asset_pipeline/tests/fixed_ladder_authoring_tests.gd
& $godot --headless --path . --script res://tools/asset_pipeline/tests/fixed_ladder_player_tests.gd
& $godot --headless --path . --script res://tools/asset_pipeline/tests/shelf_ergonomics_review_tests.gd
& $godot --headless --path . --script res://tools/asset_pipeline/tests/modular_rack_authoring_tests.gd
& $godot --headless --path . --script res://tools/asset_pipeline/tests/wing_storage_bridge_interaction_tests.gd
& $godot --headless --editor --path . --quit
& $godot --headless --path . --quit-after 120
```

Results on `e7e8036e718a477025cce22ea152c91b7ffc27c4`:

| Check | Result |
| --- | --- |
| `fixed_ladder_authoring_tests.gd` | PASS, exit 0 |
| `fixed_ladder_player_tests.gd` | PASS, exit 0 |
| `shelf_ergonomics_review_tests.gd` | PASS A/B/C, exit 0; 15 surfaces = 8 legacy + 3 starter + 4 proof |
| `modular_rack_authoring_tests.gd` | PASS, exit 0 |
| `wing_storage_bridge_interaction_tests.gd` | PASS, exit 0; continuing gameplay retains 12 surfaces |
| Headless editor scan | exit 0; `FixedLadder` global class registered |
| Default project smoke, no explicit scene | exit 0; continuing gameplay installed 12 surfaces, F6 OFF, F7 disabled |

`project.godot` still selects UID `uid://bljf1nlhijej`, resolving to `res://gameplay/logistics_wing/wing_gameplay.tscn`. The 15-surface ladder proof remains review-scene-only.

## Interaction-layer verification

`fixed_ladder_player_tests.gd` places the real ladder movement body between the real player camera and each target, proves a movement-body ray hits the ladder, and then exercises the production interaction queries.

```text
Ladder movement collider blocks ordinary player movement: YES
Ladder movement collider participates in WorldItem pickup ray: NO
Ladder movement collider participates in StorageSurface ray: NO
ApproachArea overlaps WorldItem pickup layer: NO
ApproachArea overlaps StorageSurface interaction layer: NO
WorldItem pickup ray still reaches the target: YES
StorageSurface ray still reaches the target: YES
```

No ray-piercing system was added.

## Preservation checks

- no ItemDefinition `.tres` changed;
- no storage-orientation, zone, canonical-pose, reservation, stacking, or packing implementation changed;
- no imported GLB/source asset changed;
- `project.godot`, `gameplay/logistics_wing/wing_gameplay.tscn`, and default scene selection are unchanged;
- `ReviewFixtures/ModularRack_Starter` remains the separate three-level ground-access reference;
- existing Metal Shelf, Ventilated Locker, promoted supply reuse, F5 eye toggle, F6 presentation, HUD, and carried-item paths remain exercised by the retained review tests;
- local ignored assets, `.godot`, reports, and import state were not deleted or cleaned.

## Known diagnostics

Every Godot command printed the existing Windows root-certificate-store diagnostic:

```text
ERROR: Failed to read the root certificate store.
```

This is unchanged from existing project records. No additional test, parser, runtime, editor-shutdown, or RID errors appeared in the final sweep.

The read-only live `git ls-remote origin refs/heads/main` preflight could not authenticate through this machine's Windows Git provider (`SEC_E_NO_CREDENTIALS`). Local `main` and the local `origin/main` tracking ref both resolved to `0a33d03dd0e18b26b1b42060e3a040a692ed6050`; no reset, fetch, push, merge, or remote mutation was performed.

## Human review launch

Use the primary 3.40 m proof condition:

```powershell
$godot = 'D:\AI Tools\Godot-4.7-Codex\Godot_v4.7-stable_win64_console.exe'
& $godot --path 'D:\Godot Projects\Sorting-apoc-PROTOTYPE' --rendering-method gl_compatibility 'res://gameplay/logistics_wing/review/shelf_ergonomics/shelf_ergonomics_review.tscn' -- --ergonomics-case=A
```

The proof installation is along Gallery B's west-side run. Turn toward `ModularRack_LadderProof`; approach `FixedLadder_LadderProof` from its aisle/front side.

## Human playtest scenarios

Record PASS / REVISE and notes for each.

### A. Frontal attach and no side capture

1. Approach from the front while holding W; judge attach distance and X/Z correction.
2. Cross the approach region laterally with A/D.
3. Cross while facing sideways.
4. Enter without W.

Expected: frontal W attaches; the other cases do not.

### B. Climb, hold, lateral, sprint, and pitch

While attached, use W, S, release both, try A/D, hold Shift, and climb while looking sharply up/down.

Expected: W/S moves vertically at one speed; release holds exact height; A/D and Shift do not move or accelerate; pitch does not change climb direction or speed.

### C. Yaw and fixed-line usefulness

Inspect both sides and the depth of every proof shelf. Judge whether `±80°` is suitable, whether one fixed line serves enough width/depth, and whether the player still feels attached.

### D. Top stop and ceiling safety

Climb to maximum, keep W held, look up, and inspect the top shelf.

Expected: no further rise, camera/body stay clear of the ceiling, top visibility is useful, and no rack-top dismount occurs.

### E. Bottom release and suppression

Descend while continuing to hold S. Confirm normal backward motion begins, no immediate recapture occurs, and attach becomes available only after leaving and re-entering the approach area.

### F. Pickup, retrieval, auto/manual placement, and packing

At useful ladder heights:

- LMB retrieve through/behind the ladder visual;
- E auto-store and hold-E where useful;
- M manual mode and manual E placement;
- R packing rotation;
- mouse-wheel/number carried selection.

Expected: normal interaction ranges and behavior remain intact; visual rails/rungs do not mechanically block the rays.

### G. HUD and carried state

Attach, climb, and detach with a carried item. Confirm exact carried identity, held-item presentation, selection, and HUD remain coherent.

### H. Zoning while attached

Open zoning for a reachable surface, hold W/S while the modal is open, and close it.

Expected: exact position/height and logical attachment are preserved; ladder movement resumes after close.

### I. Installation judgment

Judge left/right coverage, useful depth, top-shelf visibility, rung/rail visual obstruction, installed-infrastructure readability, and whether the extra capacity is worth the interaction cost. The ladder may be moved modestly left/right in the editor for comparison; do not infer sliding traversal.

## Developer disposition

```text
PROMOTE / REVISE

Date:
Decision notes:
Required corrections, if any:
```

PROMOTE approves this fixed-line architecture only for selected taller installations. It does not approve universal ladder coverage, final ladder dimensions/assets, general climbing, movable/sliding ladders, or shelf-top traversal. REVISE should remain bounded to evidence from the scenarios above unless the fixed-line model itself fails.
