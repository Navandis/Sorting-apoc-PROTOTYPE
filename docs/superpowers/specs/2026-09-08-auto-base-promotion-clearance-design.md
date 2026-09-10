# Auto Base Promotion and Robust Stack Clearance Design

## Status

Approved on 2026-09-08 for TDD implementation. Stop at the focused human playtest handoff.

## Scope

Automatic placement may promote a larger compatible incoming item beneath an auto-coherent stack. Manual placement remains top-only. Mixed-stack automatic semantics, multi-column packing, item metadata, storage poses, physics, save data, and unrelated inventory behavior remain unchanged.

Closed-level physical clearance is derived from adjacent authored level `y_ratio` planes. Open-top clearance is explicitly authored per placed shelf in world metres through `StorageShelfClearanceContext`; family values are fallback-only and missing explicit authoring is surfaced. `MAX_STACK_USED_FRACTION = 0.95` remains the single global tuning authority and is applied exactly once.

## Automatic promotion

Within each automatic zone tier, search all stacks for ordinary insertion before searching all stacks for base promotion, then search empty placement. Tier order remains matching specific category followed by General.

Promotion requires an auto-coherent non-empty matching group, incoming support capability, a stackable existing base, an incoming orientation containing the existing base footprint, valid resulting height, and a valid expanded reservation. Existing entries keep relative order and packing rotation. Native incoming orientation is preferred; 90-degree packing orientation is tried only when native has no valid expansion.

For old origin `O`, old size `S`, and new size `N`, enumerate only origins in `[O + S - N, O]`, clipped to surface bounds. Each rectangle must contain the old reservation, contain only empty cells or the old owner, and consist entirely of the active tier category. Choose the origin with the smallest squared displacement between doubled rectangle centers, then lower row and lower column.

## Atomic ownership

Generalize base removal and base insertion through one validated base-transition primitive. All registry, reservation, cell, member lookup, ID-collision, containment, zone, support, and clearance checks occur before mutation. Commit performs only infallible in-memory assignments: entries, cell owner, reservation owner/key, stack key and ID, lookup values, `WorldItem` metadata, positions, and one notification.

The incoming ID becomes authoritative after insertion. The old base remains entry one and never remains an owner. Controller integration prepares the transition and visual before removing the carried item. An unexpected failure after removal restores the exact carry slot and selection, so failed promotion cannot perturb selection state.

## Clearance

For a closed level:

```text
local physical clearance = bounds.size.y * (next.y_ratio - current.y_ratio)
world physical clearance = local physical clearance * abs(furniture global Y scale)
usable limit = world physical clearance * MAX_STACK_USED_FRACTION
```

X and Z scale never participate. `StorageSurface` receives world physical clearance and applies the usable fraction only from `get_maximum_stack_top_y_m()`.

Every currently placed shelf receives an explicit `StorageShelfClearanceContext.open_top_clearance_world_m`: `0.919` for `SM_MetalShelves`, `0.615730` for `SM_MetalShelves2`, `0.519` for `SM_ventilated_locker2`, and `0.339945` for `SM_ventilated_locker`. These values are not multiplied by furniture scale. Family fallbacks remain available but emit a warning when used.

## Verification

Focused tests cover promotion rules, native/rotated orientation, expansion and tie selection, ownership rekeying, atomic rejection, tier and disabled-cell policy, controller carry rollback, manual top-only behavior, clearance derivation and axis scaling, explicit open-top contexts, and existing real content fixtures. All existing headless suites, audit, editor scan, and whitespace checks remain required before playtest handoff.
