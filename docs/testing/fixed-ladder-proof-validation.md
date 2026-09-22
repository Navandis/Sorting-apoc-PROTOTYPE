# Fixed-Ladder Proof Validation and Human Playtest Handoff

**Feature:** Single-rack fixed-ladder proof  
**Status:** TECHNICALLY VERIFIED / FINAL HUMAN RE-REVIEW PENDING
**Date:** 22 September 2026  
**Feature branch:** `codex/fixed-ladder-proof`  
**Implementation checkpoint:** `e7e8036e718a477025cce22ea152c91b7ffc27c4`  
**Round-1 correction checkpoint:** `c8fd13ff732890efb714613107edcc6e9743b986`
**Round-2 correction checkpoint:** `872cbd1add4f824242648831e211c75895ad3625`
**Round-2 visible-yaw follow-up checkpoint:** `a4fecadceab582e6ef3feb4dddbdf187b606b464`
**Godot:** `4.7.stable.official.5b4e0cb0f`

This record must not be changed to PROMOTE until the developer completes the final focused human re-review and makes a PROMOTE / REVISE decision.

## Human review round 1 — REVISE

**Disposition:** REVISE — bounded tuning; ladder architecture validated.

The human review strongly validated the ladder's gameplay utility, fixed-line model, visual fit, and interaction-through-ladder decision. It did not identify an architectural failure. Four bounded corrections were requested:

1. rotate only the current visual source normalization by 180° yaw so its mounting hooks face the served storage side (`-Z`) while functional approach remains `+Z`;
2. remove the visible attachment jolt by allowing attach only when the player's X/Z is already close to the climb anchor;
3. rearm bottom attachment after a short deliberate back-away inside the outer `ApproachArea`, while continuing to prevent immediate recapture;
4. reduce attached yaw from `±80°` to `±70°` without changing pitch or wrap-safe relative-yaw behavior.

All four are implemented in correction checkpoint `c8fd13ff732890efb714613107edcc6e9743b986`. Fixed-line climbing, storage-family independence, height authoring, interaction-ray behavior, storage range, and all promoted storage systems remain unchanged.

### Correction measurements and behavior

- ladder movement-collision front half-depth: `0.07 m`;
- player capsule radius: `0.34 m`;
- climb-anchor standoff: `0.46 m`;
- resulting collision clearance: `0.05 m`;
- maximum horizontal attach correction: `0.12 m`;
- deterministic accepted test approach correction: `0.0849 m`;
- former outer candidate position exercised by the regression: `0.39 m` from the anchor, now rejected;
- bottom rearm distance: `0.22 m` horizontal from the local climb line;
- regression back-away: `0.24 m`, still overlapping the outer `ApproachArea`, then normal W reapproach and reattachment;
- attached yaw clamp: `±70°`.

Suppression still clears on full outer-area exit as a fallback. Inside the outer area, the next attachment eligibility check clears the rearm requirement once local horizontal distance from the climb line reaches `0.22 m`.

### Visual verification

The current GLB normalization was rotated beneath `Visual/Source`; the `FixedLadder` root, movement collision, approach area, climb anchor, and functional `+Z` front were not flipped. A normal OpenGL compatibility runtime capture confirmed the mounting tabs project toward the rack/storage side in the side view while the aisle view remains the functional approach side.

Local ignored captures (not Git backup):

```text
reports/logistics_wing/fixed_ladder_correction_approach.png
reports/logistics_wing/fixed_ladder_correction_storage.png
reports/logistics_wing/fixed_ladder_correction_hook_side.png
```

### Correction verification

The required bounded sweep ran on the correction checkpoint with the preserved human-authored review-scene working changes present:

| Check | Result |
| --- | --- |
| `fixed_ladder_authoring_tests.gd` | PASS, exit 0; visual source storage-side normalization and unchanged functional `+Z` front |
| `fixed_ladder_player_tests.gd` | PASS, exit 0; `0.0849 m` accepted correction under `0.12 m`, far capture rejected, inner rearm and reattach verified, `±70°` verified |
| `shelf_ergonomics_review_tests.gd` | PASS A/B/C, exit 0; 15 surfaces retained |
| Headless editor scan | exit 0; `FixedLadder` global class registered |
| Default project smoke, no explicit scene | exit 0; continuing gameplay retained 12 surfaces |

Every command retained the existing Windows root-certificate-store diagnostic. No additional parser, runtime, test, or editor error appeared.

The human-authored uncommitted proof-rack/ladder scene adjustments were preserved and excluded from the correction commit. Their added proof-rack collision overlapped the old review entry, so the only ancillary change moves that review-only entry `0.45 m` farther back; this is the allowed small position adjustment needed for stable review and does not alter proof-rack or ladder architecture.

## Human review round 2 — REVISE, minor tuning

The first bounded revision removed the reported attachment jolt and substantially improved bottom reattachment. Round 2 retained the validated architecture and identified three small tuning concerns:

1. the outer `ApproachArea` candidate volume was slightly too narrow laterally;
2. the `±70°` yaw range appeared asymmetric during human review;
3. the `0.22 m` inner rearm distance remained about 10% too long.

Round-2 correction checkpoint `872cbd1add4f824242648831e211c75895ad3625` makes and verifies the following bounded changes:

- `ApproachArea` width increases from `0.90 m` to `1.12 m` (`+0.11 m` per side), remains centred at local X `0`, and retains its `0.62 m` depth and `1.85 m` height;
- the real `0.34 m`-radius player is now recognized at a representative `0.85 m` lateral candidate position;
- the separate snap-safe attachment cap remains `0.12 m`, with a near-edge eligible approach attaching from `0.1077 m`; therefore widening candidate context does not restore the round-1 positional jolt;
- lateral movement intent remains rejected by the existing facing/intent path;
- the inner rearm distance decreases by exactly 10%, from `0.22 m` to `0.198 m`; the regression rearms at `0.205 m` while still inside the outer candidate area, preserves immediate suppression, and reattaches normally on W approach.

### Yaw-centre investigation

The production clamp already centres on `FixedLadder.get_ladder_yaw_world()`, which the current functional root contract and review-scene transform both resolve to the yaw of functional root `+Z`. It uses a wrap-safe signed relative angle and does not consult attach-time player yaw or `Visual/Source`.

The previous automated check used an excessively large mouse delta; after angular wrapping it landed at approximately `±60.844°`, so it never exercised either clamp endpoint. The corrected behavioral regression drives a deliberate `100°` request from the same functional centre and measures:

```text
centre = 0.000°
left   = -70.000°
right  = +70.000°
midpoint offset = 0.000°
```

Because the owning player-controller implementation already satisfies the requested symmetric behavior, no player-controller yaw code was changed. The regression now protects both signed endpoints, equal magnitude, zero-offset midpoint, and independence from the accepted 180° visual-source normalization. Final human re-review remains the gate for the reported visual feel.

That conclusion was incomplete: it established symmetric player-body yaw in the isolated ladder fixture, but did not measure the visible camera axis in the actual shelf-ergonomics review setup. The fresh human recording supplied after round 2 is authoritative evidence that the visible asymmetry persisted; the follow-up below supersedes the no-change conclusion for the review setup while preserving this investigation history.

### Round-2 focused verification

| Check | Result |
| --- | --- |
| `fixed_ladder_authoring_tests.gd` | PASS, exit 0; `1.12 m` centred lateral area, unchanged depth/height |
| `fixed_ladder_player_tests.gd` | PASS, exit 0; real near-edge candidate overlap, lateral rejection, `0.1077 m` snap-safe attach, exact `-70°/+70°`, `0.198 m` rearm behavior |
| `shelf_ergonomics_review_tests.gd` | PASS A/B/C, exit 0; 15 surfaces retained |
| Headless editor scan | exit 0; `FixedLadder` global class registered |

Every command retained only the known Windows root-certificate-store diagnostic. No shared player-controller code changed, so the optional default-project smoke was not repeated.

### Round-2 visible-yaw follow-up

Fresh in-game recording confirmed that the left visible endpoint was narrower than the right. The ladder clamp itself remained symmetric, but the shelf-review entry setup called `look_at()` on the child camera. That left `-6.521°` of horizontal yaw on `Player/Camera3D` while the player body remained at `0°`. The clamp then limited only the player body to `±70°`, producing an approximately `63.479°` visible left range and `76.521°` visible right range around the ladder axis.

Follow-up checkpoint `a4fecadceab582e6ef3feb4dddbdf187b606b464` moves the review entry's horizontal orientation onto the player body and leaves only pitch on the child camera. The corrected runtime metric is identical in cases A, B, and C:

```text
player body yaw = -6.116°
camera local yaw = 0.000°
visible attached endpoints = -70.000° / +70.000°
```

The shared player controller, ladder yaw centre, `±70°` limit, ladder geometry, review-scene composition, approach width, attach correction, and rearm distance are unchanged. The focused ladder regression now measures the world yaw of the visible camera axis rather than only `Player.rotation.y`; the shelf-review regression separately prevents review setup from reintroducing child-camera yaw.

| Check | Result |
| --- | --- |
| `fixed_ladder_authoring_tests.gd` | PASS, exit 0 |
| `fixed_ladder_player_tests.gd` | PASS, exit 0; visible camera endpoints exactly `-70°/+70°`, attach correction still `0.1077 m` under `0.12 m` |
| `shelf_ergonomics_review_tests.gd` | PASS A/B/C, exit 0; player `-6.116°`, camera-local yaw `0.000°`, 15 surfaces retained |
| Headless editor scan | exit 0; scripts and global classes registered |

Every command retained only the known Windows root-certificate-store diagnostic. Final human re-review remains required for the corrected visible feel.

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
- no top dismount; bottom release resumes normal S movement and suppresses immediate reattachment until the inner rearm distance or outer-area exit;
- carried identity and existing pickup/storage/HUD/zoning paths remain intact; zoning holds exact attached position;
- WorldItem and StorageSurface rays pass through ladder movement collision through existing layer separation;
- separate taller functional `ModularRack_LadderProof` and `FixedLadder_LadderProof` in the retained shelf-ergonomics review scene.

Initial implementation approved-plan deviations: none. The later review-entry adjustment is recorded in the bounded correction section above.

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

Delivery documentation also includes the approved design, approved implementation plan, supplied validation template, and this record. The initial implementation did not change `shelf_ergonomics_review.gd`; round 1 later moved its review entry, and the round-2 visible-yaw follow-up moved that entry's horizontal look from the child camera to the player body. `project.godot` and `wing_gameplay.tscn` remain unchanged.

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
| Approach width / depth / height | `1.12 / 0.62 / 1.85 m` |
| Climb speed | `1.65 m/s` |
| Maximum horizontal attach correction | `0.12 m` |
| Bottom inner rearm distance | `0.198 m` |
| Yaw clamp | `±70°` |
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

## Final focused human re-review only

Do not repeat the original ladder matrix or the complete round-1 re-review. Record PASS / REVISE and concise notes for these seven checks.

### 1. Centre and near-edge frontal attachment

Approach once near the ladder centre and once with roughly half the player body laterally in front of the ladder. Hold W and confirm both feel intentional; candidate recognition may be wider, but attachment still occurs only near the snap-safe climb line.

### 2. Lateral crossing

Cross the wider approach region laterally once. Confirm it does not attach.

### 3. Left/right yaw-max symmetry

While attached, turn fully left and fully right. Confirm both endpoints feel equally distant from the ladder's functional forward centre and remain `±70°`.

### 4. Shorter bottom rearm

Descend and detach, continue S for a short deliberate back-away while remaining inside the outer approach volume, then press W toward the ladder. Confirm reattachment becomes available sooner.

### 5. Immediate bottom bounce prevention

At bottom detach, reverse toward the ladder without first reaching the short rearm distance. Confirm immediate recapture remains blocked.

### 6. Attachment-jolt regression

Perform one quick ordinary frontal W attachment and confirm the round-1 positional jolt remains fixed.

### 7. Interaction smoke

Perform one pickup/retrieve or storage placement while attached. Confirm the ladder still does not mechanically block the normal interaction ray.

## Developer disposition

```text
PROMOTE / REVISE

Date:
Decision notes:
Required corrections, if any:
```

PROMOTE approves this fixed-line architecture only for selected taller installations. It does not approve universal ladder coverage, final ladder dimensions/assets, general climbing, movable/sliding ladders, or shelf-top traversal. REVISE should remain bounded to evidence from the scenarios above unless the fixed-line model itself fails.
