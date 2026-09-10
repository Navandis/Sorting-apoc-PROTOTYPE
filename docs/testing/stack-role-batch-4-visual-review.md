# Stack Role Batch 4 Focused Visual Review

## Scope

This is a proportional authoring check for the two Batch 4 records carrying
`VISUAL_REVIEW_RECOMMENDED`. It does not start Auto Group review or
catalogue-scale gameplay stress testing.

| Stable ID | Asset | Provisional role | Visual question |
|---|---|---|---|
| `loot_000011` | `SM_PigCarcass_1.glb` | `false / false` | Can the irregular, deformable carcass rest as one stable centered member without deformation or skewering-dependent support? |
| `loot_000032` | `SM_Armor_02.glb` | `false / false` | Does the approved upright armor pose have a credible deterministic resting interface without leaning, deformation, or pose change? |

## Reproducible check

1. Run `main.tscn` with current assets imported.
2. Place each item on an empty shelf in its approved storage pose.
3. Inspect from above and both sides for a stable centered resting relationship;
   do not treat leaning, skewering, deformation, or a different pose as
   credible support.
4. Inspect upper surfaces separately. A soft, curved, interrupted, or
   deformable form is not a generic centered support surface.

## Response

```text
loot_000011 — APPROVE
loot_000011 — ADJUST: true / false
loot_000011 — HOLD
loot_000032 — APPROVE
loot_000032 — ADJUST: true / false
loot_000032 — HOLD
```

`APPROVE` retains the conservative candidate. `ADJUST` changes only reviewed
role booleans. `HOLD` preserves the unreviewed record for a later focused
fixture.
