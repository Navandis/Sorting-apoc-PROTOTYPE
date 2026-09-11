# Singleton Shelf Vertical-Clearance Fix Playtest

## Status and setup

`AWAITING HUMAN GAMEPLAY VALIDATION`

Run `main.tscn` from a fresh state with current assets imported. Use `F6` to identify storage levels and clear earlier test items between scenarios. Record the tested build/commit and a pass or concrete failure for every section.

The primary closed-shelf fixture is `SM_ventilated_locker` level 3. It is an interior level with approximately `0.321610 m` physical clearance. Computer Mouse 01 is the positive control; Gas Cylinder 01 is the tall negative control. Computer Tower 01 and standing Pants 02 may be repeated as additional tall controls, but do not alter their poses or footprints.

## A. Original clipping reproduction and automatic fix

1. Zone an empty area of `SM_ventilated_locker` level 3 as General or as the selected item's matching category.
2. Carry Gas Cylinder 01 and use automatic placement while looking at that level.
3. Require rejection before any reservation or world item is created. The item must remain carried and must not penetrate the level above.
4. Repeat with Computer Tower 01 if available. Require the same physical rejection.

Before the fix, automatic empty placement could reserve and commit the tall singleton because it checked only horizontal cells and zones.

## B. Manual ghost and final-placement fix

1. Carry Gas Cylinder 01, switch to manual mode, and aim at empty enabled cells on the same level.
2. Require a blocked/red ghost rather than a valid placement preview.
3. Press `E`. Require no placement, no reservation, and no carried-item loss.
4. Rotate with `R` and repeat. Require identical vertical rejection; the Y-only packing rotation must not change seated height.
5. Repeat once with Computer Tower 01 or standing Pants 02 if available.

Ghost and final placement must agree. A green ghost followed by rejection, or a red ghost followed by placement, is a failure.

## C. Short-item positive control

1. Carry Computer Mouse 01 and target empty enabled cells on the same level.
2. Require valid automatic placement.
3. Retrieve it, switch to manual placement, and require a valid ghost and successful final placement.
4. Confirm the item remains visibly seated above the shelf plane and below the enclosing geometry.

The fix fails if it rejects this visibly fitting control.

## D. Normal stacking control

1. Use `SM_MetalShelves2` level 1.
2. Place Computer Tower 01 manually in its fitting `3x5` packing orientation.
3. Place Book 01 on the Tower.
4. Require the existing valid Tower/Book stack to remain accepted and visibly separated from the upper shelf.
5. Try Med Kit 4 on the Tower and require the existing footprint-and-clearance rejection.

This is a control only; do not change Stack Roles, Auto Groups, insertion, promotion, or the 95% stack headroom.

## E. Genuine open-top context

1. Use the highest generated level of `SM_MetalShelves2`, which is a genuine exterior/open-top storage surface with an explicit per-instance `0.615730 m` physical cap.
2. Place a visibly fitting singleton automatically and manually. Require acceptance.
3. Try a singleton whose seated top visibly exceeds that cap. Require automatic rejection and a blocked manual ghost/final placement.
4. Confirm this surface does not behave as unlimited height and does not use another shelf instance's cap.

## F. `SM_ventilated_locker2` classification check

`SM_ventilated_locker2` is physically enclosed. Its four generated StorageSurfaces are interior surfaces; level 4 is the highest valid interior storage level. There is no authored exterior/top storage grid. The current generic profile installer obtains level 4's `0.519 m` cap through the final-level per-instance clearance route, but this does not make the visual locker open-top.

1. Inspect level 4 and confirm it is inside the locker enclosure.
2. Verify a fitting singleton is accepted and an over-height singleton is rejected against the `0.519 m` cap.
3. Confirm no exterior/top grid appears above the locker.

Do not add an exterior surface as part of this validation.

## Acceptance question

Does rejection now occur before a visually impossible shelf penetration, without rejecting items that visibly fit? The defect remains awaiting human validation until sections A–F pass in-game.
