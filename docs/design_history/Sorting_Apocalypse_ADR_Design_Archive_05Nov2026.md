# Sorting Apocalypse — Accumulation–Drawdown–Recovery Design Archive

**Date:** 5 November 2026  
**Status:** HISTORICAL / PARKED — preserved design exploration, not current gameplay authority  
**Origin:** Design discussion following M4 human promotion and publication at `c9f9417a97cf65ef416c58189ca1f741b6a90406`.  
**Purpose:** Preserve motivations, decisions, proposals, design implications and unresolved questions for deliberate future reuse (including a possible survival mode). The subsequent collection-and-organization pivot supersedes this direction as the intended main game.

## 1. Why this design was explored

The M4 prototype validated bounded mechanics: selected-item five-lane expedition provisioning, Bulk and capped Utility, irreversible submission, UI, timing, ordinary continuation and report behavior. It did **not** validate actual expedition returns, injury/recruitment/population consequences, a complete survival economy or the desired hoarding experience. In one normal-speed playtest, the developer fully provisioned and dispatched all four teams before cutoff, but only narrowly; afterward, shelves were nearly empty. That particular run completed meals, but its Medical request was unfilled. The early scripted delivery, unfamiliar stock, and interface friction were material confounders.

The central design tension was that significant resident stock was needed to make organizing and hoarding satisfying, yet an always-scarce survival economy continuously removed possessions. Increasing incoming loot risked trivializing daily survival, while increasing consumption emptied shelves and marginalized storage. The accumulation–drawdown–recovery proposal attempted to replace a flat pressure baseline with changing conditions, without forcing every player onto the same inventory curve.

This archive records the substantial later discussion; it should not be mistaken for an approved event director, implemented feature, or finalized balancing specification.

## 2. Proposed experience and principles

The intended rhythm was **accumulate useful reserves → experience a difficult spell of drawdown → recover and rebuild → face further unevenly shaped pressure**. This was intended across the experience, with especially careful opening curation and distinct later-run pacing. It was not a prescribed sine wave, equal-length calendar, fixed catastrophe interval, hidden inventory correction, guaranteed difficulty escalation or predetermined point of failure.

### 2.1 First accumulation

- New players receive a relatively low-risk opportunity to learn handling, requests, expeditions, and their preferred approach. Neat organization, messy accumulation, request-proximity arrangement, material conservation, and time efficiency were all valid styles to discover.
- Returning players receive a calm-before-the-storm period to establish a known strategy, recognizing that a more difficult spell is coming.
- The **primary aim is building useful stock**, not perfect shelf organization. Organization should help but should not chiefly decide first-drawdown survival; early upgrades are tertiary and mostly a min-maxing edge.
- Competent but imperfect preparation should make survival of the **first** drawdown very likely. Repeated waste, poor provisioning, missed obligations, excessive incineration/salvaging and neglected planning could still cause failure or a lasting spiral.
- Good preparation must be interpreted broadly; neither mathematically perfect contributions nor a prescribed organizational layout is required.

### 2.2 First drawdown

The user favored **reduced useful incoming supply as the principal pressure**, rather than predominantly increasing consumption. Reduced supply tests the reserve built during accumulation and permits the player to keep fulfilling ordinary obligations. Category-specific reductions matter more than the raw number of possessions or filled shelves. Shortage can coexist with continued arrivals and receiving work; no single category need disappear completely.

The early drawdown was to demonstrate more than one form of pressure, but not necessarily combine every worst-case event. It needed to leave meaningful decisions during the lean spell and reward preparation without becoming an entirely predetermined outcome.

### 2.3 Later accumulations and recovery

The second accumulation is simultaneously an opportunity to rebuild supplies and repair earlier damage. Most ordinary surviving players were expected to end it **worse off than at the first accumulation peak**, without a dynamic system that checks their inventory and artificially pushes it toward a target. Possible carryover disadvantages included materially lower stocks in several categories, fewer surviving scavengers, more patients and treatment backlog, and few upgrades.

Those disadvantages compound: a smaller Ready workforce can gather less, a Medical shortage can prolong unavailability, and missed upgrades can slow later development. A careful experienced player could recover fully, build all upgrades, fill shelves and potentially survive indefinitely. Those successes were not to be countered automatically by extra punishments.

An important balance caveat was that fewer dispatchable scavengers also consume fewer expedition provisions; the net productive loss matters more than gross headcount alone. Recovery is an improvement in conditions and a chance for the player to act, **not** necessarily a rescue grant.

## 3. External and internal event palette (historical proposals)

The unseen outside world and deeper bunker would be inferred through reports, requests and returned objects. No playable exterior, visible refugees, combat, or populated institutional interiors were proposed. Gameplay merit was to govern an event's actual effects; the fiction provides a convincing broad explanation rather than a literal simulation.

### 3.1 External conditions

| Fictional event | Potential mechanical consequences | Boundaries and caveats |
|---|---|---|
| Roaming zombie hordes | More Weapons/Protection needs, injury risk, or blocked access | Multiple severe modifiers together can become excessive; select effects deliberately. |
| Heatwave | Higher Hydration requirements and/or changed demand | Extra loadout Bulk can itself reduce room for loot. |
| Routes or facilities inaccessible | Temporarily unavailable destination combinations or reduced category access | Leave overlapping alternative supply sources where intended. |
| Dangerous weather or radiation | Elevated risk or, extremely, no dispatch for a whole day | At-home meal accounting and saved loadout expense must be considered. |
| Raiders / depleted sites | Lower loot amount or cargo abandoned before return | Do not remove already delivered/organized items. |
| Temporary illness/weakness | Decreased team capacity or readiness | Must define whether effects attach to individuals, team slots or route conditions. |
| Lost/delayed expedition | One- or multi-day delay in return and crew availability | Would expand the same-day team model; retained only as a future possibility. |

### 3.2 Internal conditions

| Fictional event | Potential mechanics | Open issue |
|---|---|---|
| Temporary refugees | Increased Food/Hydration use | Ordinary Kitchen request versus separate full-day obligation. |
| Administrator repair/expansion | Extra Fuel/Electronics demand | Mandatory maintenance versus optional project investment. |
| Community illness outbreak | Extra Medical demand | Do not silently create fictional scavenger patients or misreport Ready forecasts. |
| Celebration/milestone | Extra Morale request | Preference was for an optional or lower-stakes positive occasion. |
| Water-treatment maintenance, cold spell | Category-specific pressure | Choose actual consumers on gameplay grounds. |
| Restored road/new stockpile | Temporary better access or richer returns | Useful favorable-period fiction. |

The event catalogue remained open and expansive. No comprehensive event roster, numerical modifier or global scheduler was approved.

## 4. Messaging, forecasting, and information history

- Outside event effects apply in **whole-day increments**. They do not begin or stop at random hours during the day. Event-driven bunker requests were also favored as full-day opportunities rather than three-hour scrambles.
- Signals may precede events by scout reports, returning expeditions, Administrator announcements, monitoring equipment or Medical staff warnings. Most warnings should enable a reasonable educated guess without displaying numerical modifiers or guaranteeing an exact date or outcome.
- Once conditions are active, concrete choices and current requirements should be legible **before** the player commits. A closed destination must be visibly closed; a current request must show the actual requirement.
- The midnight report was proposed to gain a **“Day N+1” tab** describing conditions becoming active, continuing or ending on the prepared next day. The report aggregates already existing information and does not generate events or retroactively become the first warning source.
- A diegetic Journal at or near the sorting workstation was proposed to preserve daily records, received reports, warnings, current and upcoming events and aggregate history. Records should preserve **what was actually known at the time**; later confirmations and revisions should be associated, not silently rewritten into earlier warnings.
- Optional Electronics improvements could provide aggregated trends, categories, comparisons and richer display, but never withhold baseline knowledge necessary for competent play.

## 5. Affinity destination design developed during the pacing discussion

The discussion shifted from named individual locations to **repeatable destination archetypes**. There would be no playable map, no geography/depletion simulation, no bespoke routine travel time, danger or backstory per location. Category choice would drive the selector; a thin fictional destination name would explain the resource combination. All eight item categories were in scope: **Electronics, Food, Fuel, Hydration, Medical, Morale, Protection, Weapons**.

The current preference at the point of parking was **two distinct, unordered, non-repeating affinities per archetype**, giving **28 pairings** (`8 choose 2`). This was favored over three unordered affinities (56), repeated pairs (36), and ordered Primary/Secondary pairs (56); exact format remained subject to testing. Each affinity should provide the **same mathematical bonus**, not guaranteed equal category returns in every haul. The user leaned strongly toward assessing bonuses in expected received **Utility**, with noticeable outcomes over comparable runs. All categories could still appear as incidental loot; an affinity did not raise team capacity, guarantee particular items, modify an item's authored Utility/Bulk, or forbid off-affinity categories.

A unified **Item Category** was explicitly decided for the intended first release: no dual- or multi-use items. Earlier vodka-style context-dependent examples were superseded. Item values remain stable; event boons and penalties change acquisition or demand rather than individual definitions.

### 5.1 Selection, reservation, and dispatch proposals

- A broad team-preparation panel with team tabs was proposed; current five loadout lanes and all existing relevant information would remain present.
- Eight affinity icons in a fixed alphabetical 2×4 layout; selecting both uniquely identifies one archetype. Availability of the second icon is filtered by the selected first and by unavailable/taken combinations. Disabled choices show explanations.
- Selecting both affinities **reserves** that specific destination for the waiting team until reassigned or dispatched. The reservation is editable; other teams cannot take it meanwhile.
- Fully provisioning a team does **not** auto-dispatch it. A deliberate Dispatch click allows players to provision multiple teams first and then assign scarce destination pairs based on their actual loadouts.
- When a team explicitly or automatically dispatches with one affinity, the system attempts a random valid destination containing it; if none remains, fallback to full-random among valid destinations. With no affinity, selection is full-random. A warning popup was proposed for manual incomplete selection; the cutoff would process teams in cardinal order, without popups.
- A first-item **departure-opportunity reservation** was explored to prevent stranded submitted supplies. It was rejected as too cognitively complex for casual players, despite mechanical soundness.
- Instead, one repeatable **General Scavenging** destination without affinities or a daily cap was preferred as an exhaustion fallback. Normal risk, provision and capacity rules apply; it should not automatically compensate for shortages. A complete outside shutdown still prevents all departures.
- During the survival-era design, a one-team-per-destination **per day** cap was approved to stop all teams stacking onto the same remaining source. This cap was later **superseded by the collection-focused pivot**, which favors one **concurrent** team per destination.

### 5.2 First drawdown availability rule

The user proposed a constrained catalogue in which **each category appears in exactly two open affinity destinations**. That is mathematically possible and results in **eight open pairings**: eight categories × two occurrences / two occurrences per pair = eight destinations. General Scavenging remains separately open under that historical plan. The exact eight pairings and their relative balance were not finalized.

## 6. Tentative opening sequence (never balanced or implemented)

| Day | Proposed condition | Purpose |
|---|---|---|
| Day 1 | Initial stock approximately covers two days of normal obligations and full expedition provisioning, **without any incoming loot**. Opening workforce possibly 10–12 scavengers / three teams. | Protect early experimentation and provide material to sort. |
| Day 2 | Richer expedition returns in Utility per Bulk; first foreshadowing warnings. | Encourage purposeful provisioning and accumulation; announce risk in time to react. |
| Day 3 | Richer returns continue; modest consumption reduction begins; full affinity catalogue remains accessible. | Last especially productive preparation opportunity. |
| Day 4 | Drawdown starts: exactly two destinations per affinity category and smaller expedition hauls. Consumption reduction still cushions the transition. | Player encounters restrictions; impact on delivered stock is delayed until return. |
| Day 5 onward | Ordinary consumption resumes; prior reduced arrivals now support current demands. | The reserve begins carrying more of the economic burden. |

These dates and modifiers were **thinking-aloud balancing candidates** only. Starting stock was to be an approximate sensible bundle, not a perfect guarantee across every random patient outcome. Richer loot would change the selected item mix, **not** item Utility or Bulk. Short qualitative narrative messages logged by the Journal would explain the circumstances without disclosing exact numerical multipliers.

If useful, simple calculations and/or repeated automatic simulations could estimate starting category budgets and the sensitivity of the first sequence to loadout efficiency, whole-item waste and Medical variation. Such models would narrow candidate ranges but would not replace human sorting/handling playtests.

The duration and ending of the first drawdown, nature and length of the following recovery, and variation across subsequent periods **were not finalized**.

## 7. Failure condition considered during this historical branch

The survival design was refined conceptually from “everyone dead” to **no scavengers able to expeditions and no established route to restore a dispatchable scavenger**. This included the possible all-Light-injured/no-Medical deadlock, after checking ordinary pending expedition returns, already-supplied treatment, recruitment and other established recovery routes. Untreated Light injury worsening into Severe remained an independent optional mechanic, not a patch required merely to make game over occur.

**This failure framework is not current** after the main-game pivot to no terminal failure and an always-available route toward the collection objective.

## 8. Clock acceleration considered, then set aside

The survival-period discussion provisionally favored 1× / 2× / 3× game-clock speeds, with normal-speed first-person movement and physical handling, paused screens unaffected, and possible automatic slowdowns on significant actionable events such as loot arrival. It was intended to address the uneven workload of fixed-length days, **not** as an animation-speed increase.

The subsequent removal of the day/night cycle made that workaround unnecessary as the initial direction. The collection pivot explicitly **sets time acceleration aside**.

## 9. Unresolved questions at parking

The most important incomplete topics were: the exact economics of first drawdown and recovery; category-specific expected supply under closures and the General fallback; the end and unwinding of concurrent restrictions; recovery's practical opportunities for a battered workforce; event cadence/overlap/warning lead time; detailed request consequences for refugee/illness/repair events; population/recruitment and upgrades; final item probabilities, numerical Utility/Bulk targets and expected player experience. No fixed first-drawdown duration, numerical difficulty curve, automated director, final event pool or broader M5 testing scope was authorized.

## 10. Reuse and authority safeguards

This archive is a record of a **parked alternative**. Do not treat it as a current GDD, restore daily timetables into the collection-focused game, reactivate death/game-over, reintroduce destination-closure events, reinstate the daily destination cap or implement this first-five-days scenario without a new developer decision. Selected ideas (two-affinity archetypes, narrative reports, Journal, physical economy, Utility/Bulk distinction) may have been independently retained or changed by the later pivot. In such cases the **later pivot and subsequent successor GDD** control the current interpretation.

Reference baseline: M1–M4 human-promoted/published/closed at `c9f9417`; GDD v0.15 and Systems MVP v0.5 were the then-current written authorities. Their historical design and accepted code evidence remain intact, despite the later game-goal revision.
