# Sorting Apocalypse — current ChatGPT conversation bootstrap

**Prepared 7 November 2026 and updated 10 November 2026 for Continuous Kitchen publication and 11 November 2026 for Fuel and Dispatch publication. Approved GDD v0.16 with the contribution decisions governs intended gameplay. M1–M4 remain HUMAN-PROMOTED / PUBLISHED / CLOSED.**

I am continuing Sorting Apocalypse, a solo-developed first-person collecting, hoarding and spatial-organizing game. The game is being redirected away from an endless survival/day-count objective. You are taking over after the collection pivot, approval of its design records, the single-current-team panel clarification, approval of the complete successor GDD v0.16, and preparation of the current-facing documentation update.

This replaces the **25 October 2026 conversation bootstrap** and the older 14 October handoff as the current conversation entry. Their evidence and reasoning remain history; their ADR-first or engineering-review-first work orders are not current.

This is a collaboration handoff, not a Codex implementation brief or permission to write/publish the repository. Do not ask me to reconstruct decisions already recorded. Read the at-a-glance state, authority map and first-response instructions, then targeted owning sections.

## At a glance

- **Design authority** — approved GDD v0.16, with [Appendix A](superpowers/plans/2026-11-07-continuous-run-collection-goal-foundation.md#appendix-a--confirmed-expedition-lifecycle-decisions-for-the-next-milestone) superseding the specified earlier open statements about preparation, destination occupancy and handover.
- **Current implementation** · The Expedition-to-Storage Loop is **HUMAN-ACCEPTED / PUBLISHED / CLOSED IN ITS BOUNDED SCOPE**. The [expedition result](testing/2026-11-08-expedition-to-storage-loop-result.md) follows the separately accepted [collection foundation](testing/2026-11-07-continuous-run-collection-goal-closure.md).
- **Incinerator** · The developer promoted and closed bounded single-item disposal on 8 November 2026. That release used schema 7 in the collection namespace. [Technical result and developer acceptance](testing/2026-11-08-incinerator-deliberate-disposal-result.md)
- **Continuous Kitchen** · **HUMAN-PROMOTED / PUBLISHED / CLOSED IN ITS BOUNDED SCOPE.** This milestone introduced schema 8. GDD §12 records the standing mechanics and provisional iteration settings. [Developer acceptance and close-out](testing/2026-11-09-continuous-kitchen-service-result.md) · [Contribution decisions](design_history/2026-11-09-contribution-effects-and-kitchen-decisions.md)
- **Fuel Reserve and Emergency Freight** · **HUMAN-PROMOTED / PUBLISHED / CLOSED IN ITS BOUNDED SCOPE.** Schema 9 retains incompatible schema-8 snapshots and requires confirmed New Run. [Fuel technical result and developer acceptance](testing/2026-11-11-fuel-reserve-emergency-freight-result.md)
- **Zero-Ready Dispatch repair** · **HUMAN-ACCEPTED / PUBLISHED / CLOSED IN ITS BOUNDED SCOPE.** [Dispatch repair result](testing/2026-11-11-dispatch-no-ready-repair-result.md)
- **Publication** · The collection foundation, expedition loop, furniture collision repair, Incinerator and Continuous Kitchen are published on `main`. The historical M1–M4 scopes are published and closed at `c9f9417a97cf65ef416c58189ca1f741b6a90406`. Frozen inputs and provenance are in the [survival-era index](design_history/survival-era/README.md).
- **Furniture collision** · The developer accepted the [furniture movement collision repair](testing/2026-11-08-furniture-collision-repair-result.md) on 8 November 2026, closing its separate scope. The old combined daily M5 proposal and ADR remain historical.

## 1. Roles and working method

Act as game-design collaborator, systems/technical architect, debugging strategist, evidence reviewer, documentation partner and solo-development scope guardian. Challenge a proposal when it conflicts with the organizing fantasy; do not merely make its supporting simulation more internally elaborate.

I own design, scope, gameplay, visual and authoring decisions. Local Codex operates the authoritative Windows checkout, Godot, ignored assets, branches and saves under explicit scoped briefs. ChatGPT’s repository access is read-only evidence about tracked files unless a write task is separately authorized; it does not expose unsaved scenes, local saves or licensed originals.

Read [AI_WORKING_GUIDELINES](AI_WORKING_GUIDELINES.md). Use one implementer by default; evidence and review should be proportionate. Do not introduce a review hierarchy, new generic framework, broad regression sweep, asset audit or another foundation milestone merely to prepare a design discussion.

Distinguish explicit decisions, favored directions, placeholders, assistant proposals, implemented behavior, reported checks, human acceptance and publication. Approval of a document containing open questions approves their recorded status; it does not settle them. New numerical suggestions remain hypotheses until tested.

I do not have native DOCX editing capability. Edit DOCX programmatically and regenerate readable companions. Preserve substantive motivation, examples, tradeoffs and unresolved choices in owning sections, not just a bootstrap synopsis. Supply substantial Codex handoffs as downloadable Markdown. Describe model/effort/session choices using available options, not historical guesses.

## 2. Authority map and reading order

| Source | Use |
| --- | --- |
| [GDD v0.16 DOCX](Sorting_Apocalypse_Preliminary_GDD_v0.16.docx) / [generated Markdown](readable/Sorting_Apocalypse_Preliminary_GDD_v0.16.md) | **Current approved intended game.** Rules, retained physical foundations, local status, open replacement design. |
| [Systems MVP v0.5](Sorting_Apocalypse_Systems_MVP_Foundation_Design_and_Progress_v0.5.md) | Implementation/contracts/progress/evidence and CF-01–CF-24. Old future survival behavior does not override v0.16. |
| [VDD v0.11](readable/Sorting_Apocalypse_Visual_Design_Direction_v0.11.md) | Retained world/art/material direction and existing authored spatial context. A proposed shorter bunker is not an already-changed scene. |
| [Findings v0.14](readable/Sorting_Apocalypse_Prototype_Findings_v0.14.md) | Historical prototype evidence, not active progress tracking. |
| [Approved pivot record](design_history/Sorting_Apocalypse_Design_Pivot_Record_05Nov2026.md) | Why the design changed; accepted input with local status preserved. Team-tab paragraph superseded by the later single-team addendum. |
| [Approved ADR archive](design_history/Sorting_Apocalypse_ADR_Design_Archive_05Nov2026.md) | Parked survival-cycle reasoning and proposals. Deliberate future reuse only. |
| [GDD v0.15](readable/Sorting_Apocalypse_Preliminary_GDD_v0.15.md) | Superseded survival-era design/history, not a second current ruleset. |
| [Approval/authority-transition record](design_history/2026-11-07-gdd-v0.16-approval-and-authority-transition.md) | This adoption’s scope, provenance and publication limit. |

Start with [guidelines](AI_WORKING_GUIDELINES.md), [CURRENT_STATE](CURRENT_STATE.md), [README](README.md) and [CODEX_BOOTSTRAP](CODEX_BOOTSTRAP.md). Then read GDD §§1–5 for vision/objective; §§8–11 for requests, current-team preparation and Receiving; §§12–16 as relevant; §§20–21 for actual implementation and open boundaries. Appendix C maps retained/replaced topics, Appendix D gives sources.

The targeted MVP v0.5 and VDD v0.11 master reconciliations are complete as dated 7 November compatibility updates. Their generated companions preserve implementation/evidence while bringing future-work and presentation assumptions into line with GDD v0.16. The [two-master consistency record](testing/2026-11-07-mvp-vdd-compatibility-consistency.md) records the checks and unresolved boundaries. Do not repeat the completed reconciliation or import old rules into an undefined replacement.

**An undefined replacement mechanic stays undefined. Do not import mortality, midnight, next-day effects, prebuilt teams, permanent training slots or daily request defaults to fill it.** Code establishes actual behavior, not automatic design approval.

## 3. Why we pivoted

The original experience was receiving messy loot, organizing it, hoarding enough to fill shelves, and making difficult choices about spending, salvaging and destroying useful possessions. Requests and expeditions were supporting sinks/faucets to add depth.

“Survive as many days as possible,” with scavenger extinction as failure, gradually inverted that relationship. Increasing supply trivialized survival pressure; increasing demand consumed the resident inventory needed to make storage matter. Daily windows and midnight introduced additional timetable and workload problems. The ADR cycle and time acceleration were attempts to repair those symptoms while retaining the survival objective.

The developer explicitly chose to change the objective and remove the day cycle. Do not respond by rebuilding a survival director or multiplying simulation systems. Keep organization itself rewarding and the stockpile itself the achievement. Most physical foundations remain useful; this is not a clean slate. GDD and VDD are not immutable barriers to this approved course correction, but changes to actual scenes/code still need deliberate scope.

The M4 playtest remains evidence with limits: all four stress-fixture teams were fully provisioned/dispatched before cutoff, narrowly; the early scripted delivery helped, unfamiliar stock and text-heavy UI hindered; meals reached 100% while Medical was 0/24/expired, and shelves were nearly empty. That motivated design work without invalidating mechanical M4 acceptance. It did not prove the complete economy or audience response.

## 4. Current collection objective and storage experience

There are eight categories: Electronics, Food, Fuel, Hydration, Medical, Morale, Protection and Weapons. All eight live totals must reach the shared target on qualifying player storage at the same moment. **2,000 Utility/category is a placeholder**, not a calibrated release number.

A category falling below its target becomes incomplete again before victory; no subgoal is permanently banked. The sorting table, carried items, Receiving cargo and returning-crew commitments do not count. Victory is immediate once the condition is met. There is no extra hold interval, request-clearance requirement, queue-empty requirement or inventory-empty requirement. The player can continue sorting after success or start an independent run for a better time.

Uneven sinks are desirable: Morale may accumulate sooner than Food even though both have the same target. The player manages unequal category progress within shared physical capacity. Roughly 80% occupied storage at a typical win is an experiential ballpark, not a quota or validated catalogue result. A winning collection should feel substantial but leave practical maneuvering room; this is not a geometric-precision puzzle.

All storage installations available from the start is the favored direction rather than capacity upgrades, with exact roster/capacity still open. Carrying, expedition and optional information improvements remain possible. Bulk is handling burden, Footprint/shape/stacking govern shelf use, and Utility measures contribution; they are not interchangeable. Keep stable item definitions and one shared Item Category: the first release has no dual/multi-use category conversions.

## 5. Continuous time, pressure and fairness

Active real-world completion time replaces days survived. The main game has no daily cycle, fixed dispatch window, forced return clamp, midnight resolution or terminal failure state. No overall time limit exists. The player may work slowly or never complete the objective.

ESC menu, main menu before a run, game-off and zoning pause the timer. Ordinary handling and travel use active time. The accepted Expedition panel stays live during preparation. Time acceleration is set aside. Focus/loading and exact modal edges remain open rather than assumed.

Aim for alert, often busy play with time to organize. The player controls whether/when to send available crews, and can deliberately create a workload they struggle to handle. Do not guarantee perfect workload smoothing or fill quiet moments with more mandatory consumption.

No dead end means a clear ordinary route to victory continues to exist. It does **not** mean rapid recovery, hidden rescue grants, adaptive loot, protected stock floors or a promise that every run remains efficient. A player may decide a badly managed run is too costly to repair and voluntarily restart. Consequences must follow understandable choices/outcomes, not unfair hidden system traps.

Requests should allow short deferral while making routine indefinite neglect costly. Both unfinished work and escalation must be bounded; unlimited stacking is not the current direction. Their exact effects, cadence, ceilings and removal remain design work. Near victory it may be legitimate to accept a penalty rather than spend the last needed supplies. Do not make request completion an additional victory rule.

## 6. Expeditions: one team being prepared at a time

This is the latest approved clarification and supersedes the pivot record’s per-team tabs:

**Choose 1–4 currently Ready scavengers → equip that current team and choose a destination → explicitly Dispatch → optionally prepare another team consecutively, in the same panel session.**

No automatic full-four-first roster; no morning allocation; no per-team preparation tabs; no parallel unfinished loadouts. Four Ready could be sent as 3+1, 4, or other permitted groupings. Multiple dispatched expeditions may operate concurrently and can have a separate status overview. All useful current loadout data must survive the broader interface: member count, five lanes, selected item, projected/applied credit, waste, full Bulk, raw/outgoing/return capacity and eligibility.

Appendix A fixes the preparation lifecycle. An editable draft becomes a committed crew at first accepted supply or successful explicit zero-loadout Dispatch. Accepted contributions are irreversible. Size is fixed after formation, affinity choices remain editable until departure, and closing/reopening retains the draft or commitment.

The working destination model is two distinct unordered affinities, giving 28 archetypes. Equal mathematical bonuses do not guarantee equal returns. All categories may occur; affinities neither guarantee particular cargo nor expand capacity. Use qualitative emphasis and retain actual item values. No bespoke ordinary location dangers, travel profiles, exterior map, depletion or lifetime caps are required.

Selectors remain the alphabetical eight icons in two rows of four. A pair identifies one archetype. One concurrent expedition occupies a destination only from successful Dispatch to return. Dispatch is disabled until two distinct affinities identify an available destination.

Requirements/capacity scale with assigned members. Outgoing Bulk remains a real cost. Expedition durations and per-member capacity can be retuned for the collection experience. A larger-team speed bonus was a possible lever, not an agreed rule. Opening population/growth and old day-60 targets must not be silently carried over.

## 7. Receiving, Medical, progression and information

Pending returns keep exact cargo and unavailable crew until admission into an active or deposited lift slot. Healthy crew become Ready at admission. The destination becomes available at return. Empty returns release the crew at return without using a lift slot. Injury classification and Medical treatment remain future work.

The finite physical deck, exact content/identity, fully-OPEN TAKE, safe permanent barrier, stationary-bay theatre and FIFO ownership remain useful. Uncapped waiting does not authorize infinite rendered cargo. Preserve existing machinery until an explicit affected implementation task changes policy.

Medical favors natural recovery with substantially faster treatment. Injured scavengers should not be sent out by assumption; the developer rejected adding injury-on-injury/capacity/provisioning complexities merely to enable that option. Fatality/daily complication rules are no longer current requirements. The full replacement model remains open under the no-dead-end condition.

Kitchen Food and Hydration restore player carrying and sprint. Fuel reserve tiers govern working lights and future facility permissions. Below 15 Utility each eligible freight delivery waits 60 active seconds before it starts. Electronics moves to one-time Workshop purchases, Medical alone handles healing and the target expedition loadout substitutes Morale for Medical. The live expedition fixture retains its Medical lane and current outcomes. Rations, Salvager and Training remain separate design work.

Goal-progress visibility is always baseline and cannot be disabled or upgrade-gated. Notification, central overview and a diegetic Journal have distinct roles. Optional information tools may improve access or analysis of existing facts, not hide indispensable data. Narrative remains short, qualitative and inferred; gameplay choices lead and fiction supports them. No visible outside world or human simulation is introduced.

## 8. What already exists and must not be reopened by default

The published build has continuous active time, player-dispatched expeditions, eight live stored Utility totals, single-item disposal, continuous Kitchen, Fuel Reserve and Emergency Freight, the accepted Dispatch repair and schema-9 continuation. Confirmed New Run can repoint the slot while retaining earlier incompatible snapshots. M1–M4 daily scheduling, reports and prebuilt Dispatch describe historical evidence. Injuries, recruitment and the supporting economy remain open.

The inspected baseline has 167 active/7 retired/174 sources. Preserve authored scale, pose/+Z Front, Footprint and support roles; twelve separate Auto Stack Group approvals remain pending with saved None. Never recycle retired IDs or replace authored values automatically. The current values are frozen testing content, not immutable release balance.

Storage, selected fixed ladders, rack authoring, Receiving A/B/C, EAF1–EAF5, C1 and intentional lighting remain promoted in their bounded scopes. Irregular frozen piles remain rejected and C1A remains parked. Do not revive old dimensions, removed props or failed experiments to “restore” a historical screenshot.

Current-state technical details, preservation rules and evidence links are in CURRENT_STATE §§4–11 and Systems MVP §16/§21. Use them selectively. Existing physical/gameplay acceptance does not mean the collection loop, final layout or full durability is already validated.

## 9. Local execution, source ownership and evidence discipline

```text
Authoritative Windows project: D:\Godot Projects\Sorting-apoc-PROTOTYPE
Repository: Navandis/Sorting-apoc-PROTOTYPE
Reported engine baseline: Godot 4.7, Compatibility renderer
Normal F5: res://gameplay/run/run_shell.tscn
Standalone F6: res://gameplay/logistics_wing/wing_gameplay.tscn
```

Check actual local branch, changes, worktrees, engine and remote state before execution. Prior reports of clean tracked files, eighteen preserved untracked sidecars and protected saves are not fresh inspection. Preserve human-authored scenes/data, ignored licensed assets, caches, reports, branches/worktrees and saves. No reset, stash, clean, force-push, history rewrite, deletion or staging sweep for convenience.

GitHub cannot certify the Windows checkout, imports, rendered art or all raw evidence. A local path named in a report is not an attachment that was read. Git-ignored scenes can still be scanned by Godot: externalize checkpoints with production UIDs/duplicate classes; retain startup-parity checks. Use guarded configured EAF source roots, not arbitrary drive scans, and avoid concurrent Godot/import writers.

Ordinary appropriate light/wear/furnishing changes use focused tracked authoring; they do not automatically require a full visual/gameplay audit. Future compression is an explicit design possibility, not current permission to move walls or discard approved art.

Keep source inspection, automated assertions, rendered proof, native input/audio observations, human promotion and publication distinct. Reuse same-state evidence with attribution. Do not rerun unchanged gameplay for document edits. Known rendering/content/loading/durability debt remains; consult CF-01–CF-24 without importing obsolete gameplay commitments.

## 10. Next design slices remain bounded

The [expedition loop](testing/2026-11-08-expedition-to-storage-loop-result.md) is closed in its bounded scope. Any further work requires its own agreed scope.

GDD §21.2 records the completed expedition decisions and open boundaries, including production tuning, bounded requests and Ops, Medical, population and progression, conversions, storage, interface, timing and release durability.

A next task can reuse accepted physical/transactional systems where relevant. No Workshop, Training, entire event framework, whole-wing remodel or new asset pass becomes a prerequisite by default. M5’s historical combined multi-day allocation scope is not automatically the next collection prototype or a name for actual expedition implementation.

## 11. First response in the new session

Verify accessible current repository state against the inspected checkpoint without resetting it. Read the current entry points and targeted approved GDD sections. If manual provision has not occurred, use the supplied approved v0.16 and disclose the discrepancy; do not mistake absence on the remote for lack of developer approval.

Orient to the approved design, the human-accepted and published collection and expedition checkpoints. Keep the historical M1–M4 results and the current scope distinct.

## 12. Provenance and maintenance

This handoff derives from the developer-approved v0.16 DOCX/Markdown, approved reconstructed 5 November pivot/ADR records, the explicit one-team addendum and the later whole-document approval. Those source records remain unchanged; v0.16 incorporates the tab supersession. It also uses the supplied 25 October handoff and read-only repository operational sources at `c9f9417` for implementation/evidence/preservation.

No fabricated timestamps are assigned to individual design messages. The dates on source documents retain their original meaning. This update is dated 7 November 2026, not a claim that the design discussion happened entirely on that date.

The package records approval and prepares manual publication; it performs no remote write, local Windows inspection, Godot test, new economic simulation, source-asset operation or save migration. The developer may upload these files later. Inspect that later state instead of treating this preparation checkpoint as forever current.

**Operating rule:** keep collection and organization central; preserve the approved detail and its open boundaries; reuse accepted foundations; leave historical survival rules in history; implement only an agreed bounded task.
