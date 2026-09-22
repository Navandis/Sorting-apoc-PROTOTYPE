# Sorting Apocalypse current development state

**Decision record:** 22 September 2026. The Storage Authoring and Testbed Foundation is consolidated. Review-scene supply reuse, reusable functional modular-rack authoring, **Storage Unit Orientation & Zoning Basis**, **Canonical Item Storage Pose & Shelf-Front Alignment**, the **Single-Rack Fixed-Ladder Proof**, and the **Wing Modular Rack + Ladder Integration bridge** are complete and human-promoted. Fixed ladders are approved only for selected taller storage installations. The next active gameplay/system gate is Receiving / physical Receiving Stage B unless a concrete storage blocker appears; this close-out does not start Receiving implementation. The retained shelf and ceiling review scene remains a mutable review tool rather than an active production scene.

## Current authorities

- [Preliminary GDD v0.10](Sorting_Apocalypse_Preliminary_GDD_v0.10.docx)
- [Visual Design Direction v0.7](Sorting_Apocalypse_Visual_Design_Direction_v0.7.docx)
- [Prototype Findings v0.10](Sorting_Apocalypse_Prototype_Findings_v0.10.docx)
- [AI working guidelines](AI_WORKING_GUIDELINES.md)

The accepted in-engine wing builder, saved scene and overview govern working dimensions over the retained 15 September schematic pixels.

The versioned GDD v0.10, Prototype Findings v0.10 and VDD v0.7 remain the dated pre-ladder-proof masters. Their stale current-status wording is superseded by this file and [Fixed-ladder proof validation](testing/fixed-ladder-proof-validation.md) until the next broader master-document revision.

## Promoted foundations

- Representative deterministic storage, stacking and zoning remain human-validated in their recorded scope.
- The accepted whole-wing geometry and Medical tuning remain the spatial baseline. General greybox correction is closed.
- `res://gameplay/logistics_wing/wing_gameplay.tscn` is the normal development and playable composition. It preserves the accepted geometry, normal player and HUD, three legacy functional storage units plus one scene-local four-level `ModularRack` with an independent promoted `FixedLadder` in temporary Gallery B, sixteen functional surfaces, and the saved `DevelopmentSetup` authoring setup. The Gallery B installation is a developer-movable Receiving Stage B storage-destination baseline, not final furnishing. F6 developer grids remain default off and F7 is suppressed in this composition.
- `DevelopmentSetup/SeedItems` in `wing_gameplay.tscn` is the current palette authority. It has at least one direct editor-authored host for every approved eligible type and preserves the developer's table and item arrangement. The fixed twelve-host regression fixture remains separate.
- Locker level 2 and Fuel maintenance are promoted. Fuel (`loot_000015`) is eligible for correctly authored development hosts. Gloves (`loot_000034`) and Pants (`loot_000036`) remain blocked.
- The default-entry transition is closed. `project.godot` selects `wing_gameplay.tscn` through UID `uid://bljf1nlhijej`. `main.tscn` remains the legacy mechanics fixture and `greybox/logistics_wing/wing_review.tscn` remains the neutral spatial review scene.
- Review-scene supply reuse is complete and human-promoted. The retained shelf ergonomics review extracts the composed `DevelopmentSetup` from `wing_gameplay.tscn` off-tree, keeps its authored tables, hosts, transforms and registrar path, and no longer activates the historical cabinet-only sample fixture.
- Reusable functional modular-rack authoring is complete and human-promoted. The reusable base scene is shelf-empty; review-scene-local Rack02 wrappers provide editable levels; runtime surfaces remain owned by the existing storage manager.
- Storage Unit Orientation & Zoning Basis is complete and human-promoted. Orientation remains unit-owned, every generated surface inherits its unit state, zoning is presented from authored Front, and existing physical grids, zone arrays, F6 behavior and packing rules remain unchanged.
- Canonical Item Storage Pose & Shelf-Front Alignment is complete and human-promoted. New placements align the ItemDefinition-authored canonical +Z Front to unit Front, retain the separate optional +90-degree packing turn, rotate reservation footprints with the final visual parity, and leave committed items stable. All 40 eligible definitions were human-reviewed in `res://gameplay/dev/item_storage_pose/item_storage_pose_authoring.tscn`; their saved `.tres` pose/footprint values are content authority. Gloves and Pants remain blocked.
- The standalone fixed-ladder architecture is complete and human-promoted for selected taller storage installations. It provides per-instance height authoring, a fixed vertical climb line, coarse movement collision, bounded attach/rearm/look behavior, and deliberate WorldItem/StorageSurface interaction through ladder geometry. This does not approve universal ladder coverage, movable/sliding ladders, general climbing, jumping, mantling, shelf-top traversal, fall/sliding systems, rung collision, or a final production ladder art roster.

## Storage ergonomics disposition

The A, B and C shelf and ceiling experiment is complete. Keep `res://gameplay/logistics_wing/review/shelf_ergonomics/shelf_ergonomics_review.tscn` as a mutable review tool. Its saved three-level starter is an editable, human-promoted `ModularRack`: the reusable base scene is shelf-empty, while deletable Rack02 shelf wrappers are local to the review scene. Runtime surfaces are derived through the existing storage backend.

- Judge the whole installation: model, authored dimensions and levels, room placement, approach space, usable depth and edge insets, viewpoint, reach, lighting and obstruction.
- Uniform compression of existing multi-level furniture is rejected as the general solution. In the tested corner-mounted rack context, more than three ground-access levels compromised visibility and manual targeting unless openings became too shallow or squat.
- Open racks may tolerate greater depth with more approach sides. Wall and corner installations generally need shallower usable depth. Evaluate slim usable-area insets per edge; do not impose one universal percentage or silently remove useful front capacity.
- Predominantly open modular storage remains the backbone. Cabinets and opaque storage are selective and lighting-aware.
- The 1.80 m eye-height and 2.8 m ceiling results remain trial observations. They do not change the production camera or wing ceilings.
- Ordinary ground-access storage should work without ladders. Fixed ladders are now an approved authored option for selected taller installations; no universal coverage, general climbing or jumping, movable/sliding ladder, animation, visible hands, fall system or shelf-adjustment feature follows from that promotion.
- The developer owns final functional storage authoring: model, installation placement, dimensions, level count and distribution, and ladder availability and placement. Codex may assist with tools, validation, decoration and later synthetic checks.

## Gate order

Completed: Review-scene supply reuse; reusable functional modular-rack authoring; Storage Unit Orientation & Zoning Basis; Canonical Item Storage Pose & Shelf-Front Alignment; Single-Rack Fixed-Ladder Proof; Wing Modular Rack + Ladder Integration bridge.

1. **Active gate: Resume Receiving / physical Receiving Stage B** unless a concrete new storage blocker appears.
2. Receiving Stage A remains the existing technical foundation; physical Stage B is not yet human-promoted.
3. Ladder promotion does not create a follow-on general climbing, jumping, movable-ladder or sliding-ladder gate.

## Explicitly deferred and known debt

Production Structural Shell and Applied Finish; full gallery furnishing; freight cage lining and real pile reach and drainability; functional Receiving Stage B and Stage C; timed obligations; full save and journal implementation; Gloves and Pants source and pose work; production starting inventory; player-adjustable shelf levels; crouch; height-aware auto-placement; camera-height and wing-ceiling changes. Storage-unit front/back semantics, zone-editor mapping, and eligible canonical item pose content are complete and human-promoted. Existing physical zone cells are deliberately not migrated when authored orientation changes. Full 0/90/180/270 item-display rotation remains optional UX debt; future save/load must restore placed orientation instead of recomputing it from current shelf Front.

The Fuel-related legacy-audit failure and timeout are resolved. Historical reports keep the status they had when written; later acceptance and this current record supersede their pending state without rewriting them.

## Current evidence

- [Continuing gameplay and F6 acceptance](testing/wing-gameplay-foundation-acceptance-2026-09-18.md)
- [Default-entry close-out](testing/wing-gameplay-default-entry-closeout-validation.md)
- [Locker and Fuel maintenance](testing/locker-fuel-maintenance-validation.md)
- [Expanded item palette](testing/expanded-item-palette-validation.md)
- [Shelf and ceiling ergonomics](testing/shelf-ceiling-ergonomics-comparison.md)
- [Review-scene supply reuse](testing/review-scene-supply-reuse-validation.md)
- [Modular rack authoring](testing/modular-rack-authoring-validation.md)
- [Storage unit orientation and zoning basis](testing/storage-unit-orientation-zoning-validation.md) — complete, technically verified and human-promoted.
- [Canonical item storage pose and shelf-Front alignment](testing/canonical-item-storage-pose-validation.md) — complete, technically verified and human-promoted.
- [Fixed-ladder proof validation](testing/fixed-ladder-proof-validation.md) — complete, technically verified and human-promoted for selected taller storage installations.
- [Wing Modular Rack + Ladder integration](testing/wing-modular-rack-ladder-integration-validation.md) — complete, technically verified and human-promoted as the real Receiving Stage B storage-destination baseline.

Ignored reports and imported asset state remain local and are not GitHub backup. The curated accepted greybox evidence remains under `docs/testing/evidence/greybox-accepted-2026-09-17/`.
