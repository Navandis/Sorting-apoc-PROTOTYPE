# Continuous Run and Collection Goal Foundation — Implementation Brief v0.1

**Sorting Apocalypse | 7 November 2026 | Prepared for local implementation; no implementation performed by this document**

**Goal:** Make receiving, sorting and storing physical items advance eight simultaneous live collection targets in a continuous, saveable run, with no surviving day-based gameplay intervention.

**Architecture:** Adapt the existing run, time, persistence and Receiving owners. Add a small collection-goal owner and basic presentation; replace calendar policy rather than the physical logistics foundation. Remove obsolete production code when its dependencies are accounted for. Do not build a second ruleset, save service or event framework.

**Technology:** Existing Godot/GDScript project and Compatibility renderer. The published project reports Godot 4.7; verify the actual local executable, checkout and asset availability rather than assuming this document verifies them.

**Execution:** Fresh local Codex session; one implementer using the strongest coding-capable model available in the existing setup, with High reasoning effort where selectable. Record the actual model/variant and effort, or explicitly record unavailable metadata. Do not invent a model identifier. Follow `docs/AI_WORKING_GUIDELINES.md` over generic workflow ceremony. One consolidated contextual review and the developer's focused playtest are sufficient unless a concrete finding requires follow-up.

**Authority:** Approved GDD v0.16; Systems MVP v0.5 and VDD v0.11 with their 7 November compatibility updates; the developer's subsequent approval of the transition approach and lifecycle decisions reproduced in Appendix A. This is a bounded successor brief, not an automatic continuation or renaming of the old M5 plan.

## 1. Status, evidence and approach

The developer selected the hybrid transition: retire the cross-cutting daily operation in one coherent first slice, then replace system-specific behavior with its successor. Wholesale demolition would discard useful ownership and continuation machinery; postponing every removal would leave incompatible calendar policy controlling new systems.

Published `main` was inspected read-only at **`be220667b720e0bf81b8b00dcae9bbbb50789b6c`**. That is a reference, not a reset target. The attached original 25 October MVP copy predates the published compatibility update; use the current published/checked-out master, not that stale status text. M1–M4 remain historically human-promoted, published and closed. No new gameplay result, local Windows inspection or independent review is claimed here.

The gameplay decisions in the GDD and Appendix A are confirmed at their stated scope. The following **brief-author choices** make this first implementation concrete; they are provisional technical/test policies, not newly approved release balance:

| Choice for this slice | Boundary |
| --- | --- |
| Fresh successor save schema, provisionally 5 | Verify the next unused schema locally. No M4 conversion or legacy runtime mode. |
| Successor save directory `user://saves/collection/` | Reuse the same save service/codec. Isolate old M4 files, not a second implementation or selectable save-history feature. |
| Automatic save every 60 active seconds, plus first victory | Use the ordinary coherent save path; measure its cost. This is not the full-game 2–3-second durability aspiration. |
| Small common collection target in a controlled fixture | Executor chooses and records one value supported by the actual catalogue and a demonstrably fitting collection. Do not adopt 2,000 or 80% as calibrated values. |
| Loading/reconstruction pauses the whole run | No scored time or mechanism progress before a coherent playable state is ready. |
| No new automatic focus-loss pause in this slice | Preserve current platform behavior and test it. No score-only pause; suspended/offline intervals must not be converted into free progress. Full focus/stall policy remains a later UX decision. |

These choices may be revised explicitly during brief review. Once execution is authorized, they are the starting contract, not unanswered questions for the executor to fill from the old survival design.

## 2. Deliverable and exclusions

At completion, normal New Run/Continue launches the successor foundation. The player can receive controlled cargo, take it, arrange it on valid storage, see current category totals, reach the simultaneous goal, keep playing, save and resume. Advancing through the former cutoff and midnight times produces no special event.

**Included:** continuous active time; calendar/report/cutoff retirement; removal of ordinary cargo forfeiture; basic goal display and first-completion recording; controlled supply fixture; coherent successor continuation; narrowly relevant code/test/document retirement.

**Excluded:** the new team-preparation panel, actual crew formation or journeys, destination selection/concurrency, personnel handover/triage, injuries/recruitment, procedural loot balance, revised departmental penalties, conversion/disposal production systems, upgrades, Journal, new room art, corridor shortening, shelf/carry-capacity tuning, catalogue expansion and release-grade crash durability.

Appendix A is confirmed design for the subsequent expedition milestone. Do not implement it incidentally in this foundation. In particular, synthetic cargo IDs are not a real personnel model.

Medical, Kitchen and Dispatch must not issue the obsolete daily requests in the successor. Preserve their authored physical spaces; remove or detach obsolete interaction controllers and misleading actionable cues. A short development status label is sufficient where explanation is needed. Do not invent replacement departmental effects to keep a frontage busy.

## 3. Runtime contracts

### 3.1 One continuous active timeline

Use one coherent active-time basis for run elapsed time, controlled arrivals and lift logical progress. One unpaused real second means one active second: no day index, simulated hours, 24× conversion, day-length clamp, calendar jump, cutoff or midnight phase. The score display reads this authority; it does not run another timer.

ESC, launch/main-menu inactivity, zoning, application-off time and loading holds stop the run consistently. Preserve nested pause ownership, blocked world input, shutter/audio pause and resume semantics. Closing one overlay cannot release another owner's pause. Unpaused ordinary interaction continues to count. No time acceleration or time-skip controls are introduced.

Use elapsed-time measurement rather than system date/time differences. Retain fractional precision. Resume/Continue restores elapsed time and pending logical progress without offline advance, duration restart or accumulating drift. Time after first victory continues to advance normal play; the first-completion record is a separate frozen timestamp.

Retain causal mechanics: last successful TAKE -> closing -> complete outbound turnaround -> retirement -> FIFO promotion/admission. Large test advances must settle each necessary boundary once, in order. Removing midnight must not remove the lift's driver or cause both autonomous and externally driven advancement.

### 3.2 Live stored collection

For the eight categories **Electronics, Food, Fuel, Hydration, Medical, Morale, Protection and Weapons**, compute:

`stored_utility[c] = sum(Utility of each committed item of category c on qualifying player storage)`

`victory = every stored_utility[c] >= the common run target`

Count individual stack members once. Exclude carrying/held visuals, seed objects not yet stored, sorting-table/staging surfaces, active/deposited/upstream cargo, environmental props, consumed contributions and unclassified future machine outputs. Registered storage technology alone is not proof of goal eligibility.

Identify qualifying surfaces explicitly at installation/registration. For the existing wing, inspect the installed player-storage surfaces and exclude staging/Receiving by role; do not guess from a node's name or room. Produce a concrete list of qualifying and excluded installed surfaces in the result record, without turning that inventory into a separate review milestone. Newly encountered unclassified surfaces do not silently qualify. No geometry, dimensions, zoning, placement or stack-support rule changes follow from scoring.

Zoning and labels do not determine the item's category or score. A legal manually placed item counts in its own category even in a differently zoned area. Later rezoning/erasing does not remove or retroactively disqualify already committed stock; those policies constrain subsequent placement.

**Category/Utility compatibility:** the source still exposes primary Utility, contextual overrides and a separate storage category. For this slice, use the existing authored primary category/Utility pair for goal contribution and validate its agreement with the intended shared category for the active definitions used. Do not add contextual values together, choose the largest contextual value or infer Utility from footprint. A materially conflicting or missing primary value is a named content-mapping issue to resolve explicitly, not permission for a catalogue-wide rewrite. Retain all existing numerical and physical authoring. Removing all legacy contextual APIs is not part of this slice; neither is inventing a separate scoring-only value. Any narrowly necessary mapping must preserve the existing authored primary meaning and be recorded explicitly.

Prefer a small read-only inventory view over authoritative storage, refreshed after successful committed changes. Surface occupancy/carry notifications may help detect changes but do not by themselves prove an enclosing transfer succeeded. Evaluate settled ownership, not speculative previews or mid-rollback state. A stale/rejected placement cannot win the run. Duplicate item ownership is an error, not hidden by scoring deduplication. No global event-bus rewrite or per-frame scene-wide rescan is required.

### 3.3 Completion and basic interface

Show eight current/target totals and active elapsed time in a compact baseline interface available throughout the wing. Keep selection, carried-item feedback, targeting and zoning usable. Use text and existing UI primitives; physical monitors, new icons and UI art are unnecessary here. Goal visibility is never upgrade-gated or disabled.

Before victory, a category can move above and below its target. Surplus in one never covers another. Re-evaluate after committed ownership changes without a gameplay holding interval. The first simultaneous completion records the precise current active time once and shows an understandable success notification. Do not require clearing requests, inventory or any cargo queue.

Continue playing normally after success. Current totals remain live and may decrease; neither the success record nor its original time is revoked or overwritten. New Run remains an explicit confirmed action. Do not resurrect the paused night report as a victory screen or freeze the shared clock permanently.

Goal totals are derived from actual restored ownership. Persist the common target, rule/fixture revision, completion flag and first-completion timestamp coherently. Do not overwrite a saved run's target from edited defaults. Restore everything before publishing goal UI or evaluating changes; reconstruction must not award victory from a partially restored collection.

### 3.4 Controlled acquisition, not pretend expeditions

Create a small successor fixture using existing active item definitions and validated cargo preparation. Reuse suitable exact manifests as data, never the M4 daily scheduler or a runtime dependency on archived fixtures. Use active-seconds offsets for a finite sequence, with stable occurrence IDs and issued-state preservation. No day fields.

The fixture must cover all eight categories, start below the common goal in at least one category, and provide enough physically attainable stock for a representative winning arrangement. Choose the provisional target from that feasibility, not vice versa. Retain current player Bulk and storage capacities. Demonstrate attainable placement without altering meshes, authored item values or shelf geometry.

Use `AwaitingLiftAdmission.submit_return(...)` and the existing preparation path. Do not bypass upstream fairness with direct manager deposits. Include a separate focused pressure fixture that fills one active plus two deposited slots and leaves additional exact hauls awaiting admission. A normal human-play fixture need not constantly overload Receiving.

The controlled fixture is clearly labeled as development supply, independent of Dispatch. Finishing its schedule does not end the run or constitute failure. Existing cargo remains usable after the sequence and after victory. Optional test-only repeat injection may reuse manifest content with fresh identities; it is not an adaptive refill or a new player supply source. No generic production loot generator is needed.

### 3.5 Receiving remains finite, cargo remains preserved

Keep one active plus two deposited FIFO slots, TAKE-only private surfaces, six-state lift operation, full-OPEN gating, cue timing, CRT meanings and full outbound turnaround. Upstream pending commitments can remain indefinitely with no designed queue cap, overflow disposal or age-based forfeiture. Finite data/memory validation limits are technical limits, not gameplay abandonment rules.

Remove the midnight-forfeit method, signal/status policy and its production callers once dependencies are retired. Preserve valid cargo through pressure, pause and continuation. Preparation/admission faults must be diagnosed, not turned into permission to omit, replace or reroll items. Do not redesign ordinary lift mechanics or make the CRT's deposited queue count include upstream waiting records.

No personnel are implemented here. Future release at cargo admission is fixed by Appendix A and must not be confused with last TAKE or the lift's subsequent retirement.

## 4. Continuation and preservation

Extend the existing snapshot/codec/save service. Save coherent items, carry/selection, player/camera/ladder, qualifying and nonqualifying storage, zoning/disabled cells, exact stack poses/reservations, cargo/arrangement/FIFO/pending commitments, run ID/allocator, active time, fixture progress and goal/completion state. Do not preserve obsolete calendar/report fields as dummy requirements of a new schema.

Use the next successor schema (5 if still unused). Reject incompatible M4 schemas clearly; no automatic migration, replay of old days, cargo conversion or reset. Launch must explain why an existing legacy run cannot be continued rather than implying it has vanished.

**Protect real saves:** the current service retires the previously pointed snapshot after successful replacement. Instantiate that same service for `user://saves/collection/` in the successor so a confirmed new successor run cannot delete the old M4 continuation under `user://saves/`. Do not offer a legacy gameplay toggle. Keep one active successor continuation, not a save-slot browser. Tests use temporary directories and must not touch developer saves. A read-only legacy-presence notice is enough; do not scan unrelated user files.

New Run validates the candidate and saves it successfully before publishing it or replacing the current in-memory run. Continue validates and fully reconstructs before activation. Failed load never starts a replacement run. Failed Save & Exit leaves the current run paused and intact. All transfers must settle before snapshot capture; no half-consumed or multiply owned items.

**Provisional autosave:** after each 60 active seconds since the last attempt, attempt one coherent save through the same service. Coalesce overdue intervals rather than issuing a burst. Persist scheduling progress so repeatedly loading cannot restart the entire interval. Also save the first completed-goal state once, and preserve Save & Exit. A concurrent due trigger and victory trigger can share one coherent write. On failure, retain the previous valid continuation and the in-memory state, show a nonmodal warning and retry only at the next normal due opportunity or explicit Save & Exit; no tight retry loop. Successful later saving clears the warning. Measure capture/validation/write cost and report intrusive stalls rather than silently dropping the trigger or excluding only score time.

This is ordinary prototype continuation, not verified crash/power-loss durability or a claim to the inherited 2–3-second loss aspiration. No new journal, cloud sync, anti-tamper framework or serializer is required.

## 5. Affected source and retirement boundaries

Paths below are inspected owners or immediate dependencies at the pinned reference; the executor confirms actual callers locally. A path is not an instruction to rewrite the whole file.

| Owner/path | Bounded work |
| --- | --- |
| `gameplay/run/run_clock.gd`, `run_identity.gd` | Retain exact elapsed identity/time ownership; remove calendar conversion, day clamp and rollover. |
| `gameplay/run/run_schedule.gd`, `run_scenario.gd` | Replace calendar policy with only the continuous coordination and fixture work required here. Remove daily roster/meal/request production and midnight resolution. Preserve lift-boundary causality. |
| `gameplay/run/run_shell.gd`, `night_report.gd`, `clock_hud.gd` | Retain launch/confirmation/pause/Save & Exit; remove report phase/signals/UI and calendar HUD. Wire collection progress and completion presentation. |
| `gameplay/run/run_snapshot.gd`, `timed_state_validation.gd`, `run_save_service.gd`, `state_codec.gd` | New schema and active-time/goal/fixture validation; retain physical integrity and one save path. Remove obsolete report/calendar validation rather than accepting fabricated compatibility. |
| `gameplay/logistics_wing/wing_gameplay.gd` | Replace M4 activation/default dependencies. Remove obsolete station creation and initialization requirements without removing physical room props or authored development stock. |
| `gameplay/logistics_wing/functional_fixtures.gd`, `functional_storage_manager.gd`, `storage_surface.gd` | Establish deliberate qualifying-storage registration and settled read access. Preserve storage algorithms and authoring. |
| `receiving/awaiting_lift_admission.gd`, `gameplay/logistics_wing/receiving/receiving_runtime.gd` | Retire forfeiture, retain admission/FIFO/cargo continuation and one lift driver. Follow references to the existing lift/manager owners only where required. |
| `gameplay/requests/dispatch_loadout.gd`, `dispatch_interface.gd` and their callers | Remove production prebuilt-roster/carousel/auto-dispatch policy when unused. Preserve/extract only genuinely shared Bulk/Utility/receipt functions; do not rebuild preparation yet. |
| `gameplay/requests/contribution_request.gd` and shared station/UI code | Retain useful tested transaction/credit logic without active daily producers. Do not discard ordinary request completion because automatic expedition departure is obsolete. |
| `item_definition.gd`, `item_instance.gd`, existing catalogue | Read canonical authored values; validate the scoring interpretation. No balance, physical metadata or full contextual-schema migration by default. |
| Proposed `gameplay/run/collection_goal.gd` and `collection_goal_hud.gd` | Small goal authority/read model and presentation. Reuse existing layout/components where simpler; no name or architecture proliferation is required. |
| Proposed `data/scenarios/collection_foundation/` | Self-contained active-seconds fixture, identity/revision and target. |
| `tools/asset_pipeline/tests/` | Add focused successor tests; retain relevant physical/transaction assertions, retire obsolete daily assertions/runners. |

**Known coupling to account for:** the schedule presently drives the lift; the shell reads `REPORT_PENDING`; the snapshot depends on clock/schedule/request history; the wing checks for legacy consumer nodes and uses M4 revision-specific seeding. Hiding UI or leaving an enormous artificial day does not retire these dependencies.

## 6. Safe decommissioning and history

Remove obsolete production scripts, branches, signals and nodes once actual references are accounted for. No old/new mode, survival plugin hooks, dormant replacement scheduler or duplicate implementation of shared owners. Do not delete shared logic merely because its original file name mentions an older milestone.

Retire daily-only tests from current required suites. Preserve their prior results and Git history; do not change expected behavior merely to manufacture a passing legacy test. Extract retained ownership/time/pause assertions into successor tests where useful. Do not leave archived `.gd` copies inside Godot's scanned project merely for historical access.

Move standalone retired specifications and frozen M4 fixture data out of active work locations into a clearly historical area, for example `docs/design_history/survival-era/`, retaining contents and a source-revision/path map. Fix affected current links and runner references. The new fixture must not import the archive at runtime. Keep accepted validation evidence discoverable; moving it must not rewrite test outcomes.

Do not move entire mixed-purpose GDD/MVP/VDD masters just because they contain history. Update their current-facing status/pointers proportionately, preserving evidence and unresolved registers. No broad repository reorganization is a prerequisite. Original M4 can be inspected at its historical revision; maintaining it as a launchable second mode on the new branch is not an acceptance condition.

Preserve local uncommitted authoring, unknown sidecars, licensed/ignored assets and source provenance. Never clean or reset the user's working tree to match this brief. Runtime noninteractive props may remain as scene context without retaining retired gameplay controllers.

## 7. Implementation sequence and proof

These are implementation steps inside one coherent slice, not separately reviewed administrative milestones. Use focused failing tests before each owning behavior change, verify the intended failure, then implement and rerun. Keep local commits recoverable. Do not merge/push without separate authorization.

### Step 1 — Continuous runtime and retirement

- [ ] Verify live branch/ref, asset-equipped checkout, engine, uncommitted/ignored dependencies and test/save isolation. Read current guidance and the targeted source owners; record a short caller/disposition map in the task result, not a separate audit report.
- [ ] Add a focused continuous-time/Receiving test. Prove the old boundary behavior is the reason it fails; do not accept a parse/import failure as useful evidence.
- [ ] Replace the calendar-driven production path, detach obsolete consumers/report UI, introduce the new fixture and preserve one causal lift driver.
- [ ] Verify normal and large advances past **2,700 active seconds** (the M4 first-day boundary), repeated former boundaries and **600 seconds** (its morning preparation boundary) cause no rollover, report, dispatch, request issuance, pause or cargo loss. These numbers are regression probes, not successor gameplay timings.

### Step 2 — Goal ownership and presentation

- [ ] Add goal tests for all categories, excluded contexts, stack members, cross-surface movement, failed/stale transfers and reversible category satisfaction.
- [ ] Implement qualifying registration, settled live totals and first-victory recording; attach the compact HUD to normal play.
- [ ] Check manual zoning mismatch and later erased cells do not change item category or invalidate retained stored stock. Verify all eight must coincide; earlier category peaks do not qualify.
- [ ] Check first victory with pending cargo/carried surplus succeeds, continued play remains active, and later stock removal does not revoke or retime the result.

### Step 3 — Successor continuation and saves

- [ ] Add new-schema round trips and incompatible-schema/no-write checks in isolated temporary save directories.
- [ ] Adapt validation/capture/restore; add the isolated successor namespace and provisional automatic-save triggers.
- [ ] Test mid-arrival, OPEN partially unloaded, closing/outbound, deposited queue and upstream waiting continuation; exact item identities and remaining phase time must survive.
- [ ] Test paused contexts, close/relaunch, target/revision preservation, completed-run restoration, interval/victory coalescing and failed saves. Confirm M4 files are byte-unchanged.

### Step 4 — One integrated result and cleanup

- [ ] Demonstrate a complete controlled-cargo -> TAKE -> carry -> qualifying storage -> goal -> Save & Exit -> Continue path through the ordinary scene.
- [ ] Exercise one deliberately full receiving queue and an additional waiter; unload to show ordered admission without expiry or double delivery. Check full-OPEN gating, last-TAKE/outbound retirement, CRT and audio with targeted rendered/human coverage.
- [ ] Remove now-unreferenced daily code, retire obsolete tests and relocate only the related historical records/fixtures. Check preload/resource references, class registrations, current documentation links and normal launch.
- [ ] Run the changed-owner suite plus relevant storage/carry/placement, admission/queue, pause/input and save-integrity regressions once as a final sweep. Preserve errors, exit codes and evidence attribution. Do not re-audit EAF/art/catalogue or rerun every historical test by default.
- [ ] Provide one consolidated result record, concise code/diff summary, retired-path list, exact checks/results, temporary limitations and a short developer playtest. Stop for human disposition; no later expedition work or publication follows automatically.

Suggested test entry points, following the existing test-directory convention:

```text
tools/asset_pipeline/tests/continuous_run_foundation_tests.gd
tools/asset_pipeline/tests/collection_goal_tests.gd
tools/asset_pipeline/tests/collection_continuation_tests.gd
```

Use the repository's actual SceneTree test style. On Windows, the command shape for a new standalone test is:

```powershell
& $Godot --headless --path $Project --script res://tools/asset_pipeline/tests/collection_goal_tests.gd
```

`$Godot` and `$Project` must be the locally verified executable and asset-equipped checkout. A successful result requires zero reported failures, exit 0 and no hidden abort/import/parse error. This command and the proposed tests have not been executed during brief preparation. Rendered/audio checks are separate from headless assertions.

## 8. Completion boundary

The implementation can be called technically ready only when the normal successor path has continuous time, truthful live goal progress, immediate recorded completion, exact receiving/storage behavior and coherent continuation, and the retired calendar policies are unreachable/removed rather than hidden behind a toggle.

The short human check should cover: ordinary receiving/sorting, retrieving below a target, finishing the final category, continued play, zoning/ESC pause, Save & Exit/Continue with cargo waiting, and clear inactive-service/fixture messaging. Human acceptance is distinct from technical verification and repository publication.

Report the final target/fixture, storage-eligibility list, autosave timing/cost and remaining design limits. This does not establish production storage capacity, a substantial 80%-occupied winning hoard, actual expedition rewards, no-dead-end economics for future systems or release durability. Those belong to later scoped work.

## Appendix A — Confirmed expedition lifecycle decisions for the next milestone

**Source:** the developer's latest message approving the transition and supplying the three lifecycle decisions. These supersede the corresponding open statements in GDD §§9.3–9.5, 11.2/11.6 and O-02–O-04 only to the extent specified below. They do not turn this foundation into expedition implementation.

### A1. One editable draft; one committed preparation

Before the first accepted supply, the current preparation consists of a chosen 1–4 Ready-scavenger count and zero, one or two affinity selections. Both size and destination choices remain editable. Merely opening the panel or making selections commits neither personnel nor a destination.

The first **successfully accepted** supply forms the team entity and commits its selected personnel. Accepted supplies retain the established irreversible contribution/receipt semantics; there is no second spend on Dispatch and no reclaimable team-inventory store. Alternatively, a successful explicit Dispatch forms and sends it with zero loadout. From formation onward, team size is fixed; affinity/destination choices remain editable until departure. Rejected submissions or failed Dispatch validation must not consume an item, form a team, occupy a destination or remove Ready personnel.

Closing/reopening preserves count, selected affinities, commitment state and contributions, including an uncommitted draft. These are logical preparation settings, not just transient controls. Existing continuation principles require their later save support; this does not require serializing an open panel or pending input.

The player cannot prepare another crew until the current one dispatches. Do not add cancellation/refund/disband mechanics that circumvent that rule. An uncommitted draft can still be edited in place. Validate current Ready availability again at the successful commitment boundary; a single panel removes competing drafts, not the need for transactional correctness.

### A2. Destination occupancy is away-only

One concurrent expedition per destination. Occupancy begins only on successful Dispatch, not on pair selection or first contribution. It ends when the expedition returns, even if the crew must wait to hand over its cargo.

Consequently several returned crews may wait with cargo from the same destination. Identify expeditions/returns independently; never use the destination ID as the unique return or team identity. Selecting a destination does not reserve it pre-departure. Failed departure leaves its occupancy unchanged.

### A3. Personnel release follows successful cargo admission

On return, release the destination. If Receiving cannot accept the haul, retain the exact waiting cargo and unavailable crew. Admission into either the free active-lift slot or either free deposited queue slot completes cargo handover. An awaiting record alone does not.

Immediately after successful handover, route healthy members to Ready and injured members to Medical as patients. Injured members are not briefly exposed as Ready before classification. Waiting for physical descent, opening, unloading or outbound retirement is not required for personnel release. Lift timing, deposited capacity, FIFO/monitor behavior and TAKE remain unchanged.

Expedition owns its personnel/return transition; Receiving accepts ownership of the deposited cargo; Medical will own treatment after patient admission. Retain identifiers/history as needed without retaining a second authoritative cargo owner. Consumption/transfer acknowledgements must be handled exactly once across immediate admission, later admission, callbacks and restoration. Loading restores facts; it does not repeat triage or personnel release.

The first expedition-to-storage proof may use all-healthy returns and simple durations/acquisition. Recruitment, injuries and full Medical implementation are separate scope. Do not introduce placeholder injury simulation merely to claim the complete lifecycle exists.

### A4. Implications, not objections

A partially supplied team can remain prepared indefinitely, tying up its selected scavengers until explicit departure. This is a visible opportunity cost, not a reason to add a timeout or auto-dispatch. Zero-loadout departure avoids requiring a completed loadout to release the preparation slot.

Deposited backlog can accumulate while some healthy crews are already Ready again; only upstream waiting blocks their release. Destination restriction prevents simultaneous journeys, not repeated throughput through that archetype. This follows the developer's stated example and is intentional, not an exploit to close.

No blocker to the present foundation follows. Before implementing actual expeditions, still define incomplete-affinity Dispatch behavior and **zero-item returns**, because the existing admission seam rejects drained/empty batches. Do not infer an empty lift journey or copy the old random-fallback rule automatically. Exact defaults for a fresh preparation and full injury rules also remain later choices. A return waiting with cargo has not yet entered Medical; treatment-start rules must respect that boundary.

The developer also explicitly approves safe removal of obsolete code and separating retired records from live guidance. A possible survival mode does not justify dormant hooks or an old/new toggle.

## Appendix B — Source pointers and inspection limits

All repository pointers below are pinned to the inspected reference, not assertions about a later checkout. Section names refer to the approved published documents. The latest lifecycle message and approval of the transition are conversation authority; no repository URL or fabricated timestamp is assigned to them.

- [Working guidelines](https://github.com/Navandis/Sorting-apoc-PROTOTYPE/blob/be220667b720e0bf81b8b00dcae9bbbb50789b6c/docs/AI_WORKING_GUIDELINES.md): proportional execution, preservation and review.
- [GDD v0.16 reading copy](https://github.com/Navandis/Sorting-apoc-PROTOTYPE/blob/be220667b720e0bf81b8b00dcae9bbbb50789b6c/docs/readable/Sorting_Apocalypse_Preliminary_GDD_v0.16.md): §§5–6 (goal/time/items), §§9–11 (expeditions/receiving), §18 (owners/continuation), §§20–21 (scope/open decisions).
- [Systems MVP v0.5, compatibility-updated](https://github.com/Navandis/Sorting-apoc-PROTOTYPE/blob/be220667b720e0bf81b8b00dcae9bbbb50789b6c/docs/Sorting_Apocalypse_Systems_MVP_Foundation_Design_and_Progress_v0.5.md): retained accepted implementation and evidence, not survival defaults.
- [Current state](https://github.com/Navandis/Sorting-apoc-PROTOTYPE/blob/be220667b720e0bf81b8b00dcae9bbbb50789b6c/docs/CURRENT_STATE.md): authoring, saves, Receiving and historical milestone boundaries.
- [Run scheduler](https://github.com/Navandis/Sorting-apoc-PROTOTYPE/blob/be220667b720e0bf81b8b00dcae9bbbb50789b6c/gameplay/run/run_schedule.gd), [clock](https://github.com/Navandis/Sorting-apoc-PROTOTYPE/blob/be220667b720e0bf81b8b00dcae9bbbb50789b6c/gameplay/run/run_clock.gd), [shell](https://github.com/Navandis/Sorting-apoc-PROTOTYPE/blob/be220667b720e0bf81b8b00dcae9bbbb50789b6c/gameplay/run/run_shell.gd), [scenario](https://github.com/Navandis/Sorting-apoc-PROTOTYPE/blob/be220667b720e0bf81b8b00dcae9bbbb50789b6c/gameplay/run/run_scenario.gd): known shared-time/calendar/report coupling.
- [Snapshot](https://github.com/Navandis/Sorting-apoc-PROTOTYPE/blob/be220667b720e0bf81b8b00dcae9bbbb50789b6c/gameplay/run/run_snapshot.gd), [save service](https://github.com/Navandis/Sorting-apoc-PROTOTYPE/blob/be220667b720e0bf81b8b00dcae9bbbb50789b6c/gameplay/run/run_save_service.gd): state validation and prior-file retirement behavior.
- [Wing entry](https://github.com/Navandis/Sorting-apoc-PROTOTYPE/blob/be220667b720e0bf81b8b00dcae9bbbb50789b6c/gameplay/logistics_wing/wing_gameplay.gd), [functional fixtures](https://github.com/Navandis/Sorting-apoc-PROTOTYPE/blob/be220667b720e0bf81b8b00dcae9bbbb50789b6c/gameplay/logistics_wing/functional_fixtures.gd), [storage surface](https://github.com/Navandis/Sorting-apoc-PROTOTYPE/blob/be220667b720e0bf81b8b00dcae9bbbb50789b6c/storage_surface.gd), [item definition](https://github.com/Navandis/Sorting-apoc-PROTOTYPE/blob/be220667b720e0bf81b8b00dcae9bbbb50789b6c/item_definition.gd): initialization, registered storage and current category/value representation.
- [Awaiting Lift admission](https://github.com/Navandis/Sorting-apoc-PROTOTYPE/blob/be220667b720e0bf81b8b00dcae9bbbb50789b6c/receiving/awaiting_lift_admission.gd): immediate/awaiting handover, finite deposited admission, forfeiture and empty-batch constraint.
- [Old loadout specialization](https://github.com/Navandis/Sorting-apoc-PROTOTYPE/blob/be220667b720e0bf81b8b00dcae9bbbb50789b6c/gameplay/requests/dispatch_loadout.gd): full/cutoff dispatch versus retained accounting.

Inspection combined the immediately preceding pinned scheduler/snapshot review with fresh checks of the unchanged reference and the additional owning files; it is not a new whole-repository audit. Read-only source inspection is not a gameplay test. The local licensed asset set, uncommitted state, engine execution, exact new fixture feasibility and performance remain execution-time checks. This brief changes no master, repository file, save, scene or item definition.
