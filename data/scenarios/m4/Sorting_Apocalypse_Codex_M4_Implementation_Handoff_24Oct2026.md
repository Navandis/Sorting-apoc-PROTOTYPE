# Sorting Apocalypse — M4 Expedition Loadout implementation handoff
## Approved-design consolidation · 24 October 2026

**Execution:** fresh local Codex session; use the most capable available coding model at **High reasoning effort**. One implementer, one proportionate final contextual review, then developer playtest. State the actual executor/model if available; do not invent a model variant.

**Goal:** deliver a local M4 candidate in which the player provisions four four-person teams at Dispatch from the same persistent supplies needed by Medical and Kitchen, with differentiated item Bulk, the agreed carousel and dispatch rules, and faithful continuation.

**Architecture:** extend the existing irreversible request/receipt, carrying, shared clock, scenario, Receiving and snapshot owners. Do not create parallel inventory, clock, save, receipt or return-admission systems. A team loadout is a separately identified concurrent request with additional pooled Bulk accounting and terminal dispatch state.

**Authority:** the developer has approved the revised 167-item calibration, its Day 2 lunch repair, and proceeding to M4. The mechanics below consolidate the preceding approved M4 discussion. The attached `Sorting_Apocalypse_M4_Locked_Baseline_24Oct2026.json` is the numerical/scenario implementation input; its CSV is an inspection companion. This is not permission to publish, redesign the economy or implement the full Expedition system.

Use the project's proportionate workflow and its existing execution tools; when using installed workflow skills, execute the plan inline rather than spawning separate workers for every step. No tool installation, framework adoption or unrelated refactor.

## 1. Read and preserve the actual baseline

Read `docs/AI_WORKING_GUIDELINES.md`, `docs/CURRENT_STATE.md`, `docs/CODEX_BOOTSTRAP.md`, the current Systems MVP master/Markdown's M4 and preservation sections, and the two pre-M4 catalogue validation records. Then inspect only the owning code and its relevant tests. Later explicit developer decisions summarized here supersede older numerical/timetable/team-formation proposals; do not treat a historical master statement as permission to undo them.

Authoritative asset-equipped project: `D:\Godot Projects\Sorting-apoc-PROTOTYPE`.

- Remote `main` was read during preparation at **`3bb69a906e921f06dd12c61bd4d8f33db35d6fce`**. That published state contains the original 155-item catalogue, not the twelve-item top-up.
- Required local top-up candidate is reported as **`71101cf6bd6302842e7c7090a0849b25ef9b75a5`** on `codex/pre-m4-catalogue-topup-12`.
- Preserve ancestry **`3bb69a9 → e8ed120 → a669c0d → 71101cf`**, including the developer's exact saved `.tres` checkpoint. Verify full SHAs and current local/remote state; do not assume the local branch is accessible remotely.
- Create a new local branch such as `codex/m4-expedition-loadout` **from the verified 167-item candidate**, or from a verified later descendant that contains it unchanged. Do not start from bare published `main` and reconstruct the missing additions. Do not merge/push the top-up as a prerequisite.
- Inspect dirty files, running Godot processes and worktrees before writing. Preserve any developer changes; do not reset, stash, clean, amend accepted history, remove worktrees or interfere with a running developer session.
- Verify the existing Godot executable/version and Compatibility renderer. Use the installed toolchain, isolated APPDATA/LOCALAPPDATA and injected save directories for testing. Do not open, migrate, overwrite or delete the developer's save slot.

**Physical authority:** actual local accepted definitions, not copied geometry from calibration exports. Preserve all 167 names, source mappings, transforms, scales, Front, Footprints, roles, Auto Stack Groups and accepted overhangs. Seven retired IDs stay permanently retired; do not allocate new item IDs. Preserve ignored licensed models and texture/import dependencies; never stage the asset archive.

The developer explicitly approved scales for 163–174 after the last reconciliation. Record that approval using the existing metadata machinery without changing geometry. Their saved Auto Stack Groups remain None; separate explicit human group-approval flags have not been supplied. Leave those flags honestly pending and retain the actual empty-group behavior. This does not block local M4 implementation and does not authorize declaring the physical top-up published/fully closed. No repeat physical review is requested.

## 2. Locked M4 numerical and scenario contract

| Parameter | Implement |
|---|---|
| Active catalogue | Exact **167** item IDs and values in `approved_items` |
| Player carrying capacity | **20 Bulk** |
| Raw team capacity | **28 Bulk × member count** |
| Requirements per member | **Food 12 / Hydration 12 / Medical 6 / Weapons 12 / Protection 12** |
| Main roster | **16 authored Ready scavengers → [4,4,4,4]**, each of the three authored days |
| Active day / clock rate | **06:00–00:00**; 1 in-game hour = **2.5 real minutes** |
| Dispatch preparation | **06:00–10:00**, half-open accepting interval |
| Kitchen | Breakfast **10:00–13:00: F48/H40**; lunch **14:00–17:00: F60/H48**; dinner **18:00–21:00: F60/H48** |
| Medical | Day 1 **07:00–10:00: 24**; Day 2 **09:00–12:00: 36**; Day 3 **17:00–20:00: 48** |
| Initial physical stock | Exact **85 items / 240 Bulk**, `scenario.seed` |
| Deliveries | Exact **12 × 16-item ordered manifests**, four/day at **08:30, 12:45, 17:30, 22:15** |
| Daily delivered Bulk | **244 / 257 / 271**, unchanged by the six reviewed Utility reductions |

These are locked starting values for M4, not final-release balance. Do not optimize, smooth, reduce scarcity, increase demand/capacity, alter rates or add supply to make a test convenient. Further tuning follows human playtests.

All 167 rows are explicit authoring data: do not infer eligibility at runtime from Storage Category. Food/Hydration serve their Kitchen and Dispatch lanes; Medical serves Medical Bay and Dispatch at the same approved amount. Make any retained `medical_bay` overrides agree with the approved amount. Weapons and Protection serve Dispatch. Fuel/Morale/Electronics receive their approved numerical authoring but **no new M4 consumer**. Keep the category name **Fuel**; no Energy migration, charge system, ammunition compatibility, cooking, durability, consumption tracking or cross-lane bonuses.

**The approved repair is an example-allocation correction, not new inventory:** Day 2 lunch Food may use the existing Corn Sack `D2-B:001` plus the already-present Pumpkin Large `SEED:020` (`loot_000066`): raw **58 + 12 = 70**, credited **60**, wasted **10**, full Bulk **18**. Never duplicate the pumpkin, add a delivery, or implement automatic allocation. `verification` tokens are analysis identifiers, not runtime instance IDs.

Read the baseline README's time conventions. `scenario.runtime_events` expresses request windows in local seconds of day. The witness uses 24-hour calendar coordinates and a **30-in-game-minute analysis allowance** after deliveries. That allowance is **not a new runtime delay**, and calendar coordinates must not be confused with the existing clock's compressed active-day elapsed time.

## 3. Formation, requests and irreversible dispatch

At each authored day start, form `floor(Ready/4)` full teams and one remainder team only if `Ready % 4 > 0`; zero Ready produces no teams. Examples: 12→[4,4,4], 13→[4,4,4,1], 16→[4,4,4,4], 17→[4,4,4,4,1], 21→[4,4,4,4,4,1]. **No independent team-count cap, round-robin filling, or individual strength attributes.** These are authored roster fixtures; do not simulate population, injuries or recruitment.

Give each daily team a unique durable identity distinct from its display index. Its request retains member count, all five targets/progress, spent item/definition IDs, raw/applied/wasted Utility, full outgoing Bulk and dispatch time/reason. Reuse the existing request accounting; preserve the global spent-ID guard across all destinations.

Submission applies to **one selected carried item and one centered team only**. Revalidate that selection, recipient, time, lane and remaining Bulk at the commit boundary—not merely at preview. Utility credit is `min(item Utility, lane remaining)`. Consume the complete item, charge all its Bulk, and discard excess Utility. A full lane or over-capacity team rejects the item intact. Equality with remaining capacity is allowed. Bulk capacity being full does not by itself dispatch an incomplete team.

Within the existing receipt-before-notification transaction boundary, completion of all five tracks dispatches the team once. Explicit **Dispatch under-prepared** dispatches the centered undispatched team immediately, including an empty loadout, without a confirmation popup. At **10:00**, the shared scheduler dispatches every remaining team exactly once, including empty teams. Preserve full/manual/cutoff reason distinctions internally. Previously dispatched teams cannot accept, refund, re-dispatch or transfer supplies.

Outgoing Bulk is retained in the immutable dispatch result. **Return Capacity = raw team capacity − full outgoing Bulk**. No protected reserve or beneficial overfill. M4 must not turn that number into actual loot or survival outcomes; incoming manifests remain scenario-controlled and independent of loadout quality or early dispatch.

## 4. Dispatch carousel and input

Use the existing **DispatchWorkSurface** proxy as the interaction point; no furnishing redesign. **F opens/closes** the interface; opening never submits. **E** submits one selected item on a distinct press. **ESC closes the panel first**, with the established press/release and menu-priority safeguards.

A centered readable card is the only actionable team. Show smaller, visually subdued previous/next cards behind it, left/right arrowheads and a team-position indicator. A/D, left/right keys and arrowhead clicks navigate the stable wrapping order; clicking a visible side card selects that team only. Mouse wheel / number keys continue selecting carried items, not teams. One- and two-team cases must not create duplicate actionable recipients. Support five or more cards without a hardcoded four-team limit.

Use ordinary 2D transforms/tweens; no new UI library or 3D carousel. Do not accept or buffer an E submission while the recipient is transitioning. Require a new press when transition settles. A/D already held during opening must be released before navigating; world movement/mouse-look stay blocked while the interface is open. Preserve the M3 stale-velocity fix without stripping legitimate saved velocity from Continue. Request UI does **not pause gameplay**; menu/report/zoning pause ownership remains independent.

Central card shows team identity/member count, deadline, five committed/projected Utility tracks, applied/wasted contribution feedback, outgoing Bulk/capacity and remaining Return Capacity, including selected-item cost. A globally ineligible item marks all five relevant lanes as rejected; a full target lane is lane-specific. Capacity rejection is explicit and must not look like an available green contribution. Distinguish no selected item and already-dispatched state from ineligibility.

Every dispatched card displays **Team Dispatched** and adopts a cohesive **light-blue treatment across the whole card and its elements**, not just the border; retain readable contrast and committed values. Its card remains in its original position and is read-only. Do not automatically advance the recipient. The interface remains open while any team is still undispatched; only when all teams have left does it auto-close and suppress the station's action cue/interaction for that preparation cycle. Disable/hide Dispatch under-prepared for terminal cards. Keep the close button and shortcuts; do not restore the redundant M3 close-hint lines.

Render and verify at **1920×1080 and 1280×720**. Higher carrying capacity can produce more than ten small items: retain reachability/selection/readability without silently imposing a new item-count cap. Do not conflate ten number shortcuts with a ten-item capacity. Adapt the existing strip presentation only as needed.

## 5. Chronology, scenario and initial stock

Use `run_schedule`/`run_clock` authority, not per-panel or node timers. At 10:00, settle due closures/dispatch before opening breakfast. Preserve initiation-time then stable-ID tie-breaking, FIFO/admission ownership, half-open deadlines and midnight hard cutoff. Test exact, fractional and bulk-advance boundary landings.

Integrate the **exact 85-item seed manifest as the new M4 start state**, not as 85 extras on top of the old M3 seed. Give instances unique runtime identities. Establish legal deterministic placement using existing seed/storage paths and production surfaces; no floating/disappearing items, inaccessible overlaps, moving decorative props, rescaling assets or new furniture. The calibration does not provide placement transforms or prove shelf fit. Capture the resulting arrangement and inventory for human review. If it cannot fit without a substantive design change, report the concrete blocker rather than silently dropping items.

Replace M3's normal scenario manifests with the approved M4 manifests only for the M4 scenario. Exercise **every exact 16-item manifest** through the production preparation/presentation path. Do not assume twelve individual-item proofs establish mixed 16-item feasibility. Preserve exact ordering/identities, full-OPEN TAKE, reach limits, deck dimensions and outbound/FIFO behavior. A geometric failure warrants a specific reported obstruction and proposed narrow composition change, **not** an unapproved substitution, reroll, omission, batch split, capacity enlargement or model shrink.

Carry unused supplies across days; do not re-seed each morning. Instantiate each authored day's new teams once; persist yesterday's immutable results separately. The three-day fixture is not a procedural economy. Retain explicit existing scenario-exhaustion behavior after authored days rather than generating unexplained new demands/supply.

## 6. Continuation and midnight reporting

Extend the existing snapshot/codec/validator for team identities, members, progress/receipts, Bulk and terminal dispatch facts. Preserve staged restoration, validation before live replacement, one save slot, Save & Exit, midnight autosave and report-pending pause behavior. Schema/content changes may reject older snapshots explainably; no silent relocation, dropped items, migration framework, crash journal or rollback protection is required here.

Restore before day activation/seed admission so Continue cannot duplicate teams, starting supplies or dispatch events. Saving while some teams have dispatched must preserve those outcomes and the remaining open requests exactly. Ephemeral open-panel state and animation need not be saved; authoritative gameplay time and accounting do.

At midnight retain completed-day Dispatch facts in the report: team/member identity, dispatch reason/time, five required/credited/unmet values, outgoing Bulk and remaining Return Capacity. This is the result of the loadout consumer—not simulated return loot, injuries or quality. Preserve Medical, per-meal Food/Hydration, Daily Meal Coverage, Receiving backlog/forfeits and autosave status. Resolution precedes report presentation; accepting the report does not resolve or dispatch teams again. Next day's clock starts at 06:00 under the existing report hold.

## 7. Source-owner map and execution sequence

The published source was inspected as context, not the unpublished local candidate. Verify local interfaces first. Relevant existing owners include:

- `item_definition.gd`, `data/items/definitions/*.tres`, `data/items/item_catalog.tres`: numeric inputs and context routing.
- `carried_items.gd`, `held_item_view.gd`, `item_preview_3d.gd` and existing carried-strip owner: capacity/selection and display.
- `gameplay/requests/contribution_request.gd` and its existing station/panel callers: persistent receipts and selected-item submission.
- `gameplay/run/run_scenario.gd`, `run_schedule.gd`, `run_clock.gd`: event validation, activation/closure and shared time. Currently one `active_request(destination)` is returned; extend Dispatch selection without breaking Medical/Kitchen single-request behavior or adding fake destinations for each team.
- `gameplay/run/run_snapshot.gd`, existing codec/save service, `run_shell.gd`, `night_report.gd`: persistence, modal ownership and report.
- `gameplay/logistics_wing/wing_gameplay.tscn` and its script/seed owner; existing Receiving runtime/admission/presenter and storage owners.
- Existing `tools/asset_pipeline/tests/` suites and authoring records; do not regenerate the accepted catalogue from old machine proposals.

Suggested focused new-owner names, **not claims about existing files**, are `gameplay/requests/dispatch_loadout.gd` and `dispatch_carousel.gd`. Choose small local extensions/subclasses as appropriate after inspecting callers; avoid turning the shared request class into unrelated architecture work.

- [ ] **Data and fixture:** freeze the supplied baseline files in the local branch; apply the exact approved numbers and capacity; add explicit tests comparing all 167 IDs/values and unchanged physical fields. Make context overrides consistent. Add M4 scenario/seed handling and assert exact counts/windows/manifests. Demonstrate tests fail on the old values, then pass on the changes.
- [ ] **Loadout owner:** cover member scaling, five independent caps, selected-team isolation, full-item Bulk, rejection preservation, global spent IDs and exactly-once full/manual/cutoff dispatch. Implement through the existing transaction boundary, then run affected contribution/ownership checks.
- [ ] **Carousel:** add station binding, input and whole-card terminal state. Exercise real controller/input/physics paths for held and released movement, held/echoed E/F/A/D, navigation, deadline closure and native-review captures—not direct UI state mutation alone.
- [ ] **Persistence, reporting and content:** integrate chronological activation/closure, staged restore, midnight facts and exact seed/Receiving content. Run isolated separate-process continuations and both rendered resolutions. Validate the starting placement and twelve full delivery manifests.
- [ ] **One final affected regression pass:** reuse same-state evidence with attribution; rerun changed owners, not all project history. Inspect completion/error signatures and exits. Record a clear final candidate and developer playtest checklist; stop locally.

Keep cohesive reviewable commits. Do not amend the accepted top-up/checkpoint history. Do not spend a separate approval cycle on every evidence/documentation step.

## 8. Required evidence and acceptance limits

| Risk | Minimum useful proof |
|---|---|
| Numbers or physical metadata drift | All 167 numerical rows match baseline; zero unauthorized changes to physical fields, sources, retirements or other worktrees. Capture the source/target revisions. |
| Team formation | Ready 0, 1–4, 12–17 and 21 follow full-team-first rule; capacities/requirements scale; no hidden team cap; four-by-four production fixture. |
| Destructive submission | Selected item/centered team revalidated; full/invalid/over-Bulk rejection preserves item and progress; partial credit charges full Bulk; no double spend across teams/Medical/Kitchen; receipts and dispatch facts committed before observers. |
| Dispatch lifecycle | Full, deliberate partial/empty and deadline paths exactly once; full Bulk but incomplete team remains open; no automatic carousel advance; all-done closure and daily reactivation correct. |
| Input/modal regression | Opening F does not submit; distinct E; no queued transition submission; A/D opening guard; released-W no drift; ESC panel-first; zoning/menu/report owners preserved; >10 small items still reachable. |
| Clock/report | 10:00 dispatch closures before breakfast; exact/fractional/bulk advancement; pause/resume; completed-day facts immutable; midnight autosave/report restore does not resolve twice. |
| Physical content | Seed totals 85/240 with legal placement; all twelve exact 16-item batches prepare and progressively drain through unchanged Receiving, carrying and shelf paths. Report any leftover/blocked/omitted identity as failure, not PASS. |
| Continuation | Separate write/read processes during partial loadout, mixed dispatched/open teams, post-cutoff and report-pending states; exact progress, spent IDs, Bulk and current time retained. Existing ladder/storage/Receiving continuation remains supported. |
| Test trust | Expected completion marker, zero assertions/unexplained script errors and correct exit; incomplete helpers fail. No suppressed diagnostics or fixture-only claims about native input/comfort. |

Preserve known CF-07 material-null, certificate-store and pickaxe LOD caveats as disclosed debt. Do not label a new error as old debt merely because it is inconvenient. No broad engine/asset repair is authorized.

A numeric replay of the approved witness may use controlled selection/time advancement in an explicitly isolated test. It must not turn into runtime automatic provisioning. It establishes exact accounting, not native-input feel or workload comfort.

## 9. Delivery and stopping point

Create/update one concise `docs/testing/m4-expedition-loadout-validation-2026-10-24.md` with baseline/commits, exact commands/exits, coverage, limitations, source preservation and a practical developer checklist. Keep bulky evidence external. Record local candidate status in operational pointers only as needed; do not claim human promotion or publication or edit historical masters to imply it. Master-document progress/publication close-out remains a separate authorized step.

Provide the full base-to-candidate review patch (excluding licensed assets), commit hashes, selected logs, representative carousel/report/seed captures, any concrete blocker, and scope-separated known debt. Request one fresh contextual review of the combined M4 diff and relevant callers, followed by native input/audio, continuation and normal-speed developer workload testing. Do not require another abstract calibration cycle before those tests.

**Stop at M4 TECHNICALLY VERIFIED / INDEPENDENT CONTEXTUAL REVIEW AND HUMAN PLAYTEST PENDING.** If any required check fails, report a bounded incomplete candidate rather than claiming that status.

**No merge, push, PR, publication, M5, full Expedition outcomes, population/injury simulation, Workshop/Bunker Ops consumer, Energy rename, continuous Ironman durability, additional asset provisioning or unsolicited balance changes.**
