# Sorting Apocalypse Preliminary GDD v0.9

> Generated text/table extract of the same-named DOCX. Content order is retained; Word pagination, headers and text styling are not reproduced. Embedded images are linked below. Edit the master and regenerate; this is not an independently authored authority.

SORTING APOCALYPSE

PRELIMINARY GAME DESIGN DOCUMENT

A first-person spatial organizing game with survival logistics

The player never fights or sees a zombie. They run the storeroom that keeps everyone else alive.

CORE PROMISE The apocalypse ends at the elevator door.

Version 0.9 | 20 September 2026

Living design | Storage authoring foundation consolidated; ladder proof is the next bounded interaction gate

Consolidates the accepted whole-wing geometry, continuing gameplay composition, editor-authored item palette, locker and Fuel maintenance, and the completed ground-access shelf and ceiling experiment. The retained review scene and user-authored modular rack are evidence tools, not production storage. Receiving remains after review-scene supply reuse, reusable modular-rack authoring and a bounded fixed-ladder proof.

Companion documents: Prototype Findings v0.9; Visual Design and World Building Direction v0.6; Receiving and Elevator MVP Architecture Design (12 September 2026).

## Document purpose and status

This document formalizes the current design of Sorting Apocalypse into a preliminary, implementation-oriented game design document. It records confirmed decisions, incorporates validated prototype evidence where explicitly promoted, distinguishes tuning targets from confirmed rules, and preserves unresolved questions as validation items rather than silently converting them into requirements.

It is intentionally layered. The document describes the intended full design, a smaller playable MVP, and an interaction prototype that can invalidate the riskiest assumptions before significant art or content production begins.

### v0.9 authority and evidence boundary

This GDD remains the overall design authority. Prototype Findings v0.9 records implementation and validation evidence; Visual Design and World Building Direction v0.6 supplies environmental and storage-installation direction. The accepted in-engine wing remains the working spatial baseline. The 12 September Receiving specification retains subsystem detail, while the current storage-authoring gates precede physical Receiving. Explicit supersessions are recorded in Appendices C and D.

This update preserves the established design mechanics and historical evidence while bringing the current record through 20 September. It records the promoted continuing gameplay scene, expanded editor-authored palette, resolved locker and Fuel maintenance, default-entry and F6 acceptance, and the completed shelf and ceiling ergonomics experiment. It does not promote review assets into production storage or authorize Receiving, gallery furnishing, camera or ceiling changes, crouch, ladders beyond the bounded proof, or player-adjustable shelves.

### Decision-status legend

| Status | Meaning |
| --- | --- |
| Confirmed | A deliberate design decision accepted for the current design. It may still change after evidence from testing. |
| Provisional | A working target, number, formula, name, or implementation route that requires tuning. |
| Validate | A design or technical assumption that must be proven through a prototype or playtest. |
| Deferred | Intentionally outside the first-release target unless later reassessed. |
| Fallback | A simpler alternative retained in case the preferred implementation is too costly or unclear. |

### Document conventions

- Numbers marked as provisional are balancing handles, not promises. Examples illustrate the desired decision space rather than final item values.

- The word "Utility" means an item's numeric contribution to a destination or request. "Bulk" is one shared burden value used for carrying and expeditions. "Footprint" governs physical storage. Utility Density is an internal balancing measure, not a player-facing item statistic.

- The world outside the logistics floor is treated as fiction supported by audio, text, items, and calculated outcomes. It is not a hidden future feature requirement.

- The design favors unified, explainable systems over literal simulation when the abstraction preserves the player fantasy.

## Contents

| Section | Title |
| --- | --- |
| Part I | Vision and Player Experience |
| 1 | Game Definition |
| 2 | Design Pillars and Non-Goals |
| 3 | Core Gameplay Loop |
| 4 | World Boundary and Fiction |
| Part II | Core Systems |
| 5 | Run Structure, Time, and Daily Rhythm |
| 6 | Unified Item Grammar |
| 7 | Physical Interaction and Storage |
| 8 | Facilities and Material Flows |
| 9 | Scavenger Population and Expedition Lifecycle |
| 10 | Provisioning, Load Capacity, and Returned Loot |
| 11 | Receiving Elevator and Delivery Queue |
| 12 | Kitchen, Meal Service, and Ration Production |
| 13 | Medical Bay |
| 14 | Bunker Ops |
| 15 | Salvage, Incineration, Workshop, and Upgrades |
| Part III | Presentation and Production |
| 16 | Feedback, Interface, Lights, and Audio |
| 17 | Narrative Direction |
| 18 | Technical and Content Strategy |
| Part IV | Scope and Validation |
| 19 | Balance Philosophy and Systemic Difficulty |
| 20 | Prototype, MVP, and Full-Game Targets |
| 21 | Validation Plan, Risks, and Open Questions |
| Appendix A | Example Day |
| Appendix B | Glossary and Confirmed Constants |
| Appendix C | v0.8 Revision and Source Register |
| Appendix D | v0.9 Storage Authoring Consolidation |

PART I | VISION AND PLAYER EXPERIENCE

## 1. Game Definition

### 1.1 One-sentence concept

A zombie survival game in which the player never fights a zombie: they receive, sort, store, ration, salvage, and dispatch the physical supplies that keep an unseen bunker alive.

### 1.2 Product snapshot

| Dimension | Current design |
| --- | --- |
| Working title | Sorting Apocalypse |
| Primary genre | First-person spatial organizing game with survival logistics |
| Structure | Formally endless, consequence-preserving runs measured in days survived |
| View and space | Contained first-person, low-complexity realistic underground logistics wing; no exterior exploration. Concrete/masonry architecture with layered survivor adaptation. |
| Player role | Anonymous Quartermaster responsible for receiving, storage, provisioning, disposal, Bunker Ops, and upgrades |
| Primary verbs | Inspect, carry, sort, stack, label, retrieve, submit, salvage, incinerate, and reorganize |
| Core pressure | Finite time, finite space, timed requests, variable loot, fragile scavenger population, treatment backlog, outages, and player-created disorder |
| Failure | All scavengers are dead after any final recruit-candidate decision, and no accepted recruit is due to join |
| Victory | No formal victory state; indefinite equilibrium is technically possible |

### 1.3 Player fantasy

The player is the master of the bunker logistics floor. They own the elegant, well-oiled system the room may become, and they own the backlog, mislabelled crates, inefficient shelves, and desperate retrieval runs when that system fails. The fantasy is not decorating a room to match a designer-authored solution. It is imposing a personal, functional order on an endless stream of imperfect material.

The Quartermaster is also indirectly responsible for survival. A neat pantry is not a score object; it is the reason breakfast can be supplied in seconds while a Medical request is also active. A crowded shelf is not merely ugly; it may conceal the last antibiotics. A low-value tennis racket is not designated junk; it may be the item that finishes a Weapons request while clearing valuable storage space.

The player is continuing an experienced Quartermaster's working life, not arriving as a new hire in an empty bunker. Installed storage, routines and familiar work areas already exist alongside a modest backlog of postponed tasks. Starting loot quantities remain an economy/balance decision; environmental age does not require a particular amount of pre-seeded inventory.

The organizing and collecting fantasy is primary. Hoarding preserves useful future options; scarcity and space pressure make selective conversion or disposal meaningful. The active bunker is a dependable, sheltered workplace. The intended presentation is casual logistics with systemic survival consequences, not gritty visible suffering or a literal inhabited-colony simulation. The absence of visible human characters controls production scope and emotional emphasis; it does not remove the existing failure rules. [D13-14, V03 §§2, 8, 14-15; D16S]

### 1.4 Core promise

- Every stored object remains physically present and potentially relevant.

- Organization is continuously disturbed by consumption, incoming loot, timed requests, and capacity pressure.

- Almost any object can be useful in the right context, but usefulness must compete with Bulk and Footprint.

- The player's layout and habits determine retrieval speed. The game does not impose a single correct filing system.

- Survival outcomes are caused by the player's handling of physical items, not by a parallel abstract strategy layer.

## 2. Design Pillars and Non-Goals

### 2.1 Design pillars

| Pillar | Design consequence |
| --- | --- |
| Sorting is survival | The organizing loop directly drives meals, treatment, expeditions, Bunker Ops, upgrades, and survival. |
| The player owns the system | Containers are permissive; labels are player-authored; bad organization remains possible and meaningful. |
| Physical first, menus second | Items move between spatially located facilities. Abstract screens support status and selection but do not replace the room. |
| Simulate consequences, not unseen events | The outside world, NPC activity, expeditions, construction, and attacks are represented through outcomes, audio, text, lights, and objects. |
| Unified rules where they help | Bulk is shared across carrying, outgoing loadouts, and incoming loot. Numeric Utility follows one consistent grammar. |
| No game-defined junk | The game supplies values and opportunity costs; the player decides what is worth keeping, salvaging, or destroying. |
| Systemic pressure over scripted escalation | Difficulty primarily emerges from the bunker's condition, population, storage saturation, and prior decisions. |
| Efficiency is an aesthetic | Low-detail art, modular architecture, frozen item states, and scripted theatre are deliberate design choices, not apologies. |

### 2.2 Non-goals for the initial game

- No player combat, zombie encounters, surface exploration, or exterior level design.

- No visible simulated human NPC population and no requirement for human character models, animation, or individual schedules. A single tentative ambient bunker dog is the only contemplated living-character exception and must remain non-mechanical.

- No free-form base building or arbitrary furniture placement. Storage expands through predetermined sockets.

- No unrestricted rigid-body item world. Items cannot be dropped anywhere on the floor.

- No broad colony-management dashboard, employee roster, or manual expedition destination selection at launch.

- No conventional money economy. Space, time, supplies, salvage, and scavenger capacity are the meaningful costs.

- No player hunger, thirst, sleep, or combat statistics.

- No modeled or visible staffed operational interiors: treatment wards, cooking stations, mess hall, fabrication floor and administrative office remain off-map. Dedicated player-accessible departmental service rooms and the Bunker Ops Transfer Landing are part of the playable wing; they are not those staffed interiors. [D16S]

- No autonomous movement, appearance, removal or tidying of decorative props to simulate unseen residents. Explicit gameplay transitions may change authored states; ordinary background dressing remains fixed.

- No displayed personnel route to the surface, perimeter-defense loop, or branching Quartermaster dialogue. The goods lift is not a player or scavenger transport route.

### 2.3 Production doctrine

When an expensive event can happen beyond a door, shutter, hatch, radio, elevator, wall, or night transition, calculate the result and present the evidence.

This smoke-and-mirrors doctrine is a recurring implementation rule. It keeps the playable domain small while allowing the fiction to imply a much larger survivor settlement and dangerous outside world.

## 3. Core Gameplay Loop

### 3.1 Minute-to-minute loop

LOOP Receive > Triage > Store > Retrieve > Submit

The player receives a pile, decides what deserves attention, transfers items through the carried bundle and legal storage, retrieves them as needed, and commits them to a request or conversion/disposal destination. Carry-to-storage organization is reversible; Receiving is TAKE-only and does not accept returned items. Submitted items are irreversible destination accounting, not hidden temporary storage.

### 3.2 Complete material loop

ELEVATOR -> CARRIED -> SORTING TABLE / STORAGE -> ACTIVE REQUEST -> KITCHEN RATION INPUT -> OVERNIGHT -> PHYSICAL RATIONS -> BUNKER OPS -> SALVAGER -> PHYSICAL SALVAGE -> STORAGE / WORKSHOP -> INCINERATOR -> REMOVED

Items never become an invisible general inventory. They remain attached to a bounded physical system until consumed, converted, or destroyed.

### 3.3 Day-to-day loop

1. At 07:00 the bunker wakes. Stored and carried loot persists; only explicitly completed production, repairs or authorized socket upgrades change the relevant authored states. Ready scavengers are divided into teams and their destinations and loadout requests become available.

2. From 07:00 to 09:00 the player provisions and dispatches teams while handling any early random request and remaining Receiving backlog.

3. At 09:00 all unsent teams depart automatically. The first fixed Kitchen meal request also anchors the day.

4. Throughout the day, Medical treatment requests, loot returns, one Bunker Ops request, ration preparation, storage work, machine outages, and upgrade decisions compete for attention.

5. The Kitchen issues additional fixed meal requests at 14:00 and 18:00.

6. Returning expeditions create delivery anticipation, elevator backlog, injuries, deaths, and possible recruit candidates.

7. At midnight, Medical treatment, Meal Coverage, Bunker Ops effects, outage schedules, Workshop progress, ration output, optional contamination, and population changes resolve; the summary pauses the game before the next day begins at 07:00.

### 3.4 Emotional rhythm

The intended rhythm alternates between deliberate order and sudden interruption. Early in a day the room may feel meditative. A fixed meal approaches, then a Medical light activates, then the service lift's arrival cues begin, then a second expedition returns while the elevator queue is already full. The game creates chaos through overlapping obligations rather than enemies in the playable space.

The strongest late-game moments should visibly consume the player's history. A carefully hoarded reserve becomes an emergency arsenal; shelves empty; low-density items are finally incinerated; ration stacks disappear. A well-stocked bunker is stored resilience, not a completed collection.

## 4. World Boundary and Fiction

### 4.1 The playable domain

The Quartermaster occupies an inward-facing logistics wing within an established survivor settlement. Receiving, Backlog, Sorting, five Storage galleries, departmental service spaces and machine spurs now exist in a complete neutral greybox. Human review after round three and the Medical-only tuning promotes this as the working spatial baseline. The accepted builder, saved geometry and final overview govern subsequent dimensional work; they are not production-art or furnished-gameplay approval. [W17, H17, A17]

Workshop and Kitchen each have a dedicated, enterable service room; Medical has an enterable Supply Anteroom. Bunker Ops uses a more open, dedicated Transfer Landing. These visible support spaces belong to their departments and accommodate handoff, equipment support and limited staging. Their staffed operational cores remain behind opaque inner boundaries and are not modeled. Do not substitute a closed door at the service-space entrance for its playable floor area. [D16S]

Personnel travel to the surface occurs elsewhere in the unseen settlement. It is not shown, mapped or explained. Normal playable circulation favors open thresholds rather than operable interior doors. The goods elevator is the Quartermaster's only direct material connection to returning surface supplies, not the route scavengers use. This supersedes v0.4's suggestion of a visible Surface Access door. [D15T, V03 §§2, 11, 16, 29]

### 4.2 The service elevator as world boundary

Receiving is a shallow freight bay recessed behind a permanent safety barrier and a powered shutter. The player remains on the apron, cannot board the lift or obstruct its machinery, and can only TAKE revealed goods. The deck and walls do not actually travel; sound, warning lamps and shutter movement imply the unseen lift journey.

Loot content is committed upstream, prepared in an isolated hidden environment and frozen into ordinary WorldItems before reveal. The shutter controls visibility and interaction availability, while the permanent barrier controls player access. Section 11 defines the preparation, deposit, presentation and recovery contracts.

### 4.3 Story through material evidence

The player does not witness events outside. They infer them from what returns, what is missing, what has been consumed, and what the bunker asks for. The contents of a haul can indicate a pharmacy, residence, failed police checkpoint, evacuation site, or disastrous retreat without a cutscene.

- Audio and PA messages suggest returns, urgency, casualties and off-screen activity while the logistics wing remains sheltered from the surface. Ordinary ambience must not turn the occupied bunker into a constant threat zone.

- Optional 2D portraits / face cards may announce events without introducing visible human models, silhouettes, staffed operational interiors or NPC simulation. The approved service rooms do not change that production boundary.

- Objects can carry low-cost narrative meaning: damaged gear, bloodied clothing, photographs, keys, notices, personal possessions, or unusual combinations.

- Scavengers remain anonymous at launch; emotional weight is expected to emerge from population counts, lost capacity, and objects rather than authored biographies.

### 4.4 Ambient bunker dog (tentative)

TENTATIVE / VALIDATE. One ambient dog may become the logistics floor's only visible living companion. The dog is atmosphere and companionship, not a survival system, worker, mascot buff, or hidden management obligation.

- Arrival is guaranteed on one fixed playtest-selected day - Day 2 or Day 3 - rather than randomized between them. It arrives through the normal service elevator during a suitable variable-time delivery, alongside an ordinary loot batch but at a dedicated safe marker rather than literally inside the pile.

- The dog has no hunger, thirst, health, injury, fear, death, loss, morale, Utility, or other gameplay state. The game must never explicitly or implicitly threaten or harm it, and its presence is independent of the bunker's simulated wellbeing.

- Behavior is lightweight and curated: authored low-traffic rest/observation regions, safe low-traffic decorative/rest areas, never beyond abandoned-route barriers; simple navigation or fallback scripted routes; and reactions only to inconsequential environmental stimuli. If navigation proves disproportionately costly, a mostly stationary companion role - for example resting near an observation point such as a fish tank - is acceptable. It has no gameplay collision authority.

- No petting, commands, customization, training, needs, inventory, or relationship progression is required initially. The lack of animated hands also argues against adding petting merely as a checkbox interaction.

- The feature is accepted only if it strengthens tone and the sense of an inhabited bunker without creating pathfinding, animation, content, or emotional-safety scope disproportionate to a solo project.

### 4.5 Approved world history and tone

The settlement inhabits part of an unfinished/decommissioned metro-service construction project, but transit ancestry is indirect: the ordinary player should read old underground municipal/service infrastructure, not a subway platform. No tracks, passenger platforms, ticketing, commuter signage or long train tunnels define the playable wing.

The visible original construction spans approximately 30-50 years, primarily late-20th-century civil work with halted phases, partial resumptions, repairs and later upgrades. Before the apocalypse, some service areas were still maintained while unfinished branches were already neglected. Survivors have occupied it for several years; they furnish, patch and adapt rather than rebuild the structure.

Competent people operate with scarce, mismatched resources. Active areas are worn but dependable, generally dry and usable. Serious collapse and neglect sit behind clear abandoned-area boundaries. The Quartermaster's workplace absorbs personal routines, but is not a residence or lounge. Decorative evidence is fixed; one-way messages from the Administrator and other unseen residents provide context. [V03 §§2-9]

### 4.6 Spatial relationships and territorial rules

| Area | Approved relationship / constraint |
| --- | --- |
| Core logistics | Receiving -> widened backlog passage -> Sorting / Quartermaster Central -> main Storage network -> Deeper-Bunker Approach. Expedition Loadout/Dispatch is a shallow alcove near Receiving. Direct Receiving -> Storage transfer remains legitimate; the sorting table is optional staging, not a mandatory step. |
| Sorting | Widened passage, not a destination room. Wall-backed wide/shallow table with front and both ends accessible; small support furniture stays secondary. Roughly 90 degrees from the work position gives partial/oblique Receiving awareness without reliable item identification; roughly 180 degrees reveals Storage. Exact clearances remain a greybox variable. |
| Storage | Five current galleries A-E carry the directional 85-90% main-capacity target. One primary spine plus one deliberate C<->D secondary connection; no grid, full ring or maze. A/B sit on the inhabited side, C/D/E on the lower/service side; Gallery E is not a shortcut into the Deeper-Bunker Approach. Gallery shapes may vary, but first-pass irregularity must remain restrained and buildable. |
| Workshop / Salvager | Dedicated service branch from Sorting/early shared Storage, never through C. Accepted Workshop Service Room connects to the separate bent Salvager spur. The former abandoned continuation was removed; no replacement dead-end is part of the current functional wing. [D16-R02, A17] |
| Kitchen / Medical | Medical begins beyond the A/B Main Storage connector, with a 10 m exclusive protected spur and an unchanged-size anteroom widening west of its aligned eastern wall. Kitchen is reached through B-east along an east-then-north approach. No Medical-Kitchen shortcut; no gallery-mediated Medical access. [A17] |
| Bunker Ops / Incinerator | The longer shared approach narrows through a clean dog-leg. Incinerator remains on its own spur with corridor buffer before a more open Bunker Ops Transfer Landing. Its material interface and the personnel-sized deeper-settlement door are separate. [H16, D16S] |
| Abandoned continuations | No abandoned stub is required or reserved in the accepted wing. Later consider roughly two or three opportunistically, never directly connected or immediately adjacent to service spaces/Ops. Retain the storytelling option without rebuilding the removed Workshop branch. Functional machine spurs and the active settlement closure are unaffected. [D16-R02] |
| A/B shared junction | Required A-east and B-west openings face shared circulation. Distinguish that junction from the protected Medical spur; these are not an extra direct inter-gallery shortcut. C<->D remains the sole dedicated gallery-to-gallery secondary connection. [H16] |

The accepted in-engine builder, saved scene and final overview are now the working dimensional authority, subordinate to later explicit decisions. Detailed Topology V3 and Basic Structural Schematic V2 remain unchanged historical intent references; do not revert approved in-engine refinements to match their pixels. Visual Direction v0.5 recorded the service spaces, Kitchen-from-B routing, Medical alignment and abandoned-stub deferral at that checkpoint; Visual Direction v0.6 is the current visual authority. [V05, A17, D16-R02]

### 4.7 Interior threshold and boundary policy

Normal playable circulation uses open architectural thresholds/doorways without operable doors. This preserves movement flow, sightlines and production scope, and avoids turning routine logistics travel into repeated door interaction.

Fixed opaque closures mark the inner boundary from playable service space to unseen staffed core, the freight system and deeper-settlement access. A service-room entrance remains open and traversable. Abandoned-route closures are later world-building, not current wing requirements; no abandoned stub remains beside Workshop or is reserved elsewhere. Crossing a territorial entrance neither commits supplies nor crosses the inner world boundary. [D16S, D16-R02]

### 4.8 Departmental service spaces and the three boundaries

CONFIRMED The player enters the quiet support space outside each department's staffed operation, not an occupied workplace with its people removed. Workshop and Kitchen are dedicated service rooms; Medical is a Supply Anteroom; Bunker Ops is a more open Transfer Landing. Distinct footprints and approach relationships are required, not one rectangle repeated with different props. [D16S]

| Boundary | Meaning and construction implication |
| --- | --- |
| Territorial | The open entrance or defined landing edge marks entry into department-owned support space. The player can walk in. This is not the inaccessible facility wall. |
| Material ownership | Only the explicit legal submission action commits supplies. Entering the room, standing near equipment or leaving a carried item selected does not transfer ownership. A plain proxy reserves the future interface location. |
| Playable world | An opaque inner wall / fixed closure separates usable support floor from the unseen staffed core. Do not place the blocker across the service-room entrance or substitute a solid box for the room. |

Shared approach -> playable departmental service space -> inner interface / opaque boundary -> implied off-map staffed core. The inner boundary may lie on a side or end wall; it must not consume the intended playable support footprint. Bunker Ops additionally retains a separate personnel-sized settlement door.

| Space | Approved footprint character / role |
| --- | --- |
| Workshop Service Room | Broad, genuinely enterable equipment/project-material support room with distinct usable floor and a separate opaque staffed-core boundary. Preserve the accepted Salvager route and continuous southern perimeter; no abandoned stub or reserved recess. Detailed furnishing and final transfer devices remain deferred. |
| Kitchen Service Room | Elongated catering-support room, spatially distinct from Medical. Usable handoff floor and perimeter space can accommodate the existing meal / ration functions later. No cooking line or dining interior is exposed. |
| Medical Supply Anteroom | Compact but genuinely room-like end-of-spur space. Protect clear standing/turning floor and restrained equipment support; no ward, patients or empty reception setting. |
| Bunker Ops Transfer Landing | A more open widened terminal/shared-circulation condition. Material handoff lies along one side; the deeper-settlement door is a separate destination. No office interior. |

The facilities retain resource consumption, distinct outcomes and unseen-community roles; Workshop remains player-initiated project investment, not another compulsory punitive quota. Service spaces add no new chore, ambient staff simulation, free Quartermaster storage or retrievable departmental reserve. Existing submission, output and state-persistence rules remain unchanged.

The service-space footprints and inner boundaries are accepted at neutral greybox fidelity. Final furnishing, staff doors, material-transfer mechanisms, delivery choreography and audio/visual treatment remain future work. Functional test shelves and real catalogue loot may be installed in the wing before art approval to validate existing handling; that does not authorize departmental dressing, free service-room storage or new sourcing. [D16S, A17, D17B]

PART II | CORE SYSTEMS

## 5. Run Structure, Time, and Daily Rhythm

### 5.1 Endless run structure

CONFIRMED A run has no formal completion day. It continues while at least one scavenger remains alive, a final recruit-candidate decision is pending, or an accepted recruit is due to join. Exceptional players may reach a stable equilibrium, although complete storage expansion eventually caps physical capacity and requires increasingly selective retention.

The principal run record is days survived. Long-run difficulty is expected to arise from saturated storage, population choices, resource conversion, queued deliveries, treatment backlog, Bunker Ops failures, and player mistakes rather than a mandatory day-count difficulty multiplier.

VALIDATE Playtesting must determine whether purely systemic pressure produces sufficient long-term instability. A restrained hybrid escalation model may be added only if expert players otherwise reach effortless permanent equilibrium.

### 5.2 Daily clock

| Time | Event or design purpose |
| --- | --- |
| 07:00 | Day begins. Stored and carried items persist; completed production and explicit authorized upgrades/repairs have applied. Teams form and morning provisioning opens. |
| 07:00-09:00 | Lenient expedition preparation window. Early loot returns are rare, leaving time to organize, prioritize teams, or handle a surprise request. |
| 09:00 | All remaining teams auto-dispatch. Kitchen meal request 1 occurs. |
| 14:00 | Kitchen meal request 2 occurs. |
| 18:00 | Kitchen meal request 3 occurs. |
| By about 23:40 | All expeditions are forced to return if their calculated duration would otherwise cross the day boundary. |
| 00:00 | Day resolves. Summary pauses the game; night calculations and production apply; next day starts at 07:00. |

### 5.3 Real-time pacing and pause rules

PROVISIONAL One full in-game day targets approximately 25-30 real minutes. This is a major pacing knob and must be tuned against carrying friction, storage size, request frequency, and the desired calm-to-chaos ratio.

- Escape/pause menu pauses simulation time.

- The night report screen pauses simulation time.

- No ordinary inspection, item handling, request, terminal, label, or storage interface pauses time. The zoning editor is the explicit exception: it pauses simulation while the player edits one StorageSurface through a modal flat view, because no world progress or timing exploit can occur inside that editor.

- There is no bed or manual sleep action. The day ends at midnight automatically.

- No real-world time passes while the application is closed.

- The scheduler must not create a request whose deadline extends past midnight.

### 5.4 Night transition

The midnight transition preserves the physical organization of stored loot, sorting-table contents, containers and the carried bundle; it does not perform general cleanup. Treatment, Meal Coverage, Bunker Ops outcomes, pre-rolled outage windows, Workshop progress, ration output, optional contamination, recovery and population changes resolve as already specified.

Explicit player-authorized progression is the bounded exception: a completed socket upgrade may remove its designated non-loot placeholder clutter and install/activate storage; a scheduled machine repair may change an offline landmark to its operational state. These authored, persistent changes occur out of view without construction or removal animations. They do not authorize ambient prop tidying or disposal of player-owned loot. [D14-15, V03 §§9, 15.1, 23]

The summary explains causality rather than equations. Short one-way Administrator messages may accompany tutorials, completed upgrades or repairs during or immediately after the transition. There is no branching conversation or required Quartermaster reply; detailed timing/presentation remains to be designed.

### 5.5 Night report

The night report targets a single paused screen composed of bounded cards in a grid. Each card should communicate one area of the bunker with a clear icon, one or two prominent figures, and no more than a few concise causal statements.

| Card | Core information |
| --- | --- |
| Scavengers | Alive, Ready tomorrow, Medical, newly recruited, and dead. |
| Expeditions | Teams returned, late clamps, loot received, and Awaiting Lift forfeits. |
| Medical | Treatment attempts, successes, Meal-related failures, state transitions, complications, and forecast returns. |
| Meal Service | Food and Hydration coverage across the three meals and the resulting treatment/Workshop modifier. |
| Bunker Ops | Fuel, Morale, and Electronics coverage plus the next day's pre-announced penalties. |
| Workshop | Current project, progress gained, delays, completion, and installed output. |

If an unusually eventful day does not fit cleanly, the first screen remains a card summary and individual cards may open compact detail sub-reports. A long scrolling ledger is the fallback of last resort.

### 5.6 Save behavior

CONFIRMED Multiple consequence-preserving run slots. The game autosaves at day transitions, supports save-and-exit during a day, and does not provide manual rollback saves. Save integrity prioritizes corruption recovery and the preservation of random outcomes and irreversible transactions.

The preferred implementation uses three resilience layers. Exact file formats are technical decisions, but the behavioral guarantees are part of the design.

| Layer | Required behavior |
| --- | --- |
| Rotating snapshots | Keep a current and previous known-good snapshot; write to a temporary file, validate, then promote. Snapshot at day transition, save-and-exit, and periodically during play. |
| Transaction journal | Immediately record irreversible actions such as submission, salvaging, incineration, recruit decisions, upgrades, dispatches, and committed treatment outcomes. |
| Deterministic outcome commitment | Persist seeds or generated results before revealing expedition loot, casualties, recruitment, treatment rolls, contamination, or outage schedules. |

A crash may acceptably roll back roughly one or two real minutes of harmless spatial reorganization, but it should not duplicate consumed items, undo irreversible choices, or reroll a revealed result. If the newest snapshot is corrupt, the game loads the previous valid snapshot and replays valid journal entries.

A failed run closes as a completed survival record. The exact presentation of failed slots, statistics, archived reports, and run history remains a UI decision rather than a gameplay-system requirement.

Evidence boundary: Stage A has tested batch identity, snapshots and reconstruction contracts, not the full game's durable journal, rotating-save implementation or crash resilience. The guarantees above remain full-system requirements until their dedicated tests pass. [D12A]

## 6. Unified Item Grammar

### 6.1 Core item properties

| Property | Purpose |
| --- | --- |
| Definition / instance identity | ItemDefinition identifies a gameplay type; each physical ItemInstance receives its own durable ID when created. A new batch has unique identities even when a seed repeats the same ordered content. |
| Utility profile | Numeric contribution to a request or destination. Within any one destination, an item may qualify for no more than one meter. |
| Storage Category | One primary placement-policy category: Food, Hydration, Medical, Weapons, Protection, Fuel, Morale, or Electronics. This is separate from destination-specific Utility. General is not an item category. |
| Bulk | One shared abstract burden value used for player carrying, expedition loadouts, return-haul budgets, and loot generation. |
| Storage Footprint | Discrete 2D storage occupancy and compatibility used by shelves, boxes, drawers, racks, stacks, and snap systems. It is separate from Bulk and from physical posed height. |
| Stackability | Authored physical support roles plus one optional automatic compatibility class. Stackability governs deterministic support stacking; it is not inferred from mesh geometry. |
| Salvage Yield | Physical standardized salvage output if processed. |
| Condition / Quantity | Optional state that modifies Utility and possibly Salvage Yield while normally retaining Bulk and Footprint. |
| Visual family | Reusable mesh, material, label, and scale configuration used to produce broad item variety efficiently. |
| Contamination flags | Optional full-game properties: CanContaminate, CanBeContaminated, and IsContaminated. Excluded from the prototype and Systems MVP. |

### 6.2 Bulk

Bulk is deliberately not literal weight or geometric volume. It represents the practical burden of handling and carrying an object. A long, awkward tennis racket can have high Bulk despite being light. A dense tool can have high Bulk despite fitting into a compact footprint.

Bulk is the same number everywhere it matters: in the Quartermaster's arms, in a scavenger loadout, and in a returning haul budget.

### 6.3 Utility

The launch expedition categories are Food, Hydration, Medical, Weapons, and Protection. Protection is supplied mainly by clothing and protective wear, ranging from socks and gloves to motorcycle helmets and ballistic vests. Meal Service uses Food and Hydration; the Medical Bay uses Medical; Bunker Ops uses Fuel, Morale, and Electronics. Utility is always shown numerically so the player develops a consistent understanding of what an object contributes.

The preferred launch rule allows destination-specific alternate uses while preventing ambiguity inside one destination. For example, vodka may count as Hydration on an expedition, Medical at the Medical Bay, and Morale at Bunker Ops, but it never asks the player to choose between two meters at the same hatch.

FALLBACK If destination-specific utility is too costly to author, communicate, or test, all items become globally single-purpose. Automatic submission and readable decisions take priority over item versatility.

### 6.4 Internal efficiency measures

Utility Density is an internal haul-generation and balance measure: normalized Utility per unit of Bulk. Storage efficiency is Utility relative to physical Footprint. The two ratios deliberately differ, producing items that are excellent to carry but awkward to store, or compact on a shelf but costly in a scavenger loadout.

Neither ratio is shown as a player statistic. The player sees an item's +X Utility, Bulk, and physical space requirement, then infers efficiency through experience. The backend may normalize and category-weight Utility when comparing unlike item types, but that normalization remains hidden.

### 6.5 Illustrative item comparisons

PROVISIONAL The values below demonstrate the intended grammar only. They are not an initial balance sheet.

| Item | Example Utility | Bulk | Footprint / handling | Decision pressure |
| --- | --- | --- | --- | --- |
| Tin of cat food | Food 2 | 1 | Small; stackable | Weak food, excellent density, easy emergency input. |
| Stale cereal box | Food 3 | 2 | Large box; poor footprint | Useful but storage-inefficient; attractive Kitchen or ration input. |
| Ration | Food 6 | 1 | Compact; standardized stack | High-density output; valid for meals and expeditions. |
| Knife | Weapons 2 | 1 | Tiny; rack or drawer | Efficient filler and easy to store. |
| Tennis racket | Weapons 1 | 4 | Long and awkward | Near-worthless ROI, but clears space and can finish a desperate request. |
| Pistol | Weapons 8 | 2 | Compact | High Weapons Utility for its Bulk; leaves more return capacity. |
| Vodka | Contextual | 2 | Bottle slot | Potentially Hydration, Medical, or Morale depending on destination. |
| Old duvet | Protection 1 / Salvage 3 | 6 | Huge; terrible footprint | Marginal protection, but still a keep, salvage, or incinerate dilemma. |
| Broken radio | Electronics 3 / contextual | 3 | Medium; irregular box | Useful Bunker Ops input; may also support a destination-specific alternate use. |
| Fuel can | Fuel 5 | 4 | Bulky container | High Fuel value and possible contamination risk; difficult to store safely. |

### 6.6 No game-defined junk

The data model does not mark items as junk for the player. Some objects simply have terrible return on space, Bulk, or attention. Their value changes across the run: an item worth preserving on Day 3 may be an obvious incinerator candidate on Day 25 after every storage upgrade is installed.

This design gives hoarders the desired agony. Keeping an object preserves an option. Salvaging converts it into compact future capacity but still occupies space. Incinerating it immediately solves a spatial problem but destroys all potential value.

Newly sourced gameplay loot must have intrinsic Utility in at least one valid destination, even when its return on space is poor. Environmental tires, broken furniture and wrapped corridor masses are non-interactive set dressing, not hidden zero-Utility loot. The optional contamination rules below remain a separately scoped exception that can reduce an existing item's Utility; they are not a generator category called Junk. [D13-14]

### 6.7 Condition and perishability

VALIDATE Condition and remaining quantity are desirable because they create physically inefficient half-useful objects. Implementation cost must be tested before committing them to the first release.

DEFERRED General food spoilage and shelf-life simulation are shelved for later reassessment. Rations still provide compaction, standardized stacking, and improved Food-per-Bulk and storage efficiency without spoilage. If perishability is later added, ration production can also normalize shelf life.

### 6.8 Contamination (full-game candidate)

VALIDATE Contamination is excluded from the interaction prototype and Systems MVP. It is a candidate for the 1.0 feature set or a later update only if the core storage loop is already stable, readable, and performant.

The mechanic adds a storage rule beyond distance and density without introducing detailed chemistry. Items may be Hazardous, Sensitive, both, or neither. Contamination is evaluated only during the night transition, so brief contact while reorganizing has no effect.

| Property | Meaning |
| --- | --- |
| CanContaminate | The item can damage an eligible Sensitive item stored in the same storage group. |
| CanBeContaminated | The item is eligible to lose Utility when stored with a contaminating item. |
| IsContaminated | Persistent state applied once; a contaminated item cannot be contaminated again. |

- Eligible storage groups are true containers, individual shelf levels or compartments, and the sorting table or its clearly defined sections.

- Receiving and its queue, carried items, expedition loadouts, hatches, facility inputs/outputs, the salvager, the incinerator, and designated specialist racks are exempt.

- At midnight, each affected storage group contaminates at most one eligible uncontaminated item, regardless of how many hazardous objects are present.

- Contamination halves every applicable Utility value, rounded up, except an original value of 1 becomes 0. A destination rejects an item only when its Utility there is 0; an item with all Utilities at 0 becomes salvage/incineration-only.

- The night report identifies the item and storage location so the consequence is attributable rather than invisible.

## 7. Physical Interaction and Storage

### 7.1 Valid item states

| Context | Representation and ownership |
| --- | --- |
| Receiving / pending batch | One committed entry per physical item. Undelivered content may exist as data; only the active revealed batch materializes pickup-enabled WorldItems. |
| Carried bundle | The same durable ItemInstance identity; any held visual is presentation, not a droppable world object. |
| Sorting table / storage | A legitimate bounded storage owner/surface/slot presents deterministic WorldItems. No generic loose-floor state exists. |
| Facility output | New physical output has a bounded owner/collection point; exact ration/salvage output blocking remains an implementation question. |
| Submitted / consumed / converted / destroyed | The submitted source ceases to be ordinary retrievable loot. Destination accounting replaces it; conversion may create separate output items. |

The player cannot drop items on floors, corridors, in front of hatches or onto arbitrary decorative furniture. Mess is created through legal storage choices. A facility input is a transaction boundary, not a reversible extra shelf. Current pre-seeded loose prototype props are test fixtures, not a third target gameplay ownership state.

### 7.2 Carrying model

The Quartermaster carries a bundle limited by total Bulk. The bundle is not presented as a backpack or inventory screen. A compact HUD strip shows carried items; one item is active for placement; mouse wheel or number keys may cycle the active item. Request zones automatically consume eligible carried items while the interaction control is held.

Basket, carrier, or cart upgrades increase carried Bulk and possibly queue readability. They do not need a physical cart model or pushing animation. The upgrade is a throughput improvement, not a vehicle simulation.

### 7.3 Storage model

| Storage type | Preferred implementation |
| --- | --- |
| Open shelves and tables | Constrained placement on a hidden 2D surface grid with authored Footprint, assisted alignment, automatic zone policy, and deterministic stored transforms. The surface uses 2D reservations while posed height remains available for stacking/clearance. |
| Sorting table | A bounded horizontal general-purpose storage surface/container for temporary staging and reorganization. Exact snap/compartment implementation remains Validate; fixed slots are not imposed by art direction. |
| Crates, boxes, drawers | Fixed or layered volumetric slots disguised as physical storage. |
| Bottle, tool, weapon racks | Dedicated snap points or compatible slot types. |
| Compatible stackable items | Deterministic single-column support stacks using authored support roles and optional strict automatic compatibility classes. Upper members do not create additional 2D occupancy; the base owns the reservation. |
| Receiving elevator | Frozen generated pile; items may be cherry-picked if visible. The player cannot add objects. |

### 7.4 Deterministic support stacking

CONFIRMED. Open-shelf stacking uses deterministic single-column support stacks rather than rigid-body piles or a 3D voxel grid. A stack consists of one base 2D reservation plus an ordered vertical list of individually physical WorldItems.

- Each item authors can_be_stacked and can_support_stack against its approved storage pose, plus at most one optional auto_stack_group. A group is a strict, player-predictable automatic compatibility class; physical manual compatibility may be broader.

- Every upper member must fit within the oriented Footprint of the item directly below it. Stack dimensions therefore do not widen upward unless automatic base promotion first installs a larger compatible new base.

- Automatic placement is stack-first within each valid zone tier. It may smart-insert a compatible item at the highest valid position and may automatically promote a larger compatible incoming item to the base if the expanded reservation remains valid. Existing members keep their relative order and packing yaw.

- Manual placement may create mixed stacks only on the current top and may ignore automatic compatibility groups. Manual under-base insertion is deferred pending broader playtesting.

- Any visible member may be retrieved. Removing a middle member recompresses members above it deterministically; removing the base promotes the next member and shrinks the reservation; no falling physics is required.

- Stack placement is limited to 95% of physical shelf clearance for gameplay headroom. Closed/intermediate levels derive clearance from authored adjacent shelf planes and furniture Y scale; top-level world-context caps are authored per instance. Ordinary empty/singleton placement instead checks its final seated posed top against physical clearance without the 95% multiplier. Both search/preview and commit enforce the appropriate fit invariant.

VALIDATE. Mixed/non-auto-coherent stacks currently reject later automatic smart insertion; manual under-base insertion remains deferred; multi-column packing of several items side-by-side on one support surface is a separate architecture and is not implied by this system.

Within each zone tier, test normal smart insertion first, automatic base promotion next, and empty placement last. Exhaust the matching specific category tier before General; never globally repack or rotate existing stack members.

Prototype evidence: the controlled registry currently contains boxed_food, flat_media, medical_boxes and round_cans; explicit None is a valid authoring decision. All four passed representative gameplay testing. Future classes require deliberate approval; this current registry is not a permanent four-class limit. [P04 §§13-14]

### 7.5 Furniture and containers

- Major shelving, cupboards, racks, machines and service interfaces occupy authored positions or predetermined sockets; there is no free furniture placement. Departmental service-space floor area does not automatically add Quartermaster storage capacity.

- Whether selected containers/units can move at all remains OPEN. Any retained movement is limited to explicitly compatible unit/socket pairs, not arbitrary positioning. The earlier empty-container requirement remains a safeguard for any movable type, not a promise to implement movement.

- During reorganization, contents may temporarily use other legal storage, the sorting table or the carried bundle. Irreversible facility inputs are not staging capacity.

- Day-one installed storage is moderate, with later capacity at authored main/satellite sockets. Some future sockets are empty; others contain designated environmental clutter removed only by the corresponding night-time upgrade.

- Future sockets are visually implicit. No glowing pads, painted upgrade footprints or mandatory in-world upgrade prompts are prescribed.

Supersession: v0.4's unconditional movable-container language is narrowed to a still-undecided feature. Starting inventory, progression tree, costs, timing and movement roster are not fixed by these spatial rules. [D14, V03 §15.1]

### 7.6 Labels and identification

Player-authored labels remain an intended identification aid, separate from mechanical Storage Zones. A label does not enforce that a container holds the category it names. The detailed authoring interaction, coverage, anchors, renderer and any icons remain OPEN rather than already implemented.

The locked visual direction is legible, restrained and generally diegetic: physical tags, cards, tape, small strips or placards may combine text, symbols and limited color. Do not recolor whole rooms or shelves, or prescribe the player's storage taxonomy through environmental decoration. [D14, V03 §8]

### 7.7 Storage zones, General, and disabled cells

CONFIRMED. Storage Zones are mechanical placement policy layered over hidden deterministic cells on a StorageSurface. They are distinct from player-authored text labels and shelf names, which remain identification aids without mechanical truth.

- The eight item Storage Categories are Food, Hydration, Medical, Weapons, Protection, Fuel, Morale, and Electronics. General is not an item category.

- Each storage cell is either one specific category, General, or blank/erased. General is a universal enabled zone that accepts any item category. Blank/erased means No Zone / disabled storage and accepts no item.

- On first entry into zoning for an untouched surface, the surface initializes to General 100%. If the player later erases cells, those cells remain disabled; they do not silently revert to General.

- Automatic placement searches the matching specific category and then General, and stops. It never uses a mismatched specific zone or disabled cell. Within a tier, a valid compatible stack is preferred before an empty placement.

- Manual placement may ignore specific-category mismatch because it is the Quartermaster's deliberate override, but it still cannot use disabled/erased cells.

- Changing a zone does not teleport, recategorize, or rearrange items already stored there. Zoning governs future placement policy.

- The zoning editor is a paused flat per-surface interface. This is an explicit exception to the normal no-pause interface rule because the editor is modal and cannot be exploited to advance or freeze world actions selectively.

### 7.8 Interaction quality requirements

- Placement must feel physical despite deterministic states and hidden bounds.

- The system should assist tidy alignment rather than make exact positioning laborious.

- Players must quickly read whether an object fits and roughly how much capacity it consumes.

- Mistakes should come from organization and decisions, not finicky collision or ambiguous targeting.

- The preferred elevator pile allows visual cherry-picking, but a more structured pile is acceptable if technical cost threatens reliability.

### 7.9 Architecture-led storage and readable furniture

Main galleries offer different geometries without pre-assigning Food, Medical or other category identities. A coherent backbone of recurring general-purpose furniture is supplemented by scavenged and limited specialist units. Specialist eligibility is a separately authored rule, not an assumption inferred from a mesh, finish or folder.

The accepted topology uses five galleries A-E. C and D retain the one intentional secondary connection; other galleries primarily address the Main Storage spine, with the agreed A/B shared-junction and B-east Kitchen openings. This is now the human-promoted working spatial baseline, not a guarantee of furnished shelf capacity or final balance. [A17, V05]

Use shallow wall-fitted shelving when rear access is unavailable. Deeper furniture belongs in wider pockets with real circulation around it; freestanding units are usually low-to-medium height. Columns, wall jogs and ceiling intrusions create credible constraints, but furniture dimensions are tuned to visibility, reach and stacking occlusion rather than forcing architecture to fit a standard shelf.

Ordinary ground-access storage must keep intended contents visible, targetable and retrievable from supported standing approaches without a ladder. Intentionally ladder-served installations may exceed that limit only after a bounded fixed-ladder proof. General climbing, jumping, movable or sliding ladders, fall systems, visible-hand animation and player-adjustable shelf levels are not approved. Crouch remains separate deferred work, not a repair for poorly composed shelving. Final furniture depth, openings, level count and usable-area insets are tested with actual catalogue items and installation geometry rather than treated as universal percentages.

## 8. Facilities and Material Flows

### 8.1 Facility overview

| Facility | Timing | Accepts / produces | Primary purpose |
| --- | --- | --- | --- |
| Service elevator | As expeditions return | Incoming frozen loot batches | Reveal, Receiving pressure, and queue throughput. |
| Expedition provisioning | 07:00-09:00 | Food, Hydration, Medical, Weapons, Protection | Trade outgoing preparation against return capacity and risk. |
| Kitchen meal hatch | 09:00, 14:00, 18:00 | Food, Hydration, and Rations | Fixed Meal Service anchors; treatment and Workshop support. |
| Kitchen ration input/output | Input during day; output overnight | Food -> standardized Rations | Controlled compaction and Food-per-Bulk improvement. |
| Medical Bay | One long daily treatment window; tranches if validated | Medical Utility | Treat Light and Severe injuries through a shared triage pool. |
| Bunker Ops | One timed request per day | Fuel, Morale, Electronics | Next-day machine/lighting, recruitment, and communications conditions. |
| Salvager | Anytime when enabled | Item -> physical Salvage | Convert low-ROI objects into compact upgrade material. |
| Incinerator | Anytime when enabled | Item -> nothing | Immediate irreversible space release. |
| Workshop | Player-initiated | Salvage and project materials | Construct upgrades for predetermined sockets. |

### 8.2 Submission principles

- Submission is irreversible by default. Items immediately leave the Quartermaster's domain.

- Active request hatches accept items only while their request is open.

- The player can carry several eligible items, interact with a destination, and feed them automatically without manually assigning each item to a meter.

- A destination never asks the player to choose between two valid meters for the same item.

- Targets stop accepting items at their cap unless a small overfill is explicitly designed, as with expedition provisioning. Meal Service and Bunker Ops do not become hidden storage.

### 8.3 Physical economy

Resources are represented as physical items wherever practical. Salvage exists as stackable objects. Rations emerge as objects. Upgrade materials must be stored until committed. Bunker Ops consumes physical items through a timed hatch rather than an abstract reserve. The game avoids top-corner currency counters when a physical representation can reinforce the organizing loop.

### 8.4 Unified request grammar

Every request uses the same collection model and outputs normalized coverage per lane. Collection rules and consequences are separate data so that a new request can reuse the same physical interaction without inventing another UI language.

| Request field | Definition |
| --- | --- |
| Destination | Physical hatch, terminal, or expedition team receiving the items. |
| Trigger | Fixed, scheduled, random, or player-initiated activation. |
| Deadline | Submission window; never extends beyond midnight. |
| Utility lanes | Accepted item categories and one target value per active lane. |
| Allocation | Automatic item-to-meter routing; no manual lane choice for one item. |
| Partial fulfillment | Always permitted unless a future feature explicitly states otherwise. |
| Overfill rule | None by default; small capped overfill only where it prevents exact-sum friction. |
| Resolution | Immediate, expedition return, or midnight Outcome Profile processing. |

A separate Outcome Profile translates each lane's 0-100 percent coverage into continuous effects, optional thresholds, optional 0 percent behavior, duration, and report text. A special 0 percent state is therefore not mandatory request grammar; it exists only where the lane needs one.

| Request | Utility lanes | Primary under-supply consequence |
| --- | --- | --- |
| Expedition | Food, Hydration, Medical, Protection, Weapons | Duration, safety, returned-Bulk utilization, recruitment, and aggregate Loot Quality. |
| Medical | Medical | Treatment delay, retained injury state, and escalating Severe-injury death risk. |
| Meal Service | Food, Hydration | Per-treatment failure chance and reduced Workshop progress. |
| Bunker Ops | Fuel, Morale, Electronics | Machine/lighting outages, recruitment reduction, and communications outages. |
| Workshop project | Salvage and project materials | No punitive failure; work waits or progresses more slowly. |

## 9. Scavenger Population and Expedition Lifecycle

### 9.1 Population model

CONFIRMED Scavengers are the only dynamically tracked population. All other bunker occupants are inferred through fixed background Meal Service demand, audio, requests, and facility operation.

The player sees aggregate counts on a bunker monitor rather than individual names or biographies. The recommended visible states are Total Alive, Ready, Away, Medical, and Awaiting Lift. Internally, temporary team records and anonymous patient cohorts are sufficient.

### 9.2 Team formation

- At 07:00, all Ready scavengers are automatically partitioned into teams of one to four.

- The system attempts to create as many teams as possible while respecting the maximum size of four.

- A team of one is valid and may gather loot, suffer losses, or encounter a recruit candidate.

- Teams are formed once per day. A scavenger can therefore participate in at most one expedition without individual attendance flags.

- Recovered scavengers and accepted recruits join team formation on the following morning.

### 9.3 Morning preparation

Each team receives an automatically selected destination and a pseudo-random loadout request. The player may switch between team panels, prioritize a high-value destination such as a pharmacy, fully dispatch a team early, or force-send a partially provisioned team.

At 09:00, every team not already sent departs automatically with whatever has been submitted, including nothing. This maintains schedule clarity and avoids a broad expedition-management interface.

### 9.4 Destination selection

CONFIRMED Destinations are automatic at launch. The player is informed of each destination before provisioning but cannot select or reroll it.

Destination tables influence item families, the base internal loot-quality band, event risks, and thematic audio. Manual destination choice remains a possible post-release expansion only if it does not displace the storeroom as the primary game.

### 9.5 Expedition timing

A return time is calculated from destination, team size, Food and Hydration provisioning, expedition outcome, and controlled randomness. The exact duration is not displayed. Random variation of roughly plus or minus 5-15 percent is a provisional target to prevent precise spreadsheet timing.

All expeditions are intended to return the same day. If a calculated return would occur after approximately 23:40, it is clamped to that time and an additional penalty is applied in proportion to the forced time reduction. The penalty may reduce returned Bulk or increase danger; exact allocation is provisional.

### 9.6 Injuries, deaths, and recovery

When an expedition resolves, each scavenger receives one categorical outcome roll: Dead, Severe injury, Light injury, or Uninjured. Death, Severe injury, and Light injury are not rolled independently and cannot overlap.

PROVISIONAL Two casualty models should be tested against the same long-run target. The choice and exact endpoints are tuning decisions, not prototype gates.

#### Model A - direct categorical roll

| Medical + Protection coverage | Death | Severe injury | Light injury |
| --- | --- | --- | --- |
| 100% | 0.5-1% | 4-7% | 12-18% |
| 0% | 3-4% | 15-20% | 35-45% |
| 1-99% | Linear interpolation | Linear interpolation | Linear interpolation |

Model B - incident-gated roll: the expedition first determines whether a dangerous incident occurred. If it did, each scavenger receives a categorical casualty roll. Destination can influence incident probability, while Medical and Protection influence the conditional result. Both models must be calibrated to comparable average casualties before subjective playtesting.

SAFETY COVERAGE = (capped Medical supplied + capped Protection supplied) / (Medical required + Protection required)

Each lane is capped at its own target before combination. Medical overfill cannot compensate for missing Protection, and Protection overfill cannot compensate for missing Medical. Detailed treatment states, triage, and complications are defined in Section 13.

Scavenger death remains restricted to expedition outcomes and Severe-injury complications in Medical. Other shortages may make those lanes less effective but do not create diffuse background mortality.

### 9.7 Recruitment

Some expedition outcomes may return a recruit candidate. The candidate appears on the scavenger monitor and may be accepted or declined before midnight. Acceptance is a logistics decision: another scavenger increases future expedition throughput, loadout consumption, risk exposure, possible Medical demand, and Receiving pressure.

- Accepted recruits join at 07:00 the following day.

- They do not retroactively change the current day's meal requirements.

- No response by midnight counts as a decline.

- Recruitment chance is modified only by the expedition's Weapons coverage, destination, and the next-day Morale effect produced by Bunker Ops.

### 9.8 Failure check

CONFIRMED Expedition outcomes and any recruit-candidate decision resolve before checking failure. If the final expedition kills the last scavenger but offers a recruit, that decision is presented immediately. The run ends at once only when no living scavenger remains and no accepted recruit is due to join.

This permits the intended recovery fantasy: one lone scavenger can find one survivor, two can become a team, and a nearly collapsed bunker can claw its way back. Conversely, the final failed expedition can end the run in the middle of a day.

## 10. Provisioning, Load Capacity, and Returned Loot

### 10.1 Team load model

TEAM LOAD CAPACITY = f(team size) OUTGOING BULK = sum(Bulk of submitted loadout items) RETURN CAPACITY = Team Load Capacity - Outgoing Bulk

Everything sent with a team is consumed by the expedition abstraction. Food is not treated as freeing capacity after consumption; weapons and crowbars are not automatically returned. The model favors clarity over literal simulation.

### 10.2 Provisioning meters

| Meter | Examples | Primary effect |
| --- | --- | --- |
| Food | Canned food, cereal, Rations | Shortens expedition duration. It does not modify base Team Load Capacity at launch. |
| Hydration | Water, soda, other liquids | Shortens expedition duration. It does not modify base Team Load Capacity at launch. |
| Medical | Bandages, medicine, disinfectant | With Protection, reduces injury and death risk. |
| Weapons | Guns, knives, crowbars, improvised objects | Improves Bulk utilization and recruitment chance. |
| Protection | Socks, gloves, coats, helmets, protective vests | With Medical, reduces injury and death risk. |

Targets are pseudo-randomized by expedition and destination. Every generated request should be theoretically fillable inside team capacity with a reasonable assortment. The player may submit nothing, partially fill meters, reach 100 percent, or slightly overfill.

### 10.3 Bulk targets for complete loadouts

PROVISIONAL A complete average-efficiency loadout should consume about 50 percent of team capacity. A highly efficient loadout should leave roughly 70-75 percent available. Even the worst theoretically complete assortment should leave approximately 10-15 percent available for return loot.

These targets prevent the player from accidentally spending every available unit of capacity merely by satisfying a valid request. Extremely inefficient combinations, such as many tennis rackets, remain costly but should not create a zero-loot outcome when they represent a complete generated request.

### 10.4 Overfill

Meters accept modest overfill so the player does not need to solve exact-sum puzzles. If a Weapons request needs 13 and the submitted bundle totals 15, both items are accepted and a small, quickly capped lane-specific bonus applies. Aggregate Loot Quality caps each lane at 100 percent, so overfill cannot conceal an unfilled need.

### 10.5 Expedition outcome axes

| Axis | Meaning |
| --- | --- |
| Safety | Injury and death probability and severity; driven by Medical and Protection. |
| Duration | Return time; driven by Food and Hydration, controlled randomness, and late clamping. |
| Bulk utilization | Share of remaining Return Capacity filled with loot; driven by Weapons. |
| Loot quality (internal Utility Density) | Internal normalized loot-quality target. All five meters contribute; full bonus requires every meter filled. |
| Recruitment opportunity | Recruit candidate chance; driven by Weapons, destination, and the separate next-day Morale modifier. |

### 10.6 Internal loot-quality target (Utility Density)

The same 20 Bulk of available return space might contain five tennis rackets or fifteen pistols. Provisioning quality determines which kind of return the bunker can expect.

All five provisioning meters together create an agnostic loot-quality bonus. The bonus biases the selected haul toward items with higher visible +X Utility for the Bulk they consume, and reaches its full value only when every required meter is filled. A well-prepared team is better able to reach valuable spaces, recognize useful supplies, abandon awkward low-value objects, and extract compact high-value items.

QUALITY COVERAGE = average(capped Food, Hydration, Medical, Protection, and Weapons coverage)

The arithmetic mean is the initial implementation. If testing shows that players can ignore one lane while still receiving unrealistically good hauls, a provisional alternative may weight both the average and the lowest lane. This remains an internal balance adjustment and is never exposed as a player-facing statistic.

Utility Density is the backend expression of that bonus, not a frontend concept. Players see the returned objects, their Utility, Bulk, and Footprint, and may infer the pattern over time. Bunker-source penalties and bonuses normally remain in their own lanes and do not alter Utility Density unless a feature is explicitly designed as a dedicated loot-quality modifier.

### 10.7 Provisional generation model

1. Select destination loot table. 2. Calculate Team Load Capacity minus outgoing Bulk. 3. Medical + Protection -> per-scavenger safety outcome. 4. Food + Hydration -> expedition duration. 5. Weapons -> returned-Bulk utilization and recruitment chance. 6. All five meters -> internal Loot Quality bias; full bonus requires every lane filled. 7. Apply only explicit lane modifiers, such as Morale to recruitment; do not alter Loot Quality indirectly. 8. Sample items to Bulk and quality targets; resolve timing, casualties, recruitment, and other events.

Exact weights, normalization, and sampling are tuning questions. The generator may accept small overshoot or undershoot rather than solving an exact packing problem. Equal returned Bulk may therefore hide sharply different future value, which is the intended player-facing consequence.

## 11. Receiving Elevator and Delivery Queue

### 11.1 Spatial boundary and incoming sequence

CONFIRMED Receiving Apron -> permanent barrier -> shutter -> shallow recessed freight deck. The player never enters the bay; the bay is TAKE-only and is not a StorageSurface.

The platform and bay walls are static. A signal, transit delay, cable/motor/impact cues, lock release and shutter animation imply movement. The active batch is reconstructed behind the closed shutter, with pickup disabled until OPEN. No visible rigid-body settling or pop-in is part of delivery.

| Presenter state | Role |
| --- | --- |
| SEALED_EMPTY | Shutter closed; no interactive pile. |
| ARRIVAL | Warning lights and arrival audio sequence. |
| SEALED_READY | Committed WorldItems available behind the closed shutter; pickup disabled. |
| REVEALING | Shutter opens; pickup still disabled. |
| OPEN | Ordinary WorldItem targeting and TAKE enabled for the active batch. |
| CLOSING | After final TAKE and short delay, pickup disabled and shutter closes. |

Only after full shutter closure does Receiving retire the drained active batch and promote the FIFO head. Each next batch receives its own arrival/reveal sequence. ReceivingManager owns occupancy and promotion; FreightBayPresenter owns cues, shutter state and materialization. Neither owns upstream loot policy. [R12 §§8-10, 17-18]

### 11.2 Committed content, identity and preparation

LootBatch owns content and accepted arrangement, not queue position. CONTENT_COMMITTED fixes batch ID, one entry per item, durable item IDs, definition IDs, Bulk totals and content/presentation seeds. An accepted arrangement atomically records presentation-local frozen transforms plus profile ID/revision and advances to PREPARED. Transient ARRANGING work is disposable.

Repeating content seed, pool revision/configuration and Bulk budget reproduces ordered definitions and content, not a globally reusable batch identity. A newly committed batch gets unique batch/item IDs; reconstructing an existing commitment preserves its IDs. Representation changes and retries never mint replacement identities.

ItemDefinition remains gameplay truth; the authoring manifest is evidence truth. The prototype generator uses an explicit 40-ID approved Receiving pool rather than runtime manifest inspection. Fuel (loot_000015) is reconciled and remains in that pool; Gloves and Pants remain excluded. Prototype Bulk sampling is a test producer, not final expedition reward balance. [R12 §§4-7; D12A, D13B]

### 11.3 Preferred hidden-settle route

CONFIRMED APPROACH / VALIDATE RESULT Use seeded initial scatter, temporary simplified rigid bodies in an isolated staging environment, stability detection, bounded retries, and a conservative deterministic fallback. This implementation direction is approved; physical pile quality and performance are not yet validated.

Preparation is separate from the live freight-bay scene so it may run while another batch is visible. Async means work may be spread across time/frames before delivery; multithreaded physics is not required. Accepted transforms, not the physics trajectory, are authority.

Freeze means replacing proxies with ordinary deterministic WorldItems. Destroy every temporary physics body; no sleeping/dormant body, velocity or live contact remains. Preserve accepted local position and orientation rather than snapping the pile into shelf poses. Taking an item leaves every other frozen pile member in place; there is no re-settle or pile compression. [R12 §§11-16]

### 11.4 Pile acceptance, targeting and fallback

- Validate containment, tolerable penetration/support, finite valid transforms and exactly one result per committed remaining entry.

- Allow disorder and temporary layered occlusion, but require every entry to become visible/targetable through successive normal TAKE operations from reachable apron-side viewpoints.

- Start with conservative iterative targeting simulation: find targetable entries, virtually remove them, repeat; reject if entries remain with no progress. Do not build a general accessibility solver without failure evidence.

- Use the existing WorldItem targeting grammar. A bay/profile-specific reach is permitted; it must not extend storage reach globally or allow interaction through closed/revealing shutters.

- Fallback preserves all content and identities and must meet the same containment/drainability guarantees. A failed fallback is a reported development error, not permission to omit or reroll items.

Record seeds, Bulk/item count, attempts, preparation duration, rejection reasons, fallback use, drain iterations and profile revision. Review aggregate fallback rate, mean attempts and p95 preparation time; no arbitrary acceptance-rate target is locked yet. Separate backend cost from player-visible delivery delay. [R12 §§14-20]

### 11.5 Deposited capacity and Awaiting Lift

| State | Capacity | Meaning |
| --- | --- | --- |
| Active bay slot | 1 batch | Deposited active batch, including its arrival/reveal/closing lifecycle; at most one pile is visible. |
| Deposited queue | 2 batches | FIFO batches waiting for the active slot. No extra playable conveyor simulation is required. |
| Prepared but undelivered | Outside the 3 slots | Backend commitments are not Receiving occupancy or player-accessible storage. |
| Awaiting Lift | Returned team state until midnight | Deposit is blocked while active + two queued slots are occupied. |

A valid PREPARED batch becomes active if that slot is empty, otherwise joins the queue if capacity exists. A fourth deposit fails without mutation. Empty fresh batches and already-drained deposits are rejected, avoiding unusable occupancy. The active slot is released after closing acknowledgement, not merely at the instant the last item leaves.

Retain the intended oldest-Awaiting-Lift admission and midnight forfeiture gameplay. A team still awaiting deposit at midnight loses its haul and returns through the existing population logic; its loadout/opportunity is spent. Its committed content may already exist backend-side: forfeiture makes it unavailable for later deposit rather than requiring that it was never generated.

Explicit supersession of v0.4 §11.3: the limit is three DEPOSITED batches, not three batch data objects in existence. The former “loot is abandoned and never generated” requirement is replaced by preserved forfeiture semantics compatible with early content/preparation. No extra hidden gameplay capacity is gained. [R12 §26; D12]

### 11.6 Recovery and transactional TAKE

Before arrangement commit, recovery preserves CONTENT_COMMITTED and discards incomplete settling. After commit, reconstruct exactly from saved local transforms and remaining-entry ownership. Profile mismatch fails closed pending an explicit migration or allowed unrevealed re-preparation; never reinterpret transforms against incompatible geometry or reroll a revealed pile.

TAKE transfers the exact existing ItemInstance into the carried bundle and releases its active batch entry as one ownership transaction. Failure leaves or restores prior ownership; duplicate/stale interaction cannot duplicate or lose an item. The last release notifies presentation to close. These are subsystem contracts, not evidence that full durable save/journal integration has shipped. [R12 §§6, 18, 20]

### 11.7 Future expedition precomputation

Once an expedition outcome is committed and no longer player-influenceable, final content and its presentation may be prepared at any convenient time before its return. This is an optional performance route, not a new gameplay rule or implemented expedition feature. Preparation must not consume deposit slots, reveal information early, change return timing or otherwise spill backend optimization into gameplay. [R12 §26]

### 11.8 Phased delivery boundary

Stage A proves data/identity/lifecycle contracts. Stage B validates one physically presented batch using manually/debug-triggered, reproducible deliveries. Stage C enables the full three-slot deposited flow and synthetic arrival-pressure tests. Neither Stage B nor C requires expedition simulation. The updated roadmap and actual milestone status appear in Section 20.

## 12. Kitchen, Meal Service, and Ration Production

### 12.1 Kitchen role

The Kitchen performs two separate functions: fixed daily Meal Service and controlled conversion of disparate Food into standardized Rations. Food and Hydration remain outside Bunker Ops because their dedicated Kitchen and expedition flows are more legible and spatially meaningful.

### 12.2 Fixed meal requests

CONFIRMED The Kitchen requests both Food and Hydration at 09:00, 14:00, and 18:00. These anchors occur regardless of the Quartermaster's current backlog.

Each meal has separate numeric Food and Hydration meters and accepts partial fulfillment. Demand equals a fixed background cost for untracked bunker occupants plus a variable cost for the scavengers currently in Medical. Ready and Away scavengers are not charged again through Meal Service because expedition loadouts already contain their Food and Hydration.

DAILY MEAL COVERAGE = average of capped Food and Hydration coverage across breakfast, lunch, and dinner

At midnight, each patient receiving an otherwise valid treatment attempt rolls against the day's Meal Coverage. The provisional initial curve is Treatment Failure Chance = 50% x (1 - Daily Meal Coverage). The 50 percent maximum is a tuning handle.

| Affected system | Meal Coverage consequence |
| --- | --- |
| Medical treatment | Each patient rolls separately. On failure, allocated Medical Utility is consumed, no treatment progress applies, and a Severe patient records an unsuccessful treatment day. |
| Workshop | Nightly construction progress is reduced according to Meal Coverage. The exact progress curve remains tunable. |
| Direct mortality | None. Meal shortages kill only indirectly by causing treatment failure in the established Medical lane. |

The night report must state when treatment failed because of Meal Coverage and how much Medical Utility was consumed. Expedition Food and Hydration remain separate provisioning requirements and are unaffected by the bunker's Meal Coverage.

### 12.3 Ration production

Ration production uses a separate Kitchen interaction point available throughout the day. The player chooses which Food to commit. Input is irreversible, processing capacity is capped per day, and capacity may be upgraded. This prevents the Kitchen from becoming an unlimited food compactor while giving the player direct control over conversion.

- Rations are produced during the night transition and appear as physical items the next morning.

- Rations can satisfy Kitchen meal requests and expedition Food meters.

- Rations are rejected as ration-production input, preventing recursive Utility multiplication.

- The conversion should improve Bulk and Footprint efficiency and provide a modest Food-Utility gain.

- If spoilage is later added, ration production may also standardize or extend shelf life.

PROVISIONAL Exact Food-to-Ration conversion, daily batch cap, upgrade curve, handling of partial batches, and output-slot blocking remain unresolved tuning and implementation questions.

### 12.4 Kitchen decision space

A Food item may be stored for future flexibility, submitted to the next meal, sent on an expedition, or committed to ration production. These lanes compete directly. The design should preserve ugly but useful food such as cat food or bulky cereal by ensuring every Food item has a valid downstream use.

### 12.5 Kitchen Service Room and community identity

The Kitchen/Mess remains an unseen social heart led by a competent former professional chef with mixed-experience helpers. Its player-accessible Kitchen Service Room supports catering logistics and supplies without exposing cooking stations or dining occupants. It is an elongated, recognizable destination rather than a hatch at the end of a corridor. Its approach connects from Gallery B's eastern opening under the round-one correction, while retaining separation from Medical and dirty machinery. [H16, D16S]

The inner facility wall lies beyond the usable service-room floor. Reserve readable spatial opportunities for meal supply and the separate ration input/output functions, without designing their mechanisms here. Department-owned non-loot equipment establishes later identity; exact assets, placement, delivery sequence and feedback are deferred. The service room adds no implicit edible reserve, free storage or new chore loop. [V04 §19; D16S]

## 13. Medical Bay

### 13.1 Purpose and daily treatment obligation

The Medical Bay treats anonymous scavenger patients produced by expedition outcomes. Its signal is fixed red. Treatment begins on the day after admission and uses one shared daily Medical Utility pool rather than item-by-item assignment to named patients.

CONFIRMED One logical Medical obligation is generated each treatment day. The preferred presentation is one long-duration consolidated request. If high totals repeatedly create retrieval-time failures rather than resource decisions, the same obligation may be split into sequential tranches.

Tranches, if used, feed the same treatment pool and triage order. They do not represent separate patient groups or permit different allocation rules.

### 13.2 Injury states and schedule

| State | Medical Utility per treatment day | Successful transition | Earliest Ready time after Day X return |
| --- | --- | --- | --- |
| Light injury | 2 | Light -> Ready | Treated during Day X+1; Ready at Day X+2, 07:00. |
| Severe injury | 2 on each of two days; 4 total | Severe -> Light -> Ready | Treated during Day X+1 and X+2; Ready at Day X+3, 07:00. |

A Severe injury is therefore two explicit treatment stages rather than one four-unit threshold. The first successful stage downgrades it to Light; the second clears it.

### 13.3 Triage and partial progress

- Allocated Medical Utility goes to the oldest Severe injuries first, then newer Severe injuries, then oldest Light injuries, then newer Light injuries.

- One Utility unit allocated toward a two-unit stage is retained as partial progress, but it does not downgrade or clear the injury.

- The player does not manually choose patients. The interface shows total demand, supplied Utility, triage order, and expected returns if treatment succeeds.

- A newly admitted patient cannot be treated on the return day; their first required treatment day is the following day.

### 13.4 Treatment success and complications

Once enough Medical Utility has been allocated to a treatment stage, that patient receives a separate Meal Coverage treatment-success roll at midnight. A failed roll consumes the allocated Medical Utility, applies no progress, and counts as an unsuccessful treatment day.

SEVERE NIGHT DEATH CHANCE = min(100%, 20% x consecutive unsuccessful required treatment days)

| Unsuccessful Severe treatment days | Night death chance |
| --- | --- |
| 0 | 0% |
| 1 | 20% |
| 2 | 40% |
| 3 | 60% |
| 4 / 5+ | 80% / 100% |

- The first death check occurs only after the patient's first required treatment day. A Severe scavenger admitted on Day X does not roll during the transition into Day X+1.

- Insufficient supplied Medical Utility, partial one-unit progress, and a Meal-related treatment failure all count as an unsuccessful required treatment day for a Severe patient.

- Light injuries do not gain a direct death chance from delayed treatment; they simply remain unavailable longer.

- Medical death and expedition death are the only launch sources of scavenger mortality.

### 13.5 Patient cohorts and feedback

The backend may track anonymous cohorts by injury state, age, partial progress, and unsuccessful-treatment count. The central monitor shows how many patients are Severe or Light and how many are expected to return on upcoming mornings if treated. The night report lists attempts, successes, Meal-related failures, state transitions, deaths, and revised Ready forecasts.

### 13.6 Medical Supply Anteroom and protected approach

Medical has a dedicated, player-accessible Supply Anteroom at the end of its calmer shared-circulation spur. This is a supply/equipment support room, not a treatment ward, reception desk or empty hospital set. Its compact, room-like footprint includes deliberate standing and turning space in front of an opaque inner facility boundary. Patients and staff remain unseen. [V04 §18; D16S]

The approach and anteroom remain protected from Quartermaster storage expansion, backlog and dirty spill. Department-owned support equipment can be added in a later pass without turning the room into treatment space. Final equipment roster and delivery mechanics are deferred. The existing Medical treatment and mortality equations are unchanged.

## 14. Bunker Ops

### 14.1 Purpose and request model

Bunker Ops replaces the previous passive reserve/top-up model. It creates one timed, multi-meter request per day using one, two, or all three lanes: Fuel, Morale, and Electronics. It follows the same physical submission grammar as every other request and does not exist as an abstract stockpile.

CONFIRMED Only the lanes included in that day's Bunker Ops request can create a next-day penalty. One request is active at most, partial fulfillment is accepted, and its timer is deliberately more lenient than Meal Service or an ordinary Medical request because up to three unrelated item categories may be required.

Submission is irreversible, the meters stop at their targets, and the hatch cannot be used as temporary storage. Exact activation time, duration, lane-count distribution, and targets are tuning variables.

### 14.2 Coverage and outcome scheduling

LANE COVERAGE = min(100%, Utility supplied / Utility required)

Coverage effects apply during the following day and are shown in the midnight report. Fuel and Electronics outage windows are pre-rolled during the transition, saved before presentation, and hidden from the player until they occur. The scheduler may limit excessive overlap if testing shows that combined penalties create unproductive spikes.

### 14.3 Confirmed lane effects

| Lane | 1-99% coverage | 0% coverage | Affected systems |
| --- | --- | --- | --- |
| Fuel | A linearly increasing number of Incinerator/Salvager outage windows. | Maximum configured outage windows. | During each window both machines are unavailable; normal room illumination and request-alert lights also fail. PA and central monitor remain operational. |
| Electronics | A linearly increasing number of communications/monitoring outage windows. | Maximum configured outage windows; no extra all-day state. | PA, central monitor, and bunker-distributed music stop. Request lights, hatches, machines, elevator, and contextual HUD remain functional. |
| Morale | Recruitment chance is reduced linearly. | Recruitment chance is zero for all expeditions that day. | No expedition efficiency, safety, duration, returned-Bulk, or Loot Quality penalty. |

### 14.4 Outage behavior

A provisional outage window lasts about 25-30 in-game minutes. Fuel outages create a practical pivot when the player arrives with unwanted items and discovers the machines offline. Electronics outages create eerie silence and loss of coordination rather than physical system failure.

- All request timers, expedition logic, hatches, item handling, and the service elevator continue during every outage.

- Contextual item and hatch panels remain available so an outage creates inefficiency and disorientation rather than complete paralysis.

- Request lights are part of the Fuel/lighting lane and remain illuminated during an Electronics outage.

- The digital wall clock's behavior during an Electronics outage remains a Validate item; either result must be legible and consistent.

### 14.5 Player feedback

The night report names the next-day consequence in plain language, such as Intermittent Machine and Lighting Outages, Maximum Communications Outages, or Recruitment Disabled. It does not reveal exact outage times.

### 14.6 Administrator and deeper-bunker handoff

The bunker leader is called the Administrator. Bunker Ops uses a modest, more open Transfer Landing near the terminus of the longer shared approach. It is a dedicated playable area for onward distribution to the wider settlement, not an empty office or another copy of the departmental service rooms. Reserve an inner handoff/interface boundary along one side; no leader model or office interior is built. [D16S]

The Deeper-Bunker Approach remains sparse shared circulation, wider initially and narrower after a restrained dog-leg. Its Transfer Landing has two distinct destinations: the Bunker Ops material handoff and a separate, personnel-door-sized opaque deeper-settlement closure set within surrounding wall. The route does not pass through an office or submission device. The Incinerator retains its own spur and intervening corridor buffer. [V04 §§20-21; H16; D16S]

## 15. Salvage, Incineration, Workshop, and Upgrades

### 15.1 The three-way disposal decision

| Action | Immediate result | Opportunity cost |
| --- | --- | --- |
| Keep | Preserves the item for future requests or conversion. | Consumes Footprint, carrying effort, and attention. |
| Salvage | Instantly converts the item into compact physical Salvage. | Destroys direct Utility and still consumes storage until spent. |
| Incinerate | Instantly removes the item with no output. | Permanently destroys all possible future value. |

The game never tells the player which action is correct. The answer depends on current storage saturation, known future needs, upgrade goals, Bunker Ops conditions, and risk tolerance.

### 15.2 Salvage

Salvaging is currently intended to be instantaneous. Standardized Salvage appears as physical, efficiently stackable items at a bounded output point. It is more compact than most source objects but not abstract and not free of spatial cost.

This delay-by-storage is essential. Eight Salvage held for three days while waiting to afford a ten-Salvage upgrade provides no immediate benefit and consumes capacity. The player has paid with both the destroyed items and the space-time used to retain the intermediate resource.

### 15.3 Incineration

Incineration is instantaneous, unlimited when operational, and produces nothing. It is the emergency release valve for a Quartermaster who values immediate capacity more than possible future return.

### 15.4 Fuel-related machine availability

The previous day's Bunker Ops Fuel coverage determines the number of pre-rolled machine-outage windows. During those windows the salvager and incinerator are unavailable and ordinary lighting and request-alert lights fail. At 0 percent the maximum configured number of windows occurs rather than a special all-day shutdown. This makes poor Fuel coverage particularly dangerous when Receiving is already saturated.

### 15.5 Workshop and upgrades

The Workshop is a separate, player-initiated facility with one active project at a time. The player selects an upgrade, irreversibly commits its Salvage and other materials, and funds a project requiring one or more productive nights.

Progress resolves at midnight and is modified by Meal Coverage. A completed upgrade appears the following morning at its predetermined socket. Exact work requirements remain tunable; there is no visible construction, free placement, or intermediate geometry.

### 15.6 Candidate upgrade families

| Family | Examples | Design effect |
| --- | --- | --- |
| Storage capacity | Shelving, cupboards, crate sockets, specialized racks | Adds physical storage up to the finite maximum. |
| Carrying throughput | Basket, carrier, cart abstraction | Raises carried Bulk without a physical vehicle. |
| Sorting throughput | Larger sorting table or more snap slots | Adds temporary sorting capacity. |
| Ration production | Additional daily batches or output handling | Raises daily Food-processing throughput. |
| Information tools | Labels, icon access, scanner or stock overview | Improves retrieval and planning; never moves items automatically. |

PROVISIONAL Upgrade order, costs, prerequisites, construction times, and which information tools belong in the initial release must be validated against solo-development scope.

### 15.7 Gradual introduction and socket-state changes

CONFIRMED / TUNING OPEN Incineration is not available from Day 1. Introduce it when storage pressure and opportunity costs become meaningful; approximately the first five days was an illustration, not a fixed unlock day. Salvager timing and whether it follows the same staged introduction remain OPEN.

Preferred presentation: a massive machine is already installed but broken/offline. A later authorized overnight repair changes its state and the Administrator explains the restored function. This avoids pretending that a multi-ton installation appeared casually. Prerequisites, costs, progression/talent structure and any dependency on Salvage are unresolved; do not create a circular requirement to use an unavailable machine.

Unavailable storage sockets may hold fixed placeholder clutter until the corresponding player-authorized upgrade installs capacity overnight. Only the designated environmental subtree changes, never unrequested player inventory. Exact installed-capacity balance and initial loot reserves remain open.

These repair/unlock states are distinct from temporary Bunker Ops outages after commissioning. Retain the lane effects in Section 14; early-game request scheduling and tutorial staging must be balanced separately. [D14-15, V03 §23]

### 15.8 Separate machinery destinations

Salvager occupies a short discoverable spur near Workshop. Incinerator occupies another terminal spur distributed along the Deeper-Bunker Approach before Bunker Ops, away from Kitchen/Medical and visibly distinct from Salvager. Both are front-operated, massive building-connected landmarks with minimal side/rear access and prominent services. Approximately 80% or more of local ceiling height is an art-direction target, not a numerical gameplay requirement.

Partial body/duct silhouettes, oblique spur openings, lighting or services should reveal each destination from normal circulation. Their separation makes recovery versus destruction intentional; detailed submission safety and output handling remain future interaction work. [V03 §§17.1, 21]

### 15.9 Workshop Service Room

The player-accessible Workshop Service Room supports equipment staging and project-material handoff; the staffed fabrication core remains unseen behind its opaque inner boundary. Preserve the separate Salvager connection and the accepted continuous southern perimeter. The abandoned continuation is removed and must not be reserved or restored here. Final equipment, intake and staff-door placement remain future work. [D16S, D16-R02, A17]

PART III | PRESENTATION AND PRODUCTION

## 16. Feedback, Interface, Lights, and Audio

### 16.1 The bunker as interface

The physical wing communicates operational state through fixed destination lights, distinct departmental service spaces, a central monitor, clock, PA and machine indicators. Use ordinary salvaged commercial/office hardware; mount Sorting displays above or beside the wall-backed table rather than occupying its legal storage surface. Green-phosphor/digital styling is a candidate, not a command-center mandate.

Signals should become learned reflexes. Red is confirmed for Medical. Every other destination receives a fixed color, distinct audio identity, and blink pattern so color is never the only identifier. The preferred central monitor is legible directly in the world; an interaction-based enlarged view is a fallback only if scale and rendering make direct reading unreliable.

### 16.2 HUD hierarchy

| Layer | Contents |
| --- | --- |
| Persistent HUD | Carried-items strip, used/remaining carried Bulk, active item, and only the minimal reticle required for targeting. |
| Contextual HUD | Item inspection panel, request progress panel, interaction prompt, and storage-fit/placement preview when aimed at a relevant object or hatch. |
| Diegetic interface | Central monitor, wall clock, fixed request lights, PA, local hatch indicators, and machine status lights. |

### 16.3 Core information surfaces

| Surface | Information |
| --- | --- |
| Carried-items strip | Current bundle, active item, and carrying Bulk. |
| Item inspection | Name, +X Utility, pips, Bulk, Footprint/compatibility, stack cues, Salvage Yield, and optional condition/contamination states. |
| Request panel | Appears when aiming at an active hatch from a useful distance; shows category icon and X/Y progress for each active lane. |
| Team provisioning | Destination, member count, five meters, outgoing Bulk, Team Load Capacity, and Return Capacity. |
| Central monitor | Scavenger states, active requests, expected returns, elevator queue, recruit decision, patients, and major current penalties. |
| Clock and signals | Current time, fixed anchors, active destinations, anticipation, and deadlines. |
| Night report | One-screen card grid with causal outcomes, next-day penalties, and optional card-level detail. |

### 16.4 Item inspection visual grammar

Inspection uses simple line-drawn dashboard icons, pips, color, and redundant text. A Can of Tuna may show a Food icon, six blocky pips, and +6 Food; the number remains authoritative when values are too large for individual pips.

| State pair | Preferred presentation |
| --- | --- |
| Safe / Hazardous | Green or red line icon plus explicit state word. |
| Resistant / Sensitive | Green or red line icon plus explicit state word. |
| Clean / Contaminated | Neutral/green versus orange line icon plus explicit state word. |

Utility and quantitative information may use a neutral blue family. Color always reinforces icon shape and text rather than replacing them, supporting color-vision accessibility and monochrome display options.

### 16.5 Request interaction

The preferred submission grammar is PUT: aim at the destination and hold E so eligible carried items feed their automatic lanes one by one; the player may stop at any time. LMB remains TAKE/select/retrieve. Storage controls are validated; detailed facility submission, meter feedback and wrong-item prevention still require their own implementation and human test gate.

### 16.6 Outage feedback

| Outage lane | Lost coordination channel | Still available |
| --- | --- | --- |
| Fuel | Normal room illumination, request-alert lights, and the currently affected Incinerator/Salvager. | PA, central monitor, contextual HUD, hatches, elevator, and all request logic. |
| Electronics | PA, central monitor, and bunker-distributed music. | Request lights, contextual HUD, clock pending validation, hatches, machines, elevator, and all request logic. |

Outages should make the player slower and more dependent on memory, not unable to act. Their distinct lost channels also make the cause legible without exposing the pre-rolled schedule.

### 16.7 Night report presentation

The report is a paused grid of bounded cards with strong icons such as a skull for deaths, a broken-bone symbol for Severe injuries, a meal icon for coverage, and machine/communications icons for Bunker Ops. The report prioritizes direct language such as 2 treatments failed: Meal Coverage over hidden modifiers. If a card needs more detail, selecting it opens a short sub-report rather than extending the main screen indefinitely.

### 16.8 Audio priorities

- Elevator motor, cable, impact, settling, lock, and door sounds create anticipation and reveal weight.

- PA, radio, and short recorded lines imply scavenger teams, Medical urgency, Bunker Ops problems, recruit candidates, weather, and surface danger.

- Distant generator, ventilation, restrained Workshop/Kitchen activity and other localized interior audio imply unseen occupation. The active logistics wing should not be routinely dominated by combat gunfire, impacts or perimeter-threat cues; exceptional narrative events require separate deliberate scope.

- Each request destination receives a unique sonic identity independent of color.

- Fuel and Electronics outages remove different coordination channels: lighting and machines versus PA and monitoring.

Audio deserves disproportionately high production priority because it supplies a large invisible world at far lower cost than characters and environments.

### 16.9 Visual direction

- The companion Visual Design & World-Building Direction v0.5 governs environment production and the current service-space/topology interpretation. Use low-complexity realism, readable silhouettes and layered materials rather than literal photorealistic concept-image detail.

- The shell is concrete/cement/masonry dominant, with localized old tile/paint and repairs. Metal principally belongs to equipment, shutters, barriers, pipes, gratings and other services.

- Warm-to-neutral practical lighting and mixed fixture generations dominate occupied space. Cooler service or Medical light is selective; ordinary shelf visibility remains reliable outside designed outage states.

- No player character model or animated hands are required initially. Environmental props remain fixed and distinct from gameplay loot.

- Use causal wear, localized moisture, sparse legacy signage, quiet surfaces and restrained dry humor. Serious abandonment is confined to peripheral dead spaces; occupied areas remain dependable.

Structural Shell and Applied Finish remain separate human production-art gates before services, furniture or atmosphere carry a finished composition. Neutral spatial proxies and a later bounded functional Receiving test are not production-art promotion and need not await finished materials. [D16P]

## 17. Narrative Direction

### 17.1 Narrative method

Sorting Apocalypse relies on inference. The player constructs an image of the world from material evidence and indirect communication. Narrative is delivered in fragments that remain subordinate to the logistics loop.

| Channel | Use |
| --- | --- |
| Loot composition | Shows where a team went, whether the run was successful, and what kind of world exists outside. |
| Missing or transformed resources | Shows that supplied items were consumed, patients required treatment, or support systems failed. |
| Short PA/radio messages | Announce events, imply personality, create urgency, contextualize unusual hauls, and optionally react to memorable player submissions. |
| Optional 2D portraits / face cards | Lightweight identity for one-way announcements or decisions; no physical NPC, visible silhouette or facility interior is implied. |
| Objects with traces | Photos, keys, damaged clothing, notes, containers, and personal items imply stories without quests. |
| Population counters | Turn death, injury, recovery, and recruitment into concrete changes in bunker capability. |

### 17.2 Tone

The tone can hold tension, dry workplace absurdity, and occasional inferred tragedy at the same time. Ten tennis rackets sent as weapons are funny. A green monitor falling from 15 scavengers to 14 is consequential. A bloodied item in a thin haul can be unsettling without a rendered death scene.

The game should resist explaining every object or event. Ambiguity is part of the fantasy: the Quartermaster knows what arrived and what the bunker needs, but not the complete truth of the surface.

The Administrator is pragmatic and familiar with the Quartermaster, not a newcomer's mission-giver. The chef and Workshop staff can show personality through short operational remarks, with jokes aimed at circumstances and accumulated habits rather than professional incompetence. The broader apocalypse is inferred; the sorting workplace remains a haven.

### 17.3 Anonymous scavengers

CONFIRMED Scavengers launch as anonymous productive capacity rather than authored individuals. Names, traits, and personalities are deferred unless playtesting shows that attachment adds more than it costs in content, UI, and systemic complexity.

### 17.4 Contextual PA reactions (optional full-release feature)

DEFERRED A data-driven reaction system is desirable for the full release or later updates if writing, voice, localization, and repetition-control costs remain proportionate.

The system may recognize conspicuous submissions: many sports items used as Weapons, one food family dominating several meals, luxury items used under desperate conditions, contaminated supplies, severe under-provisioning, or repeated behavior across days. A short PA response makes the bunker feel observant and encourages playful experimentation beyond pure efficiency.

- Evaluate exact-item combinations, item-family counts, share of a request's Utility, repeated historical patterns, and unusually poor Utility-to-Bulk submissions.

- Trigger at most one reaction per completed request, prefer the most specific rule, use probability and cooldowns, and prevent immediate repetition.

- Keep reactions flavor-only at launch: no Morale gain, request bonus, or hidden efficiency reward.

- Use original lines, subtitles, and data-driven tags. Nonessential reactions simply do not play during an Electronics outage and are not queued for a later burst.

Illustrative original reactions include: Six rackets? Are we clearing a sports centre? and Lamb again? The Kitchen has apparently declared a theme week.

### 17.5 One-way operational messages and static evidence

Short messages from the Administrator or other unseen residents may explain tutorials, upgrades, repairs, requisitions and FYIs, including during/immediately after the nightly transition. A face card is optional. No branching dialogue, Quartermaster replies or character model is required. Exact delivery UI, timing and replay policy remain OPEN.

Flavor may refer to a fixed machinery husk, old backlog or absurd scavenged sign without moving it in the player's absence. Routine decorative clutter stays authored; only explicit progression or legal item interactions change physical state. Functional confirmations are distinct from the optional contextual-reaction system above. [D14-15, V03 §§8-9, 23]

## 18. Technical and Content Strategy

### 18.1 Intended technical shape

The current project is a Godot prototype with local CLI-based implementation and testing. Godot 4.7 is the reported development baseline for this evidence window; each task verifies the installed executable and branch state. Future architect and Codex sessions begin with docs/AI_WORKING_GUIDELINES.md, docs/CURRENT_STATE.md and docs/CODEX_BOOTSTRAP.md, then consult the current master documents and only the records relevant to the active gate. Architecture remains data-driven, deterministic and explicit about irreversible ownership rather than relying on an assumed engine path.

### 18.2 Minimal simulation architecture

- First-person movement and room collision only; no character animation dependency.

- Items use simple hidden bounds and explicit states rather than continuous rigid-body simulation.

- Stored objects are frozen and owned by a storage system.

- Furniture is authored/static or socketed. A future movement feature, if retained, is restricted to approved unit/socket relationships and empty eligible containers; movement is not otherwise promised.

- Receiving content and arrangement are committed separately; temporary isolated preparation proxies are destroyed before frozen WorldItems are presented. No live or dormant rigid-body loot survives in the playable bay.

- NPCs, expeditions, treatment, construction, Bunker Ops, and outside events are outcome calculations.

- Night transition is a deliberate synchronization point for changes that would be costly or visually awkward to animate.

### 18.3 Data-driven item resources

ItemDefinition (gameplay type) stable definition ID / display name / visual resource destination Utility / Bulk / primary Storage Category Footprint / approved Storage Pose / Stack Role / Auto Group Salvage Yield / separately scoped optional instance-state support ItemInstance (physical identity) durable instance ID / definition reference / applicable instance state WorldItem (representation) existing ItemInstance / bounded owner / context / deterministic transform LootBatch (upstream commitment) unique batch ID / ordered entries / seeds / Bulk totals CONTENT_COMMITTED or PREPARED / profile ID and revision committed local transforms / remaining-entry ownership

Large catalogues should be authored and validated as data rather than bespoke code. Tooling should flag missing destinations, ambiguous same-destination utilities, unreasonable Bulk/Footprint ratios, unreachable request categories, and outlier internal Utility Density.

Item authoring follows an explicit dependency chain: canonical Scale -> approved Storage Pose -> approved Footprint -> approved Stack Role -> approved Auto Group. Tooling may seed conservative provisional candidates, but human review remains the authority for support roles and every new automatic compatibility class. A controlled registry prevents free-form group drift; normal audits are read-only and flag stale or invalid authoring rather than silently rewriting gameplay data.

Maintain the explicit separation: ItemDefinition is gameplay truth; the review manifest is authoring/evidence truth. Source fingerprints and approved dependency chains are audited through explicit tools, never read by the runtime loot generator to decide eligibility. For the prototype, an authored 40-ID pool resolves through ItemCatalog; future stable loot tables can replace it without changing Receiving.

Generating a second batch with the same seed reproduces its ordered content, not its unique identities. An instance identity survives representation changes and reconstruction until the item is consumed/converted/destroyed; a static mesh name or newly instantiated host node does not define identity. [R12 §§4-7]

### 18.4 Request definitions and Outcome Profiles

RequestDefinition destination / trigger / deadline / utility lanes / targets / overfill / resolution OutcomeProfile lane coverage curve / optional thresholds / 0% behavior / affected systems / duration / report text

This separation lets the same physical hatch interaction support expeditions, Medical, Meal Service, and Bunker Ops while keeping their consequences legible and independently tunable. Outage schedules and treatment outcomes are generated from saved seeds or committed results.

### 18.5 Save-integrity architecture

| Mechanism | Purpose |
| --- | --- |
| Rotating full snapshots | Recover from partial writes or corruption using current and previous known-good states. |
| Append-only transaction journal | Preserve irreversible actions between snapshots without forcing a full synchronous save after every item. |
| Deterministic committed outcomes | Prevent rerolling expedition loot, casualties, recruitment, treatment, contamination, or outage windows after a crash. |

Snapshots should occur at day transition, save-and-exit, major safe checkpoints, and approximately every 60-120 real seconds if performance permits. Journal records must be small, checksum-validatable, and replayable. Crash-injection testing should target request submission, expedition arrival, midnight resolution, salvage creation, and snapshot replacement.

### 18.6 Asset grammar

Content breadth should come from reusable forms, data and material variants rather than unique high-detail modeling for every item. Preserve strong silhouettes and actual gameplay readability. A large environment library is not evidence of a coherent architectural/material palette.

- Use sourced distinctive geometry for shutters, barriers, detailed machinery, furniture, cables, pipes and irregular debris where it fits the visual direction.

- Simple structural walls, slabs, ceilings, beams, pillars, trims and openings may use selected coherent meshes, Godot primitives for validation, or a repeatable Blender-generated modular kit.

- Ready PBR maps provide a potential common material layer for generated geometry. The inspected KitBash sample includes Base Color, Roughness, Metallic and Normal PNGs plus Height EXRs, USD material definitions and Substance sources/dependencies. Those files make the route plausible; a finished Blender -> GLB -> Godot structural-material workflow has not yet been validated.

- Check map conventions, texture scale, UV repetition and final Godot appearance in a focused pipeline proof. Optional height/displacement and arbitrary Blender/Substance shader graphs are not assumed to transfer automatically. Substance processing is not required for the proposed ready-map route.

- The collection of prefab architecture may be insufficient for the diversity of coherent concrete/paint/tile/repair finishes required by the visual direction. Inspect it against the Foundation Gate; do not force mismatched modules, buy more content blindly, or commit to a generation pipeline before the small proof.

### 18.7 Foundation Gate and evidence-driven production

The early ugly-room gate has established the representative no-drop storage/content premise. The September Receiving shell showed why technical fit is insufficient for environment approval. Each major space now passes two independent human reviews before later visual layers: [D13B, V03 §10]

| Gate | Required result | Must not substitute for it |
| --- | --- | --- |
| Layer 1: Structural Shell | Plausible concrete/masonry civil architecture, proportions, wall/opening logic, circulation, recesses and sightlines. Furniture envelopes may inform ergonomics without forcing the shell around one imported prop. | An attractive door, machine, pipe cluster or dense dressing. |
| Layer 2: Applied Finish | Coherent material families, scale/repetition, appropriate roughness, localized paint/tile/repair and maintained wear under reasonably neutral review light. | Warm lighting used to hide gloss, pristine surfaces or mismatched textures. |
| Later layers | After both approvals: infrastructure and functional lighting; occupation/furniture; restrained detail/signage. | Automatic continuation past a failed human visual gate. |

Creative reuse may include rotation, sensible scaling, cross-category use and hidden embedding. Visible joins must remain plausible; hiding a beam end in opaque concrete is different from visibly intersecting finished steel members. Do not treat filenames, folders or convenient dimensions as art direction.

The first Stage-B Receiving shell remains visually rejected and preserved separately; it predates the mature visual brief. The full-wing greybox has since converged through three correction rounds and a Medical-only tuning pass, followed by explicit human acceptance. Preserve the approved spatial arrangement and the original test-room fixture. This promotion does not approve production Structural Shell/Applied Finish, furnishings or physical Receiving. [W17, H17, A17]

### 18.8 Asset provenance and local-authority boundary

Environment/non-loot sources live in semantic assets/environment families for architecture, infrastructure, furniture and dressing. Vendor provenance is kept in separate records rather than gameplay-facing taxonomy. Source assets describe what an object is; authored scenes describe its local behavior. A light fixture may anchor a light and rubble may block movement without changing source classification.

The authoritative local Windows checkout contains intentionally ignored assets/ and .godot import state. Git commits preserve tooling/scenes/data, not the physical asset library. A separate checkout or remote merge alone cannot reproduce asset relocation. Local Codex handles asset-aware inspection, imports, tests and commits; online ChatGPT provides architecture and review.

KitBash support supplied written project-continuation clarification: work and release may continue after subscription expiry for projects/assets incorporated while subscribed; the files are not licensed for new projects afterward under that response. Preserve the exact correspondence, incorporation/acquisition dates and relevant license records. This supersedes the former pending-clarification block; it is a record of the supplied answer, not a broader legal assurance. No new subscription or PBR purchase is required by this design. [K13; P05 §2.3]

PART IV | SCOPE AND VALIDATION

## 19. Balance Philosophy and Systemic Difficulty

### 19.1 Four interlocked resources

| Resource | Why it matters |
| --- | --- |
| Stuff | Physical items are future options, supply inputs, salvage sources, and clutter. |
| Space | Finite storage makes retention selective and turns low-density utility into pressure. |
| Time | Fixed meals, random requests, expedition returns, deadlines, and travel between facilities reward organization. |
| Scavengers | Fragile productive capacity converts outgoing supplies into future loot while increasing consumption and risk. |

No resource can be optimized independently. More scavengers increase loot potential, loadout consumption, and possible treatment pressure. More loot increases resilience and storage saturation. Salvage creates expansion capacity while consuming time and space. Reorganization saves future time but costs time now.

### 19.2 Systemic difficulty

CONFIRMED The initial design has no mandatory day-count escalation. Difficulty emerges from the bunker's actual condition and the player's decisions.

A technically sustainable equilibrium may exist, but the player must continue handling random composition, finite final storage, recruit decisions, treatment backlog, Bunker Ops requests, timed obligations, and occasional bad outcomes. What is worth keeping changes across the run.

### 19.3 Failure spirals and recovery

Under-supplied expeditions may return later, fill less available Bulk, deliver lower-quality objects, suffer injuries, fail to recruit, or lose scavengers according to the affected provisioning lanes. Injuries increase Medical and Meal Service pressure; failed treatment keeps scavengers unavailable or can kill Severe patients. The loop can spiral downward, but early stages must remain recoverable and legible.

- Poor outcomes should first reduce Loot Quality, returned-Bulk utilization, availability, or treatment success before making death routine.

- The player should have time to recognize trouble and consume hoarded reserves intentionally.

- Recruitment offers a comeback mechanism with a new ongoing consumption cost.

- A lone scavenger remains viable, preserving the possibility of improbable recovery.

- The game should avoid hidden mathematically doomed states that continue for a long period without actionable feedback.

### 19.4 Balancing priorities

| Priority | Balancing question |
| --- | --- |
| Loot quality (internal Utility Density) | Does better all-round provisioning produce visibly better future options per returned Bulk without exposing a synthetic quality statistic? |
| Storage density | Do Footprints make low-ROI items painful without making storage unreadable? |
| Request cadence | Do fixed meals create routine while stochastic events create disruption rather than noise? |
| Carrying friction | Does Bulk capacity reward layout and upgrades without turning movement into repetitive chores? |
| Queue pressure | Does a three-batch limit punish neglect without creating unavoidable losses? |
| Population thresholds | Do team sizes of one to four create meaningful ebb and flow without excessive volatility? |
| Bunker Ops penalties | Are Fuel, Morale, and Electronics consequences clear, proportional, lane-specific, and recoverable? |
| Late-game selectivity | Does final storage saturation force evolving standards of value rather than simple exhaustion? |
| Medical cascade | Do injury frequency, treatment demand, Meal failure, and Severe complications create pressure without overwhelming inbound loot capacity? |

### 19.5 Major tuning knobs

- Real minutes per day and in-game minutes per request timer.

- Team Load Capacity curve for one to four scavengers.

- Generated meter targets and allowed overfill cap.

- Lane-specific provisioning effects on safety, duration, Bulk utilization, recruitment, and the aggregate internal Loot Quality bonus. Base Team Load Capacity does not change with Food or Hydration at launch.

- Destination loot-table composition and category normalization.

- Patient-based Kitchen demand, the provisional 50 percent maximum treatment-failure multiplier, Workshop progress, and ration conversion throughput.

- Bunker Ops activation time, request duration, lane count, targets, outage-window counts, and overlap rules.

- Direct versus incident-gated casualty model, casualty endpoints, Medical request tranche threshold, treatment failure, and Severe complication curve.

- Recruitment frequency and the independent Weapons, destination, and Morale modifiers.

- Storage upgrade costs, installation timing, and final maximum capacity.

- Initial installed storage, starting loot buffer, Incinerator unlock timing, possible Salvager introduction and progression prerequisites; none is fixed by illustrative early-day examples.

- Gallery proportions, local shelf depth/height, reachable bay depth, request travel times and the longer Bunker Ops approach; preserve comfort and avoid route changes becoming repetitive chores.

## 20. Prototype, MVP, and Full-Game Targets

### 20.1 Interaction/content prototype: completed scope

VALIDATED IN REPRESENTATIVE SCOPE Pickup/carry/store/retrieve, zoning, deterministic support stacking, approved pose/Footprint/Stack Role/Auto Group metadata and singleton physical clearance passed the representative storage/content gate. Formal catalogue stress testing is complete, not ongoing.

The gate comprised 14 mechanical passes and 14 expected-predictability judgments across all four approved Auto Groups. It used 40 eligible definitions within the 42-definition catalogue; Gloves/Pants were intentionally blocked. loot_000010 pickup and singleton shelf-clearance defects were separately fixed and human-validated. [P04 §§13-14]

The representative storage/content gate does not establish a functional Receiving source or broader Systems MVP. The accepted wing now supplies the continuing gameplay composition, functional storage surfaces, saved editor-authored palette and default project entry. The current evidence sequence is review-scene supply reuse, reusable functional modular-rack authoring, one fixed-ladder proof, the human ladder decision, then Receiving. Full requests, saves/journals and economy remain later work. [A17, D17B]

### 20.2 Systems MVP

- Full 07:00-00:00 day cycle, card-based summary, pause rules, consequence-preserving save slot, transaction-safe irreversible actions, and immediate failure check.

- Anonymous scavenger population, automatic teams of one to four, 07:00-09:00 provisioning, same-day returns, per-scavenger categorical casualty model, Light/Severe treatment, death, and recruitment.

- Five expedition meters, fixed base Team Load Capacity, outgoing Bulk, Return Capacity, destination tables, and internal Utility-Density-biased haul generation.

- One visible elevator batch, two queued batches, Awaiting Lift state, and midnight loot forfeit.

- Three fixed Food/Hydration Meal Service requests, one daily Medical treatment obligation, basic Bunker Ops, and physical storage depletion.

- Salvager, incinerator, physical Salvage, one or two storage upgrades, and static sockets.

- Enough item families to test genuine low-ROI decisions rather than only obvious categories.

The Systems MVP should answer whether sorting and survival form one loop, whether partial provisioning creates understandable consequences, and whether the game can generate both calm organization and self-authored chaos.

### 20.3 Full-game target

- Kitchen ration production with daily capacity and overnight output.

- Full Bunker Ops implementation for Fuel, Morale, and Electronics, including pre-rolled lane-specific outage windows and next-day report warnings.

- Broader storage expansion tree up to a finite maximum capacity.

- Dynamic text labels and, if inexpensive, preset hand-drawn icons.

- Multiple storage areas and facility geography that supports player-designed logistics routes.

- Expanded destination tables, item catalogue, audio worldbuilding, and material storytelling.

- Robust multiple run slots, corruption recovery, transaction journal, deterministic outcome commitment, statistics, accessibility settings, and late-run performance optimization.

- Expanded one-screen night report, diegetic monitor coordination, contextual item/request panels, and distinct Fuel/Electronics outage readability.

### 20.4 Optional full-release or later candidates

| Feature | Current disposition |
| --- | --- |
| Contamination | Possible 1.0 or later feature; excluded from prototype and Systems MVP until storage readability and night feedback are proven. |
| Contextual PA reactions | Desirable for full release or later updates if writing, voice, localization, and cooldown management remain proportionate. |
| Condition / remaining quantity | Preferred if implementation is inexpensive and item inspection remains fast; otherwise omit from the first release. |
| Ambient bunker dog | Tentative / validate. One guaranteed, non-mechanical dog may arrive on a fixed Day 2 or Day 3 via the normal elevator and remain as the only visible living companion. No needs, injury/death/loss, survival bonuses, commands, or required petting; lightweight authored navigation only. |

### 20.5 Explicitly deferred or post-release

| Feature | Reason |
| --- | --- |
| Food spoilage and full shelf-life simulation | High state and communication cost; ration system remains useful without it. |
| Named scavengers, traits, relationships, and biographies | Would expand content, UI, and outcome simulation substantially. |
| Manual expedition destination selection | Risks shifting attention from the storeroom to a broad economic layer. |
| Overnight expeditions | Complicates midnight state, Away counts, deliveries, and scheduling. |
| Free-form furniture placement and base building | Introduces collision, navigation, layout, and save complexity. |
| Exterior exploration, combat, and visible zombies | Outside the product fantasy and solo-production boundary. |
| Intrinsically escalating day-count difficulty | Held as a playtest fallback if systemic pressure is insufficient. |

### 20.6 Approved execution roadmap and gated transition

Promoted storage/content + promoted whole-wing spatial baseline + completed repository/documentation close-out, seeded wing integration, default-entry promotion and Fuel reconciliation -> review-scene supply reuse -> reusable functional modular-rack authoring -> fixed-ladder proof -> human ladder decision -> functional Receiving -> first real timed request/system slice -> expedition-produced batches -> broader Systems MVP.

Greybox geometry, the continuing wing, default project entry, editor-authored eligible palette and Fuel maintenance are accepted. Repository and documentation close-out is complete and synchronized. Preserve history and ignored asset/import state; later bounded gates must not delete local evidence or silently waive known diagnostics. [A17, D17B]

| Stage | Scope | Reported state at this revision |
| --- | --- | --- |
| A: data/lifecycle | Durable identities, immutable committed content, prepared transforms/snapshots, 40-ID pool, seeded Bulk source, profile/job/diagnostics contracts, one-active/two-queued manager. | Implemented, reviewed, merged and technically verified. No physical-pile or full-save claim. |
| B: one physical batch | Representative bay geometry, barrier/shutter boundary, isolated settle/validation/fallback, WorldItem materialization, contextual TAKE, reproducible deliveries and human pile tests. Production-art gates remain separate. | Physical piles remain unvalidated. Whole-wing spatial geometry, continuing gameplay integration and default entry are PROMOTED after human review. Review-scene supply reuse, reusable rack authoring and the bounded fixed-ladder decision precede physical Receiving. Art approval remains separate. [A17, D17B] |
| C: deposited pressure | Enable three deposited slots, FIFO advancement after closure, rejected fourth deposit and repeated synthetic delivery/throughput tests. | Not started. Requires Stage B human promotion. |

Seeded storage integration, the continuing gameplay composition and the default-launch switch are complete. The next bounded gate is review-scene supply reuse, followed by reusable functional modular-rack authoring, the fixed-ladder proof, the human ladder decision and then Receiving. Preserve the old main test scene as an explicit legacy mechanics fixture and keep the neutral and shelf-ergonomics review scenes available. [D17B]

Systems-MVP scope in §20.2 is retained as the eventual integrated target, not authorization to switch all mechanics on from Day 1 or to bypass the phased roadmap.

### 20.7 Seeded storage gameplay integration completed bridge

The completed bridge provides a playable continuing wing with existing storage-capable shelves and a bounded editor-authored assortment of real catalogue items. It preserves the accepted geometry and keeps the functional setup within valid Storage and Sorting space rather than redesigning rooms or populating departmental service spaces.

The continuing scene reuses ItemDefinition, ItemInstance, WorldItem, per-level StorageSurface profiles, carrying, held/HUD presentation, zoning, placement and support stacking. Shelf meshes alone remain insufficient. The editor-authored palette supplies varied eligible shapes and categories without defining production starting stock; the fixed twelve-host fixture remains separate regression evidence.

main.tscn and its tunnel/test-room contents retain their original mechanics-fixture purpose. res://gameplay/logistics_wing/wing_gameplay.tscn is the accepted continuing composition built from the promoted geometry. The neutral wing review and shelf-ergonomics review scenes remain separately runnable, and functional authoring remains outside generated geometry subtrees.

The developer accepted the continuing wing's broad handling and editor-authorship review, including the saved item arrangement, carrying and storage behavior, and the three focused F6 checks. That acceptance establishes the completed integration bridge; it does not validate requests, live Receiving piles or full-game saves.

The continuing wing is now the normal project launch through UID uid://bljf1nlhijej. The old main remains independently runnable and is not deleted, stripped or merged into the new environment. F6 developer grids remain available and default off in the continuing scene; F7 is suppressed there.

## 21. Validation Plan, Risks, and Open Questions

### 21.1 Highest-risk assumptions

| Risk | Required evidence |
| --- | --- |
| Constrained placement feels tactile | Representative storage/content gate passed. Retain regression coverage as new content and furniture enter; do not reopen by default. |
| Bulk queue does not feel like hidden inventory | Multi-item carrying remains legible, fast, and spatially grounded. |
| Automatic submission is trustworthy | Players understand where items went and rarely feel that the wrong item was consumed. |
| Loot Quality is legible without a frontend statistic | Balanced loadouts visibly yield more useful future options per returned Bulk. |
| Three meal anchors remain welcome | They create planning rhythm without becoming repetitive busywork. |
| Medical cascade remains recoverable | Injuries, treatment demand, Meal failure, and Severe complications create tension without routine hard collapse. |
| Bunker Ops outages are disruptive, not disabling | Different lost channels create adaptation and memory play without accessibility failure. |
| Frozen piles remain readable and performant | Hybrid isolated settling and deterministic fallback must prove full progressive drainability from the apron, stable reconstruction, readability and tolerable cost; Stage A data tests are not this evidence. |
| Night report explains causality | Players understand why treatment, recruitment, machines, or communications changed. |
| Ironman saves remain resilient | Crash tests do not corrupt slots, duplicate irreversible items, or reroll committed outcomes. |
| Architectural/material coherence | Independent human Structural Shell and Applied Finish approval. A technically passing Godot scene can still be visually NO-GO. |
| Introduction and layout burden | Machine unlock timing, initial stock, comfortable routes, incidental vs required Sorting use, shelf visibility and machinery discoverability require playtests. |

### 21.2 Provisional design and tuning items

| Question | Current direction |
| --- | --- |
| Casualty model | Test direct per-scavenger categorical rolls against incident-gated rolls at comparable long-run casualty rates. |
| Casualty endpoints | Start with substantially reduced direct probabilities; tune through simulation and playtesting. |
| Medical request size | One consolidated daily obligation by default; split into sequential tranches only above a tested usability threshold. |
| Ration conversion | Separate daily-capped input, overnight physical output, no recursive Rations; exact batches and output blocking remain open. |
| Condition at launch | Preferred if implementation and inspection cost are low; otherwise omit. |
| Multi-purpose item authoring | Destination-specific profiles with one eligible lane per destination; fallback is globally single-purpose. |
| Signal colors and patterns | Medical is red; other fixed colors, blink patterns, and accessibility redundancies require testing. |
| Meal Coverage tuning | Six-meter arithmetic average is confirmed; the 50 percent maximum treatment-failure multiplier and Workshop curve remain tunable. |
| Bunker Ops cadence | One request per day; activation, duration, one-to-three-lane distribution, targets, and outage frequency remain tunable. |
| Outage overlap | Pre-roll at night and allow the scheduler to constrain excessive stacking if testing requires. |
| Digital clock during Electronics outage | Validate whether it fails with monitoring or remains on emergency power. |
| Generated pile implementation | Approved direction: isolated hybrid hidden settling, conservative drainability validation, bounded retries, deterministic fallback, replacement with WorldItems. Actual quality/performance still Validate. |
| Late-game instability | No intrinsic escalation initially; add restrained pressure only if permanent equilibrium is too easy. |
| Workshop projects | One active project and night-only progress are confirmed; costs, workdays, and Meal modifier remain tunable. |
| Contamination scope | Candidate for 1.0 or later, not a prototype/MVP requirement. |
| Contextual PA scope | Full-release or later candidate; writing, recording, localization, repetition controls, and budget remain open. |
| Mixed-stack automatic coherence | Current rule retained after representative catalogue PASS: mixed/non-auto-coherent stacks reject automatic insertion. Revisit only if later expanded content or system evidence exposes a specific issue. |
| Manual under-base insertion | Deferred. Automatic base promotion is confirmed; manual placement currently appends only to the visible top. Reassess only after larger-scale playtesting. |
| Multi-column support packing | Not part of the confirmed linear-stack architecture. Consider only if future evidence justifies multiple side-by-side items on one support surface without undermining predictability. |
| Starting inventory | Economy/balance TBD. Moderate starting installed capacity does not imply a fixed stock level. |
| Furniture movement / labels | Unit/socket movement remains OPEN; existing empty-only safeguard applies if retained. Labels are intended, restrained/diegetic; exact mechanics, anchors, renderer and icons remain open. |
| Machinery unlocks | Incinerator unavailable on Day 1; exact day and prerequisites open. Offline-from-start repair is preferred fiction. Salvager introduction remains undecided. |
| Layout / shelf and bay metrics | Accepted builder/saved geometry and final overview are the working spatial baseline. Future furniture, bay lining, actual item visibility/reach and request travel may motivate specific revisions; they do not reopen the completed greybox by default. Current storage-authoring gates precede Receiving in the order stated in §21.3. |
| Expedition precomputation | Optional only after outcome commitment removes player influence. Backend preparation cannot change deposited capacity or reveal timing. |
| Material-kit route | Ready PBR maps inspected; generated structural-kit pipeline and in-game finish quality still require proof. No subscription purchase implied. |
| Service-space detailing | Room roles, distinct footprint character and three boundaries are confirmed. Exact furnishing, asset roster, delivery actions/mechanisms and feedback are later work, not a greybox prerequisite. |

### 21.3 Current next artifacts and bounded follow-ups

Current documents are GDD v0.9, Prototype Findings v0.9 and Visual Direction v0.6. Greybox spatial approval, repository/documentation synchronization, seeded wing integration, default-entry promotion and Fuel reconciliation are complete. The current gate order is review-scene supply reuse -> reusable functional modular-rack authoring -> fixed-ladder proof -> human ladder decision -> Receiving.

- Reuse the accepted review-scene supply setup. Retain the A, B and C comparison scene and developer-authored rack; this gate does not select production installations.

- Build reusable functional modular-rack authoring while preserving developer authority over model, placement, dimensions and levels. The retained static rack is not production storage.

- Test one fixed shelf-serving ladder on one rack, then obtain the human decision. The proof does not authorize general climbing, movable ladders, animation, fall systems or adjustable shelves.

- After the human ladder decision, resume Receiving unless storage work reveals another blocker. Fuel is reconciled; Gloves and Pants remain excluded from the Receiving pool.

- Keep the architectural and material proof separate. Later validate Stage B piles, Stage C queue pressure and the first timed obligation; economy, simulation and save/crash work remain later.

APPENDIX A | EXAMPLE DAY

## A.1 Illustrative Day 12 timeline

PROVISIONAL This example demonstrates intended rhythm. Event frequency, values, and durations are not balance commitments.

| Time | Event | Quartermaster decision |
| --- | --- | --- |
| 07:00 | Day starts with 13 Ready scavengers and two Medical patients: teams 4/4/4/1. Destinations include pharmacy, residential, hardware, and supermarket. | Prioritize Medical and Protection for the pharmacy team while noting today's patient-based meal demand. |
| 07:25 | Red Medical signal: one consolidated treatment request asks for 8 Medical before late afternoon. | Interrupt pantry work, submit 5/8 now, and plan a second retrieval after expedition dispatch. |
| 08:10 | Pharmacy team is fully provisioned and sent early. | Its compact loadout leaves 73 percent Return Capacity; Food and Hydration improve timing but do not change base capacity. |
| 08:52 | Three teams remain and time is short. | Force-send the hardware team with weak Protection; finish Weapons for residential to improve Bulk utilization. |
| 09:00 | All remaining teams depart. Breakfast requests 18 Food and 10 Hydration. | Submit bulky cereal, cat food, water, and soda; preserve compact Rations for expeditions. |
| 10:20 | Bunker Ops opens a long request for Fuel, Morale, and Electronics. | Stage Fuel, Morale and Electronics items in the carried bundle or a legal nearby storage surface; the hatch itself is not storage. |
| 11:05 | Pharmacy team returns. The elevator reveal contains dense medicine, clothing, and awkward household objects. | Cherry-pick Medical first, then clear high-Bulk objects before another batch arrives. |
| 12:30 | A pre-rolled Fuel outage from yesterday disables the salvager and incinerator; room and request lights go dark. | Carry the bulky lamp back to the sorting table instead of destroying it; use the still-active monitor and PA to coordinate. |
| 13:47 | Residential team is incoming while the elevator still contains six items. | Clear Receiving before lunch rather than turning the elevator into hidden storage. |
| 14:00 | Lunch requests Food and Hydration while the Medical obligation is still only 5/8 supplied. | Carry a mixed bundle, fill lunch, then finish Medical before returning to the elevator. |
| 15:25 | An Electronics outage silences the PA and central monitor; request lights remain on. | Navigate by clock, room layout, local lights, and contextual hatch panels until communications return. |
| 16:10 | Hardware team returns with a low-Utility assortment after weak all-round provisioning. | Keep wire and tools, salvage a bulky item when the machine returns, and accept that equal returned Bulk can contain poor future value. |
| 18:00 | Dinner opens. Daily Meal Coverage will be imperfect. | Use two Rations plus remaining low-density Food and Hydration to reduce tomorrow's treatment-failure risk. |
| 21:40 | The one-person team returns with poor loot and a recruit candidate. | Accept the candidate despite limited storage to rebuild future team count. |
| 23:40 | The final clamped expedition arrives and the elevator queue reaches three batches. | Unload enough to prevent an Awaiting Lift team from abandoning its loot at midnight. |
| 00:00 | Night report resolves treatment, Meal Coverage, Bunker Ops effects, Workshop progress, Rations, recruit arrival, and next-day warnings. | Review one screen of cards: one patient recovered, one treatment failed due to Meal Coverage, and maximum Electronics outages are scheduled tomorrow. |

### A.2 Intended player story

Nothing in this example required a visible human NPC, exterior level, combat encounter, vehicle, simulated Kitchen worker, or moving elevator. The optional ambient dog, if retained, remains non-mechanical and does not alter any of these logistics outcomes. The player nevertheless experienced prioritization, treatment pressure, poor expedition consequences, spatial reorganization, machine and communications outages, Bunker Ops planning, a recruitment gamble, and a queue crisis through physical objects and timed signals.

APPENDIX B | GLOSSARY AND CONFIRMED CONSTANTS

## B.1 Glossary

| Term | Definition |
| --- | --- |
| Bulk | Shared abstract handling burden used for player carrying, outgoing team load, and returned loot budgets. |
| Footprint | Discrete physical storage occupancy and compatibility, separate from Bulk. |
| Utility | Numeric contribution an item provides to a destination or request. |
| Utility Density | Internal normalized Utility per unit of Bulk, used to balance and generate haul quality; never displayed as a frontend item statistic. |
| Loot Quality | Player-legible result of all-round expedition provisioning; internally expressed through Utility-Density-biased item selection. |
| Meal Coverage | Arithmetic average of capped Food and Hydration coverage across the three daily meals. |
| Safety Coverage | Combined capped Medical and Protection coverage used by the expedition casualty model. |
| Return Capacity | Team Load Capacity remaining after subtracting outgoing loadout Bulk. |
| Bulk utilization | Fraction of Return Capacity actually filled by a haul. |
| Receiving batch | Durable committed per-item content with a separate preparation state. It may exist before delivery; it counts toward Receiving only after deposit. |
| Awaiting Lift | Returned team whose loot cannot be deposited because all three Receiving slots are occupied; undeposited haul is forfeited at midnight even if prepared earlier. |
| Bunker Ops | One daily multi-meter Fuel, Morale, and/or Electronics request that determines next-day lane-specific conditions. |
| Treatment stage | A two-Medical-Utility step that clears Light or downgrades Severe to Light. |
| Outcome Profile | Coverage-to-consequence data applied after a request resolves. |
| Outage window | Pre-rolled temporary loss of a defined machine, lighting, communications, or monitoring channel. |
| Salvage | Physical standardized upgrade material produced by the salvager. |
| Run | One consequence-preserving survival attempt from Day 1 until failure. |
| ItemInstance identity | Durable ID for an individual physical item, distinct from definition ID and preserved across valid representations/reconstruction. |
| PREPARED | Committed accepted presentation-local transforms and matching profile identity/revision; not an occupancy state. |
| Administrator | Unseen bunker leader coordinating wider needs, tutorials and operational one-way messages. |
| Foundation Gate | Separate human production-art approval of Structural Shell and Applied Finish. Neutral gameplay fixtures and seeded-storage tests do not require finished art and do not promote it. |
| Storage socket | Authored placement opportunity for a compatible unit; never unrestricted furniture placement. |
| Service space | Playable department-owned support room / landing in front of an opaque inner boundary; not the staffed operational core or automatic Quartermaster storage. |
| Three boundaries | Territorial entry, explicit material-ownership transfer and the inner playable-world limit are separate conditions. |
| Frontage (legacy label) | Historic shorthand on retained schematics. Interpret as the current service-space/interface territory; never as authority to replace its usable footprint with a blocker. |

### B.2 Confirmed constants and launch rules

| Rule | Confirmed value |
| --- | --- |
| Working title | Sorting Apocalypse |
| Day window | 07:00-00:00 |
| Target real day duration | 25-30 minutes, provisional tuning range |
| Fixed Kitchen meals | 09:00, 14:00, 18:00; each requests Food and Hydration |
| Meal demand basis | Fixed untracked-bunker cost plus current Medical patients; no all-scavenger double charge |
| Meal Coverage | Average of six capped meal meters; provisional treatment-failure maximum is 50% |
| Expedition preparation | 07:00-09:00 |
| Latest normal return target | Approximately 23:40; later calculations are clamped with penalty |
| Team size | 1-4, automatically formed |
| Expeditions per team | At most one per day |
| Expedition meters | Food, Hydration, Medical, Weapons, Protection |
| Team Load Capacity | Fixed by team size at launch; Food and Hydration do not modify it |
| Elevator batch capacity | Three DEPOSITED slots: one active plus two FIFO queued. Prepared undelivered batches consume none. |
| Medical treatment | 2 Medical Utility per stage; Light requires one stage, Severe requires two |
| Severe complication | +20 percentage points of night death chance per unsuccessful required treatment day, capped at 100% |
| Bunker Ops | One daily request using one to three of Fuel, Morale, and Electronics |
| Fuel 0% state | Maximum configured machine/lighting outage windows next day |
| Electronics 0% state | Maximum configured communications/monitor outage windows next day |
| Morale 0% state | Zero recruitment chance for all expeditions next day |
| Medical light | Red |
| Failure | No living scavenger remains after any final recruit-candidate decision, and no accepted recruit is due the next morning |
| Save model | Multiple ironman-style slots; rotating snapshots, transaction journal, committed random outcomes, save on exit |
| Furniture | Static or predetermined sockets. Movement remains OPEN; only specified unit/socket pairs and empty eligible containers if retained. |
| Arbitrary dropping | Not allowed |
| Game-defined junk | None |
| Rations | Accepted by meals and expeditions; rejected by ration production |
| Item Storage Categories | Food, Hydration, Medical, Weapons, Protection, Fuel, Morale, Electronics |
| General storage zone | Universal enabled storage zone; not an item Storage Category |
| No Zone / erased cells | Disabled storage; automatic and manual placement both reject these cells |
| Auto-placement zone order | Matching specific category -> General -> stop; compatible stacks are preferred before empty placement within a tier |
| Support stacking | Deterministic single-column stacks; automatic smart insertion/base promotion; manual mixed top-stacking; visible-member retrieval |
| Stack headroom | 95% of physical clearance for stacks. Singletons use physical clearance only; both enforce fit at commit. |
| Receiving physical boundary | Permanent barrier; stationary bay/deck; animated shutter; TAKE-only; no live/dormant rigid-body loot. |
| Incinerator introduction | Not Day 1; exact unlock timing/cost/prerequisites remain provisional. Salvager timing remains open. |
| Authored environment | No ambient prop rearrangement. Explicit night upgrades/repairs may change designated persistent states. |
| Off-map facilities | Staffed operational cores remain unseen; Workshop/Kitchen service rooms, Medical Supply Anteroom and Bunker Ops Transfer Landing are playable. No visible personnel route to the surface. |
| Starting loot | Production starting stock remains economy/balance work. The explicitly seeded wing-integration fixture is a reproducible test load, not a new-game inventory decision. |

### B.3 Closing design statement

The sorting is not a minigame attached to survival. Sorting is how the player operates the survival simulation.

Sorting Apocalypse succeeds if players develop personal systems, feel ownership over both order and mess, understand why their material decisions changed the bunker's future, and can tell stories about an outside world the game never had to render.

APPENDIX C | v0.8 REVISION AND SOURCE REGISTER

### C.1 Material changes and explicit supersessions

| Affected sections | Historical v0.7 changes; v0.8 consolidation below |
| --- | --- |
| 1-4; 12-16 | Dedicated Workshop/Kitchen service rooms, Medical Supply Anteroom and open Bunker Ops Transfer Landing replace frontage-only representation. Staffed cores remain unmodeled. |
| 4.7-4.8; VDD §16 | Three boundaries separated: open territorial entry; explicit supply commitment; opaque inner world boundary. The old blanket ban on all facility interiors no longer excludes service rooms. |
| 4.6; VDD §§15, 19, 29 | Round-one Kitchen route now uses Gallery B's east doorway. Restore A-east/B-west openings to the shared junction; Medical remains on its protected spur. Explicit change, not a silent schematic reconciliation. |
| 18; 20-21 | v0.7 historical status: first wing existed under REVISE; preserve original main/player and historical Receiving work. Superseded for current status by the v0.8 promotion below. |
| 18; 20-21 | Earlier in-session sequencing decision retained: functional Receiving may use neutral geometry before final finish approval. Foundation Gate still governs production-art progression. |
| Source figures / later scope | Retain original V3/V2 images with explicit interpretation notes; do not claim redrawn or dimension-approved schematics. Exact furnishing and delivery choreography remain deferred. |
| All unaffected systems | No change to day clock, utilities, request consequences, Workshop project model, treatment, expedition/loot rules, stacking/zoning, progression balance or save requirements. |
| v0.8: 4; 18; 20-21 | PROMOTE accepted neutral whole-wing geometry after three revision rounds and final Medical tuning. Builder/saved scene/overview supersede schematic pixels as dimensional baseline. |
| v0.8: 4.6; VDD §22 | Remove the Workshop abandoned-route retention rule. No abandoned stubs now; roughly two or three may be considered later away from service-space adjacencies. |
| v0.8: 20.6-20.7 | Require stable local/GitHub/documentation close-out, then seeded shelves/loot integration, then functional Receiving. Old main remains intact; default-scene changes are deferred to bridge implementation and acceptance. |
| v0.8: evidence / production | Record supervised whole-wing authoring and bounded revision feasibility without claiming unattended production, final materials, delivery mechanics or balanced capacity. |

The following remain deliberately unchanged: day clock and fixed meals; request lanes and automatic allocation; expedition population, capacity, casualties and recruitment; Medical triage/stages/complications; Bunker Ops lane effects; basic salvage/ration conversions; intended consequence-preserving save behavior; optional/deferred feature boundaries unless expressly noted.

### C.2 Source and authority register

| Key | Source / boundary |
| --- | --- |
| G05 | Supplied Preliminary GDD v0.5, 15 September 2026. Baseline design immediately before the topology/schematic consolidation. |
| P05 | Supplied Prototype Findings v0.5, 15 September 2026. Evidence baseline immediately before the topology/schematic consolidation. |
| R12 | Receiving/Elevator MVP Architecture Design, 12 September 2026; repository target docs/superpowers/specs/2026-09-12-receiving-elevator-mvp-design.md. Approved design, not proof of physical implementation. |
| V03 | Visual Design & World-Building Direction v0.3, 15 September 2026. Prior visual/topology baseline; unchanged material/world rules retained, service-space and route wording superseded explicitly by V04. |
| D11-15 / D12 / D13-14 / D14-15 | User-approved decisions and supplied Codex/human reports in the 11-15 September 2026 project conversation. Narrow suffixes identify the relevant discussion dates. |
| D12A | Reported Stage A completion/merge at 41415a4 with 30/30 strict suites and post-merge verification. |
| D13B | Reported Pass 1 shell commit c9752c8 and human visual NO-GO; separate loot_000015 reimport drift. |
| K13 | Written KitBash support response supplied by the developer on 13 September; recorded as correspondence, not independently revalidated licensing advice. |
| P06 | Supplied Prototype Findings v0.6, 15 September 2026. Historical implementation/evidence baseline before first-wing review. |
| D15T | 15 September topology/layout session: approved five-gallery network, C<->D loop, branch/frontage refinements, dog-legged Deeper-Bunker Approach, door policy, Detailed Topology V3 and Basic Structural Schematic V2. Design approval only; no Godot greybox run. |
| G06 | Supplied Preliminary GDD v0.6, 15 September 2026. Source document for this targeted revision. |
| V04 / P07 | Prior companion Visual Direction v0.4 and Findings v0.7. Service-space agreement retained; their then-current geometry status and roadmap were superseded by V05/P08 and later by V06/P09. |
| W16 | Supplied logistics-wing-greybox-validation.md: implementation verified through 7ba27a5, captures at 21a2dba, 33/33 non-hanging scripts and 17 routes / 7 boundaries reported. Later final commit d81783f is user-reported, not independently audited. |
| H16 | Developer round-one walkthrough observations, annotated images and recording. Disposition: refine existing wing; geometry correction directions include Kitchen access via Gallery B east. |
| S16 | Supplied Greybox Round01 Source Review and wing source snapshot: static geometry/shared-wall/capture findings, not a new Godot or physics test run. |
| D16S | Developer-approved dedicated service-space concept: three enterable support rooms, distinct footprints, open Ops landing, three boundaries; furnishing and delivery detail explicitly deferred. |
| D16P | Earlier approved in-session sequence: low-fidelity wing first, prompt return to functional Receiving, then a bounded visual-construction proof. Production-art approval does not block neutral gameplay experiments. |
| G07 / P07 | Supplied full GDD v0.7 and Findings v0.7 (16 September), retained source for this consolidation. |
| V05 / P08 | Companion Visual Direction v0.5 and Findings v0.8 (17 September); historical records of the then-current visual, spatial and evidence state, superseded by V06/P09. |
| D16-R02 | Developer decision and round-two amendment: remove Workshop abandoned stub, no immediate service-space adjacency, later opportunistic stubs only. |
| W17 / H17 | Supplied round-one/two/three and Medical reports plus developer walkthroughs. Final Medical source aeb1ef2; final docs 8d64086; local reported tests, followed by explicit human acceptance. |
| A17 | Sorting_Apocalypse_Wing_Greybox_Acceptance_2026-09-17.md and independent static-check JSON. Promoted neutral spatial baseline; no new runtime test or repository write. |
| D17B | Developer request in this conversation: complete repository/documentation bookkeeping, then functional shelves and pre-seeded loot in the wing before Receiving; retain old main intact. |
| R17 | Read-only GitHub inspection on 17 September: Navandis/Sorting-apoc-PROTOTYPE main at 8ee62bd3, only main branch returned. At that historical checkpoint, publication of the local wing remained a local close-out action and had not been performed. |

This v0.8 consolidation recorded accepted spatial evidence and the then-required seeded-storage prerequisite. At that checkpoint it changed status, abandoned-route scope and sequencing, not item, request, treatment, expedition, stacking, zoning or save mechanics. It made no local merge/push, Godot-run, scene-migration or functional-Receiving claim. [W17, H17, A17, D17B, R17]

## APPENDIX D v0.9 STORAGE AUTHORING CONSOLIDATION

### D.1 Current playable composition and palette

res://gameplay/logistics_wing/wing_gameplay.tscn is the normal development and playable composition. It combines the accepted wing geometry, normal player and HUD, three functional storage units, twelve functional surfaces, and the saved DevelopmentSetup palette. Legacy main.tscn remains an explicit mechanics fixture and the neutral review scene remains available for spatial review. In the continuing scene F6 developer grids are retained and default off, while F7 is suppressed.

The saved DevelopmentSetup/SeedItems composition is the palette authority. It contains at least one direct editor-authored host for every currently approved eligible type, retains the separate fixed twelve-host regression fixture, and preserves the developer's table and item arrangement. Fuel (loot_000015) is eligible for correctly authored development hosts after its maintenance reconciliation. Gloves (loot_000034) and Pants (loot_000036) remain blocked. This palette is development authoring support, not a production starting inventory decision.

### D.2 Storage installation and authoring authority

Storage usability belongs to the complete installation: furniture model, authored dimensions and level distribution, room placement, approach space, usable depth and insets, player viewpoint, interaction reach, lighting, target visibility and obstruction. Technical cell capacity alone is not proof that a person can see, target and manually place items.

- Use a mixed storage family. Predominantly open modular racks form the general backbone; shallow wall storage, specialist units and deliberately absent top decks solve specific conditions. Cabinets and other opaque storage remain selective rather than the default.

- Open racks may tolerate greater usable depth where players can approach from more sides. Wall and corner installations generally require shallower usable depth and clear shelf openings.

- A slim authored usable-area inset may be evaluated independently at each edge. Do not impose one universal percentage or silently remove useful front-edge capacity.

- The developer retains final authority over functional storage installation authoring: model selection, installation placement, unit dimensions, level count and distribution, and ladder availability and placement. Codex may assist with tooling, validation, decoration and later synthetic checks. This is a development-authoring responsibility, not a player-facing furniture-construction permission. The in-game player retains ownership of storage taxonomy, zoning, labels and day-to-day organization within the authored installations.

### D.3 Ground access evidence and fixed ladder proof

The A, B and C review experiment is completed evidence and its explicit review scene is retained. Uniformly compressing existing multi-level furniture is rejected as the general solution. In the tested corner-mounted modular-rack context, more than three ground-access levels produced unacceptable compromises in visibility and manual targeting unless the shelves became too shallow or squat. The developer's manually authored three-level modular-rack configuration is a useful ground-access reference, not a universal production template. SM_Rack01.glb and SM_Rack02.glb remain static review assets without functional storage surfaces.

A 1.80 m eye height improved some upper-level cases but did not solve deep shelves or opaque dividers and could worsen low-shelf viewing. A 2.8 m ordinary ceiling looked more proportionate in the tested context. Both remain trial observations; neither changes the wing camera or ceilings.

Fixed shelf-serving ladders are approved only for a bounded proof based on the current ergonomics evidence. This does not approve production ladders, general climbing or jumping, movable or sliding ladders, animations, visible hands, a fall system or shelf-adjustment interaction. Player-adjustable shelf levels remain a post-release or expansion possibility with no weight in the current ladder decision.

### D.4 Current gate order and supersessions

1.  Reuse the accepted review-scene supply and item presentation where it reduces duplicate setup without changing the normal palette authority.

1.  Create reusable functional modular-rack authoring that preserves player ownership of each installation.

1.  Run one fixed shelf-serving ladder proof on a single rack.

1.  Make the human ladder decision from that proof.

1.  Resume Receiving unless storage ergonomics exposes another concrete blocker.

This order supersedes the v0.8 sequence that treated seeded storage, Fuel reconciliation and shelf ergonomics as pending. Receiving remains the next systems feature after the Storage Authoring and Testbed Foundation and ladder decision. Production palette reuse, functional modular racks, ladders, camera or ceiling promotion, gallery furnishing, crouch, height-aware auto-placement and player-adjustable shelves are not implemented by this revision.

### D.5 Current evidence

Current repo-local records are docs/testing/wing-gameplay-default-entry-closeout-validation.md, docs/testing/wing-gameplay-foundation-acceptance-2026-09-18.md, docs/testing/locker-fuel-maintenance-validation.md, docs/testing/expanded-item-palette-validation.md and docs/testing/shelf-ceiling-ergonomics-comparison.md. Process guidance is docs/AI_WORKING_GUIDELINES.md. Historical reports retain the status they had when written.
