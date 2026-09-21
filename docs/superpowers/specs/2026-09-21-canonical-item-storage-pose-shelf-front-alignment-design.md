# Sorting Apocalypse — Canonical Item Storage Pose & Shelf-Front Alignment Design

**Date:** 21 September 2026  
**Status:** Conversational design approved; written-spec review pending  
**Prerequisite:** Storage Unit Orientation & Zoning Basis must be human-PROMOTED, closed out, merged/synchronized to `main`, and clean before implementation begins.  
**Next gate after this one:** Fixed-ladder proof, unless human item-pose review exposes a concrete blocker.  
**Separate optional debt:** Full 360° quarter-turn player display rotation.

## 1. Purpose

Make every newly stored loot item begin from one stable, item-authored canonical presentation and then align that presentation to the configured **Front** of the storage unit receiving it.

The desired authoring/runtime workflow is:

```text
untouched imported asset
        ↓
register as an ItemDefinition
        ↓
author storage_rotation_degrees
against a canonical shelf reference
        ↓
validated canonical stored pose
(desired item Front faces canonical shelf Front)
        ↓
place on any functional storage unit
        ↓
align canonical item Front to that unit's authored Front
        ↓
optionally apply the existing 90° packing rotation
        ↓
commit the placed item
```

Examples:

- a soup can's label is authored to face canonical Front;
- a cereal box's broad front panel is authored to face canonical Front;
- a hammer, rifle or other irregular asset may require pitch, yaw and roll corrections before its intended presentation faces canonical Front and rests naturally.

Once authored, the same item definition must present consistently on ModularRack, Metal Shelf, Ventilated Locker and future storage families that implement the promoted storage-unit orientation contract.

## 2. Core semantic distinction

Three concepts must remain separate.

### 2.1 Canonical item storage pose

Owned by the **ItemDefinition**.

Existing field:

```gdscript
storage_rotation_degrees: Vector3
```

continues to allow full pitch, yaw and roll.

Its refined meaning is:

> The three-axis correction that converts the untouched imported visual into the item's canonical stored presentation, authored against a canonical storage reference whose Front is +Z.

This includes both resting orientation and presentation orientation.

There is no separate explicit `item_front_axis` field in this milestone. The item's intended Front is implicit in the human-approved canonical pose.

### 2.2 Storage-unit Front

Owned by the **storage unit**, through the promoted four-state unit-orientation system.

For the physical StorageSurface basis:

```text
state 0: Front +Z / Right +X
state 1: Front +X / Right -Z
state 2: Front -Z / Right -X
state 3: Front -X / Right +Z
```

Every surface of one storage unit inherits the same state.

### 2.3 Packing rotation

Owned by the **individual placement**.

The existing boolean model remains for this milestone:

```text
packing_rotated = false
packing_rotated = true
```

Its meaning becomes purely:

```text
false = canonical front-aligned placement
true  = canonical front-aligned placement + one 90° packing turn
```

The 90° state may cause the item's front/label to face sideways. That is expected and permitted.

Storage flexibility takes precedence over presentation neatness when a player or the auto-packer chooses the rotated footprint.

## 3. Canonical reference convention

The canonical item-pose authoring reference uses the same state-0 convention as the promoted storage-unit orientation system:

```text
Front = +Z
Back  = -Z
Right = +X
Left  = -X
Up    = +Y
```

An item definition is considered correctly authored when, in this canonical reference:

- it rests in the intended physical stance;
- its intended display/front side points toward +Z;
- its canonical footprint metadata corresponds to that stance.

The raw imported asset is not modified.

No FBX/GLB/source-asset transform cleanup is required merely to satisfy storage presentation.

## 4. ItemDefinition contract

Keep the existing field:

```gdscript
@export var storage_rotation_degrees: Vector3 = Vector3.ZERO
```

Update its documentation/comment to the refined contract:

> Converts the untouched imported visual into its canonical stored pose. In the canonical unrotated stance, the item's intended Front faces storage +Z. Runtime aligns that canonical pose to the owning storage unit's authored Front, then applies the optional 90° packing rotation.

Do not replace this with yaw-only metadata, a separate imported-asset-front enum, per-storage-family item rotation, or per-unit item overrides.

One item definition must remain portable across all compatible storage units.

## 5. Canonical footprint meaning

The existing deterministic footprint remains item-authored and abstract rather than literal geometry.

For storage placement, the current two used footprint components are treated as the canonical state-0 footprint:

```text
canonical width  = across item/shelf Left ↔ Right
canonical depth  = along item/shelf Back ↔ Front
```

The canonical footprint is authored for the item's canonical front-facing pose.

This matters because storage-unit orientation now rotates that canonical pose relative to the physical StorageSurface grid.

Therefore a front-facing item does **not** always use the raw footprint dimensions in physical grid X/Z order.

## 6. Placement quarter-turn calculation

For a surface with unit orientation state:

```text
q ∈ {0,1,2,3}
```

and existing packing state:

```text
packing_rotated ∈ {false,true}
```

define:

```text
packing_turn = 0 if false, 1 if true

placement_quarter_turns =
    (q + packing_turn) mod 4
```

The visual placement yaw relative to the physical StorageSurface basis is:

```text
placement_yaw = placement_quarter_turns × +90°
```

| Unit state | Unit Front | Packing | Final visual quarter-turn |
| --- | --- | --- | --- |
| 0 | +Z | false | 0° |
| 0 | +Z | true | 90° |
| 1 | +X | false | 90° |
| 1 | +X | true | 180° |
| 2 | -Z | false | 180° |
| 2 | -Z | true | 270° |
| 3 | -X | false | 270° |
| 3 | -X | true | 0° |

For `packing_rotated = false`, the item canonical Front therefore always maps to the storage unit's authored Front.

For `packing_rotated = true`, the item is intentionally turned one additional quarter-turn.

## 7. Physical footprint calculation

The physical deterministic footprint must rotate with the visual presentation.

Given canonical footprint:

```text
canonical = Vector2i(width, depth)
```

use:

```text
placement_quarter_turns % 2 == 0
    → physical footprint = Vector2i(width, depth)

placement_quarter_turns % 2 == 1
    → physical footprint = Vector2i(depth, width)
```

This is required even when `packing_rotated == false`.

Example:

```text
canonical cereal box footprint = 2×1
```

On a state-0 shelf:

```text
canonical placement = 2×1
packing rotated     = 1×2
```

On a state-1 shelf:

```text
canonical placement = 1×2
packing rotated     = 2×1
```

The visual and reservation footprint must never disagree.

## 8. Small pure orientation helper

Add one small pure helper rather than spreading parity/yaw rules through the placement controller.

Recommended:

`res://storage_item_orientation.gd`

Conceptual API:

```gdscript
class_name StorageItemOrientation

static func placement_quarter_turns(
    unit_orientation_quarter_turns: int,
    packing_rotated: bool
) -> int

static func physical_footprint(
    canonical_footprint: Vector2i,
    unit_orientation_quarter_turns: int,
    packing_rotated: bool
) -> Vector2i

static func placement_yaw_radians(
    unit_orientation_quarter_turns: int,
    packing_rotated: bool
) -> float
```

The helper may reuse `StorageOrientation.normalize_quarter_turns()`.

Do not create a second storage-unit orientation table.

## 9. Visual transform hierarchy

Preserve the promoted canonical pose/seating implementation and keep storage-unit alignment distinct from packing rotation.

Recommended runtime hierarchy:

```text
Stored_<Item>
└── StoredUnitOrientationYaw
    └── StoredPackingYaw
        └── StorageSeating
            └── AuthoredStoragePose
                └── ImportedVisual
```

Responsibilities:

```text
StoredUnitOrientationYaw
    = unit orientation state q × 90°

StoredPackingYaw
    = existing 0° / 90° packing bool

AuthoredStoragePose
    = ItemDefinition.storage_rotation_degrees
      including pitch + yaw + roll
```

The same conceptual hierarchy applies to the manual-placement ghost.

This separation is intentional:

- unit yaw answers “which way does this storage unit face?”;
- packing yaw answers “did this particular placement use the alternate footprint?”;
- authored pose answers “how must this raw item asset be corrected to become its canonical stored presentation?”

Do not collapse those concepts into one authored Euler value.

## 10. StorageVisualPose responsibility

Retain `StorageVisualPose` as the owner of:

- authored three-axis item pose;
- seating/alignment to the support plane;
- current 0°/90° packing-yaw behavior where practical.

The storage-unit yaw should be applied **outside** the existing pose/seating path.

This minimizes risk to vertical seating, posed-height measurement, stack-clearance calculations and item-specific pitch/roll correction.

Do not make `storage_rotation_degrees` depend on the current shelf orientation.

## 11. StoragePlacementController integration

When targeting a StorageSurface, resolve:

```gdscript
unit_orientation_quarter_turns =
    surface.get_semantic_orientation_quarter_turns()
```

Use that state for both physical footprint selection and visual storage-unit yaw.

### 11.1 Entry creation

The existing entry builder must stop assuming:

```text
packing_rotated false → raw canonical footprint
packing_rotated true  → raw footprint swapped
```

Instead use the pure helper from section 8.

Conceptually:

```gdscript
func _entry_for_item(
    item,
    packing_rotated: bool,
    surface_orientation_quarter_turns: int
) -> StorageStack.Entry
```

The `StorageStack.Entry.packing_rotated: bool` field remains.

### 11.2 Auto-placement

Preserve current orientation preference:

1. canonical/front-facing candidate first;
2. 90° packing candidate second, only when the canonical footprint cannot satisfy the existing deterministic fit/stack selection.

Do not introduce a new visual-neatness score.

Do not change zoning priority, deterministic scan order, stacking priority, or category fallback.

### 11.3 Manual placement

`R` retains its current back/forth behavior:

```text
false ↔ true
```

For non-square canonical footprints it changes the physical footprint according to the combined unit+packing quarter-turn rule.

It is acceptable for `R` to turn the item's visible Front sideways.

### 11.4 Square footprints

Preserve current behavior for this milestone:

- square footprints do not gain a packing advantage from the 90° toggle;
- current `R` suppression for equal width/depth remains.

Allowing purely visual rotation of square items belongs to the future 360° display-rotation UX work.

## 12. Auto-placement and stack behavior

The canonical candidate remains first in orientation arrays.

For a target surface:

```text
candidate 0:
    packing_rotated = false
    visual Front aligns with unit Front
    physical footprint derived from unit state

candidate 1:
    packing_rotated = true
    visual adds 90°
    physical footprint derived from unit state + packing turn
```

Stack fit, base promotion, clearance and support rules remain unchanged once they receive the correct physical footprint and existing posed-height data.

The item-facing feature must not loosen or rewrite stack compatibility.

## 13. Placement is initialization, not a live constraint

Shelf Front determines a newly stored item's **initial/default orientation at placement time**.

It is not a continuous constraint.

After an item is committed:

- changing the StorageSurface/unit orientation metadata must not rotate that already-placed item's visual;
- moving around the shelf must not affect it;
- reopening zoning must not affect it;
- future gameplay rotation must be explicit.

The current runtime implementation should therefore set the item's storage-unit yaw once when constructing the stored visual/ghost and leave committed stored visuals unchanged thereafter.

## 14. Future save/load contract

No save/load system is implemented in this milestone.

However, this feature establishes a binding future rule:

> Loading a save restores each placed item's saved placement/orientation state. Load initialization must not recompute or “neaten” stored items from the current shelf Front.

A future save record must preserve enough per-placement state to reconstruct the player's chosen stored orientation, including at least physical placement/stack state and packing/display orientation state required by the implemented rotation model.

If the future four-quarter-turn UX expands placement orientation beyond the current boolean, save data must preserve that expanded state.

Changing a shelf's authored Front in a later map revision must not silently rotate items in an existing player save. Any such migration requires an explicit migration decision.

## 15. Canonical item-pose authoring fixture

Create a retained developer authoring/review scene dedicated to item storage pose.

Recommended path:

```text
res://gameplay/dev/item_storage_pose/item_storage_pose_authoring.tscn
```

with an `@tool` controller:

```text
ItemStoragePoseAuthoring
├── ReferenceShelf
├── CanonicalSurface
├── DirectionMarkers
│   ├── FRONT (+Z)
│   ├── BACK (-Z)
│   ├── LEFT (-X)
│   └── RIGHT (+X)
├── FootprintPreview
└── ItemPreviewRoot
```

The fixture is not a gameplay level.

### 15.1 Authoring input

The root exposes:

```gdscript
@export var item_definition: ItemDefinition
```

Assigning a definition:

- instantiates its `visual_scene`;
- applies its current `storage_rotation_degrees`;
- seats it using the same `StorageVisualPose` path as runtime;
- shows its canonical footprint;
- updates live when the definition changes.

Prefer editing the actual `ItemDefinition.storage_rotation_degrees` resource value rather than introducing a second scene-local rotation value that must later be copied back.

### 15.2 Visual reference

The fixture must make the canonical reference unmistakable.

At minimum show:

- a neutral horizontal support surface;
- FRONT at +Z;
- BACK at -Z;
- LEFT at -X;
- RIGHT at +X;
- footprint rectangle/cells centered under the item.

The human author adjusts `storage_rotation_degrees` until:

- the item rests correctly;
- the intended item Front points toward the visible FRONT marker;
- the footprint convention is sensible for the resulting pose.

### 15.3 Optional packing preview

The authoring fixture may expose a preview-only boolean:

```text
Show 90° packing state
```

to verify the alternate placement.

It must not change the definition's canonical pose or footprint metadata.

The default authoring view is always the canonical unrotated/front-facing stance.

### 15.4 No source mutation

The tool must not rotate or re-export source GLB/FBX assets, write transforms into the imported model scene, or create per-shelf pose overrides.

All authoring remains in `ItemDefinition`.

## 16. Item registration workflow

The intended developer workflow becomes:

1. import the source asset without storage-specific transform edits;
2. create/register the ItemDefinition through the existing item pipeline;
3. assign the visual scene and other item metadata;
4. open/select the definition in the canonical storage-pose fixture;
5. edit `storage_rotation_degrees` on all three axes as required;
6. validate that the intended item Front faces canonical +Z;
7. validate canonical footprint metadata;
8. save the ItemDefinition;
9. test the item on differently oriented storage units.

This milestone does not replace the existing item-registration pipeline.

## 17. Existing item definitions

Existing `storage_rotation_degrees` values were authored before the storage-unit Front contract was mature.

Do not automatically reinterpret or batch-rewrite them based on guessed asset axes.

After the system and authoring fixture work:

- the human reviews representative items first;
- then existing item definitions may be corrected through the canonical authoring workflow;
- any definition changed by the human should be treated as deliberate content authoring, not runtime compensation.

A catalogue-wide audit may be performed as an authoring pass, but it must not be replaced by inferred rotations from mesh geometry.

## 18. Cross-family behavior

The same validated ItemDefinition must behave consistently across ModularRack, Metal Shelf and Ventilated Locker.

For each family, canonical placement must point the item's intended Front toward that unit instance's authored Front.

Two instances of the same rack family with different unit-orientation states must therefore present the same canonical item at different physical world yaws while preserving the same semantic relationship:

```text
item Front → unit Front
```

## 19. Testing requirements

### 19.1 Pure quarter-turn/footprint tests

For unit states 0, 1, 2, 3 and both packing states:

- assert exact final quarter-turn;
- assert exact physical footprint parity;
- include asymmetric footprints such as 2×1 and 3×2;
- include square 2×2 and confirm footprint remains 2×2.

Expected for 2×1:

| Unit state | Packing false | Packing true |
| --- | --- | --- |
| 0 | 2×1 / 0° | 1×2 / 90° |
| 1 | 1×2 / 90° | 2×1 / 180° |
| 2 | 2×1 / 180° | 1×2 / 270° |
| 3 | 1×2 / 270° | 2×1 / 0° |

### 19.2 Canonical-front visual tests

Use a deliberately asymmetric test visual whose Front can be determined structurally.

For every unit state with `packing_rotated=false`:

- resulting visual Front axis must equal the surface/unit authored Front axis.

For `packing_rotated=true`:

- resulting visual Front must equal one quarter-turn from unit Front.

### 19.3 Three-axis authored pose preservation

Use a test item with nonzero pitch, yaw and roll.

Verify:

- canonical pose correction remains intact;
- unit alignment contributes only the outer yaw;
- 90° packing contributes only its outer yaw;
- authored pitch/roll are not flattened or recomputed.

### 19.4 Physical reservation consistency

For every unit state:

- reservation footprint equals the visual quarter-turn parity;
- ghost footprint equals committed footprint;
- no visual 2×1 / reserved 1×2 mismatch;
- manual and auto paths agree.

### 19.5 Auto preference

Provide a surface where canonical fit is available.

Assert auto-placement selects `packing_rotated=false`.

Provide a surface where only the alternate footprint fits.

Assert auto-placement selects `packing_rotated=true`.

Do not alter unrelated deterministic placement ordering.

### 19.6 Stack regressions

Test both canonical and rotated placements through stack insertion, stack retrieval, base promotion where already supported, and clearance checks.

Existing stack group/support semantics remain unchanged.

### 19.7 Placed-state stability

Place an item, snapshot its visual basis/transform, then change the surface's semantic orientation metadata.

Assert the already stored item's visual transform does not change.

Place a new copy after the metadata change.

Assert the new copy uses the new unit Front.

This directly pins the “placement initializes orientation; it is not a live constraint” rule.

### 19.8 Cross-family tests

Place the same asymmetric item definition on differently oriented ModularRack, Metal Shelf and Ventilated Locker.

Assert canonical placement aligns with each unit's Front and that canonical item scale is unchanged.

## 20. Human review

Human validation has two parts.

### 20.1 System behavior

Choose several visually asymmetric items, including:

- one package/can with an obvious label/front;
- one rectangular box;
- one irregular item requiring pitch/roll correction if available.

For each:

1. author/confirm the canonical pose in the fixture;
2. place it on at least two storage units with different Front states;
3. confirm unrotated placement faces each unit's authored Front;
4. press `R` on an asymmetric-footprint item;
5. confirm its footprint transposes and the item turns sideways;
6. toggle back and confirm it returns to canonical Front-facing placement;
7. verify auto-placement prefers canonical when it fits;
8. verify alternate packing is used when required.

### 20.2 Existing item-definition review

Use the authoring fixture to inspect existing item definitions.

The human decides whether current `storage_rotation_degrees` values still represent correct canonical poses under the newly meaningful Front convention.

Do not infer approval from previous tests that predate the unit-Front contract.

## 21. Optional 360° quarter-turn UX debt

Do not expand the current packing boolean in this milestone.

Record separately:

> Future item-display rotation may allow 0° / 90° / 180° / 270° manual states so players can choose which face of an item is displayed while organizing shelves.

That future feature would add presentation flexibility, not new rectangular packing shapes:

```text
0° and 180° share one footprint
90° and 270° share the transposed footprint
```

It will require an explicit placed-item orientation state rather than the current boolean.

Square items may gain meaningful visual rotation at that time.

## 22. Documentation and gate order

On human PROMOTE:

1. close out Canonical Item Storage Pose & Shelf-Front Alignment;
2. record any item definitions intentionally re-authored during validation;
3. keep full four-quarter-turn display rotation as optional UX debt;
4. proceed to the single-rack fixed-ladder proof unless the item audit exposes a concrete blocking content/system defect.

## 23. Explicit non-goals

Do not implement:

- full 360° quarter-turn player rotation;
- arbitrary free-angle item rotation;
- per-shelf item-pose overrides;
- automatic mesh-based item-Front inference;
- automatic batch correction of existing item definitions;
- source-asset rotation/re-export;
- player-facing item pose editor;
- save/load implementation;
- save migration;
- storage-unit orientation redesign;
- zoning redesign;
- modular-rack geometry/calibration changes;
- ladder behavior;
- Receiving.

## 24. Completion boundary

A successful delivery establishes:

- one canonical three-axis stored pose per ItemDefinition;
- canonical Front authored against a visible +Z reference;
- new unrotated placements aligned to each storage unit's authored Front;
- existing optional 90° packing retained as a separate placement choice;
- physical footprint rotated consistently with the final visual quarter-turn;
- canonical-first auto-placement preserved;
- committed items left unchanged after placement;
- a retained developer authoring fixture for future item registration/review.

It does **not** claim every existing loot definition has already been re-authored, and it does **not** implement future save/load or four-way display rotation.
