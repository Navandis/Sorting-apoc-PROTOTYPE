# Sorting Apocalypse — Wing Modular Rack + Ladder Integration Plan

**Date:** 22 September 2026  
**Status:** Approved bounded pre-Receiving integration task  
**Current promoted main:** `7d9aeada780c94ddf4ccb01eff5e4ebe2f70c7c5`  
**Purpose:** Put one promoted functional `ModularRack` + `FixedLadder` installation into `wing_gameplay.tscn` so physical Receiving Stage B can be tested in the real logistics wing.

## 1. Goal

Add one real, functional ladder-served modular rack to the normal continuing gameplay composition.

The installation is a **pre-Receiving integration bridge**, not a production furnishing decision.

The developer has chosen **Gallery B as the initial placement area**. Codex does not need to search for, optimize, or infer a final gallery/socket. The developer will later move/refine the installation manually.

The task proves only that the promoted rack and ladder systems operate correctly inside:

```text
res://gameplay/logistics_wing/wing_gameplay.tscn
```

alongside the existing player, HUD, storage fixtures, palette, routes, and future Receiving work.

## 2. Why This Belongs in `wing_gameplay`

Physical Receiving Stage B is spatially coupled to the live logistics wing:

- the pile must fit and read correctly inside the accepted freight/elevator bay;
- the player must TAKE items from the real Receiving location;
- those items must be carried through the actual wing;
- real storage destinations must be available;
- future pile reach/drainability and route ergonomics need the accepted geometry.

Therefore `wing_gameplay.tscn` should become the primary live integration/human-validation composition for physical Receiving.

Hidden preparation/settling jobs may remain isolated when Receiving Stage B is implemented; this task does not change that architecture.

## 3. Placement / Authoring Decision

Initial placement:

```text
Gallery B
```

Codex should place the new rack/ladder in a **clearly usable, non-overlapping temporary Gallery B position**.

Do not spend time finding an optimal or final location.

Do not make architectural changes to Gallery B.

Do not move existing storage fixtures to "make room" unless the developer has already done so locally.

If no obviously safe temporary spot exists without moving accepted geometry/fixtures, stop and report the conflict rather than redesigning the room.

The developer will later move the installation to its final intended position.

## 4. Ownership and Scene Structure

The new rack should be a direct child of:

```text
WingGameplay/FunctionalFixtures
```

because the existing `StoragePrototypeManager` already discovers direct-child `ModularRack` instances and calls `build_runtime_storage()` for them.

The new ladder should also be a direct child of:

```text
WingGameplay/FunctionalFixtures
```

as an independently authored sibling installation.

This preserves the promoted architecture:

```text
FunctionalFixtures
├── existing Metal Shelf A
├── existing Metal Shelf B
├── existing Ventilated Locker
├── ModularRack_GalleryB_Initial
└── FixedLadder_GalleryB_Initial
```

The ladder is not owned by the rack technically.

Do **not** put either installation inside `DevelopmentSetup`.

`DevelopmentSetup` remains the item/palette authority. The new rack is live functional storage.

## 5. Starting Rack Configuration

Use the promoted ladder-proof installation as a **safe starting template**, not as a production standard.

Suggested initial values:

```text
rack length:       ~4.04 m
rack depth:        ~0.82 m
frame height:      ~3.00 m

shelf supports:
0.30 m
1.05 m
1.82 m
2.55 m
```

The developer may later alter:

- length;
- depth;
- frame height;
- number of levels;
- level distribution;
- position;
- yaw;
- per-edge insets;
- semantic Front;
- ladder position/height.

This task should not freeze those values as production constraints.

If the Gallery B ceiling/geometry makes the proof configuration physically unsuitable at the temporary position, adjust only enough to create a coherent temporary installation and report the actual authored values.

## 6. Starting Ladder Configuration

Use the promoted `FixedLadder` scene.

Suggested starting values based on the accepted proof:

```text
ladder height:      ~2.92 m
overhead limit:     match actual Gallery B local ceiling/clearance
yaw clamp:          promoted ±70°
climb speed:        promoted 1.65 m/s
```

Keep the ladder approximately centred on the rack initially.

No need to optimize offset.

Use the promoted functional front/storage-side convention.

Do not create a new ladder visual or ladder variant.

## 7. Existing Systems to Reuse

Reuse without redesign:

- `ModularRack`;
- its scene-local `Levels` wrappers;
- runtime `StorageSurface` generation;
- `StoragePrototypeManager`;
- F6 developer grids;
- storage orientation / authored Front;
- zoning;
- canonical item-facing;
- stacking;
- `FixedLadder`;
- player ladder movement;
- `DevelopmentSetup/SeedItems`;
- normal carried-item/HUD paths.

No new storage manager, rack registrar, ladder manager, or seed fixture is required.

## 8. Expected Surface-Count Change

Current normal wing:

```text
3 legacy storage units
12 functional surfaces
```

With a four-level modular rack:

```text
3 legacy units + 1 ModularRack
16 functional surfaces
```

Do **not** blindly change every `12` assertion to `16`.

Tests should distinguish:

- 12 established legacy surfaces;
- plus the actual authored level count of the new wing ModularRack.

Preferred invariant:

```text
expected_total =
    legacy_surface_count
    + sum(authored ModularRack levels)
```

For the initial four-level installation this evaluates to 16.

The existing storage manager installs legacy-family surfaces before ModularRack surfaces, so the established legacy surface ordering should remain unchanged. Verify this rather than depending on it accidentally.

## 9. Tests / Regressions to Update

Likely affected existing tests:

```text
tools/asset_pipeline/tests/wing_gameplay_composition_tests.gd
tools/asset_pipeline/tests/wing_storage_debug_f6_tests.gd
tools/asset_pipeline/tests/wing_storage_bridge_interaction_tests.gd
```

Update only the assertions that genuinely encode the old "exactly 12 total surfaces / no other StorageSurface" contract.

Preserve the existing legacy-fixture checks.

Add explicit checks that:

- one direct-child wing `ModularRack` exists;
- its authored local levels are present;
- it builds one runtime surface per valid level;
- its surfaces are included in `get_functional_surfaces()`;
- its semantic Front is present and inherited;
- the sibling `FixedLadder` exists;
- the ladder remains independent from the rack;
- default F6 shows/hides the new rack surfaces consistently;
- the three established legacy fixtures remain unchanged.

Do not make exact temporary world position a long-term regression invariant unless needed to prevent accidental overlap during this bridge task.

## 10. Focused Interaction Verification

Use the existing `DevelopmentSetup` palette.

Technically verify at least one representative loop against the new rack:

```text
palette item
→ pickup
→ carry
→ zone/auto-store on new rack
→ retrieve
→ manual place / R packing where useful
→ stack or ordinary store
```

Also verify:

- ladder attach/climb in `wing_gameplay`;
- interaction with a reachable upper rack surface while attached;
- carried item survives climbing;
- F6 includes all rack levels;
- zoning opens from authored Front;
- ordinary existing legacy shelf interaction remains intact.

Do not seed permanent items onto the new rack merely to make the test easier.

## 11. Human Validation

Launch normal Run Project or `wing_gameplay.tscn`.

The developer should perform a short bridge check:

1. reach the Gallery B temporary rack normally;
2. carry one or more items from the existing development palette;
3. zone at least one rack surface;
4. auto-store;
5. retrieve;
6. manual-place / rotate once;
7. climb the ladder;
8. interact with an upper level;
9. toggle F6;
10. confirm the rack/ladder can be selected and moved later in the Godot editor without architectural coupling.

The key human question is:

> **Does the promoted rack + ladder behave normally inside the continuing wing and provide a valid real storage destination for forthcoming Receiving items?**

This is not another ladder or storage-mechanics design gate.

## 12. Evidence Record

Create one concise record:

```text
docs/testing/wing-modular-rack-ladder-integration-validation.md
```

Status before human check:

```text
IMPLEMENTED / TECHNICALLY VERIFIED / HUMAN REVIEW PENDING
```

After human acceptance:

```text
IMPLEMENTED / TECHNICALLY VERIFIED / HUMAN PROMOTED
```

Record:

- exact rack/ladder authored values;
- initial Gallery B placement as temporary/developer-movable;
- resulting total surface count;
- focused tests;
- default-gameplay smoke;
- human disposition.

## 13. Documentation Scope

This is small logistics/integration work.

Do not perform a new GDD / Findings / VDD revision.

After human promotion, update only concise current operational docs if necessary:

```text
docs/CURRENT_STATE.md
docs/CODEX_BOOTSTRAP.md
docs/README.md
```

The new current state should say that `wing_gameplay.tscn` now contains at least one promoted functional ModularRack + FixedLadder installation and is ready to host physical Receiving Stage B integration.

## 14. Non-Goals

Do not:

- implement Receiving;
- modify the freight/elevator bay;
- generate a loot pile;
- change Receiving Stage A;
- optimize rack placement;
- furnish Gallery B;
- decide production gallery storage layout;
- decide production starting inventory;
- redesign ModularRack;
- redesign FixedLadder;
- add more ladders/racks;
- change camera/ceiling;
- change general interaction range.

## 15. Stop Condition

Stop when:

- one functional ModularRack exists in `wing_gameplay`;
- one promoted FixedLadder serves it;
- both are initially placed in Gallery B;
- the existing storage manager owns the rack's surfaces;
- normal wing surface-count contracts/tests are updated correctly;
- existing legacy storage remains unchanged;
- focused storage + ladder interaction works;
- F6 includes the rack;
- default gameplay smoke passes;
- human validation handoff exists.

Do not start physical Receiving Stage B in the same task.
