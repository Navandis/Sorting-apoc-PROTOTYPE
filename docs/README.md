# Sorting Apocalypse — documentation index

## Read first
[Current project state](CURRENT_STATE.md) distinguishes promoted evidence, remaining technical debt and the next gate.

| Current authority | Editable document | Derived readable text |
|---|---|---|
| Overall game design | [GDD v0.8](Sorting_Apocalypse_Preliminary_GDD_v0.8.docx) | [Text and tables](readable/Sorting_Apocalypse_Preliminary_GDD_v0.8.md) |
| Visual/world/spatial direction | [VDD v0.5](Sorting_Apocalypse_Visual_Design_Direction_v0.5.docx) | [Text, tables and images](readable/Sorting_Apocalypse_Visual_Design_Direction_v0.5.md) |
| Implementation and human evidence | [Findings v0.8](Sorting_Apocalypse_Prototype_Findings_v0.8.docx) | [Text and tables](readable/Sorting_Apocalypse_Prototype_Findings_v0.8.md) |

The Markdown editions are generated extracts of the listed DOCX files. Regenerate them when changing the master rather than maintaining independent competing versions. The DOCX files retain the full established design/history; this revision is not a replacement synopsis.

## Accepted spatial baseline
[Whole-wing acceptance](testing/logistics-wing-greybox-acceptance-2026-09-17.md) records the developer's approval after final Medical tuning. The accepted builder/saved scene and actual [overview](testing/evidence/greybox-accepted-2026-09-17/overview_debug_topdown.png) supply working dimensions. The two old schematics remain history/intent references; their obsolete dead-end and frontage details are not current construction requirements.

The neutral review entry is `res://greybox/logistics_wing/wing_review.tscn`; the old mechanics fixture is `res://main.tscn`. Bookkeeping does not change default launch. Read the bridge preflight before choosing the gameplay composition.

The implemented continuing-gameplay candidate is `res://gameplay/logistics_wing/wing_gameplay.tscn`. It reuses the accepted geometry through an author-owned environment wrapper and adds three functional storage units plus a removable saved table/loot setup. The broad handling/editor review is accepted; it remains an explicit scene until the focused F6 check and a later separately authorized default-entry close-out.

## Current administrative and implementation records
- [Close-out verification](testing/logistics-wing-greybox-closeout-validation.md): fresh tests, accepted/refined source relation, actual local/remote synchronization and preserved evidence.
- [Seeded-storage preflight](testing/wing-storage-integration-preflight.md): source-grounded next-milestone recommendation; implementation is separate.
- [Continuing gameplay foundation design](superpowers/specs/2026-09-18-wing-gameplay-foundation-design.md): approved composition, ownership and editor-authored seed contract; supersedes only the preflight's runtime-array seed proposal and temporary-scene framing.
- [Continuing gameplay foundation validation](testing/wing-gameplay-foundation-validation.md): implementation, automated/rendered evidence, preservation ledger and pending human PROMOTE/REVISE gate.
- [Continuing gameplay human follow-up](testing/wing-gameplay-foundation-follow-up.md): completed integration review, F6 clarification and approved staged follow-up order.
- [F6 developer-grid validation](testing/wing-storage-debug-f6-validation.md): key-specific correction, tests, preservation and focused human-check evidence.
- [Receiving/Elevator design](superpowers/specs/2026-09-12-receiving-elevator-mvp-design.md): subsystem contract, not proof of physical Receiving.

Older DOCX editions, design amendments, implementation plans and validation reports remain historical evidence. Their original dates and pre-human-review statuses must not be silently rewritten. Active tasks use the current versions and later explicitly recorded decisions.
