# Stacking Stabilization Pass — Manual Validation

Use the stacking-spike scene and ordinary player controls. Keep the storage clearance and item authoring data unchanged during this pass.

## A. Base retrieval and ordinary replacement

1. Zone two shelf surfaces as General.
2. Build a deterministic stack with at least three compatible members, such as Book/CD media or compatible cans.
3. Aim at the base member and pick it up with LMB.
4. Without removing either survivor, enter manual mode with M and place the carried base in empty enabled cells on the same shelf with E.
5. Confirm the item appears at the ghost location, the promoted survivor stays the base of the original stack, and no hidden occupied cells remain at the original base footprint edges.
6. Repeat, placing the removed base on the second shelf.
7. Repeat once while carrying only the removed base.
8. Repeat once with another item already carried; select the removed base before E and confirm that only a successful placement advances selection to the remaining item.

## B. Immediate same-surface return

1. Build another stack with at least three members.
2. Pick up its base while leaving the promoted stack in place.
3. Aim at a valid empty enabled location on that same shelf.
4. Press E once.
5. Confirm E stores the selected base as an ordinary separate placement. It must not merely rotate the item, leave it carried, or switch selection without storing it.
6. Repeat in automatic mode with enough General space for a separate destination. A larger removed base must not be inserted beneath the smaller promoted base.

## C. Contextual manual orientation

1. Use a shelf whose usable depth is four cells.
2. Manually place a MedKit/compatible base stack in the fitting 4×5 packing orientation.
3. Set the next compatible MedKit's manual R preference to the non-fitting 5×4 orientation.
4. Aim directly at the existing stack.
5. Confirm the ghost automatically uses the valid 4×5 alternative and is green.
6. Place it and confirm the final packing yaw matches the ghost.
7. Before placing another item, leave the stack target and aim at ordinary empty space. Confirm the manually selected R preference still governs the normal ghost.
8. Check a roomy stack where both orientations fit; confirm the preferred orientation is retained.
9. Check a stack where neither orientation fits; confirm the ghost remains invalid/red.

## D. Erased cells are disabled

1. Open zoning on a fresh surface and confirm the first interaction initializes it to General 100%.
2. Erase a visible region, leaving another region General.
3. Auto-store several items and confirm none use erased cells.
4. Leave a compatible stack whose base reservation is inside a region, erase that region, then auto-store another compatible member. Confirm it does not join that stack.
5. In manual mode, aim at erased cells and confirm the ghost is invalid/red and E does not place.
6. Aim at an enabled cell carrying an item whose category differs from that specific zone; confirm manual placement remains allowed.
7. Confirm General continues to accept items from every storage category.

## Deferred design records

`BASE_PROMOTION_SMART_INSERTION — PROTOTYPE REFINEMENT PENDING DESIGN`

`MIXED_STACK_AUTO_COHERENCE — REQUIRES BROADER CONTENT PLAYTEST`

This stabilization pass does not implement either deferred behavior and does not refactor shelf clearance.
