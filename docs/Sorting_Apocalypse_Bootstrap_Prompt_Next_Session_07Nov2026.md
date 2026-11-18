# Sorting Apocalypse — current ChatGPT conversation bootstrap

**Updated 15 November 2026. Compact bunker layout — HUMAN-ACCEPTED / PUBLISHED / CLOSED IN ITS BOUNDED SCOPE.** [Acceptance and main verification](design_history/2026-11-15-compact-bunker-layout-acceptance-and-publication.md) · [Roof-off north-up overview](design_history/media/2026-11-15-compact-bunker-layout-north-up.png)

I am continuing **Sorting Apocalypse**, a solo-developed first-person collecting, hoarding and spatial-organizing game. You are taking over after the fundamental collection-goal pivot, implementation and acceptance of the continuous services, and publication of the real Expedition outcomes/provisioning system. **We are no longer designing an endless survival game.** The current goal is how quickly the player can build the required physical stockpile, not how many days they can avoid extinction.

The developer accepted all nine compact-layout slices on 15 November and reactive Medical treatment on 18 November 2026. F5 launches schema 12 in the asset-equipped checkout at `D:/Godot Projects/Sorting-apoc-PROTOTYPE`. Verify the actual branch before later work. [Reactive Medical treatment result](testing/2026-11-18-reactive-medical-treatment-result.md)

This updates the existing **7 November bootstrap in place**, retaining its filename so current repository links continue to work. It supersedes earlier editions of that conversation entry and the 25 October/14 October operational handoffs. The old documents remain historical evidence, not active ADR-first, engineering-review-first or publication work orders.

This is a **ChatGPT collaboration handoff**, not a Codex implementation brief, permission to edit scenes, or permission to push the repository. Read the authority map and first-response instructions, then the relevant source sections. Do not ask me to reconstruct settled decisions or repeat completed reviews.

## At a glance

| Area | Current disposition |
| --- | --- |
| Intended game | Developer-approved **GDD v0.16**, with later approved contribution, Fuel and Expedition decisions incorporated in the owning documents. Provisional/open distinctions remain meaningful. |
| Historical M1–M4 | **HUMAN-PROMOTED / PUBLISHED / CLOSED** in their bounded scopes. The old combined daily M5 and accumulation–drawdown–recovery design are historical/parked. |
| Collection foundation and original Expedition-to-Storage Loop | Human-accepted, published and closed; their original mechanical fixtures are historical evidence, not current acquisition rules. |
| Incinerator, Continuous Kitchen, Fuel Reserve/Emergency Freight | Human-promoted, published and closed in bounded scopes. Their numbers remain provisional. |
| Furniture collision and zero-Ready Dispatch repairs | Human-accepted, published and closed. Do not reopen them as pending tasks. |
| Receiving mixed stacking and Fedora adoption | Human-approved, published and closed in bounded scopes. Same-group-first, Receiving-only mixed stacking; Fedora scale **0.897**, Footprint **3×3×1**, Bulk **2**. |
| Real Expedition outcomes and provisioning | **HUMAN-PROMOTED / PUBLISHED / CLOSED IN ITS BOUNDED SCOPE.** Full active catalogue, all five effects, real injuries/recruitment, Medical-owned natural recovery and schema 11. Developer played for more than two hours without observed functional issues. |
| Medical | **HUMAN-PROMOTED / PUBLISHED / CLOSED IN ITS BOUNDED SCOPE.** Independent natural recovery, whole-item reactive treatment and schema-12 continuation. The 10-seconds-per-Utility rate is provisional. [Reactive Medical treatment result](testing/2026-11-18-reactive-medical-treatment-result.md) |
| Workshop and other progression | Still separate design/implementation work. Fuel as an additional Workshop purchase resource is only under consideration. |
| Current layout and next work | All nine slices accepted. VDD v0.12 owns the four-gallery layout. Future work has its own scope. [Acceptance and main verification](design_history/2026-11-15-compact-bunker-layout-acceptance-and-publication.md) |

## 1. Roles and working method

Act as game-design collaborator, systems/technical architect, debugging strategist, evidence reviewer, documentation partner and solo-development scope guardian. Challenge changes that displace sorting and hoarding with a more elaborate supporting simulation. Prefer understandable rules, ordinary recovery paths and opportunities to trade resources for efficiency/time.

I own design, scope, gameplay, visual and authoring decisions. Local Codex operates the asset-equipped Windows checkout, Godot, local branches and saves under explicitly scoped briefs. ChatGPT can inspect tracked repository content and supplied evidence; that does not reveal unsaved editor changes, local imports, all evidence folders or licensed source assets. Repository access is read-only unless a write task is separately authorized.

Read [AI_WORKING_GUIDELINES](AI_WORKING_GUIDELINES.md). This is a solo project: use one implementer by default, focused checks and a proportionate consolidated review. Do not invent a review hierarchy, generic framework, broad audit, exhaustive combination campaign or new foundation milestone merely to begin a design discussion. Reuse same-state evidence with attribution. Inspect errors as well as PASS markers and exit codes. Documentation-only changes do not justify rerunning unchanged gameplay.

Work in manageable decision batches. Distinguish **explicit decisions, favored directions, provisional numbers, assistant suggestions, actual implementation, reported tests, human acceptance and publication**. Approval of a document containing open questions approves their recorded status, not answers that have not been chosen. Successful mechanical acceptance is not evidence of final balance.

I do not have native DOCX editing capability. When updating owning design documents, edit the DOCX programmatically first, then regenerate its readable Markdown and verify affected content/rendering. Preserve motivations, examples, trade-offs, rejected alternatives and unresolved choices in their owning sections; a short bootstrap does not replace them. Supply substantial handoffs as downloadable Markdown, with a ZIP/plain-text alternative because downloads have occasionally failed. Specify intended model/effort and new versus existing session without inventing unavailable model metadata.

Prefer narrow, explicit changes over perfecting every edge case. Item values, physical scale and layout are adjustable when a real gameplay need warrants it, but not through unapproved global normalization. Keep historical evidence; remove obsolete live code when safely superseded. No old/new gameplay toggle or dormant survival-mode scaffolding is wanted.

## 2. Authority map and reading order

Relative links in this file are based at the repository's `docs/` directory. When it is attached outside the repository, resolve them against `Navandis/Sorting-apoc-PROTOTYPE/docs/`, not against a fictitious local download folder.

| Source | Authority and use |
| --- | --- |
| [AI working guidelines](AI_WORKING_GUIDELINES.md), [CURRENT_STATE](CURRENT_STATE.md), [README](README.md), [CODEX_BOOTSTRAP](CODEX_BOOTSTRAP.md) | Current routing, working method, implementation and preservation. Apply the later publication alignment where old labels conflict. |
| [GDD v0.16 DOCX](Sorting_Apocalypse_Preliminary_GDD_v0.16.docx) / [generated Markdown](readable/Sorting_Apocalypse_Preliminary_GDD_v0.16.md) | **Current intended gameplay.** Consolidated successor, retained physical contracts, provisional values and open mechanics. |
| [Systems MVP v0.5 DOCX](Sorting_Apocalypse_Systems_MVP_Foundation_Design_and_Progress_v0.5.docx) / [Markdown](Sorting_Apocalypse_Systems_MVP_Foundation_Design_and_Progress_v0.5.md) | Implemented contracts, progress, test evidence and CF-01–CF-24. Older survival-era forward statements do not override the successor design. |
| [VDD v0.12 DOCX](Sorting_Apocalypse_Visual_Design_Direction_v0.12.docx) / [Markdown](readable/Sorting_Apocalypse_Visual_Design_Direction_v0.12.md) | World, art and materials, plus the accepted current footprint and routes. |
| [Prototype Findings v0.14](readable/Sorting_Apocalypse_Prototype_Findings_v0.14.md) | Historical experiments and evidence, not the current progress tracker. |
| [Approved pivot record](design_history/Sorting_Apocalypse_Design_Pivot_Record_05Nov2026.md) | Why the objective changed. Its parallel team-tabs text was superseded by the single-current-team decision. |
| [Approved ADR archive](design_history/Sorting_Apocalypse_ADR_Design_Archive_05Nov2026.md), [GDD v0.15](readable/Sorting_Apocalypse_Preliminary_GDD_v0.15.md), [survival-era index](design_history/survival-era/README.md) | Preserved survival-era reasoning, tentative settings, alternatives, frozen M4 inputs and completed evidence. Deliberate future reuse only. |
| [Approval/authority transition](design_history/2026-11-07-gdd-v0.16-approval-and-authority-transition.md) | The successor's approval and original publication boundaries. Read dated statements in their historical context. |
| [Kitchen/contribution decisions](design_history/2026-11-09-contribution-effects-and-kitchen-decisions.md), [Fuel decisions](design_history/2026-11-11-fuel-reserve-and-emergency-freight-decisions.md), [Expedition decisions](design_history/2026-11-13-expedition-outcomes-and-provisioning-decisions.md) | Detailed approved refinements; later decisions supersede earlier tentative versions, especially Food's former capacity bonus and Fuel's former request/greyout model. |
| [Expedition result, acceptance and extended playtest](testing/2026-11-13-expedition-outcomes-and-provisioning-result.md) | Primary current evidence and the reason spatial work now has priority. Original technical evidence remains separately attributed. |
| [Publication and layout handoff alignment](design_history/2026-11-14-publication-and-layout-handoff.md) | Current disposition and next-scope clarification only; not a competing gameplay specification. |

Start with the four entry points and the latest Expedition acceptance/extended-playtest sections. Then read GDD §§1–5 for purpose/objective, §4 and §7 for spatial/storage constraints, §§8–16 as they affect routes, and §§19–21 for tuning and open scope. Read the relevant VDD world/spatial passages and current-scene notes, including its later Receiving baseline rather than treating the original September schematics as current geometry. Consult Systems MVP for affected implemented contracts and evidence. Do not reload every historical report before discussing the layout.

The targeted MVP/VDD compatibility pass is already complete; [its record](testing/2026-11-07-mvp-vdd-compatibility-consistency.md) is evidence, not pending work. DOCX masters remain gameplay authority; their older dated implementation/publication notices are qualified by subsequent acceptance/publication records. **An undefined successor mechanic stays undefined. Never fill it with an obsolete mortality, midnight, prebuilt-team or daily-request rule.**

## 3. Why we pivoted — preserve the reasons, not just the new goal

The original fantasy was receiving messy loot, sorting it, arranging it on shelves, hoarding until space mattered, and making difficult choices about spending, salvaging or destroying possessions. Requests and expeditions were added to deepen that backbone with useful sinks and supply sources.

“Survive as many days as possible,” with no scavengers left as failure, gradually inverted the relationship. More incoming goods trivialized survival pressure; more consumption emptied the stock that was supposed to make storage valuable. Daily windows, forced dispatch and midnight added timetable constraints and difficulties keeping the player appropriately occupied. Accumulation–drawdown–recovery and time acceleration were attempts to repair symptoms while retaining that objective.

The developer explicitly changed the objective to **accumulation speed**, removed the day cycle and rejected designed terminal dead ends. This is not a clean slate: physical storage, Receiving, ownership, interaction and much of the world remain useful. Supporting systems now create decisions about exchanging stock for time/efficiency. They must not become the main activity at the expense of organization.

The prior ADR discussions were extensive and deliberately preserved, including their reasons and unfinished choices. They are not current progression, event, scarcity, population or failure rules. A potential survival sequel/mode does not justify keeping obsolete runtime code or connection points in the main game. Archived implementation/evidence can remain without being live dependencies.

The original M4 test remains a successful bounded mechanical test, not proof of a balanced survival economy. Its stress provisioning, daily cutoffs and nearly empty shelves helped motivate the pivot; they are not instructions to restore those conditions.

## 4. Current collection objective and storage experience

The eight categories are **Electronics, Food, Fuel, Hydration, Medical, Morale, Protection and Weapons**. All eight **live Utility totals on qualifying player storage** must meet the shared target simultaneously. Victory is immediate, with no hold interval or permanently banked category. Before success, removing goods can make a category incomplete again. The first completion time is then retained while continued play and live totals remain available.

Sorting tables, carried inventory, lift/deposited/upstream cargo and expedition commitments do not count. Clearing requests, emptying the queue or emptying inventory are not extra victory requirements. **2,000 Utility/category is still illustrative. The published test fixture uses six Utility/category**, so serious playtesting continues after its early victory. Neither figure is an established release balance target.

Uneven sinks and uneven category accumulation are desirable. Roughly 80% occupied storage at a typical win is an experiential ballpark, not a quota or a validated capacity result. Preserve room to maneuver and assisted organization; this is not intended to be a geometric-precision puzzle. All storage available from the start is the favored direction, not a finalized production roster. Storage upgrades are not a default solution to layout problems.

Bulk measures carrying burden; Footprint, shape and support/stacking govern space; Utility governs contribution and collection. They are not interchangeable. The first release uses one shared category per item and no dual/multi-use conversions. Buffs affect acquisition/systems, not silent changes to an item's definition. Explicit surgical authoring changes remain possible with approval and reconciliation of current derivatives.

## 5. Continuous time, service pressure and fairness

Active real-world completion time replaces days survived. No day/night cycle, preparation window, mandatory daily return, midnight abandonment, completion deadline or designed terminal failure. ESC/main menu/offline/zoning pause the run. Dispatch, Kitchen, Fuel, Incinerator and Medical remain live. Time acceleration is set aside. Preserve the actual shared timeline and pause ownership rather than introducing new timers or unapproved focus/suspension behavior.

No dead end means an ordinary route back to progress remains, not guaranteed quick recovery, hidden grants, adaptive loot or a protected stock floor. A player may voluntarily restart an inefficient run. The player controls dispatch timing and can create more workload than they comfortably handle; that does not absolve us from providing time for sorting.

### Kitchen — reactive cumulative demand, already implemented

An independent Kitchen timing stream chooses the first and subsequent intervals in **180–300 active seconds**, anchored to scheduled triggers, never payment. Each event proposes **60–80 total Food/Hydration Utility**, with the larger proposed lane no more than 1.25 times the smaller. Separate category balances form one obligation. There is one **60-second grace period** on opening; additions do not reset it, and overdue additions increase the penalty immediately.

Outstanding Utility is capped at **105**. Additions are clipped to available headroom; overflow is discarded, not banked. Cap-blocked events are consumed and the schedule continues. Each **three outstanding Utility means one percentage point** of carrying loss, capped at **35%**. Normal player capacity is **22**, so maximum penalty leaves `floor(22 × .65) = 14` Bulk. Partial credited contributions proportionally relieve capacity loss; sprint returns only when both balances clear. Ordinary walking speed is unchanged.

Existing carried goods are grandfathered when the limit falls; no forced deletion/drop/storage. New pickups enforce the effective limit. Whole items are submitted with capped credit and waste, and rejected transfers preserve exact state. The panel displays percentage loss and selected-item consequences. Older 20/10 carrying, 150-Utility debt and 50% penalty belong to earlier evidence, not current settings.

### Fuel — proactive reserve, not another recurring request system

Reserve starts **55/60**, drains continuously at **one Utility per 30 active seconds**, and never becomes negative. Fixed operating thresholds are **45, 30 and 15 Utility**. Environmental light-strength multipliers are **1.000 / 0.835 / 0.670 / 0.500**. Below 45 Salvager permission is off; below 30 Workshop permission is also off; those facilities' actual mechanics remain future work. These fixed thresholds are not stretched by later tank-capacity upgrades.

Below 15, each otherwise-ready delivery waits **60 active seconds before ARRIVAL**. The wait starts only when cargo exists and the preceding turnaround is complete; unloading and empty idle do not bank waiting credit. A top-up below 15 retains the deadline; reaching at least 15 removes the restriction and starts the eligible load once. Already-started cycles finish normally, preserving audiovisual timing. At zero, emergency freight remains possible. There are no greyout episodes, overlapping timers, Fuel debt, threshold bonuses or renewed grace periods.

CRT text is green for normal and orange for emergency freight, with explicit mode/waiting information; essential UI is not dimmed. Physical refuelling uses the **temporary cabinet beside the lift**, with whole-item fractional headroom credit and waste. Its convenient position is not a finalized production location. Consumption/tank upgrades remain Workshop candidates.

### Incinerator — deliberate disposal

Available from the start, instantaneous, no output, no Fuel cost, cooldown or outage dependency. Carry the selected item physically; F opens, a fresh E submits. The exact irreversible-destruction warning appears once per run and is consumed when shown, including Back. No remote disposal or automatic floor dropping. Only single-item disposal is implemented; mass disposal is not implicitly authorized.

## 6. Expeditions — the real system is implemented and published

Prepare **one current crew of 1–4 Ready scavengers** in the live panel, contribute selected whole items, choose two distinct affinities, then explicitly Dispatch. No per-team loadout tabs, prebuilt morning allocation, parallel unfinished crews, cutoff or automatic dispatch at full provision. A crew forms at first accepted supply or successful zero-loadout Dispatch. Size then locks; affinities remain editable until departure. Closing/reopening preserves draft choices and committed supplies. At zero Ready, an unformed draft is unavailable; a legitimately formed last crew remains usable.

There are **28 unordered affinity pairs**. A destination is occupied from successful departure until return, not until personnel handover. No repeated-location depletion, destination-specific hazards, external map or closure-event system is required. Dispatch requires both affinities; no current random-destination fallback.

### First-iteration numerical contract — provisional, not production balance

| Lane | Credited Utility ceiling per original scavenger | Effect |
| --- | ---: | --- |
| Food | **10** | Each Utility adds **0.125 expected bonus items**. Pool across the crew: whole count guaranteed, one additional item rolled from the fraction. Fully supplied crews of 1/2/3/4 have expected counts 1.25/2.5/3.75/5; a full four-person crew guarantees five. |
| Hydration | **5** | Linear reduction up to **25%** of a uniformly sampled **210–300-active-second** journey. Baseline duration does not depend on crew size. Full provision gives 157.5–225 seconds. |
| Protection | **12** | Linear relative reduction up to **50%** of both per-member risks: Light **20%→10%**, Severe **10%→5%**. Exactly one healthy/Light/Severe result per original member. No immunity or duration-based risk. |
| Weapons | **10** | Linear blend up to **50% uniform + 50% Utility/Bulk-weighted** selection among eligible items in the already-chosen category. No quality exclusions or alteration of category odds. |
| Morale | **15** | Linear recruitment chance **0→5% per original member**, independently rolled. One success adds one healthy recruit. No population ceiling or one-recruit-per-team cap. |

Ordinary capacity is **23 Bulk per original scavenger**. Full Bulk of every submitted item, including Food, subtracts from the ordinary return budget. Food's bonus haul is separate from that budget but joins the **same exact physical delivery**. Bonus objects retain their normal Bulk everywhere else and have no bonus-only Bulk/Utility ceiling. Food does not increase carrying capacity. The UI displays guaranteed/possible counts such as “1–2 Bonus Items,” or an exact count when certain, and must explain useful contributions that do not change the displayed range. Zero ordinary capacity does not necessarily mean zero returned loot.

The generator uses all **167 active definitions**, not the earlier sixteen-item fixture. Baseline categories are equal; two affinities each receive a **20% relative probability increase** from 12.5% to 15% when all eight categories are feasible. Relative weights **9:7** for affinity/non-affinity implement that distribution; remove categories with no fitting ordinary item for that draw and renormalize. Category catalogue size does not itself alter category odds. Within-category selection is uniform without Weapons; duplicates are allowed. Ordinary generation continues until no eligible whole item fits. Bonus draws use full-category eligibility without the ordinary remaining-Bulk filter, with the same affinity and Weapons rules.

Provision effects are linear/capped; percentage effects normalize credited Utility by original crew size. Extra Food count uses total credit with a crew-scaled ceiling. Whole-item overfill is wasted. Outcomes commit once at successful Dispatch and persist; reopening a panel or continuing a save does not reroll rewards.

Injury and recruitment are **independent**. An injured original can recruit; injury does not remove that person's carrying capacity or alter the committed journey. Recruits do not expand or dilute that journey's cargo/provisioning, change its duration, suffer its injury rolls or roll again for more recruits. Healthy joining is current behavior; injured recruits are only a possible later tuning option. No HP, treatment-success rolls, severity shifting or mortality is implemented.

## 7. Receiving, Medical, progression and information

### Handover and recovery

Receiving accepts one active plus **two deposited FIFO** batches, with upstream Awaiting Lift beyond that capacity. A nonempty expedition releases its destination at return, but personnel stay unavailable until the exact cargo is admitted to an active/deposited slot. Admission completes handover even if emergency freight has not begun descending. Healthy originals and recruits become Ready; injured originals enter Medical as patients. Empty combined manifests hand over at return without using a slot or starting an empty lift trip.

Medical owns **120-second Light / 300-second Severe natural recovery**. Independent timers start at handover and advance in active time. At the frontage, F opens the panel. Use the wheel or number keys to select a carried item, then press a fresh E to treat. The provisional rate is **10 seconds per Medical Utility**. The same budget shortens the shortest timer first, spills over to subsequent patients and discards final excess. Each completion releases one scavenger immediately to Ready. Schema 12 replays treatment receipts to restore exact recovery and personnel availability. Confirmed New Run preserves incompatible snapshots.

Workshop remains a one-time upgrade-purchase direction, with work taking time and power permission able to pause progress rather than erase it. Electronics is no longer a recurring Ops demand. Adding Fuel to some Workshop costs is a new option under consideration, not approved. Rations, Salvager conversion, Training and final progression are separate work. These must not be implemented merely to begin layout design.

### Exact presentation and accepted improvements

Preserve one exact haul/one delivery, full-OPEN TAKE, permanent barrier, stationary-bay theatre, complete outbound turnaround and FIFO ownership. Cargo surfaces remain private TAKE-only surfaces, not ordinary goal storage. No hidden filler, loss, content substitution or reroll of awkward objects.

Receiving now prefers valid same-group stacking, then valid mixed top-appends, then empty placement. Existing support flags, Footprint fit and clearance still apply. Ordinary shelf automatic stacking is unchanged. Committed layouts and removal history survive current-build continuation. Mixed stacking is a general capability whose value may grow with future catalogue combinations; its first stress-test pass count is not its entire value.

The surgical Fedora adjustment is adopted: `loot_000172`, scale **0.897**, Footprint **3×3×1**, Bulk **2**, other properties retained. Current derivatives were reconciled; historical data remained unchanged. Mystery Meat Large remains scale 1, Footprint 13×5, Bulk 14. Its smaller trial and the assistant's 11×5 grid witness were diagnostic/proposed only, not approved edits.

Two extreme cases remain **developer-deferred prototype limitations**. These are the 157-Bulk meat-and-mice area overrun and long-object bounded-planner failure. The safe pre-dispatch path rejects an unpreparable exact outcome while retaining the draft, supplies, personnel and random state. An unchanged retry repeats it. Universal presentation remains future work.

The developer strongly rejected haul chunking as a default answer because random geometry would impose extra delivery/fuel-delay penalties disconnected from player choices. The preferred response order is Receiving-only mixed stacking; surgical scale/Footprint tuning; justified Bulk tuning; small manually authored widening; shelves only much later; split deliveries far behind those. No broad shrinking, item-ID-specific packing recipes, lift rebuilding or exhaustive stress campaign is authorized. Reassess after a significant catalogue expansion or a concrete new playtest problem, not on every handoff.

Goal visibility remains baseline. A diegetic Journal, PA and central monitoring remain presentation directions, not proof that their final systems already exist. The broader bunker population and surface world are inferred through goods, requests and reports, not visible simulated people or exterior gameplay.

## 8. Progress and lessons from the session being handed over

This session moved from the surviving M4 mechanical prototype and extensive ADR discussion to the approved collection-game successor, reconciled the current document authorities, and implemented the following bounded slices. Do not restart any as unfinished design:

| Progress | Record / lesson |
| --- | --- |
| Collection foundation | [Result](testing/2026-11-07-continuous-run-collection-goal-result.md) and [closure](testing/2026-11-07-continuous-run-collection-goal-closure.md): continuous active time, stored-Utility objective, continuing after victory; broad obsolete calendar/report infrastructure retired. |
| Original expedition loop | [Result](testing/2026-11-08-expedition-to-storage-loop-result.md): draft formation, departure, exact cargo, zero-item returns, destination occupancy versus personnel release, continuation. Temporary acquisition rules later replaced. |
| Furniture collision | [Repair](testing/2026-11-08-furniture-collision-repair-result.md): seven fixtures restored without removing storage/pickup behavior; accepted separately. |
| Incinerator | [Result](testing/2026-11-08-incinerator-deliberate-disposal-result.md): physical selected-item disposal and once-per-run warning, with no power dependency. |
| Kitchen | [Result](testing/2026-11-09-continuous-kitchen-service-result.md): bounded cumulative demand, percentage relief, independent timing and recovery; old meal/UI remnants reconciled. A narrated 15/10 display at an earlier 43% penalty was not reproduced; the focused probe found correct 15/11 then 14/11. It is not an open confirmed bug. |
| Fuel and zero-Ready repair | [Fuel result](testing/2026-11-11-fuel-reserve-emergency-freight-result.md), [Dispatch repair](testing/2026-11-11-dispatch-no-ready-repair-result.md): proactive reserve/emergency throughput replaced request/episode proposals; formed versus unformed last-crew behavior preserved. |
| New loadout assessment | Recipes rebuilt from the active catalogue and new five-lane targets, not reused from M4. **23 Bulk/scavenger chosen.** Ordinary ~50% usage and efficient 70–75% remaining were aspirations. Solo efficient headroom is lower and explicitly acceptable; do not raise all crews to 33–40 Bulk to fix that asymmetry. Reassess after significant catalogue expansion. |
| Receiving stress and adoption | [Mixed-stacking/Fedora result](testing/2026-11-13-receiving-mixed-stacking-result.md): mixed stacks implemented, Fedora adopted, current derivatives reconciled, remaining extremes deferred. The v0.2 assessment retained all 20 recipes and capacity comparisons. |
| Real Expeditions | [Result and extended playtest](testing/2026-11-13-expedition-outcomes-and-provisioning-result.md): full catalogue, five actual effects, real personnel outcomes and recovery, schema 11. Old sixteen-item/8-Bulk/90–180-second/Medical-lane/fixed-population assumptions retired or their useful coverage migrated. |

The developer's **more-than-two-hour sustained playtest** found no bugs or functional failures and explicitly promoted Expeditions. It did reveal four important experience/balance observations:

1. **Too much walking**, even without treatment and Workshop. Existing bunker size and frequent service/item-handling trips were major contributors.
2. **Food and Hydration depleted too quickly** to sustain Kitchen and loadouts comfortably. Sprint was unavailable much of the time; reduced carrying meant more trips. The consequences behaved correctly but their frequency/cost felt excessive.
3. **Workload may be too high**: continually behind on unloading, crew preparation and requests, despite the conveniently located temporary refuelling panel and missing services.
4. **Fuel accumulated much faster than other categories**, even when wasting roughly 40-Utility items to fill roughly ten-Utility gaps.

The observed reinforcing cycle was: long routes → slower unloading/provisioning → supply pressure → loss of sprint and carrying capacity → more trips → further congestion. This is a reported interaction, not a measurement isolating each cause. Shorter routes may improve throughput but also enable more dispatches; do not promise layout alone resolves the economy.

Fuel's high-end catalogue mix and Weapons/bonus acquisition are **suspected contributors**, not a proven diagnosis. Fuel alongside Electronics for some Workshop upgrades is **under consideration**, not a newly approved sink. Do not respond by immediately lowering Fuel Utility, raising reserve consumption, reducing Kitchen requests or changing expedition durations.

**The developer accepted the compact layout after all nine walkthroughs.** Earlier transit observations informed the geometry work. Final economy, Food/Hydration pressure, Fuel surplus and workload remain subjects for representative integrated play. [Nine-slice technical result](testing/2026-11-14-compact-bunker-layout-result.md)

## 9. Local execution, physical ownership and evidence discipline

```text
Repository: Navandis/Sorting-apoc-PROTOTYPE
Read-only handoff anchor: d242de49441b410c4abb88ab4f7b61971b6424d1 (14 November 2026)
Historical Expedition retest checkout:
  C:/Users/Boschetar/Documents/ChatGPT/Sorting Apocalypse - Prototype/Expedition
Current asset-equipped layout authoring checkout on main:
  D:/Godot Projects/Sorting-apoc-PROTOTYPE
Reported engine: Godot 4.7.stable.official.5b4e0cb0f, Compatibility
Normal F5: res://gameplay/run/run_shell.tscn
Standalone F6: res://gameplay/logistics_wing/wing_gameplay.tscn
Current save schema: 12, existing user://saves/collection/ service
```

The asset-equipped layout authoring checkout is `D:/Godot Projects/Sorting-apoc-PROTOTYPE` on `main`. The separate Expedition clone above is a historical retest location. Verify the actual branch, editor state, assets, engine and working paths for the next requested task.

Use current saved scenes/builder and human overrides as the physical baseline. Relevant owners include `gameplay/logistics_wing/wing_gameplay.tscn` and its script, `gameplay/run/run_shell.tscn`, `player_controller.gd`, storage/ladder owners, and `gameplay/logistics_wing/receiving/receiving_runtime.gd`. Discover connected structural/environment owners from those references rather than inventing filenames or treating old plan pixels as current topology. CURRENT_STATE §§6–8 and VDD's later physical notes identify the accepted environment and source safeguards.

The current catalogue is **167 active / seven retired / 174 sources**. Never recycle retired IDs or regenerate accepted values from old scoring proposals. Twelve separate Auto Stack Group approvals remain pending with saved None; do not turn a scope-limited approval into completion of unrelated metadata. Catalogue values can change surgically when explicitly approved, with canonical definitions and affected current data reconciled; historical evidence is not retroactively rewritten.

Retain exact item identity/ownership, atomic consumption/TAKE/storage, rejection rollback, zoning, support/clearance, current shelf and fixed-ladder functionality, fully OPEN freight access, shared active-time/pause logic and current-build continuation. Layout edits may intentionally move authorized components, but their collisions, interaction targets, lights and linked surfaces must move coherently. Do not simply delete difficult props or extend reach to conceal layout problems.

No reset, stash, clean, force-push, history rewrite, branch/worktree deletion, untracked staging sweep, commercial-asset cleanup or arbitrary drive scan for convenience. Keep checkpoint scenes with production UIDs or duplicate global classes outside Godot-scanned roots. Avoid concurrent Godot/import writers, especially across junction-linked clones. A tracked repository clone is not a licensed-asset backup.

Old-save migration/backward compatibility was explicitly waived for the recent changes. Existing save files still should not be deleted as housekeeping. Current-build saving/loading must remain correct, and incompatible saved layouts should be rejected explainably rather than silently relocated. Reconfirm only if a new task materially changes this scope.

Known debt includes synchronous autosaves and large-stock cost, release durability, brief silent suspension, Windows certificate-store and held-material diagnostics, the historical CRT formatting checks and other CF-01–CF-24 items. The layout result records the inherited launch-UID and 46-host assertions together with the passing route and continuation evidence.

## 10. Accepted compact layout and future work

The accepted wing runs from Receiving and Dispatch through shortened Backlog and Sorting into Main Storage. A–D remain, including the shared A/B circulation and C–D link. Medical and Kitchen have separate approaches, Workshop leads west to Salvager, Incinerator branches directly south from Main Storage, and the straight 3 m eastern link reaches Bunker Ops. The working Fuel cabinet is in Receiving.

The actual whole-wing plan is a roof-off diagnostic. Normal player views keep ceilings, and the existing authored Receiving installation retains its scoped visual acceptance. The current layout preserves the physical storage roster and the lift-alert sightline from Sorting.

Use the accepted scene as the baseline for later materials, lighting, furnishing and focused playtest adjustments. Starting stock, final capacity, progression, integrated economy and remaining service mechanics retain separate scope. Further work begins with an agreed brief. [Roof-off north-up overview](design_history/media/2026-11-15-compact-bunker-layout-north-up.png) · [Nine-slice technical result](testing/2026-11-14-compact-bunker-layout-result.md)

## 11. First response in the new session

Read the current entry points and the relevant GDD v0.16 and VDD v0.12 sections. Use the layout close-out and Expedition playtest records for provenance. Verify accessible repository state before making local or published claims.

Start from the developer’s requested task. Treat schema 12, the published Medical implementation, the promoted Expedition outcomes and the compact layout as established. Workshop remains the next separate service scope. Medical release tuning and save performance remain deferred. Ask about missing details only when they affect the requested scope.

## 12. Provenance and maintenance

The 15 November revision followed the 14 November Expedition handoff and the developer’s acceptance of Slice 9. The earlier approval records, playtest evidence and authority boundaries retain their original dates. [Acceptance and main verification](design_history/2026-11-15-compact-bunker-layout-acceptance-and-publication.md)

The filename retains its 7 November date for link stability. The current edition includes the 18 November 2026 Medical acceptance.

Use the acceptance and publication records for main verification and the technical result for measured outcomes. Release balance, furnishing and durability retain separate scopes.

**Operating rule. Keep collection and organization central, use the accepted layout as the working baseline, and follow the developer’s next explicit scope.**
