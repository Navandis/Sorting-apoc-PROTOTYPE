# Sorting Apocalypse — Codex bootstrap

**7 November 2026 authority update: GDD v0.16 APPROVED; M1–M4 HUMAN-PROMOTED / PUBLISHED / CLOSED.**

The current intended game is collection, hoarding and spatial organization. The local [Expedition-to-Storage Loop](superpowers/plans/2026-11-07-expedition-to-storage-loop.md) is **HUMAN-ACCEPTED / CLOSED IN ITS BOUNDED SCOPE**. See its [technical result and developer acceptance](testing/2026-11-08-expedition-to-storage-loop-result.md) and the [accepted foundation checkpoint](testing/2026-11-07-continuous-run-collection-goal-closure.md).

## Read first

1. [AI_WORKING_GUIDELINES.md](AI_WORKING_GUIDELINES.md).
2. [CURRENT_STATE.md](CURRENT_STATE.md) for the current implementation, retained contracts, authoring and debt.
3. [README.md](README.md) for the authority map.
4. [GDD v0.16](readable/Sorting_Apocalypse_Preliminary_GDD_v0.16.md), especially the owning sections for the actual task and §21 for unresolved choices. DOCX is the editable master.
5. Relevant Systems MVP v0.5/VDD v0.11 passages and only the focused validation records needed for the task.

The [current conversation bootstrap](Sorting_Apocalypse_Bootstrap_Prompt_Next_Session_07Nov2026.md) supplies fuller collaboration context. The old 25 October ADR-first handoff is historical.

## Authority and publication boundary

The developer approved the complete v0.16 draft and authorized approval-state and entry-point updates for manual provision. Every internal PROVISIONAL, DIRECTION, OPEN and HISTORICAL label remains meaningful. [The approval record](design_history/2026-11-07-gdd-v0.16-approval-and-authority-transition.md) separates this approval from implementation/publication.

At preparation, read-only GitHub comparison showed `main == c9f9417a97cf65ef416c58189ca1f741b6a90406`. The approval package was prepared for manual publication. After manual upload, verify the actual ref and relevant files; the baseline SHA is not a reset target and the dated upload boundary is not a reason for recursive housekeeping commits.

GDD v0.16 governs intended gameplay. Systems MVP v0.5 remains the implementation/evidence home, and VDD v0.11 retains visual/material/current spatial context. Their dated 7 November compatibility updates are complete; consult the [two-master consistency record](testing/2026-11-07-mvp-vdd-compatibility-consistency.md). Do not repeat that documentation reconciliation as pending work. Conflicting survival-era future requirements are superseded by v0.16; unresolved replacements are **not** filled by old midnight, mortality, training or daily-request rules. Source code establishes what exists, not approval of the next mechanic.

The [pivot record](design_history/Sorting_Apocalypse_Design_Pivot_Record_05Nov2026.md) is approved provenance; its §5.3 tabs are superseded by the single-team addendum incorporated in v0.16. The [ADR archive](design_history/Sorting_Apocalypse_ADR_Design_Archive_05Nov2026.md) and [GDD v0.15](readable/Sorting_Apocalypse_Preliminary_GDD_v0.15.md) are historical. Do not resume ADR, invent a survival mode, delete history or reopen completed reviews.

## Target design guardrails

The objective is simultaneous **live qualifying stored Utility** across all eight categories, with immediate victory and optional continued play. No banked category, sorting-table/carrying/cargo credit, hold interval or request-clearance gate. 2,000/category and roughly 80% occupancy are illustrations, not final numbers or additional goals. Uneven category sinks are intentional.

Active real-world completion time replaces days survived. No day cycle, morning cutoff, forced daily return, midnight loss, designed terminal failure or artificial catch-up. A poor run may take considerable effort to recover; ordinary rules must avoid a true dead end. ESC/main menu/game-off/zoning pause; preparation is tentatively live; acceleration is set aside. Goal visibility is baseline and protected from upgrades/penalties.

**Prepare one current team, not multiple cards:** choose 1–4 Ready scavengers, equip and choose destination, click Dispatch, then optionally prepare the next crew consecutively in the same panel. No prebuilt morning roster, per-team loadout tabs, parallel unfinished teams or automatic dispatch at 100%. Concurrent dispatched expeditions may be monitored separately. Preserve every useful M4 loadout datum in the wider panel.

Two distinct unordered affinities identify one of 28 destinations. Dispatch requires an available pair. The destination is occupied only while its crew is away. The development sampler favors both affinities equally before whole-item fit filtering. See GDD §§9–10 and the expedition brief.

Pending return cargo remains intact. Waiting crews stay unavailable until admission to the active lift or deposited queue. Healthy members become Ready at admission. Empty returns release the crew at their committed return time, outside Receiving.

Requests have bounded unresolved work/escalation, legitimate short deferral and meaningful neglect costs. Exact recurring/penalty behavior remains open. Medical favors slower natural recovery and faster treatment; do not add injured expedition participation or a full replacement treatment model by assumption. Fixed full storage is a favored direction, not a finalized shelf roster. Workshop, Training, population growth and route compression require further design.

## Known open boundaries before affected implementation

Use GDD §21.2 rather than asking for reapproval of the whole pivot. In particular:

- O-02–O-04 cover the confirmed preparation, destination and healthy handover rules in the expedition brief. Injury classification and Medical treatment remain open.
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

F5 New Run starts the playable expedition-to-storage loop. Continue restores schema 6 from `user://saves/collection/`. Schema-5 and M4 snapshots are preserved. Standalone F6 keeps the human-authored `DevelopmentSetup/SeedItems` palette. The [historical M4 input and plans](design_history/survival-era/README.md) remain separate.

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

The developer accepted the [furniture movement collision repair](testing/2026-11-08-furniture-collision-repair-result.md) on 8 November 2026, closing its separate scope. The expedition close-out and repair acceptance are local. Publication is pending.
