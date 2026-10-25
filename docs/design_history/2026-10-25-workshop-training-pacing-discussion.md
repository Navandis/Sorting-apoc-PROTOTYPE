# Workshop Training and pacing conversation reconstruction

25 October 2026. **NON-AUTHORITATIVE PROVENANCE COPY.** This preserves the supplied reconstruction of visible conversation and its editorial integration guidance. It is not a newly verified verbatim transcript, and the anchor labels do not invent individual message timestamps. Embedded instructions describe the supplied packet; they do not authorize implementation or override the user’s documentation-only request. Current design ownership remains GDD v0.15; progress/findings remain Systems MVP v0.5. Read the [disposition and QA record](../testing/m4-documentation-semantic-reconciliation-2026-10-25.md) for final destinations and status.

The original supplied specification follows in full.

# Sorting Apocalypse — Design-context retention specification

25 October 2026. Prepared from the visible project conversation and the supplied GDD v0.15 / Systems MVP v0.5 documentation.

**Purpose:** recover the reasoning, examples, constraints and unresolved choices that the latest summaries omit. Integrate this material into the actual GDD and MVP masters; do not leave it only in a bootstrap, task prompt or external handover. This is a documentation source and editorial specification, not authorization to implement future systems.

**Preserved state:** M4 HUMAN-PROMOTED / CLOSED LOCALLY / PUBLISH PENDING. No M5 work, publication, balance change, room construction or new gameplay implementation follows from this document.

## 1. Status and attribution discipline

A feature can be tentative while containing details explicitly settled within that tentative concept. Preserve both facts. Conversely, an assistant recommendation discussed without subsequent explicit approval must not become a confirmed rule merely because it is sensible.

Use these distinctions in the revised masters:

- **Current accepted contract:** already agreed or implemented behaviour, including M4's bounded closure and baseline cross-wing awareness as a required future design need.
- **Developer-proposed direction / tentative feature:** the developer's intended concept and reasons for it, retained in detail but not an implementation specification.
- **Confirmed detail within a tentative feature:** one guaranteed training day per upgrade, with the improvement available the following morning. The developer explicitly confirmed this timing; the feature as a whole remains tentative and unimplemented.
- **Discussion recommendation / not yet decided:** suggested safeguards, costs, activity ordering and evaluation methods supplied in the discussion. Preserve them as recommendations or open questions, not approvals.
- **Illustrative example:** numbers, places, event ideas and comparisons used to explain a decision. These do not create a default scenario or numerical commitment.

The main preservation error to avoid is replacing all of these with either “approved” or “tentative.” A vague tentative label is not a substitute for recording what the idea actually is.

### Conversation source anchors

These anchors identify passages in the visible conversation. They are source locators, not repository commits or independently dated test records. The date of this reconstruction is 25 October; do not invent a separate timestamp for each original message.

| Anchor | Speaker and identifiable passage | What it establishes |
|---|---|---|
| WS-U1 | Developer: “Should the various planned monitors and other useful electrical/electronic devices be enabled via the Workshop consuming Electronics?” | Original Electronics-funded infrastructure concept, concrete upgrades, tutorial example, competition with Ops and player-specific priorities. |
| WS-U2 | Developer: Workshop could overlap the conceptual research/talent tree, which is “run-specific however, not across multiple independent runs!” | Within-run progression, tactile facility evolution, possible but undefined character progression. |
| WS-U3 | Developer: “the Workshop + Electronics feels strong enough” before proposing Training. | Positive concept-level assessment; not implementation authorization. |
| TR-U1 | Developer: Training upgrades “team-slot based,” unlocked once a slot has formed, with the ten-scavenger 4/4/2 example. | Persistent slot improvements, focus-versus-spread choice, no personnel redistribution on training days, uncertain occupancy. |
| TR-U2 | Developer: “one guaranteed training day per upgrade, with the improvement available the following morning.” | Explicit timing confirmation within the tentative feature. |
| FUT-U1 | Developer: “we won't go further into refining these two additions ... Next time we update the GDD we'll track these as tentative, along with the summary of the broad-strokes designs.” | Retain the discussion without expanding it into a final system or derailing M4. |
| PLAY-U1 | Developer's normal-speed M4 playtest: nearly full morning, early elevator assistance, unfamiliar stock, text-heavy UI, missed-request risk, quiet afternoon, travel burden and nearly empty shelves. | Human observations and the problem motivating further economy/awareness work; not a statistically representative playtest. |
| PACE-U1 | Developer: accumulation in the first X days, followed by periods where “consumption significantly outstripping incoming loot,” with variable waves. | Broader accumulation/drawdown direction and its supply/demand levers. |
| PACE-U2 | Developer: “the game cannot have a linear, flat challenge vector”; first ten days and days 30–40 need not follow the same approach. | Whole-experience non-flat pacing, special care for the opening, no decision restricting deliberate pacing to the opening. |
| PACE-U3 | Developer: new/casual players may fail the first or second valley and improve across subsequent runs; examples of Project Zomboid and 7 Days to Die. | Intended learning-through-runs and preparation/payoff analogies, not measured audience retention or imported mechanics. |
| CAL-U1 | Developer: worst loadouts may be invalid through excessive Bulk; small consequences would make good decisions insufficiently meaningful. | No guaranteed minimum return reserve for every complete loadout. |
| CAL-U2 | Developer: same-size teams have equal base capacity; capacity and five requirements scale directly per scavenger. | Current baseline proportionality rather than arbitrary per-team/destination demand variation. |
| CAL-U3 | Developer: prefer adjusting a few overvalued items over increasing global requests/player capacity to accommodate them; case-by-case waste judgment. | Calibration rationale and no universal maximum-waste percentage. |
| SAVE-U1 | Developer's full-game Ironman clarification: continuously maintained snapshot, ideally 2–3 seconds loss, same system for internal saving/Save & Exit/midnight. | Supersedes the old minute-scale rollback premise; multiple independent runs are not rollback histories. |
| UI-U1 | Developer's successive M4 UI requests, followed by acceptance of the final in-game UI and report. | Current compact previews, tabs, yellow fulfilled-lane feedback, dispatch timestamps and partially fulfilled meal label. |
| ACCEPT-U1 | Developer: M4's goal was five-lane requests and outgoing capacity; item-specific values, handling and timing, not demonstrating the entire organizing economy. | Bounded M4 success criteria; future design questions do not reopen M4. |
| A-DISC | Assistant discussion of these proposals before documentation close-out. | Analysis, examples and recommendations only where not explicitly adopted by the developer. |

## 2. Workshop/Electronics expansion — substantive GDD treatment

**Placement:** expand GDD §15.10, with links from §15.6, §16 and the progression/scope sections. Preserve §15.5's existing Workshop project model. The following is substantive content to integrate, not text to compress back into two paragraphs.

### 2.1 Purpose and identity

**Developer-proposed, favourably received direction; TENTATIVE / VALIDATE / NOT IMPLEMENTED.** The Workshop could use Electronics for optional operational infrastructure, creating a second use for those supplies alongside recurring Bunker Ops requirements. The player chooses between maintaining operations, retaining a flexible Electronics reserve and committing supplies to a lasting improvement.

This is intended to strengthen the Workshop beyond a narrow sequence of storage-capacity unlocks. Shelves substantially alter the storage economy; clocks, displays and repeaters offer a different progression scale, improving access to information and reducing unnecessary travel. They give the bunker visible, tactile evolution without requiring visible workers or construction simulation. Their value is not assumed to be negligible: saving trips or avoiding a missed deadline can materially affect performance.

The intended strategic question is not merely whether the player can afford an upgrade today. It is whether to stockpile Electronics across several days, whether doing so leaves enough for Bunker Ops, and whether a particular convenience suits the player's own working routes and organization. Future destination affinities could add another decision, but selectable destinations are not a prerequisite or approved by this idea. The current launch destination policy remains unchanged unless separately revisited.

### 2.2 Concrete candidate projects

Retain the developer's examples rather than just the label “information tools”:

| Candidate | Intended player-facing benefit | Boundary |
|---|---|---|
| Dedicated Expedition display in Dispatch | Check expedition/crew information without repeatedly returning to Sorting. | Uses real available information; not a simulator or a source of invented outcomes. |
| Additional request monitors | Check active obligations, progress and deadlines from another working area. | Supplements a usable baseline overview rather than creating the first reliable awareness of requests. |
| Additional clocks at predetermined sockets | Read the shared game time along preferred routes and in other rooms. | No independent device timers; preserve the development HUD until it is deliberately replaced. |
| Coloured request/lift alert repeaters | Notice activity out of direct sight of its department or too far from a monitor to read text. | Candidate destinations include Lift, Medical, Kitchen and Bunker Ops. Room identity should carry through. |
| Richer or more integrated display information | Compare relevant facts more quickly or add useful detail to another display. | Does not reveal committed but intentionally hidden random outcomes or remove information already accepted in current equipment. |

The original discussion included unlocking a lift queue count and subsequently adding a clock to that monitor. Preserve the historical example, but explain the supersession: the current Receiving CRT already supplies its accepted deposited queue count, so that existing count is not to be removed and resold. A richer or additional display can still be a future project.

Colour should not be the only identifier for alert repeaters. Symbols, location, wording or patterns are discussion recommendations consistent with the existing feedback direction, not a finished alert-language specification.

### 2.3 Baseline awareness versus optional convenience

**Later developer playtest finding / required future design need:** local room lights and audio alone are insufficient. Players do not always have line of sight, and making sound carry everywhere could make it over-loud near its source. Central monitoring and dependable request awareness are therefore baseline integrated-game needs, not premium Workshop content.

Distinguish notification from overview. The player needs a reliable way to discover that an obligation exists while working elsewhere, and a predictable place to inspect its details. A central monitor solves only part of that problem if the player must stare at it constantly. Exact implementation remains undecided.

Optional infrastructure should improve the reach, placement or richness of already usable information. It should not repair deliberate informational blindness. This is the important later refinement to the original suggestion of gating all monitors.

### 2.4 Tutorial possibility and its unresolved timing

The developer suggested teaching the Workshop on Day 1 by contributing a known quantity of pre-seeded Electronics to enable a clock. Retain this example as a candidate, not a mandatory tutorial design or exact price.

The discussion identified a tension with the established overnight Workshop model and the need for time awareness before timed obligations. A baseline time source plus an additional clock/display repair was suggested as the simpler version. A special immediate tutorial repair was another implementation possibility, not an approved exception. Do not silently decide that the only clock remains unavailable during meaningful timed obligations, or that all Workshop projects become instant.

### 2.5 Within-run progression and player agency

The conceptual research/talent lane was explicitly **within a run**, not progression retained across independent runs. Workshop projects may provide a more physical expression of facility progression than an abstract bonus tree. The player can favour an Expedition display, request overview, clocks or repeaters according to their routes and priorities.

A project menu may still display branches and prerequisites; a separate research currency or unlock charge is not required merely to duplicate construction costs. A character/equipment progression lane for carrying or movement remains undefined, not abolished and not authorized here.

The concern about Workshop longevity is a design motivation, not a requirement for infinite projects, recurring device maintenance or upgrade decay. Finite meaningful progression may be enough; those recommendations remain open for validation.

### 2.6 Existing systems and open questions

Existing Workshop contracts remain: player-initiated commitment, project-specific materials/Salvage, one active project, productive nights influenced by Meal Coverage, fixed installation sockets and no visible construction. The discussion favoured direct Electronics costs for relevant projects so competition with Bunker Ops remains tangible; exact material recipes and progression are undecided.

Construction material does not determine outage ownership. The currently specified Fuel lane governs ordinary lighting/request-alert light outages; Electronics governs monitors/PA/communications. Funding an alert light with Electronics does not itself reassign it to the Electronics outage lane. Clock outage behaviour remains a separate open question.

Still unresolved: project roster, pricing, prerequisites, installation order, exact richer information, tutorial sequence, number/placement of sockets, accessibility treatment, and integration with any later research or character progression. No project values, new rooms, interfaces or unlock code are authorized by this record.

## 3. Team-slot Training / Expedition Readiness — substantive GDD treatment

**Placement:** expand GDD §15.11 or give Training a distinct subsection with links from population/team formation, provisioning, Kitchen, progression and validation. Preserve its identity as a separate concept, not an Electronics Workshop project.

### 3.1 Motivation and safe-haven boundary

**Developer-proposed alternative; TENTATIVE / VALIDATE / NOT IMPLEMENTED.** Training gives Weapons and Protection competing uses without threatening the bunker or disturbing sorted inventory. It was proposed after the discussion of Security requests and night theft raised concerns about the safe-haven promise and frustration at losing carefully arranged possessions.

The rejected/parked theft direction is relevant provenance, not an invitation to implement raids. Retain the goal of dual-use equipment while keeping combat, stolen stored items and involuntary disruption of organization outside the present concept.

The developer envisaged an additional facility/service frontage like the other departments, with an unseen operational interior: no visible scavengers or trainers, no active training minigame and no new animated activity. Exact room/location is unapproved. “No facility implementation authorized now” must not be rewritten as “the concept has no physical facility” or as a commitment to a purely abstract remote menu.

### 3.2 Persistent slots rather than individual skills

The player invests in **Team 1, Team 2, and so on as persistent organizational slots**, not in named scavengers or a particular day's loadout. The next crew assembled into a slot inherits that slot's improvements. This avoids tracking personal experience, skill transfer, heterogeneous strength, biographies or training histories across injuries and recruitment.

A useful proposed fictional rationale is institutional readiness: procedures, preparations and assigned equipment associated with a slot. This rationale explains persistent capability despite changing personnel; it is not authorization for a hidden individual training model. “Training” and “Readiness” remain working names.

Separate permanent slot state (identity, unlocked status, acquired improvements) from daily team state (member count, activity, loadout, departure). Stable slot identity matters when middle slots train or later slots are temporarily empty. Do not renumber an active Team 3 to Team 2 because Team 2 stayed home.

### 3.3 Unlock rule and growth

The developer's proposed rule is that a slot becomes available for upgrades once the normal Expedition system has formed it at least once. Three initial teams expose slots 1–3. Reaching a population that forms Team 4 unlocks that slot permanently, even if subsequent injuries or population decline temporarily leave it unoccupied. Further slots follow the same rule; there is no independent team-count cap.

This connects progression opportunities to population growth without requiring a complete design for maximum population or maximum teams. Upgrades survive temporary loss of occupancy within the run. They are not cross-run meta progression.

**Open distinction:** unlocked-for-investment versus occupied-and-eligible-to-train. The assistant recommended that an empty slot must not complete cost-free training while perhaps allowing advance funding. The developer has not explicitly settled that eligibility/funding distinction. Record it as an important unresolved rule, not as a confirmed implementation requirement.

### 3.4 Form first, reserve the assigned crew, do not redistribute

The ordinary formation rule fills four-person teams first and then at most one partial team. Training is selected against that formed roster. The selected team's assigned scavengers remain home; they are not moved into another slot to preserve expedition throughput.

Preserve the developer's worked example:

| Ten Ready scavengers | Formation | Train Team 2 | Train Team 3 instead |
|---|---:|---|---|
| Team 1 | 4 | Four depart | Four depart |
| Team 2 | 4 | Four train | Four depart |
| Team 3 | 2 | Two depart as Team 3 | Two train |

Training Team 2 therefore sends Teams 1 and 3, with six scavengers total. It does not repartition six people into Teams 1 and 2 or create another slot to evade the reservation. Training Team 3 leaves eight available for expeditions but invests in a smaller, potentially less reliably occupied slot.

On the next morning, teams form again from that day's Ready population while permanent slot improvements persist. Injury and recovery can change the remainder and which later slots are occupied. That gives Medical and survivability indirect significance for the utilization of training investments.

### 3.5 Timing detail that the developer explicitly confirmed

**Confirmed within the otherwise tentative feature:** each upgrade requires **one guaranteed training day**; the benefit is available **the following morning**. The team does not also undertake an expedition that day. Do not demote this timing to an entirely unanswered question, add a training-success roll or replace it with a variable multi-day programme by default.

Still unresolved: selection deadline, whether projects can be pre-funded, the commitment/cancellation boundary, whether a partially provisioned team can switch activities, simultaneous training throughput, exact completion plumbing, and how trained-at-home scavengers are represented in Kitchen demand. The assistant's suggested “fund in advance, schedule before loadout, finish overnight” sequence is a proposal, not an approved complete interaction contract.

### 3.6 Strategic choices and opportunity cost

Three costs interact: Weapons/Protection committed, one expedition opportunity forgone, and permanent investment tied to a slot whose utilization may vary.

The player can concentrate upgrades on one slot or spread improvements. Earlier slots are more reliably occupied under full-four-first formation; later slots may be cheap to withhold on a partial-team day but may not fill or even remain occupied soon. This is voluntary investment risk, not random removal of the purchased improvement.

Training a two-person team currently gives only half the aggregate benefit of a four-person team **for benefits proportional to member count**, such as a hypothetical +2 Bulk per member. It is not a universal rule for per-expedition recruitment or probability effects. No +2-Bulk bonus is approved; it is an explanatory example.

Opportunity cost is net, not simply gross loot forgone. A team staying home also avoids that expedition's loadout expense and exposure to expedition risk. Material cost, saved preparation, lost expected return, population risk and player handling effort must be evaluated together. The system could give the player a deliberate quieter logistics day when reserves are strong or Receiving needs attention; this is a discussion rationale, not a requirement for a separate cooldown mechanic.

Weapons/Protection with poor expedition Utility-to-Bulk efficiency may become useful training contributions while compact equipment is reserved for teams going out. Training still consumes real items and carrying effort. This does not define a new Training capacity statistic.

### 3.7 Candidate improvements and important risks

The developer suggested survivability, lower requirements per expedition, more carrying capacity and higher recruitment opportunity. Retain all four as candidates, not approved ranks or numeric bonuses.

| Candidate | Intended value | Interaction requiring later validation |
|---|---|---|
| Survivability | Improve a regularly used slot's resilience | Daily Medical/Protection preparation must remain meaningful. |
| Carrying capacity | More useful return space, usually scalable with crew size | Greater returns also add handling/storage pressure. |
| Reduced requirements | Save supplies and trips; change useful combinations | Whole-item thresholds can remove an entire item, reduce outgoing Bulk and increase return space simultaneously. |
| Recruitment opportunity | Invest in growth and future slot availability | Interacts with existing Weapons/destination/Morale rules and can create compounding growth. |

The earlier equality rule becomes conceptually “same size and same upgrades imply the same capacity/requirements.” Purchased, visible progression is distinct from arbitrary heterogeneous scavenger stats. The baseline still uses equal per-scavenger values; no modifiers are implemented by documenting this proposal.

The assistant recommended starting with bounded safety and carrying improvements, treating requirement reduction/recruitment more cautiously. That recommendation is not a final feature selection.

### 3.8 Discussion safeguards that remain recommendations

Retain these concerns and suggestions without converting them to approved defaults:

- **Team 1 dominance:** earliest slots are most reliable. Finite ranks, increasing higher-rank costs, the opportunity cost of withholding an already productive team, and cheap partial-slot training days could support a focus-versus-spread choice. No cost curve is approved.
- **Partial-slot purchase discount:** price by upgrade/slot rank rather than current crew size was recommended to avoid buying a permanent full-size benefit cheaply with one current member. The cost basis remains open.
- **Empty-slot training:** avoid an unoccupied slot completing upgrades without sacrificing an expedition opportunity; funding versus actual training eligibility remains to be decided.
- **Commitment exploit:** switching from a spent loadout into training must not casually refund irreversible submissions or become free storage. Exact scheduling/cancellation rules remain open.
- **Preparation obsolescence:** permanent progression should not make daily loadouts irrelevant. This is a validation concern, not permission to secretly compensate with arbitrary higher demands.
- **Kitchen interaction:** at-home trainees do not carry an expedition ration allowance. Whether and how the existing Kitchen demand model accounts for them is unresolved; do not silently add a new training-meal request.
- **Finite progression is acceptable:** no mandatory decay, maintenance fees or endless ranks were proposed merely to keep Training occupied.

A bunker-wide doctrine project was discussed as a simpler fallback if persistent slots prove awkward. It was not selected and should not replace the slot-based proposal in the documentation.

Training's economic test ultimately needs real or deliberately linked expedition returns. M4's independent scripted deliveries can validate interfaces/accounting but cannot prove the value of forgoing an expedition. This remains a future-system boundary, not a reason to reopen M4.

## 4. Accumulation, drawdown and recovery — broader pacing direction

**Placement:** expand and rename GDD §19.6 so it is not limited by title to the opening. Reconcile §2.1, §5.1, §19.2, §20.5 and §21.2; do not leave an unchanged emergent-only long-run rule that nullifies the new discussion. The early run gets special treatment within the broader direction, not an exclusive exemption from it.

### 4.1 The design problem and developer's proposed response

**Developer-proposed broad design direction; concrete pacing system UNDESIGNED / UNIMPLEMENTED / REQUIRES VALIDATION.** The organizing fantasy requires useful possessions that persist long enough for sorting, placement and storage expansion to matter. Meaningful consumption requires scarcity, competition and consequential spending. Trying to satisfy both through a nearly flat day-by-day balance leaves too little margin: either shelves repeatedly empty or supplies make choices trivial.

The developer therefore proposed a changing economic rhythm, roughly wave-like but not a literal sine function: begin with an accumulation phase, follow with periods of significant net consumption, and allow later recovery/accumulation before further pressure. Duration, severity, baseline, amplitude and intervals need not repeat. This is not a locked event director, exact calendar, formula or day-count multiplier.

Initial abundance can come from a larger seed reserve, stronger expedition returns, lower requirements, or a combination. Drawdown can result from higher demand, lower incoming supply, or both. Better organization, judicious item allocation, lower waste, appropriate upgrade choices and deliberate reserves should materially reduce the impact of lean periods.

The broadened world fiction can contextualize these shifts through the existing off-screen apocalypse. No combat, exterior environment, visible suffering, raids or overhaul of the safe-haven presentation follows from this direction.

### 4.2 Early-run curation versus later-run variety

The developer explicitly distinguished the opening (for example, the first ten days) from much later play (for example, days thirty to forty). Early experience deserves greater authoring attention because it establishes the game and is encountered by more players. A later survivor is likely to have different reserves, infrastructure, habits and resilience.

These day counts are illustrations, not a ten-day boundary after which designed variation stops. Later pacing may use different event combinations, degrees of curation or systemic inputs. The exact later model is open. Do not preserve the old “systemic-only unless equilibrium is proven” rule as an overriding constraint that prevents consideration of deliberate later supply/demand changes.

Equally, the proposal does not require every later valley to be stronger, a fixed repeating catastrophe or automatic escalation until every expert run fails. Indefinite survival remains the existing formal run structure unless separately changed. The relationship between authored conditions and long-run systemic consequences requires design, not an undocumented decision in either direction.

### 4.3 Failure, learning and preparation

The developer accepts that new or casual players may fail the first or second lean period and survive farther on later runs as they learn to prepare. That is part of the intended learning possibility, not a measured failure rate, a mandatory death target or authorization for unavoidable early failure.

This direction does not change the existing run-failure condition or add direct hunger/thirst mortality. How supply pressure reaches failure continues through the agreed consequence systems unless separately redesigned.

The earlier “90%” observation concerned expected audience distribution and design effort, not measured analytics or a retention objective. Preserve it only as a hypothesis, if mentioned at all.

The discussion recommended making the type and approximate horizon of major pressure understandable enough for preparation. Baseline monitoring matters: missing a request because it was invisible is not the same as knowingly underfunding it. Exact communication, certainty and forecast detail are undecided; do not expose hidden future outcomes merely to make every event predictable.

At the current M4 compression, 18 active game hours equal 45 real minutes, so ten days equal 7.5 active real hours before pauses. This is arithmetic context, not a fixed release day length. The opening should be considered in real player-hours and meaningful choices, not only calendar labels.

The developer cited Project Zomboid's loss of conveniences and 7 Days to Die's periodic threat as preparation/payoff analogies. Preserve their purpose, not unverified exact game schedules. No spoilage, siege, utility-grid or combat mechanics from those examples are imported into Sorting Apocalypse by analogy.

### 4.4 Authored conditions versus forced inventory outcomes

**Discussion recommendation:** author the pressure opportunities and conditions, not an exact stockpile trajectory every player must experience.

Efficient players should be allowed to enter a valley with more reserves and leave it in better condition. Poor allocation may turn the same conditions into a crisis. The game should not silently increase needs or reduce rewards merely to force both players down to the same stock floor. This preserves the developer's premise that preparation meaningfully softens the valley.

Similarly, recovery is not an automatic rescue grant whenever stock runs low. It is a change in the conditions under which the player works. No adaptive balancing architecture has been approved; any future use of one would need its own explicit scope and limits.

The proposed pacing complements consequences; it should not sever them. Once actual expeditions are implemented, environmental/supply conditions should influence those real outcomes while preserving the effect of provisioning and the committed-outcome model. M4's independently scripted delivery fixture is not the intended substitute for that relationship.

### 4.5 Persistent reserves and the organizing payoff

**Discussion recommendation:** do not aim to empty the entire bunker at the end of every valley. Some resident inventory should remain useful across days so organization has continuity. Uneven category pressures can create serious shortages without reducing every shelf to empty.

A large physical reserve does not mean adequate supply in every lane. A player can hold substantial Food but little compact Hydration, awkward Weapons but scarce efficient equipment, or Medical sufficient for treatment but not generous expedition preparation. These are illustrative conditions, not current manifest changes.

Once a substantial working reserve exists, a modest daily surplus can be acceptable. It is the long wait to build any meaningful reserve from almost nothing that motivated the concern. Conversely, endless high surplus would eventually make finite storage or choices problematic; the goal is not infinite accumulation.

Stable zones are a reward. Reusing a well-organized shelf is not a failure that must be corrected by forcing daily reorganization. The ongoing activity can come from replenishment, retrieval, a changed assortment and occasional expansion. Avoid worthless filler added only to make shelves look full.

### 4.6 Material pressure and handling pressure

**Discussion recommendation:** treat resource scarcity and physical workload as separate design dimensions.

Abundant phases can create handling pressure through receiving, placement and space decisions while survival needs remain forgiving. Lean phases can reduce incoming volume yet make allocation more consequential. They need not maximize time pressure and scarcity simultaneously.

This gives quieter afternoon/evening periods a legitimate role in organizing and preparing. Do not automatically fill every quiet interval with more consumption requests, especially when lack of resident stock is the reason there is little to organize.

Travel burden also interacts with reserve size and geography. A large nearly empty bunker creates little reason to use distant rooms. Later spatial review should distinguish travel, searching, reading and handling rather than compensating by repeatedly raising player capacity or movement speed. No geometry changes are authorized here.

### 4.7 Use existing levers before adding major systems

The developer's preference is creative use or modest extension of existing/planned systems. Candidate expressions discussed include:

| Fictional condition (illustrative only) | Existing-system lever to investigate |
|---|---|
| Access to an unusually productive location | Greater useful expedition supply or a changed assortment for a period |
| Unreliable access or less productive routes | Lower expected returns or a category-specific supply constraint |
| Temporary operational requirement | An explicitly designed Bunker Ops need using existing lanes |
| Difficult expeditions and retained injuries | Consequent Medical pressure through the injury/treatment system, not arbitrary added patients |
| Conditions improve | Supply/demand changes that permit rebuilding without resetting possessions |

These are possibilities, not a finished event catalogue. Exact events, timing, forecasting, demand curves, generation rules and recovery limits remain open. Preserve the existing strict content ownership: Receiving presents committed cargo; it never rerolls or removes awkward items to manufacture a pressure phase.

### 4.8 First evaluation and open design questions

A proposed low-scope evaluation is one authored accumulation–drawdown–recovery sequence tested with different allocation behaviours and initial reserves, before building a general pacing director. This is a recommendation for later design, not M5 authorization or an extension of M4 acceptance.

Questions worth retaining: how much useful resident stock survives mornings and nights; category coverage rather than only net Bulk; duration items remain stored before use; occupied reachable shelf space; whether costly upgrades are chosen or postponed for meaningful reasons; whether good preparation noticeably changes the valley; whether a failed run leaves understandable lessons; and how to give recovery value without guaranteeing an effortless equilibrium.

None of the exact numerical answers is settled. The important retained decision is that the overall experience should deliberately consider non-flat abundance and scarcity, with a particularly curated opening and a separately designed later experience.

## 5. M4 observations and calibration rationale to retain in the MVP record

The following should become a concise but substantive progress/design-findings section, linked to the detailed GDD concepts rather than duplicating their entire text:

1. **M4's exit boundary is mechanical.** Five-lane selected-item contributions, outgoing/return capacity, item-specific Bulk/Utility, handling, clock, continuation and the final UI are human-accepted. The entire hoarding/survival economy is not an additional M4 gate.
2. **Morning pressure had competing confounders.** The developer almost completed four full teams by the cutoff, assisted by an early scripted delivery; unfamiliar, unorganized seeded stock and text-heavy UI worked against them. Do not describe the window as proven “lenient,” and do not change it solely from this run.
3. **Opening population is an intended direction, not shipped data.** Around ten scavengers means 4/4/2 under the existing formation rule. Sixteen remains M4's stress fixture. No final starting-population value is locked.
4. **Selection learning versus UI friction.** Learning item values and choosing efficient combinations is desirable mastery. Parsing redundant prose is not. The final inline colour/UI change materially improved the developer's reported speed of understanding; this is human observation, not an instrumented comprehension metric.
5. **Monitoring is necessary.** Local indicators alone do not reliably announce obligations across the wing. Baseline awareness and central overview are future requirements, not optional upgrade purchases.
6. **Stockpile deficiency is a design finding.** After heavy provisioning and meals, shelves were nearly empty, leaving little reason to organize or expand. The pictured Day 1 report had all four teams full and meals at 100%, but Medical 0/24/expired; do not turn it into evidence that every consumer was fulfilled. Other tests remain separate.
7. **Quieter afternoons and travel deserve dedicated treatment.** They are not automatically evidence for more mandatory requests or global speed/capacity changes. Layout compression is an investigation, not a committed remodel.
8. **Item-specific corrections precede global compensation where appropriate.** The developer reduced a few Food/Hydration high ends after observing represented quantity and avoidable waste. The large carcass's irregular Footprint is not proof of much more food than the piglet. Request sizes/carrying capacity remain tunable, but changing hundreds of interactions to accommodate a few outliers is not the first response. No universal zero-waste rule or maximum-waste threshold was approved.
9. **Practical catalogue authoring is not a single Footprint formula.** Preserve Bulk as handling burden, Utility as useful contribution and represented quantity, broad nutritional grounding for Food, per-category effectiveness, and deliberate strong/weak options. P01 remains historical/proposed, not a command to regenerate the accepted 167 values. The wider catalogue intentionally contains a broad useful middle and weak/exceptional options; do not force every Utility lane or efficiency ratio into one bell curve. Strong combinations remain desirable when supply availability and opportunity cost prevent reliable on-demand repetition.
10. **Loading architecture is a targeted future investigation.** Stage A/B improvements were human-observed and technically accepted; residual catalogue/wing loading is not an M4 blocker. Study it before major content growth if warranted; do not label a particular loading architecture defective without diagnosis.

## 6. Documentation integration and acceptance test

The full GDD must let a reader who never saw this conversation reconstruct the Workshop purpose, Training slot rules/tradeoffs and the whole-run pacing direction. MVP should retain the causal playtest findings and link to those substantive sections. README/CURRENT_STATE/BOOTSTRAP should remain concise operational pointers, not become the only place the ideas survive.

For each concept include: motivation, player choice, proposed operation, at least one concrete example, confirmed details, boundaries, interaction with existing systems, unresolved choices and provenance. Use the anchors in §1 to distinguish developer proposals from recommendations.

A future reader should not conclude any of the following: all monitoring must be bought; current lift data should be removed; Training grants individual stats or cross-run unlocks; training Team 2 repacks its people into another team; an unoccupied slot is definitively allowed or forbidden to train without a decision; one-day training is still wholly undecided; deliberate pressure ends after Day 10; 90% early failure is a target; every valley must empty the bunker; or M4 cannot close until these ideas are implemented.
