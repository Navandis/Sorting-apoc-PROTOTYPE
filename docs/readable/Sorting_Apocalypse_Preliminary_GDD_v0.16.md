<!-- Generated from the approved v0.16 DOCX master. Do not edit independently. -->

> Developer-approved successor; approval-state update 7 November 2026. Original draft compiled 6 November 2026. Local provisional/open statuses are preserved. Prepared for manual repository provision; no implementation or remote publication is claimed.

DESIGN & EVIDENCE SERIES / SUCCESSOR EDITION

# SORTING APOCALYPSE

PRELIMINARY GAME DESIGN DOCUMENT

Collection, hoarding and spatial organization

Version 0.16  |  7 November 2026  |  Approved successor

> Build the hoard. Organize the space. Keep supplies moving.

The Quartermaster receives, sorts, stores and selectively spends physical loot in an unseen apocalypse. Success is a simultaneous live stored-Utility target across eight categories, measured by active real-world completion time—not days survived.

> The apocalypse ends at the elevator door.

| **This edition** | **Boundary** |
| --- | --- |
| Approved input | Developer-approved ADR archive and collection-pivot record dated 5 November, plus the subsequent single-team preparation-panel addendum. |
| Document status | Approved consolidated successor to GDD v0.15. The developer approved this edition in its entirety; local provisional, open and historical statuses remain. |
| Implementation baseline | M1–M4 remain human-promoted, published and closed at c9f9417 in their bounded scopes. The collection pivot is not implemented by this document. |
| Delivery scope | Approved DOCX and generated Markdown, with reconciled entry-point files for manual upload. No remote write, game, scene, save or other-master edit. |

The targets of 2,000 Utility per category and roughly 80% storage occupancy are illustrations, not validated balance or extra completion requirements. Undefined replacement mechanics remain explicitly open.

<a id="s_Reader_s_guide_and_authority"></a>

## Reader’s guide and authority

This edition is a full gameplay-design successor, not an override sheet for the survival-era GDD. It carries forward applicable physical rules and production boundaries, rewrites the objective and dependent systems, and records unfinished replacements in their owning sections. Historical designs remain available without acting as silent defaults.

<a id="s_Status_and_precedence"></a>

### Status and precedence

| **Label** | **Meaning in this edition** |
| --- | --- |
| CONFIRMED | Explicit developer decision, including approved record content at its stated level of certainty. Does not imply implementation or that numerical tuning is final. |
| RETAINED | Applicable inherited design or physical invariant from the published predecessor. Implementation evidence is identified separately. |
| DIRECTION / PROVISIONAL | Favored approach, candidate mechanic, illustrative number or calibration target that still requires definition or playtesting. |
| OPEN / REDESIGN | No complete current rule. Do not fill the gap with the old daily/survival behavior or an assistant suggestion. |
| HISTORICAL / PARKED | Preserved for provenance or deliberate future reuse, not an active requirement for the collection game. |
| IMPLEMENTED BASELINE | What accepted code/evidence establishes at c9f9417. A record of existing behavior, not an instruction to retain an obsolete rule in the release design. |

Approval of this edition and its source records preserves every local provisional, favored, open and historical distinction; it does not turn unresolved mechanics or illustrative values into final rules. The panel addendum explicitly supersedes the pivot record’s per-team preparation tabs.

The developer has reviewed and approved this edition in its entirety. GDD v0.16 is now the single current intended-gameplay authority, superseding v0.15. The approved documentation package reconciles current-facing pointers for manual provision to the repository; no remote publication or gameplay implementation is claimed.

> An unresolved post-pivot mechanic is an unresolved mechanic—not permission to restore its survival-era predecessor.

<a id="s_Document_roles"></a>

### Document roles

| **Reference** | **Role** |
| --- | --- |
| This approved GDD v0.16 | Consolidated intended collection game, retained physical rules, local status and open design boundaries. |
| Systems MVP v0.5 | Accepted implementation, tests, progress and carry-forward obligations. Its obsolete forward plan needs later reconciliation, not retrospective falsification. |
| VDD v0.11 | World/material/art and current spatial baseline. Future pivot-driven spatial changes require explicit design and authoring; accepted art is not discarded. |
| Prototype Findings v0.14 | Historical experiments, rejected approaches and evidence. Not the active progress tracker. |
| Approved pivot record / latest addendum | Decision provenance and purpose of the redesign. Addendum removes parallel preparation of prebuilt teams. |
| Approved ADR archive / GDD v0.15 | Historical survival design. Possible later reuse, not a second current ruleset. |

<a id="s_How_to_read_and_use_the_draft"></a>

### How to read and use this edition

Read §§1–5 for the revised product and objective; §§6–11 for item, storage, submission and expedition/Receiving rules; §§12–17 for supporting departments and presentation; §§18–21 for technical boundaries, balance, evidence and remaining work. Appendix A gives an illustrative continuous sequence, Appendix B defines terms, Appendix C maps supersession, and Appendix D identifies sources.

Source labels identify project material, not outside research. [PIV] is the approved pivot record; [ADD] is the panel addendum; [ADR] is the approved parked archive; [G15], [MVP], [VDD], [H25] and [WG] identify the sources in Appendix D. [APP] records approval of this edition. The original draft was compiled 6 November 2026; this approval-state update is dated 7 November 2026.

This task updates document approval and current-facing entry points for the developer’s manual repository provision. It authorizes no game implementation, M5 execution, reacceptance of M4, asset audit, gameplay rerun or assistant repository write. It creates no new implementation milestone.

<a id="s_Contents"></a>

## Contents

[1  Game definition and purpose](#s_1_Game_definition_and_purpose)

[2  Design pillars and non-goals](#s_2_Design_pillars_and_non_goals)

[3  Continuous core loop](#s_3_Continuous_core_loop)

[4  World boundary and spatial context](#s_4_World_boundary_and_spatial_context)

[5  Victory, active time and run continuity](#s_5_Victory_active_time_and_run_contin)

[6  Unified item grammar](#s_6_Unified_item_grammar)

[7  Physical interaction and storage](#s_7_Physical_interaction_and_storage)

[8  Facilities, submission and request pressure](#s_8_Facilities_submission_and_request_)

[9  Scavengers, team preparation and destinations](#s_9_Scavengers_team_preparation_and_de)

[10  Provisioning, capacity and returned loot](#s_10_Provisioning_capacity_and_returne)

[11  Receiving and waiting expeditions](#s_11_Receiving_and_waiting_expeditions)

[12  Kitchen and ration conversion](#s_12_Kitchen_and_ration_conversion)

[13  Medical and workforce availability](#s_13_Medical_and_workforce_availabilit)

[14  Bunker Ops](#s_14_Bunker_Ops)

[15  Salvage, incineration, Workshop and upgrades](#s_15_Salvage_incineration_Workshop_and)

[16  Feedback, interface and audio](#s_16_Feedback_interface_and_audio)

[17  Narrative and unseen-world presentation](#s_17_Narrative_and_unseen_world_presen)

[18  Technical, content and persistence boundaries](#s_18_Technical_content_and_persistence)

[19  Balance philosophy and tuning](#s_19_Balance_philosophy_and_tuning)

[20  Implementation baseline and scope](#s_20_Implementation_baseline_and_scope)

[21  Validation priorities and open questions](#s_21_Validation_priorities_and_open_qu)

[A  Illustrative continuous play sequence](#s_Appendix_A_Illustrative_continuous_p)

[B  Glossary and status-sensitive values](#s_Appendix_B_Glossary_and_status_sensi)

[C  Supersession and retention map](#s_Appendix_C_Supersession_and_retentio)

[D  Sources and maintenance](#s_Appendix_D_Sources_and_maintenance)

Headings are available in Word’s Navigation pane. The generated Markdown preserves section order, tables, local status and source labels.

<a id="s_1_Game_definition_and_purpose"></a>

## 1. Game definition and purpose

<a id="s_1_1_One_sentence_concept"></a>

### 1.1 One-sentence concept

A first-person collecting and organizing game in which the Quartermaster builds a substantial, physically stored hoard while supplying an unseen bunker and sending scavengers out for more loot.

<a id="s_1_2_Product_snapshot"></a>

### 1.2 Product snapshot

| **Dimension** | **Current intended design** |
| --- | --- |
| Primary experience | Receiving, sorting messy assortments, hoarding, arranging shelves, retrieving and selectively spending or disposing of real items. |
| Run structure | Finite objective with optional continued play after victory; independent new runs invite faster completion. |
| Victory | All eight live category totals on qualifying player storage meet the shared target simultaneously. Immediate completion; no hold interval. |
| Performance | Active real-world time to first victory. No time limit, survival score or designed terminal failure state. |
| Player role | Anonymous Quartermaster in an established underground logistics workplace; unseen residents and expeditions supply context. |
| Pressure | Finite physical space, handling/travel effort, uneven category accumulation, recurring material sinks and self-created workload/backlog. |
| Supporting systems | Expeditions supply sorting work; requests, treatment and upgrades give selective spending a useful role in acquisition and handling efficiency. |

<a id="s_1_3_Why_the_goal_changed"></a>

### 1.3 Why the goal changed

The original organizing-and-hoarding promise became subordinate to surviving as many days as possible. The need to make survival failure matter drove consumption, casualties, fixed windows and restrictive supply. High inflow threatened to trivialize survival, while high consumption removed the persistent possessions that made shelving and organizing worthwhile. Storage increasingly behaved as a brief distribution buffer rather than the central scarce resource.

The daily timetable added forced morning preparation, same-day returns, midnight resolution and cargo forfeiture. Balancing quiet intervals and busy periods then encouraged time-acceleration workarounds. The accumulation–drawdown–recovery proposal tried to reconcile abundance and survival pressure within that structure. The developer chose to change the objective instead, preserving that exploration separately.

The new objective makes the stockpile itself the achievement. Supporting systems now justify themselves by enriching collection, selection, storage and throughput. They are not being removed simply because they consume items; their purpose and consequences must support accumulation rather than sustain an endless survival simulator.

<a id="s_1_4_Player_fantasy_and_mastery"></a>

### 1.4 Player fantasy and mastery

The player owns both the arrangement and the operating habits of the storeroom. An organized collection is satisfying in itself, and also reduces search and handling work. A crowded shelf is a record of progress, but its contents may be inefficient for the space they occupy. Choosing to consume or destroy a useful object can be a difficult but advantageous hoarding decision.

Players may sort neatly, retain a jumble, arrange supplies near service routes, conserve material precisely, or prioritize handling speed. The game does not prescribe one filing scheme or reward an abstract neatness score. Physical limits and item choices make some arrangements more effective without turning storage into a precision-only puzzle.

The player continues an experienced Quartermaster’s working life, rather than arriving as a new hire in an empty settlement. Existing furniture, familiar departments and incidental backlog remain appropriate. Starting stock and onboarding are separate balance choices.

Basis: [PIV §§1–4]; [ADD]; retained player/world framing from [G15 §§1–4].

<a id="s_2_Design_pillars_and_non_goals"></a>

## 2. Design pillars and non-goals

<a id="s_2_1_Governing_pillars"></a>

### 2.1 Governing pillars

| **Pillar** | **Design consequence** |
| --- | --- |
| Organization and accumulation are primary | Shelf space, useful stored stock and selection dominate the objective. Avoid making the player spend nearly all their time servicing secondary systems. |
| Physical goods are progress | Items count only in qualifying storage; exact ownership survives every legitimate transfer. No abstract global reserve substitutes for the collection. |
| The player owns the system | Zones, labels, staging, retention and departure timing express player choices. Poor organization and self-created overload remain possible. |
| Busy, but room to organize | Overlapping activities create priorities. Short deferrals are legitimate, and voluntary expedition cadence gives players control over incoming workload. |
| Consequences cost time, not the run | Bad decisions may produce slow, effortful recovery. Do not create impossible progression or hidden rescue/catch-up mechanics. |
| No game-defined junk | Low-efficiency items remain useful. The player decides when their spatial cost exceeds their value. |
| Simple rules before simulation | Single Item Category, anonymous scavengers, stable item definitions and destination archetypes avoid unnecessary edge cases. |
| The apocalypse remains outside | Imply the broader world through requests, goods, messages and outcomes; preserve the dependable bunker and bounded production scope. |

<a id="s_2_2_Product_boundaries_retained"></a>

### 2.2 Product boundaries retained

There is no player combat, playable exterior, visible zombie encounter, simulated human workforce, named-character management requirement, player hunger/thirst/sleep system, branching Quartermaster dialogue, conventional money economy or free-form base building. Staffed operational cores remain off-map, while player-accessible service spaces remain real spaces. The optional ambient dog is discussed separately in §17.4.

Physical items use bounded owners and assisted deterministic storage. Arbitrary floor dropping, unrestricted rigid-body piles and automatic tidying of the player’s collection are not introduced. Free furniture placement and generalized climbing are not implied by the pivot. A stored collection need not pass through the sorting table as a compulsory extra step.

<a id="s_2_3_Explicit_changes_and_parked_syst"></a>

### 2.3 Explicit changes and parked systems

The main game no longer uses days survived, a scavenger-death victory/failure framework, a day/night calendar, synchronized morning dispatch, automatic daily team formation, forced cutoff dispatch, midnight cargo loss or a required accumulation–drawdown–recovery director. The proposed clock acceleration is set aside. Old daily formulas must not be reintroduced under new names without a deliberate decision.

Destination selection is now part of the intended expedition design; its old post-release-only classification is superseded. The daily destination cap is replaced by a favored concurrent-use limit. Availability events intended to shape scarcity valleys and the generic fallback destination are disfavored/no longer needed under the approved direction. This does not prohibit every possible narrative message or future deliberately scoped event.

<a id="s_2_4_Production_doctrine"></a>

### 2.4 Production doctrine

Calculate unseen activity and present its evidence. Do not build an exterior hospital, moving personnel lift, visible staffed kitchen or construction simulation to explain a resource transfer. The environment, devices and exact physical items provide the player-facing game.

The pivot permits substantial design revision, including possible spatial compression. It does not authorize deletion or regeneration of human-authored scenes, new asset sourcing, engine changes or speculative implementation. Retained acceptance is evidence of a bounded foundation, not a veto on later approved redesign.

Basis: [PIV §§1,4–9,11]; retained non-goals and production doctrine [G15 §2]; [WG].

<a id="s_3_Continuous_core_loop"></a>

## 3. Continuous core loop

<a id="s_3_1_Material_and_decision_loop"></a>

### 3.1 Material and decision loop

> Prepare an expedition → receive its cargo → sort and store → retain, spend, convert or discard → improve the collection and repeat.

The player chooses a current team from Ready scavengers, equips it and selects its destination, then deliberately dispatches it. Another team may be prepared next in the same interface session. Existing expeditions continue independently. No morning divides the population or forces everyone to leave.

Returns provide exact physical assortments through Receiving. The player chooses which exposed items to take, carries them within Bulk limits and either stores them, stages them temporarily, or supplies a legitimate consumer. Stored goods remain present until the player moves or spends them. Continued arrivals, retrieval and expenditure create new organizational decisions.

<a id="s_3_2_Material_destinations"></a>

### 3.2 Material destinations

| **Path from carried items** | **Role in the collection game** |
| --- | --- |
| Qualifying shelf/container/rack | Adds the item’s category Utility to live goal progress while it remains legally stored there. |
| Sorting table or other defined staging | Supports reorganization without counting toward victory. Staging is optional, not a mandatory processing step. |
| Expedition loadout | Trades current supplies and outgoing Bulk for future acquisition effectiveness. |
| Kitchen / Medical / Ops | Supplies an active obligation or treatment; costs stock in exchange for a relevant operational benefit. |
| Workshop / approved conversion input | Commits physical goods to an optional project or transformation; output and timing need their own rules. |
| Salvager / incinerator | Converts useful but inconvenient goods into physical intermediate material, or permanently removes them to free space. |

<a id="s_3_3_Workload_and_self_authored_conge"></a>

### 3.3 Workload and self-authored congestion

The player can send teams close together, stagger departures, or hold Ready scavengers while clearing intake and rearranging shelves. These choices need not protect them from overloading their own workflow. They transfer a meaningful part of pacing control from a fixed timetable to the player.

The desired experience is alert and often busy, but it must include enough uninterrupted attention to complete useful sorting and organization. Requests can be deferred briefly. Waiting cargo ties up its team rather than disappearing. Congestion, treatment delay and poor preparation can all lengthen completion time without ending the run.

<a id="s_3_4_Uneven_accumulation_and_the_fina"></a>

### 3.4 Uneven accumulation and the final approach

Categories intentionally need not have equal sink rates. Morale may cross its target relatively early while Food continues circulating through expeditions and Kitchen. The player must accommodate that imbalance physically and bring the lagging categories up while retaining enough of the earlier ones.

Before victory, a category’s completed indicator is only a description of its current total. Spending below target reverses that indicator. Requests may remain outstanding during the final push; neither clearing those requests nor unloading every queued batch is part of the win condition. After victory the completion record is retained while the player continues if desired.

Basis: [PIV §§2–8]; [ADD]; retained material ownership [G15 §3].

<a id="s_4_World_boundary_and_spatial_context"></a>

## 4. World boundary and spatial context

<a id="s_4_1_A_sheltered_logistics_workplace"></a>

### 4.1 A sheltered logistics workplace

The setting remains part of an unfinished or decommissioned underground civil/service construction project with indirect metro ancestry. It should read as old municipal infrastructure adapted by survivors, not a passenger station, purpose-built military base, warehouse shell or futuristic colony. No tracks, platforms, ticketing systems or iconic rail spaces are required.

The inherited fabric spans roughly 30–50 years of mostly late-20th-century construction, interruptions, repairs and partial commissioning. Survivors have occupied it for several years. Competent adaptation of mismatched resources is the visual identity: improvised does not mean carelessly assembled.

Concrete, cement and masonry define the envelope; metal belongs mainly to machinery, barriers, services and reinforcement. Warm-to-neutral practical lighting, quiet surfaces, useful shadows, restrained wear and sparse dry humor keep items and work areas readable. Serious collapse or heavy neglect belongs at blocked edges, not in the dependable core.

<a id="s_4_2_Playable_domain_and_unseen_inhab"></a>

### 4.2 Playable domain and unseen inhabitants

Receiving, Backlog, Sorting/Quartermaster Central, main storage, departmental service rooms and machine spurs make up the playable wing. Workshop and Kitchen have enterable support rooms; Medical has a Supply Anteroom; Bunker Ops has a more open Transfer Landing. Staff, patients, diners and the fabrication floor remain behind opaque inner boundaries.

| **Boundary** | **Meaning** |
| --- | --- |
| Territorial | An open approach or landing edge identifies a department-owned support space the player may enter. |
| Material ownership | Only an explicit valid submission transfers an item. Crossing a room threshold or opening a panel does not spend it. |
| Playable world | An opaque inner boundary conceals the staffed operation. It does not replace the usable service room with a blocked facade. |

Personnel reach the surface through an unseen route elsewhere. The goods lift is a freight interface, not a transport the player or scavengers visibly board. Ordinary circulation favors open thresholds rather than repeated door interactions. Fixed closures communicate limits and off-map continuation.

<a id="s_4_3_Current_layout_and_the_pivot_s_s"></a>

### 4.3 Current layout and the pivot’s spatial freedom

The accepted composition remains the implementation baseline: Receiving → Backlog → Sorting → a five-gallery storage network → the Deeper-Bunker Approach. Dispatch adjoins Receiving; Workshop and Salvager form one service branch; Medical and Kitchen retain separate approaches; Incinerator and Ops occupy distinct farther destinations. The C–D storage link, the shared A/B circulation and Kitchen’s B-east connection are existing authoring facts, not newly imposed constraints on every future redesign.

The developer is explicitly considering reducing bunker size, especially long corridors, to support the higher-paced collection loop. Exact topology, distances, gallery allocation and furniture changes remain OPEN. Do not silently redesign the wing in this document, but do not treat old dimensions as immovable design goals. Measure travel separately from search, reading, handling and deliberate organization.

The old 85–90% main-storage versus satellite-capacity split is a prior spatial direction, not a validated distribution for the new collection target. Likewise, the roughly 80% winning occupancy aspiration concerns use of available storage, not the physical area of the bunker or a gallery-layout mandate.

<a id="s_4_4_Authored_environment_and_informa"></a>

### 4.4 Authored environment and information placement

Decorative props do not autonomously move, disappear, appear or tidy themselves to imply unseen residents. Explicit legal item handling and designed persistent upgrade/repair changes are separate. Designated environmental state changes must not remove player-owned loot.

Keep the sorting table’s legal working surface clear of decorative equipment. A Journal, side desk, wall-mounted display or overhead monitor can provide information nearby without occupying that surface. This is a placement direction, not a final furnishing roster. Source approval, visual placement approval and gameplay acceptance remain distinct.

Basis: [VDD §§2–16,18–25,34]; [G15 §4]; [PIV §§1,9,11].

<a id="s_5_Victory_active_time_and_run_contin"></a>

## 5. Victory, active time and run continuity

<a id="s_5_1_Simultaneous_live_collection_obj"></a>

### 5.1 Simultaneous live collection objective

**CONFIRMED.** Victory occurs immediately when physically stored Utility in every one of the eight Item Categories reaches the target at the same moment. The current illustration is 2,000 Utility in each category. The equality of category end targets is intentional; the number is provisional.

For category c, let S(c) be the sum of that category’s Utility on qualifying storage and T the common run target:

```text
VICTORY = S(c) >= T for every category c
T = 2,000 only as the present placeholder
```

Electronics, Food, Fuel, Hydration, Medical, Morale, Protection and Weapons are separate totals. Surplus Fuel does not cover missing Food. Cumulative acquired Utility, lifetime handled items and Utility previously stored but already spent do not satisfy the live condition.

| **Item context** | **Counts toward the target?** |
| --- | --- |
| Legally placed on qualifying player storage | Yes, while the item remains owned by that storage. Compatible stacked members remain individual physical items. |
| Sorting table / temporary staging defined as excluded | No. Useful work space is not automatically qualifying storage. |
| Player’s carried bundle / selected held item | No. |
| Active lift, deposited cargo or waiting expedition | No, even though the cargo is committed and recoverable. |
| Committed request or loadout input | No. Spending does not create another qualifying reserve. |
| Machine/project input or output awaiting collection | Not implicitly. Only its later qualifying storage and an explicitly defined Item Category/Utility can count; salvage/output classification remains open. |
| Environmental props / unregistered furniture | No. A visually shelf-like surface does not automatically qualify. |

The implementation must identify qualifying storage deliberately. Category zoning and player labels are not additional score requirements. A legal manual placement in a differently labeled area does not convert the item’s category. Exact classification of future specialist units and conversion outputs belongs to their design, not a guessed furniture tag.

<a id="s_5_2_Completion_is_not_permanently_ba"></a>

### 5.2 Completion is not permanently banked by category

A category indicator can become satisfied and later become unsatisfied when the player takes or consumes items. All eight must coincide once. There is no additional holding interval, requirement to finish requests, empty Receiving, clear the carried bundle or dispose of every surplus item.

At the first successful simultaneous condition, record completion and the active time. Continuing after victory does not undo that recorded achievement when stock later falls. The player can continue for the satisfaction of sorting and hoarding or begin a fresh run. Detailed result screens and historical comparison UI remain OPEN.

<a id="s_5_3_Active_real_world_time"></a>

### 5.3 Active real-world time

| **Context** | **Completion timer policy** |
| --- | --- |
| Ordinary movement, handling, receiving and unpaused interactions | Runs at real-world speed while the run is active. |
| ESC pause menu | Paused. |
| Main/launch menu before a run is loaded | Not running for the inactive run. |
| Game closed / not running | No accumulation of completion time; no offline gameplay advance. |
| Zoning editor | Paused; retained intentional planning exception. |
| Expedition preparation panel | Tentatively unpaused. Reconsider only if playtesting shows preparation interaction is excessively time-consuming. |
| Incinerator panel and first-use warning | Runs at real-world speed while expeditions, autosave and the lift continue. |
| Loading, focus loss, exceptional stalls, other future modals | Detailed handling remains OPEN. No undocumented selective progress while score time is stopped. |

There is no time limit. The clock is a performance measure, not a countdown to loss. Calendar days, midnight and simulated hours are removed from the main-game structure. Time acceleration is set aside; no 2×/3× feature is required by this edition.

Paused contexts should remain coherent with the established full-pause principle: freezing the scoring timer must not secretly permit expeditions, treatment or request penalties to advance for free. The exact pause-owner integration is technical work; the approved zoning pause remains a legitimate exception for planning, not an exploit to eliminate.

<a id="s_5_4_No_terminal_failure_and_no_artif"></a>

### 5.4 No terminal failure and no artificial catch-up

**CONFIRMED.** The design must avoid dead-end situations that make victory impossible. It does not promise quick, comfortable or automatically assisted recovery. A player who makes repeated poor decisions can face substantial work and time to restore an effective operation, and can legitimately prefer to abandon that run and restart.

The recovery path must follow ordinary legible rules rather than concealed rescue grants, adaptive stock replenishment or compensation intended to accelerate a struggling player’s victory. The Medical preference is slow natural recovery, substantially faster with treatment; other acquisition dependencies still need definition. Fairness requires that the player’s decisions and understandable outcomes explain the setback.

A ruleset allowing all acquisition to cease permanently through ordinary allowed play would contradict this requirement, even without a Game Over screen. This is an acceptance condition for the future economy, not approval of a particular free expedition, recruitment grant or supply floor.

<a id="s_5_5_Save_and_continuation_principles"></a>

### 5.5 Save and continuation principles retained

A continuing run preserves actual stock, organization, commitments, active time and outcomes. New Run initializes once; Continue does not reseed goods, reset penalties, reissue cargo, heal people or reroll preserved outcomes. Exit and genuine pause do not advance the run offline.

The existing intended policy of one advancing recoverable state per independent run remains a continuity baseline. Multiple independent runs are distinct from player-selectable historical rollback saves. Full-game durability and its ideal seconds-scale loss target remain unimplemented inherited technical goals, not a new claim of release-ready saving. Midnight is removed as a trigger; no replacement autosave schedule is invented here. See §18.5.

Basis: [PIV §§2,4,7–10]; [G15 §§5.6,18.5] and [MVP §§6–9,19] for retained continuity, with daily triggers superseded.

<a id="s_6_Unified_item_grammar"></a>

## 6. Unified item grammar

<a id="s_6_1_One_category_separate_physical_p"></a>

### 6.1 One category, separate physical properties

| **Property** | **Meaning** |
| --- | --- |
| Item Category | Exactly one of Electronics, Food, Fuel, Hydration, Medical, Morale, Protection, Weapons for ordinary category-bearing loot. Shared by affinities, storage policy, requests and goal accounting. |
| Utility | Authored numeric useful contribution within that category. The same item does not become another category’s resource at another department. |
| Bulk | Shared handling burden for the player’s bundle, outgoing loadout and returned cargo. Not literal weight or occupied shelf volume. |
| Footprint and posed height | Authored physical reservation and clearance in deterministic storage; separate from Bulk and Utility. |
| Storage Pose and Front | Authored canonical presentation, with +Z item Front aligned to the installation’s Front and a distinct optional packing turn. |
| Stack support and Auto Group | Authored ability to sit on/support another item and optional strict automatic compatibility class. |
| Definition and instance identity | Stable type data versus the durable identity of each physical copy. Visual nodes do not create a second copy. |
| Salvage Yield / conversion metadata | Potential physical output from a defined transformation. This does not reintroduce context-dependent multi-category request use. |

**CONFIRMED.** Dual-use and multi-use items are not part of the intended first release. The exploratory vodka example is superseded. A Medical item serves treatment in the target design. The mechanical Dispatch fixture still uses a Medical lane. A Fuel item cannot serve Kitchen Food. General remains a universal storage-zone type, not a ninth Item Category or goal.

<a id="s_6_2_Stable_item_definitions"></a>

### 6.2 Stable item definitions

Authored Utility and Bulk do not temporarily change because an item was acquired during a boon, sent on an expedition or found at an affinity destination. Better acquisition means a different assortment of existing items, not inflated values on otherwise identical goods. Events are not an approved reason to rewrite definitions. This stability lets players learn the objects.

Authored values can still be deliberately retuned during development. That is different from a run-time modifier, and cannot retroactively change credited receipts or silently reinterpret a saved run. Compatibility and migration need an explicit treatment when data changes.

<a id="s_6_3_Handling_and_storage_efficiency"></a>

### 6.3 Handling and storage efficiency

Bulk is a practical burden: a long racket can be awkward to carry despite being light, while a compact dense object can have high Bulk. Storage efficiency depends on physical size, shape, stacking and accessible space. Utility per Bulk and Utility per Footprint describe different opportunities; neither requires a new visible score.

A compact high-Utility object may be desirable to retain for the goal or to send in a loadout that leaves more return space. A bulky low-Utility object may be an attractive request input because consuming it frees shelf space. An inefficient Morale item may still be worth keeping while that category is short, and worth replacing once Morale is comfortably above target.

<a id="s_6_4_Affinity_evaluated_in_useful_ret"></a>

### 6.4 Affinity evaluated in useful returns

The preferred measure of an affinity’s value is received category Utility across comparable expeditions. Both affinities receive the same mathematical bonus. Different item pools, item sizes and randomness can still produce unequal returns, and neither affinity is guaranteed to appear in every small haul.

This is a design objective, not a settled sampler. Exact weighting, normalization across categories, category choice versus item choice, capacity fitting and interaction with provisioning quality remain OPEN. Do not equate equal bonus with forced equal Utility in each batch, or add extra carrying capacity for favored items.

<a id="s_6_5_No_default_junk_and_no_forced_un"></a>

### 6.5 No default junk and no forced uniform catalogue

Ordinary gameplay loot has intrinsic useful contribution even when its efficiency is poor. The game does not classify an object as disposable junk on the player’s behalf. Environmental tires, broken furniture and wrapped corridor masses remain clearly distinct non-interactive dressing, not a hidden cache of free supplies.

The inherited catalogue deliberately allows a broad useful middle, weak options and exceptional items rather than forcing every category or ratio into a single bell curve. Numerical calibration uses human judgment about represented quantity, usefulness and handling—not a universal Footprint-to-Utility formula. The current accepted M4 values remain reproducible testing content, not proof of suitability for the collection objective.

<a id="s_6_6_Conversions_and_optional_instanc"></a>

### 6.6 Conversions and optional instance state

Rations and Salvage remain physical-output concepts. The classification and goal contribution of any output need to be explicit. The single-category decision does not silently settle whether standardized Salvage is an eight-category item, a project-only intermediate or something else. Do not invent a ninth goal or let an abstract currency inflate the stock objective.

Condition/remaining quantity, spoilage and contamination were optional or deferred predecessor ideas. None becomes a requirement merely because it could create inefficient objects. The nightly contamination design cannot be transplanted into a game without nights. Their post-pivot disposition is OPEN / REASSESS; no continuous decay timer, hidden Utility loss or new item-state system is authorized.

Basis: [PIV §§2–3,5,7]; [ADR §5] for the separately retained single-category decision; [G15 §§6,18.3] for physical and catalogue grammar.

<a id="s_7_Physical_interaction_and_storage"></a>

## 7. Physical interaction and storage

<a id="s_7_1_Valid_ownership_states"></a>

### 7.1 Valid ownership states

| **Context** | **Retained representation and rule** |
| --- | --- |
| Pending / deposited Receiving cargo | One committed entry per ItemInstance; upstream data and active visible representation are distinct. Waiting cargo is not player storage. |
| Carried bundle | The same durable identity within a Bulk-limited owner. Held mesh and HUD are representations, not droppable copies. |
| Player storage / sorting table | A bounded owner or surface presents deterministic items. Only designated qualifying storage contributes to victory. |
| Facility output | Physical output has a bounded collection owner; output capacity and admission rules require a complete conversion design. |
| Submitted / consumed / converted / destroyed | The source ceases to be ordinary retrievable loot. Receipts preserve what was credited; conversion creates separately identified output. |

There is no generic loose-floor inventory state. Items cannot be dropped into corridors, in front of hatches or onto arbitrary decorative furniture. Existing editor-seeded loose objects are development fixtures, not an additional release storage loophole. Facility inputs are irreversible commitments, never overflow shelves.

<a id="s_7_2_Carrying_and_interaction_grammar"></a>

### 7.2 Carrying and interaction grammar

The player carries a bundle constrained by total Bulk. A compact HUD strip displays its members and the active selection; the wheel or number keys changes that selection. Left Mouse Button takes/selects an exposed item. E expresses PUT/SUBMIT; M selects the manual-placement mode and R supplies its packing turn. O opens the zoning editor. Current input distinctions are retained as the starting interaction language, with any later change requiring deliberate usability work.

For requests, F opens/closes the panel without spending. Each distinct E submits only the selected whole eligible item. Held E must not repeat irreversible submissions or search the bundle for suitable items. The accepted held-E automatic-storage behavior is separate and remains reversible physical placement.

Basket/carrier/cart-like upgrades may raise carried Bulk or improve bundle readability without requiring a physical cart simulation. Values and progression remain open. The old M4 player capacity of 20 Bulk is an implemented fixture value, not the new release balance.

<a id="s_7_3_Surfaces_Front_and_orientation"></a>

### 7.3 Surfaces, Front and orientation

Ordinary shelves use a hidden two-dimensional grid with authored width/depth reservations, assisted alignment, deterministic transforms and separate vertical clearance. They are not a volumetric voxel puzzle. Each storage unit owns a semantic Front inherited by its levels. At state 0, Front is +Z, Back −Z, Right +X and Left −X; other states turn that basis by quarter turns without changing the underlying physical cell array.

New placements align the item’s authored canonical +Z Front with the unit Front. A separate optional +90-degree packing turn can orient the item sideways. Existing placed objects keep their committed orientation when installation Front changes; save/load restores that orientation rather than recomputing it.

The zoning view is always presented from authored Front, with Back at the top. Semantic painting maps to the physical cells. Developer F6 remains a physical diagnostic, not player-facing evidence that the grid has been rotated or migrated. Mesh appearance does not choose Front, and per-item shelf-family rotation hacks are not part of the model.

<a id="s_7_4_Zoning_automatic_storage_and_man"></a>

### 7.4 Zoning, automatic storage and manual exceptions

| **Rule** | **Retained behavior** |
| --- | --- |
| Cell meaning | Each cell has one specific category, General, or no enabled zone. Blank/erased means deliberately disabled. |
| Initial policy | First zoning interaction on an untouched surface initializes General 100%. Later clearing does not repeat that initialization. |
| Automatic tier order | Search matching category, then General, then stop. Never fall back to a mismatched specific category or disabled cells. |
| Within each tier | Try compatible stack insertion, then automatic base promotion, then empty placement. Exhaust the specific-category tier before General. |
| Manual placement | May override category mismatch but not disabled cells, physical support, fit or clearance. |
| Changing zones | Does not teleport, rearrange, recategorize or remove existing items. It governs future placement. |
| Default presentation | Zone-auto placement avoids a persistent grid/precision ghost; manual placement remains an explicit control for exceptions and tighter arrangements. |

A label is an identification aid, not a mechanical declaration of item contents. Category totals follow actual Item Category and qualifying ownership, not a shelf name. The player remains free to develop their own taxonomy.

<a id="s_7_5_Deterministic_support_stacking"></a>

### 7.5 Deterministic support stacking

Open-shelf stacks use one base two-dimensional reservation and an ordered single vertical column of individually physical items. No falling physics or post-TAKE resettling is required. Each item authors whether it can sit on another support, whether it can support another item, and at most one automatic compatibility group.

- Each upper item must fit the supporting item’s final physical Footprint after orientation and packing. A stack cannot widen upward unless an approved automatic base promotion changes the base first.

- Automatic placement tries canonical/front-facing placement before the permitted packing alternative. Compatible items may smart-insert at the highest valid place without reordering or rotating existing members.

- A larger compatible incoming item may become the base only when expanded reservation, support and clearance remain valid. This is automatic base promotion, not permission for manual under-base insertion.

- Manual placement may create broader mixed stacks on the visible top when physical rules permit. Current mixed/non-auto-coherent stacks reject later automatic insertion.

- Any visible member may be retrieved. Middle removal recompresses objects above deterministically; base removal promotes the next member and shrinks the reservation. Ownership mappings change coherently.

- Stacks use the accepted 95% headroom rule. A singleton instead checks full physical clearance without that stack multiplier. Closed/intermediate levels derive clearance from neighboring authored planes; open-top levels use explicit context caps.

The current registry contains boxed_food, flat_media, medical_boxes, round_cans and folded_clothing. The fifth group is approved for items 152–155 only, without bypassing fit, support or clearance. Explicit None is valid. Items 163–174 retain saved None with separate group approval pending at the published baseline. These are content/evidence facts, not a permanent limit on future deliberate group authoring.

Manual under-base insertion, multi-column packing on one support, broader display rotation and crouch remain separate deferred/open work. The pivot does not turn them into prerequisites for storage-goal scoring.

<a id="s_7_6_Installation_authoring_and_playe"></a>

### 7.6 Installation authoring and player freedom

The developer authors furniture choice, placement, dimensions, level count/distribution, unit Front and ladder availability. The player controls organization within those installations. Reusable ModularRack is a shelf-empty authoring scaffold whose local wrappers provide levels; it is not a universal rack silhouette or a player construction feature.

The favored new direction is to provide all storage installations from the start and remove storage-capacity progression. Exact roster and capacity remain unvalidated. Predetermined installation positions and the absence of free-form building remain compatible with that direction. The old moderate-starting-capacity/nightly-socket-upgrade plan is not the current default.

Whether any particular containers can move between compatible sockets remains unresolved inherited work. No unrestricted movement follows from the pivot. Departmental support floor does not become free Quartermaster storage merely because it is accessible. Sorting-table space and the carried bundle remain available for temporary maneuvering but do not count toward victory.

<a id="s_7_7_Ergonomics_labels_and_substantia"></a>

### 7.7 Ergonomics, labels and substantial occupancy

Use predominantly open, readable storage. Wall-fitted units generally need shallower usable depth; deeper units belong where multiple approaches provide access. Per-edge insets, shelf openings and headroom are authored per installation rather than imposed as a single percentage. Actual visibility, targeting and retrieval matter as much as mathematical fit.

Ordinary ground-access storage should work without a ladder. Selected taller installations may use the promoted fixed ladder: a fixed floor position, bounded vertical access and normal item interaction. That acceptance does not introduce jumping, mantling, movable ladders, shelf-top traversal or a fall system, and does not solve rear occlusion automatically.

Player-authored labels remain intended, with restrained tags, cards, tape, text or simple icons. Detailed editor, coverage, anchors and rendering remain open; naming support alone does not prove a complete label system. Preserve readable item silhouettes and useful shelf illumination.

A winning collection should feel substantial—roughly 80% occupied storage is the developer’s rough aspiration for an average run—but the exact occupancy metric and achievable assortment need testing. There must be room to manipulate, swap and retrieve near capacity. No score requires 80% and no perfect-packing solution is prescribed.

Basis: [G15 §§7,18.3]; [MVP §§5–6,16] for transfer/continuation; [VDD §§15,32–33]; [PIV §§2–3].

<a id="s_8_Facilities_submission_and_request_"></a>

## 8. Facilities, submission and request pressure

<a id="s_8_1_Supporting_material_flows"></a>

### 8.1 Supporting material flows

| **Consumer or destination** | **Categories / output** | **Current design role** |
| --- | --- | --- |
| Expedition loadout | Food, Hydration, Protection, Weapons, Morale (target) | Proactive bonuses to an individual expedition. The current mechanical fixture retains Medical in place of Morale and has no outcome bonuses. |
| Kitchen | Food and Hydration; potential physical Rations | Food and Hydration relieve a shared player carrying and sprint penalty. Rations remain an optional future conversion. |
| Medical | Medical | The Ward alone handles healing. Medical accelerates natural recovery of Light and Severe injuries. Treatment implementation remains open. |
| Bunker Ops | Fuel (possible future Energy framing) | Future finite greyouts affect bunker machinery and environmental lighting. |
| Workshop | Electronics for one-time purchases. Other materials and Salvage remain open. | Optional lasting improvement purchased with goods that might otherwise support the hoard. |
| Salvager | Item → physical Salvage | Spatially useful conversion; output grammar and yields remain to revalidate. |
| Incinerator | Item → no output | Deliberate permanent space release. |

<a id="s_8_2_Shared_selected_item_transaction"></a>

### 8.2 Shared selected-item transaction

Open a panel without spending; inspect the selected item’s eligibility, applicable Utility, credited amount and waste; submit through one distinct deliberate input. A category has one unambiguous applicable lane. The interface must not consume other carried items or choose an optimal combination for the player.

Retain whole-item cap-and-waste: credited Utility is the smaller of the item’s Utility and remaining need. Any excess on that accepted object is wasted, not retained for a later request or converted into an undisclosed bonus. Dispatch also charges the whole item’s Bulk. A full lane, ineligible item, closed request or over-capacity submission rejects without consumption.

For example, at 11/12 supplied, an eligible +8 item credits 1, completes 12/12 and wastes 7. The player may accept that waste to save handling time; the game does not require exact arithmetic matches. The preview must describe the actual commitment before it occurs.

A successful submission transfers the exact item once and records one contribution. Rejection preserves its prior owner and state. Notifications emitted during a tentative mutation are not proof of successful spending. Saving must not capture a half-completed transfer. Irreversible inputs are not temporary shelves and are not automatically returned on closing a panel.

Incineration follows the same exact-item transaction boundary. Its receipt records destruction without a Utility lane or credit. See §15.3 for access, input and confirmation.

<a id="s_8_3_Continuous_requests_with_bounded"></a>

### 8.3 Continuous requests with bounded escalation

**AGREED HIGH-LEVEL APPROACH.** Briefly deferring a request to finish another activity is legitimate; ignoring a department indefinitely should generally be costly. The working direction is persistent requests without ordinary short expiry windows, with a possible grace/wind-up interval before adverse effects intensify and persist until addressed.

Both outstanding work and penalties need understandable bounds. Kitchen's cumulative obligation, grace and proportional restoration are defined in §12. Fuel greyout boundaries are in §14. Other services retain their own open issuance and recovery rules.

An expedition with no loadout has its ordinary capabilities. Voluntary loadout buys advantages for that crew. Bunker services operate at baseline without an outstanding problem. Recurring contributions restore service under departmental rules. Kitchen affects player logistics. Fuel may delay bunker handover through the lift. Service obligations leave committed expedition duration, cargo, recruitment and injuries intact. Clearing a request is never a victory condition.

<a id="s_8_4_Definition_state_and_consequence"></a>

### 8.4 Definition, state and consequences remain separate

| **Concern** | **Retained contract / unresolved replacement** |
| --- | --- |
| Requirement source | Defines identity, lanes and targets. Kitchen uses its own continuous schedule in §12. Other service cadences need separate design. |
| Live state | Stores accepted contributions, lifecycle, penalty state and relevant timestamps. Loading must not regenerate an open obligation. |
| Submission | Validates and commits one exact item plus credit and Bulk where applicable. |
| Consequences | Use actual supplied state under a defined department rule. Kitchen gives equal relief per Utility credited to either lane. |
| Feedback | Shows current demand, accepted/projected contribution and comprehensible consequences. Qualitative world messages do not hide a request’s actual targets. |

The predecessor’s shared RequestDefinition / OutcomeProfile separation remains useful. It does not authorize generic framework expansion, a universal zero-percent catastrophe or reuse of old midnight outcomes. Different services may have different causes and effects while retaining the same physical transaction grammar.

<a id="s_8_5_In_progress_expedition_commitmen"></a>

### 8.5 In-progress expedition commitments

The player edits one logical draft. The first accepted whole item forms the selected crew and spends the item in the same transaction. A successful zero-loadout Dispatch forms the crew at departure. Both boundaries recheck Ready availability.

Closing the panel and continuing a saved run preserve count, affinity selection and accepted contributions. Count stays locked after formation. Affinities stay editable until departure. The next draft becomes available after dispatch.

<a id="s_8_6_No_dead_end_through_stacked_syst"></a>

### 8.6 No dead-end through stacked systems

Evaluate combinations of penalties, injury, depleted supplies, full carried capacity and storage congestion. Every ordinary allowed state must retain a clear route toward the goal. That does not mean every action is profitable or every setback brief. The useful question is whether the path exists under the rules—not whether the game invisibly makes the player catch up.

Basis: [PIV §§5.1,7–8]; [ADD]; retained [G15 §8] and [MVP §§4–5]; explicit boundary noted where approved source phrasing is not yet a complete lifecycle.

<a id="s_9_Scavengers_team_preparation_and_de"></a>

## 9. Scavengers, team preparation and destinations

<a id="s_9_1_Anonymous_productive_capacity"></a>

### 9.1 Anonymous productive capacity

Scavengers remain the only dynamically tracked population. Other bunker residents are inferred through departmental demand, messages and environmental context, not simulated individually. Display meaningful aggregate availability and active expedition records without requiring biographies, traits or a character-management layer.

The player needs to understand who is Ready, being prepared, away, waiting with cargo or recovering. Exact accounting and transition names remain technical/design work. A scavenger cannot be allocated simultaneously to two crews. No morning batch formation or next-day readiness gate remains in the target design.

Opening population, recruitment, population growth and any release cap remain OPEN under the pivot. Historical survival targets of three opening teams or six–seven teams around Day 60–70 are not current continuous-run calibration. More personnel can increase useful inflow and also create more provisioning and sorting work; they are not a survival-life counter.

<a id="s_9_2_One_current_preparation_not_a_pr"></a>

### 9.2 One current preparation, not a prebuilt roster

> CONFIRMED ADDENDUM: one team is assembled, equipped and dispatched at a time. No per-team loadout tabs and no parallel preparation of multiple teams.

The player selects a count from 1–4 scavengers, limited to the number currently Ready. They then equip that current team and select its destination in one broad Expeditions panel. After deliberately dispatching it, they may prepare another available team consecutively without needing to close and reopen the panel. Already dispatched expeditions can be active concurrently; preparation remains sequential.

Four available scavengers may be sent as one team of four, as three plus one, or in other permitted 1–4-member groups. The game does not pre-divide everyone, require full-four-first allocation, or maintain a set of morning loadout cards waiting to be serviced. This addendum supersedes both the pivot record’s tabbed preparation description and the earlier “provision all teams, then assign destinations” workflow.

| **Preparation element** | **Required meaning** |
| --- | --- |
| Scavenger count | Choose 1–4 from the Ready pool. Display available capacity honestly; do not permit double assignment. |
| Loadout | Five category lanes and all relevant information from the accepted M4 panel, not merely the sparse elements shown in the rough sketch. |
| Destination | Two distinct unordered affinity choices identify one archetype; show its name, expected category emphasis and current occupancy. |
| Dispatch | An explicit action sends the current crew. Reaching 100% provisioning does not auto-send. |
| Next crew | After dispatch, allow consecutive preparation of another team in the same session when personnel are available. |
| Other expeditions | Can be monitored as away/waiting/returning activity. Removing preparation tabs does not forbid a separate status overview. |

<a id="s_9_3_Preparation_UI_and_open_edit_bou"></a>

### 9.3 Preparation UI and formation

The full loadout and affinity selector belong in the same broader panel. Current and projected lane credit, waste, full item Bulk, used/raw capacity, remaining return capacity, selected item and eligibility feedback must survive the redesign. A high-level sketch is not permission to remove information that already proved useful.

The preparation panel and its zero-capacity warning stay live in the expedition playtest. ESC closes the warning or preparation before opening the pause menu. Physical fetching and carrying use the ordinary controls.

Draft edits reserve neither personnel nor a destination. First accepted supply locks the crew count and removes those members from Ready. Contributions remain spent. Cancellation, disbanding and resizing are outside this slice.

<a id="s_9_4_Twenty_eight_repeatable_archetyp"></a>

### 9.4 Twenty-eight repeatable archetypes

**PREFERRED MODEL.** Choose two different categories without ordering them. Eight categories yield 8 × 7 / 2 = 28 possible pairs, and the finite affinity catalogue has one named archetype per pair. Choosing Medical then Weapons is identical to choosing Weapons then Medical. Repeated selections and Primary/Secondary tiers are not the working model.

A destination name is a thin fictional wrapper around desired supplies, not a location the player must memorize. No clickable geography, individual-site exploration, finite visit count, loot depletion or bespoke ordinary danger/travel-time profile is required for each name. Repeated expeditions may visit the same archetype indefinitely.

Both chosen affinities receive the same mathematical bonus, communicated qualitatively—for example, “Potentially more Medical and Weapons loot.” Percentages and ranking are not shown. Incidental items from every other category remain possible; the team could encounter them en route or near its destination. Fiction supports the assortment without requiring a literal outside simulation.

The bonus changes the chance of selecting each category before fit filtering. Return capacity and authored item values stay fixed. The expedition playtest uses development pair labels and the category-first sampler in §10.5. Final names and production calibration remain open.

<a id="s_9_5_Alphabetical_resource_selector"></a>

### 9.5 Alphabetical resource selector

| **Top row, left to right** | **Bottom row, left to right** |
| --- | --- |
| Electronics · Food · Fuel · Hydration | Medical · Morale · Protection · Weapons |

The preferred frontend is a fixed two-row/four-column icon selector alongside the supply area. Two selected icons identify the destination and its description below. Alphabetical positions remain stable. Selecting one category leaves only valid partners selectable; an unavailable pair is disabled/marked with a short explanation. A category with no possible pairing is disabled before the first choice.

Selected icons must remain intelligibly deselectable. Names/tooltips and explanations complement icons and color. Requirements and affinities remain visually separate concepts: one describes supplies sent, the other the desired incoming assortment. No sorting of icons by shortages or invisible recommendation of an “optimal” choice is required.

<a id="s_9_6_Concurrent_exclusivity_and_reser"></a>

### 9.6 Concurrent exclusivity and reservations

One crew may be away at a destination. Selection and provisioning leave the pair available. Successful Dispatch occupies it until the crew returns.

A returned crew releases its destination immediately, even while it waits for cargo admission. Several waiting crews can share a destination and retain separate expedition identities.

Available partners follow the currently occupied pairs. The selector explains unavailable partners and keeps selected affinities deselectable. Dispatch rechecks availability and preserves the selected pair on rejection. Availability events and destination depletion are deferred.

<a id="s_9_7_Dispatch_incomplete_choices_and_"></a>

### 9.7 Dispatch, incomplete choices and expedition timing

Dispatch requires an explicit action with a valid crew and two distinct affinities identifying an available destination. Incomplete affinity selection disables Dispatch and explains the requirement. Zero provisioning is permitted.

Zero return capacity opens a confirmation before departure. Back preserves the preparation and receipts. Confirming revalidates the crew and destination, then commits an empty journey if still valid.

The expedition playtest draws one uniform 90–180 active-second journey at departure for every crew size and loadout. The exact return timestamp persists through Continue. Production duration and any provisioning or crew-size effects remain open.

<a id="s_9_8_Return_personnel_and_growth"></a>

### 9.8 Return, personnel and growth

Nonempty returns complete personnel handover when Receiving admits the cargo to either the active lift or the deposited queue. Crews awaiting a slot remain unavailable. Empty returns complete at the return timestamp. Every member in this slice returns healthy and becomes Ready at the applicable handover boundary.

Recruitment and permanent progression must be reconsidered without death-driven survival pressure. A larger workforce may be a useful investment, but no recruit frequency, acceptance timer, next-morning join or compulsory growth path is inherited. Persistent team-slot Training is specifically incompatible as written with disposable player-assembled crews; see §15.6.

Basis: [ADD] overrides [PIV §5.3]; [PIV §§4–6,8–10]; [ADR §5] only for independently retained affinity reasoning; [G15 §§9–10] for selected capacity/identity concepts, not daily lifecycle.

<a id="s_10_Provisioning_capacity_and_returne"></a>

## 10. Provisioning, capacity and returned loot

<a id="s_10_1_Retained_capacity_relationships"></a>

### 10.1 Retained capacity relationships

```text
TEAM BASE CAPACITY = selected members × per-member base capacity
BASE LANE TARGET = selected members × per-member lane requirement
OUTGOING BULK = sum of Bulk of committed whole loadout items
RETURN CAPACITY = Team Load Capacity − Outgoing Bulk
```

Equal-sized teams with equal applicable upgrades have equal base requirements and capacity. The new 1–4-person choice scales those values proportionally; no arbitrary heterogeneous scavenger stats or destination-specific equipment requirements are implied. Upgrades can deliberately introduce defined modifiers after their design is agreed.

A successful contribution spends the whole outgoing item immediately and charges its full Bulk against return capacity. Departure uses the accepted receipts and leaves the remaining capacity available for cargo.

<a id="s_10_2_Five_lanes_and_outcome_boundari"></a>

### 10.2 Five lanes and outcome boundaries

| **Lane** | **Retained contribution concept** | **Current outcome boundary** |
| --- | --- | --- |
| Food | Food goods and potential Rations | Increase that team's carrying capacity while charging full outgoing Bulk. Net headroom should reward useful provisioning. Formula, magnitude and validation order remain open. |
| Hydration | Drinks and water-category goods | Shorten that expedition. Lift admission and backlog still follow their own rules. |
| Morale | Morale goods | Increase recruitment opportunity in proportion to participating scavengers. Equal coverage and personnel totals should give comparable opportunity across team sizes. Rates, rolls, limits and joining remain open. |
| Weapons | Weapons/tools classified as Weapons | Prefer better Utility per Bulk within the selected category. Affinity weights and item values stay fixed. The quality curve and pool remain open. |
| Protection | Clothing/protective gear classified as Protection | Reduce injury chance. The Medical Ward owns healing. |

These five lanes define the intended loadout. The accepted mechanical fixture still uses Food, Hydration, Medical, Weapons and Protection. Its outgoing Bulk and lane costs are live. Outcome bonuses, recruitment and the Morale substitution remain future work. The example of zero baseline and five percent per member is illustrative.

<a id="s_10_3_Whole_item_contribution_and_eff"></a>

### 10.3 Whole-item contribution and efficient loading

The current accepted foundation charges the full Bulk of each submitted item, caps Utility at the remaining lane target, previews waste and rejects objects that exceed remaining capacity. Filling a lane stops further submissions to that lane. No surplus bonus or capacity discount is added.

Efficient provisioning preserves Bulk for incoming cargo. A crew can depart with zero return capacity after confirmation and can return empty when the remaining Bulk cannot fit a whole eligible item. Provisioning effects and economy balance remain open.

The old aspirations of roughly 50% capacity used by an ordinary loadout and 70–75% left by efficient loading are historical calibration examples, not targets this edition reaffirms. The M4 28 Bulk per scavenger and lane values 12/12/6/12/12 remain testing evidence only. New per-member capacities may be deliberately increased if useful for a substantial collection and manageable run length.

<a id="s_10_4_Return_amount_usefulness_and_as"></a>

### 10.4 Return amount, usefulness and assortment

Distinguish four matters: return capacity available; how much is filled; how useful the chosen items are for that Bulk; and which categories they represent. A larger capacity does not guarantee it will be filled, and equal returned Bulk can contain very different useful supplies.

The intended Weapons benefit biases the whole-item draw toward higher Utility per Bulk within the category chosen by the sampler. Affinities still determine category emphasis. The quality curve, fit filtering interaction and ordinary item availability need later validation.

Utility is the favored affinity measure, but physical footprint and handling load remain essential balance observations. High-Utility returns that fit too easily may undermine the substantial-hoard experience; abundant inefficient returns may create excessive handling or obstruct completion. Neither problem should be solved by Receiving deleting awkward objects.

<a id="s_10_5_Generation_and_commitment_contr"></a>

### 10.5 Generation and commitment contract

An upstream expedition outcome owns the selected items. It must respect the agreed capacity/selection rules and create durable identities. Receiving receives and presents that exact committed manifest. A backend preparation failure cannot reroll loot, change the outcome, replace hard-to-place items or reduce the manifest without a deliberate new design.

Precomputation is allowed only after the inputs the player may legitimately influence are fixed. It does not reveal hidden results, start a return early, occupy deposited lift slots or become an independent timer. Preserved outcomes survive save/load rather than being redrawn near arrival.

For this playtest the sampler draws a category first with weight 9 for each of the two affinities and 7 for each other category. With all categories eligible this is 15% for each affinity and 7/60 for each other category. Categories without a fitting item are removed, then one fitting definition in the selected category is drawn uniformly. Whole items fill the remaining Bulk until none fits. Duration, the exact manifest and a validated deck arrangement commit at Dispatch. These settings and the declared pool apply to the test configuration.

<a id="s_10_6_What_should_be_legible_to_the_p"></a>

### 10.6 What should be legible to the player

The player sees item Category, Utility, Bulk, lane completion/waste, assigned member count, outgoing and remaining capacity, destination affinities and relevant current status. Internal normalization and sampling weights need not be exposed. Narrative descriptions can contextualize outcomes without numerical modifier lists. Actual targets and valid choices remain concrete at the moment of commitment.

Basis: [PIV §§3,5,7]; retained [G15 §10] and [MVP §§5,12,21]; new formula/effect work remains open rather than inferred from survival tuning.

<a id="s_11_Receiving_and_waiting_expeditions"></a>

## 11. Receiving and waiting expeditions

<a id="s_11_1_Retained_freight_boundary"></a>

### 11.1 Retained freight boundary

Receiving remains a stationary shallow bay behind a permanent player barrier and moving shutter. The player stays on the apron and takes revealed objects; they do not board the lift or obstruct moving machinery. Arrival, opening, closing and departure cues imply unseen freight travel while the deck and enclosing walls remain fixed.

Receiving is TAKE-only. Its private presentation surfaces expose no PUT, zoning, player labels, manual placement, ordinary storage registration or visible gameplay grid. Cargo there never counts toward the stored collection objective. The decorative emergency-stop control remains noninteractive unless explicitly redesigned.

<a id="s_11_2_Uncapped_pending_returns_finite"></a>

### 11.2 Uncapped pending returns, finite physical presentation

> No midnight forfeiture, abandonment countdown or queue-overflow cargo loss. Waiting teams retain their cargo and remain occupied until the defined handover.

| **Layer** | **Retained or revised meaning** |
| --- | --- |
| Upstream committed haul | Exact items exist as data before presentation. Early preparation alone does not mean a team has returned. |
| Returned teams waiting to hand over | Effectively uncapped pending queue under the new direction. Each keeps its exact haul and unavailable personnel; backlog costs throughput and time. |
| Deposited physical queue | Existing owner supports one active plus two deposited FIFO loads. This is separate from pending team records; the pivot does not by itself enlarge physical capacity. |
| Active revealed load | Materialized objects are progressively taken from the apron. The lift waits for successful removal of all items. |
| After cargo handover | Admission completes crew handover. Healthy personnel become Ready, and injured personnel will go directly to Medical once that system is defined. Destination occupancy ended at return. |

A player can leave returning teams queued as long as desired. The cost is tied-up productive capacity and a longer completion time, not missing goods. The waiting cargo itself cannot complete the goal. Clearing the lift and keeping storage workable makes the workforce useful again.

The all-destinations-busy case and the all-crews-waiting case must be legible, but they are not terminal failures. A full cargo queue is a consequence of activity management. Item handling, legal disposal and the eventual crew-release rule must prevent it from becoming an irreversible dead end.

<a id="s_11_3_Six_state_lift_cycle_retained"></a>

### 11.3 Six-state lift cycle retained

| **State** | **Player-facing and ownership behavior** |
| --- | --- |
| SEALED_EMPTY | Shutter closed and TAKE disabled. During outbound turnaround the visible IDLE state still means the machinery is busy. |
| ARRIVAL | Arrival cue and amber warning. Committed cargo is not pickup-enabled. |
| SEALED_READY | Exact cargo is staged behind the closed shutter and transitions when preparation is ready. |
| REVEALING | Opening motion and cue; TAKE remains disabled until fully open. |
| OPEN | Normal targeting/TAKE enabled; steady green. Waits indefinitely for every active item to be removed successfully. |
| CLOSING | Last successful TAKE starts closing, impact/latch and the full cue. Complete outbound turnaround precedes retirement and the next FIFO load. |

Failed pickup or a full carried bundle cannot drain cargo, close the shutter or release capacity. Last TAKE is not itself deposited-slot release. Empty fixtures and drained active ownership persist through closing and outbound turnaround; then retirement, promotion and admission follow their existing causal order. Opposing journeys do not overlap.

An available deposited queue slot can accept a new haul while the active load is OPEN. Full-turnaround retirement is not a blanket prohibition on queued admission during unloading. Oldest eligible waiting returns retain priority over new arrivals.

<a id="s_11_4_Exact_identity_and_deterministi"></a>

### 11.4 Exact identity and deterministic cargo arrangement

Expedition owns content; Receiving owns presentation and deposited lifecycle. LootBatch retains unique item identities, ordered entries and content commitment separately from accepted placement transforms. Reusing a seed can reproduce a selection, but must not reuse instance identities. Reloading a revealed batch restores its remaining entries and arrangement, not a newly generated equivalent.

The promoted presenter uses front crates, rear pallets and useful loose MainDeck cargo. Ordinary WorldItem and legal stack TAKE behavior operate on private surfaces. Enabled fixtures start with cargo; empty fixture visuals persist until concealed retirement. All committed items must become reachable through progressive ordinary TAKE from supported apron viewpoints.

The irregular frozen-pile experiment remains rejected production research. Describing incoming assortments as messy does not authorize resurrecting hidden rigid-body settling, support graphs or a new pile solver. The sorting challenge is the mixed collection and subsequent arrangement, not a requirement for physically chaotic cargo.

<a id="s_11_5_Current_physical_baseline_and_f"></a>

### 11.5 Current physical baseline and feedback

The published prototype’s MainDeck has 3.30 × 2.00 m usable area, 33 × 20 cells at 0.10 m, and profile revision 4. Physical support is approximately 3.441 × 2.100 m with authored margins. Fixture-integrated Receiving TAKE reach is 3.4 m; ordinary loose and storage/manual reaches are 1.4 m and 2.3 m. These are established prototype metrics, not final collection-game capacity promises.

The read-only freight CRT reports lift status, individual remaining active cargo entries and deposited QUEUE 00–02. That count does not include upstream waiting crews. Any wider monitor must distinguish deposited cargo from waiting expeditions rather than silently relabeling the existing count. Basic accepted queue information is not removed to sell it back as an upgrade.

Localized W1 warns amber during arrival/staging/opening, shows green while OPEN and is off during closing/idle. Existing authored sounds, shutter contact and full-cue handoff remain the presentation baseline. A faster game may eventually justify explicit timing changes, but no such retiming or art edit is authorized by this document.

<a id="s_11_6_Open_handover_boundary"></a>

### 11.6 Handover and empty returns

Successful admission to the active lift or the deposited queue completes nonempty handover. The healthy crew becomes Ready once, while Receiving owns the cargo. An awaiting crew remains unavailable and its destination is free for another departure.

Empty outcomes complete in Expedition at their return timestamp without creating a batch or occupying a lift slot. Future triage uses the handover boundary. Healthy members go Ready and injured members go directly to Medical. Injury and treatment rules remain open.

Basis: [PIV §6]; [ADD] for sequential preparation context; retained [G15 §11], [MVP §§6–8,16] and [VDD §§13,34.7] except explicitly removed midnight loss.

<a id="s_12_Kitchen_and_ration_conversion"></a>

## 12. Kitchen and ration conversion

<a id="s_12_1_Retained_identity_redesigned_ca"></a>

### 12.1 Retained identity, redesigned cadence

Kitchen remains the dedicated Food/Hydration consumer, separate from Ops, and may also convert selected Food into standardized physical Rations. Its purpose is to support the operating loop while creating meaningful use for stock that could otherwise count toward victory. It is not a cooking or serving minigame.

The local continuous Kitchen uses independent active-time demand and a cumulative obligation under §12.2. Fixed meals and daily Meal Coverage remain historical evidence. The prototype keeps the original 20-Bulk normal capacity and six-Utility goal per category. Kitchen only affects player logistics.

<a id="s_12_2_Demand_and_consequences_remain_"></a>

### 12.2 Continuous demand and proportional relief

Kitchen maintains one cumulative obligation with separate Food and Hydration balances. Opening from zero starts one 60-active-second grace. Additions join the remaining balances under the same deadline. Further demand increases an overdue penalty immediately. Only clearing both lanes closes the obligation and restores sprint. A later opening starts a fresh grace.

The provisional schedule draws uniform integer intervals of 180–300 active seconds, including the first trigger. Each next trigger is measured from the scheduled event time. Each event draws a uniform total of 60–80 Utility, then a uniform feasible integer Food share. The iteration interprets the 25% gap as larger lane at most 1.25 times smaller lane. Timing and amounts use separate random streams that advance even at the cap. Contributions leave the schedule unchanged. Continue preserves it, including through pauses and offline time. Kitchen stays live after victory.

After grace, each 3 outstanding Utility costs one percentage point of normal carrying capacity. At combined demand D, effective capacity is floor(normal capacity × (300 − D) / 300). Grace preserves capacity and sprint. Overdue demand disables sprint while ordinary walking and ladders retain their baseline. The bound of 150 Utility limits loss to 50%. Each incoming addition uses proportional whole-Utility clipping. The iteration assigns largest remainders first and alternates exact ties by scheduled event index, odd favoring Food. Discarded overflow never returns.

<a id="s_12_3_Rations_as_a_retained_conversio"></a>

### 12.3 Rations as a retained conversion candidate

Rations can strengthen the physical-selection loop by compacting disparate Food into standardized, readily stackable objects. Retain the concept rather than its nightly production schedule. Inputs are physical and committed; outputs are new physical objects collected at a bounded point, not a virtual account.

The predecessor’s useful constraints remain reference material: Rations can serve Food requirements, should not be recursively fed back as production inputs, and can improve Bulk/Footprint efficiency. A Food-Utility gain, price, work interval, capacity limit and output quantity require new balance validation. A processing cap need not be daily in a game without days; no replacement cooldown is selected here.

Whether and how Ration output contributes to the Food storage objective must be defined alongside its category and values. The conversion cannot become an unexplained exception to stable item definitions or generate infinite Utility through recursive processing. Output blocking, partial batches and paused/save behavior remain OPEN.

<a id="s_12_4_Space_and_community_presentatio"></a>

### 12.4 Space and community presentation

The Kitchen Service Room remains an enterable, elongated catering-support space with an opaque boundary to unseen cooking and dining areas. A competent chef and helpers can be implied through practical messages, warm service cues and fixed non-loot equipment. No empty staffed interior, visible residents or autonomous tray simulation is needed.

The existing Gallery B approach leads to the service frontage. F opens or toggles the live panel, E commits one eligible selected whole item, and Escape closes the panel first. The panel shows both balances, grace, active or pending percentage loss, sprint and the selected item's applied credit and waste. Percentages display up to two decimals. Capacity uses the exact ratio. Notices report admitted demand, expiry and clearance. The carry HUD shows actual Bulk over the effective limit. Existing carried ownership and failed-transfer rollback remain legal above that limit. New pickups must fit. Settle expiry, then the addition, then input at a shared timestamp.

Basis: [PIV §§7,9–10]; retained concepts [G15 §12], with daily demand/outcome formulas superseded; [VDD §19].

<a id="s_13_Medical_and_workforce_availabilit"></a>

## 13. Medical and workforce availability

<a id="s_13_1_Purpose_under_the_collection_ob"></a>

### 13.1 Purpose under the collection objective

Medical spends Medical-category goods to shorten the time scavengers are unavailable, thereby returning productive capacity to expeditions sooner. This is a direct contribution to faster acquisition and completion, not an additional win condition or a survival-loss system.

Patients remain anonymous. The player need not individually assign medicines, manage named characters or operate a treatment minigame. Aggregate state and clear recovery information can remain sufficient; exact patient/cohort bookkeeping should be only as detailed as the agreed mechanics need.

<a id="s_13_2_Preferred_simple_recovery_appro"></a>

### 13.2 Preferred simple recovery approach

**MEDICAL DIRECTION.** Light and Severe injuries recover naturally at a slower rate. Medical treatment in the Ward substantially accelerates return to duty. The Ward alone handles and modifies healing. Kitchen Food and Hydration affect neither healing speed nor success. Ordinary recovery remains available when no crew can leave for supplies.

The developer is disinclined to send injured people on expeditions. Re-injury, altered carry capacity and special loadout rules would add simulation mainly to support that exception. Do not introduce them by assumption. Routine fatalities are likewise disfavored under a design that must never exhaust all progress routes; final injury states and personnel outcomes still need specification.

Poor management can mean a prolonged slow operation or substantial corrective work. Natural recovery is not a promise of a short wait, automatic full stock replenishment or guaranteed parity with an efficiently played run. The no-dead-end requirement and the speed of recovery are different design concerns.

<a id="s_13_3_Decisions_needed_before_impleme"></a>

### 13.3 Decisions needed before implementation

| **Open point** | **Boundary already known** |
| --- | --- |
| Injury states and durations | Exact severities, rates and recovery times are undefined. Do not copy Light/Severe daily stage counts or death curves. |
| Treatment cost and application | Medical accelerates useful availability. Per-patient versus pooled accounting, partial contribution, when the benefit applies and any limits remain open. |
| Natural recovery and supplies | The basic recovery path must not depend on supplies obtainable only from the people who cannot leave. |
| Return admission | When injured crew leave the waiting-cargo state and enter Medical must align with the defined handover. |
| Other departmental effects | Healing belongs to the Ward. Keep untreated recovery available without Kitchen or other service supply. |
| Communication | Explain current unavailable counts, treatment requirements and meaningful expected recovery without inventing outcome certainty. |

The old first-treatment-next-day restriction, oldest-Severe daily triage, retained one-of-two-unit stage progress, midnight treatment-success rolls and escalating fatal complications are superseded as active rules. They remain in the predecessor for historical reference. Choosing any corresponding continuous mechanic later requires its own design justification.

Light injuries worsening is an independent candidate to assess on gameplay merits, not a workaround required to force a terminal failure. This collection design does not need all injured people eventually to die.

<a id="s_13_4_Presentation_and_protected_serv"></a>

### 13.4 Presentation and protected service space

Medical’s fixed red identity is retained, with redundant text/icon/audio rather than color alone. The Supply Anteroom stays a usable support space rather than a treatment ward or empty hospital set. Patients and staff are unseen. The protected approach is not default overflow storage.

Exact equipment, interface layout and revised route length remain later design/authoring. Current accepted geometry and materials are evidence to preserve until deliberately changed, not proof that long travel is appropriate for faster continuous treatment decisions.

Basis: [PIV §§5,7–8]; [G15 §13] for retained anonymous/service-space context and explicitly superseded daily rules; [VDD §18].

<a id="s_14_Bunker_Ops"></a>

## 14. Bunker Ops

<a id="s_14_1_Physical_support_for_the_unseen"></a>

### 14.1 Physical support for the unseen settlement

Fuel is the planned recurring Ops input. Electronics moves to one-time Workshop upgrades. Morale has a prospective expedition role. Uneven sinks are intentional, including the potential for Electronics to accumulate faster.

Greyouts are finite and separated by meaningful powered intervals. Repeated rolls and accumulated debt cannot sustain one indefinitely. Fulfilling pending Fuel ends an active greyout immediately. Run time and outside expeditions continue. Salvager operation and Workshop work suspend at defined boundaries. Preserve funded progress and cargo.

<a id="s_14_2_Lane_consequences_require_redes"></a>

### 14.2 Fuel greyout direction

| **Category** | **Current design direction** | **Current constraint** |
| --- | --- | --- |
| Fuel | Dim environmental lights and suspend relevant bunker machinery. | Restore authored light intensity on recovery. Preserve UI brightness, targeting, identities and handling assistance. The Incinerator remains usable. |
| Electronics | One-time Workshop investment. | Preserve essential goal visibility and baseline information. |
| Morale | Future expedition recruitment bonus. | Rate and joining details remain open. Recurring Ops is no longer its designated role. |

Idle stays closed and available queue slots can accept a return. ARRIVAL finishes descent and holds at SEALED_READY. Hold before opening at SEALED_READY where practical. If that narrow boundary cannot be intercepted reliably, finish REVEALING to OPEN. A revealing lift finishes opening. OPEN allows normal TAKE and holds after the last TAKE before CLOSING. CLOSING finishes to a stable closed state before holding outbound pickup.

A later stable boundary is acceptable where a fragile mid-transition interruption would otherwise be needed. Allowing outbound already in progress to finish is a recommendation. Exact chronology, slot integration, theatre resumption and persistence require the Fuel milestone. Environmental dimming may make identifying stock slower by requiring a closer look or a different viewpoint. The effect has no target delay in seconds.

<a id="s_14_3_Deferral_investment_and_the_fin"></a>

### 14.3 Deferral, investment and the final push

Supplying Ops can compete with retaining category progress or buying an upgrade. That is useful when maintenance earns its resource and handling cost. A short delay while organizing can be reasonable; indefinite neglect should generally be slower or less effective. A player near victory may still choose to tolerate a current penalty rather than spend the final items.

Do not make “Ops satisfied” a hidden win predicate. Do not automatically scale demand to undo good performance or erase the benefits of a larger reserve. Exact balance must be established through the continuous collection loop, not the old survival equilibrium.

<a id="s_14_4_Administrator_and_spatial_ident"></a>

### 14.4 Administrator and spatial identity

The Administrator remains off-screen and communicates through brief practical one-way messages. The Transfer Landing is an open, dedicated onward-distribution space, with the submission interface distinct from an opaque personnel-sized door implying the wider settlement. No office interior, visible leader or new dialogue system is needed.

The longer Deeper-Bunker route is the current layout baseline. Fuel-to-Energy naming, service naming, new catalogue items and reassignments remain future authoring. Any reframing uses the existing category slot. Batteries, power banks and compact generators or panels are candidates for physical loot. Charge, generation, renewables and permanent benefits from ordinary Fuel submission remain outside the current direction.

Basis: [PIV §§2,7,9]; [G15 §14 and §15.10.6] for historical lane/context references; [VDD §20].

<a id="s_15_Salvage_incineration_Workshop_and"></a>

## 15. Salvage, incineration, Workshop and upgrades

<a id="s_15_1_Choosing_what_not_to_keep"></a>

### 15.1 Choosing what not to keep

| **Action** | **Value to the collection** | **Cost** |
| --- | --- | --- |
| Retain / reorganize | Keeps live goal contribution and future options. | Uses limited storage and attention; may displace a better assortment. |
| Consume for a useful obligation | Supports operations while freeing physical space. | Removes the item’s live progress if it was stored. |
| Salvage | Turns an inefficient object into useful physical project material. | Destroys its original Utility and still requires storage/handling for output. |
| Incinerate | Immediately releases physical capacity with no output. | Permanently sacrifices all remaining direct and conversion value. |

None is automatically correct. A low-density item can be crucial while its category is short and an obvious candidate for consumption or disposal once better goods arrive. The game supplies facts and constraints; it does not mark legitimate goods as junk or instruct the player which sentimental hoard must go.

<a id="s_15_2_Salvager_and_output_pressure"></a>

### 15.2 Salvager and output pressure

Retain the concept of instant conversion into standardized, efficiently stackable physical Salvage. Exact yields and the new project economy are OPEN, and “instant” describes the inherited candidate rather than a validated release throughput figure. Stored intermediate material still occupies space while the player saves for a project; it is not a free invisible bank.

Output capacity and ownership must be designed so that input is not accepted into an impossible transformation. Rejection or a defined blocked state must preserve exact commitments; no silent deletion, duplicate output or magical return to shelves is acceptable. This is an ownership requirement, not a prescribed new queue architecture.

The relationship of Salvage to the unified category grammar and eight goal totals needs an explicit decision. Do not count unclassified intermediate value as Electronics or another target merely because an upgrade eventually uses it.

<a id="s_15_3_Incinerator_and_working_space_r"></a>

### 15.3 Incinerator and working-space release

**CONFIRMED.** The Incinerator is available from the beginning of every run. It has no unlock, repair, Fuel cost, cooldown or throughput limit. Energy blackouts leave it usable. It accepts any valid portable item the player is carrying, including items with zero Utility and future carried Rations or Salvage when those objects exist. The player picks up and carries the item to the machine under the ordinary carrying limits.

Aim at the machine and press F to inspect the selected item's name, category, Utility and Bulk. A distinct E press attempts to destroy one selected whole item. The red action label states that destruction is permanent and yields no output. A successful action frees the item's Bulk immediately and leaves the panel open.

On the first valid E attempt in a run, show this warning. “Incinerated items are permanently destroyed! This is a one-time warning.” Mark the warning shown when it appears. Back or Escape clears the command and retains the item. Continue is a separate action that revalidates the original item, its selection and ownership, and station access before destruction. Later distinct E presses destroy one item each. Held input cannot replay a command. Separate Escape presses close the warning, close the panel and then open pause.

The panel and warning own movement and handling input while the simulation stays live. The clock, expeditions, autosave and lift keep operating. Retrieval from qualifying storage already subtracts the item's live Utility. Incineration leaves the live totals and first victory record intact. Continuation preserves the shown flag even after Back and keeps a receipt for each destruction. Pending confirmation is transient. A new independent run resets the flag and receipts.

Single-item disposal is the approved scope. If mass disposal is adopted later, it will take the entire carried bundle with a fresh confirmation each time.

<a id="s_15_4_Workshop_purpose_and_project_me"></a>

### 15.4 Workshop purpose and project mechanics

Workshop remains player-initiated investment. Electronics funds one-time purchases, with one purchase per tier if tiers are used. A useful early investment can improve carrying, acquisition or information. Costs and roster remain open, including the role of other materials.

The Workshop needs redesign. Its old one-active-project, Salvage/material funding, productive-nights and Meal Coverage framework is historical specification—not automatically a complete continuous project system. Project concurrency, recipes, work timing, installation states and cancellation require explicit decisions. No visible workers or construction simulation are required by the concept.

Within-run progression remains the inherited direction. No cross-run unlocks, permanent meta-currency, duplicate research charges, infinite upgrade ranks or recurring maintenance are approved merely to give Workshop activity. The absence of an endless survival goal may make a finite meaningful project roster sufficient.

<a id="s_15_5_Candidate_improvements_and_info"></a>

### 15.5 Candidate improvements and information baseline

| **Family** | **Retained possibility** | **Boundary** |
| --- | --- | --- |
| Player carrying | More carried Bulk and clearer handling of a bundle. | No physical vehicle or movement-speed change assumed. |
| Expedition capability | Capacity, requirements, time or other acquisition advantages. | Exact ownership and effects open; no slot-based carryover by default. |
| Electronics / information | Extra monitors, distributed repeaters and richer comparisons. | Must extend useful baseline awareness; never gate or disable live collection-goal information. |
| Sorting or conversion convenience | Possible staging/output improvements or Ration throughput. | Needs evidence that it supports handling rather than adding chores. |
| Storage capacity | Now disfavored; likely all installations available initially. | No nightly capacity-unlock progression imported from the old GDD. |

Optional displays may help the player inspect request state from another working area, see returning crews or compare incoming/consumed category totals. Those are candidates, not a required statistics suite. Existing lift queue data is not removed and resold. Exact project roster, costs, device sockets, tutorial and accessibility treatment remain open.

The old clock-repair tutorial and additional day clocks need reinterpretation without daily anchors. Do not create a paid requirement to see active run time or collection progress. Building a light with Electronics also does not automatically settle its future outage owner; penalty design is separate and unfinished.

<a id="s_15_6_Training_Readiness_retain_prove"></a>

### 15.6 Training / Readiness: retain provenance, redesign ownership

The predecessor’s tentative Training service was proposed to give Weapons and Protection another useful sink without theft, raids or disturbing stored possessions. It invested in permanent Team 1/Team 2 slots while daily personnel changed. One guaranteed training day and next-morning benefit were confirmed within that older tentative feature.

That exact model no longer fits: teams are player-assembled for each current preparation, there is no morning roster and no day boundary. This edition does not invent persistent preparation slots, per-scavenger skills, named staff or universal bunker doctrine to replace it. **Training is OPEN / REASSESS under the pivot.** The old slot rules and timing remain historical, not implementation requirements.

Potential expedition improvements are still useful design material. Their costs, ownership, duration and opportunity cost must be chosen afresh if a Training feature is retained. A service frontage remains a presentation possibility rather than approved new geometry. Security/theft remains a parked alternative, not a source of hidden inventory loss.

<a id="s_15_7_Machinery_and_authored_changes"></a>

### 15.7 Machinery and authored changes

Salvager and Incinerator remain distinct front-operated, building-connected landmarks, with a Workshop-associated spur and a separate deeper-bunker spur in the current layout. Their separation can make conversion versus destruction deliberate. Exact route distances and service geometry are open to the broader spatial investigation.

Any future repair or project installation must apply an explicit persistent change to designated authored content. Removing the night transition leaves presentation timing unresolved; do not silently introduce whole-room pop-in, arbitrary furniture placement or automatic rearrangement of player stock.

Basis: [PIV §§3,7,9–11]; retained [G15 §§15.1–15.10]; [G15 §15.11] explicitly historical/redesign after [ADD]; [VDD §§17,21,23].

<a id="s_16_Feedback_interface_and_audio"></a>

## 16. Feedback, interface and audio

<a id="s_16_1_Essential_information_is_baseli"></a>

### 16.1 Essential information is baseline

The player must have dependable access to live stored totals for all eight categories and their common target. This information is never gated behind an upgrade or disabled by penalties/events. The exact HUD-versus-diegetic presentation is still open; essential functionality is not.

Distinguish notification from overview. While working away from a department, the player needs a reasonable way to discover new work and a dependable place to inspect it. Local lights and sound alone were insufficient in the earlier wing playtest; a monitor that requires continuous watching is not a complete notification system.

| **Surface or function** | **Information to retain or provide** |
| --- | --- |
| Goal progress | Eight current qualifying category totals, target and current satisfaction; immediate completed-run status when all coincide. |
| Carried strip and item inspection | Active selected item, category, numeric Utility, Bulk, carried capacity and relevant fit/stack cues. |
| Request panel | Actual active lane targets, supplied amounts, selected-item applied/wasted contribution and meaningful current consequences. |
| Current expedition preparation | 1–4 selected members; Ready availability; all five lanes; raw/outgoing/return Bulk; item eligibility; two affinities; explicit Dispatch. |
| Expedition / receiving overview | Away and waiting activity, occupied workforce, relevant cargo status and clear separation of waiting versus deposited loads. |
| Medical / Workshop status | Only actual defined recovery/project information. Do not display speculative benefits or guaranteed times before rules are chosen. |
| Active-time display | Real-world elapsed active run time, with pause policy understood; no simulated-day clock required. |

<a id="s_16_2_Single_team_preparation_panel"></a>

### 16.2 Single-team preparation panel

No per-team loadout tabs, carousel of prebuilt morning teams or parallel provisioning mode is part of the target UI. The broad panel presents the current assembled team, its loadout and affinities together. It supports consecutive preparation after dispatch, while other teams operate independently in the background. A separate activity overview can show them without reintroducing editable pending loadouts.

The 2×4 alphabetical affinity grid and full supply area remain the preferred arrangement, but final dimensions, labels and icon treatment are not locked by the rough sketch. Distinguish resources going out from affinities sought on return. Disabled combinations need explanations. The tentative non-pausing behavior must be tested under actual single-team use.

<a id="s_16_3_Retained_feedback_and_input_saf"></a>

### 16.3 Retained feedback and input safeguards

Current prototype feedback distinguishes applied gains, waste, ineligible/capacity rejection, a fulfilled lane and a terminal dispatched state. The exact art can evolve, but those distinctions should remain readable. Numeric Utility remains authoritative when pips become impractical at larger values. Color reinforces icons and text rather than carrying meaning alone.

A UI transition must not silently redirect a selected item, repeat held consumption or commit through another overlay. F opens without spending; distinct E submits one selected object; ESC closes a contribution panel before a subsequent pause-menu action. Retained pause ownership prevents closing one modal from resuming a different modal’s pause.

<a id="s_16_4_Journal_and_optional_analytical"></a>

### 16.4 Journal and optional analytical information

A diegetic Journal/ledger or workstation display remains a useful record concept. It can retain received messages, meaningful operational history and actual outcomes. It is not required to reproduce a Day+1 tab or daily report grouping after the calendar is removed. Event and message records describe existing state; opening the Journal does not generate or resolve outcomes.

If historical messages are retained, preserve what the player was told at the time rather than rewriting an early ambiguous message as a precise forecast after the fact. Aggregated trends and comparative displays are optional convenience candidates. They may help interpretation without creating a required spreadsheet-management layer or hiding essential goal information behind upgrades.

<a id="s_16_5_Departmental_identities_and_the"></a>

### 16.5 Departmental identities and the bunker as interface

Medical retains red as its established signal identity. Other fixed colors, symbols, blink patterns and audio identities need a coherent final language. Place ordinary commercial/office monitors above or beside the working surface, not in the usable sorting area. A directly legible in-world screen is preferred where practical; enlarged interaction views remain an accessibility/readability option.

The freight CRT’s deposited count and localized W1 remain accepted presentation. Other notices and repeaters can extend awareness, but frequent overlapping messages must not obscure item handling or make the busiest moments unreadable. Current operational changes and actual requirements must remain understandable before a consequential commitment.

<a id="s_16_6_Audio_priorities"></a>

### 16.6 Audio priorities

Freight travel, latch, shutter and machinery cues create anticipation without a moving physical lift. PA/radio remarks and restrained distant Kitchen/Workshop activity imply the wider community. Normal occupied areas should not be dominated by combat gunfire or threat cues. Contextual speech needs repetition control and subtitles; functional warnings should be distinguishable from flavor.

The four human-authored freight cues and full-turnaround relationship remain the accepted baseline. Their old durations are not new balance prescriptions for the continuous loop, and this document does not remix or replace them. Audio and lighting are contextual owners, not alternate clocks or authorities over item state.

Basis: [PIV §§2,5–6,9]; [ADD]; retained [G15 §16], [MVP §§5,9,21.2–21.4], [VDD §§7–9,13–14,34.7].

<a id="s_17_Narrative_and_unseen_world_presen"></a>

## 17. Narrative and unseen-world presentation

<a id="s_17_1_Inference_rather_than_simulatio"></a>

### 17.1 Inference rather than simulation

The outside and the wider settlement are inferred through item assortments, what departments need, short messages, equipment status and outcomes. The player does not see refugees, distant expeditions, bunker expansion work or staffed interiors. Fiction can support a gameplay effect without simulating each causal step.

Choose effects on gameplay merits, then give them a suitable broad explanation. Do not change an effective consumption rule solely because a particular story detail would imply a narrower effect in real life. Conversely, a narrative mention does not authorize extra casualties, new patients or another modifier that was never designed.

<a id="s_17_2_Tone_and_category_fiction"></a>

### 17.2 Tone and category fiction

Keep dry workplace humor, competent staff and practical familiarity. The Administrator is not a newcomer’s mission-giver, and the chef and Workshop staff need not be made incompetent to supply jokes. The apocalypse is contextual, while the Quartermaster’s workplace remains dependable.

Destination names support their two affinities without implying that every off-affinity object is impossible there. Crews travel through other places and collect incidental useful goods. There is no need to produce a bespoke site backstory, map or danger profile for all 28 pairs.

Qualitative messages can describe better finds, delays, a service problem or a repaired installation. They need not reveal internal percentages, quality bands or terms such as Utility Density. The actual item Utility and request targets still remain concrete through the normal interface.

<a id="s_17_3_Optional_reactions_and_portrait"></a>

### 17.3 Optional reactions and portraits

A lightweight data-driven PA reaction system remains a deferred possibility, not an initial requirement. It could recognize a conspicuous contribution pattern—many sports goods used as Weapons, repeated foods or unusually wasteful loadouts—and provide a brief flavor-only remark. It must not create a hidden efficiency bonus or another objective.

The inherited candidate limits remain useful: prefer the most specific rule, at most one reaction per completed request, probability/cooldown/repetition controls, original lines and subtitles. Remove references that require daily meals, contamination or unsupported penalties. Optional 2D face cards can imply identity without visible characters or branching conversation.

<a id="s_17_4_Ambient_dog_tentative_non_mecha"></a>

### 17.4 Ambient dog: tentative, non-mechanical

The predecessor’s one ambient dog remains a tentative scope candidate, not confirmed release content. If retained, it is companionship/atmosphere only: no hunger, health, injury, death, loss, Morale, Utility, buffs, labor, commands, mandatory petting or progression. Do not threaten it through a bunker consequence.

Use safe low-traffic authored regions and lightweight behavior; it has no gameplay collision authority. A mostly stationary role is a simpler fallback if navigation costs too much. The former Day 2/Day 3 arrival is obsolete; a continuous-run introduction has not been chosen. Its presence must not become a dependency for the collection objective or current implementation.

<a id="s_17_5_Messages_history_and_events_aft"></a>

### 17.5 Messages, history and events after the pivot

The ADR warning catalogue and its whole-day forecasts are parked. Removing destination-closure events does not require silence in the world, but it does not authorize another scarcity director through narrative messages. Any retained event needs a deliberate current purpose and defined effects.

The Journal can preserve short operational messages and accepted consequences while fixed decorative evidence remains in place. No automatic prop rearrangement, unseen theft, raids on sorted possessions or visible population simulation follows from the higher-paced loop.

Basis: [PIV §§1,4,7,9]; retained [G15 §§4.3–4.5,17]; [ADR §§3–4,10] as parked provenance; [VDD §§2,8–9].

<a id="s_18_Technical_content_and_persistence"></a>

## 18. Technical, content and persistence boundaries

<a id="s_18_1_Extend_the_foundation_do_not_as"></a>

### 18.1 Extend the foundation, do not assume a rewrite

The reported development baseline is Godot 4.7 with the Compatibility renderer. That is a project evidence fact, not a claim about the latest engine release. Local tasks verify the installed executable, actual checkout and current authoring state. The asset-equipped Windows checkout remains separate from read-only published repository access.

Keep one authoritative owner for each gameplay concern. The pivot changes policy and lifecycle but does not require replacing the accepted carrying/storage, contribution transaction, Receiving, identity or continuation architecture by default. Technical investigations should follow a concrete dependency rather than treating a design reset as permission for broad cleanup.

<a id="s_18_2_Type_data_instances_and_represe"></a>

### 18.2 Type data, instances and representations

| **Owner / concept** | **Retained responsibility and change boundary** |
| --- | --- |
| ItemDefinition | Authored type data: Category, Utility, Bulk, Footprint, pose, support and source references. Unified Item Category is intended; existing contextual fields need explicit migration, not a silent runtime reinterpretation. |
| ItemInstance | Durable physical identity and type reference. Survives changes between world, carrying and storage until consumed/converted/destroyed. |
| WorldItem / held visual / HUD | Represent an existing instance in a permitted context. They are not extra copies or source-of-truth inventories. |
| Storage owner / stack | Owns exact reservation, membership, transforms, orientation, zoning and legal placement. Presentation does not decide goal eligibility. |
| LootBatch / upstream return | Owns exact committed items and return identity. Content and preparation/arrangement remain separate commitments. |
| Requests and prepared expedition | Owns accepted receipts, lane credit and applicable Bulk/state. New single-team lifecycle must preserve those commitments coherently. |
| Receiving manager / admission / theatre | Deposited lifecycle, upstream fairness and display/gating are separate responsibilities; remove midnight forfeiture through a later explicit change. |

<a id="s_18_3_Authoring_and_catalogue_preserv"></a>

### 18.3 Authoring and catalogue preservation

Item authoring follows Scale → Storage Pose → Footprint → Stack Role → Auto Group. Tooling can suggest geometry, but human review controls intended fit/support and deliberate exceptions. Runtime eligibility is not read from an authoring-review manifest. Source fingerprints and approval state are evidence, while saved ItemDefinitions are gameplay data.

The current catalogue has 167 active definitions, seven permanently retired IDs and 174 retained source models. Scale, canonical pose/+Z Front, Footprint and support roles are accepted for the active set; twelve separate Auto Stack Group approvals remain pending with saved None. Retired suffixes are 005, 023, 024, 034, 036, 037 and 042 under the loot_000 prefix. Do not recycle IDs or resurrect the old Gloves/Pants sources because new Leather Gloves/Wellies exist.

Preserve developer-authored names, scale factors, footprints, poses, support decisions and intentional geometric overhangs. A new economy target does not authorize regenerating physical metadata from meshes. Numerical rebalance is a separate decision, and the M4 testing packet remains reproducible.

The existing item pose workbench is res://gameplay/dev/item_storage_pose/item_storage_pose_authoring.tscn. Source assets, ignored imports/caches and commercial originals are local dependencies; Git history is not a complete art backup. Retain provenance and actual licensing records without treating this GDD as legal advice or new redistribution permission.

<a id="s_18_4_One_coherent_active_timeline"></a>

### 18.4 One coherent active timeline

Removing calendar days does not remove chronology. Expedition progress, recovery, requests, project work, receiving theatre and the completion record must share coherent active elapsed time and pause semantics. No subsystem should gain time because the application was closed, restart a duration on load, or extend deadlines through repeated reconstruction.

Retain the lift sequence from last TAKE through closing, full outbound, retirement and FIFO promotion. At the same active timestamp the lift settles older waiters first. Expedition returns sharing a timestamp are processed in dispatch identity order.

<a id="s_18_5_Continuation_and_durable_commit"></a>

### 18.5 Continuation and durable commitments

The inherited complete-game goal is one continually maintained advancing recoverable state per run, with Save & Exit and internal preservation using the same state ownership and service. An ideal loss window of roughly 2–3 real seconds remains an unimplemented aspiration from the published continuity design. It does not require full scene serialization every few seconds; journal/delta and snapshot details need proportionate evidence.

Ordinary schema-4 continuation is accepted at M4, but is not continuous crash-durable saving. Retain its protections: failures are reported honestly, a failed load does not silently create a new run, failed Save & Exit does not abandon the active state, and historical recovery copies are not player-selectable rollback timelines. Independent new runs remain distinct.

| **State that must remain coherent** | **Examples relevant to the pivot** |
| --- | --- |
| Physical ownership | Items in storage/carrying, exact spent receipts, pending and deposited cargo; no duplication or lost transfer halves. |
| Organization | Zones, disabled cells, names, stacks, reserved cells, transforms and placed orientation—not fresh automatic packing. |
| Current operations | Editable preparation, exact away and waiting crews, destination occupancy and Kitchen schedule, grace and balances. Medical recovery and Workshop project progress remain future scope. |
| Time and completion | Active elapsed time, pause-independent logical progress, recorded first victory and exact pending transitions. |
| Committed outcomes | Previously selected cargo and any already-resolved random facts; reopening a report or continuing cannot reroll them. |
| Identity allocation | Run-scoped allocator state so new items/requests/expeditions remain unique after restart. |

Outcome commitment should occur at a natural backend point after legitimate player choices are fixed, before presentation where possible. Preserve committed results through continuation. Incidental uncommitted rerolls within the tolerated loss interval are not a reason to build a general anti-cheat framework; reliable selection among already preserved outcomes remains disallowed by the inherited policy.

The local continuous Kitchen build uses schema 8 in the existing collection slot. It preserves exact Kitchen trigger times, independent random states, outstanding balances, grace and consumption receipts with the existing run, Incinerator, preparation, expedition and victory state. Continue restores effects before play with service panels closed. Confirmed New Run repoints the slot and retains incompatible prior snapshots. Schema 7 has no automatic conversion. The M4 slot remains separate. Release durability remains open.

<a id="s_18_6_Environment_and_authored_produc"></a>

### 18.6 Environment and authored production

Retain the promoted EAF workflow: standardized material/light review; metre-authored structural pieces; curated PBR sources; independent wear/scalar authoring; and the accepted Receiving production composition. Structural shell, surface composition, services, wear and lighting remain separate editable concerns. UV is the default; source approval is not room-role approval.

The current Receiving palette, human-authored light/wear state and matched movement proxies remain the implementation reference. Current saved scene values supersede old inventories and screenshots. Do not restore intentionally removed monitors or decorative alternatives, normalize protected transforms, or rebuild retired experiments to match historical counts.

A later approved room compression or revised lift workload can legitimately change a bounded part of that composition. It requires targeted authoring and validation, not reopening every closed EAF/C1/Stage C milestone. Licensed originals, ignored caches, other worktrees and evidence must be preserved.

<a id="s_18_7_Technical_restraint"></a>

### 18.7 Technical restraint

No new framework, queue platform, event director, broad simulator, full asset audit or parallel save service follows from this documentation. Reuse current source and tests where the contract remains; replace obsolete policy only when the new behavior is defined. Stage changes through explicit bounded briefs and appropriate human testing. The task here is the successor document, not its implementation plan.

Basis: [G15 §18]; [MVP §§4–9,16,19]; [H25 §§6–7,13,15]; [PIV §11]; [WG].

<a id="s_19_Balance_philosophy_and_tuning"></a>

## 19. Balance philosophy and tuning

<a id="s_19_1_Optimize_the_organizing_experie"></a>

### 19.1 Optimize the organizing experience, not survival pressure

The scarce physical installation and live category objective should make accumulation, rearrangement and selective spending worthwhile. Expeditions must create enough useful resident stock to support the hoarding fantasy. Requests must not remove practically every item immediately or monopolize the player’s attention.

Completion time supports mastery in a fair, understandable noncompetitive game. Players may take indefinitely long. Useful combinations and ordinary efficiency differences are welcome. Investigate gross bypasses and extreme completion-time collapse. Four to five hours versus thirty minutes illustrates the scale of a distortion to investigate. Production time targets remain open.

<a id="s_19_2_Equal_goals_deliberately_uneven"></a>

### 19.2 Equal goals, deliberately uneven sinks

The category targets are equal; category availability, typical item efficiency and consumption need not be. Lower Morale demand can produce an early surplus that occupies space while Food remains difficult to retain. That is desired resource imbalance, not a defect to remove by adding identical mandatory sinks everywhere.

Observe which categories consume shelves, which are repeatedly spent and which lag behind the goal. A winning run is about bringing those different flows together. Do not dynamically reduce expert supply or increase their needs merely because they are ahead of an expected curve.

<a id="s_19_3_Target_catalogue_and_physical_c"></a>

### 19.3 Target, catalogue and physical capacity

The illustrative 2,000-per-category goal must be evaluated against actual items, stacking and furniture. Roughly 80% occupied storage at an average win is an experiential ballpark, not a second requirement. Define a useful occupancy observation before reporting a percentage; floor area, used base cells, vertical headroom and perceived fullness are not interchangeable.

An ordinary competent collection should be achievable without a near-perfect packing solution. Efficient players can use better objects and arrangements; disorganized choices may fill shelves before the goal. Retain working space for retrieval, replacement and rearrangement. Do not fix one hidden winning assortment or require a prescribed taxonomy.

<a id="s_19_4_Arrival_throughput_and_handling"></a>

### 19.4 Arrival throughput and handling capacity

More expedition capacity can shorten acquisition time but adds physical work, pending cargo and storage competition. Shorter journeys can create more frequent return pressure. More scavengers allow more simultaneous activity but require more preparation. Player choice controls departure timing, not the time cost of every consequence.

Measure time spent preparing, walking, searching, unloading, storing, reorganizing, servicing and waiting. Faster completion is not a reason to shrink all handling away; handling is much of the game. Long routes that mostly add repetition should be distinguished from decisions that make a spatial workplace satisfying.

<a id="s_19_5_Service_costs_and_bounded_negle"></a>

### 19.5 Service costs and bounded neglect

Requests should earn the stock they consume through a meaningful operational benefit. Short deferral should not immediately ruin a plan, and indefinite neglect should generally be an inefficient route. Bounded penalties must still matter; unlimited cumulative debt is not needed to make them matter.

Near the finish, a player may knowingly accept an outstanding penalty to preserve the last qualifying goods. That is consistent with the simple victory rule. Do not add an unannounced “all departments healthy” requirement merely to stop that choice.

<a id="s_19_6_No_dead_end_checks_without_catc"></a>

### 19.6 No-dead-end checks without catch-up

Assess whole systems rather than only individual escape paths. Natural recovery cannot rescue all-injured play if another penalty freezes it forever. A legal expedition cannot restore acquisition if it always produces nothing under every available configuration. Full storage cannot be cleared if every possible release action requires inaccessible inputs. These are design validation cases, not new compensatory mechanics.

A difficult recovery is allowed when it follows understandable player choices. The player can choose to restart. The goal is reachability under ordinary rules, not guaranteed recovery speed, adaptive grants or forced convergence among players.

<a id="s_19_7_Useful_calibration_tools_and_th"></a>

### 19.7 Useful calibration tools and their limits

Simple category accounting, representative manifests, whole-item loadout calculations and bounded automatic simulations can narrow candidate values where assumptions are known. Preserve Utility, Bulk, footprint and waste rather than treating every resource as infinitely divisible. Use actual approved catalogue data, not remembered examples.

Such models do not prove handling comfort, clear communication, satisfying shelf fullness or the time required to use an interface. Distinguish mathematical feasibility from normal-speed human play. No numerical victory target, rate or model is validated by this edition.

<a id="s_19_8_Parked_survival_rhythm"></a>

### 19.8 Parked survival rhythm

The approved Accumulation–Drawdown–Recovery archive preserves the forgiving opening, Day 2 warnings, proposed Day 4 disruption, eight open pairings, category pressures, later attrition, functional failure discussion and clock acceleration. Those were coherent questions for the old objective and remain reusable history. They are not the current balancing framework or a mandatory survival-mode roadmap.

Basis: [PIV §§1–10]; [ADD]; [ADR] historical-only; retained evidence/measurement distinctions [MVP §§10,21.4] and [H25 §§8–10].

<a id="s_20_Implementation_baseline_and_scope"></a>

## 20. Implementation baseline and scope

<a id="s_20_1_What_is_already_accepted"></a>

### 20.1 What is already accepted

M1–M4 are human-promoted, published and closed in their bounded scopes at c9f9417a97cf65ef416c58189ca1f741b6a90406. A read-only comparison during the 7 November approval-state update found published main identical to that reference. Local Windows working tree, saves, ignored assets and unpublished edits were not inspected. The SHA is an evidence anchor, never a reset target.

| **Foundation** | **Established evidence—not a new rerun** |
| --- | --- |
| Storage/content | Representative take/carry/store/retrieve, zones, deterministic stacking, physical fit, canonical pose/Front and selected fixed-ladder/rack work are promoted. |
| Receiving A/B/C | Exact cargo/identity, deterministic TAKE-only presentation, six-state theatre, fully-OPEN pickup, FIFO and upstream admission are accepted. |
| EAF/C1/lighting | Environment authoring workflows and bounded Receiving art/lighting acceptance remain closed. |
| M1 | Medical contribution and ordinary exact continuation through shared ownership/transactions. |
| M2 | Day clock, scheduled inputs, midnight ordering/report and ordinary persistence under the old prototype rules. |
| M3 | Kitchen Food/Hydration consumers and Meal Coverage reporting through the shared foundation. |
| M4 | Five-lane loadout, member-scaled fixture teams, outgoing Bulk/capped Utility, dispatch ownership/timing, improved UI and schema-4 continuation. |

The Continuous Run and Collection Goal Foundation is human-accepted and published in its bounded scope. It establishes continuous active time, simultaneous live stored totals and schema-5 continuation with controlled cargo. The record is [docs/testing/2026-11-07-continuous-run-collection-goal-result.md](../testing/2026-11-07-continuous-run-collection-goal-result.md). The Expedition-to-Storage Loop is also human-accepted and published in its bounded scope. Production collection balance and full-game durability remain open.

<a id="s_20_2_Frozen_M4_testing_values"></a>

### 20.2 Frozen M4 testing values

| **Parameter** | **Published test fixture** |
| --- | --- |
| Catalogue | 167 active / 7 retired / 174 source models; twelve Auto Stack Group approvals pending. |
| Personnel / capacity | 16 authored Ready → four full teams; 20 player Bulk; 28 raw Bulk per member. |
| Per-member lanes | Food/Hydration/Medical/Weapons/Protection: 12/12/6/12/12. |
| Calendar | 06:00–00:00 day; 06:00–10:00 preparation; 150 real seconds per game hour. |
| Supply fixture | 85 seeded items / 240 Bulk; twelve 16-item deliveries over three days, four per day. |
| Outcome boundary | Scripted deliveries are independent of team departures. No actual provisioning-to-return or population loop. |
| Continuation | Schema 4 ordinary continuation; continuous release-grade preservation remains future. |

These are historical M4 test values. Frozen inputs are preserved at [docs/design_history/survival-era/m4/](../design_history/survival-era/m4/README.md). They establish reproducible M4 evidence within the original scope.

<a id="s_20_3_Playable_entry_and_human_author"></a>

### 20.3 Playable entry and human authoring

Normal F5 launch uses res://gameplay/run/run_shell.tscn. The local continuous Kitchen slice is technically ready for developer playtest and builds on the accepted expedition and Incinerator loops. Standalone F6 uses res://gameplay/logistics_wing/wing_gameplay.tscn with the authored palette. Legacy main.tscn and spatial review scenes retain their authoring roles.

Current saved human content governs actual installations, poses, lighting, wear and source references. Future work must inspect actual dependencies before changes; remote documentation alone does not certify ignored commercial assets or runtime rendering. No game files are changed by this edition.

<a id="s_20_4_Future_scope_must_be_redefined_"></a>

### 20.4 Future scope must be redefined deliberately

The previously planned M5 meant combined authored scenarios using Medical, Kitchen and Dispatch—not automatic real-expedition implementation. It must not proceed unchanged against obsolete survival assumptions. No new M5 scope or implementation sequence is authorized here.

The expedition-to-storage loop is HUMAN-ACCEPTED / PUBLISHED / CLOSED IN ITS BOUNDED SCOPE. Appendix A of [docs/superpowers/plans/2026-11-07-continuous-run-collection-goal-foundation.md](../superpowers/plans/2026-11-07-continuous-run-collection-goal-foundation.md#appendix-a--confirmed-expedition-lifecycle-decisions-for-the-next-milestone) records the confirmed lifecycle decisions and their precise supersessions of the earlier open statements. The accepted slice uses the provisional settings in the expedition brief.

Keep the distinct scopes visible: retained mechanics; new score/continuous-time requirements; actual expeditions and personnel; revised requests/treatment; production storage/layout; optional progression/information. Their eventual delivery order requires a separate agreed brief. No new room-art pass, catalogue expansion, review framework or completed-milestone audit is a prerequisite by default.

<a id="s_20_5_Optional_and_historical_feature"></a>

### 20.5 Optional and historical features

| **Concept** | **Current disposition** |
| --- | --- |
| Dynamic labels / specialist storage | Intended or open retained features; exact mechanics/roster remain to design. |
| Rations / physical Salvage / optional projects | Retained concepts requiring continuous timing, output and balance definitions. |
| Training / persistent slots | Tentative historical proposal; redesign required before inclusion. |
| Ambient dog / contextual PA | Optional/deferred candidates with bounded non-mechanical/flavor scope. |
| Condition / quantity / contamination / spoilage | Not newly authorized. Reassess separately; nightly contamination rules do not survive automatically. |
| ADR cycle / survival mode | Parked history. A possible future mode is not a current release commitment. |
| Named personnel, combat, exterior, free building | Remain outside the intended core; no promotion by omission. |
| New code, publishing or scene remodeling | Not part of this document delivery. |

Basis: [H25 §§1–7,13–15]; [MVP §§13–17,19,21]; [PIV §11]; repository comparison at the cited reference; [WG].

<a id="s_21_Validation_priorities_and_open_qu"></a>

## 21. Validation priorities and open questions

<a id="s_21_1_What_the_new_design_must_demons"></a>

### 21.1 What the new design must demonstrate

| **Question** | **Useful evidence for a later authorized test** |
| --- | --- |
| Does stored loot feel like progress? | A substantial visible collection develops; meaningful sorting, shelving and retention occupy the session rather than only brief redistribution. |
| Does the goal stay simple? | Players understand live simultaneous category totals, excluded staging/cargo, reversible category satisfaction and immediate victory. |
| Can the collection fit without precision play? | Representative obtainable assortments fit with competent assisted placement and enough maneuvering room. |
| Does preparation help? | Useful return differences are noticeable across comparable expeditions without secret stat changes or guaranteed affinity items. |
| Does the single-team panel work? | Choose available members, inspect/submit, select affinities and dispatch consecutively without tabs, accidental spending or excessive reading. |
| Does backlog create worthwhile pressure? | Waiting crews reduce throughput; goods remain intact; players can understand and clear the bottleneck. |
| Are requests support rather than the whole game? | Short postponements are viable, sustained neglect has a cost, and bounded work/penalties preserve time to organize. |
| Are poor states recoverable under ordinary rules? | Injuries, depleted stock, blocked output and congestion never remove every route to the goal; no adaptive rescue is needed. |
| Does continuation preserve truth? | Ownership, live goal count, elapsed active time, pending crews and commitments survive without duplication or replay. |

These are design-validation aims, not claimed test results or a new automated acceptance framework. Use the smallest meaningful experiment and preserve the difference between code checks, arithmetic, developer play and unfamiliar-player observations. Existing accepted mechanics need only relevant regression coverage when changed.

<a id="s_21_2_Priority_open_decisions"></a>

### 21.2 Priority decision register

| **ID / subject** | **Boundary to resolve** |
| --- | --- |
| O-01 · Goal/capacity calibration | Actual shared Utility target, starting stock, qualifying storage/output classification and a useful occupancy measure. 2,000/80% remain placeholders. |
| O-02 · Single preparation lifecycle | Resolved for this slice. Formation at first accepted supply or zero-loadout Dispatch, with persistent draft edits, locked count after formation and whole-item receipts. See §§8.5 and 9.3. |
| O-03 · Destination lifecycle | Resolved for this slice. Exactly two distinct affinities, away-only exclusivity and explicit availability feedback. See §§9.5–9.7. |
| O-04 · Return and personnel handover | Healthy release at admission or empty return is confirmed. Injury classification, Medical admission mechanics and treatment remain open. See §11.6 and O-07. |
| O-05 · Acquisition model | The bounded test pool, capacity, lane targets, 90–180 active seconds and category weights are specified for this playtest. Production tuning and provisioning effects remain open. See §§9.7 and 10.5. |
| O-06 · Requests and Ops | Kitchen standing rules and provisional iteration settings are in §12. Fuel greyout direction is in §14. Fuel scheduling, costs, exact machine boundaries and save representation remain open. |
| O-07 · Medical | The Ward alone modifies natural healing with Medical treatment. Injury risk, recovery durations, pooled versus individual or FIFO treatment, costs, timing and UI remain open. |
| O-08 · Population and upgrades | Initial Ready count, recruitment/growth, progression ownership for assembled crews, Workshop project roster and Training disposition. |
| O-09 · Conversion and release | Rations and Salvage category and target rules, yields, capacity and output blocking remain open, along with Salvager access and restrictions. Incinerator rules are confirmed in §15.3. |
| O-10 · Space and handling | Production shelf capacity/roster, all-storage-from-start decision, route compression and final ergonomics. |
| O-11 · Interface and time edges | The local build keeps Kitchen, preparation and the Incinerator live. Escape closes service layers before pause. Journal scope, final interface and platform timing edges remain open. |
| O-12 · Delivery/continuation | Continuous Kitchen uses schema 8 with confirmed New Run for incompatible snapshots. Release migration and durability remain open. |

The register deliberately leaves unanswered mechanics open. The project already has enough direction to produce this successor; these are boundaries for later design/implementation, not reasons to recreate the old behavior or repeatedly ask the developer to approve the pivot.

<a id="s_21_3_Interpretation_traps_to_avoid"></a>

### 21.3 Interpretation traps to avoid

Do not bank a category permanently; count the sorting table or queued cargo; require request completion to win; turn the timer into a limit; promise quick recovery; add hidden catch-up; send injured crews by assumption; recreate morning teams/tabs; convert daily caps into depletion; forfeit queued loot; restore availability events to force a valley; or unlock essential goal information behind Electronics.

Do not copy old population/day targets, mortality formulas, daily Kitchen averages, one-night Training timing, night-only upgrades or pre-rolled outage schedules into empty replacement sections. Do not infer that removing days authorizes a new time-acceleration system. Do not treat undefined mechanics as proven by the scripted M4 scenario.

<a id="s_21_4_Known_debt_and_evidence_retenti"></a>

### 21.4 Known debt and evidence retention

The Systems MVP carry-forward register remains the detailed evidence home. Technical concerns such as CF-07 held/material diagnostics, certificate-store diagnostics, Pickaxe 108 co-located-LOD representation, pending group approvals and continuous durability are not silently fixed by this rewrite. Historical unrun checks remain unrun.

The collection pivot supersedes midnight handling, mortality, next-day Medical, nightly projects and socket expansion. The contribution decision record supplies provenance for the current allocation and the bounded Kitchen scope. Dated acceptance evidence still describes its original fixtures.

<a id="s_21_5_Document_adoption_and_stopping_"></a>

### 21.5 Document adoption and stopping point

The developer approved the complete v0.16 draft and subsequently approved the contribution allocation and Kitchen rules in the 9 November decision record. Kitchen values are provisional. The record separates iteration defaults from standing design and retains the open decisions for Fuel, provisioning, Medical and Workshop.

The entry points route current work to the owning masters and evidence. Kitchen is the sole implementation scope authorized by the continuous-service brief. The accepted expedition fixture and its Medical lane remain the mechanical baseline. Future contribution effects require their own implementation scopes.

Basis: [PIV §§10–12]; [ADD]; [MVP §§16,21.4]; [H25 §§2–3,10,14]; [WG].

<a id="s_Appendix_A_Illustrative_continuous_p"></a>

## Appendix A. Illustrative continuous play sequence

ILLUSTRATIVE ONLY. This sequence applies agreed concepts without selecting request intervals, injury rates, expedition durations, exact item values or a required strategy. It is not a scenario specification.

| **Situation** | **Player decision / observable result** |
| --- | --- |
| Several scavengers are Ready. | Choose three for the current expedition, inspect its five lanes and equip it with available goods. Select two affinities addressing useful gaps. |
| Preparation is adequate for the player’s plan. | Click Dispatch. In the same panel session, select another available crew and prepare it consecutively; no prebuilt team tabs are needed. |
| Cargo arrives while a shelf is crowded. | Take a mixed bundle, stage an awkward item temporarily and store the objects worth retaining. Only qualifying storage advances the live totals. |
| A request competes with sorting work. | Finish a short organization task before responding. Its defined bounded cost remains visible; the example does not specify a new grace duration. |
| A category already exceeds the target. | Choose whether surplus items are worth the space. Consuming some may keep the category above target or make its indicator unsatisfied again. |
| Several returns are waiting. | The crews remain occupied with their intact cargo. Clear Receiving and move items into useful storage to restore throughput under the defined handover rule. |
| A scavenger is recovering. | Under the favored Medical model, spend Medical to bring availability forward or accept the slower natural recovery; no injured-departure rules are required. |
| The last lagging category reaches target in storage. | All eight totals now satisfy the condition simultaneously. Record victory and active time immediately, even if a request, carried item or cargo backlog remains. |
| After completion. | Continue organizing for its own sake, or start a separate new run to improve time. Spending afterward does not erase the recorded first completion. |

A player who makes less efficient choices may generate more congestion, retain poor space-efficiency goods or spend more time recovering. The game does not correct their stockpile to match this example. The required safeguard is a legitimate path to completion, not equal outcomes.

<a id="s_Appendix_B_Glossary_and_status_sensi"></a>

## Appendix B. Glossary and status-sensitive values

| **Term** | **Meaning** |
| --- | --- |
| Utility | Numeric contribution within one Item Category; also the stored contribution to that category’s goal. |
| Bulk | Shared carrying/handling burden; not physical shelf occupancy. |
| Footprint | Authored two-dimensional reservation, combined with posed-height and stack rules for physical fit. |
| Qualifying storage | Designated player storage whose owned physical items contribute to live goal totals; not the sorting table, bundle or Receiving. |
| Ready | Available scavengers from which the player chooses the current crew; detailed reservation transitions remain open. |
| Current preparation | The single crew presently being assembled/equipped. Distinct from other already dispatched expeditions. |
| Affinity destination | One archetype selected by two distinct unordered category preferences; a repeatable supply emphasis, not guaranteed loot. |
| Concurrent destination use | Favored one-team-at-a-time restriction; release semantics still require design. |
| Awaiting Lift / pending return | A returning crew with retained cargo not yet handed over under the defined lifecycle; not a deposited physical slot. |
| Deposited queue | The finite physical FIFO owned by Receiving, historically two queued plus one active. |
| Live goal total | Present Utility on qualifying storage, not cumulative acquired or previously stored value. |
| Active time | Real-world run time counted under the approved pause rules, not calendar days or offline time. |
| No dead end | Victory remains attainable through ordinary rules, even if recovery is slow and a restart is attractive. |
| ADR archive | The parked Accumulation–Drawdown–Recovery survival design, preserved for deliberate reuse. |

<a id="s_Values_and_their_status"></a>

### Values and their status

| **Value** | **Correct interpretation** |
| --- | --- |
| 8 categories | Confirmed shared category set; General is not a ninth category. |
| 2 distinct unordered affinities / 28 pairs | Preferred retained destination format, subject to testing; no repeats or hidden Primary/Secondary tier. |
| 1–4 members | Explicit current-team count in the latest addendum, limited by Ready availability. |
| 2,000 Utility per category | Illustrative common victory target, not balanced or final. |
| Approximately 80% storage occupancy | Rough substantial-hoard aspiration for an average winning collection, not a requirement or measured result. |
| 1 active + 2 deposited queued | Accepted physical Receiving baseline, separate from the uncapped waiting-return direction. |
| 95% stack headroom | Retained physical stacking rule; singleton clearance is different. |
| 20 / 28 Bulk; 12/12/6/12/12 lanes | M4 player/per-person capacity and lane testing values only. |
| 2–3 real seconds | Inherited ideal full-game preservation-loss target, not current measured durability. |
| Day 2 warnings / Day 4 first drawdown / 2×–3× | Historical ADR proposals only; no active successor timetable or acceleration setting. |

<a id="s_Appendix_C_Supersession_and_retentio"></a>

## Appendix C. Supersession and retention map

<a id="s_C_1_Predecessor_section_disposition"></a>

### C.1 Predecessor section disposition

This map records where the substantive predecessor topics went. “Retained” preserves applicable content, not every dated phrase or status banner. Old registers, example days and source lineage remain in v0.15 rather than being duplicated into the active rules.

| **v0.15 topic** | **v0.16 treatment** |
| --- | --- |
| §§1–3 · Vision, pillars, loop | Rewritten around collection victory and physical hoarding; retains personal organization and unseen-world constraints. ADR rationale preserved historically. |
| §4 · World and geography | Retains setting, safe haven, three boundaries, inferred community and current spatial context. Exact layout is open to deliberate compression. |
| §5 · Days, night, failure and save | Replaces day-count survival with simultaneous stock goal and active-time record. Removes daily transitions; retains coherent continuation without offline advance. |
| §6 · Items | Retains Utility/Bulk/Footprint/identity; unifies Item Category and removes alternate uses. Optional contamination/condition remain reassessment candidates. |
| §7 · Storage | Carries forward detailed zoning, Front, pose, deterministic stacks, clearance, input, labels and ergonomics. Fixed starting installation favored over expansion. |
| §8 · Facilities and requests | Preserves selected-item irreversible accounting; replaces daily request grammar with bounded continuous-pressure direction and explicit open mechanisms. |
| §9 · Population and expeditions | Replaces morning formation/tabs/cutoffs with one player-assembled preparation at a time, asynchronous activity and affinities. Failure removed; growth/lifecycle open. |
| §10 · Provisioning/loot | Retains proportional capacity and outgoing Bulk; reclassifies old outcome curves/numbers as redesign material. Adds equal unranked affinities without changing definitions. |
| §11 · Receiving | Retains exact content, identity, private TAKE-only deck, cycle and FIFO. Replaces midnight loss with waiting crews and intact cargo; exact handover open. |
| §12 · Kitchen | Retains Food/Hydration sink and ration concept; removes fixed meals/daily coverage/night output. Continuous effects and conversion details open. |
| §13 · Medical | Retains anonymous patients/service identity; favors slower natural and faster treated recovery. Daily stages, complication/death formulas no longer active. |
| §14 · Ops | Retains categories and physical Administrator handoff; old next-day outage/recruitment rules require redesign. |
| §15 · Machines/progression | Retains disposal/conversion and optional capability investment; daily project mechanics and capacity progression not inherited. Training slots explicitly under redesign. |
| §16 · Presentation | Retains core data/input/feedback and bounded freight cues. Adds protected baseline goal visibility and no-tab preparation; removes day/night report requirements. |
| §17 · Narrative | Retains inferred world, one-way messages, optional reactions and dog scope; removes dependence on particular days or mortality. |
| §18 · Technical/content | Retains owners, identity, authoring, coherent timeline, continuity and provenance. Calendar-specific transitions and schemas need later adaptation. |
| §19 · Balance/ADR | Replaces survival pressure with storage, category imbalance, handling and time-to-completion. Parked cycle is archived, not active. |
| §20 · Milestones/scope | Preserves accepted foundation and M1–M4 evidence. Old M5/full-game plan is not automatic implementation authority. |
| §21 · Risks/open choices | Replaces survival validation questions with collection-loop risks and explicit open replacements. |
| Old Appendices A–F and source registers | Retained in predecessor and dated evidence. This edition supplies a continuous example, glossary, mapping and source register instead of copying obsolete timelines. |

<a id="s_C_2_Decisions_superseded_within_the_"></a>

### C.2 Decisions superseded within the approved records

The approved pivot record §5.3 retains per-team tabs from the previous prebuilt-roster design. [ADD] replaces that passage: select one current count of 1–4 Ready scavengers, equip and choose destination, dispatch, then optionally prepare the next crew consecutively. No parallel multi-team provisioning or morning allocation follows.

The ADR archive remains accurate history even where its specific-destination daily cap, general-scavenging fallback, fully paused multi-team panel, cardinal cutoff processing, first-drawdown timing or functional-failure rule is no longer current. The latest pivot retains selected useful concepts, not the entire historical mechanism around them.

<a id="s_C_3_Carry_forward_evidence_and_futur"></a>

### C.3 Carry-forward evidence and future updates

Retain Systems MVP CF-01–CF-24 as an evidence register, with later dispositions where the design changes. Technical identity/transfer/continuation and human-authoring obligations remain relevant. CF-05’s midnight component is superseded; CF-14/15’s mortality and daily population/treatment expectations need revision; CF-16/17’s night/socket progression needs reconciliation; CF-19’s economy and route questions need the new objective. This is not a finding that their earlier implementations or reports were incorrect.

Continuous durability, rendering/content debt, licensed-local asset boundaries and authoring approvals remain preserved. An old obligation cannot silently authorize an obsolete survival mechanic. The accompanying operational documents route current work to this approved edition while leaving historical evidence and the MVP/VDD masters intact.

<a id="s_Appendix_D_Sources_and_maintenance"></a>

## Appendix D. Sources and maintenance

<a id="s_D_1_Primary_approved_conversation_re"></a>

### D.1 Primary approved conversation records

**[PIV]** Sorting_Apocalypse_Design_Pivot_Record_05Nov2026.docx and its generated .md, supplied in Sorting_Apocalypse_Design_Records_05Nov2026.zip. Read as the reviewed/approved reconstructed edition, not claimed byte-identical to the earlier inaccessible files. Its internal status distinctions remain.

**[ADR]** Sorting_Apocalypse_ADR_Design_Archive_05Nov2026.docx and generated .md in the same approved ZIP. Historical/parked survival design; retained for reasoning and deliberate future reuse.

**[ADD]** The developer’s subsequent approval message accompanying this editioning request: no team tabs, no prebuilt teams, one current 1–4-Ready-scavenger crew equipped and assigned before dispatch, with consecutive crews possible in the same panel session. This is the latest authoritative panel direction; no fabricated message timestamp is assigned.

The approved archive and pivot records were read from their mounted files and retain their original 5 November 2026 dates. This successor was compiled 6 November 2026. [APP] is the developer’s subsequent message approving the draft documents in their entirety and authorizing approval-state and entry-point updates for manual repository provision; that update is dated 7 November 2026. Approval is not a claim of remote publication.

<a id="s_D_2_Published_reference_set"></a>

### D.2 Published reference set

Published repository reference: Navandis/Sorting-apoc-PROTOTYPE at c9f9417a97cf65ef416c58189ca1f741b6a90406. A read-only GitHub comparison of that commit to main returned identical during preparation. No Windows runtime, saves, dirty-file state or ignored assets were inspected.

[[G15] Preliminary GDD v0.15 — published generated reading copy](https://github.com/Navandis/Sorting-apoc-PROTOTYPE/blob/c9f9417a97cf65ef416c58189ca1f741b6a90406/docs/readable/Sorting_Apocalypse_Preliminary_GDD_v0.15.md)

[[MVP] Systems MVP Foundation Design and Progress v0.5 — generated companion](https://github.com/Navandis/Sorting-apoc-PROTOTYPE/blob/c9f9417a97cf65ef416c58189ca1f741b6a90406/docs/Sorting_Apocalypse_Systems_MVP_Foundation_Design_and_Progress_v0.5.md)

[[VDD] Visual Design Direction v0.11 — generated reading copy](https://github.com/Navandis/Sorting-apoc-PROTOTYPE/blob/c9f9417a97cf65ef416c58189ca1f741b6a90406/docs/readable/Sorting_Apocalypse_Visual_Design_Direction_v0.11.md)

[[WG] Proportionate AI Working Guidelines](https://github.com/Navandis/Sorting-apoc-PROTOTYPE/blob/c9f9417a97cf65ef416c58189ca1f741b6a90406/docs/AI_WORKING_GUIDELINES.md)

[Published current-state record — historical implementation routing](https://github.com/Navandis/Sorting-apoc-PROTOTYPE/blob/c9f9417a97cf65ef416c58189ca1f741b6a90406/docs/CURRENT_STATE.md)

[Published documentation index — historical pre-adoption pointers](https://github.com/Navandis/Sorting-apoc-PROTOTYPE/blob/c9f9417a97cf65ef416c58189ca1f741b6a90406/docs/README.md)

The v0.15 reading copy has blob SHA 8c613e9cd50c3afaeef601e03bffa2b78062faae. Its generated-master convention is retained. This task read the published companion for substantive predecessor design; it did not modify or claim to re-render the remote v0.15 DOCX.

**[H25] Sorting_Apocalypse_Bootstrap_Prompt_Next_Session_25Oct2026.md is the historical attached handoff used for publication disposition, milestone boundaries, source roles, preservation and local-versus-remote distinctions. Its ADR-next instruction is superseded. The accompanying Sorting_Apocalypse_Bootstrap_Prompt_Next_Session_07Nov2026.md is the current conversation handoff.**

Historical Prototype Findings v0.14 and VDD v0.11 are also available as project DOCX files. Their dated references to earlier gameplay authority remain historical; they do not supersede the new developer decisions. No outside game-design research is used to fill missing mechanics.

<a id="s_D_3_Source_sensitive_unresolved_word"></a>

### D.3 Source-sensitive unresolved wording

The approved pivot record describes loadout goods as consumed on dispatch and also retains irreversible physical submission. The expedition brief fixes the boundary for this slice. The first accepted whole-item contribution spends the item and forms the crew. Dispatch uses the recorded receipt. See §8.5.

Similarly, an uncapped waiting queue is not an uncapped visible deck, one concurrent expedition is not a daily limit, and a simple natural-recovery preference is not a complete Medical specification. These distinctions must survive future condensed handoffs.

<a id="s_D_4_Maintenance_and_adoption"></a>

### D.4 Maintenance and adoption

This DOCX is the editable master of the approved v0.16 edition. The same-stem Markdown is generated from its final body, tables and hyperlinks; it is not a second independently edited authority. Edit the master first and regenerate the companion. Preserve stable owning headings and all source/status distinctions.

The accompanying index, current-state and bootstraps identify v0.16 as the approved current gameplay authority and v0.15 as superseded history. The developer retains manual publication. MVP/VDD forward-looking passages require targeted reconciliation without deleting accepted art, code, tests or observations. Document approval does not authorize code changes, M5 execution or assistant Git writes.

No gameplay run, new economic simulation, catalogue rebalance, external review or implementation claim accompanies this edition. Document verification addresses content consistency, package structure, generated-text parity, links and rendered layout only.

> Current direction: a collection-and-organization game with operational consequences. Retain the physical foundation; keep historical evidence; do not restore undefined survival rules by default.
