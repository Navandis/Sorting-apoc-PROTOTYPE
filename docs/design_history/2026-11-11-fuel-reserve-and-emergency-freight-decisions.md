# Sorting Apocalypse — Fuel Reserve and Emergency Freight Decisions

**11 November 2026 · Conversation-derived specification for the first Fuel/Energy slice**

## 1. Authority, purpose and status

The developer approved a persistent, proactively refuelled reserve and slow emergency freight, including the rule that each emergency delivery waits 60 active seconds from when it could otherwise begin. They authorized drafting the implementation handoff, documentation reconciliation and targeted predecessor Ops cleanup. This record carries those decisions into the local work order. It does not claim implementation, human acceptance or publication of this slice.

The source is the developer's conversation following Kitchen publication: rejection of UI-driven mechanics; consideration of cumulative shortfalls, fixed cycles and consumption; approval of slow emergency freight; fixed operating thresholds under tank upgrades; CRT feedback; provisional reserve/consumption/lighting/delay values; and the final approval of the ready-to-start delay. Earlier episode-based proposals are superseded as stated below, not silently treated as additional requirements. This is a decision summary, not a verbatim transcript or an invented historical timestamp record.

Repository source was inspected read-only at `b0dee116dbfd6802ccd41e046df50d294de05a41` on 11 November. Kitchen is published and closed. The earlier attached Kitchen result's LOCAL / PUBLICATION PENDING heading is dated evidence, not the current publication state. Verify the actual checkout before execution; this SHA is an evidence anchor, never a reset target.

Read this record with the [implementation plan](../superpowers/plans/2026-11-11-fuel-reserve-emergency-freight.md), current GDD, MVP/VDD and `docs/AI_WORKING_GUIDELINES.md`. Reconcile current intended behavior into the DOCX owners and regenerate their Markdown. Preserve this record as provenance, with current-facing documentation identifying the owning GDD sections.

## 2. Intent and the model selected

Fuel trades physical stockpile progress for operational efficiency and time away from servicing the bunker. A player can proactively commit Fuel before any restriction exists, accept a lower operating level, or fill extra reserve before organizing elsewhere. A stable, finite reserve also supplies a useful storage-pressure outlet. Fuel-free completion remains possible, but sustained neglect is intended to be materially less efficient in ordinary play. That is a later balance target, not a universal claim about every final-push decision or a reason to tune this mechanical slice until every strategy is equal.

**Selected:** one persistent reserve, consumed during active time, with facility/lighting tiers and an additional wait between eligible freight deliveries under low power. No difficulty director, performance compensation or second emergency consumable reserve.

**Considered, not selected:** Kitchen-like cumulative Fuel obligations with intermittent greyouts; fixed funding cycles and deadlines; overlapping/queued/compounding outage episodes; manual emergency operation. These alternatives create different accounting or unrelated work. Do not implement them beneath the reserve UI.

**Explicitly superseded for current Fuel design:** randomized request issuance, request grace/expiry, outstanding Fuel debt, outage chance rolls, finite full-bunker restoration windows, overlapping outage timers, contribution-percentage restoration milestones, and holding the lift at SEALED_READY/OPEN/CLOSING boundaries. The new delay is only before a fresh delivery begins. Prior design discussion and acceptance history remain available, marked historical where relevant.

Kitchen remains a separate approved cumulative request system. Its timing, grace, cap, partial relief, sprint consequences and independent randomness do not change. Other contribution decisions—future expedition bonuses, Medical-only healing, Electronics one-time purchases—remain intact and unimplemented where previously unimplemented.

## 3. Approved operating rules and provisional values

### 3.1 The first-test configuration

| Parameter | Value | Status |
| --- | --- | --- |
| Initial tank capacity | 60 Fuel Utility | Developer's provisional value |
| Starting reserve | 55 Fuel Utility | Developer's provisional value; not a physical stored item |
| Consumption | 1 Fuel Utility per 30 active seconds | Developer's provisional rate |
| Fixed operating thresholds | 45, 30, 15 Fuel Utility | Derived from the agreed 75/50/25% bands of the initial 60-unit reference |
| Emergency delivery wait | 60 active seconds per eligible delivery | Developer's provisional value; start condition is confirmed |
| Maximum environmental light reduction | 50% of authored light strength | Developer's provisional value |
| Dimming portions | 0%, 33%, 66%, 100% of that reduction | Working bands carried through the approved numerical discussion |

Use continuous consumption: `reserve(t + dt) = max(0, reserve(t) - dt / 30)` between contributions. Keep fractional reserve internally. No whole-Utility tick that silently delays threshold entry by 30 seconds. Only the established active clock advances consumption. ESC, zoning, launch/offline and other real pause owners retain their behavior; live station panels do not stop it. Continue after victory continues consumption without changing the first-completion timestamp.

The reserve never goes negative; time spent empty generates no debt. Charging additional Fuel per freight cycle, changing the rate with current staffing or machine use, and simulating individual electrical loads are not approved. Consumption remains constant while positive, even if a facility is currently idle or unavailable.

### 3.2 Availability and illumination bands

| Authoritative reserve | Salvager power permission | Workshop power permission | Lift | Environmental light multiplier |
| --- | --- | --- | --- | --- |
| `R >= 45` | Available | Available | Normal cycle admission-to-start timing | 1.000 |
| `30 <= R < 45` | Unavailable | Available | Normal | 0.835 |
| `15 <= R < 30` | Unavailable | Unavailable | Normal | 0.670 |
| `0 <= R < 15` | Unavailable | Unavailable | Emergency start wait | 0.500 |

Threshold equality belongs to the higher band. Display rounding cannot alter band eligibility. At continuous downward crossings the lower band applies as reserve goes below the threshold; implement boundary settlement without stale power flags, repeated zero-length steps or frame-rate-dependent extra delays.

From 55 without refuelling, the threshold values are reached at 300, 750 and 1,200 active seconds; restrictions start just below them. Empty occurs at 1,650 seconds. This is 5:00 / 12:30 / 20:00 / 27:30, not 27.5 minutes of full power.

Thresholds stay at the same Fuel quantities if future tank upgrades raise capacity. Capacity upgrades add headroom; they do not grant Fuel, stretch thresholds, change the current band or charge additional Fuel just to keep the same facilities running. Consumption upgrades are separate future candidates. Neither upgrade system nor purchase values is implemented here.

### 3.3 Physical refuelling

Fuel must be collected and physically carried normally. No remote shelf withdrawal, cargo access, increased carrying allowance, or exemption from Kitchen's effective carry limit. One accepted whole item is spent once; the reserve is not withdrawable storage and contributes nothing to collection totals. Retrieving a shelf item already changes its live goal contribution; refuelling must not subtract it again.

Apply the existing physical contribution grammar: inspect without spending, preview credit/waste, then deliberately submit the selected eligible item. Accepted Fuel increases the reserve immediately up to capacity, and relevant effects update coherently. No category substitution, bonus for crossing a threshold, top-up grace, stored overflow or automatic item selection. Exact first-iteration transaction/UX choices are identified in §7 rather than passed off as separately negotiated design.

Fuel remains the actual item-category ID in this slice. "Energy" is explanatory UI language and the feature framing, not an authorized catalogue migration. Keep the eight categories, affinity pairs, item statistics and physical authoring unchanged. Batteries/panels/generators, final naming and item reassignment remain future work.

## 4. Emergency freight contract

### 4.1 Delay the start; preserve the cycle

A new delivery waits 60 active seconds only when all ordinary conditions for starting it are satisfied and the reserve is below 15. In particular, a valid next load exists and the previous load has completed unloading, closing, the full outbound cue and normal retirement/promotion.

The delay does not run during unloading, closing or outbound travel. It does not accrue while there is no available load. No banked wait credits, no first emergency delivery exemption, no call button or manually powered recovery task. One completed wait permits exactly its delivery, not every waiting load.

An already-started delivery runs normally through ARRIVAL → SEALED_READY → REVEALING → OPEN → CLOSING → outbound turnaround. OPEN still waits indefinitely for ordinary successful TAKE of every item. New low-power transitions never freeze shutters, pause/re-time cues, skip closing, shorten outbound travel or re-open drained cargo. This rule replaces the earlier stage-by-stage greyout holds.

### 4.2 Mode changes and timing

| Situation | Required result |
| --- | --- |
| Reserve falls below 15 during an active cycle | That cycle finishes normally; the next otherwise-ready delivery is subject to a new wait. |
| No cargo and an idle emergency lift | No running/stored wait; an eligible arrival later begins its full 60 seconds. |
| Next cargo becomes ready at active time `t` | Start one wait due at `t + 60`; no ARRIVAL audio or shutter movement yet. |
| Further cargo arrives during that wait | Normal FIFO/admission rules; do not reset the waiting delivery's timer. |
| A top-up remains below 15 | The original wait continues unchanged. |
| Refuelling restores at least 15 while waiting | Remove the restriction and start the eligible delivery once; do not continue a redundant wait. |
| Reserve falls again after a delivery started normally | Do not restart/interfere with that cycle. The next cycle receives its own assessment. |
| Wait completes at zero Fuel | Start the ordinary cycle; no Fuel charge, emergency replenishment or preferential loot. |
| Pause/save/load | Preserve remaining active-time delay and exact cargo; no offline countdown, restart, reroll or duplicated start cue. |

This is deliberately limited emergency throughput, not spontaneous restoration of the reserve, lights, Salvager or Workshop. At zero those remain at their low-power permissions indefinitely until refuelled. No continuous-lockout state is introduced.

### 4.3 Admission is not delivery start

Keep one active/pending delivery slot plus two deposited FIFO slots. A load accepted into the normal active slot may be pending its emergency start while the shutter remains closed. This is a new *mechanical waiting state*, not a fourth slot and not upstream Awaiting Lift. Other two queue slots remain usable.

Successful admission completes nonempty crew handover exactly as before; a crew is not kept unavailable solely because its already-admitted cargo has a 60-second wait. Teams with no deposited capacity remain upstream and keep their exact cargo/personnel. Oldest waiting teams retain priority. Destination release remains on return. Empty journeys remain Expedition-owned, bypass the lift and complete normally at return even during low power.

Queue promotion and admission after a completed outbound turnaround remain real mechanical events. Do not defer these ownership/crew transitions until emergency-wait expiry. Conversely, do not retire the previous active load early to begin a wait at last TAKE or shutter contact.

Prepared/staged hidden cargo stays pickup-disabled before OPEN. Receiving remains responsible for presentation of the committed manifest, not selecting, dropping or rerolling its contents. Preserve existing audio/animation settings, geometry, reach, CRT queue semantics and item identity.

## 5. Feedback, lighting and the temporary station

### 5.1 Lift CRT

Under normal lift power retain its existing readable light-green text. In emergency mode the readout text becomes orange and includes an explicit low-energy/emergency mode row. Use text as well as color. Suggested first-pass copy is "Freight mode: Normal" and "Low energy — Emergency freight"; wording and orange tint are not final art decisions.

Separate operating mode from mechanical state. An emergency-mode cycle can still be INCOMING/OPENING/OPEN/CLOSING. When awaiting the additional delay, make that wait identifiable rather than claiming to await nonexistent cargo. Preserve STATUS, DECK and QUEUE facts. QUEUE still counts only the two deposited queue slots, not upstream waiting crews or the selected active load.

Do not change the external W1 warning lamp's existing stage meanings. Do not dim the CRT, HUD, item facts, goal totals, previews or input feedback as a side effect of environmental power. Central Sorting monitoring can repeat this information later; do not build it now.

### 5.2 Environmental dimming

Multiply each included environmental light's authored normal strength by the current tier multiplier. Never repeatedly multiply an already-dimmed value or save the altered runtime value as the new authored baseline. Use an explicit set of participating room/working lights, not an indiscriminate walk of every light in the tree. Preserve range, pose, color and shadows; exclude preview/held-item UI worlds and status/safety indicators.

Use the current project's existing runtime/reflection refresh mechanisms as necessary when tiers change, not every frame. Do not re-author materials, bake new lighting, add postprocess blur, reduce targeting reliability or alter placement assistance. The local implementer should inspect the actual lighting and report which nodes/properties are included. Missing visual evidence is not permission to claim the illumination result is satisfactory.

Salvager and Workshop are not implemented operational systems at the published baseline. Expose simple power-availability facts from the reserve; test their band values. Do not create fake production tasks or instantiate either future system to demonstrate suspension. Their later work must respect those facts and preserve funded work while unavailable.

### 5.3 Refuelling station

For this test, use the existing electrical panel on the player's right of the lift shutter. Resolve its exact local node path and safe interaction target in the asset-equipped checkout, then record it. Preserve its transform/appearance/collision; add only the required ordinary reach/occlusion-aware target and minimal cue. Do not activate the decorative emergency-stop control.

There is one Fuel reserve and one refuelling interaction for this slice, not a second Ops debt owner. The distant Ops frontage stays as authored and inactive for this test. This is an explicit temporary test location, not permanent bunker relocation or corridor/layout approval. The adjacent station must not occlude the existing CRT, obstruct TAKE, or interfere with movement and shutter clearance.

The live panel shows reserve/capacity, consumption rate, current power band, affected facility permissions, selected-item credit/waste and projected band. Fuel stock must be physically carried there. Minimal tier-change feedback is appropriate; no full Journal, PA, per-frame notifications or monitor upgrade system.

## 6. Continuation and preservation

The existing save service remains the only persistence path. Save the fractional reserve and its accounting anchor, accepted top-up receipts, test configuration signature, and pending delivery identity/deadline/mechanical state. Reconstruct exact committed data before revealing play; panels and transient input reset closed. Do not roll time forward while offline, grant new starting Fuel on Continue, or recapture already-dimmed lights as normal.

Terminal Fuel receipts must be disjoint from live physical ownership, Kitchen contributions, expedition loadouts and incineration. Generated Fuel can legitimately be spent while its source batch is OPEN, closing/outbound, or retired; exact identity/definition/prior handover still require validation. Unknown missing goods must remain errors.

Schema 8 has neither reserve history nor an emergency waiting state. Proposed technical default: use the next unused schema (9 if available), confirmed New Run and no automatic schema-8 conversion. Keep the collection service/namespace; preserve incompatible snapshots and existing legacy/M4 files. A failed Continue or canceled New Run must not replace anything. Ordinary autosave cadence and durability limits stay unchanged.

Retain all accepted Kitchen and Incinerator behavior, exact expedition outcomes, storage and ladder interaction, collision repair, goal totals and first victory. The six-Utility collection target, eight-person roster, sixteen-item acquisition pool and other expedition fixture settings are not retuned. Testing continued play or isolated near-threshold saves is appropriate; silently shortening the production starting buffer is not.

## 7. Narrow execution defaults (author recommendations, not new release tuning)

**D1 — Whole-item cap and waste with a fractional reserve.** Use the existing primary Fuel Utility (including established per-instance effects). A positive Fuel item with available tank headroom may be submitted. Credit `min(item Utility, capacity - reserve)` and discard the remainder; keep fractional applied/wasted amounts. Reject full-tank, zero-Utility, wrong-category, invalid/stale and already-spent actions without consumption. At 59.5/60 an item supplying 6 credits 0.5 and wastes 5.5. No minimum top-up threshold, container return, siphoning or extra confirmation is added. The preview must not display a positive sub-unit credit as zero; revalidate at commit because the panel is live.

**D2 — Familiar controls.** F inspects/toggles the Fuel panel; a distinct E submits the selected item, with normal carried selection. No repeated held E, no cost on opening, no popup per top-up. ESC closes the service layer before pause; only one service panel owns input. Access and selected identity are revalidated immediately before exact consumption. Use current Kitchen/Incinerator conventions instead of reviving the retired contribution modal.

**D3 — Suggested minimum UI.** Add a short temporary interaction label, honest reserve values with sufficient fractional precision, power tier, projected item credit/waste and emergency wait feedback. Working labels/tint can be chosen for legibility. The existing CRT must retain its live data and layout readability; minor text layout accommodation is allowed, wholesale CRT/art redesign is not. No promise of a final segmented gauge.

**D4 — Technical chronology.** Integrate reserve changes and freight-start permissions into the existing active timeline. At a shared timestamp update authoritative consumption before evaluating a not-yet-started delivery, then preserve existing FIFO/crew ordering. A successful same-time top-up must update power and settle start eligibility before transaction observers see an inconsistent state. No positive time is advanced inside an item transaction. An already-started cycle never loses its commitment. Implement threshold equality/next-positive-time handling without polling-induced drift or an epsilon-created loop. Choose a coherent representation locally and pin its exact boundary behavior in tests.

**D5 — Deferred-facility clarity.** The reserve can return Salvager/Workshop availability booleans and display them as power permissions; indicate that those services themselves are not implemented. No generic buff/electrical network, simulated consumer objects, outage manager or upgrade hooks beyond simple current values are required.

D1–D5 and the proposed schema boundary make the work order executable without reopening the agreed mechanics. Report any concrete contradiction rather than silently changing thresholds, credit grammar, acquisition or recovery rules.

## 8. Acceptance boundary

The slice proves refuelling, deterministic reserve consumption, tier feedback, lighting, admitted-cargo emergency waiting, no-dead-end freight and exact continuation. It does not prove release balance, a full-scale catalogue, completed Workshop/Salvager integration, large-stock save performance, short-suspension timing, or release crash durability.

Local implementation stops at **technically ready for developer playtest**. No automatic human promotion, merge, push, PR, next slice or historical branch removal. The existing Incinerator and Kitchen promotions remain valid, not reopened.

## 9. Inspected source anchors

All links pin the source used while drafting, not presumed future implementation:

- [Published main / current state](https://github.com/Navandis/Sorting-apoc-PROTOTYPE/blob/b0dee116dbfd6802ccd41e046df50d294de05a41/docs/CURRENT_STATE.md): Kitchen publication, retained contracts and provisional fixture.
- [Working guidelines](https://github.com/Navandis/Sorting-apoc-PROTOTYPE/blob/b0dee116dbfd6802ccd41e046df50d294de05a41/docs/AI_WORKING_GUIDELINES.md): one implementer, proportionate checks, scoped cleanup and evidence.
- [Active timeline](https://github.com/Navandis/Sorting-apoc-PROTOTYPE/blob/b0dee116dbfd6802ccd41e046df50d294de05a41/gameplay/run/collection_timeline.gd): existing boundary splitting and progress guard.
- [Lift cycle](https://github.com/Navandis/Sorting-apoc-PROTOTYPE/blob/b0dee116dbfd6802ccd41e046df50d294de05a41/gameplay/logistics_wing/receiving/receiving_lift_cycle.gd): automatic arrival on active-batch change and completed outbound retirement.
- [CRT](https://github.com/Navandis/Sorting-apoc-PROTOTYPE/blob/b0dee116dbfd6802ccd41e046df50d294de05a41/gameplay/logistics_wing/receiving/receiving_lift_phosphor_display.gd): state-indexed text and live counts.
- [Receiving runtime](https://github.com/Navandis/Sorting-apoc-PROTOTYPE/blob/b0dee116dbfd6802ccd41e046df50d294de05a41/gameplay/logistics_wing/receiving/receiving_runtime.gd): configuration and presentation/continuation boundaries.
- [Run snapshot](https://github.com/Navandis/Sorting-apoc-PROTOTYPE/blob/b0dee116dbfd6802ccd41e046df50d294de05a41/gameplay/run/run_snapshot.gd): schema 8, terminal receipt composition and the current closed/busy/departing invariant.

The prior contribution record at `docs/design_history/2026-11-09-contribution-effects-and-kitchen-decisions.md` remains provenance. Its episode/hold-based Fuel subsection needs a supersession pointer, not deletion of the historical discussion or reopening of its Kitchen decisions.
