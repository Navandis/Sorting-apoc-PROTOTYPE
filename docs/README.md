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

The normal development entry is `res://gameplay/logistics_wing/wing_gameplay.tscn` through UID `uid://bljf1nlhijej`. It reuses the accepted whole-wing geometry and contains the normal player and HUD, sixteen ordinary functional storage surfaces, the saved editor-authored palette, and the private deterministic seeded TAKE-only Receiving deck presenter. Normal launch does not synthesize a Receiving batch. `main.tscn` remains the legacy mechanics fixture. `res://greybox/logistics_wing/wing_review.tscn` remains the neutral spatial review entry.

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
- [Receiving A/B/C geometry comparison](testing/receiving-abc-geometry-comparison.md): completed isolated precursor; useful review history, with no case promoted as final production geometry.
- [Receiving real-item physics pile proof](testing/receiving-real-item-physics-pile-proof.md): completed and technically verified research; human review rejected irregular frozen piles for production.
- [Receiving deterministic deck presenter](testing/receiving-deterministic-deck-presenter-validation.md): implemented, technically verified and human-promoted in its tested Stage B scope; includes the original proof, spatial correction and accepted current baseline.
- [Receiving and Elevator design](superpowers/specs/2026-09-12-receiving-elevator-mvp-design.md): historical subsystem contract; the focused deterministic-deck record now governs the promoted Stage B presenter baseline.

The fixed-ladder proof, temporary Gallery B wing integration, deterministic seeded TAKE-only Receiving deck presenter, and functional freight fixtures are human-promoted in their recorded scopes. Receiving Stage A remains upstream batch/lifecycle authority: Expedition owns the exact batch contents while Receiving presents that batch without filler, omissions, replacements or loot bias. The presenter's promoted baseline and current reach values are in [Current project state](CURRENT_STATE.md). It uses private surfaces, fills local `+Z` FRONT toward local `-Z` REAR, and exposes no PUT, zoning, labels, manual placement, visible grids, F6 Receiving surface, or ordinary storage registration. The irregular frozen-pile presenter remains human-rejected. Stage C1 environment work is paused; its C1A shell is parked as unpromoted research. **EAF1 — Material + Lighting Lookdev Foundation** is the active prerequisite gate, with EAF2's non-exhaustive structural-substrate closure defined in [Current project state](CURRENT_STATE.md). Ladder promotion still does not approve universal coverage, general climbing/jumping, movable/sliding ladders or shelf-top traversal.

GDD v0.10, Prototype Findings v0.10 and VDD v0.7 remain dated masters. Their stale current-status and Receiving wording is superseded by [Current project state](CURRENT_STATE.md) and the focused validation records until the next broader master-document revision.

Historical plans, validation reports and earlier master editions retain their original dates and evidence states. Later acceptance records and current authorities supersede stale pending conclusions without rewriting history.
