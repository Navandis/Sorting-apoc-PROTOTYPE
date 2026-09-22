# Sorting Apocalypse — Single-Rack Fixed-Ladder Proof Implementation Plan

**Prepared:** 22 September 2026  
**Status:** APPROVED — human-reviewed 22 September 2026  
**Design authority:** `docs/superpowers/specs/2026-09-22-fixed-ladder-proof-design.md`  
**Implementation authority:** This plan only after human approval  
**Expected tracked `main` at planning time:** `0a33d03dd0e18b26b1b42060e3a040a692ed6050`

---

## 1. Goal

Implement the approved **single-rack fixed-ladder proof** as one bounded gameplay gate.

The implementation must prove:

- a reusable fixed vertical ladder can be placed independently of a storage family;
- ladder height can be authored per instance in the Godot editor;
- frontal approach plus forward input attaches reliably;
- side crossing does not capture the player;
- W/S performs camera-independent vertical movement;
- releasing W/S holds height;
- A/D and sprint do not move the player while attached;
- mouse look remains available with ladder-relative yaw clamping;
- the top stop protects the full player body from the authored overhead limit;
- descending through the bottom releases and continued S backs away;
- immediate reattachment is suppressed until the player exits the approach region;
- carrying, pickup, retrieval, auto/manual storage, packing rotation, HUD and zoning remain available;
- ladder movement collision does not block item/storage interaction rays;
- one deliberately taller functional rack supplies the human proof installation.

The work ends at a **human PROMOTE / REVISE decision**. It does not continue into Receiving.

---

## 2. Preservation Boundaries

Do not redesign or alter the promoted behavior of:

- deterministic storage reservations;
- support stacking;
- Storage Zones;
- Storage Unit Orientation & Zoning Basis;
- canonical item storage pose;
- packing rotation;
- item definitions or catalogue metadata;
- `DevelopmentSetup` palette authority;
- current interaction grammar;
- accepted whole-wing geometry;
- default `wing_gameplay.tscn` composition;
- current ModularRack storage architecture.

Do not modify the current three-level `ModularRack_Starter` merely to make it ladder-served. It remains ground-access ergonomics evidence.

Do not modify imported ladder GLB source geometry during this task unless a concrete normalization blocker is discovered. Asset-sensitive source/import inspection must occur in the authoritative local checkout.

No merge, push, branch deletion, Receiving work, or broader documentation reconciliation is authorized by this implementation plan.

---

## 3. Expected Working Method

Use one local Codex implementer.

Before edits:

1. verify local repository path is `D:\Godot Projects\Sorting-apoc-PROTOTYPE`;
2. verify installed Godot is the expected 4.7 build;
3. inspect branch, working tree, `main`, `origin/main`, recent commits and local ignored state;
4. read:
   - `docs/AI_WORKING_GUIDELINES.md`;
   - `docs/CURRENT_STATE.md`;
   - approved fixed-ladder technical design;
   - `docs/testing/shelf-ceiling-ergonomics-comparison.md`;
   - `docs/testing/modular-rack-authoring-validation.md`;
5. preserve all user-authored scene/resource work;
6. create one focused ladder feature branch from the verified current `main`.

Suggested branch name:

```text
codex/fixed-ladder-proof
```

Do not reset the local checkout to a planning-time SHA if local `main` has legitimately advanced.

---

## 4. Planned Owning Files

### New ladder component

Create a focused directory, suggested:

```text
res://gameplay/traversal/fixed_ladder/
```

Expected new files:

```text
gameplay/traversal/fixed_ladder/fixed_ladder.gd
gameplay/traversal/fixed_ladder/fixed_ladder.tscn
```

The exact directory name may be adjusted during local preflight if an existing project convention clearly fits better. Do not create a general traversal framework.

### Existing player movement

Primary existing owner:

```text
player_controller.gd
```

`gameplay/player/gameplay_player.tscn` should change only if a scene-level player property or stable helper node is genuinely needed. Prefer deriving player collider/camera offsets from the existing scene rather than duplicating constants.

### Proof scene

Reuse the retained shelf-ergonomics review environment:

```text
gameplay/logistics_wing/review/shelf_ergonomics/shelf_ergonomics_review.tscn
gameplay/logistics_wing/review/shelf_ergonomics/shelf_ergonomics_review.gd
```

Add a **separate ladder-proof installation** rather than altering the promoted three-level starter.

### Tests

Add focused ladder tests under the existing test location.

Suggested files:

```text
tools/asset_pipeline/tests/fixed_ladder_authoring_tests.gd
tools/asset_pipeline/tests/fixed_ladder_player_tests.gd
```

Extend an existing review-scene test only where the proof installation genuinely belongs in that scene's contract. Avoid turning the existing ergonomics test into the main ladder behavior harness.

### Validation record

After technical verification and human playtest, add one concise evidence record:

```text
docs/testing/fixed-ladder-proof-validation.md
```

Do not update GDD / Findings / VDD / CURRENT_STATE until the human ladder decision establishes what was actually promoted.

---

## 5. Phase A — Implement Reusable `FixedLadder`

### A1. Scene skeleton

Create the approved standalone scene:

```text
FixedLadder                  Node3D / @tool
├── Visual                   Node3D
│   └── Source               current ladder GLB
├── MovementCollision        StaticBody3D
│   └── Shape                CollisionShape3D
├── ApproachArea             Area3D
│   └── Shape                CollisionShape3D
├── ClimbAnchor              Marker3D
├── LadderTop                Marker3D
├── OverheadLimit            Marker3D
└── AuthoringPreview         generated editor-only
```

Use:

```text
res://assets/environment/furniture/storage/SM_Ind_War_Equipment_Ladder_Metal_Worn_01.glb
```

as the initial visual source.

### A2. Authoring contract

Implement per-instance exported properties for at least:

```text
ladder_height_m
overhead_limit_local_y_m
show_authoring_preview
```

Centralize the initial tuning constants in `fixed_ladder.gd`, including:

- functional ladder width;
- functional ladder depth;
- player standoff;
- approach-region depth/width;
- top view margin;
- ceiling safety margin;
- initial yaw clamp;
- initial climb speed or player-side equivalent.

Do not expose every internal constant in the inspector unless it materially helps the human proof.

### A3. Transform restrictions

Validate:

- root scale = `(1,1,1)`;
- root pitch = 0;
- root roll = 0;
- root translation/yaw remain free.

Use Godot configuration warnings rather than silently correcting root transforms.

### A4. Visual normalization

Normalize the current ladder asset beneath `Visual` so that the functional root contract is independent of the GLB's source axes/offset.

`ladder_height_m` must update the visual's vertical extent.

Do not make rung count or mesh topology part of gameplay.

If source-mesh bounds make direct normalized Y scaling ambiguous, resolve that once inside the `Visual` wrapper rather than leaking asset-specific axes into player logic.

### A5. Coarse movement collision

Use one simple box-like movement collider.

It must:

- follow `ladder_height_m`;
- use the common functional width/depth envelope;
- block ordinary player movement;
- remain entirely separate from pickup/storage interaction collision layers.

No rung collision.

### A6. Approach area and runtime contract

The bottom/front `ApproachArea` should be shallow and sufficient to detect a candidate player.

`FixedLadder` should expose a small explicit runtime contract rather than letting the player reach into arbitrary child nodes.

Suggested methods/properties:

```text
get_climb_anchor_world_position()
get_ladder_top_world_y()
get_overhead_limit_world_y()
get_ladder_forward_world()
get_ladder_yaw_world()
is_player_in_approach_area(player)
is_attach_suppressed_for(player)
suppress_until_approach_exit(player)
```

Exact naming is implementation-local, but responsibilities should remain bounded.

Avoid a general "climbable" interface unless implementation evidence actually requires one.

---

## 6. Phase B — Add the Minimal Player Ladder State

Primary owner: `player_controller.gd`.

### B1. State

Add only a bounded ladder-attached state.

Conceptually:

```text
NORMAL
LADDER_ATTACHED
```

Store:

- currently attached `FixedLadder` reference;
- attachment state;
- ladder-relative yaw centre;
- any minimal release-suppression state needed by the player side.

Do not create a general movement-state framework merely for this feature.

### B2. Normal movement remains default

Keep current normal movement code behavior unchanged whenever no ladder is attached:

- gravity;
- WASD;
- sprint;
- acceleration/deceleration;
- `move_and_slide()`;
- existing interaction processing.

Refactor only as much as necessary to place a clear ladder branch around the existing behavior.

### B3. Candidate attachment

While not attached, determine whether a nearby ladder is eligible.

Attach only when:

- the player is within the ladder approach area;
- the player is on the front side;
- player facing is within the provisional frontal threshold;
- W / forward is pressed;
- movement intent points into the ladder rather than laterally through it;
- zoning is not open;
- reattachment suppression is not active.

Do not attach merely because an `Area3D` overlap began.

Do not add an interact key.

### B4. Attach transition

On attach:

- move X/Z to the ladder's climb anchor;
- keep/clamp player Y within the legal lower range;
- clear X/Z velocity;
- set Y velocity to zero;
- preserve camera pitch;
- preserve carried items;
- preserve storage controller state;
- establish the ladder-relative yaw centre.

The horizontal correction should be small because approach geometry should already place the player near the climb line.

### B5. Attached movement

While attached:

- suppress gravity;
- W => positive Y climb speed;
- S => negative Y climb speed;
- no W/S => zero Y movement / hold height;
- A/D => no movement;
- Shift => no speed modifier;
- X/Z remain on the fixed climb line;
- continue using the existing `CharacterBody3D` and `move_and_slide()`.

Do not reparent the player to the ladder.

Do not move only the camera.

### B6. Ladder-relative mouse yaw

Keep existing mouse pitch handling.

While attached:

- update desired body yaw from mouse X movement;
- clamp that yaw around the ladder-facing centre;
- initial target is approximately `±80°`;
- maintain one continuous yaw representation that avoids wraparound errors near ±π.

Do not forcibly centre the view on attach unless the current yaw lies outside the allowed interval.

On detach, normal unrestricted yaw resumes without a visible rotation jump.

### B7. Top limit

Derive player dimensions from the existing player scene.

Current tracked scene contains:

- `CharacterBody3D` root;
- 1.75 m capsule;
- camera at approximately 1.716 m above root.

Implementation must not assume those values as duplicated ladder constants if they can be measured from the actual nodes.

Calculate:

```text
preferred_player_root_y =
    ladder_top_world_y
    + top_view_margin_m
    - player_eye_offset_from_root
```

and:

```text
ceiling_safe_player_root_y =
    overhead_limit_world_y
    - player_body_top_offset
    - ceiling_safety_margin_m
```

Then:

```text
max_climb_y = min(preferred_player_root_y, ceiling_safe_player_root_y)
```

Upward input at the limit produces no further upward movement.

No top dismount.

### B8. Bottom detach

When downward movement reaches/passes the ladder's bottom release threshold:

- clamp/release cleanly;
- return to normal movement;
- retain held S input so normal backward movement begins immediately;
- mark that ladder suppressed for immediate reattachment.

Primary suppression reset:

```text
player exits that ladder's ApproachArea
```

Add a very short secondary timer only if actual testing exposes a same-frame/physics-edge recapture that exit-reset alone does not solve.

---

## 7. Phase C — Preserve Existing Interaction While Attached

### C1. Do not block interaction rays

No special ray-piercing algorithm should be written.

Current item and storage targeting already use interaction `Area3D` layers and `collide_with_bodies = false`.

Therefore ensure:

- ladder `MovementCollision` is an ordinary body on the movement/environment collision path;
- ladder `ApproachArea` uses a dedicated/non-conflicting area layer;
- neither ladder component occupies WorldItem pickup or StorageSurface interaction layers.

Then existing rays naturally pass through the ladder.

### C2. Existing controls

Do not branch or disable these merely because the player is attached:

- LMB pickup/retrieve;
- E place/auto-store;
- hold-E auto-store;
- M auto/manual mode;
- R packing rotation;
- carried-item selection;
- HUD;
- held-item view;
- F6 diagnostics.

### C3. Zoning modal

When the zoning editor opens while attached:

- player position remains unchanged;
- player stays logically attached;
- `_physics_process` must not cause vertical ladder motion from held W/S while the modal is active;
- closing zoning resumes the same ladder attachment at the same height.

Prefer using the player's existing `_zone_editor_open` state rather than introducing ladder-specific UI plumbing.

---

## 8. Phase D — Build the Dedicated Taller-Rack Proof Installation

Use the existing shelf-ergonomics review scene because it already provides:

- ordinary gameplay player/HUD;
- real storage interactions;
- functional ModularRack authoring;
- controlled 3.40 m / 2.80 m ceiling contexts;
- existing review lighting;
- F5/F6 review tooling;
- retained ground-access comparison fixtures.

### D1. Preserve existing starter

Do not repurpose:

```text
ReviewFixtures/ModularRack_Starter
```

Its three-level configuration remains ground-access comparison evidence.

Existing tests currently assume the delivered scene has one starter rack and derive three levels. Update those expectations only to account explicitly for the new proof installation, not by deleting or mutating the starter.

### D2. Add separate proof rack

Add a new scene-local ModularRack instance, suggested name:

```text
ModularRack_LadderProof
```

Author:

- a deliberately taller frame;
- shelf levels with the highest usable surface clearly beyond comfortable normal standing access;
- dimensions that remain plausible under the 3.40 m Case A/B ceiling;
- enough rack width to test left/right inspection from a fixed ladder line;
- normal runtime StorageSurfaces.

Do not finalize production rack dimensions here. They are proof geometry.

### D3. Add `FixedLadder`

Place one ladder approximately at the horizontal centre of the proof rack, on the shelf-facing vertical plane.

Author:

- root floor position;
- yaw;
- height slightly above the top proof shelf;
- 3.40 m overhead limit for the initial proof condition.

The scene should permit straightforward manual left/right ladder repositioning for human comparison without code changes.

### D4. Initial proof condition

Use Case A / 3.40 m ceiling as the primary ladder interaction condition.

Do not make Case B/C ladder variants a prerequisite for initial implementation.

The 2.80 m condition may be tried later if the developer wants to inspect ceiling-limited behavior after the main proof works.

### D5. Real storage evidence

Populate/retain enough real functional storage and catalogue items to test:

- top shelf retrieval;
- top shelf auto-store;
- top shelf manual placement;
- R packing rotation;
- side inspection;
- meaningful depth visibility.

Do not create a new duplicate item palette.

Reuse the promoted review-scene supply mechanism.

---

## 9. Phase E — Focused Automated Verification

Testing should target the approved ladder invariants and nearby regressions only.

### E1. `fixed_ladder_authoring_tests.gd`

Cover:

- scene loads/instantiates;
- root is expected ladder class;
- required child structure exists;
- current ladder visual source is present;
- height changes update visual bounds meaningfully;
- height changes update movement-collision height;
- top marker follows height;
- overhead marker follows authored overhead;
- approach region remains bottom/front rather than scaling into a full-height capture volume;
- functional width/depth remain stable as height changes;
- non-unit root scale invalidates/warns;
- root pitch/roll invalidates/warns;
- invalid/no legal vertical range reports clearly;
- independent instances retain independent authored heights and collision resources.

Avoid asset-pixel-level assertions that would make harmless future ladder-model replacement difficult.

### E2. `fixed_ladder_player_tests.gd`

Prefer deterministic calls/state setup over brittle synthetic keyboard automation where possible.

Cover:

- eligible frontal forward attachment;
- side/lateral candidate does not attach;
- no-forward candidate does not attach;
- attach locks X/Z to climb line;
- W raises player independent of camera pitch;
- S lowers player;
- A/D do not move X/Z;
- Shift does not alter ladder speed;
- zero W/S holds Y;
- yaw clamp respects configured range;
- top clamp uses the lower of visual target and body-safe ceiling limit;
- full capsule top remains below authored overhead;
- bottom release transitions to normal state;
- suppressed ladder cannot immediately recapture;
- suppression clears after approach-area exit;
- carried item identity survives attach/detach;
- zoning-open path produces no climb movement.

### E3. Interaction-ray invariant

Add a focused assertion using real physics layers that confirms:

- ladder movement body lies between camera and test target;
- WorldItem pickup ray still reaches the item;
- StorageSurface targeting ray still reaches the surface.

Do not create a bespoke "ray through ladder" implementation just to satisfy the test.

### E4. Review-scene contract

Update `shelf_ergonomics_review_tests.gd` only enough to verify:

- original starter still exists unchanged in intended role;
- one separate ladder-proof rack exists;
- one FixedLadder exists for the proof installation;
- proof rack builds the expected number of surfaces from its authored levels;
- existing Metal Shelf/Locker and review-supply behavior remain intact;
- F5/F6 behavior remains intact.

Do not freeze incidental proof shelf counts if the scene can derive them safely.

---

## 10. Regression Sweep

After focused ladder tests pass, run one final bounded sweep.

Required:

```powershell
& $godot --headless --path . --script res://tools/asset_pipeline/tests/fixed_ladder_authoring_tests.gd
& $godot --headless --path . --script res://tools/asset_pipeline/tests/fixed_ladder_player_tests.gd
& $godot --headless --path . --script res://tools/asset_pipeline/tests/shelf_ergonomics_review_tests.gd
& $godot --headless --path . --script res://tools/asset_pipeline/tests/modular_rack_authoring_tests.gd
& $godot --headless --path . --script res://tools/asset_pipeline/tests/wing_storage_bridge_interaction_tests.gd
& $godot --headless --editor --path . --quit
```

Also perform a normal default-project smoke to confirm `wing_gameplay.tscn` remains the normal launch and the ladder proof has not been injected into production gameplay.

Only add another existing regression suite if an actual touched dependency justifies it.

Inspect error output as well as PASS/exit codes.

Known unchanged diagnostics should remain classified according to existing project records rather than treated as new ladder failures.

---

## 11. Human Playtest Handoff

Create one concise:

```text
docs/testing/fixed-ladder-proof-validation.md
```

with:

- exact commit;
- launch command;
- proof-scene location;
- controls;
- ladder authoring values used;
- focused automated results;
- any known diagnostics;
- human scenarios;
- explicit PROMOTE / REVISE question.

### Required human scenarios

#### 1. Approach / capture

- Walk frontally into the ladder while holding W.
- Confirm attach feels intentional.
- Walk laterally through the approach region.
- Confirm no attach.
- Enter approach region without forward intent.
- Confirm no attach.

#### 2. Basic movement

- W up.
- S down.
- release to hold.
- try A/D.
- try Shift.
- look sharply up/down while climbing.
- confirm vertical speed/direction remain independent of camera pitch.

#### 3. Look range

- inspect left/right portions of the rack;
- decide whether ±80° is too much, too little, or suitable;
- confirm the player still feels attached to the ladder.

#### 4. Top safety

- climb to maximum;
- confirm clear visibility over the top storage surface;
- look upward;
- verify no camera/body ceiling clipping;
- confirm W does not push higher.

#### 5. Bottom release

- descend through bottom;
- keep S held;
- confirm normal backward movement carries the player away;
- confirm no immediate reattach;
- approach again and confirm attachment becomes available after leaving/re-entering the approach region.

#### 6. Storage interaction

From multiple ladder heights:

- retrieve stored item with LMB;
- auto-store with E;
- hold-E where useful;
- enter manual mode;
- place manually;
- use R packing rotation;
- cycle carried item;
- confirm HUD remains coherent;
- verify the ladder visual may obscure portions of objects but does not mechanically block the interaction ray.

#### 7. Zoning

- open zoning while attached;
- hold W or S while modal is open;
- close zoning;
- confirm player remains at the same height and remains attached.

#### 8. Fixed-line usefulness

Judge:

- left/right shelf coverage;
- usable depth;
- top shelf inspection;
- rung/rail visual obstruction;
- whether the extra vertical capacity is worth the interaction cost.

Move the ladder modestly left/right in the editor if useful for comparison. Do not implement sliding traversal.

---

## 12. Human Decision Criteria

### PROMOTE

Promote if:

- attachment is predictable;
- accidental capture is rare/absent;
- climbing is immediately understandable;
- holding height feels stable;
- top stop is safe;
- bottom release is clean;
- storage interactions remain usable;
- one fixed climb line services enough of the test rack;
- visual obstruction is acceptable;
- the ladder reads as installed infrastructure;
- no promoted storage behavior regresses.

Promotion approves the fixed-ladder architecture for selected installations only.

### REVISE

Revise without architectural escalation when evidence points to tuning of:

- climb speed;
- yaw clamp;
- player standoff;
- approach area;
- facing threshold;
- top view margin;
- ceiling safety margin;
- proof rack layout;
- ladder position/height.

Escalate to architectural redesign only if the fixed-line interaction itself fails the gameplay goal.

---

## 13. Commit / Delivery Structure

Keep commits small enough to review but do not manufacture ceremony.

A sensible sequence is:

1. `feat: add height-authorable fixed ladder`
2. `feat: add player fixed-ladder movement`
3. `test: add fixed-ladder proof coverage`
4. `test: add ladder proof installation and handoff`

This is a suggestion, not a requirement if a smaller clean commit structure is more natural.

Before delivery:

- verify feature branch diff against current `main`;
- confirm no unintended ItemDefinition/resource edits;
- confirm no imported source asset mutation unless explicitly required and reported;
- confirm `project.godot` default scene remains unchanged;
- confirm `wing_gameplay.tscn` is unchanged unless a concrete implementation dependency required otherwise;
- preserve ignored local assets/import state.

Stop after the proof is ready for human review.

Do **not** merge or push without explicit authorization.

---

## 14. Expected Implementation Risks

### Visual-source axis normalization

The current GLB has an unusual transform in the historical review scene. Local inspection must determine its source bounds/axis once and normalize it beneath `Visual`.

This should not affect the functional ladder coordinate contract.

### CharacterBody contact with ladder collider

A player fixed in front of a solid ladder body may encounter Jolt contact behavior while moving vertically. Keep standoff sufficient that the capsule does not grind against the movement collider.

Do not solve this with rung collision or physics complexity.

### Attached yaw wraparound

Clamp ladder-relative yaw using angle-safe math rather than naïve scalar world-yaw comparisons.

### Top collision

The authored overhead formula should prevent expected ceiling collision, but `move_and_slide()` remains the final physical safeguard.

Do not disable the player collider while climbing.

### Approach recapture

Use approach-exit reset first. Add a tiny cooldown only if actual frame/overlap ordering makes it necessary.

### Review scene scope growth

The shelf review scene is already evidence-rich. Add only the separate proof installation and ladder-specific contract needed for this gate. Do not turn it into a production gallery-furnishing scene.

---

## 15. Stopping Point

Implementation is complete when all of the following are true:

- reusable height-authorable `FixedLadder` exists;
- current ladder GLB works as its initial visual;
- player can attach/climb/hold/look/release according to the approved design;
- full-body top safety works;
- interaction rays pass through the ladder by layer separation;
- existing carried/storage/zoning interaction works while attached;
- dedicated taller-rack proof installation is runnable;
- focused tests and bounded regression sweep pass;
- concise human playtest handoff exists;
- feature branch is left unmerged for developer review.

At that point, stop.

The next action is the developer's **PROMOTE / REVISE** decision, not Receiving implementation.
