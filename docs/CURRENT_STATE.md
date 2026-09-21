# Sorting Apocalypse current development state

**Decision record:** 21 September 2026. The Storage Authoring and Testbed Foundation is consolidated. Review-scene supply reuse and reusable functional modular-rack authoring are complete and human-promoted. **Storage Unit Orientation & Zoning Basis** is implemented and technically verified on `codex/storage-unit-orientation-zoning`; human review is pending, so the fixed-ladder proof remains blocked. The retained shelf and ceiling review scene remains a mutable review tool rather than an active production scene.

## Current authorities

- [Preliminary GDD v0.9](Sorting_Apocalypse_Preliminary_GDD_v0.9.docx)
- [Visual Design Direction v0.6](Sorting_Apocalypse_Visual_Design_Direction_v0.6.docx)
- [Prototype Findings v0.9](Sorting_Apocalypse_Prototype_Findings_v0.9.docx)
- [AI working guidelines](AI_WORKING_GUIDELINES.md)

The accepted in-engine wing builder, saved scene and overview govern working dimensions over the retained 15 September schematic pixels.

## Promoted foundations

- Representative deterministic storage, stacking and zoning remain human-validated in their recorded scope.
- The accepted whole-wing geometry and Medical tuning remain the spatial baseline. General greybox correction is closed.
- `res://gameplay/logistics_wing/wing_gameplay.tscn` is the normal development and playable composition. It preserves the accepted geometry, normal player and HUD, three functional storage units, twelve functional surfaces and the saved `DevelopmentSetup` authoring setup. F6 developer grids remain default off and F7 is suppressed in this composition.
- `DevelopmentSetup/SeedItems` in `wing_gameplay.tscn` is the current palette authority. It has at least one direct editor-authored host for every approved eligible type and preserves the developer's table and item arrangement. The fixed twelve-host regression fixture remains separate.
- Locker level 2 and Fuel maintenance are promoted. Fuel (`loot_000015`) is eligible for correctly authored development hosts. Gloves (`loot_000034`) and Pants (`loot_000036`) remain blocked.
- The default-entry transition is closed. `project.godot` selects `wing_gameplay.tscn` through UID `uid://bljf1nlhijej`. `main.tscn` remains the legacy mechanics fixture and `greybox/logistics_wing/wing_review.tscn` remains the neutral spatial review scene.
- Review-scene supply reuse is complete and human-promoted. The retained shelf ergonomics review extracts the composed `DevelopmentSetup` from `wing_gameplay.tscn` off-tree, keeps its authored tables, hosts, transforms and registrar path, and no longer activates the historical cabinet-only sample fixture.
- Reusable functional modular-rack authoring is complete and human-promoted. The reusable base scene is shelf-empty; review-scene-local Rack02 wrappers provide editable levels; runtime surfaces remain owned by the existing storage manager.

## Storage ergonomics disposition

The A, B and C shelf and ceiling experiment is complete. Keep `res://gameplay/logistics_wing/review/shelf_ergonomics/shelf_ergonomics_review.tscn` as a mutable review tool. Its saved three-level starter is an editable, human-promoted `ModularRack`: the reusable base scene is shelf-empty, while deletable Rack02 shelf wrappers are local to the review scene. Runtime surfaces are derived through the existing storage backend.

- Judge the whole installation: model, authored dimensions and levels, room placement, approach space, usable depth and edge insets, viewpoint, reach, lighting and obstruction.
- Uniform compression of existing multi-level furniture is rejected as the general solution. In the tested corner-mounted rack context, more than three ground-access levels compromised visibility and manual targeting unless openings became too shallow or squat.
- Open racks may tolerate greater depth with more approach sides. Wall and corner installations generally need shallower usable depth. Evaluate slim usable-area insets per edge; do not impose one universal percentage or silently remove useful front capacity.
- Predominantly open modular storage remains the backbone. Cabinets and opaque storage are selective and lighting-aware.
- The 1.80 m eye-height and 2.8 m ceiling results remain trial observations. They do not change the production camera or wing ceilings.
- Ordinary ground-access storage should work without ladders. One fixed shelf-serving ladder proof is approved; no production ladder, general climbing or jumping, movable or sliding ladder, animation, visible hands, fall system or shelf-adjustment feature is approved.
- The developer owns final functional storage authoring: model, installation placement, dimensions, level count and distribution, and ladder availability and placement. Codex may assist with tools, validation, decoration and later synthetic checks.

## Gate order

Completed: Review-scene supply reuse; reusable functional modular-rack authoring.

1. **Active human gate: Storage Unit Orientation & Zoning Basis — implemented / technically verified / human review pending.**
2. Single-rack fixed-ladder proof — blocked until the orientation gate is human-promoted.
3. Human ladder decision.
4. Resume Receiving unless storage ergonomics exposes another concrete blocker.

## Explicitly deferred and known debt

Production Structural Shell and Applied Finish; full gallery furnishing; freight cage lining and real pile reach and drainability; functional Receiving Stage B and Stage C; timed obligations; full save and journal implementation; Gloves and Pants source and pose work; production starting inventory; player-adjustable shelf levels; crouch; height-aware auto-placement; camera-height and wing-ceiling changes. Storage-unit front/back semantics and the zone-editor mapping are implemented on the active feature branch but remain human-review pending. Existing physical zone cells are deliberately not migrated when authored orientation changes. Item-packing orientation remains a separate post-review observation; it is not automatically a blocker unless the human orientation review classifies it that way.

The Fuel-related legacy-audit failure and timeout are resolved. Historical reports keep the status they had when written; later acceptance and this current record supersede their pending state without rewriting them.

## Current evidence

- [Continuing gameplay and F6 acceptance](testing/wing-gameplay-foundation-acceptance-2026-09-18.md)
- [Default-entry close-out](testing/wing-gameplay-default-entry-closeout-validation.md)
- [Locker and Fuel maintenance](testing/locker-fuel-maintenance-validation.md)
- [Expanded item palette](testing/expanded-item-palette-validation.md)
- [Shelf and ceiling ergonomics](testing/shelf-ceiling-ergonomics-comparison.md)
- [Review-scene supply reuse](testing/review-scene-supply-reuse-validation.md)
- [Modular rack authoring](testing/modular-rack-authoring-validation.md)
- [Storage unit orientation and zoning basis](testing/storage-unit-orientation-zoning-validation.md) — implemented/technically verified; human review pending.

Ignored reports and imported asset state remain local and are not GitHub backup. The curated accepted greybox evidence remains under `docs/testing/evidence/greybox-accepted-2026-09-17/`.
