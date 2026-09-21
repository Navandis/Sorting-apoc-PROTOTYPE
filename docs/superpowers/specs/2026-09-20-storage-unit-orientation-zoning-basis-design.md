# Sorting Apocalypse — Storage Unit Orientation & Zoning Basis Design

**Date:** 20 September 2026  
**Status:** Design approved in conversation; written-spec review pending  
**Prerequisite:** Reusable modular-rack authoring milestone must be human-PROMOTED, closed out, merged/synchronized to `main`, and clean before this work begins.  
**Next gate after this one:** Single-rack fixed-ladder proof, unless item packing orientation is explicitly promoted into an immediate follow-up after human review.

## 1. Purpose

Define one explicit semantic orientation contract for every storage **unit** that owns one or more `StorageSurface`s.

The contract must make the following concepts consistent without rotating or rebuilding the deterministic physical grid:

- unit Front / Right / Back / Left;
- all StorageSurfaces belonging to that unit;
- the 2D zoning editor's presentation;
- the physical cells affected when a player paints a semantic zone.

The feature exists because current prototype behavior lets imported furniture axes leak into player-facing zoning semantics. The result can be:

- wide shelves displayed 90° from their physical shape in the zoning UI;
- FRONT/BACK labels reversed relative to the intended unit orientation;
- zones that appear on an unexpected side of a shelf in world space;
- inconsistent interpretation across Metal Shelves, Lockers and Modular Racks.

This milestone corrects the **storage-unit semantic basis and zoning mapping**.

It deliberately does **not** redesign item packing yaw or canonical item storage poses.

## 2. Ownership: orientation belongs to the storage unit

Front/Right/Back/Left is authored once per storage **unit/rack**, not per individual shelf surface.

Examples:

```text
ModularRack_A
├── unit orientation = state 0
├── Shelf_01 → StorageSurface inherits state 0
├── Shelf_02 → StorageSurface inherits state 0
└── Shelf_03 → StorageSurface inherits state 0

ModularRack_B
├── unit orientation = state 2
├── Shelf_01 → StorageSurface inherits state 2
└── Shelf_02 → StorageSurface inherits state 2
```

Two placed instances of the same furniture family may have different authored orientation states.

All surfaces belonging to one unit must share the same semantic orientation.

No individual surface-level Front/Back override is supported.

## 3. Four-state semantic orientation

The unit stores one integer quarter-turn state:

```text
0
1
2
3
```

The four directions are always a cyclic orthogonal frame. They are never independently editable.

This guarantees that invalid arrangements such as:

```text
Front, Back, Right, Left
```

cannot be authored.

The unit authoring UI exposes:

- current quarter-turn state;
- `Rotate Storage Directions CW`;
- `Rotate Storage Directions CCW`.

Each action advances or reverses the entire four-direction frame by one shelf side.

A direct numeric/enum state may remain visible for diagnostics, but normal authoring should use the two rotation controls.

## 4. Approved default convention

Every storage unit has a valid non-null default.

**State 0 is:**

```text
Front = local +Z
Back  = local -Z
Right = local +X
Left  = local -X
Up    = local +Y
```

This is a storage-system default, not a claim that every imported furniture asset visually faces +Z.

The developer expects to review and adjust each placed unit.

The default is chosen because the existing `StorageSurface` physical grid already behaves as:

- column increases from local -X → +X;
- row increases from local -Z → +Z.

Therefore state 0 maps the current physical grid naturally to:

```text
physical cell (0, 0) = semantic back-left
```

and requires no permutation for an unrotated zoning view.

## 5. Explicit state mapping

Let the physical StorageSurface grid be:

```text
W = physical grid_size.x
D = physical grid_size.y
x = physical column, 0..W-1, local -X → +X
z = physical row,    0..D-1, local -Z → +Z
```

Let semantic zoning coordinates be:

```text
u = left → right on zoning canvas
v = back → front on zoning canvas
```

The four states are:

| State | Front | Right | Back | Left | Semantic grid size |
| --- | --- | --- | --- | --- | --- |
| 0 | +Z | +X | -Z | -X | W × D |
| 1 | +X | -Z | -X | +Z | D × W |
| 2 | -Z | -X | +Z | +X | W × D |
| 3 | -X | +Z | +X | -Z | D × W |

Semantic → physical cell mapping:

```text
state 0: x = u           z = v
state 1: x = v           z = D - 1 - u
state 2: x = W - 1 - u   z = D - 1 - v
state 3: x = W - 1 - v   z = u
```

The inverse mapping must also be implemented and tested.

CW/CCW button behavior must follow this exact state sequence. If Godot's inspector/world-view visual sense makes the button labels feel reversed in practice, correct which button increments/decrements the state; do not change the state table or silently redefine saved orientation values.

## 6. Player-facing zoning view

The zoning editor always presents the storage unit **as viewed from its authored Front**.

The player's current world position and approach direction are irrelevant.

On screen:

```text
top    = Back
bottom = Front
left   = unit Left when viewed from Front
right  = unit Right when viewed from Front
```

A free-standing open rack therefore has one stable zoning view even if the player opens the editor from its physical back or side.

Rotating the unit's authored semantic orientation changes the zoning presentation, not based on player viewpoint but based on the unit's authored state.

For rectangular surfaces, states 1 and 3 naturally swap zoning-canvas width/depth.

## 7. Physical grid remains authoritative

Do not rotate, reorder or rebuild the underlying `StorageSurface` grid solely to change semantic orientation.

The existing physical data remains:

- `_cells`;
- `_zone_cells`;
- reservations;
- stack origins;
- item-to-stack ownership;
- physical `grid_size`;
- physical StorageSurface transform;
- F6 world grid.

The new system adds a reversible semantic mapping on top.

This separation minimizes migration risk:

```text
physical storage coordinates = deterministic implementation truth
semantic coordinates         = player-facing zoning view
```

Automatic placement continues searching the existing physical zone cells.

If the zoning UI paints the correct mapped physical cells, auto-placement automatically uses the intended world-space portion of the shelf without a second placement system.

## 8. Shared orientation helper

Create a small pure mapping unit, recommended:

`res://storage_orientation.gd`

Conceptual responsibility:

```gdscript
class_name StorageOrientation

static func normalize_quarter_turns(value: int) -> int
static func semantic_grid_size(physical_size: Vector2i, quarter_turns: int) -> Vector2i
static func semantic_to_physical_cell(
    semantic_cell: Vector2i,
    physical_size: Vector2i,
    quarter_turns: int
) -> Vector2i
static func physical_to_semantic_cell(
    physical_cell: Vector2i,
    physical_size: Vector2i,
    quarter_turns: int
) -> Vector2i
static func front_local_axis(quarter_turns: int) -> Vector3
static func right_local_axis(quarter_turns: int) -> Vector3
```

This unit owns the permutation math.

Do not duplicate the four-state cell mapping independently in the UI, manager and StorageSurface.

## 9. Unit-level authoring component

### 9.1 Generic placed storage units

For storage units that do not already have an authoring root script, use a small child context:

`res://storage_unit_orientation.gd`

Recommended:

```text
SM_MetalShelves_GalleryA_West
└── StorageUnitOrientation

SM_ventilated_locker_GalleryC_West
└── StorageUnitOrientation
```

The component is `@tool` and exposes:

- quarter-turn state with default 0;
- CW action;
- CCW action;
- a readable summary such as:
  - `Front +Z | Right +X`;
  - `Front +X | Right -Z`;
  - etc.

The component has a stable API such as:

```gdscript
func get_storage_orientation_quarter_turns() -> int
func rotate_storage_directions_cw() -> void
func rotate_storage_directions_ccw() -> void
```

It contains no per-surface state.

### 9.2 ModularRack

`ModularRack` already has a developer-facing root authoring controller.

Expose the same orientation controls on the **ModularRack root**, alongside its length/depth/frame/inset controls.

The rack root implements:

```gdscript
func get_storage_orientation_quarter_turns() -> int
```

All generated rack surfaces receive that one value.

Do not require the developer to select each generated shelf surface.

### 9.3 Missing context

The storage backend must always have a usable value.

Resolution order:

1. storage unit/root implements `get_storage_orientation_quarter_turns()`;
2. otherwise direct child `StorageUnitOrientation` provides it;
3. otherwise use state 0.

Existing units must never receive null/undefined orientation.

For currently placed functional Metal Shelf/Locker units, add explicit orientation authoring context with state 0 so the developer can edit each instance directly rather than relying only on fallback.

## 10. StorageSurface semantic orientation metadata

Each runtime `StorageSurface` stores the inherited unit state:

```gdscript
var semantic_orientation_quarter_turns: int = 0
```

Add a configuration path such as:

```gdscript
func set_semantic_orientation_quarter_turns(value: int) -> void
func get_semantic_orientation_quarter_turns() -> int
```

or extend `configure()` only if doing so does not make the existing call sites materially harder to read.

Every surface generated for a single unit receives the same value.

Changing this metadata must not rotate the surface's physical transform.

## 11. Semantic StorageSurface API

Add player-facing zoning helpers to `StorageSurface`.

Recommended API:

```gdscript
func get_semantic_grid_size() -> Vector2i

func semantic_to_physical_cell(cell: Vector2i) -> Vector2i
func physical_to_semantic_cell(cell: Vector2i) -> Vector2i

func get_semantic_zone_category(cell: Vector2i) -> String

func set_semantic_zone_rect(
    category: String,
    first_cell: Vector2i,
    second_cell: Vector2i
) -> void

func clear_semantic_zone_rect(
    first_cell: Vector2i,
    second_cell: Vector2i
) -> void

func get_semantic_zone_rect_percentage(
    first_cell: Vector2i,
    second_cell: Vector2i
) -> float
```

### Semantic rectangle application

For this prototype, iterate every semantic cell inside the selected rectangle:

1. map it to one physical cell;
2. write the underlying `_zone_cells` entry;
3. emit `zones_changed` once after the batch.

This is simple, deterministic and avoids hidden dependence on rotation/corner ordering.

The surface's existing physical zone methods remain available to backend tests/systems that deliberately work in physical coordinates.

## 12. Zoning UI changes

`StorageZoneCanvas` becomes a semantic-coordinate consumer.

Replace use of:

```text
surface.get_grid_size()
surface.get_zone_category()
surface.set_zone_rect()
surface.clear_zone_rect()
surface.get_zone_rect_percentage()
```

for interactive zoning with:

```text
surface.get_semantic_grid_size()
surface.get_semantic_zone_category()
surface.set_semantic_zone_rect()
surface.clear_semantic_zone_rect()
surface.get_semantic_zone_rect_percentage()
```

The canvas itself still draws:

```text
BACK
...
FRONT
```

at top/bottom.

Because it now receives a semantic grid, those labels become truthful.

No player-location/camera calculation belongs in `StorageZoneCanvas` or `StorageZoneEditor`.

## 13. Existing zones and migration behavior

The underlying physical `_zone_cells` array is not reordered or migrated by this feature.

This means:

- current zone data remains attached to the same physical cells;
- changing only UI presentation does not corrupt physical storage state;
- setting a unit's authored quarter-turn changes how those physical cells are **interpreted/presented semantically**.

The orientation value is development/world authoring data. It is expected to be finalized before production save compatibility becomes a concern.

This milestone does **not** implement automatic rotation/migration of previously authored zones when a developer changes a unit's orientation state.

If persistent player save data later spans a shipped orientation change, that becomes explicit save-migration work.

## 14. Storage installation integration

### Existing family manager

When the storage manager installs Metal Shelf/Locker surfaces:

1. resolve the owning unit's orientation state once;
2. install all surfaces with existing physical profile transforms unchanged;
3. assign the resolved semantic state to every generated surface.

Do not change the existing Metal/Locker profile numbers merely to make the zoning UI look right.

### ModularRack

When `ModularRack.build_runtime_storage()` creates its surfaces:

1. use the already-promoted deck/support calibration unchanged;
2. use the current physical surface transforms/insets unchanged;
3. assign the rack root's semantic orientation state to every generated surface.

Do not rotate the F6 grid or Rack02 geometry to implement semantic orientation.

## 15. Current placed-unit authoring

The developer will manually review current units after implementation.

Required initial behavior:

- each existing placed functional unit receives default state 0;
- no attempt is made to infer a “correct” semantic front from walls, player paths or mesh appearance;
- the developer uses CW/CCW authoring controls to set the intended orientation for each placed unit.

For the retained shelf ergonomics review:

- ModularRack starter exposes its orientation at the rack root;
- runtime review Metal/Locker fixtures may use state 0 unless an authored review-specific control is justified;
- the review exists to validate mapping behavior, not to canonize those temporary fixture directions.

For continuing `wing_gameplay` functional fixtures:

- each placed Metal Shelf/Locker has an explicit editable orientation context;
- default 0 is acceptable until the developer reviews it.

## 16. Item packing orientation is out of scope

Do not intentionally modify:

- `StorageVisualPose`;
- authored item storage rotation metadata;
- native vs 90° packing choice;
- `_entry_orientations_for_item()`;
- automatic orientation preference;
- manual R behavior.

The semantic zoning change may expose different visual packing results because items are now directed to different physical cells.

That observed behavior must be human-reviewed **after** this milestone.

Possible outcomes after review:

1. current packing behavior is acceptable → proceed to ladder proof;
2. packing orientation is clearly wrong/confusing → open a small immediate follow-up;
3. packing is imperfect but non-blocking → record debt and proceed.

Do not preempt that decision inside this feature.

## 17. F6 and physical interaction

F6 remains a physical-world diagnostic.

It should continue showing the actual physical cell grid at the current `StorageSurface` transform.

Do not rotate F6 merely to mimic zoning-canvas orientation.

This distinction is intentional:

```text
F6 = physical deterministic grid
zoning editor = semantic player-facing view of that grid
```

Manual placement raycasting and nearest-cell selection remain physical and unchanged.

## 18. Testing requirements

### 18.1 Pure orientation mapping tests

For multiple rectangular sizes, including e.g.:

```text
8 × 3
3 × 8
7 × 7
```

test all four states.

For every physical cell:

```text
physical
→ physical_to_semantic
→ semantic_to_physical
```

must round-trip exactly.

For every semantic cell, the inverse round-trip must also succeed.

Test expected semantic grid dimensions for each state.

### 18.2 Exact corner tests

For a physical grid `W × D` verify:

State 0:

```text
semantic back-left   → physical (0, 0)
semantic front-right → physical (W-1, D-1)
```

State 1:

```text
semantic back-left   → physical (0, D-1)
semantic front-right → physical (W-1, 0)
```

State 2:

```text
semantic back-left   → physical (W-1, D-1)
semantic front-right → physical (0, 0)
```

State 3:

```text
semantic back-left   → physical (W-1, 0)
semantic front-right → physical (0, D-1)
```

### 18.3 Zone write/read tests

For every state:

1. paint a semantic front-left rectangle;
2. verify the expected physical `_zone_cells` region changed;
3. query it back semantically and confirm the same semantic rectangle is shown;
4. verify unrelated physical cells are unchanged.

Test erase and clear-all behavior.

### 18.4 Storage behavior preservation

Confirm:

- auto-placement still obeys physical zone cells;
- stack behavior unchanged;
- manual placement unchanged;
- F6 grid unchanged;
- stored item global scale unchanged;
- Metal/Locker/ModularRack physical surface transforms unchanged.

### 18.5 Unit inheritance

For a multi-surface unit:

- all generated surfaces receive one unit orientation;
- changing a second instance's orientation does not affect the first;
- no individual surface can silently diverge.

## 19. Human review

Human validation must include at least:

### Unit authoring

For two ModularRack instances:

1. leave one at default;
2. rotate the other with the authoring control;
3. save/reopen;
4. confirm independent states persist.

Repeat on at least one continuing-gameplay Metal Shelf or Locker orientation context.

### Zoning presentation

For each of the four orientation states on a clearly rectangular rack:

1. open the same surface in zoning;
2. confirm canvas aspect rotates appropriately;
3. paint a distinctive zone at semantic front-left;
4. close zoning;
5. use F6 / auto-placement to verify it occupies the expected physical side of the rack.

Approach the same open rack from its physical back and reopen zoning.

The 2D zoning view must remain identical because it follows authored Front, not player viewpoint.

### Cross-family check

Validate one:

- ModularRack;
- Metal Shelf;
- Ventilated Locker.

The semantic contract must behave consistently even though their imported mesh orientations differ.

## 20. Documentation and gate order

On human PROMOTE:

1. close out the orientation/zoning-basis milestone;
2. record the manually authored orientation state of current test/continuing functional units where useful;
3. explicitly review item packing orientation behavior;
4. decide whether packing requires an immediate follow-up;
5. if not blocked, proceed to the single-rack fixed-ladder proof.

The ladder proof must not begin before this milestone is validated.

## 21. Explicit non-goals

Do not implement:

- automatic semantic-front inference from room walls;
- player-position-dependent zoning views;
- per-surface orientation overrides;
- arbitrary non-orthogonal orientation;
- runtime player editing of storage-unit Front;
- automatic migration/rotation of historical zone data when developer orientation changes;
- canonical item-pose redesign;
- packing-yaw redesign;
- item auto-placement heuristics beyond existing zone behavior;
- changes to modular-rack physical deck calibration;
- ladder behavior;
- Receiving.

## 22. Completion boundary

A successful delivery establishes:

- one authored four-state orientation per storage unit;
- all unit surfaces inheriting that state;
- a stable player-facing zoning view from authored Front;
- reversible semantic↔physical cell mapping;
- current physical storage, F6, stacking and placement behavior preserved.

It does **not** claim item packing orientation is final.
