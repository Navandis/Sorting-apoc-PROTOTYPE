# Stacking Stabilization Pass Design

## Goal

Stabilize the deterministic support-stacking prototype by correcting promoted-base ownership, making targeted manual stack orientation contextual, and treating deliberately erased zoning cells as disabled storage.

## Confirmed root cause

`StorageSurface.remove_stack_entry()` removes the old base entry and promotes the next entry geometrically, but it leaves the stack dictionary key, reservation key, occupied-cell owner, survivor lookup values, and surviving `WorldItem` metadata keyed to the removed base item ID. Empty placement then collides with the still-active old ID, while automatic placement can rediscover the surviving stack and unintentionally reinsert the carried item. A successful unintended placement removes the carried selection and can therefore look like E advanced the carried index; an automatically selected alternate packing orientation can look like E rotated the item. The E dispatcher itself only requests placement.

## Promoted-base ownership transition

When a non-final base is removed, the first surviving entry becomes the authoritative base. Before mutating active registries, `StorageSurface` validates that the promoted ID is non-empty, distinct from the old ID, mapped to the current stack, and does not already own another stack or reservation. It also validates that the promoted footprint is a legal centered shrink inside cells owned by the old stack.

After validation, one non-failing mutation phase moves every ownership reference together:

- erase the old `_stacks` key and insert the same `StorageStack` under the promoted item ID;
- move the reservation to the promoted item ID;
- replace every occupied-cell owner equal to the old ID with the promoted ID where the shrunken reservation remains occupied, clearing released cells;
- rewrite every surviving `_item_to_stack` value to the promoted ID;
- set `StorageStack.stack_id` to the promoted ID;
- update each surviving `WorldItem` to report the promoted stack ID while retaining its own storage item key and surface;
- update the promoted base footprint/origin and reposition survivors.

The removed base ID must be absent from all active ownership and lookup structures immediately after promotion. Validation failure returns before removing the entry or changing any registry, so partial promotion cannot occur. Final-item, middle-item, and top-item removal retain their current behavior.

## Contextual manual stack orientation

Targeted manual stack fitting receives a preferred entry derived from the player's `_rotated` preference and, for a non-square footprint, the single allowed 90-degree alternative. It evaluates preferred first and only evaluates the alternative if preferred is invalid. The selected entry's packing orientation is returned in the placement fit and is used by both ghost and final placement.

The controller never writes the contextual result back to `_rotated`. Leaving the stack target therefore restores ordinary manual behavior using the player's existing preference. Both-valid preserves preferred; neither-valid stays invalid.

## Erased-cell semantics

The existing `_zones_initialized` flag cleanly distinguishes untouched surfaces from authored surfaces. Untouched surfaces preserve legacy manual placement behavior, while the first automatic zoning interaction still initializes every cell to General.

Once initialized, an empty zone category means disabled storage:

- automatic tier search considers matching specific category and General only;
- automatic stack candidates must have their complete base footprint in the active tier;
- manual empty placement ignores category mismatch but requires every footprint cell to have a non-empty zone category;
- manual stack placement requires the existing base reservation footprint to remain storage-enabled.

Existing stored items are not moved when their cells are erased, but those disabled cells cannot receive manual or automatic placement.

## Scope boundaries

This pass does not expand reservations, insert a larger incoming item beneath a base, move stacks, change smart insertion ordering, alter mixed-stack auto-coherence, refactor shelf clearance, change approved item footprints or poses, change held/HUD presentation, modify save serialization, or implement multi-column packing.

Deferred records remain:

- `BASE_PROMOTION_SMART_INSERTION — PROTOTYPE REFINEMENT PENDING DESIGN`
- `MIXED_STACK_AUTO_COHERENCE — REQUIRES BROADER CONTENT PLAYTEST`

## Tests and validation

Focused headless tests cover registry-complete promoted-base rekeying, rollback/no-partial-state behavior, ordinary placement of the removed base in manual and automatic modes, same-surface return with one and multiple carried items, unchanged top/middle/final retrieval, preferred/alternate/both/neither targeted orientation cases, preference preservation, ghost/final parity, disabled erased cells in auto/manual/stack paths, General and specific-category policy, first-use General initialization, and ordinary one-entry equivalence.

Final verification runs all stacking suites, storage/category regressions, catalogue/manifest/audit suites, interaction smoke, the main-scene audit, a Godot parser/editor scan, and `git diff --check`. The pre-existing `main.tscn` worktree changes are preserved and excluded from this pass.
