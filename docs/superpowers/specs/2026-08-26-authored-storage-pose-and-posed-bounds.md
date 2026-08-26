# Authored Storage Pose and Posed-Bounds Design

## Scope

Correct stored-item and manual-ghost visual alignment so authored storage poses are applied before bounds-based seating and centering. Persist the reviewed pose states and 13 achievable candidate rotations, leave Pants unresolved, and extend the geometry audit with posed evidence under audit schema 1.3.

This pass does not alter Footprints, Bulk, Utility, zoning, reservation behavior, Receiving, held-item/HUD presentation, player interaction grammar, or source assets.

## Runtime transform contract

Both final stored visuals and manual-placement ghosts use the same visual pose/alignment helper and the same hierarchy:

```text
packing yaw root
  → seating / centering root
    → authored storage-pose root
      → canonical visual
```

The helper owns only visual pose/alignment math. It does not own or change reservation, cell-fit, zoning, placement-mode, or item-transfer logic.

The helper applies `ItemDefinition.storage_rotation_degrees` to the authored-pose root, calculates posed bounds from actual mesh contributors, then offsets the seating root so posed bounds are centered on X/Z and posed minimum Y is 0.006 m above the shelf plane. That clearance has one source of truth owned or consumed by the helper; ghost and final-placement code do not duplicate the literal. The existing optional 90-degree Y packing rotation is applied only to the outer packing-yaw root after alignment.

The stored pose is constructed solely from the canonical visual and ItemDefinition data. It never derives a delta from the source world instance transform. Manual mode exposes only the existing optional 90-degree packing rotation and cannot introduce pitch or roll. Packing yaw rotates the complete posed visual as a physical object; label-facing authored yaw is not counter-rotated when packing yaw is active.

## Candidate authoring

The eight explicit yaw candidates use the human-provided Y angles. Firearm, gloves, and hammer candidates are selected by inspecting each canonical asset's actual axes and choosing a minimal explicit Euler correction that produces the requested physical pose. No heuristic auto-orientation is added. If a semantic pose remains ambiguous after inspection, it is reported for manual tuning rather than guessed.

The 28 unaffected definitions retain zero authored rotation and become `DEFAULT_POSE_APPROVED`, each with its current source fingerprint and a zero reviewed-rotation snapshot. The 13 achievable candidates become `CUSTOM_POSE_REQUIRED`; each stores the current source fingerprint but its candidate rotation is not treated as an approved snapshot. Pants remains at its current rotation and Footprint with `CUSTOM_POSE_REQUIRED` and the unresolved folded-visual note. Every Footprint review remains `UNREVIEWED`. Pants remains ineligible for Footprint approval while its pose decision is unresolved.

## Review freshness

`DEFAULT_POSE_APPROVED` and `CUSTOM_POSE_APPROVED` are current only when both source fingerprint and reviewed rotation match. `CUSTOM_POSE_REQUIRED` is current whenever its reviewed source fingerprint matches, regardless of candidate rotation changes. A source fingerprint change stales every completed pose decision.

The authoring-manifest serialized structure remains schema 1.0.

## Posed audit evidence

Canonical geometry fields remain unchanged. Audit schema 1.3 adds current authored rotation, posed effective bounds and dimensions, and posed raw width/depth cells plus A/B orientations.

Posed bounds are aggregated from the same actual mesh contributors as canonical bounds. For every contributor, the measured posed transform is explicitly `authored_pose * contributor_to_asset_root` before eight-corner expansion, preserving internal root and child transforms. The audit does not rotate an already aggregated canonical AABB and does not write posed results back to `storage_footprint`.

## Verification

Focused runtime tests use synthetic asymmetric mesh contributors to verify authored-pose independence, zero-pose compatibility, post-rotation seating/centering, clearance, packing-yaw behavior, ghost/final equivalence, manual/auto equivalence, and absence of arbitrary manual pitch/roll.

Manifest tests cover status-specific freshness and source-fingerprint invalidation. Audit tests prove canonical invariance, posed X/Z changes, posed Footprint derivation, contributor-level aggregation, and schema 1.3. Representative interaction smoke coverage exercises the requested default, explicit-yaw, semantic-candidate, and unresolved Pants cases through pickup, auto placement, manual ghost/rotation/placement, and retrieval.

Completion requires all requested focused and integration suites, main-scene audit, Godot parser/editor scan, and `git diff --check` to pass without warnings.
