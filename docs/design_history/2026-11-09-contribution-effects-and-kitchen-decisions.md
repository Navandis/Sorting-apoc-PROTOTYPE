# Sorting Apocalypse — Contribution Effects and Kitchen Decisions

**9 November 2026 | Conversation-derived design record and Kitchen iteration specification**

## 1. Authority, status and purpose

This record consolidates the developer's decisions after the Incinerator documentation close-out. It is the design source for the accompanying first continuous Kitchen implementation, not a claim that the wider contribution systems already exist. Reconcile its applicable content into the current DOCX masters and regenerate their reading copies in the documentation-first work block. Do not maintain conflicting parallel specifications afterward.

The developer approved a holistic contribution-effects design pass before implementing another service. Previously tentative lane assignments and effects were explicitly reopened. The developer then approved the Kitchen refinements, scheduling model and capped additions, and supplied the initial quantities below. These values are **provisional iteration settings**, not balanced release requirements. Distinguish confirmed rules, working future-system direction and brief-author operational defaults throughout the master updates.

Read-only repository preflight on 9 November found `main` at `856353ef7fef957e1b3b8dd1b8c607df4aff2c17`, the Incinerator close-out commit. Earlier attached evidence describing publication as pending is a dated statement, not grounds to roll back the live ref. This is a source anchor, never a reset target. The new design in this record is not implemented by that commit.

Primary decision provenance is the developer's conversation: the bonus-versus-restoration distinction; the revised contribution shortlist; the Weapons/Kitchen/Energy/Electronics/Medical clarifications; proportional Kitchen relief; approvals of cumulative capped demand, independent randomized timing and cap clipping; and the 9 November numerical request. This is a faithful decision summary, not a verbatim transcript or invented message-timestamp register.

## 2. Cross-system effect allocation

### 2.1 Baselines and scope

An expedition with no loadout has its ordinary baseline capabilities. Loadout contributions proactively buy advantages for that expedition. A bunker with no outstanding service problem operates at baseline; recurring service contributions reactively remove penalties. These systems need not use identical incentive or timing rules.

Do not make recurring bunker obligations rewrite ongoing expedition duration, cargo, recruitment or injury outcomes. The Energy service may obstruct bunker-side receiving machinery and thereby delay cargo handover; that is distinct from changing an expedition's committed outside outcome.

| Contribution | Agreed allocation / working direction | Implementation boundary |
| --- | --- | --- |
| Expedition Food | Increase that team's carrying capacity. The contributed item's full Bulk remains charged. Useful provisioning should offer worthwhile net headroom. | Formula, magnitude and capacity-validation ordering need the later Expedition scope. |
| Expedition Hydration | Shorten the individual expedition. | No cargo admission acceleration or backlog bypass. |
| Expedition Protection | Reduce injury chance. | Prevention, not treatment or an extra casualty system. |
| Expedition Weapons | Prefer better Utility/Bulk items **within the selected category**. | Do not alter affinity probabilities or authored item values. Exact quality curve/pool remains open. |
| Expedition Morale | Replace Medical in the intended loadout; increase recruitment opportunity proportional to participating scavengers. | Equal coverage and equal total scavenger participation should not favor one-person-team spam merely through extra expedition records. Exact rolls, limits, joining and rates remain open. The example zero baseline / five percent per member is not approved tuning. |
| Kitchen Food + Hydration | One shared condition: reduced player carrying capacity and sprint disabled after grace. Contributions relieve capacity proportionally; full clearance restores sprint. | Implement in this milestone. No ordinary walking-speed reduction. |
| Fuel / possible Energy service | Finite greyouts: lower environmental light intensity; suspend lift progression, Salvager operation and Workshop work at defined boundaries. | Document only. No category rename or outage implementation here. |
| Electronics | Remove from recurring Ops demand. Use for one-time Workshop purchases, including one purchase per upgrade tier if tiers exist. | Document as confirmed design, not a new upgrade implementation. |
| Medical Ward | Medical contributions accelerate natural recovery of Light/Severe injuries. The Ward alone handles and modifies healing under the current direction. | Kitchen Food/Hydration do not alter healing speed or success. No patients, injury rolls or treatment in this milestone. |

The target loadout is Food, Hydration, Protection, Weapons and Morale. The accepted mechanical fixture still uses Medical and has no provisioning outcome bonuses. Explicitly distinguish these in the GDD/MVP: **do not change the live expedition lanes or add the new bonuses during the Kitchen task.**

Unequal category sinks are intentional. Electronics can accumulate faster because its expenditures are one-time investments. Morale need not remain a recurring Ops lane. The category set remains eight; possible Fuel-to-Energy framing is broadening/renaming an existing category, not a ninth category.

### 2.2 Fuel/Energy decisions to preserve, not implement

Greyouts are finite, separated by meaningful powered intervals, and cannot become effectively endless through repeated rolls or accumulated debt. Fulfilling the pending Fuel requirement immediately ends an active greyout. Machinery work, cargo and funded project progress are preserved rather than reset. Run time and outside expeditions continue. Incinerator operation is immune to Fuel/Energy interruptions.

Dimming means reducing environmental light intensity. No blur, UI dimming, inaccurate targeting, altered object identity or removal of interaction assistance. The intended inefficiency is qualitative: a player may approach closer or change viewpoint to distinguish stored goods. Exact seconds of lost sorting efficiency are not a design requirement. Restore the authored lighting baseline afterward.

The developer supplied this lift intent:

| Lift state at interruption | Approved direction |
| --- | --- |
| SEALED_EMPTY / truly idle | Remain closed/idle. A returned crew may deposit into an available queue slot, as when the lift is busy downstairs. |
| ARRIVAL | Complete descent; hold at SEALED_READY. |
| SEALED_READY | Hold before opening. Explicit tolerance: if this narrow transition cannot be intercepted reliably, complete REVEALING to OPEN instead. |
| REVEALING | Finish opening to OPEN. |
| OPEN | Normal TAKE remains available. If emptied during the greyout, do not begin CLOSING until restored. |
| CLOSING | Finish closure and its stable presentation boundary; do not begin the outbound pickup journey until restored. |

The developer permits reaching a later stable state rather than fragile mid-transition interruption. Exact chronology, queue/active-slot integration, theatre resumption and save representation need the Fuel milestone. **Outbound already in progress** was raised by the architect: allowing it to finish before holding the next descent is a recommendation, not an independently approved additional transition. Preserve that status.

Fuel naming, service naming, catalogue additions (batteries, power banks, compact generators/panels) and item reassignment remain future authoring. Do not implement battery charge, generator simulation, renewable production or permanent benefits from an ordinary request submission by implication.

### 2.3 Balance and Medical boundaries

The target is a fair, understandable noncompetitive collection game, not near-perfect equality between every strategy. Useful strong combinations and repeat-run mastery are acceptable. Investigate gross bypasses or extreme completion-time collapse, not every efficiency difference. The developer's four-to-five-hours versus thirty-minutes example describes an unacceptable order-of-magnitude distortion; neither is an approved target duration.

Poor play may require substantial recovery effort; avoiding dead ends is not adaptive catch-up or a guarantee of fast recovery. Medical's slower untreated recovery and faster treated recovery remain the intended direction. Pooled versus individual/FIFO treatment, costs, UI, injury severities' actual times and outcomes require the Medical milestone. Do not add injured-away behavior, Kitchen-dependent recovery, or mortality curves.

## 3. Kitchen: standing rules

### 3.1 One cumulative obligation

Maintain one player-facing Food/Hydration obligation. Each lane has its own integer outstanding balance. Food cannot satisfy Hydration or vice versa. Additional demand joins the **remaining balances**, not the historical original totals. Do not average the two lanes' percentage coverage; every credited Utility point has equal penalty-relief value.

When the obligation opens from zero outstanding, start one grace period. During grace neither the capacity penalty nor sprint prohibition applies. More demand joins the same deadline without restarting or extending it. Once overdue, additions increase the penalty immediately; they receive no separate grace.

Partial contributions reduce the appropriate outstanding lane and therefore the potential or active penalty. Clearing both lanes closes the obligation, restores ordinary upgraded capacity and restores sprint. A later opening gets new grace. Completion is never a victory condition. Kitchen remains functional after victory without changing first-completion time.

### 3.2 Penalty and carrying

Let `D = outstanding Food + outstanding Hydration`, `R` be Utility per **percentage point**, and `C` the current normal upgraded carrying limit.

During grace or with no obligation: effective carrying limit is `C`, sprint allowed.

When overdue:

```text
penalty percentage points = D / R
capacity = floor(C * (1 - D / (100 * R)))
sprint allowed = false until both lanes reach zero
```

Retain fractional percentage internally. Round down only the final carrying limit, not individual contribution gains. An upgrade changes `C` without changing the Kitchen percentage. The penalty is never applied repeatedly to an already-penalized limit.

Existing possessions remain when the limit falls: `20 carried / 10 effective` is legitimate. New pickups must fit the effective limit. Legal submission, storage, retrieval choices and Incinerator use follow their normal ownership paths; no forced item removal, teleporting or Incinerator-specific carrying exception. Exact rollback of a failed transfer restores its prior legal ownership even when that prior inventory exceeds the current effective limit. That is not a new pickup.

The first iteration retains normal capacity 20, ordinary walking, acceleration, collision and ladder rules. Only eligibility for the existing sprint multiplier changes. Carrying upgrades are not implemented; tests can exercise a controlled `C = 25` or another normal limit through the same calculation to prove future compatibility.

### 3.3 Contribution and feedback

Whole selected items are committed once, irreversibly, through the accepted transaction boundary. Credit `min(item Utility, lane remaining)`; excess is wasted, not stored for later demand or the other lane. Use the entire merged category balance, not artificial historical request partitions. No automatic choice of carried items and no held-E repeated consumption.

Display outstanding Food/Hydration, current phase/grace countdown, **percentage capacity loss** and sprint state. Preview the selected item's applied credit, waste and before/after percentage. The ordinary carried HUD continues to show actual Bulk / effective limit, including over-limit states. During grace distinguish current `0%` from the potential after-grace penalty; a contribution reduces the latter rather than claiming an active reduction. A fractional reduction can leave whole-Bulk capacity unchanged.

Inform the player when actual demand is added and when penalty state changes, without requiring a visit to discover a disabled sprint. Notification implementation remains minimal for this iteration; no PA, Journal or monitoring-upgrade system is implied.

### 3.4 Bounded outstanding demand

Cap **total outstanding Utility**, not merely the displayed penalty. At the initial ratio and maximum below the bound is 150. Issued demand never exceeds it; there is no invisible over-cap debt.

An incoming addition that exceeds headroom is clipped to fill that headroom exactly, approximately preserving its proposed Food/Hydration ratio through whole-integer allocation. Existing balances are not redistributed. At zero headroom add nothing. Discard the unissued excess permanently; no queue, repayment obligation, later catch-up or immediate refill follows a contribution.

A highly unequal cumulative balance is legitimate after the player supplies one lane. The generated-addition balance constraint does not force the live remainder back toward equality.

### 3.5 Independent active-time schedule

Each scheduled event picks the next timestamp a random bounded interval after the **scheduled event time**, not actual callback time or player interaction. Events count as processed even if they add zero demand at the cap. The first trigger is selected once for that run; subsequent timestamps derive from the committed sequence. New runs initialize independently; no cross-run uniqueness guarantee is necessary.

Kitchen timing randomness belongs to this narrow system. Keep it independent of expedition/loot randomness **and Kitchen amount/split randomness**. Payment, cap clipping, panel use and other events cannot perturb timing draws. Save the first timestamp, next timestamp, event progress and relevant generator state; restoring, exiting, pausing or continuing after victory does not reroll them.

Only active time advances. Request minimum spacing and initial obligation grace are separate. Clearing just before another scheduled event does not delay the event; the newly opened obligation gets its own grace. No post-payment quiet period or performance-dependent scheduling is introduced.

## 4. First-iteration numerical configuration

| Setting | Value | Status |
| --- | --- | --- |
| Proposed total per scheduled event | Integer 60–80 Food + Hydration Utility, chosen each time | Developer-supplied provisional test range |
| Food/Hydration imbalance | Gap no greater than 25% | Developer constraint; denominator interpretation below is explicitly an author default |
| Initial obligation grace | 60 active seconds | Developer-supplied provisional value |
| Maximum capacity penalty | 50 percentage points | Developer-supplied provisional value |
| Utility-to-penalty ratio | 3 Utility per percentage point | Developer-supplied provisional value |
| Outstanding Utility cap | 150 combined Utility | Derived from 50 × 3 |
| Scheduled inter-event interval | 180–300 active seconds | Developer-supplied provisional range |

These are testing settings. Do not adjust item stats, target six Utility/category, roster eight, 8 Bulk/member, 90–180-second expedition trips, sixteen-item acquisition pool or existing fixture loadout costs to make these Kitchen values appear balanced.

### 4.1 Explicit draft-author defaults to remove small ambiguities

These are not represented as additional developer-confirmed release decisions. They are operational choices for this first iteration and can be changed deliberately.

**A1 — Meaning of the 25% gap.** Use the conservative relative interpretation: `larger lane <= 1.25 * smaller lane`. Equivalently, after drawing total `T`, choose Food uniformly from the inclusive integer interval `[ceil(4*T/9), floor(5*T/9)]`; Hydration is `T - Food`. Draw `T` uniformly from 60 through 80. Examples: T=60 permits 27/33 through 33/27; T=72 permits 32/40 through 40/32; T=80 permits 36/44 through 44/36. This is NOT `abs(F-H) <= 0.25*T`, which would allow a wider imbalance. Only full proposed additions must meet this rule.

**A2 — First trigger.** Draw it uniformly 180–300 active seconds after New Run, using the same range as subsequent intervals. Do not issue an immediate initial request or add another onboarding delay. Use integer-second draws; the authoritative active clock keeps its existing finer precision.

**A3 — Clipped integer split.** For headroom H and proposed `(F,Hd)`, accept at most `A = min(H,F+Hd)`. Allocate integer shares by proportional largest remainder: floor each `A*lane/(F+Hd)`, then give the remaining unit to the larger fractional remainder. Exact ties alternate by scheduled event index (odd favors Food, even Hydration), without consuming timing RNG. With only one unit of headroom a one-lane addition is valid; do not violate the total cap just to keep both additions positive. Discard zero-headroom proposals. Draw a proposal on every scheduled event, including capped events, so contribution actions do not alter the sequence of proposed amounts either.

**A4 — Percentage display.** Display up to two decimal places, trimming redundant zeroes, with approximate formatting where needed. Use exact integer/rational calculation for capacity; never use the rounded display value as gameplay input. At R=3 the overdue formula is `floor(C*(300-D)/300)`. Even a one-Utility debt must not display as zero penalty.

**A5 — Minimal awareness and panel behavior.** Use the existing notice/HUD conventions for actual added demand, grace expiry and closure, plus a compact baseline Kitchen status. No exact future-trigger countdown is needed in player-facing UI. The station panel is live, uses F/E/ESC and selected carried-item switching, and stays open at clearance with an inactive/no-outstanding state; E then spends nothing. Opening while inactive is safe. This is a first-iteration UX choice, not a final-art mandate.

**A6 — Coincident events.** Settle due Kitchen grace expiry, then due scheduled addition, before a player contribution at the same timestamp. A shared-time due event is processed once. Preserve the pre-existing causal order of lift and expedition work. This is deterministic boundary policy, not an extra delay or grace period.

**A7 — Save boundary.** Prefer the next unused schema (8 if unused locally), fresh New Run and no automatic schema-7 conversion. Use the existing collection save service/namespace and preserve all incompatible snapshots. A schema-7 run has no historic Kitchen timetable; do not invent one during Continue. Confirm the actual local schema before implementation. No new autosave trigger, journal or release-durability claim.

## 5. Meaning and limits of the first iteration

This iteration proves a recurring service acting on player logistics, not the complete service economy or a balanced finite run. The short goal can be completed before the first Kitchen event; use continued play and isolated fixtures to test service behavior rather than changing victory settings. Unprovisioned crews remain superior in the temporary expedition model; do not repair that incentive inside this task.

At the inspected baseline, all generated expedition-pool definitions are checked to be at most 8 Bulk. Normal player capacity 20 falls to 10 at maximum Kitchen penalty. That avoids this particular pool producing a new uncarryable single cargo object; it is not proof for all authored seeds, a future full catalogue or later capacities. Check the local pool bounds and demonstrate a real bounded recovery path with Food and Hydration under the maximum penalty. No rescue grants, remote disposal, enlarged carry exceptions or full-catalogue expansion.

Do not call the future Food/Hydration/Protection/Weapons/Morale bonuses, Energy interruptions, natural healing, recruitment or Workshop purchases implemented. Ration conversion, mass incineration, Fuel rename, source assets, scene geometry and baseline lighting remain untouched.

## 6. Documentation reconciliation destinations

- GDD v0.16: reconcile facility/category table, §§8–10 contribution and outcome boundaries, §12 Kitchen, §§13–15 Medical/Ops/Workshop, relevant open questions and implementation-status summaries. Preserve accepted historical evidence while distinguishing the current fixture from target design.
- Systems MVP v0.5: record confirmed future direction and the newly authorized Kitchen scope; do not rewrite M1–M4 results or claim their daily consumers remain the new implementation. After execution, summarize actual Kitchen proof and its limits separately from human acceptance.
- VDD v0.11: targeted textual compatibility only where service labels, information or Energy dimming assumptions are affected. No node movement, material changes, corridor shortening or actual light edits. If no applicable passage needs editing, leave the master unchanged and say so.
- Edit DOCX masters first; regenerate companions with the established extractor. Check changed paragraphs/tables, links and affected rendered pages. Do not independently maintain generated Markdown.
- Reconcile `docs/README.md`, `docs/CURRENT_STATE.md`, `docs/CODEX_BOOTSTRAP.md` and the existing 7 November conversation bootstrap only where authority/current scope/status changes. This dated record supplies decision provenance; no replacement bootstrap is necessary solely for its date.

All current masters must retain the distinction **confirmed design ≠ implemented ≠ technically verified ≠ human-promoted ≠ published**. No historical survival rule supplies an unspecified post-pivot mechanic.
