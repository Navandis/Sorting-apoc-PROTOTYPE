# Sorting Apocalypse — documentation index

**Current intended game: GDD v0.16, approved by the developer in its entirety.**
**Continuous Run and Collection Goal Foundation: HUMAN-ACCEPTED / PUBLISHED / CLOSED IN ITS BOUNDED SCOPE.**
**Expedition-to-Storage Loop · HUMAN-ACCEPTED / CLOSED IN ITS BOUNDED SCOPE.** [Technical result and developer acceptance](testing/2026-11-08-expedition-to-storage-loop-result.md).

See the [approved foundation brief](superpowers/plans/2026-11-07-continuous-run-collection-goal-foundation.md) the [accepted result](testing/2026-11-07-continuous-run-collection-goal-result.md) and the [closure record](testing/2026-11-07-continuous-run-collection-goal-closure.md).

## Read first

Read [AI working guidelines](AI_WORKING_GUIDELINES.md), [current development state](CURRENT_STATE.md), and the relevant sections of the approved GDD. Use [Codex bootstrap](CODEX_BOOTSTRAP.md) for local execution boundaries and the [current conversation bootstrap](Sorting_Apocalypse_Bootstrap_Prompt_Next_Session_07Nov2026.md) for a new ChatGPT design session. Consult detailed validation records only when their scope is relevant.

## Current authority map

| Authority | Editable master | Generated reading copy / scope |
| --- | --- | --- |
| **Intended game design** | [GDD v0.16](Sorting_Apocalypse_Preliminary_GDD_v0.16.docx) | [Generated Markdown](readable/Sorting_Apocalypse_Preliminary_GDD_v0.16.md). Approved successor; owns the collection game, retained physical rules, provisional directions and open replacement mechanics. |
| **Implemented contracts, progress and evidence** | [Systems MVP v0.5](Sorting_Apocalypse_Systems_MVP_Foundation_Design_and_Progress_v0.5.docx) | [Generated Markdown](Sorting_Apocalypse_Systems_MVP_Foundation_Design_and_Progress_v0.5.md). M4 fixture/evidence and CF-01–CF-24 remain useful; obsolete survival-era forward requirements do not override v0.16. |
| **World, art, material and spatial context** | [VDD v0.11](Sorting_Apocalypse_Visual_Design_Direction_v0.11.docx) | [Generated Markdown](readable/Sorting_Apocalypse_Visual_Design_Direction_v0.11.md). Retained visual direction and current authored scene baseline; day/night/socket assumptions are subject to v0.16. No geometry change is authorized here. |
| **Historical prototype evidence** | [Findings v0.14](Sorting_Apocalypse_Prototype_Findings_v0.14.docx) | [Generated Markdown](readable/Sorting_Apocalypse_Prototype_Findings_v0.14.md). Historical experiments, promotions and debt, not the active progress tracker. |

DOCX masters govern. Edit the relevant DOCX first and regenerate its Markdown; do not maintain a second independent gameplay specification. Approval of v0.16 preserves its internal **CONFIRMED / RETAINED / DIRECTION / PROVISIONAL / OPEN / HISTORICAL** distinctions. It does not finalize placeholders or complete unresolved mechanics.

**An unresolved post-pivot rule stays unresolved. Do not fill it with a survival-era rule merely because an older document specifies that rule in detail.** Existing source establishes what the prototype does, not the intended release design or automatic permission to modify it.

The targeted Systems MVP v0.5 and VDD v0.11 master reconciliations are now complete as dated 7 November compatibility updates. The [two-master consistency record](testing/2026-11-07-mvp-vdd-compatibility-consistency.md) describes the earlier compatibility pass. Systems MVP §15.6 records the later local foundation acceptance. [GDD Appendix C](readable/Sorting_Apocalypse_Preliminary_GDD_v0.16.md#s_Appendix_C_Supersession_and_retentio) remains the original approval-time retention map.

## The approved direction

The player builds a substantial physical hoard and wins immediately when all eight category totals on qualifying player storage meet the shared Utility target simultaneously. Totals remain live; reaching one category does not bank it permanently. The sorting table, carried items, Receiving cargo and waiting expedition cargo do not count. Outstanding requests and queued or carried goods are not additional victory conditions. **2,000 Utility per category and roughly 80% storage occupancy remain illustrative, unvalidated values.** Uneven category sinks are intentional.

Active real-world completion time replaces days survived. There is no day cycle, imposed completion deadline or designed terminal failure state. Poor decisions may create a lengthy recovery; ordinary rules must prevent a true dead end without hidden catch-up. ESC, main menu, game-off and zoning pause the timer. Preparation is tentatively unpaused; time acceleration is set aside. Goal visibility is baseline and cannot be gated or disabled by upgrades or penalties.

Expedition preparation is **one current crew at a time**. Choose 1–4 Ready scavengers, contribute selected whole items, select two distinct affinities and explicitly Dispatch. Occupancy lasts until return. The [expedition brief](superpowers/plans/2026-11-07-expedition-to-storage-loop.md) records the committed lifecycle and provisional acquisition rules.

Requests are intended to use bounded pressure. Nonempty expedition returns release healthy personnel on admission to an active or deposited lift slot. Empty outcomes complete at return. See GDD §§5–16 for the full rules and status distinctions.

## Approved records and superseded history

| Record | Purpose |
| --- | --- |
| [v0.16 approval and authority-transition record](design_history/2026-11-07-gdd-v0.16-approval-and-authority-transition.md) | Approval basis, document-only scope, current-versus-implemented distinction and publication limits. |
| [Design pivot record — DOCX](design_history/Sorting_Apocalypse_Design_Pivot_Record_05Nov2026.docx) / [Markdown](design_history/Sorting_Apocalypse_Design_Pivot_Record_05Nov2026.md) | Approved rationale and decision history. Its §5.3 team-tabs text is superseded by the single-current-team addendum incorporated in GDD §§9 and 16; it is not a competing current specification. |
| [ADR archive — DOCX](design_history/Sorting_Apocalypse_ADR_Design_Archive_05Nov2026.docx) / [Markdown](design_history/Sorting_Apocalypse_ADR_Design_Archive_05Nov2026.md) | Approved historical/parked survival-cycle record, including reasons, tentative tuning, alternatives and open choices. Reuse only by deliberate later decision. |
| [GDD v0.15 — DOCX](Sorting_Apocalypse_Preliminary_GDD_v0.15.docx) / [Markdown](readable/Sorting_Apocalypse_Preliminary_GDD_v0.15.md) | Superseded for current intended gameplay; preserved survival-era design and provenance. |
| [25 October discussion reconstruction](design_history/2026-10-25-workshop-training-pacing-discussion.md) | Older non-authoritative provenance; its Training/day/pacing instructions are not current work orders. |

The two 5 November records are included unchanged from the editions the developer reviewed. The old GDD, dated evidence and historical handoffs are not rewritten or deleted. Historical “pending” text does not reopen a subsequently closed milestone.

## What is playable now

F5 launches `res://gameplay/run/run_shell.tscn` with live Utility targets, player-dispatched expeditions, single-item disposal and the continuous Kitchen in the published build. Continue uses schema 8. Confirmed New Run retains incompatible snapshots, including schema 7. Standalone F6 `res://gameplay/logistics_wing/wing_gameplay.tscn` retains the authored palette. The [survival-era archive](design_history/survival-era/README.md) preserves the earlier plans and frozen M4 input.

See [CURRENT_STATE](CURRENT_STATE.md) for the current content, scene, preservation and debt details. The [M4 validation record](testing/m4-expedition-loadout-validation-2026-10-24.md), [publication record](testing/m4-publication-2026-10-25.md), and [semantic reconciliation record](testing/m4-documentation-semantic-reconciliation-2026-10-25.md) preserve prior acceptance. They are not new tests of v0.16.

## Next-work boundary

The expedition loop and the separate [furniture movement collision repair](testing/2026-11-08-furniture-collision-repair-result.md) are human-accepted, published and closed in their bounded scopes.

The developer promoted and closed single-item disposal on 8 November 2026. The close-out is published on main. [Technical result and developer acceptance](testing/2026-11-08-incinerator-deliberate-disposal-result.md)

GDD §§8–15 record the approved contribution allocation. Continuous Kitchen is **HUMAN-PROMOTED / PUBLISHED / CLOSED IN ITS BOUNDED SCOPE**. GDD §14 specifies the approved Fuel reserve and emergency freight slice. Expedition bonuses, the Morale lane, healing and Workshop purchases remain future scopes. [Fuel decisions](design_history/2026-11-11-fuel-reserve-and-emergency-freight-decisions.md) · [Implementation plan](superpowers/plans/2026-11-11-fuel-reserve-emergency-freight.md) [Developer acceptance and close-out](testing/2026-11-09-continuous-kitchen-service-result.md) · [Contribution decisions](design_history/2026-11-09-contribution-effects-and-kitchen-decisions.md)

The complete pre-adoption operational index remains available in [the pinned c9f9417 snapshot](https://github.com/Navandis/Sorting-apoc-PROTOTYPE/blob/c9f9417a97cf65ef416c58189ca1f741b6a90406/docs/README.md). Current-facing consolidation changes routing, not the historical evidence.
