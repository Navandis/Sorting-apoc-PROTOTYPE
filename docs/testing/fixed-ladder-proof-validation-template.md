# Fixed-Ladder Proof Validation and Human Playtest Handoff

**Feature:** Single-rack fixed-ladder proof  
**Status:** TECHNICALLY VERIFIED / HUMAN REVIEW PENDING  
**Date:** _fill on implementation delivery_  
**Feature branch:** _fill_  
**Implementation commit:** _fill_  
**Godot:** `4.7.stable.official.5b4e0cb0f` unless local verification reports otherwise

> This record is completed by the implementation task and then updated only with the developer's human PROMOTE / REVISE decision. Do not mark the ladder promoted based on automated checks alone.

---

## 1. Implemented Scope

Fill in the actual delivered result.

Expected scope:

- reusable standalone `FixedLadder`;
- editor-authored `ladder_height_m`;
- editor-authored overhead limit;
- normalized initial ladder visual;
- one coarse movement collider;
- bottom/front approach trigger;
- fixed climb line;
- player `LADDER_ATTACHED` state;
- frontal + W attach;
- W/S vertical movement;
- release-to-hold;
- no A/D or sprint ladder motion;
- ladder-relative yaw clamp;
- body-aware top stop;
- bottom release and reattach suppression;
- item/storage rays pass through ladder collision;
- existing storage/carry/HUD/zoning interaction remains available;
- separate taller-rack proof installation in the shelf-ergonomics review scene.

List any approved-plan deviations explicitly:

```text
None.
```

or:

```text
Deviation:
Reason:
Effect on human proof:
```

---

## 2. Files Changed

_Fill from final diff._

Expected ownership includes:

```text
gameplay/traversal/fixed_ladder/fixed_ladder.gd
gameplay/traversal/fixed_ladder/fixed_ladder.tscn
player_controller.gd
gameplay/logistics_wing/review/shelf_ergonomics/shelf_ergonomics_review.tscn
gameplay/logistics_wing/review/shelf_ergonomics/shelf_ergonomics_review.gd
tools/asset_pipeline/tests/fixed_ladder_authoring_tests.gd
tools/asset_pipeline/tests/fixed_ladder_player_tests.gd
tools/asset_pipeline/tests/shelf_ergonomics_review_tests.gd
docs/testing/fixed-ladder-proof-validation.md
```

Remove paths that were not actually changed and add any justified extra owning files.

---

## 3. Proof Installation Authoring Values

Fill actual values.

| Property | Value |
|---|---:|
| Proof rack name | |
| Rack length | |
| Rack depth | |
| Rack frame height | |
| Highest usable shelf Y | |
| Ladder name | |
| Ladder height | |
| Ladder functional width | |
| Ladder functional depth | |
| Ladder X/Z placement relative to rack | |
| Ladder/player standoff | |
| Approach depth | |
| Climb speed | |
| Yaw clamp | |
| Top-view margin | |
| Ceiling-safety margin | |
| Authored overhead limit | `3.40 m` expected for primary proof |

These are proof values, not production constants unless later explicitly promoted.

---

## 4. Automated Verification

Record exact commands, PASS/FAIL and relevant diagnostics.

### Fixed ladder authoring

```powershell
& $godot --headless --path . --script res://tools/asset_pipeline/tests/fixed_ladder_authoring_tests.gd
```

Result:

```text
_fill_
```

### Player ladder behavior

```powershell
& $godot --headless --path . --script res://tools/asset_pipeline/tests/fixed_ladder_player_tests.gd
```

Result:

```text
_fill_
```

### Shelf ergonomics review regression

```powershell
& $godot --headless --path . --script res://tools/asset_pipeline/tests/shelf_ergonomics_review_tests.gd
```

Result:

```text
_fill_
```

### ModularRack regression

```powershell
& $godot --headless --path . --script res://tools/asset_pipeline/tests/modular_rack_authoring_tests.gd
```

Result:

```text
_fill_
```

### Continuing storage interaction regression

```powershell
& $godot --headless --path . --script res://tools/asset_pipeline/tests/wing_storage_bridge_interaction_tests.gd
```

Result:

```text
_fill_
```

### Editor scan

```powershell
& $godot --headless --editor --path . --quit
```

Result:

```text
_fill_
```

### Default project smoke

Command:

```powershell
_fill exact command_
```

Result:

```text
_fill_
```

Confirm:

```text
Run Project still enters res://gameplay/logistics_wing/wing_gameplay.tscn: YES / NO
Ladder proof remains review-scene-only: YES / NO
```

---

## 5. Interaction-Layer Verification

Record the actual result:

```text
Ladder movement collider blocks ordinary player movement: YES / NO
Ladder movement collider participates in WorldItem pickup ray: NO expected
Ladder movement collider participates in StorageSurface ray: NO expected
ApproachArea overlaps WorldItem pickup collision layer: NO expected
ApproachArea overlaps StorageSurface interaction layer: NO expected
```

Evidence / test name:

```text
_fill_
```

---

## 6. Known Diagnostics

Record only actual diagnostics.

Expected recurring project diagnostics may include:

- Windows root certificate-store diagnostic;
- intentional missing-clearance-context warning-path coverage;
- scripted editor shutdown scan/RID cleanup diagnostics.

State whether each observed diagnostic is unchanged from existing evidence.

Do not hide new errors inside this section.

---

## 7. Human Review Launch

Primary proof should use the 3.40 m review condition.

Example launch:

```powershell
$godot = 'D:\AI Tools\Godot-4.7-Codex\Godot_v4.7-stable_win64_console.exe'
& $godot --path 'D:\Godot Projects\Sorting-apoc-PROTOTYPE' --rendering-method gl_compatibility 'res://gameplay/logistics_wing/review/shelf_ergonomics/shelf_ergonomics_review.tscn' -- --ergonomics-case=A
```

Replace if implementation adds a more specific proof flag.

---

## 8. Human Playtest Scenarios

### A. Frontal attach

1. Walk toward the ladder from the front while holding W.
2. Confirm attach happens near the ladder rather than from an excessive distance.
3. Confirm horizontal correction is small and not a visible teleport.

Result:

```text
PASS / REVISE
Notes:
```

### B. No side capture

1. Walk laterally through the approach region with A/D.
2. Cross while looking substantially sideways.
3. Enter the region without W.

Expected: no attachment.

Result:

```text
PASS / REVISE
Notes:
```

### C. Basic climbing

While attached:

- W up;
- S down;
- release W/S;
- press A/D;
- hold Shift;
- look sharply up/down while moving.

Expected:

- vertical W/S only;
- release holds exact height;
- A/D does not move;
- Shift does not alter climb speed;
- camera pitch does not affect vertical direction/speed.

Result:

```text
PASS / REVISE
Notes:
```

### D. Mouse look / yaw

Inspect both sides of the proof rack.

Questions:

- Is the current yaw clamp too narrow, too wide, or suitable?
- Can enough of the shelf width be inspected?
- Does the player still feel physically attached to the ladder?

Result:

```text
PASS / REVISE
Preferred yaw clamp if changed:
Notes:
```

### E. Top stop / ceiling safety

1. Climb to maximum height.
2. Continue holding W.
3. Look up.
4. Inspect top shelf.

Expected:

- no further rise at limit;
- no camera clipping;
- no body/capsule ceiling penetration;
- useful visibility over highest shelf;
- no rack-top dismount.

Result:

```text
PASS / REVISE
Notes:
```

### F. Bottom release

1. Descend to/below ladder base.
2. Keep S held.
3. Confirm detachment.
4. Confirm continued S backs away.
5. Confirm no immediate reattach.
6. Exit and re-enter the approach region.
7. Confirm attach becomes available again.

Result:

```text
PASS / REVISE
Notes:
```

### G. Pickup / retrieval

At useful ladder heights:

- LMB retrieve a stored item through/behind the ladder visual;
- confirm visual rails/rungs do not mechanically block the ray;
- confirm carried item identity is correct.

Result:

```text
PASS / REVISE
Notes:
```

### H. Auto/manual storage

While attached:

- E auto-store;
- hold-E where useful;
- M manual mode;
- manual E placement;
- R packing rotation;
- mouse wheel / number selection.

Expected: existing behavior remains available within normal interaction range.

Result:

```text
PASS / REVISE
Notes:
```

### I. HUD / carried state

Attach with a carried item and climb.

Expected:

- carried state preserved;
- held-item presentation preserved;
- HUD preserved;
- detach preserves same carried contents.

Result:

```text
PASS / REVISE
Notes:
```

### J. Zoning while attached

1. Open zoning for a reachable surface.
2. Hold W/S while modal is open.
3. Close zoning.

Expected:

- no movement while modal is open;
- exact height preserved;
- player remains attached;
- normal ladder movement resumes after close.

Result:

```text
PASS / REVISE
Notes:
```

### K. Fixed-line usefulness

Judge the installation rather than movement alone:

- left/right coverage;
- useful depth;
- top shelf visibility;
- rung/rail visual obstruction;
- relationship between ladder and shelf;
- whether the extra capacity is worth ladder interaction.

Optional: move the ladder modestly left/right in the editor and compare. Do not implement sliding traversal.

Result:

```text
PASS / REVISE
Notes:
```

---

## 9. Human Decision

### PROMOTE

Use PROMOTE only if the fixed-line model is sufficiently predictable and comfortable for selected taller storage installations.

Promotion does **not** approve:

- universal ladder coverage;
- all ladder visual assets;
- final ladder dimensions;
- general climbing;
- movable/sliding ladders;
- shelf-top traversal.

### REVISE

Use REVISE for bounded tuning such as:

- climb speed;
- yaw clamp;
- player standoff;
- approach depth;
- facing threshold;
- top-view margin;
- ceiling-safety margin;
- ladder position/height;
- proof-rack shelf distribution.

Escalate architecture only if the fixed-line model itself fails.

### Developer disposition

```text
PROMOTE / REVISE

Date:
Decision notes:
Required corrections, if any:
```

---

## 10. Post-Decision Gate

If **PROMOTE**:

1. record the human promotion without rewriting historical reports;
2. merge/push only when separately authorized;
3. reconcile core docs only when useful;
4. resume Receiving unless a concrete storage blocker remains.

If **REVISE**:

1. keep the same bounded ladder gate;
2. implement only the evidenced correction;
3. rerun affected focused checks;
4. repeat only the relevant human scenarios;
5. do not begin Receiving.
