# Deferred Pickup Defects

`loot_000010` (`SM_Dry_Goods_01g.glb`) currently cannot be picked up in-game.
This defect predates the Stack Role pass and does not affect its approved Stack
Role value of `can_be_stacked = true`, `can_support_stack = true`.

No debugging or gameplay changes are included in the Batch 2 human-authoring
commit. Resolve the defect before the later catalogue-scale gameplay stress
test.
