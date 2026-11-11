# Fuel Reserve and Emergency Freight — Implementation Plan

> **For agentic workers:** Use `superpowers:executing-plans` for one-implementer execution or the equivalent available workflow. Apply the project's proportionate working guidelines before generic per-task review ceremony. Checkboxes track work; they are not independent acceptance gates.

**Date:** 11 November 2026 · v0.1 execution draft

**Goal:** Add proactive physical Fuel refuelling, stable reserve-based power tiers, environmental dimming and 60-second emergency delivery starts without changing the accepted freight spectacle or ownership.

**Architecture:** One reserve owner consumes from the existing active clock and supplies narrow power facts. The existing lift owns its per-delivery start wait; the manager retains cargo capacity/FIFO and admission retains crew handover. Runtime visual adapters apply derived lighting and CRT state. Existing exact-item consumption and snapshot service preserve commitments.

**Tech stack:** Existing asset-equipped Godot/GDScript project, configured native Compatibility renderer, established tests and DOCX-to-Markdown tools. Verify the installed engine and paths locally. No new dependency, generic service director or second timer/save framework.

**Spec:** [Fuel decisions and complete behavior](../../design_history/2026-11-11-fuel-reserve-and-emergency-freight-decisions.md). Read fully, especially supersession, admission versus motion, and labeled defaults D1–D5.

## 1. Scope, execution and permissions

Use a **fresh local Codex session**, the coding model successful on Kitchen, High reasoning where selectable. Record actual model/effort or unavailable. Use one implementer and one consolidated read-only final review if available, not a reviewer chain after each step. Work in the asset-equipped `D:\Godot Projects\Sorting-apoc-PROTOTYPE`, on a safe dedicated branch such as `codex/fuel-reserve-emergency-freight`.

Order: reconcile documentation and inventory relevant legacy dependencies first; implement reserve, emergency freight and presentation/continuation next; finish verified safe retirement and focused evidence. These are one bounded milestone with cohesive local commits. Documentation does not need its own separate human gate.

Read `docs/AI_WORKING_GUIDELINES.md`, `docs/CURRENT_STATE.md`, `docs/CODEX_BOOTSTRAP.md`, the spec and relevant source. Main was inspected at `b0dee116dbfd6802ccd41e046df50d294de05a41`; verify the live local/remote ancestry and later relevant changes. Do not reset to the anchor or repeat Kitchen acceptance/publication.

Scoped local source/document/test commits are authorized when this prompt is supplied as the work order. **No merge, push, PR, branch deletion, broad clean/reset, automatic human acceptance or next-milestone implementation.** Preserve unrelated work, ignored assets, real saves, existing logs and untracked Godot image sidecars. Hash actual pointers/referenced and preserved snapshots before/after; run all tests/imports/native launches with isolated application data/save paths.

## 2. Global constraints

- Reserve starts 55/60, consumes continuously at 1/30 Utility per active second, floors at zero, and creates no debt/offline usage. Fractional reserve is authoritative.
- Fixed bands 45/30/15 use equality in the higher band. Lighting multipliers are 1.000 / 0.835 / 0.670 / 0.500. These and delay/rate/capacity are provisional config, not production tuning.
- Emergency mode below15 adds 60 active seconds only when a valid next delivery could otherwise start. No countdown during unloading/outbound/no-cargo idle, and no wait credits.
- Once a cycle starts it completes normally. Keep arrival/shutter/closing/departure cues, authored timings, ordinary TAKE and full-turnaround retirement unchanged. Old per-stage greyout freezes are superseded.
- One pending/active plus two queued deposited loads; original FIFO and crew release on admission; destination release on return; no empty-return lift journey. Power must not rewrite expedition outcomes.
- Refuel one selected carried positive-Fuel item using exact atomic cap-and-waste credit; fractional headroom is valid. No withdrawal, output, refund, remote supply or extra score subtraction.
- Fuel panel is live and temporary at the existing electrical panel right of the shutter; do not repurpose emergency stop or remodel Receiving. Use ordinary reach/occlusion.
- CRT normal green/emergency orange plus mode text; preserve all baseline facts, external W1 semantics, goal visibility and input legibility.
- Environmental lighting derives from original authored values, explicitly scoped. Incinerator immunity, Kitchen behavior, base movement, item data, shelves, ladders and collision remain unchanged.
- Document power permissions for future Salvager/Workshop; do not implement those systems or their upgrades. No Energy-category rename, new items, central-monitor feature, episode scheduler or adaptive catch-up.
- Keep current expedition/goal fixture settings and autosave cadence. Prefer next unused save schema (9 if unused), fresh New Run, no invented schema-8 reserve history; same save service and preserved incompatible files.

## 3. Review focus

1. **Fresh-cycle versus mid-cycle:** holding a future start must never pause existing theatre or retire/hand over cargo early. Cover all mechanical stages and emergency-wait cancellation in Task 2.
2. **Admission versus emergency delay:** the active pending load owns its normal slot and its crew has already handed over; new arrivals must neither reset the timer nor gain priority. Cover finite queue and zero-item returns in Tasks 2–3.
3. **Time and threshold precision:** continuous depletion, exact-boundary eligibility, large advances and post-victory pause/Continue must not drift, loop or bank free waits. Cover analytic/partitioned advances in Tasks 1–3.
4. **Terminal identity and conservation:** Fuel credit, lost excess, reserve depletion and item consumption must stay disjoint from live/Kitchen/loadout/disposal owners, including active and retired cargo. Cover rejection/forgery in Tasks 1 and 3.
5. **Presentation restoration and access:** restore correct tier/orange text before play, never darken protected UI or compound authored light multipliers, and use the real reachable panel rather than remote test-only calls. Cover native and restore checks in Task 3.

## 4. Inspected owners and narrow file map

Existing paths are source facts at the inspected baseline; new paths/interfaces below are proposed implementation organization. Follow equivalent smaller local conventions if needed and record deviations. Do not restructure unrelated large files.

| Existing owner | Necessary work / preservation |
| --- | --- |
| `gameplay/run/collection_timeline.gd` | Currently splits at lift, expedition-return and Kitchen boundaries. Include Fuel tier/depletion and pending-start endpoints, settle consumption before checking new starts, and extend zero-progress detection without masking stuck boundaries. Preserve existing admission/return order. |
| `gameplay/logistics_wing/receiving/receiving_lift_cycle.gd` | `_on_active_batch_changed` currently starts ARRIVAL immediately. Add pending-start gating. `seconds_to_boundary`, advance/capture/restore and readout must describe the wait without freezing an active cycle. `_departing` distinguishes closed outbound from truly idle. |
| `receiving/receiving_manager.gd`, `receiving/awaiting_lift_admission.gd` | Retain capacity, exact cargo and release semantics. Prefer leaving these owners unchanged; inspect synchronous activation/retirement notifications. No new offscreen slot or upstream wait for admitted crews. |
| `gameplay/logistics_wing/receiving/receiving_runtime.gd` | Restore may present active cargo before lift state is restored. Suppress automatic cycle starts/audio during reconstruction and bind power before publishing gameplay. Preserve standalone authoring/debug behavior. |
| `gameplay/logistics_wing/receiving/receiving_lift_phosphor_display.gd` and its owning scene | Extend actual live CRT text/theme with a mode row and waiting indication. Existing status arrays assume six states: no out-of-range label. Keep 704×400 screen/material binding, queue meanings and readability. Locate its scene locally. |
| `gameplay/logistics_wing/wing_environment.tscn` and existing Receiving lighting/reflection content | Inspect authored lights and electrical panel. Add explicit runtime bindings/metadata only as necessary. Never rewrite normal light values or scene geometry; identify exact participating paths in result. |
| `gameplay/logistics_wing/wing_gameplay.gd`, `player_controller.gd`, `gameplay/run/run_shell.gd` | Own setup, reachable station binding, one live service panel and nested pause/ESC. Follow current Kitchen/Incinerator patterns. Effects apply before resumed input. |
| `carried_items.gd` | Reuse `commit_selected_consumption(expected, commit_receipt, validate)`. Fuel does not change carry rules or Kitchen's over-limit/rollback policy. |
| `gameplay/kitchen/kitchen_operations.gd`, `kitchen_snapshot.gd`; `gameplay/disposal/incinerator_operations.gd`; expedition owners | Reuse proven receipt/guard conventions and include Fuel in terminal-identity guards where necessary; do not change service mechanics or revive deleted `contribution_panel.gd`. |
| `gameplay/run/run_snapshot.gd`, `gameplay/expeditions/expedition_snapshot.gd` | Compose Fuel terminal validation and new mechanical-wait invariants. Current validator equates SEALED_EMPTY+busy with departing: explicitly distinguish a held start rather than accepting arbitrary inconsistent states. |
| `gameplay/run/run_save_service.gd` | Reuse atomic slot handling and incompatible-snapshot retention. No speculative persistence rewrite. |

Suggested new files: `gameplay/fuel/fuel_test_config.gd`, `fuel_operations.gd`, `fuel_panel.gd`, `fuel_lighting.gd`, and `fuel_snapshot.gd` if validation merits a separate owner. Avoid a separate manager for every boolean. Normal UID sidecars belong with their actual scripts.

**Proposed interfaces:** reserve initialization/restore are separate; `settle_to(now: float) -> void`, `next_boundary_at() -> float`, `preview(item: ItemInstance) -> Dictionary`, `contribute(carry: CarriedItems, expected: ItemInstance, has_access: Callable) -> Dictionary`, `lift_emergency() -> bool`, `lighting_multiplier() -> float`, `salvager_available() -> bool`, `workshop_available() -> bool`, `capture_state() -> Dictionary`, `restore_state(state: Dictionary) -> void`, and change notification. Equivalent existing patterns are acceptable. No constructor used by Continue may grant starting Fuel or spend logical time.

The existing lift should expose emergency mode, whether a start is waiting, its remaining active delay and ordinary mechanical state. A compact explicit `waiting`/deadline/batch record alongside the six-stage enum can be less disruptive than renumbering existing stages. Either representation must be validated and distinguish no-cargo idle, pending-start, normal outbound and active cycles. Pending start belongs to the lift, not to a parallel Fuel cargo queue.

## 5. Documentation and legacy preflight (first checkpoint)

- [ ] Verify local branch/assets/engine/ancestry and read relevant current accepted evidence. Inspect existing save replacement behavior before choosing the schema. Capture original save and unrelated sidecar hashes without operating on them.
- [ ] Add the supplied decision record and this plan as provided, resolving pre-existing copies safely. Reconcile the GDD owning sections (especially facilities, Receiving, Ops/Fuel, machinery/upgrades and current status). Replace active episode/hold descriptions with the approved reserve and start-wait model. Leave future naming/upgrades and final numbers qualified.
- [ ] Reconcile MVP intended-versus-implemented progress and VDD power/CRT/temporary-station compatibility. Preserve historical acceptance, dimensions, metrics and authored visual rationale. Update current state/index/two bootstraps only where affected. The old November 9 decision record gets a clear Fuel supersession pointer; its Kitchen content stays intact.
- [ ] Edit DOCX masters before regenerating Markdown; check changed paragraphs/tables, retained anchors and references, render and inspect affected pages. Do not rebuild current masters from old attachments or silently edit only reading copies. Keep edition numbers unless local project policy requires otherwise.
- [ ] Inventory active code/resources/tests for old Ops daily lane coverage, outage rolls, morale/electronics taxes, episode timers, disabled incinerator hooks, obsolete panels/signals/save fields and UID references. Trace actual consumers rather than delete keyword matches. Read the foundation retirement record; do not redo that broad audit.
- [ ] Record a concise initial disposition: already retired, live/reused, safe removal, or concrete dependency. Keep geometry/frontages and historical evidence. Make one documentation checkpoint; do not call the Fuel slice implemented or create another approval gate.

## 6. Task 1 — Reserve accounting and atomic top-ups

**Create:** Fuel config/operations and `tools/asset_pipeline/tests/fuel_operations_tests.gd` with normal UID. **Touch only necessary shared guards.**

**Interfaces:** consumes shared active time, ItemInstance Fuel Utility and `CarriedItems.commit_selected_consumption`; produces reserve/tier queries, preview/contribution results and ordered terminal receipts for Tasks 2–3.

- [ ] Write focused failing checks for initial reserve, fractional depletion, fixed bands, zero clamp, top-up cap/waste, exact selection and rejection. Run the new operations script headlessly with isolated user data and retain the expected failure.
- [ ] Implement one config signature with the exact provisional numbers. Separate init from restore. Compute reserve from time/accounting anchors or an equivalently stable approach; do not serialize rounded UI values or subtract per displayed frame. At zero later elapsed time must not consume a future top-up retroactively.
- [ ] Implement positive-Fuel eligibility and commit one selected item plus fractional applied/wasted credit, timestamp, identity/definition and conservation evidence before emitting observers. Revalidate recipient access, identity, headroom and other terminal owners. A full tank rejects without spending; live headroom is reevaluated at commit. No separate inventory removal path.
- [ ] Implement band and multiplier queries independent of tank size. Sample a larger test capacity in unit fixtures only; do not add Workshop purchases or production upgrades. Integrate accounting with the shared timeline only as needed for the next task, not a free-running timer node.
- [ ] Run red-to-green checks, inspect actual errors and save a cohesive local commit. Commit only completed owned paths, not broad staging of unrelated work.

**Required exact witnesses:**

| Input / sequence | Expected |
| --- | --- |
| New run | reserve55, capacity60, normal lift, multiplier1. |
| Advance15 seconds, no input | reserve54.5. |
| At300 /750 /1200 /1650 active seconds | reserve45/30/15/0; equality is higher band, a subsequent positive advance crosses each nonzero threshold. |
| Direct reserve29.999 /30 /44.999 /45 | correct distinct band and multiplier, no display-rounded eligibility. |
| Run empty for a long interval; add6 | reserve6 at contribution, not consumed by prior empty time. |
| 59.5 reserve, Fuel+6 | applied0.5, wasted5.5, reserve60, one consumed identity. |
| Full60 / ineligible / stale / inaccessible / spent identity | rejected, no removal/receipt/credit; opening also never spends. |
| Normal run with equivalent large versus partitioned time advances and same contribution timestamps | equivalent reserve, bands and receipts within justified numerical precision. |
| Test capacity60→90 at reserve40, no upgrade system | reserve40 and permissions unchanged; extra headroom only. |
| Exact item transaction observers | see coherent removal, Fuel credit and terminal receipt; reentrant duplicate rejected. |

## 7. Task 2 — Shared chronology and the emergency start gate

**Modify:** timeline, lift, narrow runtime setup; manager/admission only if a demonstrated dependency requires it. **Create:** `tools/asset_pipeline/tests/fuel_receiving_tests.gd`.

**Interfaces:** consumes Task1 reserve/power and normal active cargo selection; produces one bound-to-cargo pending-start state, next boundary and mode/readout notification. Ownership and personnel stay in existing owners.

- [ ] Write failing checks proving no wait banking during empty idle/unloading/outbound, exactly60 extra seconds from eligibility, and no changes to an already-started cycle. Include emergency changes in every mechanical stage, finite queue/admission and a legitimate empty return.
- [ ] Gate the existing transition into ARRIVAL rather than pause the whole lift. On promotion/new accepted active cargo, either begin normally or store its stable pending deadline. Multiple content notifications must not recreate that deadline. Pending cargo may stage hidden; TAKE/audio/shutter remain disabled until normal start.
- [ ] Include reserve threshold/depletion and emergency-wait boundaries in the shared timeline. Settle large deltas chronologically at real endpoints rather than starting waits at the end of a frame. Preserve ordinary FIFO-before-new-return behavior. Extend the progress guard to recognize reserve/wait work without silently allowing an infinite zero-step loop.
- [ ] Apply mode changes immediately to start eligibility, but not to ongoing theatre. A below-threshold top-up does not reset the wait; normal power ends it and starts the eligible delivery once. A subsequent low-power cycle needs a fresh wait, never a saved allowance.
- [ ] Keep active-slot reservation and queue admission independent of motion. Verify one pending/active plus two deposits, correct Ready release and an upstream waiter at full capacity. Complete outbound retirement/promotion before selecting the next start; no early crew release from last TAKE.
- [ ] Run targeted lift/admission tests plus new checks to green. Do not edit cue durations/sound streams to make the delay look successful. Create a coherent local checkpoint, or combine with Task3 if a runnable save-compatible build requires it.

**Boundary scenarios:** no cargo for120 seconds then eligible load → first arrival begins at180, not120; selected load at t0 in emergency → no ARRIVAL at59, one at60; OPEN held beyond60 → still full new wait after completed outbound; refill at wait20 to remain below15 → original expiry60; refill above/equal15 → immediate normal start; extra arriving loads → no timer reset; reserve hits0 mid-wait → expiry unchanged; simultaneous Kitchen grace/return/Fuel crossing → each settles once. Test same choreography over one large advance and small increments. At exact equality, pin consistent higher-band behavior; do not fix precision by altering published thresholds.

## 8. Task 3 — Live station, lighting, CRT and exact continuation

**Create:** panel/lighting/snapshot owners as needed; `fuel_interaction_tests.gd` and `fuel_continuation_tests.gd`. **Modify:** wing/player/shell, existing CRT script and owning scene, run/expedition snapshot integration. Minimal explicit lighting/station bindings may be authored; no geometry redesign.

**Interfaces:** consumes reserve and lift readout facts; produces ordinary live F/E/ESC interaction, reversible visual tiers, schema state and validated Fuel terminal dispositions. Scene reconstruction must publish none of these prematurely.

- [ ] Write failing interaction/continuation cases before adding the live binding. Use the real electrical panel target and normal carried items. Test reach/occlusion, held/repeated input, switching panels, live time, and direct versus already-stored item paths.
- [ ] Identify and record the exact panel path and environmental-light membership locally. Add the temporary Fuel interaction without modifying collision/appearance, exposing remote access or activating the emergency stop. Keep the far Ops frontage inactive and preserve its authored scene.
- [ ] Build the minimal live panel per D1–D3. Show honest reserve, capacity, tier/permissions and fractional credit/waste. Refresh selection and consumption values without per-frame world mutations. Use existing key release guards; no input leaking into shelf store/TAKE when closing. Existing pause owners must not be cleared by closing Fuel.
- [ ] Apply explicit light multipliers from cached authored originals after normal initialization, including hidden candidate loading. Exclude indicator/UI worlds. Repeated transitions, New Run and Continue cannot compound values or contaminate another scene instance. Use current reflection invalidation only when useful at tier changes. No normal lighting re-authoring.
- [ ] Extend the CRT with normal-green/emergency-orange mode text and honest start-wait status. Distinguish mode from active mechanical state. Preserve STATUS/DECK/QUEUE values, Surface1 texture binding, viewport, fonts and unobstructed scene position. Check actual native readability at supported resolutions; do not trust flat UI-only screenshots.
- [ ] Integrate Fuel capture/validation/restore through the existing service. Prefer schema9 if unused; preserve schema8 files rather than automatically converting absent reserve history. Suppress auto-arrival signals/audio while restoring a held start and apply Fuel/lighting before play resumes. Keep the normal 60-active-second/first-victory save policy.
- [ ] Validate conservation by replaying accepted top-up arithmetic/timestamps against constant consumption or an equally strong bounded accounting check. Receipts must prove raw/applied/wasted Utility and source identity. No live item can also be Fuel-spent, incinerated, Kitchen credit or loadout credit. Verify original seed definitions and generated manifest/prior handover. Positive reserve cannot appear from a forged receipt; missing cargo cannot be excused by an arbitrary terminal flag.
- [ ] Explicitly replace the old `SEALED_EMPTY + busy => departing` snapshot assumption with the narrowly defined held-start case. Reject drained held-start cargo, timer without a pending batch, mismatched ID, early TAKE, impossible queue order and incoherent power/wait state. Do not simply remove lift validation to accept the new case.
- [ ] Run focused checks to green. Commit live integration and continuation together if needed so the local runnable checkpoint has coherent saves.

**Continuation witnesses:** new55/60; fractional reserve; each band; empty for extended active time; waiting with a partial deadline and two queued loads/upstream waiter; an active cycle after power loss; after refill cancels wait; spent Fuel from a still-OPEN source and after retirement; Kitchen over-limit carrying and Incinerator warning/receipts; post-victory first time unchanged. Restore no offline depletion, reroll, replenishment, cue replay or duplicate personnel release. Reject duplicate/mismatched receipts, invalid reserve/rate/config, incoherent deadlines and loadout/Kitchen/disposal collisions. Failed save retains last valid pointer; failed Continue/new-run cancel retains incompatible files.

## 9. Finish legacy retirement, verify and hand off

- [ ] Complete the preflight legacy disposition with concrete paths and active references. Safely remove Ops-only obsolete code, stale signals/UIDs, obsolete tests and unreachable compatibility branches where no present consumer remains. Refactor useful assertions into current owners. A no-removal finding is valid with evidence; do not manufacture a deletion quota.
- [ ] Specifically ensure no active Fuel debt generator, blackout roll, timer stacking, old light/monitor tax, old Incinerator-disable hook or stage-freeze code remains as an unreferenced survival bridge. Preserve shared transactions, supported snapshot rejection diagnostics and actual geometry. Historical manuscripts/records remain history; move only genuinely active-facing superseded routing and retain provenance links.
- [ ] Run one selected final regression sweep: Fuel suites; Kitchen operations/interaction/continuation; Incinerator operations/interaction/continuation as affected; expedition operations/continuation and zero-return proof; collection goal; Receiving lift/admission; storage rollback; furniture collision; nested pauses and F5/F6 startup parity. Select the actual relevant existing scripts and record why. Do not rerun unrelated asset authoring reviews or demand an arbitrary assertion count.
- [ ] Run native Compatibility with isolated saves at 1280×720 and a larger supported window, reporting actual viewport. Test F/E and selection at the real panel, staged tier changes and light restoration, CRT readability in normal/wait/active-emergency states, and unchanged delivery choreography. Use controlled near-threshold fixtures rather than waiting20 minutes per test. Record fixture positioning; the human checklist covers ordinary travel/use.
- [ ] Demonstrate zero-Fuel recovery with actual generated Fuel taken through ordinary reticle/TAKE, physically carried and submitted while Kitchen is at its maximum10-Bulk limit. Keep the original <=8-Bulk acquisition pool. Verify emergency cycles at0, FIFO and Ready release, and Incinerator usefulness/immunity. Do not inject rescue items as the claimed recovery proof.
- [ ] Obtain one consolidated contextual read-only review of changed behavior, save/receipt invariants and intended retirement. Address actionable findings; rerun affected checks only. Report unavailable review/tools honestly. No new broad audit or chained per-function reviews.
- [ ] Update final technical status in the existing masters/companions and current-facing entries, with local result/evidence links. Inspect changed rendered pages and text/table parity. Keep historical then-pending claims as history; do not erase earlier qualifications. Verify final scoped diff, unresolved dependencies, original save hashes and unrelated sidecars.
- [ ] Deliver exact local commits, changed/retired/reused paths, measured tests and raw logs/captures, save compatibility, limitations and the short playtest below in `docs/testing/2026-11-11-fuel-reserve-emergency-freight-result.md` (or actual execution date, recorded consistently). Stop at technically ready for developer playtest, clean tracked tree or accurately described deviations. No publishing or automatic promotion.

## 10. Commands and evidence discipline

Use the current project's configured Godot binary and existing isolated-profile conventions. The previous path was `D:\AI Tools\Godot-4.7-Codex\Godot_v4.7-stable_win64_console.exe`; verify rather than download/update an engine. A representative invocation in an isolated PowerShell process is:

```powershell
$profile = Join-Path $env:TEMP ('Sorting-Fuel-' + [Guid]::NewGuid().ToString('N'))
$env:APPDATA = Join-Path $profile 'Roaming'
$env:LOCALAPPDATA = Join-Path $profile 'Local'
New-Item -ItemType Directory -Path $env:APPDATA,$env:LOCALAPPDATA -Force | Out-Null
& $godot --headless --path $repo --script res://tools/asset_pipeline/tests/fuel_operations_tests.gd
```

Resolve `$godot` and `$repo` to verified local paths. Use the same isolated profile discipline for other tests/import/native launches; preserve existing test-specific arguments such as the startup parity external save path. A failed invocation is a recorded failure, not a passing suite. Capture exit status plus actual assertions/diagnostics. Do not suppress certificate-store/material warnings or confuse deliberate malformed-cargo/write-blocker cases with ordinary runtime failures.

Keep one concise result record and relevant raw evidence under its ordinary testing evidence folder. No new report generator, classifier, archive framework or forced performance work. Existing synchronous-save cost, silent-suspension gap, real crash durability and full-catalogue limits stay attributed and open. Measure changed save cost if the existing tests already do so; do not grow this task into a persistence rewrite.

## 11. Developer playtest for the completed slice

1. New Run shows55/60 and green normal freight. With the nearby refuelling panel, F alone spends nothing; selected Fuel preview and a fresh E top-up have the stated credit/waste. Wrong category/full tank rejects. The panel remains live and pauses close in the existing order.
2. In an explicitly isolated low-reserve fixture, observe three lighting levels and the CRT's orange mode/wait labels. The original startup numbers remain unchanged in ordinary play. Refuelling reverses the levels; UI stays legible and external warning cues retain their meanings.
3. Leave a delivery OPEN for more than60 seconds, then clear it. Closing and full outbound complete normally; only then does the next ready load wait its full60 seconds. Add another arrival during the wait: its deadline/order must not change.
4. Refill partway through a wait, first to remain below15 and then to restore normal lift power. The first top-up keeps the deadline; the second starts the ready delivery without repeating a cue. Falling low mid-cycle does not interrupt its spectacle.
5. Save/Continue while waiting, mid-cycle and after topping up. Reserve fractions, mode, exact cargo, deadline, personnel and first-victory time persist. Check ordinary Kitchen, shelf/ladder, collision and Incinerator use.
6. At zero reserve, unload an emergency delivery, take generated Fuel within the ordinary carry limit, refuel and resume normal freight. No free Fuel, teleporting or permanently immobilized lift. Workshop/Salvager power permissions are visible/tested facts only, not completed services.
