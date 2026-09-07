# Deterministic Support Stacking Spike Design

## Status and gate

This document defines a deliberately constrained prototype. Completing it does not promote stacking to confirmed design. Technical verification ends at a focused human playtest handoff, after which the developer decides whether the hypothesis should be promoted, revised, or rejected.

The existing `StorageSurface` remains a deterministic two-dimensional cell reservation system. Vertical stacking is a visual and runtime extension over one ordinary base reservation, not a volumetric inventory model.

## Scope

The spike implements one centered linear column of independently targetable `WorldItem` instances. It does not implement voxels, physics settling, balance, arbitrary overhang, upper-surface offsets, multiple columns, support trees, free pitch/roll, save serialization, or metadata inference from geometry.

All existing storage behavior remains authoritative: authored storage poses, posed-bounds seating and centering, optional 90-degree packing yaw, manual placement, deterministic zone-auto placement, category-to-General-to-unassigned fallback, ordinary retrieval, and the current two-dimensional reservation rules.

## Item metadata

`ItemDefinition` gains only:

- `can_be_stacked: bool`
- `can_support_stack: bool`
- `auto_stack_group: StringName`

`ItemInstance` exposes null-safe getters. The existing `stackable` property remains untouched for compatibility and is not used as support-stacking authority.

Metadata is authored only for these definitions:

| Visual | Role | Auto group |
| --- | --- | --- |
| `SM_Book_01` | stackable and supporting | `flat_media` |
| `SM_CDStack_01` | stackable and supporting | `flat_media` |
| `SM_MedKit_4` | stackable and supporting | `medical_boxes` |
| `cereal_box` | stackable and supporting | `boxed_food` |
| `SM_Gun_Pistol` | terminal/top-only | empty |
| `SM_Bread_1` | terminal/top-only | empty |
| `SM_ComputerTower_01` | base-only support | empty |
| `SM_Metal_Can_01a` | stackable and supporting | `round_cans` |
| `SM_Dry_Goods_01c` | stackable and supporting | `round_cans` |

All other definitions retain false/false/empty defaults and must remain observationally identical to current unstacked storage when represented internally as one-entry stacks.

## Stack data and ownership

A focused `StorageStack` runtime type contains the explicit mechanical state. Its record stores:

- stable stack ID;
- owning `StorageSurface` runtime reference;
- base reservation origin and oriented footprint;
- an ordered bottom-to-top list of entries.

Each entry stores the stable `ItemInstance`, stable item key, oriented footprint, packing-rotation flag, measured posed height, support flags, automatic group, and optional runtime host/`WorldItem` references. Runtime references are not the mechanical source of truth; the remaining scalar and identity fields can be mapped to serialization later without relying on node parenting.

Every successful shelf placement creates a one-entry stack record. Only its base owns a normal `StorageSurface` reservation, keyed by the stable stack ID. Upper members consume no cells. Non-participating items cannot accept or join a stack, so their visible placement, occupancy, retrieval, and carry identity remain unchanged.

`StorageSurface` owns its stack registry and item-to-stack lookup because stack lifetime, base reservations, zone membership, candidate scan ordering, and reservation shrink are surface-local concerns. `StoragePlacementController` remains responsible for targeting, carried-item transactions, ghosting, visual construction, and placement orchestration.

## Support and insertion rules

An oriented incoming footprint fits an oriented support footprint only when both dimensions are less than or equal to the support dimensions. Existing entries never rotate during insertion.

Manual stacking targets an existing stored stack and considers only placement above its current top. It requires the incoming item to be stackable, the current top to support a stack, the selected native or manual 90-degree orientation to fit, and the completed stack to remain within clearance. It ignores automatic groups. A terminal Pistol or Bread therefore caps its stack.

Automatic stacking additionally requires a non-empty incoming group and an auto-coherent candidate stack. A stack is auto-coherent only when every existing entry has the same non-empty group. A manual mixed or terminal addition makes that stack ineligible for future automatic insertion while leaving manual stacking available.

For each candidate stack, automatic insertion tests the incoming native orientation before its allowed 90-degree alternative. It scans insertion positions from top toward the fixed base and selects the highest valid position. The entry below must support and contain the incoming footprint; if an entry exists above, the incoming item must support it and contain its footprint. Existing order and packing orientations stay unchanged. Entries above the insertion point move only vertically to recompute the centered column.

Existing stacks are scanned in the surface's stable back-to-front row and left-to-right column order. Because reservations do not overlap, origin ordering is sufficient to preserve deterministic candidate order without a global optimization score.

## Zone-auto policy

The surface evaluates each existing zone tier in this exact order:

1. matching-category compatible stack;
2. matching-category empty placement;
3. General compatible stack;
4. General empty placement;
5. unassigned-cell compatible stack;
6. unassigned-cell empty placement.

A stack belongs to a tier only when its complete base reservation is currently inside that tier's cells. This reuses live zone data and prevents a manually placed stack, a later zone edit, or a cross-category auto group from bypassing specific-zone policy. Cross-category `round_cans` may auto-stack in General when General normally accepts the incoming item, but never in a mismatched specific-category zone.

## Posed height and clearance

The current surface/profile architecture has no trustworthy per-level value representing usable height to the next obstruction. Each authored level profile therefore gains the smallest explicit `stack_clearance_m`, transferred to its `StorageSurface` in world metres.

`StorageVisualPose` remains the authority for authored pose, packing yaw, seating, and posed bounds. The placement controller measures each candidate orientation through that same helper. The maximum permitted used height is:

`surface_base_y + stack_clearance_m * 0.95`

The actual aligned base offset, accumulated posed heights, and one centralized physically negligible contact-gap constant, if testing proves one necessary, are included in the top calculation. No maximum entry count is added.

The approved Tower is `5x3`; the approved MedKit is `5x4`. Neither MedKit orientation fits the Tower. The real pair must therefore be reported as rejected by both footprint and clearance when its measured height also exceeds the configured limit, never as the clearance-only proof. Synthetic stack fixtures prove acceptance immediately below the 95% threshold and rejection immediately above it. A real clearance-only pair may be reported only if existing content naturally supplies one without changing metadata, footprints, or storage poses.

## Visual placement and preview parity

The base uses the existing shelf-plane candidate transform. Each later host is centered on the stack's base reservation and placed at the deterministic cumulative posed height of entries below it. Packing yaw and authored pose remain separate transform layers.

Manual stack targeting uses an independently targetable stored `WorldItem` to identify its stack. The ghost uses the same resolved footprint, packing rotation, insertion/base transform, and posed-height calculation committed by final placement. Previewing an insertion does not temporarily mutate the live stack; tests compare the incoming ghost transform and orientation to the committed item.

Automatic mode remains visually quiet.

## Retrieval and compression

Each stored `WorldItem` carries its stack ID and stable item key. Pickup first proves carry capacity, then requests removal through the owning surface. A failed storage removal rolls back the carry addition.

Removing the top deletes only that entry. Removing a middle entry retains order and deterministically recomputes every upper host transform from posed heights. Removing the base promotes the next entry and replaces the old reservation with the promoted oriented footprint, entirely inside the former reservation.

For parity mismatches, the new origin is:

`old_origin + floor((old_footprint - new_footprint) / 2)`

This is a stable lower-index/back-left bias. Surviving hosts recenter on the new reservation. The operation never grows into new cells. Removing the final entry releases the reservation, stack record, and item lookup with no hidden occupancy.

## Testing and verification

Focused headless suites cover metadata roles and all nine definitions; support geometry; both packing orientations; terminal and base-only roles; synthetic 95% boundaries; real Tower/Book and Tower/MedKit outcomes; exact six-step zone search order; mismatched-zone exclusion; manual group independence; automatic coherence; flat-media and round-can families; General cross-category cans; 5x5/1x1/2x3/4x4 smart insertion; highest-position and orientation tie-breaking; fallback; top/middle/base/final retrieval; deterministic parity bias; targetability; ghost/final parity; and manual rotation parity.

A dedicated regression compares non-stack-enabled one-entry storage with the pre-spike path at the observable boundary: reservation count and cells, reservation key/origin/footprint/rotation, stored transform and authored-pose hierarchy, individual targetability, retrieval identity, carry result, released occupancy, and absence of leftover stack state.

Verification also runs every existing category, catalogue, pose, footprint-review, authoring-review, audit, and interaction suite; the new stack suites; a Godot headless editor/parser scan; and `git diff --check`. GDScript warnings remain errors.

## Playtest handoff

The technical handoff provides normal in-game procedures for flat media, mixed terminal stacks, Tower support, cross-category round cans, arbitrary visible-member retrieval, base/middle compression, and unchanged ordinary items. The completion report records evidence and limitations but leaves all ten design-success questions for the developer's playtest. No claim promotes stacking beyond prototype status.
