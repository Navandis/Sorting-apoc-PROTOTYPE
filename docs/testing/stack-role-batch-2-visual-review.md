# Stack Role Batch 2 Focused Visual Review

## Scope

This is a proportional authoring check for the two Batch 2 records with
`VISUAL_REVIEW_RECOMMENDED`. It does not start Auto Group review or
catalogue-scale gameplay stress testing.

| Stable ID | Asset | Provisional role | Visual question |
|---|---|---|---|
| `loot_000016` | `SM_GasCanister_01.glb` | `true / false` | Does the stored top expose any broad, level, rigid surface that credibly supports a smaller centered item? |
| `loot_000027` | `SM_CoughSyrup_01.glb` | `true / true` | Is the stored bottle base stable and its cap sufficiently broad, level, and rigid for a smaller centered item? |

## Reproducible check

1. Run `main.tscn` with the current project assets imported.
2. Place each item on an empty shelf in its approved storage pose and inspect it from above and from both sides.
3. Confirm that the base rests without leaning, nesting, or an X/Z offset.
4. For the gas canister, inspect whether handles, caps, seams, or curvature interrupt every plausible upper support surface.
5. For the medicine bottle, inspect whether the cap provides a broad, level, rigid centered contact area rather than a narrow or rounded one.

## Response

Use one of the following lines in the Batch 2 response for each item:

```text
loot_000016 — APPROVE
loot_000016 — ADJUST: true / true
loot_000016 — HOLD
loot_000027 — APPROVE
loot_000027 — ADJUST: true / false
loot_000027 — HOLD
```

`APPROVE` accepts the provisional candidate. `ADJUST` records only the reviewed
role booleans. `HOLD` preserves the unreviewed record for a later focused
fixture.
