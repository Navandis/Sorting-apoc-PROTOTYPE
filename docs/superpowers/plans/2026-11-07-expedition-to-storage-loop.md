# Sorting Apocalypse — Expedition-to-Storage Loop

**Recommended configuration:** One implementer, focused tests, one consolidated independent review and a developer playtest. Follow `docs/AI_WORKING_GUIDELINES.md` over generic workflow ceremony.

## 1. Task, authority and stopping point

Implement the first **real expedition-to-storage loop** on the accepted Continuous Run and Collection Goal Foundation:

> Choose a crew, provision it, select two affinities, explicitly dispatch, wait for its committed outcome, return, hand cargo over through existing Receiving, release personnel at the correct boundary, and store the goods toward the live collection goal. Repeat with another expedition.

The developer approved this bounded model and its test-only duration/acquisition rules in the conversation. This prompt records those decisions and supersedes the relevant unresolved expedition entries in GDD v0.16 and foundation Appendix A. It is not an approval of a complete Expedition economy, Medical simulation or the old M5 scope.

Use focused local implementation and verification. Local task commits are permitted after the foundation is securely checkpointed. No merge, push, PR, destructive Git cleanup or automatic human promotion/publication. Stop with a technically verified result and a focused human playtest; do not implement the following milestone.

Save this brief in `docs/superpowers/plans/2026-11-07-expedition-to-storage-loop.md` as part of this task's bounded documentation. Do not create a second contradictory specification or require another brainstorming cycle for the decisions already recorded below.

### Read first and establish the base

Read `docs/AI_WORKING_GUIDELINES.md`, `docs/CURRENT_STATE.md`, `docs/CODEX_BOOTSTRAP.md`, and:

- `docs/testing/2026-11-07-continuous-run-collection-goal-closure.md` and its linked result record.
- The foundation brief's Appendix A, retained alongside its result.
- Current GDD v0.16 §§8–11, §18, and the relevant open-decision entries; current MVP implementation/continuation notes.

Confirm the actual local checkout, branch, engine and asset availability. Use the closure response's SHA or the Git commit introducing its closure record to establish the accepted base; inspect any later changes. A published remote is not required if the verified local checkpoint is available. Do not treat `d802de64...`, `be220667...` or an old M4 SHA as the completed foundation, and never reset local work to a historical anchor.

If the closure is still uncommitted, relevant source differs from the accepted checkpoint, or unrelated modifications overlap this task, explain the concrete situation before overwriting anything. Do not demand a whole-project audit or unrelated clean tree. Use the asset-equipped workspace and safe branch/isolation practice; do not create an asset-blind worktree or duplicate Godot-scanned scripts/resources.

The supplied foundation result is evidence of the preceding slice, not a source inspection of the current checkout. Discover actual current interfaces before editing. Do not restore the removed day scheduler, Dispatch carousel/loadout implementation or nightly logic from history merely to get a convenient starting point.

## 2. Included scope and deliberate omissions

Included: one persistent editable preparation; anonymous Ready personnel and formed crews; 28 two-affinity destinations; explicit Dispatch; five-lane contribution accounting; committed random duration and bounded random cargo; away-only destination exclusivity; return/admission/personnel transitions; zero-item returns; a readable preparation panel and minimal operation status; continuation and relevant regressions.

Omitted: injuries, triage computation, treatment, death, recruitment, persistent team-slot training, request penalties, Kitchen/Medical/Ops recurrence, Workshop/upgrades, disposal production systems, PA/announcements, a full Journal, production balancing, unrestricted catalogue acquisition, new room art/geometry, time acceleration, survival events or destination depletion.

All crews return healthy in this slice. No simulated Medical admission is needed to claim lifecycle completeness. The future routing boundary remains: triage follows handover, healthy members go Ready, injured members become patients without briefly becoming Ready.

Zero-loadout crews may be economically superior in this deliberately incomplete model. Do not add injuries, lost loot, preparation quality bonuses, minimum provisioning, slower unprovisioned trips, or hidden catch-up to correct that incentive. No conclusions about balance, pace, optimal strategy, production duration or final target follow from this test.

## 3. One current preparation

A preparation starts as a logical draft: chosen count of **1–4** currently available Ready scavengers, and zero, one or two distinct affinities. It does not reserve personnel or a destination merely because the panel opens or controls change.

**Formation occurs atomically at the first successfully accepted supply, or at a successful zero-loadout Dispatch, whichever happens first.** Remove the selected count from Ready exactly once, assign a durable expedition/team identity and retain that crew. Failed or rejected commands do not form a team, consume anything or change occupancy.

Before formation, both count and affinities remain editable. After the first accepted supply, count is locked; affinities remain editable until departure. Existing committed supplies remain spent under the whole-item receipt model; no second spend at Dispatch, reclaimable loadout store, refund, cancellation/disband action, resizing or timeout is introduced.

Closing/reopening preserves the exact count, partial or complete affinity selection, formation state and contribution progress—even for an uncommitted draft. These logical settings also survive Save & Exit / Continue. Transient UI focus, open panels and queued clicks need not reopen on load. No other team may be prepared until the current one successfully dispatches. After Dispatch, the panel can immediately prepare the next crew consecutively; no team-preparation tabs or parallel loadouts.

Revalidate Ready availability at the actual formation boundary. An uncommitted displayed count is not a reserved crew. A locked preparation is valid even when the remaining Ready count is zero; do not require those same members to be available a second time.

### Contributions and capacity

Reuse the retained shared contribution/receipt/transfer logic, not a second item-consumption implementation. F opens/closes the panel without spending; a distinct E contributes one selected eligible whole item. No held-repeat spending or automatic selection of an ideal item. Preserve pre-commit preview, applied credit, excess waste, outgoing Bulk, member count, lane targets, remaining capacity and rejection explanations.

Use Food, Hydration, Medical, Weapons and Protection lanes. Targets and raw capacity scale linearly with the selected count. Reject a wrong-category, already-full-lane or over-capacity item without spending or forming a crew. Successful submissions cap Utility at remaining lane demand, waste the excess and charge the item's entire Bulk. Definitions are never edited to make a contribution fit.

`return_capacity = member_count × per_member_capacity − submitted_bulk` must never be negative. Reaching 100% of all lanes does **not** dispatch or destroy the editable preparation. Zero provisioning remains legal. Count and lane completion are separate from destination selection.

The task uses the agreed single-category/primary-Utility interpretation. Do not reactivate historical alternate-context item uses. Reuse or narrowly adapt current category access; broad removal/migration of unused legacy catalogue fields is not a prerequisite and does not authorize editing the 167 authored definitions.

## 4. Destination selection and dispatch

Eight categories, alphabetically arranged in a stable two-row/four-column selector:

`Electronics | Food | Fuel | Hydration`

`Medical | Morale | Protection | Weapons`

Select two **distinct, unordered** categories. Clicking a selected icon deselects it, including when a pair is complete; it can then be selected again. Do not reorder the controls by stock shortages or auto-select a recommended pair. The loadout supply area and affinity area are parallel parts of the same broader panel. Reuse existing icons where available; labeled prototype buttons are acceptable rather than commissioning art.

There is exactly one destination for each pair: **28 total**. Canonical pair identity is independent of click order. Existing suitable names can be reused; absent finalized names, clearly marked development pair labels are sufficient. No map, unique hazards/travel profiles, generic destination, availability-event system or depletion.

**Dispatch requires exactly two selected affinities identifying an available destination**, as well as a valid crew. It is disabled with zero or one affinity. Explain the missing requirement. No random assignment, countdown, cutoff or auto-dispatch fallback. For zero return capacity, Dispatch remains possible after the warning confirmation below.

One **away** expedition per destination. Occupancy begins only when Dispatch succeeds, never on selection or first contribution. Release it at return, even if cargo must wait upstream. A preselected destination must be revalidated at dispatch; a busy/invalid selection must not redirect or silently change. Dynamic partner disabling follows currently available pairs; selected controls remain deselectable. If a category has no available partner, explain its unavailable state.

A returned team can be Awaiting Lift while another team departs for the same destination. Multiple returned teams may consequently await cargo handover from that destination. This is intentional. Destination ID is never a unique expedition/return ID.

### Zero-capacity departure warning

On clicking Dispatch with zero remaining return capacity, show a short confirmation, for example:

> No return capacity. This team's supplies occupy its entire carrying capacity. It will return without loot.
> Back to preparation / Dispatch anyway.

Back preserves the existing preparation and receipts. Dispatch anyway follows ordinary validated departure. Revalidate on confirmation; stale modal actions and repeated clicks must not double-send. Keep the surrounding preparation and warning live under the approved test direction; ESC closes the top panel/modal before the normal pause menu. The normal nested pause safeguards remain.

## 5. Test acquisition and timing — not production tuning

### Approved test rules

- Duration is a uniform random **90–180 active seconds** for every team size/loadout. A continuous draw in that interval is the default; no additional size or provisioning modifier. Commit it once at successful Dispatch and preserve the actual return timestamp.
- Use a declared representative pool covering all eight categories, drawn only from existing active, approved item definitions. Several choices per category are preferred where physically practical. Other catalogue items remain valid for normal storage and eligible provisioning; the acquisition pool does not restrict those uses.
- Baseline category selection is equal: 1/8 each. With two affinities, each affinity receives **15%**, and each of the other six **7/60 (approximately 11.6667%)**, before fit restrictions. This is exactly a 20% relative increase over 12.5%, not +20 percentage points and not a 1.2-weight normalization yielding 14.2857%.
- An exact relative representation is **9 for each affinity and 7 for each other category**, total 60. Mask categories without a fitting item and normalize only across the remaining categories. Apply both affinities identically; there is no hidden primary/secondary tier.
- Pick a category first, then an eligible whole item within it. Handoff implementation default: uniform choice among the declared eligible item definitions of that category. More definitions must not increase a category's selection probability.
- Repeated types are permitted, with distinct physical instance identities. Fill from the remaining Bulk budget until no eligible whole item fits; stop cleanly at zero budget. Do not exceed capacity, force an affinity representative, target the player's deficits or alter item Utility/Bulk.
- The final manifest and travel duration commit at successful Dispatch. Preserve those exact outcomes, identities and any accepted presentation arrangement. Reloading/receiving/waiting must not regenerate them. No loot preview from opening or editing the preparation.

These are category-selection probabilities, **not** guaranteed Utility shares or a 20% increase in delivered Utility. Near the capacity limit, feasibility filtering changes the distribution. Keep hidden probability numbers out of the player-facing destination description; communicate the two potential supply affinities qualitatively.

### Bounded authoring choices delegated to the implementer

Record them in a small test configuration before integration; they are not new release design:

- **Handoff-author starting default: eight healthy Ready scavengers**, no recruitment or daily replenishment. This supports a full crew plus several small crews and queue-pressure tests. It is a test roster, not revival of an earlier opening-population target. An anonymous count/ledger is sufficient; no named-character simulator.
- Choose one conservative positive integer per-member Bulk budget and five positive integer per-member lane targets. Demonstrate actual catalogue items can exercise both a completed loadout and zero remaining capacity through the real contribution rules. Keep them fixed during a reported test run. Do not automatically inherit M4's 28 / 12-12-6-12-12 as current production balance.
- Declare exact pool IDs, their authored Category/Utility/Bulk and the maximum possible four-member manifest budget. Preserve the original loose starting palette and the current target of six/category unless a concrete mechanical test requires a separately labeled test variant. A small, explicit runtime-only loadout test bundle is allowed if needed; it must not mutate the developer's saved palette or become hidden replenishment.
- Choose a simple fresh-draft default and document it. It applies only to a genuinely fresh preparation; reopening or loading must preserve the prior draft exactly. Do not auto-form or auto-dispatch a crew.

### Presentation feasibility is an integration gate, not a loot penalty

The preceding fixture proved twelve particular items, not unrestricted randomly composed hauls. Inspect the current preparation planner and conservative pool before treating this as ready to run. Bound maximum count through the chosen capacity and positive item Bulk; check representative mixed hauls and credible count/footprint/height extremes at the four-member budget. Use bounded deterministic seeds and representative actual TAKE checks, not exhaustive catalogue approval or thousands of unrelated engine launches.

Every selected manifest must be presentable through unchanged Receiving, with progressive normal reticle/TAKE access. Where practical, prepare/validate its arrangement within the Dispatch transaction before publishing Away state. That does not reserve a lift slot, start travel presentation or show the outcome early.

If the pool/budget cannot be supported, narrow the **declared test configuration** before accepting the implementation. Never hide a failure by rerolling, trimming cargo, converting it to an empty return, expanding the lift or inventing overflow trips. An unexpected preparation failure is a technical error: preserve committed preparation, do not publish a successful departure, and report it. If resolving it requires a larger presentation rewrite or a changed gameplay rule, stop that expansion and explain the concrete conflict.

## 6. Return, cargo handover and personnel

### Nonempty return

At the committed return timestamp, Expedition releases the destination and submits the exact cargo through the existing upstream admission path. Do not deposit directly into ReceivingManager in a way that bypasses oldest-waiting fairness.

If admitted to the free active slot **or a free deposited queue slot**, cargo handover succeeds and the crew completes its return. For this all-healthy slice, all members become Ready immediately and exactly once. Do not wait for descent, full opening, unloading, last TAKE or outbound retirement.

If admission reports Awaiting Lift, the members remain unavailable. The existing upstream owner retains the exact cargo commitment. A later successful admission completes the personnel return once. Expedition retains status and references as needed, not a second authoritative mutable copy of cargo already owned upstream/Receiving.

Handle immediate admission and delayed callbacks without double-release. Settle ownership coherently before saving or notifying other systems. A failed admission is an error, not cargo abandonment or a successful crew release. Duplicate callbacks and restored completed records cannot add Ready members again.

### Empty return

Include this now, under **Expedition** ownership. A legitimate zero-item outcome travels normally, occupies its destination until return, then releases that destination and completes personnel return immediately. It does not call the cargo-admission path with a fake empty batch, allocate a deposited slot, trigger lift motion, enter Awaiting Lift or wait behind other cargo. Full queues do not delay it.

For this slice, empty-return personnel all become Ready. Later injury classification will use this completion boundary; do not add a triage subsystem or injured-away behavior now. Provide a brief visible returned-with-no-loot status. The proposed PA announcement is deferred.

This applies to any legitimate empty generated outcome, including positive residual capacity smaller than every eligible whole item. A sampler/planner/integration failure is not a legitimate empty outcome.

### Invariants and unchanged Receiving

For this fixed healthy test roster:

`initial_personnel = Ready + committed_preparation_members + Away_members + Awaiting_Lift_members`

An uncommitted draft contributes nothing to that sum. Deposited cargo contributes nothing: its crew has already returned. Validate conservation and terminal transitions rather than adding artificial roster limits to conceal leaks.

Each departure has its own durable identity. Preserve exact cargo, destination occupancy, chronology and receipts across repeated visits and callbacks. Several waiting expeditions can share a destination ID.

Receiving remains one active plus two deposited FIFO slots, with an uncapped upstream waiting collection. Preserve the CRT's existing distinction between deposited queue and upstream waiting, stationary deck/barrier, fully-OPEN TAKE, sound/shutter sequence, indefinite OPEN, and full outbound turnaround before retirement/promotion. Do not give new arrivals priority over older waiters or enlarge physical capacity. No cargo loss, midnight rules or abandonment timers.

## 7. Integration, interface and continuation

The normal successor New Run should use actual player-dispatched expeditions as its recurring source of incoming cargo. Remove the automatic two-haul foundation demonstration from that normal path; preserve its exact fixture/evidence where useful for isolated regression tests, not as a second player mode or concurrent unexplained free deliveries. Preserve the human-authored starting palette and never reseed on Continue.

Activate the existing Dispatch frontage with a single unpaused preparation panel. Retain useful old loadout information, without restoring the old carousel/tabs. Display selected members, available Ready count, five lanes, selected-item credit/waste and full Bulk, outgoing/remaining capacity, affinities/destination and dispatch validity. Provide a small read-only status view sufficient to distinguish Away and Awaiting Lift crews and understand unavailable destinations. Monitoring is not parallel preparation. No bespoke monitor network or Journal is required.

Use the accepted continuous clock for travel and all existing mechanics. Process due returns at their actual timestamps, in a stable order for ties, and coordinate with lift boundaries so a large test advance and ordinary frames agree. Do not add an independent wall clock, offline progress, calendar, time skip or shortcut that admits cargo early.

Extend the same snapshot/codec/save service. Preserve logical drafts (including an uncommitted single-affinity draft), locked crew count, receipts/Bulk, Ready/away/waiting counts, canonical destinations, committed duration/cargo, unique identity allocation, return/admission completion and the accepted physical/goal/time state. Away cargo must be represented in authoritative ownership accounting before it reaches Receiving. Completed receipts and released cargo cannot be duplicated or resurrected on load; preserve the foundation's corrected released-cargo validator guarantees.

Restore coherently before enabling player input, returns or callbacks. Continue does not form a team, reroll duration/cargo, spend again, free a waiting crew, reoccupy a returned destination or repeat completed handover. Already-materialized cargo keeps exact remaining entries and arrangements. Store the test configuration/revision needed to interpret a run; do not silently apply edited pool/capacity parameters to old commitments.

A fresh test run and an explicit next-unused save schema are permitted if the new state requires them. Do not auto-convert a schema-5 foundation run by injecting a roster or replaying its fixture. Keep old saves intact, reject unsupported continuations explainably, and preserve New Run confirmation. Reuse `user://saves/collection/` and the existing service unless a concrete implementation reason requires a disclosed alternative; do not introduce a parallel serializer or accumulate old/new gameplay modes. Use isolated temporary save directories for all automated and manual executor proofs, including native rendering. Preserve the developer's real collection and M4 saves; any replacement of a real active slot belongs to the developer's explicit New Run choice, not testing convenience.

Retain 60-active-second automatic attempts, first-victory saving, coalescing and failed-save behavior. This task does not implement release crash durability, fix silent Windows suspension or redesign synchronous saving. Recheck only regressions caused by the added state, and record any meaningful new cost.

## 8. Suggested implementation sequence and owning areas

These are steps inside one milestone, not separate review/approval ceremonies. Begin by mapping actual files in the checkpoint; paths below identify ownership areas, not claims that uninspected post-foundation classes already exist.

1. **Inspect retained interfaces and author the bounded test configuration.** Read `gameplay/run/`, the surviving `gameplay/requests/` transaction/panel logic, `gameplay/logistics_wing/wing_gameplay.gd`, the current Receiving runtime/planner, `receiving/awaiting_lift_admission.gd`, current snapshot validators and the foundation tests. Resolve the exact source map and pool/capacity feasibility in a short local task breakdown.
2. **Add preparation/dispatch and anonymous personnel state.** Prefer small expedition-owned modules, for example under `gameplay/expeditions/`, rather than storing personnel in Receiving or the HUD. Reuse transaction boundaries and bind the new panel to state. Tests first for formation, rejection, editable draft, fixed committed count and explicit dispatch.
3. **Add acquisition, travel and return integration.** Exercise exact weights, fit filtering and stable commitments; then nonempty immediate/waiting returns and the Expedition-owned empty-return path. No speculative future Medical framework.
4. **Extend continuation and connect normal F5 play.** Preserve every new state through the current service, remove the recurring source ambiguity, expose minimal operation status, and run affected physical/clock/goal regressions.
5. **One integrated verification and review.** Capture evidence on first useful runs, inspect failures/logs, repair concrete findings, rerun affected checks and deliver for human playtest. No phase-by-phase subagent assembly line.

A compact implementation plan using exact inspected file paths and relevant existing test commands is sufficient. Do not turn source mapping, documentation or packaging into new reviewed milestones.

## 9. Required focused proof

Use the existing Godot test style and isolated saves. The preceding record used `Godot --headless --path <project> --script res://tools/asset_pipeline/tests/<name>.gd`; confirm the executable and local invocation. Use new focused tests rather than resurrecting daily-only suites. Verify the intended failure before fixing it, then inspect exit codes and diagnostics as well as PASS markers.

| Area | Required observations |
| --- | --- |
| Preparation | Counts 1–4; unavailable count rejection; draft survives close/reopen and Continue; rejected first supply commits nothing; accepted first supply commits once and locks count; affinity edits remain possible; another draft cannot begin before departure. |
| Contribution and Dispatch | Whole-item receipt/Bulk/waste; no double spend; full lane/capacity rejection; fully supplied team stays in preparation; zero-loadout sends; zero/one affinity cannot send; deselect/reselect; zero-capacity confirmation and cancellation; repeated/stale dispatch commands are inert. |
| Destinations | Exactly 28 canonical unordered pairs; swapped click order is identical; busy pair blocks departure; return releases it before admission; repeated visits from that pair can wait concurrently. |
| Acquisition | Exact unmasked 9/7 weights, normalized 15%/15%/7/60 for six others; valid uniform item selection; fit filtering; no negative/over-budget Bulk; repeated types get unique IDs; no hidden guaranteed categories or Utility promises. Check probability logic directly—do not require each random haul or small sample to look balanced. |
| Timing and ownership | Duration in 90–180 active seconds, committed once; no outcome changes on Continue; appropriate pause behavior; large-step/ordinary return ordering; cargo belongs to one owner before and after transfer. |
| Handover | Immediate active-slot and queued-slot admission both release healthy personnel; Awaiting does not; existing older waiters are not bypassed; duplicate callbacks cannot release twice; ready/formed/away/waiting sum remains constant. |
| Empty returns | Zero capacity and a positive-but-unfillable budget return normally without a batch/trip/slot/waiter; full deposited and upstream queues are unchanged; personnel/destination release once, including save/reload around completion. |
| Continuation | Uncommitted draft, partially supplied preparation, Away, Awaiting, deposited cargo and completed empty/nonempty returns round-trip. Preserve receipts, exact manifest/time, occupancy and goal. Malformed duplicate/released-owner/personnel records reject before mutation. Failed save retains last valid continuation; incompatible older saves remain untouched. |
| Real interaction | At least one complete preparation→journey→actual cargo→reticle/TAKE→storage path at representative 1- and 4-member budgets, plus congestion and crew reuse. Include normal input and a native Compatibility render with the wider panel, continued live clock and unchanged lift/CRT. |
| Foundation regression | Qualifying/excluded storage, zone independence, eight simultaneous targets, first-victory time with continued play, autosave and basic storage/lift sequencing. Keep the accepted broad evidence; rerun affected checks, not every historical review. |

Use fixed seeds or injected draws in tests where necessary for reproducibility. They are test aids, not player-selectable reroll tools. A moderate diagnostic sample may supplement direct probability checks; it cannot establish production balance.

One independent review should focus on the whole bounded diff: transactional formation/dispatch, same-destination repeated returns, immediate/delayed/empty handover, committed random outcomes, physical manifest feasibility and save ownership. Resolve important findings with targeted follow-up. If an independent reviewer cannot run, disclose that rather than presenting self-review as independent.

## 10. Completion record and developer playtest

Write one concise `docs/testing/2026-11-07-expedition-to-storage-loop-result.md` (use the actual completion date if later). Record source checkpoint/diff, exact pool and provisional numeric settings, presentation evidence, schema/compatibility decision, actual executed checks with failures/corrections, reviewer disposition, unresolved limits and save preservation. Distinguish unit/direct-handler, native/rendered and human evidence.

Update only affected active pointers/progress and owning design decisions. Record confirmed lifecycle details and approved test semantics in the appropriate current GDD/MVP sections where still marked open; maintain DOCX-first generation for masters. Clearly label technical completion pending human acceptance. Preserve previous foundation and M1–M4 history, archived files, source provenance and catalogue approval limitations. No spatial changes follow from document updates.

Provide a short human checklist covering: edit/reopen a draft; lock count with one contribution; change destination afterward; reject incomplete affinity dispatch; send zero-loadout and confirm a zero-capacity departure; prepare another team consecutively; observe returned destination freedom versus waiting crew occupancy; clear intake and reuse personnel; save/continue a partial preparation and a journey/waiter; store expedition goods and confirm the original goal behavior. Technical fixtures may cover hard-to-reach cases without requiring every case in one long manual run.

Finish with the exact local revision(s), changed owners, tests/review, protected-save evidence, known omissions and the human-playtest instructions. Stop at **technically ready / developer acceptance pending**. No claims about balanced provisioning, production pacing, final acquisition quality, complete Expedition/Medical implementation or release durability.

## 11. Sources and status of this brief

Basis: approved GDD v0.16 and compatibility-updated masters; the developer's accepted foundation playtest and its supplied result; foundation Appendix A; the subsequent developer decisions on disabled incomplete Dispatch, empty returns and test duration; and the developer's explicit approval of the refined category-first test model, exact 20% relative bonus and representative eight-category pool.

This brief's eight-person test roster, uniform-within-category item choice, fresh-draft default delegation, local checkpoint policy and test-configuration authoring instructions are **handoff implementation choices**, not newly claimed user-set production numbers. Exact pool IDs and capacity/target coefficients require the implementer's asset-equipped feasibility work. No current local source, new random-haul feasibility, gameplay tests, publication or future checkpoint has been verified merely by drafting this prompt.
