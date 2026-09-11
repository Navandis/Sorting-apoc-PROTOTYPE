# `loot_000010` Pickup Fix Playtest

This is a narrow validation for `SM_Dry_Goods_01g.glb`. It is not the
catalogue-scale stacking stress test.

## A. Original reproduction

1. Run `main.tscn` and approach the taller `Dry Goods 01g` can at approximately
   `(5.44, 0.87, 2.42)` in the dry-goods cluster.
2. Aim at the can from within normal pickup range.
3. Observe that the reticle does not identify `Dry Goods 01g`. If the ray also
   crosses another loot proxy, that other item may be identified instead.
4. Press LMB while aiming at `Dry Goods 01g`.

Before the fix, the visible can stayed in the world and `loot_000010` was not
added to the carried bundle.

## B. Fixed path

1. Run `main.tscn` from a fresh state and approach the same `Dry Goods 01g`
   can within normal pickup range.
2. Aim directly at the can from a clear, slightly elevated angle.
3. Confirm the contextual prompt names `Dry Goods 01g` and offers
   `[LMB] PICK UP`.
4. Press LMB once.
5. Confirm the carried bundle gains `Dry Goods 01g` and the world can is
   removed. A second click must not duplicate it.

## C. Adjacent regressions

1. Pick up one nearby `Dry Goods 01c` (`loot_000009`) can and the nearby
   `Dry Goods 01a` (`loot_000008`) can.
2. For each item, confirm the prompt names the aimed-at item, LMB adds exactly
   one carried item, selection remains valid, and the picked world instance is
   removed.
3. Place one of those carried items through the normal storage interaction and
   confirm the carried bundle updates once and the stored world item appears.
4. Retrieve that stored item with LMB and confirm it returns to the carried
   bundle once and its stored world instance is removed.

Record the build/commit tested and whether every check above passed. The bug
remains awaiting human validation until this playtest is completed.
