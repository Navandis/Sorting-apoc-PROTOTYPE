# Sorting Apocalypse — Codex bootstrap

**15 November 2026. Compact bunker layout — HUMAN-ACCEPTED / PUBLISHED / CLOSED IN ITS BOUNDED SCOPE.** GDD v0.16 is approved. [Acceptance and main verification](design_history/2026-11-15-compact-bunker-layout-acceptance-and-publication.md) · [Roof-off north-up overview](design_history/media/2026-11-15-compact-bunker-layout-north-up.png)

The current intended game is collection, hoarding and spatial organization. The [Expedition-to-Storage Loop](superpowers/plans/2026-11-07-expedition-to-storage-loop.md) is **HUMAN-ACCEPTED / PUBLISHED / CLOSED IN ITS BOUNDED SCOPE**. See its [technical result and developer acceptance](testing/2026-11-08-expedition-to-storage-loop-result.md) and the [accepted foundation checkpoint](testing/2026-11-07-continuous-run-collection-goal-closure.md).

The [13 November Expedition decisions](design_history/2026-11-13-expedition-outcomes-and-provisioning-decisions.md) supersede the fixture acquisition and healthy-only outcomes. The developer promoted and published the schema-11 iteration on 14 November. Read-only GitHub verification found `main` at `d242de49441b410c4abb88ab4f7b61971b6424d1`. [Publication and layout handoff](design_history/2026-11-14-publication-and-layout-handoff.md) qualifies older dated local/pending notices; no acceptance or publication task remains for this iteration. [Acceptance and technical evidence](testing/2026-11-13-expedition-outcomes-and-provisioning-result.md)

**18 November 2026. Reactive Medical treatment — HUMAN-PROMOTED / PUBLISHED / CLOSED IN ITS BOUNDED SCOPE.** The current continuation uses schema 12. [Reactive Medical treatment result](testing/2026-11-18-reactive-medical-treatment-result.md)

## Read first

1. [AI_WORKING_GUIDELINES.md](AI_WORKING_GUIDELINES.md).
2. [CURRENT_STATE.md](CURRENT_STATE.md) for the current implementation, retained contracts, authoring and debt.
3. [README.md](README.md) for the authority map.
4. [GDD v0.16](readable/Sorting_Apocalypse_Preliminary_GDD_v0.16.md), especially the owning sections for the actual task and §21 for unresolved choices. DOCX is the editable master.
5. Relevant Systems MVP v0.5 and [VDD v0.12](readable/Sorting_Apocalypse_Visual_Design_Direction_v0.12.md) passages and only the focused validation records needed for the task.

The [current conversation bootstrap](Sorting_Apocalypse_Bootstrap_Prompt_Next_Session_07Nov2026.md) supplies fuller collaboration context. The old 25 October ADR-first handoff is historical.

## Authority and publication boundary

The developer approved the complete v0.16 draft and authorized approval-state and entry-point updates for manual provision. Every internal PROVISIONAL, DIRECTION, OPEN and HISTORICAL label remains meaningful. [The approval record](design_history/2026-11-07-gdd-v0.16-approval-and-authority-transition.md) separates this approval from implementation/publication.

At the original 7 November approval-package preparation, read-only GitHub comparison showed `main == c9f9417a97cf65ef416c58189ca1f741b6a90406`; that was a historical publication boundary. The 14 November publication anchor is recorded above. Verify later actual refs and relevant files; no recorded SHA is a reset target and dated pending text is not a reason for recursive housekeeping commits.

GDD v0.16 governs intended gameplay. Systems MVP v0.5 owns implementation and evidence. [VDD v0.12](readable/Sorting_Apocalypse_Visual_Design_Direction_v0.12.md) owns visual direction and the accepted spatial baseline. The [7 November compatibility record](testing/2026-11-07-mvp-vdd-compatibility-consistency.md) and its VDD v0.11 source are historical. Undefined replacement mechanics retain their explicit open scope.

The [pivot record](design_history/Sorting_Apocalypse_Design_Pivot_Record_05Nov2026.md) is approved provenance; its §5.3 tabs are superseded by the single-team addendum incorporated in v0.16. The [ADR archive](design_history/Sorting_Apocalypse_ADR_Design_Archive_05Nov2026.md) and [GDD v0.15](readable/Sorting_Apocalypse_Preliminary_GDD_v0.15.md) are historical. Do not resume ADR, invent a survival mode, delete history or reopen completed reviews.

## Target design guardrails

The objective is simultaneous **live qualifying stored Utility** across all eight categories, with immediate victory and optional continued play. No banked category, sorting-table/carrying/cargo credit, hold interval or request-clearance gate. 2,000/category and roughly 80% occupancy are illustrations, not final numbers or additional goals. Uneven category sinks are intentional.

Active real-world completion time replaces days survived. No day cycle, morning cutoff, forced daily return, midnight loss, designed terminal failure or artificial catch-up. A poor run may take considerable effort to recover; ordinary rules must avoid a true dead end. ESC/main menu/game-off/zoning pause; the accepted preparation panel is live; acceleration is set aside. Goal visibility is baseline and protected from upgrades/penalties.

**Prepare one current team, not multiple cards:** choose 1–4 Ready scavengers, equip and choose destination, click Dispatch, then optionally prepare the next crew consecutively in the same panel. No prebuilt morning roster, per-team loadout tabs, parallel unfinished teams or automatic dispatch at 100%. Concurrent dispatched expeditions may be monitored separately. Preserve every useful M4 loadout datum in the wider panel.

Two distinct unordered affinities identify one of 28 destinations. Dispatch requires an available pair. The destination is occupied only while its crew is away. The full-catalogue sampler favors both affinities equally; ordinary draws filter categories and items by remaining Bulk, while bonus draws have no ordinary-budget restriction. See GDD §§9–10 and the 13 November Expedition decisions.

Pending return cargo remains intact. Waiting crews stay unavailable until admission to the active lift or deposited queue. At handover healthy originals and recruits become Ready and injured originals enter Medical. Empty returns hand over at their committed return time, outside Receiving.

Kitchen §12 defines bounded cumulative demand and carrying/sprint consequences. The Expedition iteration sets 22 normal player Bulk, 105 Kitchen demand cap and a 35% maximum penalty. The fixed meals and Daily Meal Coverage belong to the archived survival-era build. [Contribution decisions](design_history/2026-11-09-contribution-effects-and-kitchen-decisions.md) · [Continuous Kitchen brief](superpowers/plans/2026-11-09-continuous-kitchen-service.md)

Fuel §14 specifies continuous reserve consumption and a 60-active-second wait before each eligible emergency delivery. Crew handover remains on admission and ongoing cycles finish normally. [Fuel decisions](design_history/2026-11-11-fuel-reserve-and-emergency-freight-decisions.md) · [Implementation plan](superpowers/plans/2026-11-11-fuel-reserve-emergency-freight.md)

Medical recovery begins at handover and runs in parallel for 120 or 300 active seconds. A selected whole Medical item supplies 10 seconds per Utility provisionally, treating the shortest remaining timer first and spilling over. Excess after the final patient is wasted. See GDD §13. Fixed full storage remains favored. Use the accepted scene as the baseline for later materials, lighting, furnishing and focused playtest adjustments. Starting stock, final capacity, progression, integrated economy and remaining service mechanics retain separate scope. Further work begins with an agreed brief.

## Known open boundaries before affected implementation

Use GDD §21.2 rather than asking for reapproval of the whole pivot. In particular:

- O-02–O-07 cover preparation, destination, handover, catalogue acquisition, bounded requests and Medical. O-07 records the decided treatment rule and provisional tuning.
- O-08–O-12: population/progression, conversions, storage/layout, UI/time edges, compatibility and successor test scope.

Do not invent automatic refunds, lost loadouts, saved parallel prepared-team storage, new technical frameworks or old daily defaults to bypass these boundaries. Resolve only what an agreed task actually reaches.

## Actual playable baseline — preserve until deliberately changed

```text
Current layout authoring checkout: D:/Godot Projects/Sorting-apoc-PROTOTYPE
Current branch: main
Run schema: 12
Repository: Navandis/Sorting-apoc-PROTOTYPE
Reported engine: Godot 4.7 / Compatibility (verify installed executable)
F5 entry: res://gameplay/run/run_shell.tscn
Standalone F6: res://gameplay/logistics_wing/wing_gameplay.tscn
Wing UID: uid://bljf1nlhijej
Legacy fixture: res://main.tscn
Neutral review: res://greybox/logistics_wing/wing_review.tscn
```

The accepted wing runs from Receiving and Dispatch through shortened Backlog and Sorting into Main Storage. A–D remain, including the shared A/B circulation and C–D link. Medical and Kitchen have separate approaches, Workshop leads west to Salvager, Incinerator branches directly south from Main Storage, and the straight 3 m eastern link reaches Bunker Ops. The working Fuel cabinet is in Receiving. [Nine-slice technical result](testing/2026-11-14-compact-bunker-layout-result.md)

Continuous Kitchen is **HUMAN-PROMOTED / PUBLISHED / CLOSED IN ITS BOUNDED SCOPE** in the F5 loop. Open the service with F and supply the selected whole item with E. Continuous Kitchen introduced schema 8 through `user://saves/collection/`. Confirmed New Run can repoint the slot while retaining incompatible snapshots. The M4 slot remains separate. Standalone F6 keeps the human-authored `DevelopmentSetup/SeedItems` palette. [Developer acceptance and close-out](testing/2026-11-09-continuous-kitchen-service-result.md)

Fuel Reserve and Emergency Freight is **HUMAN-PROMOTED / PUBLISHED / CLOSED IN ITS BOUNDED SCOPE**. It introduced schema 9 through the existing save service. Refuel at the cabinet right of the Receiving shutter with F and a distinct E. [Fuel technical result and developer acceptance](testing/2026-11-11-fuel-reserve-emergency-freight-result.md)

Receiving mixed stacking is **HUMAN-APPROVED / PUBLISHED / CLOSED IN ITS BOUNDED SCOPE** with the approved Fedora revision. That milestone introduced schema 10. The published Expedition checkpoint then established schema 11. Confirmed New Run retains incompatible saves without migration. The 157-Bulk meat-and-mice area overrun and the long-object planner failure remain developer-deferred. [Receiving and Fedora result](testing/2026-11-13-receiving-mixed-stacking-result.md)

Schema 12 uses the same slot and validates treatment receipts with the shared item ownership rules. Confirmed New Run retains incompatible snapshots. [Reactive Medical treatment result](testing/2026-11-18-reactive-medical-treatment-result.md)

The zero-Ready Dispatch repair is **HUMAN-ACCEPTED / PUBLISHED / CLOSED IN ITS BOUNDED SCOPE**. [Dispatch repair result](testing/2026-11-11-dispatch-no-ready-repair-result.md)

GDD §15.3 records the Incinerator design. The developer promoted and closed the bounded single-item slice on 8 November 2026. The close-out is published on main. [Technical result and developer acceptance](testing/2026-11-08-incinerator-deliberate-disposal-result.md)

## Retained high-risk invariants

Exact ItemInstance ownership and one-item irreversible contribution remain central. The retained request transaction commits a selected eligible whole item and its receipt together. Rejection preserves it, accepted credit is capped and excess is wasted. Do not use pre-commit collection signals as proof of success. Held-E storage remains its separate reversible interaction.

Preserve zoning policy, deterministic support/clearance/pose rules, selected fixed-ladder scope, exact continuation, authored transforms and current catalogue identities. Catalogue: 167 active / 7 retired / 174 source models; twelve Auto Stack Group approvals still pending with saved None. Approved physical scale/pose/Footprint/roles are not permission to rewrite source fields or reincorporate retired items.

Receiving keeps exact committed content, private TAKE-only surfaces, fully-OPEN targeting/transfer guards and complete outbound turnaround before FIFO retirement. Retain upstream admission ownership and oldest-waiting fairness. The CRT shows the existing two deposited queue slots, and the expedition panel reports crews Awaiting Lift separately. No hidden refill, omission or reroll of awkward cargo.

Current scene art—not old count tables—governs saved placements and light/wear overrides. Preserve the compact Receiving/Dispatch geometry, protected nonuniform lift roots, P05_C02, reinforced-concrete shaft, accepted audio and mapped movement proxies unless the actual task explicitly changes them. Use CURRENT_STATE §§6–8 and VDD §34.7 for details. Ordinary tuning does not automatically reopen C1/Stage C/EAF.

## Execution discipline

Verify branch, working tree, worktrees, engine, current remote ancestry and task scope before local edits. Earlier reports of clean tracked state, eighteen untracked sidecars and protected saves are historical, not a fresh inventory. SHAs are evidence anchors.

Do not reset, stash, clean, force-push, rewrite history, delete branches/worktrees, stage all untracked files, discard saves or alter ignored commercial assets for convenience. Use existing guarded source roots and selected staging. A Git clone is not a complete asset backup.

Godot can scan Git-ignored scenes/scripts. Keep checkpoint copies with production UIDs and duplicate global classes outside scanned roots or behind a narrowly supported exclusion; preserve startup-parity checks. Do not run concurrent import/Godot writers on the same mutable checkout.

Use one implementer by default, affected checks and proportionate contextual/human review. Documentation alone does not justify unchanged-game sweeps. Preserve evidence attribution and CF-01–CF-24; new technical findings may need focused repair, not milestone reacceptance. Do not silently suppress existing/new diagnostics together.

The developer accepted the [furniture movement collision repair](testing/2026-11-08-furniture-collision-repair-result.md) on 8 November 2026, closing its separate scope. That repair and the original Expedition-to-Storage Loop close-out are published on `main`.
