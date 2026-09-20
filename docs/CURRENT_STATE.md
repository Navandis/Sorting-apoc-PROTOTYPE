# Sorting Apocalypse current development state

**Decision record:** 20 September 2026. The Storage Authoring and Testbed Foundation is consolidated. The retained shelf and ceiling review scene is completed evidence, not an active production scene.

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

## Storage ergonomics disposition

The A, B and C shelf and ceiling experiment is complete. Keep `res://gameplay/logistics_wing/review/shelf_ergonomics/shelf_ergonomics_review.tscn` as a future review tool. The developer's manually authored three-level modular rack is retained as a useful ground-access reference. `SM_Rack01.glb` and `SM_Rack02.glb` are static review assets and do not yet provide functional storage surfaces.

- Judge the whole installation: model, authored dimensions and levels, room placement, approach space, usable depth and edge insets, viewpoint, reach, lighting and obstruction.
- Uniform compression of existing multi-level furniture is rejected as the general solution. In the tested corner-mounted rack context, more than three ground-access levels compromised visibility and manual targeting unless openings became too shallow or squat.
- Open racks may tolerate greater depth with more approach sides. Wall and corner installations generally need shallower usable depth. Evaluate slim usable-area insets per edge; do not impose one universal percentage or silently remove useful front capacity.
- Predominantly open modular storage remains the backbone. Cabinets and opaque storage are selective and lighting-aware.
- The 1.80 m eye-height and 2.8 m ceiling results remain trial observations. They do not change the production camera or wing ceilings.
- Ordinary ground-access storage should work without ladders. One fixed shelf-serving ladder proof is approved; no production ladder, general climbing or jumping, movable or sliding ladder, animation, visible hands, fall system or shelf-adjustment feature is approved.
- The developer owns final functional storage authoring: model, installation placement, dimensions, level count and distribution, and ladder availability and placement. Codex may assist with tools, validation, decoration and later synthetic checks.

## Gate order

1. Review-scene supply reuse.
2. Reusable functional modular-rack authoring.
3. Single-rack fixed-ladder proof.
4. Human ladder decision.
5. Resume Receiving unless storage ergonomics exposes another concrete blocker.

## Explicitly deferred and known debt

Production Structural Shell and Applied Finish; full gallery furnishing; freight cage lining and real pile reach and drainability; functional Receiving Stage B and Stage C; timed obligations; full save and journal implementation; Gloves and Pants source and pose work; production starting inventory; player-adjustable shelf levels; crouch; height-aware auto-placement; camera-height and wing-ceiling changes.

The Fuel-related legacy-audit failure and timeout are resolved. Historical reports keep the status they had when written; later acceptance and this current record supersede their pending state without rewriting them.

## Current evidence

- [Continuing gameplay and F6 acceptance](testing/wing-gameplay-foundation-acceptance-2026-09-18.md)
- [Default-entry close-out](testing/wing-gameplay-default-entry-closeout-validation.md)
- [Locker and Fuel maintenance](testing/locker-fuel-maintenance-validation.md)
- [Expanded item palette](testing/expanded-item-palette-validation.md)
- [Shelf and ceiling ergonomics](testing/shelf-ceiling-ergonomics-comparison.md)

Ignored reports and imported asset state remain local and are not GitHub backup. The curated accepted greybox evidence remains under `docs/testing/evidence/greybox-accepted-2026-09-17/`.
