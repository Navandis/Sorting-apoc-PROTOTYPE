# Sorting Apocalypse — Collection & Organization Design Pivot

**Date:** 5 November 2026  
**Status:** CURRENT DESIGN DIRECTION / TRANSITION RECORD — substantive agreed direction with unresolved replacement mechanics and provisional balance. Not an implemented or published GDD.  
**Reference implementation:** M1–M4 human-promoted/published/closed at `c9f9417a97cf65ef416c58189ca1f741b6a90406` in their bounded scopes. Actual expedition returns and population consequences remain unimplemented.

## 1. Executive decision and reason for the pivot

The developer is deliberately redirecting Sorting Apocalypse from an **endless survival/day-count game** to a **finite, replayable collection, hoarding and spatial-organizing game**. The previous fundamental success metric (“survive as many days as possible”) and terminal failure (“no scavengers remain”) gradually transformed supporting systems into the dominant experience. Demand, casualties and deadlines repeatedly consumed the possessions that were supposed to give sorting, hoarding, space planning and salvaging their appeal.

The day/night structure introduced artificial preparation windows, forced returns, midnight forfeiture and an increasingly difficult schedule/time-speed balance. The recently explored accumulation–drawdown–recovery cycle was a proposed repair of this underlying tension; it is now parked rather than continued into implementation.

**New north star:** acquire, physically store, select, organize and hoard enough useful loot to meet clear category goals as quickly as the player can. The unseen bunker and expedition logistics are supporting supply faucets, material sinks and interesting constraints; they must not become a separate survival simulator.

The GDD and VDD are explicitly open to revision for this pivot. This is **not** a clean slate: accepted physical item/stacking/storage/Receiving work, environmental identity and many shared transactions remain valuable. The historical implementation remains accurate evidence even where its gameplay rules are no longer intended for release.

## 2. The victory condition

The proposed collection objective is **a simultaneous live stored-Utility threshold in each of the eight categories**: Electronics, Food, Fuel, Hydration, Medical, Morale, Protection, Weapons. The illustrative number is **2,000 Utility per category**, strictly a placeholder to be measured and tuned.

### Qualifying stock

- Only physically stored items on **valid player storage implementations** count. Items on the sorting table, carried by the player, in inventory, in the Receiving lift, or in returning-crew commitments do not count.
- All eight category totals must meet their thresholds **at the same moment**. Reaching a category target does *not* permanently complete it; subsequent expenditure that drops the category below target reverses its current completion status.
- When the live condition is met, victory is immediate, with no extra hold period. No additional victory conditions are imposed for outstanding requests, pending freight, items carried or unsorted items elsewhere.
- After recording a completion time, the player may continue organizing or begin a new run to improve their time.
- Item Category should be unified across gameplay: **no dual-/multi-use item-category conversion in the intended first release**. The early context-dependent vodka example is superseded.

It is **desirable** that some categories have higher sinks than others. For instance, Morale may reach its target earlier and more easily than Food. This creates the central allocation problem: the player must balance uneven accumulation toward equal category end targets rather than have every category behave identically.

### Performance measure

The win time measures **real-world elapsed active run time**, not in-game days. ESC, main menu, application not running, and the paused zoning editor stop the relevant timer. The expedition preparation panel is **tentatively unpaused** under the continuous flow; a pause may be reconsidered if actual use consumes too much time. Real-world active time continues during ordinary handling, physical walking and unpaused gameplay interfaces. No 2×/3× time acceleration is currently planned.

The exact presentation of timer, post-victory record, new-run comparisons and pause edge cases remains future UI/detail design.

## 3. Storage is the central scarce resource

The target collection should be physically substantial. The developer's rough desired experience for an average winning run is around **80% of available storage occupied**; this is **not** a second win condition, exact limit, verified catalogue ratio or geometric packing requirement. The goal is to feel like a serious hoard while retaining sufficient working room for rearrangement and retrieval.

Good organization and careful item selection should allow a collection that an undisciplined pile-up might fail to accommodate. The game should **not** become a precision-only packing puzzle that demands near-optimal placement or pixel-perfect geometry. Bulk, authored Utility and spatial Footprint remain three different properties: high-Bulk or large-Footprint objects need not be proportionally valuable, and objects attractive to carry may be poor to store.

The resulting desired choice is often whether to retain, consume, repurpose, salvage or incinerate a legitimate item because of its opportunity cost in space. The game has no default category of useless “junk.” Its utility can be low, but its retention/disposal is a player decision.

**Storage capacity upgrades are now disfavored:** the likely direction is to expose all valid storage installations from the start, so players can learn and optimize their use of a fixed physical environment. Exact total capacity, furniture placement, item-stat balancing and production storage catalogue remain to be validated. Player carrying, expedition and Electronics/information upgrades may still exist.

## 4. Continuous flow replaces the day/night calendar

- **No daily cycle or automatic midnight resolution** is intended in the new main game. There is no synchronized morning dispatch window, “teams must return by midnight,” or imposed nightly end-of-day report.
- The player decides whether and when to prepare and dispatch available teams; teams and return events progress independently.
- Expeditions should generally be **much shorter** than in the survival design, creating an active flow of physical loot and frequent opportunities for sorting.
- Request timing/consequences, treatment, upgrades and production must be re-expressed without daily windows, next-day effects or night-only transitions.
- The game should feel alert and often busy, with overlapping activities, but not so constantly interrupted that it removes the player's opportunity to sort and organize. Player choices about dispatch number and timing should meaningfully influence workload.
- The previously proposed 2×/3× in-game clock speed is **set aside** as a workaround for the removed fixed-day scheduling problem.

The exact general time source and event cadence remain technical design questions. This record does not authorize a new scheduler or refactor by implication.

## 5. Expedition system: free team sizes and repeatable destinations

### 5.1 Player-controlled preparation and teams

The player chooses team composition from available scavengers, within a proposed **1–4 members per team**. If four scavengers are available, the player can choose a team of three and another of one, rather than receiving automatically formed teams. Loadout targets and raw carrying capacity continue scaling with assigned members; submitted whole items are consumed on dispatch and use Bulk, while return capacity is raw capacity less outgoing Bulk.

The five provisioning lanes (Food, Hydration, Medical, Weapons, Protection) and the principle that preparation affects expedition efficiency can be retained and retuned. Expedition duration is a balancing lever, including a possible larger-team speed benefit, **not** an approved rule. Per-member capacity and return quantities may be increased if that helps the physical collection objective, but extra loot must still be handled and stored.

No routine death/fatality system is currently favored; injured scavengers are expected to remain capable of recovery, without creating a terminal expedition dead end. Exact treatment and injury mechanics remain open.

### 5.2 Affinity destinations

The preferred archetype model is **two distinct unordered affinities** chosen from the eight categories, producing **28 named archetypes**. A pair selects its unique destination. Affinities make their category returns measurably more likely/useful in terms of acquired Utility over comparable runs, with the same mathematical bonus for both selected categories, but neither guarantees particular loot nor excludes other item types. They do not alter team capacity or item definitions.

All archetypes remain repeatable without finite loot depletion, lifetime visit caps or individually simulated geography. No bespoke ordinary danger, long travel time, location story or hazard modifier is required per destination. A named place serves as a light fictional wrapper around the resource choice; no visual exterior map is necessary.

A destination may serve **one team concurrently**, rather than one team per day. The earlier availability-event system, the daily destination restriction and a generic no-affinity destination are **disfavored or no longer needed** under the collection pivot. Exact selection/reservation and release moments remain to be specified so that the player always understands where a team can be sent.

### 5.3 Expedition panel

A broad shared Expeditions panel, with a per-team tab and both **all current loadout details** and a two-row/four-column affinity icon selector, remains the preferred direction. Icons appear alphabetically; selecting the second filters unavailable pairs, with clear explanations for unselectable destinations. Complete destination selection reserves that location for the waiting team until choice changes or dispatch occurs.

The full loadout is shown within the same panel. The player deliberately clicks Dispatch; filling 100% does not automatically depart a team. The previously favored paused menu is **tentatively no longer paused** because there is no fixed morning deadline; playtesting may revisit this. Earlier incomplete-affinity random fallback discussion was developed in the day-cycle context, and its exact relevance must be reassessed under voluntary continuous dispatch rather than silently adopted.

## 6. Receiving and queue pressure

The accepted Receiving system has one physically active load and two deposited FIFO positions, with an upstream `Awaiting Lift` owner. The old rule forfeiting pending returns at midnight is incompatible with the pivot.

**Preferred replacement:** an effectively **uncapped upstream queue of returning expeditions**, without cargo destruction or an abandonment timer. Teams with cargo waiting to be handed off remain occupied and cannot leave on another expedition. Thus congestion costs throughput and completion time, directly rewarding prompt unloading and a well-organized receiving/storage flow. Queued stock does not advance stored-category victory until the actual physical items reach valid storage.

Preserve the separation between unbounded **pending team/haul records** and the existing finite **deposited** physical lift capacity. Do not enlarge the lift or invent hidden cargo admission capacity merely to support this queue. Exact handover and release timing still need definition: whether crew availability returns on cargo admission, after lift handover or at another clear lifecycle point. Physical item identity and exact committed haul content survive the entire chain; Receiving must not reroll or quietly discard cargo.

A large backlog is acceptable if it is the consequence of player workload choices; it is not a death state. No hard deadline forces unloading, but tied-up teams provide substantial incentive.

## 7. Requests and bunker departments: supporting acquisition

Requests remain useful as physical sinks, providing reasons to retrieve, spend and reconsider stock. But their primary function is now to support **the player's speed and efficiency of accumulation**, not to threaten survival or directly control the victory condition.

The direction under discussion is requests **without ordinary short expiry windows**, whose adverse effects start after a modest grace/wind-up interval and persist until properly addressed. A brief postponement to finish sorting should be legitimate. Permanent neglect must not become the best strategy. A potentially unlimited request backlog or unbounded compounded penalty is **not approved**: escalating costs should be bounded and legible, with a manageable outstanding workload and a clear way to restore normal effectiveness.

The practical tradeoff is: spend current qualifying stock to recover conditions that produce or move new stock faster. Some endgame choices may deliberately ignore a request to reach victory; fulfilling all requests is **not** an additional winning requirement.

All current departmental consequences require systematic reconsideration because many assume midnight, next-day application, discrete meal windows, population mortality or indefinite day-based survival. The original physical one-item selected submission, irreversible transfer, capped credit and persistent state ownership remain useful, though individual request grammar/stacking must be redesigned.

Possible revised services:

| Facility | Likely retained role | Open design work |
|---|---|---|
| Kitchen | Food/Hydration sink and possible ration compacting | Continuous request model, effects and conversion/output timing. |
| Medical | Spend Medical to restore injured crew faster | Natural untreated recovery, accelerated treatment and fair non-dead-end rules. |
| Bunker Ops | Fuel/Electronics/Morale sinks | Operational effects that make speed/throughput worse when ignored, without sabotaging core sorting. |
| Workshop | Optional investment in lasting capability | New project roster/costs/timing, no nightly resolution. |
| Salvager | Convert poor-space-ROI objects into useful physical outputs | Re-evaluate yields, utility and space tradeoffs. |
| Incinerator | Irreversibly free scarce storage | Access/unlock and role under new collection goal. |

The desired penalties should be materially costly to ignore but not lock out the only acquisition or recovery route. There is **no compensating catch-up grant** and no requirement to make poor runs recover quickly; a player may choose to restart an inefficient run. They must not be trapped in a logically impossible progression state caused by routine allowed decisions or unfair random consequences.

## 8. Injury, population and progress without a failure state

The main game will have **no formal failure condition**. In particular, no progression state should leave all scavengers unavailable forever with no route toward new supplies and the goal. Injury should cost real time and expedition throughput. An explicitly favored simple approach is: untreated injured scavengers eventually recover at a slower natural rate; Medical contributions substantially accelerate their return to duty.

The developer is **disinclined** to allow injured scavengers to keep departing. That would require re-injury rules, modified capacity and additional simulation complexity that does not support the collection focus. Fatality is likely to be removed, but the exact treatment states, restoration timelines and personnel acquisition model remain open.

“Not dead-ended” is **not** the same as guaranteed quick recovery. If an inefficient run takes a very long time to restore, abandoning it and starting again is a legitimate player choice. Do not add adaptive rescue or automatic replenishment merely to accelerate bad play.

## 9. Player information, UI and spatial scope

- Baseline **live goal progress** across all eight categories must remain visible or readily available. It cannot be gated behind upgrades or disabled by events/penalties.
- The bunker remains a **safe haven**. Outside threats and offscreen residents are inferred through goods, messages and outcomes; no visible NPC simulation, combat or exterior world is implied.
- Spatial compression is an explicit future investigation, especially long corridors, because real-time completion rewards handling rather than commuting. No dimension change or scene edit is authorized by this observation.
- All shelves and suitable storage implements are likely present from the beginning. Existing layout, exact installed capacity, labels, zoning and ergonomics remain authoring/validation matters rather than automatically resolved target capacity.
- The Journal/monitor concepts, baseline alerting and optional information tools can be reconsidered for the new continuous flow; remove the day-specific report assumptions rather than preserving a nominal “Day+1” tab without days.
- Pauses: ESC menu, launch/main menu, game closed/not running and zoning editor pause the completion timer. The expedition panel is provisionally unpaused. No generic time-acceleration feature is currently intended.

## 10. What is settled, tentative, and open

| Area | Status as of this discussion | Important boundary |
|---|---|---|
| Collection-focused finite victory; live simultaneous eight-category stock | **Developer direction / chosen conceptual objective** | Numeric threshold 2,000 each is illustrative. |
| No formal game failure / no day-night cycle | **Developer pivot direction** | Existing M4 runtime still implements days and deadlines. |
| Target ~80% storage occupancy at average win | **Rough experiential aspiration** | Not a score rule or validated capacity model. |
| Player-chosen expedition sizes (1–4), asynchronous departures | **Strong direction** | Exact population/readiness lifecycle remains to design. |
| Two unordered unique affinities, 28 locations | **Preferred design under testing** | Exact sampling bonuses and UI tuning open. |
| One concurrent team per destination | **Preferred replacement rule** | Lock/unlock lifecycle open; no depletion. |
| Uncapped waiting returns; crew unavailable while queued | **Favored direction** | Exact team release point open. |
| No routine cargo loss from queue | **Strong preference** | Physical deposited queue still finite. |
| Persistent requests with bounded escalation | **Agreed high-level design approach** | Individual rules, cap, grace, penalties open. |
| Natural slow injury recovery, faster with Medical | **Favored simple option** | No full treatment system approved. |
| All storage initially accessible | **Likely direction** | Current installed physical total not certified adequate. |
| Expedition menu unpaused | **Tentative** | Revisit by playtesting. |
| Clock acceleration | **Set aside** | No current design obligation. |
| Parked ADR cycle | **Historical / not current** | Preserve record separately for possible survival mode. |

Every number and candidate mechanic remains subject to human playtesting. An unanswered replacement may **not** silently inherit the old survival-era behavior.

## 11. Documentation recommendation for AI workflows

### 11.1 Successor, not a short override

Create **Preliminary GDD v0.16** (provisional edition label) as a **full consolidated successor** to v0.15. Preserve v0.15 unchanged as historical survival-era design. The new GDD must directly describe the intended current game section by section: new objective, continuous progression, storage, expedition/queue, requests, departments, injuries, progression, interface, world limits, scope and validation. Carry over the applicable implementation-relevant details of physical handling, deterministic storage, immutable ItemInstances, Receiving presentation and human spatial authoring. Do not shrink it to a one-page concept or force AI workers to reconcile old daily rules with a front-page override.

For each owning section: classify previous content as **retained, revised, superseded, historical only, or unresolved**. Preserve rationale and alternative status, not only a verdict. If a replacement mechanic is open, record it explicitly rather than transplanting the old rule as a default.

### 11.2 Other documents and exact status separation

- **Systems MVP v0.5:** keep the accepted M1–M4 evidence as truth about the *implemented historical prototype*. Later status/roadmap sections must point to the pivot and stop treating the survival economy/M5 as the automatically next game design.
- **VDD v0.11:** retain the safe-haven world grammar, Receiving visual acceptance, source/material authority, and human-authored work. Reconcile later spatial geometry or storage-upgrade descriptions only as justified by actual approved pivot design; no speculative remodeling.
- **Prototype Findings v0.14:** preserve historical evidence. Do not reactivate it as current progress authority.
- **ADR Design Archive:** preserve as explicitly parked alternative and possible survival-mode source, not as a second current GDD.
- **Operational routing** (`docs/README.md`, `docs/CURRENT_STATE.md`, `docs/CODEX_BOOTSTRAP.md`, conversation bootstrap): update authority links, current design status and next-work boundary **after** the successor is reviewed/approved. Historical dated records remain unchanged.

M4 is **human-promoted, published and closed** at `c9f9417`. It requires no repeated acceptance audit or re-publication. Nothing in this discussion authorizes implementation, new testing milestones, history rewrite, asset deletion, saved-scene edits or Git publication. The previously planned M5 combined scenario is not to proceed unchanged against obsolete survival assumptions; subsequent validation work must be re-scoped deliberately.

### 11.3 Practical documentation transition

1. Preserve this pivot record and the separate parked ADR archive.
2. Build the consolidated successor GDD from the old master's applicable sections plus the new decisions, marking truly unresolved replacements.
3. Reconcile the MVP's *forward-looking* narrative and VDD touchpoints without falsifying historical tests or altering accepted art.
4. Update current-state/index/bootstrap pointers so fresh AI sessions see exactly one current gameplay authority and accurate implementation status.
5. Run focused semantic cross-reference and DOCX/Markdown parity/layout QA; do not rerun unrelated game suites for documentation-only work.
6. Review and approve publication separately. Do not assume that documentation drafting alone changes the repository.

## 12. Working priority after this record

The near-term design task is to develop a **small representative continuous acquisition–receiving–sorting–storage–service sequence** that confirms the new central promise. In particular, we need a request-pressure model that rewards servicing the bunker without converting the player's session into endless department chores, and a return/crew lifecycle that lets congestion cost time without losing committed goods. That work precedes any new Codex implementation brief.

**Final rule:** the current direction is a timed collection-and-organization game, not an endless survival simulator. Preserve the accepted physical foundation, maintain historical evidence honestly, and make unresolved post-pivot mechanics explicitly open.
