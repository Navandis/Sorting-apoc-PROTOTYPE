# Sorting Apocalypse documentation index

## Read first

[AI working guidelines](AI_WORKING_GUIDELINES.md) define the proportionate execution and evidence standard. [Current project state](CURRENT_STATE.md) records promoted evidence, current debt and gate order. [Codex bootstrap](CODEX_BOOTSTRAP.md) is the concise entry point for a new architect or local Codex session.

| Current authority | Editable document | Derived readable text |
| --- | --- | --- |
| Overall game design | [GDD v0.10](Sorting_Apocalypse_Preliminary_GDD_v0.10.docx) | [Text and tables](readable/Sorting_Apocalypse_Preliminary_GDD_v0.10.md) |
| Visual, world and spatial direction | [VDD v0.7](Sorting_Apocalypse_Visual_Design_Direction_v0.7.docx) | [Text, tables and images](readable/Sorting_Apocalypse_Visual_Design_Direction_v0.7.md) |
| Implementation and human evidence | [Findings v0.10](Sorting_Apocalypse_Prototype_Findings_v0.10.docx) | [Text and tables](readable/Sorting_Apocalypse_Prototype_Findings_v0.10.md) |

The Markdown editions are generated extracts of the listed DOCX masters. Edit the master and regenerate its extract; do not maintain an independent Markdown authority. Older DOCX editions remain historical records.

## Current playable and spatial baseline

The normal development entry is `res://gameplay/logistics_wing/wing_gameplay.tscn` through UID `uid://bljf1nlhijej`. It reuses the accepted whole-wing geometry and contains the normal player and HUD, three functional storage units, twelve functional surfaces and the saved editor-authored palette. `main.tscn` remains the legacy mechanics fixture. `res://greybox/logistics_wing/wing_review.tscn` remains the neutral spatial review entry.

The accepted in-engine builder, saved scene and [overview](testing/evidence/greybox-accepted-2026-09-17/overview_debug_topdown.png) govern working dimensions. The retained Topology V3 and Structural Schematic V2 images explain design history and relationships but do not override the accepted geometry.

## Current records

- [Continuing gameplay foundation design](superpowers/specs/2026-09-18-wing-gameplay-foundation-design.md): approved composition and editor-authored seed contract.
- [Continuing gameplay and F6 acceptance](testing/wing-gameplay-foundation-acceptance-2026-09-18.md): developer promotion and its limits.
- [Default-entry close-out](testing/wing-gameplay-default-entry-closeout-validation.md): saved-scene authority, launch promotion and guarded synchronization.
- [Locker and Fuel maintenance](testing/locker-fuel-maintenance-validation.md): promoted locker containment, Fuel reconciliation and Fuel eligibility.
- [Expanded item palette](testing/expanded-item-palette-validation.md): promoted editor-authored eligible-type coverage and accepted manual arrangement.
- [Shelf and ceiling ergonomics](testing/shelf-ceiling-ergonomics-comparison.md): completed ground-access experiment, retained review scene and bounded fixed-ladder status.
- [Review-scene supply reuse](testing/review-scene-supply-reuse-validation.md): promoted reuse of the authored wing palette in the retained shelf-ergonomics review.
- [ModularRack authoring](testing/modular-rack-authoring-validation.md): promoted shelf-empty reusable scaffold, scene-local editable levels and Rack02 calibration.
- [Storage unit orientation and zoning](testing/storage-unit-orientation-zoning-validation.md): promoted unit-owned Front semantics and authored-Front zoning view without physical-cell migration.
- [Canonical item storage pose](testing/canonical-item-storage-pose-validation.md): promoted canonical +Z Front, separate packing turn and the full 40-eligible-item human reconciliation.
- [Fixed-ladder proof validation](testing/fixed-ladder-proof-validation.md): technically verified and human-promoted standalone fixed ladders for selected taller storage installations.
- [Wing Modular Rack + Ladder integration](testing/wing-modular-rack-ladder-integration-validation.md): technically verified and human-promoted temporary Gallery B storage-destination baseline for Receiving Stage B.
- [Receiving and Elevator design](superpowers/specs/2026-09-12-receiving-elevator-mvp-design.md): subsystem contract; physical Receiving remains unvalidated.

The fixed-ladder proof and the temporary Gallery B wing integration are human-promoted in their deliberately narrow scopes. Receiving / physical Receiving Stage B is now the active gate unless a concrete new storage blocker appears; Receiving Stage A remains the technical foundation, and physical Stage B is not yet human-promoted. Ladder promotion does not approve universal coverage, general climbing/jumping, movable/sliding ladders or shelf-top traversal.

GDD v0.10, Prototype Findings v0.10 and VDD v0.7 remain dated pre-ladder-proof masters. Their stale current-status wording is superseded by [Current project state](CURRENT_STATE.md) and the fixed-ladder validation record until the next broader master-document revision.

Historical plans, validation reports and earlier master editions retain their original dates and evidence states. Later acceptance records and current authorities supersede stale pending conclusions without rewriting history.
