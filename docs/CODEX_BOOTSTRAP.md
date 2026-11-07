# Sorting Apocalypse — Codex bootstrap

**7 November 2026 authority update: GDD v0.16 APPROVED; M1–M4 HUMAN-PROMOTED / PUBLISHED / CLOSED.**

The current intended game is collection, hoarding and spatial organization, not endless day-count survival. The implemented prototype remains the published M4 fixture. This bootstrap is routing and preservation guidance, **not an implementation brief or blanket repository-write authorization**.

## Read first

1. [AI_WORKING_GUIDELINES.md](AI_WORKING_GUIDELINES.md).
2. [CURRENT_STATE.md](CURRENT_STATE.md) for the current implementation, retained contracts, authoring and debt.
3. [README.md](README.md) for the authority map.
4. [GDD v0.16](readable/Sorting_Apocalypse_Preliminary_GDD_v0.16.md), especially the owning sections for the actual task and §21 for unresolved choices. DOCX is the editable master.
5. Relevant Systems MVP v0.5/VDD v0.11 passages and only the focused validation records needed for the task.

The [current conversation bootstrap](Sorting_Apocalypse_Bootstrap_Prompt_Next_Session_07Nov2026.md) supplies fuller collaboration context. The old 25 October ADR-first handoff is historical.

## Authority and publication boundary

The developer approved the complete v0.16 draft and authorized approval-state and entry-point updates for manual provision. Every internal PROVISIONAL, DIRECTION, OPEN and HISTORICAL label remains meaningful. [The approval record](design_history/2026-11-07-gdd-v0.16-approval-and-authority-transition.md) separates this approval from implementation/publication.

At preparation, read-only GitHub comparison showed `main == c9f9417a97cf65ef416c58189ca1f741b6a90406`. No assistant push, commit, merge or PR is part of this task. After manual upload, verify the actual ref and relevant files; the baseline SHA is not a reset target and the dated upload boundary is not a reason for recursive housekeeping commits.

GDD v0.16 governs intended gameplay. Systems MVP v0.5 remains the implementation/evidence home, and VDD v0.11 retains visual/material/current spatial context. Their masters have not been rewritten in this adoption package. Conflicting survival-era future requirements are superseded by v0.16; unresolved replacements are **not** filled by old midnight, mortality, training or daily-request rules. Source code establishes what exists, not approval of the next mechanic.

The [pivot record](design_history/Sorting_Apocalypse_Design_Pivot_Record_05Nov2026.md) is approved provenance; its §5.3 tabs are superseded by the single-team addendum incorporated in v0.16. The [ADR archive](design_history/Sorting_Apocalypse_ADR_Design_Archive_05Nov2026.md) and [GDD v0.15](readable/Sorting_Apocalypse_Preliminary_GDD_v0.15.md) are historical. Do not resume ADR, invent a survival mode, delete history or reopen completed reviews.

## Target design guardrails

The objective is simultaneous **live qualifying stored Utility** across all eight categories, with immediate victory and optional continued play. No banked category, sorting-table/carrying/cargo credit, hold interval or request-clearance gate. 2,000/category and roughly 80% occupancy are illustrations, not final numbers or additional goals. Uneven category sinks are intentional.

Active real-world completion time replaces days survived. No day cycle, morning cutoff, forced daily return, midnight loss, designed terminal failure or artificial catch-up. A poor run may take considerable effort to recover; ordinary rules must avoid a true dead end. ESC/main menu/game-off/zoning pause; preparation is tentatively live; acceleration is set aside. Goal visibility is baseline and protected from upgrades/penalties.

**Prepare one current team, not multiple cards:** choose 1–4 Ready scavengers, equip and choose destination, click Dispatch, then optionally prepare the next crew consecutively in the same panel. No prebuilt morning roster, per-team loadout tabs, parallel unfinished teams or automatic dispatch at 100%. Concurrent dispatched expeditions may be monitored separately. Preserve every useful M4 loadout datum in the wider panel.

Two distinct unordered affinities across eight categories give 28 archetypes in the working model. They bias useful returns without guaranteeing particular items, increasing carrying capacity or changing item definitions. One concurrent team per destination; no depletion. Destination-availability events and the generic fallback are disfavored/no longer needed. Do not independently finalize reservation/release or incomplete-choice rules.

Pending return cargo remains intact; waiting teams remain occupied until the defined handover. No queue-overflow destruction. An uncapped pending queue does not mean an infinite physical presentation deck. Receiving ownership/fairness survives while obsolete midnight policy changes only under a scoped implementation brief.

Requests have bounded unresolved work/escalation, legitimate short deferral and meaningful neglect costs. Exact recurring/penalty behavior remains open. Medical favors slower natural recovery and faster treatment; do not add injured expedition participation or a full replacement treatment model by assumption. Fixed full storage is a favored direction, not a finalized shelf roster. Workshop, Training, population growth and route compression require further design.

## Known open boundaries before affected implementation

Use GDD §21.2 rather than asking for reapproval of the whole pivot. In particular:

- O-02: readiness reservation, closing/reopening one unfinished preparation, resizing/cancellation after irreversible contributions, and consume-on-dispatch phrasing versus accepted submission ownership.
- O-03/O-04: destination occupancy/release, incomplete affinity selection, all-busy feedback, cargo handover, zero-loot returns and Medical admission.
- O-05/O-06/O-07: acquisition, persistent requests, bounded penalties and Medical recovery.
- O-08–O-12: population/progression, conversions, storage/layout, UI/time edges, compatibility and successor test scope.

Do not invent automatic refunds, lost loadouts, saved parallel prepared-team storage, new technical frameworks or old daily defaults to bypass these boundaries. Resolve only what an agreed task actually reaches.

## Actual playable baseline — preserve until deliberately changed

```text
Authoritative asset-equipped checkout: D:\Godot Projects\Sorting-apoc-PROTOTYPE
Repository: Navandis/Sorting-apoc-PROTOTYPE
Reported engine: Godot 4.7 / Compatibility (verify installed executable)
F5 entry: res://gameplay/run/run_shell.tscn
Standalone F6: res://gameplay/logistics_wing/wing_gameplay.tscn
Wing UID: uid://bljf1nlhijej
Legacy fixture: res://main.tscn
Neutral review: res://greybox/logistics_wing/wing_review.tscn
```

M4 still runs the 06:00–00:00 day, 06:00–10:00 preparation, full/manual/cutoff dispatch, four prebuilt stress-fixture teams and paused three-tab night report. Testing values are 20 player Bulk, 28/member and lanes 12/12/6/12/12; 85 seeded items and twelve 16-item deliveries over three days. **The scripted supplies are not real team returns.** Ordinary schema-4 continuation is accepted; real expedition/personnel outcomes, the new victory condition and continuous durability are not implemented here. Frozen `data/scenarios/m4/` remains reproducible.

F5 New Run seeds the fixture once; Continue does not reseed/reissue/redispatch. Standalone F6 keeps the human-authored `DevelopmentSetup/SeedItems` palette and does not inject unsolicited debug cargo. Preserve review fixtures and their distinct roles. Do not replace source art with an asset-blind worktree or silently convert old saves.

## Retained high-risk invariants

Exact ItemInstance ownership and one-item irreversible contribution remain central. F opens without spending; distinct E commits the selected eligible whole item. Rejection preserves it; accepted credit is capped, excess wasted and full loadout Bulk charged. Do not use pre-commit collection signals as proof of success. Held-E storage remains its separate reversible interaction.

Preserve zoning policy, deterministic support/clearance/pose rules, selected fixed-ladder scope, exact continuation, authored transforms and current catalogue identities. Catalogue: 167 active / 7 retired / 174 source models; twelve Auto Stack Group approvals still pending with saved None. Approved physical scale/pose/Footprint/roles are not permission to rewrite source fields or reincorporate retired items.

Receiving keeps exact committed content, private TAKE-only surfaces, fully-OPEN targeting/transfer guards and complete outbound turnaround before FIFO retirement. Retain upstream admission ownership and oldest-waiting fairness. Its existing 1+2 deposited slots and CRT 00–02 describe the current build; successor personnel/queue semantics remain separate. No hidden refill, omission or reroll of awkward cargo.

Current scene art—not old count tables—governs saved placements and light/wear overrides. Preserve the compact Receiving/Dispatch geometry, protected nonuniform lift roots, P05_C02, reinforced-concrete shaft, accepted audio and mapped movement proxies unless the actual task explicitly changes them. Use CURRENT_STATE §§6–8 and VDD §34.7 for details. Ordinary tuning does not automatically reopen C1/Stage C/EAF.

## Execution discipline

Verify branch, working tree, worktrees, engine, current remote ancestry and task scope before local edits. Earlier reports of clean tracked state, eighteen untracked sidecars and protected saves are historical, not a fresh inventory. SHAs are evidence anchors.

Do not reset, stash, clean, force-push, rewrite history, delete branches/worktrees, stage all untracked files, discard saves or alter ignored commercial assets for convenience. Use existing guarded source roots and selected staging. A Git clone is not a complete asset backup.

Godot can scan Git-ignored scenes/scripts. Keep checkpoint copies with production UIDs and duplicate global classes outside scanned roots or behind a narrowly supported exclusion; preserve startup-parity checks. Do not run concurrent import/Godot writers on the same mutable checkout.

Use one implementer by default, affected checks and proportionate contextual/human review. Documentation alone does not justify unchanged-game sweeps. Preserve evidence attribution and CF-01–CF-24; new technical findings may need focused repair, not milestone reacceptance. Do not silently suppress existing/new diagnostics together.

**Stopping point:** the GDD is approved and the entry points are reconciled documentation. The developer provisions them. No M5, new implementation milestone, catalogue rebalance, geometry change, review restart or repository publication is authorized to the assistant by this bootstrap. Wait for the actual next bounded request, without re-litigating approved decisions.
