# Stack Role Batch 3 Focused Visual Review

## Scope

This is a proportional authoring check for `loot_000014`
(`SM_FirewoodPile_01.glb`). It does not start Auto Group review or
catalogue-scale gameplay stress testing.

The provisional role is `can_be_stacked = true` and
`can_support_stack = false`. The open question is whether the stored firewood
pile provides a stable resting interface when centered on a suitable broad
support. Its uneven logs are not provisionally a credible upper support.

## Reproducible check

1. Run `main.tscn` with current assets imported.
2. Place `Firewood Pile 01` on an empty shelf in its approved storage pose.
3. Inspect it from both sides and above, confirming that it rests without
   leaning, nesting, or requiring an X/Z offset.
4. Inspect whether the visible log surfaces form a broad, level, rigid area for
   a smaller centered item; do not infer support capability from a narrow or
   interrupted contact.

## Response

```text
loot_000014 — APPROVE
loot_000014 — ADJUST: false / false
loot_000014 — HOLD
```

`APPROVE` retains the conservative candidate. `ADJUST` is appropriate only if
the pile cannot credibly rest in the approved pose. `HOLD` preserves the
unreviewed record for a later focused fixture.
