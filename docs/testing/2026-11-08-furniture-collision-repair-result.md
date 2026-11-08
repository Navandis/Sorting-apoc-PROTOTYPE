# Furniture Movement Collision Repair

**8 November 2026 · HUMAN-ACCEPTED / PUBLISHED / CLOSED IN ITS BOUNDED SCOPE**

Repair branch `codex/furniture-movement-collision` starts at the accepted expedition close-out `82207db3258a22b2b81acaf3badf05bdff74a065`. The developer's report lists the four tables and three storage units in the expedition result. Onset remains unknown. [Original report](2026-11-08-expedition-to-storage-loop-result.md#open-furniture-movement-collision-follow-up).

## Cause and repair

The F5 run shell adds both New Run and Continue candidates to the tree while hidden. The runtime collision generator then rejected their furniture meshes because `is_visible_in_tree()` included the hidden wing root. Publishing the wing did not rerun initialization. The visible standalone wing generated one movement shape per affected fixture. The authored rack, ladder and Receiving barrier provided working controls.

- [environment_collision.gd](../../environment_collision.gd) adds an opt-in branch-local visibility check and makes initialization idempotent. The existing convex generation uses the authored meshes and transforms.
- [seeded_storage_setup.tscn](../../gameplay/logistics_wing/development/seeded_storage_setup.tscn) and [functional_fixtures.tscn](../../gameplay/logistics_wing/functional_fixtures.tscn) enable the check for the two affected fixture groups. Hidden descendants remain excluded.
- [furniture_movement_collision_tests.gd](../../tools/asset_pipeline/tests/furniture_movement_collision_tests.gd) exercises the actual player capsule, ordinary targeting and the isolated run shell.

## Evidence

| Check | Observation |
| --- | --- |
| Baseline capsule sweeps | All seven fixtures had zero enabled movement shapes in both F5 New Run and Continue. The capsule crossed the furniture bounds from the accessible floor-level approaches. Standalone F6 blocked the same approaches. Baseline exited 1 with 28 expected assertions. [Baseline log](evidence/furniture-collision-repair-2026-11-08/baseline.log). |
| Repaired capsule sweeps | One aligned blocker per fixture in New Run, Continue and F6, with all 26 accessible face and diagonal approaches blocked in each. Adjacent movement remained possible. Repeated setup kept one blocker per fixture. The ladder-side, rack and Receiving barrier probes still blocked. |
| Interactions and continuation | The production reticle picked up stock at all four tables. Automatic placement and reticle retrieval worked on the locker and both shelf units. The isolated snapshot matched after Continue, preserving exact item ownership, stored organization, zoning, grid state, goal state and player pose. Only item transfers changed collection credit. |
| Native Compatibility | At 1280×720, the normal W input moved the player 0.178 m toward SeedWest and 0.181 m toward Gallery A West before stopping. The corresponding capsule sweeps stopped at 0.178 m and 0.183 m. The focused native script exited 0. [Log](evidence/furniture-collision-repair-2026-11-08/native.log) · [Table](evidence/furniture-collision-repair-2026-11-08/table-movement.png) · [Shelf](evidence/furniture-collision-repair-2026-11-08/shelf-movement.png). |

The headless focused test and six selected regressions exited 0. These were startup parity, wing storage bridge interaction, collection continuation (136 checks), wing seed fixtures, fixed ladder player and storage command validation. Logs contained the known Windows certificate-store and held-material diagnostics and the deliberate invalid seed-fixture diagnostics.

**Existing saved pose.** A copy of the current collection slot restored at `(-6.767843, 0.000127, 3.812810)`, overlapping the restored Food palette table blocker. On the copy, normal movement in the S direction let the physics controller separate onto the tabletop and then walk down to the floor. The restored pose was preserved until ordinary movement stepped it. [Copied-slot log](evidence/furniture-collision-repair-2026-11-08/copied-slot.log).

The original M4 and current collection pointers and pointed snapshots matched their pre-test SHA-256 hashes. All runs used temporary slots, a temporary application profile or the preserved copy. The current collection snapshot retained SHA-256 `D236E854A3CE14D7CC1DA8DAE96D5898D1ECDC19FAB8F2D1F26A3D904604BDC5`.

The repair uses the existing movement layer and preserves the separate item and storage targeting layers. The authored meshes, transforms, grids, storage rules, lift, expedition mechanics and save schema are unchanged.

## Retest instructions from the repair handoff

Use F5 Continue. If it starts inside the Food palette table in the reported saved view, hold S until you are back on the floor. Approach the four tables, Gallery C locker and both metal shelves from an accessible side. The player should stop at the furniture and still be able to walk alongside it. Pick up table stock and place and retrieve an item on the shelves. The expedition acceptance remains closed.

## Developer acceptance · 8 November 2026

The developer confirmed in-game that all seven affected fixtures now block player movement as intended, the shelves still work for normal storage, and no additional issue surfaced during the retest.

Codex’s earlier verification covered the hidden-wing initialization cause and the scoped fix that avoids duplicate blockers. It recorded 26 accessible capsule-sweep approaches in each of New Run and Continue, native Compatibility movement checks, table pickup, shelf placement and retrieval, and six passing regressions. The Food palette table overlap and backward `S` escape were observed by Codex on an isolated save copy. The original save was preserved. The date the defect was introduced remains unknown.

The developer closed the repair in its bounded scope on 8 November 2026. The accepted chain was published to `origin/main` on 8 November 2026. An independent remote check matched the acceptance commit `de6b9bd7102e555b46a45f6733d9e7669db5d3b5`. The earlier expedition and collection foundation acceptances remain closed.
