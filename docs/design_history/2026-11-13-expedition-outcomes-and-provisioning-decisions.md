# Expedition outcomes and provisioning — agreed first iteration

**13 November 2026 · Design consolidation for implementation, not an implementation result.**

This record consolidates the developer's explicit decisions after the collection pivot, the five-lane discussions, the fresh loadout assessment and the Receiving/Fedora follow-up. The gameplay rules are agreed; numerical settings are provisional playtest values. The 23-Bulk capacity is selected, not a still-open 22/23/24 comparison. Reassess loadouts after a significant catalogue expansion or a demonstrated balancing need, not merely to erase solo-team inefficiency.

## 1. Purpose, alternatives and boundaries

Expeditions supply a physical hoard and offer voluntary resource-for-time/efficiency decisions. Zero provisioning is a valid baseline, not a special punitive mode. Full bars do not auto-dispatch. The game is not a combat, health or survival simulation. No day cycle, expedition window, daily team formation, destination depletion, artificial rescue, terminal no-scavenger failure, or population ceiling is introduced.

Retained decisions and rejected alternatives:

| Subject | Selected direction | Not selected |
| --- | --- | --- |
| Food | A capped linear expected bonus-item count, outside ordinary return Bulk; outgoing Food still costs Bulk | Extra carrying capacity, fractional capacity rounding, a bonus-only item Bulk ceiling, guaranteed return on investment |
| Weapons | Continuous mixture of uniform and Utility/Bulk-weighted selection within an already-chosen category | Quality bands, low/full thresholds, item-stat changes, modifying affinity weights |
| Personnel | Independent per-original-member injury and recruitment outcomes | Team-wide all-or-nothing accidents, immunity, recruits diluting provision, injury reducing committed cargo |
| Receiving | One exact combined manifest, one delivery; approved Receiving-only mixed stacking | Chunking, hidden loot substitutions/rerolls, geometry changes or a new packing investigation in this milestone |
| Capacity | 23 ordinary Bulk per scavenger, accepting the solo efficiency difference | Raising capacity to 33–40 to force solo compliance with a loadout aspiration |

Balancing should avoid a plainly dominant broken strategy, not enforce equal efficiency or guaranteed profitable provision in every situation. A lucky valuable bonus item is not itself a problem. Food has competing Kitchen and collection uses. Injury risk remains at maximum Protection, but treatment need not be mandatory for every patient.

## 2. Selected first-iteration settings

Let `n` be the ORIGINAL dispatched crew count, 1–4. Let `F,H,P,W,M` be credited Utility in the five lanes. Whole-item credit is capped at the remaining lane need; excess is discarded, and the full item Bulk is charged. No cross-lane substitution or banked excess.

| Setting | Value |
| --- | --- |
| Original crew size | Player chooses 1–4 Ready scavengers |
| Ordinary capacity | `23 * n` Bulk |
| Food ceiling | `10 * n` Utility |
| Hydration ceiling | `5 * n` Utility |
| Protection ceiling | `12 * n` Utility |
| Weapons ceiling | `10 * n` Utility |
| Morale ceiling | `15 * n` Utility |
| Unmodified journey duration | Uniform continuous draw in 210–300 active seconds, independent of crew size |
| Maximum Hydration reduction | 25% |
| Maximum Weapons mixture | 0.5 |
| Baseline injury probabilities per original | Light 20%, Severe 10%, Healthy 70% |
| Maximum Protection reduction | 50% RELATIVE reduction of both injury probabilities |
| Natural recovery | Light 120 active seconds; Severe 300 active seconds |
| Recruitment | Baseline zero, maximum 5% per original, one independent opportunity each |
| Starting workforce | Retain existing eight Ready for this iteration; not a new release-balance decision |
| Collection target | Retain existing six Utility per category test goal, continued play after victory |
| Player normal carry limit | 22 Bulk |
| Kitchen maximum penalty | 35%; combined outstanding demand cap 105 at three Utility per percentage point |

Four members therefore require F40/H20/P48/W40/M60 for full provisioning. These are five separate needs, not 208 interchangeable Utility. No single inventory of starting stock is assumed to contain an optimum recipe.

## 3. Preparation and ownership: extend, do not rebuild

Retain the accepted one-current-draft workflow. The first successful supply submission forms the crew and removes its members from Ready. A successful zero-supply Dispatch forms the crew at departure. Before formation, size can change within Ready availability; afterward size is locked. Affinities remain editable before successful dispatch. Contributions are irreversible, panel closure preserves the current draft, and another team cannot be prepared in parallel.

Exactly two distinct unordered affinities and an available destination are required for dispatch. There are 28 possible pairs of the eight categories, no reservation before dispatch, and at most one AWAY crew per pair. Destination occupancy ends at RETURN, not handover. A team awaiting lift can share its former destination with a newly dispatched team.

Preserve the no-Ready repair: with zero Ready and no formed crew, show no available crew and prevent affinity edits, contributions and dispatch in both UI and action owner. A formed last crew remains usable even with zero Ready. Handover/recovery refreshes availability while the panel is open. Do not create a fake zero-member team or delete valid draft preferences.

Opening never spends. A fresh E submits one selected item; F/ESC, wheel/number selection and existing input suppression remain. Dispatch is explicit even when every lane is full. The panel remains live. No refunds, resizing formed crews, parallel tabs, auto-send or cancellation/disbanding feature is added.

All submitted supply Bulk counts against `23*n`, including Food. A submission that would exceed the raw capacity rejects intact; the bonus never authorizes overpacking. Existing exact-item receipts, duplicate-spend guards and rollback behavior remain authoritative.

## 4. Ordinary and bonus acquisition

### 4.1 Catalogue and category choice

Use the active `ItemCatalog` registry and its resolved canonical `ItemDefinition` resources, not the old sixteen-definition test list and not an analysis spreadsheet as runtime data. The reference state contains 167 definitions; verify the actual adopted state. Retired IDs stay excluded because they are not active entries. Preserve source mappings, Category, Utility, Bulk, scale, pose, Footprint, support flags and Auto Stack Group values. Pending authoring review flags are not an extra runtime exclusion rule.

All eight categories start equally likely. Both selected affinities have equal impact. The agreed 20% is a RELATIVE increase over each category's 12.5% baseline: with all categories feasible, each affinity is 15% and each other category 11 2/3%. Use weights 9 and 7, respectively. Do not replace this with weights 1.2 and 1, which normalize to a different probability.

Stable category and definition ordering make seeded runs/replays reproducible. Catalogue validation should expose invalid/missing data rather than silently omit inconvenient objects. No rarity tiers, category-count bias, stockpile-dependent weighting, pity mechanics, depletion, or personal destination hazards.

### 4.2 Ordinary haul

`ordinary_budget = 23*n - sum(full Bulk of all accepted supplies)`.

At each draw, determine the categories containing at least one eligible whole item whose Bulk fits the remaining ordinary budget. Remove infeasible categories for that draw and normalize the same 9/7 category weights among the remaining categories. Draw category first, then definition using §6. Subtract that whole item's Bulk and repeat until no eligible item fits. Do not retain the old hardcoded minimum pool Bulk of two; the actual catalogue includes one-Bulk items.

Duplicates are allowed without depletion. Every repeated definition becomes a distinct durable item instance. Item count is not the selection budget. No extra random amount-found limit, fixed item-count ceiling, or limit of ten carried objects is introduced.

### 4.3 Food bonus count

Each credited Food adds 0.125 expected bonus items. Pooled team opportunity is `E=F/8`, capped by the lane at `10*n` Food and thus at `1.25*n` expected items.

Use an exact whole-plus-remainder calculation: `guaranteed = F // 8`; one additional item succeeds with probability `(F % 8)/8`. At an exact integer there is no extra possible item. Do not perform separate rounding/bonus rolls per scavenger.

| Crew at full Food | Credited Food | Count outcome |
| --- | ---: | --- |
| 1 | 10 | 1 guaranteed; 25% chance of 2 |
| 2 | 20 | 2 guaranteed; 50% chance of 3 |
| 3 | 30 | 3 guaranteed; 75% chance of 4 |
| 4 | 40 | Exactly 5 |

A team at F33 has four guaranteed plus 12.5% chance of five. This matters for partial-provision extreme-haul legality and must not be rounded to either four or five beforehand.

### 4.4 Bonus selection and combined manifest

For each awarded bonus item, use the same category affinity weights and Weapons preference as ordinary generation, but NO ordinary remaining-Bulk filter and NO bonus-only Bulk/Utility ceiling. Every otherwise eligible active category remains available. Bonus items neither consume nor enlarge the ordinary budget. They retain their full Bulk everywhere else, including player carrying, storage and any future contribution.

Generate the ordinary portion against its complete budget independently of bonus packing. Record which entries are ordinary and which bonus (or a durable ordinary-prefix boundary) so continuation can validate the distinct allowances. The exact ordered combined manifest is presented as ONE batch and ONE delivery. No split trips, extra personnel releases, separate queue slots or Food-specific Receiving contents.

There is no requirement to match the submitted Food's Utility or Bulk with the bonus reward. Tune opportunity per Food and its cap only through a later deliberate balance change. Do not offset exceptionally good draws with deliberately bad draws.

## 5. Hydration duration

Draw `T0` once uniformly in 210–300 active seconds. Use:

`h = min(1, H/(5*n))`

`duration = T0 * (1 - 0.25*h)`.

At the cap the range is 157.5–225 seconds. Keep fractional active seconds internally. Crew size does not independently change the base range. Recruits never change its denominator. Preview the range; commit the exact sampled duration only at successful departure. Hydration does not bypass the lift queue or shorten the emergency wait, and does not change per-journey injury or recruitment probabilities.

## 6. Weapons selection

For the already-selected category and its eligible candidate set, let `m` be its size and `q_i = Utility_i/Bulk_i`. With `a = 0.5 * min(1, W/(10*n))`, use:

`Pr(item i | category) = (1-a)/m + a*q_i/sum(q)`.

At zero Weapons selection is uniform. Full Weapons gives an equal mixture of uniform and quality-weighted selection; it does NOT promise 50% higher Utility or a 50% chance of the best definition. Same-ratio definitions receive equal probabilities. No candidate is gated by a provision tier. Category probabilities do not change with Weapons. Ordinary fit filtering and bonus unrestricted selection create different candidate sets by design.

For valid positive-Utility catalogue data the denominator is positive. A future all-zero-Utility candidate category can use uniform fallback as a narrowly documented technical safety default, not authorization to add such items or new eligibility exclusions now.

## 7. Protection, injuries and Medical-owned natural recovery

For each ORIGINAL member, make one mutually exclusive outcome draw: Healthy, Light or Severe. The reduction is:

`r = 0.5 * min(1, P/(12*n))`

`p_light = 0.20*(1-r)`; `p_severe = 0.10*(1-r)`; `p_healthy = 1-p_light-p_severe`.

Maximum provision gives 10% Light, 5% Severe, 85% Healthy. This preserves the 2:1 Light/Severe ratio among injured members. Do not roll Light and Severe independently or grant immunity. Risk does not depend on duration, destination, other lanes, Kitchen, Fuel, current population or existing patients.

Injuries do not reduce selected cargo, recalculate capacity, delay a committed trip or cancel recruitment. Injured originals are not dispatchable while recovering.

At the personnel-handover boundary (§9), each injured original becomes an anonymous Medical patient, with `recovery_at = handover_at + 120` for Light or `+300` for Severe. Natural recovery begins then, never at Dispatch or arrival while still Awaiting Lift. Every patient progresses independently/parallel in active time. No beds, FIFO treatment queue, scarcity penalty or ward capacity limit is introduced. Stable patient/cohort identity must distinguish individual completion even without biographies.

Medical owns recovery state and timers. Completion returns the person to Ready once; it is not a new recruit or a population increase. All-injured states retain this ordinary recovery path. Fuel depletion and Kitchen penalties cannot pause natural healing. Pausing the active run does pause it; offline time does not count. Recovery continues after victory.

No HP, death, treatment success rolls, injury worsening/severity shifting, injured-away variant, or new injury traits. These remain unimplemented future design options, not dormant hooks. A later Medical milestone adds physical Medical contributions and acceleration after that service is designed.

## 8. Morale and recruitment

One independent opportunity per ORIGINAL dispatched member, separate from that person's injury result:

`p_recruit = 0.05 * min(1, M/(15*n))`.

Zero Morale gives zero chance. Each success adds one healthy newcomer. No one-recruit-per-team cap; a four-person crew can find zero through four. Full provision gives `1-0.95^4 = 0.18549375` chance of at least one and 0.20 expected recruits. An injured original can still recruit. Do not condition recruitment on health or recalculate modifiers over originals plus recruits.

Newcomers do not add return capacity, change duration, receive injury rolls on the same trip or roll for further recruits on that trip. They enter Ready at the same normal handover as the expedition's other personnel. A departure of four can therefore hand over more than four people. No recruitment acceptance ceremony, new-recruit state-machine minigame or population ceiling. Injured newcomers are a possible future tuning option, not part of this iteration.

Show recruit counts in the expedition outcome and retain the outcome for subsequent viewing. Do not expose hidden committed recruitment while the trip is still Away.

## 9. Returns, handover and personnel conservation

Nonempty return releases destination occupancy at its return timestamp and offers the exact batch to Receiving. The crew remains unavailable until admission to the active slot or either of the two deposited slots. A pending-start emergency load already admitted to the active slot has completed personnel handover even though ARRIVAL has not begun. Full Receiving capacity leaves the crew Awaiting Lift. Do not tie release to physical unloading or retirement of an already-admitted batch.

At successful handover, healthy originals and healthy recruits enter Ready; injured originals enter Medical. Complete this exactly once before exposing a completed handover state. No duplicate release through both callback and signal observers. An empty combined manifest bypasses all Receiving admission and lift movement, completes handover at return, and still applies its injury/recruitment outcomes normally.

Use one coherent personnel accounting model. A suitable conservation invariant is:

`Ready + formed-originals + Away-originals + Awaiting-originals + recovering originals = starting population + recruits already handed over`.

Recruits attached to an Away/Awaiting journey are pending outcomes, not yet available population and not an extra chance to dispatch. Validate handover and recovery history so a duplicate recovery or recruit cannot merely be hidden by a plausible total. No named-character simulation is necessary.

## 10. Randomness, commitment and known preparation failures

All inputs the player may change are settled at successful Dispatch. Stage duration, ordinary/bonus selection, injuries, recruits and exact presentation transactionally; successful departure stores the outcomes and future RNG state. Later Fuel/Kitchen changes, patient recovery, panel refresh or Continue cannot redraw or rewrite them.

Use stable, explicit random-stream ownership. At minimum, isolate outcome families so item counts/quality draws do not accidentally change injury or recruitment draws, and keep Expedition independent of Kitchen's timing/amount streams. This is a local deterministic implementation detail, not a new global randomization framework. Separate saved streams or deterministic per-journey substreams are both acceptable if outcomes and continuation obey the contract.

**Known Receiving limitation retained, not solved:** the 157-Bulk meat-and-mice overrun and long-object packing failure are deferred by explicit developer direction. No claim is made that all legal combinations fit. Keep the inherited safe pre-dispatch preparation rejection when the unchanged presentation cannot accept a staged haul. Show a clear diagnostic; do not lose goods, release/duplicate crew, occupy a destination, advance successful-dispatch sequence state or alter an already-formed draft. Already-spent provisioning remains in that same draft; it is not refunded. Restore staging RNG state on failure, so retrying unchanged inputs is not an implicit loot reroll. Record a reproducible failed manifest/seed for diagnosis without showing hidden successful outcomes during preparation.

This safe failure is a PROTOTYPE LIMITATION, not a newly designed release reward rule or proof of a universal no-dead-end guarantee. Do not invent automatic retries with different content, discard awkward items, split delivery, enlarge Receiving or restart the extreme-packing campaign. A newly common failure observed during ordinary play is reported with evidence and proposed scope, not silently masked or automatically solved.

## 11. Player and Kitchen settings

Adopt normal player capacity 22, maximum overdue Kitchen penalty 35%, and outstanding Food+Hydration cap 105 with the unchanged ratio of three Utility per percentage point. Effective capacity is `floor(22*(300-D)/300)` for overdue total D, so D=105 permits 14 Bulk. Use the current upgraded normal maximum in the general formula; do not implement upgrades now.

Keep Kitchen's existing independent 180–300 active-second schedule, 60–80 proposed total demand, lane-split constraint, one 60-second grace, proportional clipped additions, independent timing/amount streams and sprint-disabled-until-clear rule. Do not leave 150 debt behind a 35% displayed cap. Preserve grandfathered over-capacity possessions, exact rollback, legal disposal and ordinary movement.

The adopted catalogue currently has maximum item Bulk 14. Verify that relation against the actual active definitions; report new outliers rather than alter/omit them. This establishes the single-item pickup condition, not a universal storage-recovery proof.

## 12. Minimal player-facing information

Retain all current preparation information: available/formed crew, lane credit, selected-item eligibility, credited/wasted Utility, full outgoing Bulk, ordinary remaining return budget, two affinities and current expedition activity. Replace the Medical loadout row with Morale; Medical remains an item/affinity/collection category.

- **Food:** display X–Y Bonus Items for a fractional outcome, exact N Bonus Item(s) for an integer. Zero means zero, not 0–1. Show selected-item projected range; when the range stays unchanged but the remainder rises, say the chance of the upper count improves. Do not show percent-of-baseline loot or fractional physical items.
- **Hydration:** current/projected active-duration range. A hidden sampled time is not rolled in response to menu edits.
- **Weapons:** clear qualitative within-category quality preference, with actual supply credit/waste. The mixture is not a promised +50% Utility result.
- **Protection/Morale:** show useful current/projected outcome probabilities, identifying them as per original scavenger. Percentage precision is display-only and must not create mechanic tiers. No obligatory new mathematical dashboard.
- **Zero ordinary capacity:** preserve a separate deliberate warning/confirmation as a first-iteration UX default, but describe the truth: no possible cargo with F=0; only chance-based bonus cargo below one guaranteed; only guaranteed/possible bonus cargo above that. No blanket assertion that zero ordinary Bulk means an empty return. Opening/backing out of a warning must not draw or commit outcomes.
- **Returns:** a concise persistent expedition history/outcome section shows actual returned count, injuries by severity, recruits and waiting/handover status. It can expose the outcome at actual return, while clearly labeling pending personnel. It must not reveal future rolls while Away. This provides a future Journal data source without implementing the Journal/PA/central-monitor milestone.
- **Medical:** a minimal live read-only panel at the existing Medical frontage tracks current patients by severity and remaining active recovery time, with a clear untreated/natural-recovery label and no active contribution button. An empty ward shows no patients. Basic recovery/Ready information must remain legible even while the player is at Dispatch. Use existing F/ESC/reach/pause conventions; do not remodel the facility.

The read-only Medical panel, concise outcome history, unchanged pair labels and truthful zero-capacity warning wording are bounded UI defaults for this implementation brief. They are not final art/content design. Retain development pair labels rather than invent 28 final destination stories/names or reopen icon design.

## 13. Continuation, chronology and tests

Extend the existing active clock/timeline and save service, not node-local autonomous timers. Settle natural-recovery deadlines along with returns, admission, Kitchen and Fuel boundaries; preserve Fuel-before-new-cycle behavior and oldest-waiter-first admission. At equal timestamps use stable ordering and exactly-once operations. No-progress detection must include Medical progress so a boundary that only recovers a patient is not mistaken for a stuck lift.

Save current configuration/content signature, exact draft/receipts, original membership, RNG commitment, split ordinary/bonus manifests, injury/recruitment outcomes, handover status, population accounting, patient creation/completion, recovery deadlines, outcome history, existing physical cargo and mixed-stack removal history. Loading restores facts and deadlines, not new rolls or relative wait resets. Continue after victory preserves first-completion time and all ongoing systems.

Recommend next unused schema **11** if still available. Confirm New Run for older schema or incompatible content; preserve older files. No migration or backward-compatibility framework. Validate exact item identities/owners/terminal receipts, full support history, ordinary versus bonus budgets, finite timings, lane math, original-member limits, population/recovery conservation and receiving FIFO. Do not remove schema-10 mixed-stack reconstruction checks merely to accept the new outcomes.

Test mathematical rules directly; do not use a statistical claim to cover a wrong formula. Small deterministic seeded samples can supplement exact tests, not become a new balance research project. Native tests must include real full-catalogue generated cargo and original production pickup/contribution/dispatch paths. Label forced outcome fixtures, controlled positioning and clock advances honestly.

## 14. Documentation and targeted decommissioning

Update owning GDD/MVP Word sections and generate their Markdown before claiming new current design. Update VDD only where presentation descriptions change; do not turn unresolved geometry into a scene instruction. Reconcile current state, README, Codex bootstrap and current conversation bootstrap with intended/implemented/pending distinctions. Keep prior accepted milestones and review evidence intact.

Explicitly retire active assumptions that Food adds capacity, Medical is a loadout lane, loot is restricted to 16 definitions or minimum Bulk two, duration is always 90–180 seconds, personnel always total the initial eight, all original crew return healthy, or bonus cargo must fit ordinary capacity. The current counterpart of `expedition_test_config.gd` should become a real provisional Expedition configuration, not a production switch back to the old fixture. Retain small test fixtures only where they test a current invariant.

Audit actual references before deleting. Reuse the shared contribution request, exact-item carrying transaction, identity allocator, active timeline, Receiving/admission and save service. Historical M4 daily semantics remain archived, not restored. Old survival Medical death/stage code is not a shortcut for the new recovery owner. Record already-retired, reused, refactored, removed and historical dispositions without a deletion quota.

No source-data blanket rewrite. Fedora stays 0.897 / 3×3×1 / 2 Bulk. Mystery Meat Large stays unchanged. The supplied workbook's alternate capacity comparisons remain historical decision support; current-facing configuration records 23 as selected. No further extreme catalogue or presentation tuning in this milestone.

## 15. Completion boundary and technical defaults

The result is a local playable candidate, documentation aligned, affected tests and one consolidated review complete, ready for developer playtest. No automatic human promotion, merge, push or next milestone.

Technical/default choices, distinct from developer-authored balance: retain initial eight Ready, existing seed stock and six-Utility goal; retain development destination labels; add the bounded read-only Medical view rather than treatment; next unused schema; separate outcome randomness; current safe preparation rejection for deferred extremes. Verify these against the published starting tree and document actual differences. Do not treat an implementation default as permanently locked design.

## Evidence and provenance

- Developer's conversation decisions: five lane formulas and ceilings; 23 Bulk; 22/35%/105 player/Kitchen changes; catalogue acquisition; Food lottery; independent personnel outcomes; handover recovery; deferred extremes.
- `references/Receiving_Fedora_Adoption_Result.md` in the handoff package: local adoption at `ed521a2`, exact Fedora row, native 49-item transfer, controlled Fedora continuation, reconciliation and retained limits.
- `references/Expedition_Loadout_Assessment_v0.2.xlsx`: catalogue/loadout decision support after Fedora adoption; unchanged bytes from developer attachment. It is not the runtime catalogue or an implementation acceptance report.
- Repository `docs/testing/2026-11-08-expedition-to-storage-loop-result.md`, `2026-11-11-dispatch-no-ready-repair-result.md`, `2026-11-11-fuel-reserve-emergency-freight-result.md`, and `2026-11-13-receiving-mixed-stacking-result.md`: accepted preceding scopes. Resolve their actual local paths/links and reuse only relevant sections.
- Remote source read at `57b217d39c23f1bc3147ff8b78d7808b3add8eed`: current operations/loadout/config, snapshot, timeline and entry points. The unpublished adoption successor was not inspected in this chat; the executor must use the verified published successor, not that old anchor.
