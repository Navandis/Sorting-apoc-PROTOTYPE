# Sorting Apocalypse — Single-Rack Fixed-Ladder Proof Design

**Draft — 22 September 2026**  
**Status:** APPROVED — human-reviewed 22 September 2026. Design authority for the single-rack fixed-ladder proof.

## 1. Purpose

The fixed-ladder proof is the active gameplay gate. Its purpose is to determine whether selected taller storage installations can gain reliable vertical access without expanding into general climbing, jumping, mantling, movable ladders, animation, fall mechanics, or shelf-top traversal.

The proof answers one gameplay question:

> **Can a fixed vertical ladder give the player comfortable, reliable access to additional high storage while preserving the existing storage interaction model?**

The proof does **not** establish a production ladder roster or general climbing system. A technically working ladder still requires human playtest approval before ladder-served storage is promoted.

The intended sequence remains:

1. Single-rack fixed-ladder proof.
2. Human ladder decision.
3. Receiving, unless the ladder proof exposes a concrete storage blocker.

---

## 2. Locked Design Decisions

The proof uses one reusable standalone `FixedLadder` authoring/runtime component.

A ladder is **not owned by `ModularRack`** and does not depend on shelf count, shelf spacing, `StorageSurface` data, storage category, or storage-unit Front.

It is an independently authored piece of installed infrastructure that may serve:

- a `ModularRack`;
- the current Metal Shelf;
- another future storage family that satisfies the same installation assumptions.

The developer authors:

- ladder world position;
- ladder yaw;
- ladder visual model;
- ladder height;
- ceiling/overhead limit for that installation.

The ladder does **not** require authored `top_shelf_height`.

The developer visually adjusts ladder height so that the physical ladder extends slightly above the intended highest shelf.

The system assumes a common functional width/depth envelope for ladder models. Different art assets may be normalized to that envelope before use.

**Per-instance height adjustment is required. Per-instance width/depth adjustment is not.**

---

## 3. Explicit Non-Goals

This proof does not add:

- a ladder interact key;
- general climbable-surface detection;
- angled ladders or stepladders;
- movable or sliding ladders;
- jumping;
- mantling;
- shelf-top dismount;
- lateral ladder traversal;
- falling systems;
- sliding systems;
- stamina systems;
- climb animations;
- visible hands;
- rung-by-rung physical collision;
- rung-by-rung interaction-ray obstruction;
- automatic rack-to-ladder generation;
- automatic determination of top shelf height;
- automatic ladder repositioning after shelf edits;
- player-adjustable ladder geometry;
- multiple climb speeds;
- sprint climbing.

Future player-adjustable storage, if ever approved, may require ladder behavior to be reconsidered. It has no architectural weight in this proof.

---

## 4. Authoring Coordinate Convention

Every `FixedLadder` uses one normalized local frame:

- **+Y:** up;
- **+Z:** ladder front / aisle / player approach side;
- **-Z:** toward the served storage unit;
- **+X:** right when standing in front of the ladder;
- root origin: ground level, centered horizontally on the ladder.

The root supports **translation and yaw only**.

Root pitch and roll remain zero.

Root scale remains:

```text
(1, 1, 1)
```

This keeps placement straightforward in the Godot editor:

1. place the root on the floor;
2. rotate it parallel to the shelf face;
3. slide it left/right as desired;
4. author its height.

The ladder may normally sit near the centre of a shelf installation, but no centre constraint exists.

---

## 5. Proposed Reusable Scene

Conceptual structure:

```text
FixedLadder                  Node3D / @tool
├── Visual                   Node3D
│   └── Source               ladder visual asset
├── MovementCollision        StaticBody3D
│   └── Shape                CollisionShape3D
├── ApproachArea             Area3D
│   └── Shape                CollisionShape3D
├── ClimbAnchor              Marker3D
├── LadderTop                Marker3D
├── OverheadLimit            Marker3D
└── AuthoringPreview         editor-only generated preview
```

`FixedLadder` owns:

- authoring data;
- visual normalization;
- coarse movement collision;
- approach detection;
- climb anchor geometry;
- climb-limit geometry;
- editor warnings/preview.

It does **not** own player movement.

The existing player `CharacterBody3D` remains authoritative for player motion.

---

## 6. Height Authoring

The primary per-instance property is:

```text
ladder_height_m
```

Changing it in the editor updates:

1. visible ladder height;
2. simple movement-collision height;
3. ladder-top marker;
4. editor preview;
5. preferred maximum climb height.

The approach trigger does **not** need to extend the full ladder height. It remains a small bottom/front region because attachment can occur only from the floor approach.

An additional property defines the local overhead constraint:

```text
overhead_limit_local_y_m
```

This represents the first ceiling, beam, or other hard vertical limit relevant to the player above that ladder.

No connection to the rack's own `overhead_limit_local_y_m` is required.

The values may happen to agree when the rack and ladder share the same ceiling, but neither component owns the other.

### Editor Validation

The ladder should warn when:

- height is non-positive or otherwise invalid;
- overhead limit is at/below the usable ladder region;
- root scale is not `(1, 1, 1)`;
- root has pitch or roll;
- calculated legal climb range is effectively zero.

Warnings should inform authoring rather than silently move geometry.

---

## 7. Visual Assets and Resizing

The current ladder asset is:

```text
res://assets/environment/furniture/storage/SM_Ind_War_Equipment_Ladder_Metal_Worn_01.glb
```

It becomes the first visual source.

Its asset-specific:

- rotation;
- offset;
- baseline scale;
- source-axis orientation

are normalized underneath `Visual`.

Functional ladder code does not depend on the GLB's native axes or dimensions.

The normalized visual branch is then vertically scaled to `ladder_height_m`.

Only height needs procedural resizing.

Width and depth use the common ladder envelope.

Moderate stretching is acceptable for the proof.

If a particular installation requires enough height that the asset becomes visibly distorted, an alternate ladder mesh can be prepared in Blender and imported as another normalized visual source.

From the functional system's perspective, it is simply another asset satisfying the same ladder contract.

No rung count, rung spacing, rail segmentation, or mesh topology becomes gameplay data.

---

## 8. Player Movement State

The player gains only one bounded alternate movement state:

```text
NORMAL
   ↓ attach
LADDER_ATTACHED
   ↓ bottom release
NORMAL
```

Being inside the ladder's approach area is merely **candidate context**, not another movement state.

No new generic traversal state machine is required.

While `LADDER_ATTACHED`:

- gravity is suppressed;
- W means climb upward;
- S means climb downward;
- A/D provide no movement;
- Shift provides no speed modifier;
- horizontal velocity is zero;
- releasing W/S produces zero vertical velocity and therefore holds current height;
- the existing `CharacterBody3D` continues to move and collide normally;
- the camera remains the existing child of that body.

The same player body and camera move together.

---

## 9. Attachment

No key is pressed specifically to interact with the ladder.

The ladder's bottom `ApproachArea` registers the player as a candidate.

Actual attachment occurs only when all of these conditions are true:

1. the player is inside the approach region;
2. the player is on the ladder's front side;
3. the player is facing sufficiently toward the ladder;
4. the player is pressing **W / forward**;
5. the player's movement intent is into the ladder rather than across it;
6. zoning/modal UI is not currently active;
7. this ladder is not temporarily suppressed after a bottom release.

This makes lateral traversal through the trigger harmless.

Walking across it with A/D does not attach.

Walking through it while facing sideways also fails the frontal/facing test.

Facing and approach-angle thresholds are tuning parameters rather than design constants.

### Attach Transition

On successful attachment:

- player X/Z is moved to the ladder's fixed climb anchor;
- player Y is preserved/clamped to the valid lower range;
- horizontal velocity is cleared;
- vertical velocity starts at zero;
- ladder-relative yaw authority becomes active;
- pitch is preserved;
- carried contents and all item interaction state are untouched.

The approach region should be shallow enough that the X/Z correction is small rather than feeling like a teleport.

---

## 10. Fixed Climb Line

Each ladder has one vertical climb line.

There is no horizontal travel along the shelf while attached.

Once attached, the player's X/Z position remains at that ladder anchor and only Y changes.

This is deliberate.

The proof needs to determine whether one fixed vertical line gives enough useful access to a shelf installation.

If that proves inadequate, the correct conclusion may be that fixed ladders are unsuitable for some rack widths—not that a sliding-ladder system must immediately be invented.

---

## 11. Mouse Look

Mouse look remains active.

Existing pitch behavior remains unchanged.

Yaw is clamped relative to the ladder-facing direction while attached.

Initial provisional value:

```text
±80°
```

This is intentionally generous because the ladder must permit inspection of storage to either side.

Its purpose is mainly to prevent a player from rotating fully backward while mechanically remaining attached.

The exact value is a human-playtest tuning parameter.

Attachment need not forcibly snap the player's view to exact centre if the existing view is already inside the legal yaw range.

---

## 12. Maximum Climb Height

Maximum height should be based on **both the visible ladder and the complete player body**, not just the camera.

Two limits are calculated.

### 12.1 Preferred Visibility Limit

The normal target is for the player's eye to finish slightly above the visible ladder top:

```text
preferred_player_root_y =
    ladder_top_world_y
    + top_view_margin_m
    - player_eye_offset_from_root
```

`top_view_margin_m` is a small provisional tuning value.

This follows the authoring assumption that the developer has placed the visible ladder slightly above the intended highest shelf.

The resulting eye position therefore naturally provides a view over that shelf without the ladder needing to know where the shelf actually is.

### 12.2 Ceiling-Safe Limit

The full player's collision body must also remain below the overhead limit:

```text
ceiling_safe_player_root_y =
    overhead_limit_world_y
    - player_body_top_offset
    - ceiling_safety_margin_m
```

The actual maximum is:

```text
max_climb_y =
    min(
        preferred_player_root_y,
        ceiling_safe_player_root_y
    )
```

Using the player's actual camera/body offsets makes this robust if eye height or player dimensions later change.

At `max_climb_y`, continued W input simply produces no further upward movement.

There is no top dismount.

---

## 13. Bottom Release

Descending to the ladder base releases the player automatically.

If S remains held after release, that same input immediately resumes its normal meaning—walking backward—and therefore carries the player away from the ladder.

This should not require:

- an extra key;
- a visible detach transition;
- a separate bottom-dismount animation.

### Reattachment Suppression

A ladder that has just released the player at its bottom is temporarily ineligible for that player.

Primary reset condition:

> **The player must exit that ladder's `ApproachArea` before it can attach again.**

This is preferable to relying solely on a timer because it directly represents the desired behavior: the player backed away, then chose to approach again.

A very small secondary cooldown may be added only as a defensive implementation safeguard if required.

---

## 14. Collision Model

The ladder uses one simple rectangular movement collider.

No rung collision is required for the proof or expected for the production game.

Its purpose is only to:

- prevent ordinary walking through the ladder;
- maintain the same coarse-collision philosophy already used elsewhere in the game.

The collider follows:

- authored ladder height;
- common functional width;
- common functional depth.

The player remains slightly in front of that collider while attached.

---

## 15. Storage and Item Rays Pass Through the Ladder

This is an explicit design decision rather than a temporary prototype cheat:

> **The ladder does not block storage placement or item pickup/retrieval raycasts.**

The visual rails and rungs may physically obscure a small portion of the player's view, but they do not create pixel/rung-accurate interaction obstruction.

The ladder's ordinary movement `StaticBody3D` does not participate in item or storage interaction-ray collision.

The ladder's approach trigger likewise must not share:

- the WorldItem pickup collision layer;
- the `StorageSurface` interaction layer.

This preserves the project's existing separation between:

- visible geometry;
- movement collision;
- interaction representation.

It also avoids making ladders uniquely simulation-heavy.

---

## 16. Existing Gameplay While Attached

The following remain functional while attached wherever their normal range permits:

- LMB TAKE/retrieve;
- E auto-store;
- hold-E repeated auto-store;
- M auto/manual toggle;
- manual E placement;
- R packing rotation;
- mouse-wheel/number carried-item selection;
- carried-item visual;
- contextual interaction HUD;
- F6 diagnostics where available.

Opening the zoning editor leaves the player at the exact ladder position and height.

Ladder movement is suspended while the modal editor is open.

Closing it returns to the same attached state.

No storage system is taught about ladders.

No storage range is globally increased merely because a ladder exists.

---

## 17. Proof Installation

The promoted three-level ground-access rack should remain intact as the ground-access reference.

The ladder proof gets a **separate deliberately taller ModularRack installation**.

This avoids rewriting prior ergonomics evidence merely to construct the next experiment.

The proof rack should:

- use the existing reusable `ModularRack` authoring system;
- clearly place its highest usable storage beyond comfortable normal standing access;
- remain within the current 3.40 m review ceiling condition initially;
- place one `FixedLadder` approximately near its centre;
- retain enough width to test meaningful left/right reach from one fixed climb line;
- use real functional `StorageSurface`s;
- use representative catalogue items.

The ladder can then be moved slightly off-centre during human experimentation without architectural changes.

The current Metal Shelf is a valid future installation target, but the **single-rack proof does not need a second storage family to pass**.

The reusable ladder architecture must simply avoid a `ModularRack` dependency.

---

## 18. Technical Validation

Automated/focused verification should establish:

1. changing `ladder_height_m` updates visible height, collision and top markers while preserving the functional width/depth envelope;
2. invalid root scaling/pitch/roll or unusable overhead configuration produces authoring warnings;
3. front + W attaches;
4. lateral crossing does not attach;
5. stationary overlap does not attach;
6. attached W/S moves only vertically and ignores camera pitch;
7. A/D and Shift do not create attached movement;
8. releasing movement holds height;
9. yaw cannot exceed the configured ladder-relative clamp;
10. top movement stops at the lower of the visibility and ceiling-safe limits;
11. the full player collider remains below the authored overhead limit;
12. bottom descent releases correctly;
13. continued S backs the player away;
14. reattachment remains blocked until the approach volume is exited;
15. carried-item identity/content survives attach, climb and detach;
16. ladder collision does not block item/storage targeting;
17. modal zoning produces no ladder movement;
18. ordinary non-ladder movement and current storage behavior remain unchanged.

The final automated pass should remain proportional.

This proof does not justify a new general traversal-test framework.

---

## 19. Human Proof Questions

Human playtesting is the decisive gate.

The proof should answer:

- Does frontal attachment happen when expected without accidental side capture?
- Is the X/Z attach correction unobtrusive?
- Does W/S climbing feel immediately understandable?
- Is one climb speed sufficient?
- Is the provisional yaw range useful without feeling detached from the ladder?
- Can the player inspect enough of the shelf's width from one fixed climb line?
- Can the player reach useful shelf depth without creating a new global interaction range?
- Does the top position provide clear enough visibility over the highest shelf?
- Does ceiling protection feel natural rather than artificially low?
- Are rails/rungs visually obstructive enough to harm targeting even though interaction rays pass through them?
- Do pickup, retrieval, auto-store, manual placement and packing rotation feel natural while attached?
- Does bottom release/back-away behavior avoid immediate recapture?
- Does the ladder look like deliberately installed infrastructure rather than an arbitrary traversal prop?
- Does the extra storage capacity justify the interaction cost?

The proof is allowed to reveal that some wide/deep installations are unsuitable for fixed ladders.

---

## 20. Promotion Boundary

### PROMOTE

PROMOTE should mean the fixed-line interaction is sufficiently predictable and comfortable that selected taller installations may deliberately use it.

Promotion would **not** mean:

- all tall shelves need ladders;
- every ladder visual asset is production-ready;
- all ladder dimensions are finalized;
- ladder placement becomes automatic;
- a second or third ladder model has been authored;
- general climbing has been approved.

### REVISE

REVISE is appropriate if the basic model works but needs tuning to:

- climb speed;
- player standoff;
- approach depth;
- height relationship;
- yaw clamp;
- top margin;
- proof-rack geometry.

A stronger redesign should only follow concrete evidence that the fixed-line model itself fails.

---

## 21. Parameters Deliberately Left Provisional

| Parameter | Initial direction |
|---|---|
| Climb speed | One value; tune in human test |
| Yaw clamp | ±80° starting point |
| Ladder/player standoff | Minimum that prevents collision and feels visually attached |
| Approach depth | Shallow |
| Facing/forward thresholds | Permissive enough for natural frontal approach |
| Top view margin | Small positive eye-above-ladder-top margin |
| Ceiling safety margin | Small collision-safe margin |
| Common width/depth envelope | Derive from the first normalized ladder asset |
| Minimum/maximum authorable height | Set from practical bunker/storage ranges after asset inspection |

These numbers are tuning handles, not design promises.

---

## 22. Architecture Summary

The proof consists of three bounded changes.

### 22.1 Reusable `FixedLadder`

A reusable height-authorable `FixedLadder` owns:

- visuals;
- coarse collision;
- approach detection;
- climb anchor;
- climb-limit geometry;
- authoring validation.

### 22.2 Minimal Player-Controller Ladder State

A minimal ladder-attached branch is added to the existing player controller while retaining:

- the current `CharacterBody3D`;
- the current camera;
- carried items;
- HUD;
- pickup;
- storage placement;
- zoning;
- packing rotation.

### 22.3 One Dedicated Taller-Rack Proof Installation

One intentionally taller storage installation asks whether the interaction genuinely improves storage ergonomics.

No:

- rack-ladder coupling;
- top-shelf metadata;
- rung simulation;
- generalized traversal system;
- new storage architecture

is required.

---

## 23. Source Authority / Existing Constraints

This design preserves the currently promoted foundations:

- accepted whole-wing spatial baseline;
- continuing gameplay scene;
- deterministic storage and support stacking;
- review-scene supply reuse;
- reusable functional `ModularRack` authoring;
- Storage Unit Orientation & Zoning Basis;
- Canonical Item Storage Pose & Shelf-Front Alignment;
- 40-item eligible catalogue reconciliation.

Relevant current authorities:

- `Sorting_Apocalypse_Preliminary_GDD_v0.10.docx`
- `Sorting_Apocalypse_Prototype_Findings_v0.10.docx`
- `Sorting_Apocalypse_Visual_Design_Direction_v0.7.docx`
- `docs/CURRENT_STATE.md`
- `docs/testing/shelf-ceiling-ergonomics-comparison.md`
- `docs/testing/modular-rack-authoring-validation.md`
- `docs/testing/storage-unit-orientation-zoning-validation.md`
- `docs/testing/canonical-item-storage-pose-validation.md`

The technical design is intended to preserve those promoted systems rather than reopen them.

---

## 24. Next Step After Approval

If this design is approved:

1. inspect the authoritative local player/controller and proof-scene context;
2. write a bounded implementation plan;
3. get human approval of that plan;
4. prepare a fresh Codex handoff;
5. implement and run focused technical verification;
6. perform the human fixed-ladder playtest;
7. PROMOTE or REVISE;
8. only after the human ladder decision, resume Receiving unless the proof exposes another concrete storage blocker.
