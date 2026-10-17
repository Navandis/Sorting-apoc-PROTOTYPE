# Sorting Apocalypse — Systems MVP Foundation Design & Progress v0.3

> Generated text/table extract of the same-named DOCX master. The DOCX is authoritative; edit it and regenerate this companion. Page layout, headers and footers are omitted. M1 published; M2 human-promoted / closed; status-only acceptance close-out. 17 October 2026.

**SORTING APOCALYPSE**

## SYSTEMS MVP
FOUNDATION DESIGN
&amp; PROGRESS

Persistent supplies. Competing obligations.
One continuing storeroom.

Version 0.3  \|  17 October 2026  \|  M2 human-promoted / closed

FIRST INTEGRATED TARGET
Medical → Kitchen → Expedition Loadout, sharing physical supplies, request accounting and one persistent run. Meaningful allocation testing begins with the combined three-consumer loop.

This is the MVP-phase counterpart to Prototype Findings: a living foundation-design, implementation-progress and evidence record. It belongs alongside the GDD and Visual Design Direction as an active project master. Prototype Findings v0.14 is retired from active progress tracking, not discarded as evidence.

| Authority | Role |
| --- | --- |
| GDD v0.14 | Overall game design, intended rules and full-game scope. |
| VDD v0.11 | World, visual, spatial, material and environment-authoring direction. |
| This master v0.3 | Active MVP contracts, approved M2 design, implementation evidence and full-game continuity principles. |
| Prototype Findings v0.14 | Preserved historical prototype record; unresolved obligations remain live here. |

**DESIGN CONFIRMED IN CONVERSATION ≠ IMPLEMENTED ≠ HUMAN-PROMOTED**

M1 remains HUMAN-PROMOTED / PUBLISHED / CLOSED. M2 is technically verified, independently ACCEPTED and HUMAN-PROMOTED / CLOSED after all final human playtests passed. Publication is authorized, subject to safe fast-forward and live remote verification (§15). M3 Kitchen is next, NOT IMPLEMENTED.

**ORIENTATION**

## Reader’s guide &amp; current position

Current position: M2 clock, scheduling, midnight and HUD are HUMAN-PROMOTED / CLOSED (§15). M1 stays published/closed; M3 Kitchen is next, NOT IMPLEMENTED. Full-game continuous preservation remains unimplemented. CF-07 and the Windows certificate-store diagnostic remain disclosed.

### How to use this master

Read §§1–3 for authority and baseline; §§4–12 for shared contracts; §§13–15 for stages, evidence and progress. Section 16 carries inherited obligations. Section 17 separates settled design from remaining technical work. Sections 18–19 record the approved M2 specification and full-game Ironman/randomness principles; appendices preserve decisions and sources.

| Section | Contents | Pages |
| --- | --- | --- |
| 1–3 | Authority and prototype retirement; verified baseline; first integrated scope. | 3–5 |
| 4–5 | Shared request ownership and irreversible physical submission. | 6–7 |
| 6 | Single-slot persistence, preserved state and reconstruction. | 8–10 |
| 7–9 | Authoritative gameplay time, presentation synchronization, midnight, menu and HUD. | 11–14 |
| 10–12 | Authored scenarios; Medical/Kitchen; Expedition Loadout. | 15–17 |
| 13–15 | Implementation stages, acceptance evidence and active progress tracking. | 18–21 |
| 16–17 | Carried-forward obligations and settled versus remaining delivery choices. | 22–26 |
| 18–19 | Approved M2 clock/scenario/night specification; full-game continuous Ironman state and randomness. | 27–33 |
| A–B | Dated decisions, published evidence anchors and edition maintenance. | 34–39 |

### Status vocabulary

CONFIRMED DESIGN records an approved behavior. NOT IMPLEMENTED means no implementation is established. REPORTED VERIFIED attributes a test or review to its source. HUMAN-PROMOTED requires a dated developer decision. DEFERRED retains work with a trigger or later scope; it does not mean rejected. OPEN identifies an unsettled choice. DERIVED REQUIREMENT labels a necessary consequence of an agreed contract, not a newly approved mechanism.

Short source labels such as [D03], [PF §25.6] and [CR15] point to the registers at the end. They distinguish this conversation’s later decisions from published prototype-era design and evidence. Dates and old pending statements remain historical; do not infer current status from an isolated historical paragraph.

**DOCUMENT GOVERNANCE**

## 1. Authority &amp; prototype retirement

### 1.1 Active document set

The developer has designated this document as the active MVP-phase counterpart to Prototype Findings. MVP progress, new findings, unresolved implementation work and subsequent acceptance belong here, with detailed evidence in focused validation records. GDD v0.14 remains gameplay/full-game authority; VDD v0.11 remains visual/spatial authority. [D10]

Prototype Findings v0.14 and earlier editions remain intact as historical context and the provenance of promoted foundations, rejected experiments, known debt and confirmed-but-unimplemented work. Retiring the document does not retire those commitments. Sections 2 and 16 carry their current dispositions into the MVP phase and retain exact source sections.

### 1.2 Supersession without silent redesign

Later explicit developer decisions govern this edition: accepted M1 controls and continuation; approved M2 scheduling, report and auto-save; and the full-game continuous Ironman contract in §19. The latter assumes the completed preservation system, not M2’s temporary save cadence. Loadout overfill and P01’s Utility estimator remain provisional. Earlier GDD tuning is superseded only where identified. [D16–D21; M2]

A historical statement that Stage C, the fixed ladder, Fuel reconciliation or EAF tooling is pending must not be imported as unfinished work when a later recorded promotion closes it. Conversely, an omitted item is not implicitly resolved: its historical record remains available and must be consulted when the affected subsystem is extended.

### 1.3 Master and evidence discipline

The DOCX is the editable master; a same-stem readable Markdown extract is derived from it, not maintained independently. Detailed tests and human reviews remain in their dated records; this master summarizes their meaning and links to them. Source code establishes implementation, but an unintended behavior is not automatically a design decision.

v0.1 and v0.2 remain preserved editions. v0.3 was published at 2cad0d7; this status-only close-out retains its edition, approved design and full-game randomness contract. The active trio remains GDD v0.14 / VDD v0.11 / MVP v0.3. M2 acceptance is recorded in §15; other masters and game source are unchanged by this close-out.

Basis: [D10] developer document-role decision; [H14 §§1, 3–4, 15]; [ER14 §§3, 12]; [WG].

**CURRENT CHECKPOINT**

## 2. Starting baseline &amp; evidence

### 2.1 Published reference

Publication preflight on 17 October verified local main and live GitHub main at 2cad0d766930ae2d5197171146ef253eb1087ad5. Reviewed M2 follows linearly: 524edf1 → c7bbf44; one docs-only promotion commit follows. M1’s accepted 4cdbb13 → 6c56edf → a7b764e → 36d527d history remains closed. These are evidence anchors, never reset targets. [PUB16; §15]

The authoritative asset-equipped checkout remains D:\Godot Projects\Sorting-apoc-PROTOTYPE, repository Navandis/Sorting-apoc-PROTOTYPE. Publication preflight verified the clean reviewed checkout and retained Godot 4.7 Compatibility configuration. No Godot run, import scan or access to the developer’s user://saves is required or performed by this documentation close-out.

| Foundation | Disposition carried into MVP |
| --- | --- |
| Storage/content | Representative carry/store/retrieve, zoning, deterministic stacking, pose/Footprint and selected fixed-ladder/rack integration remain HUMAN-PROMOTED. |
| Receiving A/B/C | Exact commitments, private TAKE-only presentation, fully-OPEN gating, FIFO departure and Awaiting Lift remain promoted in their agreed prototype scopes. |
| C1 / intentional lighting / EAF1–EAF5 | Promoted/closed as recorded. Ordinary later authoring does not automatically reopen them. |
| Pre-MVP R-01–R-03 | Corrected, independently reviewed, human-playtested and HUMAN-PROMOTED; published in the current main history. |
| R-04 reflection teardown | Originally deferred; bounded owner-lifetime repair accepted within M1. Broader CF-07 rendering debt remains. [M1] |

### 2.2 Evidence boundary

The repair record preserves the initial 16 selected suites and six abort canaries, the independent REVISE for two manual-address cases, and the seven-suite/unchanged-probe follow-up with one focused review. The developer subsequently reported correct behavior in all manually tested scenarios and promoted the repairs. These are attributed prior results, not new executions or an exhaustive runtime guarantee. [CR15]

The earlier pre-MVP corrections did not implement persistence. Accepted M1 establishes ordinary Medical, menu and continuation; accepted M2 adds calendar, timed requests and midnight (§15). Kitchen, Loadout and full-game continuous Ironman durability remain unimplemented.

Basis: [PF §§24–30, 34]; [CR15]; [R15].

**SCOPE &amp; VALIDATION**

## 3. First integrated MVP target

Operate the same storeroom across repeated days and application sessions, allocating finite physical supplies between Medical, Kitchen and Expedition Loadout. Both organization and expenditure persist. [D01–D03]

| Consumer | Utility lanes | Competition introduced |
| --- | --- | --- |
| Medical | Medical | Departmental demand competes with loadout Medical and future reserves. |
| Kitchen | Food, Hydration | Today’s meals compete with tomorrow’s provisioning and other meal windows. |
| Expedition Loadout | Food, Hydration, Medical, Weapons, Protection | Broad equipment demand overlaps both departments; outgoing Bulk preserves equipment-efficiency choices. |

### 3.1 What this slice can establish

Test whether players preserve reserves, deliberately leave some requests partially fulfilled, select items for different destinations, and benefit from their own storage organization. A supply spent today must be unavailable tomorrow unless a genuinely new delivery replaces it. Saving or relaunching must not reset the decision. Direct Receiving-to-destination delivery remains legitimate; Sorting and storage must not be made artificially compulsory. [D01–D02; GDD §§3, 4.6]

Medical alone is an implementation and local-usability checkpoint. Meaningful three-way allocation validation is reserved for the combined consumers across continuing cycles and sessions. Later unfamiliar-player testing can examine comprehension and voluntary organization; developer play and code tests do not establish broad audience response. [D01–D02; H14 §5]

### 3.2 Simplified outcomes, retained architecture

Initial Medical and Kitchen requests are X needed → X submitted → X consumed, with durable fulfillment/shortfall records. No patient cohort or treatment calculation is required. Team-labelled loadout requests do not imply actual Expedition teams, journeys, casualties, return scheduling or population. Incoming loot remains scenario-controlled. [D01–D02]

This creates real material depletion and competing obligations, but does not yet validate the full survival economy, treatment/mortality balance or provisioning-to-loot feedback. Workshop, Bunker Ops, ration production, salvage/incineration, upgrades and full Expedition integration remain later scopes; none is discarded. [GDD §§8–15, 20; §16 here]

Basis: [D01–D03]; [GDD §§3, 6, 8, 10, 20–21]; [H14 §5].

**DESIGN CONTRACT**

## 4. Shared foundation ownership

Build one collection system that can be extended, not three disposable consumers. The names below identify responsibilities; except for existing project types, they do not prescribe new classes, autoloads, files or API signatures. The GDD’s RequestDefinition / OutcomeProfile separation remains the design basis. [D02; GDD §§8.4, 18.4]

| Owner / responsibility | Initial role | Later extension |
| --- | --- | --- |
| Requirement source | Authored scenario supplies request identity, destination, lanes, targets and activation/closure conditions. | Patient state, Kitchen demand rules and actual team formation can replace controlled inputs. |
| Request state | Owns one persistent request’s targets, accepted contributions and lifecycle. | Same state supports richer outcomes; it is not re-created from its definition on load. |
| Submission transaction | Validates and commits an exact item plus destination credit as one operation. | Other material consumers reuse the transfer boundary, not a copy of carrying logic. |
| Resolution / OutcomeProfile | Produces durable required/supplied/unmet results. | Treatment, Meal Coverage effects and expedition outcomes consume those results later. |
| Run persistence | Captures and restores a coherent set of live gameplay state. | Additional owners extend the saved state without making presentation nodes authoritative. |
| Simulation clock / scheduler | Activated in the clock stage; owns chronology and configured events. | Real demand/return producers use the same timeline later. |
| Presentation | HUD, menu, physical interface feedback and lift theatre interpret gameplay state. | Future in-world clocks read the same time source; rendering is not a second timer. |

### 4.1 Existing type and ownership boundaries

ItemDefinition already exposes primary Utility, destination-specific overrides, Bulk and a separate Storage Category. ItemInstance remains durable physical identity; WorldItem and held/HUD objects are representations. Use the existing contextual Utility path rather than treating Storage Category as a destination’s consumption rule. Current data support does not establish that every scenario item has been economically balanced or validated for the new consumers. [SRC15; GDD §6]

A controlled requirement of 12 Medical Utility can later be replaced by patient-derived demand of 12 without changing the collector. That is the intended extensibility test—not a mandate for a large generic framework. [D02]

Basis: [D02]; [GDD §§6, 8.4, 18.3–18.4]; [SRC15]; [ER14 §12].

**IRREVERSIBLE OWNERSHIP**

## 5. Submission &amp; request accounting

Either the player retains the item and the request receives nothing, or the exact item is committed and its contribution is credited once. A later request resolution does not consume that item a second time. [D02]

### 5.1 Shared player operation

The player approaches the relevant collection proxy carrying physical supplies. Eligibility depends on the destination’s active request, not on Storage Category or proximity. Entering a room, targeting a proxy or opening the panel never consumes an item; ineligible, closed and full requests are not extra storage. [GDD §§4.8, 7.1, 8.2]

F opens/closes the non-pausing request panel without consuming. Each distinct E submits only the selected eligible carried item; holding E never repeats or chooses “best” bundle contents. Wheel/number selection changes the preview. First ESC closes the panel, next ESC opens the pause menu. Completion closes the centered panel and suppresses station cues. Existing held-E reversible storage is unchanged. [D16; M1]

### 5.1.1 Projected contribution and ineligible state

Preview the held item’s impact before spending: Food 5/12 with +3 soup displays projected 8/12, five solid committed pips, three brighter prospective pips and +3. A subtle green highlight or pulse may identify the impacted lane, but preview and committed gain must remain distinguishable. If the item cannot contribute, show no new pips, a red bar border/highlight and “Selected item not eligible” instead of remaining-after-submission. No green gain for ineligible items. [D14–D15]

Submitting spends the whole item and credits only min(Utility, remaining). At 11/12, a +8 item previews 12/12, +1 applied and 7 wasted; no excess is retained. Show waste before E. Ineligible, full or closed submissions consume nothing. Medical/Kitchen use cap-and-waste; Loadout overfill remains open for M4. [D14; P01]

### 5.2 Transaction and save boundary

Validate the selected item and current request at commit time. Removal, credited Utility and optional loadout Bulk must form one coherent operation; rejection preserves the original state. A save must not capture a half-completed transfer. This is required for ordinary continuation, not a crash journal. [D02–D03]

The engineering review found that carrying item_added, item_removed and contents_changed signals describe collection mutation and can precede success or rollback of the enclosing transfer. They are not authoritative consumption notifications. Irreversible request credit must follow the successful transaction boundary; no speculative global event framework is required. [ER-RESULT §4; CR15]

### 5.3 Persistent result, not a retrievable reserve

After submission, the request holds the credited contribution and exact spent-item ID; the source is no longer retrievable. Previously credited amounts do not change when future item values are retuned. Partial fulfillment is valid. A completed request closes once, recording its target, credited total and unmet amount. Continuing a saved closed request must neither re-credit it nor restore consumed items. [GDD §§3.1, 8.4; D02–D03, D14]

For the initial consumers, resolution reports required, supplied and unmet amounts. It does not claim treatment, recruitment, death, or expedition benefits. Adding those outcome consumers later must not require replacing physical submission or request-instance persistence. [D01–D02]

Basis: [GDD §§3.1, 4.8, 6.3, 7.1–7.2, 8.2–8.4]; [D01–D03]; [ER-RESULT §4]; [CR15].

**6.1  SINGLE RUN CONTRACT**

## 6. Persistence &amp; continuation

| Requirement | First implementation obligation |
| --- | --- |
| Across day transitions | Keep supplies and their organization. Apply only configured request/event/day changes; do not reset or tidy stock. |
| Manual save and resume | Save a coherent current state; close/reopen the application; Continue restores the same gameplay state. |
| One save slot | One advancing continuation; Save &amp; Exit and midnight use the same path. Full-game continuous maintenance extends it (§19). |
| Explicit New Run | Starting stock is created once for a new run. Continue is not a fresh initialization. |
| Midnight auto-save | From the clock stage, save after transition calculations using the same save operation as manual saving. |
| No offline advancement | Time and events do not advance merely because the application was closed. |

### 6.1.1 Deliberately excluded resilience work

Release-grade crash durability, journaling and rotating recovery were excluded from M1 and remain outside M2 implementation. This is a delivery boundary, not the full-game design premise: the intended complete system maintains one advancing run state continuously, ideally limiting loss to 2–3 real seconds (§19). Internal preservation, Save &amp; Exit and midnight saving use the same system. [D03–D04, D21]

At the accepted M1/initial M2 delivery level, unsaved actions may be lost after unexpected termination. Ordinary continuation must still preserve exact ownership, credit and gameplay time. Do not use this intentionally limited implementation to assess the full-game randomness principle. Exact audiovisual-frame recovery remains unnecessary. [D03, D05, D21]

### 6.1.2 Ordinary failures and scope boundaries

A failed save is visibly reported rather than called successful; Save &amp; Exit does not leave the active run after failure. A failed load must not silently create a replacement run. The midnight warning and previous successfully saved state should remain available after an ordinary reported write failure; this does not promise resilience against crashes, power loss or manual corruption. [D03–D04; D08–D09]

M1 implements Save &amp; Exit through versioned JSON, Save_&lt;RUN_ID&gt;_DDMMYY-HH-MM.json and one active-slot pointer under user://saves/. No separate Save/Quick Save is requested. M2 invokes the same service after midnight resolution. Full-game continuous preservation later extends that path rather than introducing another save system. [M1; D11, D19, D21]

One slot is one active continuation, not selectable timestamped archives. The run ID is stable; filename wall time does not drive gameplay. M1 validates schema, references and ordinary replacement, retaining the prior valid state on failure. Future journal/rotating copies are internal recovery, never player-choice history. Full-game cadence and safeguards are defined in §19. [M1; D21]

Basis: [D03–D05, D08–D09]; [GDD §§5.3–5.6, 18.5].

**6.2  STATE THAT MUST SURVIVE**

## 6. Persistence &amp; continuation

The preservation inventory is the continuing contract. M1 implements its then-present player, item, storage, request and Receiving owners. M2 extends it with actual calendar, timed occurrences and report state; no patient, roster or full-outcome simulation is implied. [M1; M2 §§6–8]

| State group | Preserve / restore |
| --- | --- |
| Physical items | Exact item identities, definition references and applicable instance state; one live gameplay owner for each remaining item. |
| Carried bundle | Remaining items, slot organization and active selection needed to continue handling coherently. |
| Player / ladder pose | M1 restores exact world position/facing, camera, same-ladder attachment and height; no fallback was needed. Transient input/modals reset. |
| Storage organization | Surface ownership, reservations, stack identities and ordered membership, placed transforms/orientation and packing state; no automatic re-packing on load. |
| Player storage policy | Zone cells, erased/disabled cells, initialization state and supported surface names; labels not yet implemented are not invented. |
| Requests and loadouts | Persistent request IDs, destination/lane targets, accepted contributions, lifecycle/resolution state, and outgoing Bulk when that consumer exists. |
| Receiving / upstream cargo | Committed batch/item identities, accepted arrangements and remaining entries; active/deposited FIFO state, retained upstream commitments and terminal dispositions as applicable. |
| Run progression | Scenario identity, current day/cycle, exact underlying simulation time, persistent event/deadline state and which configured events have already occurred. |
| Identity allocation | The state necessary for new run-scoped items, requests and deliveries to remain unique after restart, independently of content seeds. |
| Transition / summary | Enough phase/result state to reopen a pending summary without repeating midnight or creating tomorrow’s events twice. |

### 6.2.1 Restore committed facts, not new placements

Stored orientation is restored as committed, not recomputed from the unit’s current Front. Rebuilding storage representations must not invoke new-placement policy to discard an existing item merely because the player later erased or changed its zone. Those policies govern future placements, not retrospective movement or removal. [GDD §§7.7–7.8, 18.5; PF §25.4]

Static authored art remains scene authority. M1 restores exact player position, camera, selected held item and the same fixed-ladder attachment/height; no attached-base fallback was needed. Transient panels and held input reset; committed zoning persists. M2 adds report-pending logical restoration without serializing arbitrary UI controls. [M1; D12, D16; M2 §8]

Basis: [D02–D05]; [GDD §§7, 11, 18.5]; [PF §§25.3–25.6, 34].

**6.3  RESTORE WITHOUT REPLAYING GAMEPLAY**

## 6. Persistence &amp; continuation

### 6.3.1 New Run and Continue are different paths

New Run applies the selected scenario’s initial conditions once. Continue restores the saved run, including already-created requests, already-issued deliveries and consumed supplies. Re-instantiating the wing must not run the development seeding path over the loaded state. Preserve the editor-authored palette and separate legacy/review fixtures; do not delete them to achieve continuation. [D02–D03; PF §24.2]

A loaded run is not regenerated by replaying its scenario from day one against empty storage. Existing commitments and fulfillment are restored; only future untriggered events remain eligible to run. Normal reconstruction must not itself emit new-consumption, new-return or midnight-resolution effects. This is a derived requirement of the agreed no-duplication contract. [D02–D05]

### 6.3.2 Identity survives the process

M1 now persists a random run namespace and next allocation sequence for requests, original hosts and new cargo. Old R-03 process-local behavior remains valid for its standalone debug scope. New occurrences after restart receive distinct identities; reconstruction retains existing identities independently of content seeds. [M1; CF-03]

### 6.3.3 Existing logical owners remain owners

ReceivingManager owns deposited batches and drain/FIFO accounting; AwaitingLiftAdmission owns upstream status and fairness. M1 restores these owners and generated storage references. M2 adds deterministic clock-boundary coordination, not another queue, fourth slot or re-preparation of revealed cargo. [M1; M2 §§3, 5, 8]

### 6.3.4 Pause, rebuild and resume coherently

Loading may hold simulation and player interaction while constructing a coherent state and synchronizing presentation. That interval cannot age request deadlines or grant one subsystem time that others did not receive. Menu-induced pause and the saved run’s logical day/summary phase must not be conflated, leaving Continue permanently paused or skipping a pending summary. [D05; D08–D09]

M1 already preserves elapsed play and live subsystem phase progress before a calendar exists. M2 adds the approved day clock and converts calendar deadlines from that coherent timeline. Existing continuation is extended, not replaced by independent drifting node timers. [M1; M2 §2]

Basis: [D02–D05, D08–D09]; [PF §§24.2, 25.4, 34.5]; [CR15]; [GDD §11].

**7.1  AUTHORITY AND SYNCHRONIZATION**

## 7. Gameplay time &amp; presentation

Gameplay time is the immovable authority. Presentation time is subordinate. Preserve the underlying simulation timestamp exactly, including sub-minute precision; never infer it from a clock label or restart independent subsystem timers on load. [D05]

### 7.1.1 Approved example

| Event | Gameplay time | Lift presentation |
| --- | --- | --- |
| Arrival begins | 10:00 | Theatre begins; bay/deck remain physically stationary. |
| Save | 10:02 | Arrival is partly complete. |
| Continue | 10:02 | Reconstruct an appropriate incoming presentation. |
| Scheduled arrival endpoint | 10:04 | Proceed to the next valid logical phase at the original deadline. |

The times are illustrative, not production cue lengths or a new day-rate setting. Replaying the whole journey while moving its completion later on every load is forbidden. Rewinding the world clock while retaining submissions or storage changes is also forbidden. Repeated save/load cycles must not accumulate timeline drift. [D05]

### 7.1.2 Allowed presentation recovery

Presentation may be reconstructed at an approximate offset, shortened or accelerated. A brief global simulation hold may be used to let presentation catch up, provided gameplay interactions and simulation-dependent systems are held together. That hold may add real-world loading time; it must not advance or rewind gameplay chronology, extend an event deadline, or give the player extra active gameplay time. [D05]

A saved phase records enough logical progress, original timing/deadline and commitment identity to recover without restarting completed work. The exact fields, numeric representation and per-phase animation/audio mapping remain technical choices. Saving only displayed HH:MM is insufficient. [D05]

### 7.1.3 Ordinary pause is not loading

Opening the ESC pause menu suspends the current session; closing it resumes from that point without reconstructing theatre. Approximate audiovisual recovery is for loading a saved run, not a shortcut every time the menu is opened. The pause and clock owners must not fight over elapsed time. [D09]

Basis: [D05–D06, D09]; [GDD §§5.2–5.3, 11].

**7.2  RECEIVING CONTINUATION**

## 7. Gameplay time &amp; presentation

The approved time separation extends Receiving; it does not replace its ownership and interaction rules. There is one stationary bay/deck and permanent player barrier, with a moving shutter and four-cue travel illusion. Existing committed content, private surfaces and normal TAKE remain authoritative. [PF §34; D05]

| Saved situation | Required logical restoration; audiovisual recovery is subordinate |
| --- | --- |
| SEALED_EMPTY / idle | Retain whether the lift is genuinely free or internally busy in outbound turnaround. IDLE alone is insufficient. |
| ARRIVAL / SEALED_READY | Restore incoming/committed cargo and original logical progress. No early reveal, item replacement or new batch identity. |
| REVEALING | Restore the original endpoint deadline and disable targeting/TAKE until the fully OPEN condition is satisfied. Resolve any necessary presentation catch-up without changing chronology. |
| OPEN | Restore fully OPEN with exactly the remaining items and accepted arrangement. OPEN waits indefinitely for successful unloading; no timer is added. |
| CLOSING / outbound | Retain drained active ownership and fixtures through remaining logical turnaround. Do not free capacity or promote FIFO twice, early, or only because a shortened clip ended. |
| Queued / Awaiting Lift | Preserve deposited FIFO and oldest-waiting admission, commitment identities and terminal dispositions. Loading is not a fresh return submission. |

### 7.2.1 Full turnaround remains a logical obligation

The previous accepted cue lengths and shutter contact timing remain the ordinary runtime baseline. A reconstructed clip may be shorter, but the saved logical departure must still complete before retirement and FIFO handoff. Conversely, late presentation must not silently move that logical event later. The phase-specific synchronization policy must reconcile both constraints explicitly. [PF §34.2; D05]

### 7.2.2 No hidden capacity or return simulator

One active plus two deposited queued batches remains the capacity. Uncollected deposited cargo persists across midnight. The existing explicit midnight hook affects only still-awaiting returns; the first clock integration supplies that event where applicable. Scenario-controlled arrival wiring does not implement Expedition travel, injuries or a real roster. [PF §§34.5–34.6; GDD §11; D01, D04]

Basis: [PF §§27, 34.2, 34.5–34.7]; [GDD §11]; [D04–D05].

**SCHEDULING CONTRACT**

## 8. Day clock &amp; midnight auto-save

### 8.1 Basic automatic day structure

M2 design is approved: retain 07:00–00:00 with 1 game hour = 150 real seconds, giving 42.5 active real minutes. Fixed services and provisioning boundaries are configurable. A later 06:00–10:00 preparation trial would also move breakfast to 10:00; it is not activated in M2. [D17; M2 §2]

Ordinary timed requests provisionally last three game hours (7.5 real minutes). Require opening &lt; deadline &lt; midnight; 20:59 is the latest whole-minute three-hour opening. The old 25–30-real-minute day is superseded for this trial. Pause and closure add no time. [D17; M2 §§2–3]

### 8.2 Ordered transition

| Order | Required behavior |
| --- | --- |
| 1 — Reach midnight | Stop normal active-day processing at the transition boundary. |
| 2 — Finalize / prepare | Resolve that day’s simplified request results and prepare next-day state. Preserve supplies, storage organization, deposited cargo and prior commitments. |
| 3 — Save | Invoke the same save operation used manually, once the transitioned state is coherent. |
| 4 — Present | Show the paused summary; continue into the already-prepared next day without resolving midnight again. |

Hard midnight cutoff: only admissions strictly before 00:00 protect upstream cargo. Resolve remaining waiters before same-time capacity release; deposited cargo survives. Apply outcomes and prepare the next day before auto-save/report. REPORT_PENDING reload displays existing results, never recalculates them; acknowledgment only releases pause. [D18–D19; §18.4]

### 8.3 Ordinary auto-save failure

Attempt the same preservation operation once after coherent night resolution. On failure, keep the previous valid continuation and display a warning on the normal report; Begin Day remains available. No Retry Save, Continue Unsaved dialog, retry loop or new recovery framework is added to M2. Save &amp; Exit still stays paused on failure. [D19; M2 §6.4]

Basis: [D04–D06, D09]; [GDD §§3.3, 5.2–5.5, 11.5]; [PF §34.5].

**PLAYER-FACING FOUNDATION**

## 9. Minimal menu, pause &amp; clock HUD

### 9.1 Barebones launch and ESC menu

| Context | Actions / behavior |
| --- | --- |
| Launch | New Run; Continue restores the single active compatible save. With no valid save, Continue is greyed out and cannot be selected. |
| In-game ESC | Resume; Save &amp; Exit; New Run. |
| Resume / ESC again | First ESC closes a contribution panel; a later distinct ESC opens the pause menu. Menu Resume/ESC releases only its own pause. |
| New Run with an existing save | Confirm before replacing the single slot. Continue must never perform this reset. |
| Save &amp; Exit succeeds | Save the current coherent state, then leave the active run and return to the launch menu. |
| Save &amp; Exit fails | Stay paused in the current run and show an error instead of leaving it. |

Use a conventional centered, minimal ESC menu over a semi-transparent dark overlay. Subtle blur is optional only if inexpensive under the retained Compatibility renderer. Continue is disabled and visually greyed out with no valid saved run, at launch and wherever the control appears. The agreed player saving control is Save &amp; Exit; a separate Save/Quick Save is not part of M1 or the intended final Ironman-style player UI. Do not introduce rollback slots through timestamped filenames. [D08–D09, D11]

### 9.2 ESC is a full gameplay pause

Pause the authoritative clock, scheduled events/deadlines, player movement and interactions, transfers, Receiving logical progression, shutter animation and its associated audio. Resume the existing theatre rather than rebuilding it. Zoning retains its established pause behavior; menu/modal ownership must prevent one overlay from unpausing another. Ordinary request handling does not pause time. [D09; GDD §5.3]

### 9.3 Persistent development digital clock

From the clock stage, show a compact digital day/time HUD independently of room, viewpoint or any physical clock asset. Read the authoritative clock directly; do not maintain a second timer. Seconds are available for development timing checks, with a clear paused/time-acceleration indication where applicable. Placement and the earlier large mock clock were illustrative, not locked UI. [D06]

Later in-world clock objects can read the same source. Removing or hiding the development overlay must not require changing simulation chronology. Physical clock assets and their room installation are not prerequisites for timing validation. The development overlay is an explicit MVP exception to the otherwise restrained persistent-HUD design. [D06; GDD §16.2; VDD §§7, 14]

Basis: [D06, D08–D09]; [GDD §§5.3, 16.2]; [VDD §§7, 14].

**CONTROLLED INPUTS, PERSISTENT RUN**

## 10. Authored multi-day scenarios

The scenario describes what should happen. The saved run records what has happened. Continue never regenerates starting supplies, clears request progress or replays already-triggered events. [D02, D07]

| Authored input | Boundary |
| --- | --- |
| Initial conditions | One-time starting supplies and supported storage setup for New Run; not a repeating daily grant. |
| Incoming deliveries | Specific committed batches and event times, using existing Receiving presentation and ownership. |
| Medical requirements | Configured per-day requirements; no patient model is implied. |
| Kitchen requirements | Food/Hydration targets at meal events; no actual kitchen consumption simulation is needed. |
| Loadout requirements | Team-labelled five-lane requests and capacity values; no underlying population or travel roster is required. |
| Progression | A deterministic multi-day sequence with deliberate variations in scarcity and competing obligations. |

### 10.1 Separate scenario data from runtime state

M2 captures the approved finite scenario and its revision into the run. Event occurrences use stable identities, exact deadlines and issued-state records. Continue does not adopt edited schedules or reissue cargo. Earliest initiation/departure and stable textual IDs resolve meaningful ties (§18.2). [D18, D20; M2 §§3, 5]

Supplies are not reset per launch or day, topped up whenever the player runs low, or rerolled merely because a batch is awkward to present. Incoming assortment and all numerical targets are testing inputs, not final economy specifications. Configure unsupported-category inflow deliberately so Fuel/Morale/Electronics accumulation is not mistaken for evidence about a three-consumer economy. [D01–D02, D07]

### 10.2 Fallback, not parallel implementation

Authored scenarios are sufficient initially. A parameterized generator controlling quantities, Bulk, Utility and timing is a fallback only if authored scenarios prove too rigid. It should feed the same definitions, requests and delivery infrastructure. No generator, live-balancing dashboard or full Expedition outcome model is part of this edition’s initial build. [D07]

M2’s three-day Medical/supply fixture and end-of-content behavior are approved as mechanical test inputs (§18.3), not final balance. Larger combined scenarios, future-demand visibility and M4 capacity/overfill remain later decisions. [D20; P01]

Basis: [D01–D03, D07]; [GDD §§6, 8, 11, 19]; [H14 §5].

**SHARED COLLECTION, SIMPLE RESULTS**

## 11. Medical &amp; Kitchen consumers

### 11.1 Medical first

Accepted M1 uses MedicalInterface with one initially open target-12 request and no deadline. F opens/closes the centered panel; distinct E submits one selected item, using contextual Medical Utility. Full fulfillment closes the panel and hides both action cues; the result remains saved but cannot be reopened at the station. M2 replaces indefinite activation with timed occurrences and report history. [M1; D16; M2 §4]

There are no actual injured scavengers consuming supplies, patient cohorts, triage, treatment stages, Meal-related treatment rolls or mortality checks in this initial consumer. Those remain later GDD behavior. The earlier suggestion to start with a treatment-eligible Light-injury cohort was superseded by the developer’s simplified-consumption direction. [D01; GDD §13]

M1’s test data add Medical-context Utility to antibiotics (5), bandages (3) and medkits (8). They are provisional fixture values, not P01’s proposed scale formula or a catalogue rebalance. New Run seeds once; Continue retains spent stock and request state. M2 uses the same collector for scheduled openings and expiry. [M1; M2 §5]

### 11.2 Kitchen second

Kitchen (M3) uses the existing KitchenInterface placeholder, opening the same request/contribution panel with separate Food and Hydration lanes. It reuses the collector, per-item E submission, committed-versus-preview segments, ineligible warning, caps/waste and save mechanisms. An item may affect at most one active Kitchen lane and cannot be auto-chosen from the carried bundle. Requests follow the established meal anchors once the clock exists; targets remain scenario-authored rather than population-derived. [D01–D02, D13–D15; GDD §12.2]

Preserve separate Food/Hydration accounting and partial fulfillment. The GDD defines daily Meal Coverage as the average of the six capped lane coverages across three meals; an aggregate may be reported without claiming that treatment or Workshop effects are operating. Ration conversion, overnight physical ration output and output-capacity blocking remain later work. [GDD §§12.2–12.3]

### 11.3 Real destinations, not floating test sinks

MedicalInterface and KitchenInterface remain the departmental proxies; DispatchWorkSurface is reserved for M4. F opens/closes the request panel, E contributes, and ESC closes it before opening the pause menu on a later press. No full room art, geometry, extra storage, staff simulation or distant menu-only sink is implied. [D13–D16; M1]

The reuse test is concrete: adding Kitchen should configure another destination and another lane, not fork the Medical transaction implementation. Future dynamic demand and real outcomes attach at the agreed boundaries. [D02]

Basis: [D01–D04]; [GDD §§4.8, 8, 12–13]; [VDD §§16, 18–19].

**THE THIRD COMPETING DEMAND**

## 12. Expedition Loadout consumer

### 12.1 Included behavior

Create scenario-defined team-labelled requests with Food, Hydration, Medical, Weapons and Protection lanes. Use the common collector and persistent request state, while tracking submitted items’ Outgoing Bulk and the configured Team Load Capacity. The initial team label is a request context, not evidence that a scavenger roster exists. [D01–D02]

Retain the GDD relationship: Return Capacity = Team Load Capacity − Outgoing Bulk. Accounting for this cost makes bulky and compact items meaningfully different at submission. It does not require generating return loot or applying a capacity-to-haul model now. All submitted loadout items are spent; weapons and tools do not automatically reappear after a fictitious journey. [GDD §10.1]

### 12.2 Shared system, destination-specific policy

All three consumers use one request/transfer/persistence path with destination-specific eligibility and targets. The shared proposed default is cap-and-waste on whole-item submission: only remaining lane Utility is credited; no surplus is retained, no exact-sum constraint is imposed, and no held-E batch transfer is allowed. A loadout still charges the item’s full Bulk and rejects submissions exceeding its remaining Team Load Capacity. The GDD’s historical modest loadout overfill/bonus remains a separate M4 choice: the developer currently leans toward removing it for consistency, but this has not yet been promoted as final M4 policy. Keep that policy configurable; do not implement a bonus prematurely or silently treat it as cancelled. [D14; P01; GDD §§6.3, 8.4, 10.2–10.4]

### 12.3 Explicitly outside this consumer

No population-derived team formation, actual dispatch journey, destination selection, duration calculation, injury/death/recruitment model, return-time calculation or provisioning-derived incoming haul is required. The 07:00–09:00 request window can close/finalize a loadout without launching those systems. Scenario-controlled deliveries remain independent test inputs. [D01–D02; GDD §§9–10]

Do not display an invented improvement to injuries, loot or survival merely because a lane is full. The initial evidence is what was spent, what requirements were met, and what remains for other demands. Future OutcomeProfiles consume that result when their systems are implemented.

### 12.4 Validation threshold

With all three consumers present, test the same finite stock over several days and application sessions. Observe Medical-versus-loadout supply pressure, meals-versus-future-provisioning decisions, equipment/Bulk choices, and whether layout reduces retrieval cost. The test should permit deliberate shortfalls; it should not imply that every request must always be filled. [D01–D02]

Basis: [D01–D02]; [GDD §§6.3, 8.4, 9–10, 19–21].

**DESIGN ORDER, NOT EXECUTION AUTHORIZATION**

## 13. Delivery stages &amp; dependencies

Stage labels M1–M5 are document tracking identifiers. They do not rename accepted Receiving stages or imply a new review hierarchy. Each slice receives a bounded implementation brief after its unresolved details are settled. [D02–D09; WG]

| Stage | Deliverable | Exit evidence |
| --- | --- | --- |
| M1<br>Persistent Medical | Accepted: MedicalInterface, F panel toggle/E one-item contribution, cap-and-waste, single-slot continuation and full pause; exact player/storage/Receiving recovery. | HUMAN-PROMOTED / PUBLISHED / CLOSED. Independent ACCEPT and successful final human checks; see §15. |
| M2<br>Clock &amp; midnight | Accepted: provisional 42.5-minute day, shared clock, timed Medical/authored cargo, hard cutoff, applied-results report and same-path midnight save. | HUMAN-PROMOTED / CLOSED. Technical verification, independent ACCEPT and all final human playtests passed; see §15. |
| M3<br>Kitchen | Food/Hydration requests at meal times through the existing collector and persistence. | Shared-code reuse, lane/cap behavior, partial fulfillment and saved request progression. |
| M4<br>Loadout | Team-labelled five-lane requests, Outgoing Bulk/capacity and approved destination policy; no Expedition simulation. | Cross-destination competition, exact expenditure and continued identities/accounting after restart. |
| M5<br>Combined scenarios | Authored multi-day test sequence using all three consumers, continuing stock and organization. | Developer and later unfamiliar-player observations of reserves, tradeoffs, retrieval and causal understanding. |

### 13.1 Dependencies, not unrelated cleanup

M1 reached and resolved the bounded CF-01/R-04 scene-lifetime issue and the relevant identity/restore dependencies. M2 preserves that accepted work while extending timing and request history. No R-01–R-03 re-audit, relighting, asset replacement or unrelated cleanup is implied. [M1; §16]

### 13.2 Technical checkpoints versus gameplay claims

M1–M4 each establish their own correct operation. The broader allocation claim is reserved for M5. The full Systems MVP target in the GDD remains larger than M5 and includes later real systems and stronger saves; completing this foundation does not complete that target. [D01–D02; GDD §20.2]

Basis: [D01–D09]; [CR15]; [GDD §20.2]; [WG; ER14 §§11–12].

**14.1  PERSISTENCE AND TRANSACTIONS**

## 14. Acceptance &amp; evidence plan

Acceptance checks below span stages. M1 and M2 execution, independent acceptance and human promotion are recorded in §15; later-stage checks remain future work. Distinguish direct/synthetic fixtures from native input, held rendering and human audio assessment. [M1; §15; M2 §10]

| Check | Expected observation |
| --- | --- |
| New Run versus Continue | Starting supplies occur once; loading does not re-seed the wing or reissue a committed delivery. |
| Partial Medical save | Supply part of a request, save, exit, reopen. Remaining items, exact contribution and unresolved request match. |
| Organized-storage round trip | Restore stack membership, reservations, orientation, zone arrays, erased cells, names, carried slots and selection; no auto-packing or silent migration. |
| Rejection and credit | Closed/full/ineligible or failed submission leaves the item and request consistent; accepted transfer credits once and cannot be retried as fresh ownership. |
| Restoring changed zoning | An existing stored item survives even where cells were subsequently disabled or reassigned. Future placement still obeys current zoning. |
| Live Receiving cargo | Save representative incoming/OPEN/closing/departing states and retained FIFO/upstream data. Restore remaining exact cargo, gates, ownership and original logical progress. |
| New identity after restart | Keep an old haul, save/relaunch, then issue a genuinely new delivery. IDs are disjoint while saved commitments keep their IDs. |
| Ordinary save/load errors | No false success or silent new run; Save &amp; Exit remains paused on failure. No crash or anti-tamper claim is added. |
| Two-step contribution preview | F opens/closes without consuming; distinct E commits one item after preview. Held input does not repeat. Invalid selection shows red/no gain; full completion closes and suppresses cues. |
| Player/ladder continuation | Preserve accepted exact player position/camera, selected held item and same-ladder attachment/height through close/reopen. Transient UI cannot submit or unpause on load. |

### Evidence classes remain separate

A serialization round-trip assertion is not a rendered scene continuation test. A deterministic direct-handler test is not native keyboard/mouse testing. A human confirmation applies to the scenarios actually tried, not an exhaustive guarantee. Store exact source/engine/mode context with the focused result record. [ER14 §§7–8, 12]

Basis: [D02–D05, D08–D09]; [GDD §§7, 11, 18.5]; [ER14 §§7–8, 12].

**14.2  TIME, PAUSE AND COMBINED PLAY**

## 14. Acceptance &amp; evidence plan

| Check | Expected observation |
| --- | --- |
| Midnight, summary, reload | Transition completes once, auto-save uses the manual save path, and Continue from the summary does not repeat day resolution or next-day setup. |
| Repeated mid-phase load | Using the approved 10:02/10:04 example or equivalent actual timing, repeated saves/loads do not move the clock or endpoint deadline. |
| Pause during lift work | ESC suspends clock, input/transfers, logical lift progress, shutter and cue. Resume continues the same theatre without catch-up. |
| Zoning and menu interaction | Closing one paused overlay does not resume gameplay while another still owns a pause. No accidental submission occurs through the menu. |
| Clock visibility | The development digital clock remains available independent of room and reads the authoritative day/time, including pause indications. |
| Shared consumers | Kitchen and Loadout use the same submission and persistence contracts. Their different lanes and capacity/cap rules do not duplicate or double-consume inputs. |
| Multi-day continuity | Today’s expenditure reduces tomorrow’s available stock; new supplies occur only through authored events, not automatic top-up or restart. |
| Allocation playtest | Observe chosen shortfalls, retained reserves, retrieval friction and organization changes with all three consumers. Do not claim real treatment or expedition balance. |

### 14.3 A proportionate completion record

For each slice, record the source revision, change boundaries, executed checks and actual outputs, relevant reused evidence, human findings, unresolved limits and disposition. Keep one concise result/playtest record with supporting raw logs. Retain deliberate rejection signatures by exact case; an unrelated error is not excused by an old warning. [WG; ER14]

Do not turn this design task into an engine rerun. During implementation, focused tests and one appropriate contextual review are the default; later behavioral corrections receive affected follow-up checks. Unchanged game tests are not repeated solely for documentation or packaging. [WG]

Basis: [D02–D09]; [WG]; [ER14 §§7–12]; [CR15].

**LIVING EVIDENCE HOME**

## 15. Active MVP progress record

Current phase status follows established evidence; detailed dated records preserve the original runs and limits. Prototype Findings remains historical. [D10]

| Workstream | Status at 17 October 2026 | Evidence / next boundary |
| --- | --- | --- |
| Prototype foundations | HUMAN-PROMOTED in recorded scopes | PF retained as historical evidence; no new acceptance task. |
| Pre-MVP review + repairs | HUMAN-PROMOTED / PUBLISHED | R-01–R-03 accepted; bounded R-04 subsequently repaired within M1. |
| MVP foundation contracts | CONFIRMED; v0.3 active master | D01–D21; v0.3 published at 2cad0d7. |
| M1 persistent Medical | HUMAN-PROMOTED / PUBLISHED / CLOSED | 6c56edf → a7b764e → 36d527d; independent ACCEPT and successful human play. |
| M2 clock / midnight / HUD | HUMAN-PROMOTED / CLOSED | 524edf1 → c7bbf44; ACCEPT and final human pass; §15.2. |
| M3 Kitchen | NOT IMPLEMENTED | Shared collector; later request and combined-scenario testing. |
| M4 Expedition Loadout | NOT IMPLEMENTED | Capacity/overfill and morning-window tuning remain later. |
| M5 combined allocation | NOT RUN | Requires persistent three-consumer scenarios; no economy conclusion. |

### 15.1 Accepted M1 implementation and publication

Original M1 6c56edf and UI follow-up a7b764e received independent ACCEPT for the complete base-to-final change. The reviewer established no important new defect; its isolated admission/resave probe reported zero failures and exit 0, without repeating prior suites. The developer then passed all five final gameplay categories and HUMAN-PROMOTED M1. [M1]

Publication 36d527d follows the two accepted commits. Prior checks cover exact player/ladder/storage/cargo recovery, Medical previews/credit, F/E/ESC, auto-closure and New Run. These are attributed results, not fresh tests by this close-out. CF-07 persists. [PUB16; D16]

### 15.2 17 October 2026 M2 human promotion

Base 2cad0d7 → implementation 524edf1 → reviewed final c7bbf44. Design v0.2 was approved; the implementer reported technical verification. Independent ACCEPT found no BLOCKER or IMPORTANT issue; its bulk-versus-32,998-fractional-step probe reported 19 checks, zero failures, exit 0. The developer reported all final playtests passed without unexpected behavior and HUMAN-PROMOTED / CLOSED M2. These are attributed prior results, not reruns.

Publication is authorized; PUBLISHED requires safe linear fast-forward and live remote confirmation, recorded in the executor’s final report. Detailed scope, prior failures and retained CF-07/certificate/Ironman limits: docs/testing/m2-day-clock-midnight-validation-2026-10-17.md. M3–M5 remain unimplemented; no full-game durability or economy claim is made.

Basis: [D10]; [PF §1]; [CR15; R15]; [ER14 §§8, 10–12].

**16.1  DEPENDENCIES REACHED BY THIS FOUNDATION**

## 16. Carry-forward register

All CF-01–CF-24 references are retained. Their current status is reconciled with published M1: bounded lifetime repair, ordinary restoration, run identities, contribution transactions and the minimal Medical proxy are accepted. Broader scopes remain live. CF-13 now also records the full-game continuity/randomness clarification, not an M2 implementation. [M1; D21]

| ID / source | Carried-forward obligation | Current disposition |
| --- | --- | --- |
| CF-01<br>CR15; ER-RESULT R-04 | Reflection frame-wait work can resume after its owner is freed. Timer-cooldown deletion was quiet; no item loss or persistent GPU failure was established. | Resolved in bounded M1 lifetime scope; accepted and published. Preserve frame-settling/coalescing behavior; no rendering redesign. [M1] |
| CF-02<br>PF §§16.5, 25.4; GDD §18.5 | Full-game persistence was not established by batch snapshots. Stored placement orientation must survive instead of being recomputed from current Front. | Ordinary exact continuation accepted in M1. M2 adds calendar/request/report state; full-game continuous durability remains CF-13. |
| CF-03<br>CR15 R-03; D02–D03 | Process-local debug namespace uniqueness does not alone ensure new delivery identity after application restart. | Run-scoped identity and saved allocator accepted in M1. M2 must preserve these across timed occurrences and replay. |
| CF-04<br>ER-RESULT §4; CR15 | Carrying mutation signals can precede transfer success/rollback and cannot authorize irreversible credit. | M1 receipt-before-notification transaction accepted. Preserve the enclosing success boundary for all later consumers. |
| CF-05<br>PF §34.5; GDD §11 | Actual return callers must use upstream admission, lifecycle results/signals and the explicit midnight event; deposited capacity stays 1 + 2. | Preserve 1+2 capacity, fairness and authoritative admission. M2 adds the approved strict midnight ordering; real expeditions remain later. |
| CF-06<br>PF §§19.4, 24.3; VDD §§16, 18–19 | Playable service spaces and routes are approved, not fully furnished request interfaces or final gameplay travel balance. | Minimal Medical proxy and readable contribution panel accepted in M1. Kitchen/Dispatch functions and full furnishing remain later. |

A dependency entering scope is not retroactive demotion of the accepted prototype. The next handoff must identify exactly which owning paths it changes and the focused evidence required. [WG; ER14 §11]

Basis: [PF §§16, 19, 24–25, 34]; [GDD §§7, 11, 18.5]; [VDD §§16, 18–19]; [ER-RESULT; CR15]; [D02–D05, D10].

**16.2  KNOWN TECHNICAL AND CONTENT DEBT**

## 16. Carry-forward register

| ID / source | Disposition preserved | Revisit boundary |
| --- | --- | --- |
| CF-07<br>PF §§3–4, 7, 14.5, 34.7 | Held/HUD presentation remains provisional; held-view material-null diagnostics were not repaired. Earlier live SubViewport lighting isolation failed, not the technology itself. | Supported-renderer reproduction, visual readability failure or a relevant rendered test. Normal prior human play remains separate evidence. |
| CF-08<br>PF §§33.3, 34.3 | Accepted one-machine probe cost: about 3.56 s added cold initialization, 125–132 ms first cargo refresh, 8–10 ms later refresh. No fresh profile here. | Credible workload, repeated loading or other-hardware impact. No speculative performance rewrite. |
| CF-09<br>PF §33.3 | Pre-existing gallery_a_fixture_front navigation failure; unrelated to reflection integration. | A relevant route/installation change or observed gameplay obstruction. Do not label it repaired. |
| CF-10<br>PF §§25.6, 33.3, 34.7 | Historical unrun editor/selection captures remain NOT RUN; scoped certificate-store, scan-aborted and shutdown RID/ObjectDB diagnostics retain their source context. | Changed signatures or affected editor/runtime workflow. No blanket suppression or universal error-free claim. |
| CF-11<br>PF §§24.2–24.3, 25.5–25.6 | Gloves loot_000034 and Pants loot_000036 remain blocked. Current pool is 40 eligible of 42 definitions; Fuel is reconciled/eligible. | Separate source/pose/content approval. Scenarios must not silently enable blocked items. |
| CF-12<br>PF §§12.3, 24.3, 25.6, 26.3 | Deep/opaque shelf readability, thin-item targeting, context-specific ladder ergonomics and optional four-way display rotation remain limited/open. Book edge excursion/tolerances are recorded accepted evidence, not a new bug. | Actual content/installation or UX evidence. No universal ladder/depth rule or broader traversal system follows. |

CF-12’s accepted calibration example is the Book 2×2 override’s measured 0.289 mm front-edge excursion within the documented 0.5 mm visual-bounds tolerance; fixture/grid calibration retains its separate 0.02 mm tolerance. Preserve the distinction instead of widening all tests. [PF §25.6]

Basis: [PF §§3–4, 7, 12–14, 24–26, 33–34]; [ER-RESULT §§2–5].

**16.3  CONFIRMED LATER SYSTEMS AND OPEN FEATURES**

## 16. Carry-forward register

| ID / source | Work retained | Relationship to this foundation |
| --- | --- | --- |
| CF-13<br>GDD §§5.6, 18.5; PF §§16.5, 34.7 | Full-game continuous game-state preservation, one advancing continuation per run, journal/rotating recovery and an ideal 2–3-real-second loss target. [D21] | Later extension of the SAME save system. Recovery copies are not selectable history. Eventual independent runs remain distinct from rollback saves. See §19. |
| CF-14<br>GDD §§9–10; PF §34.7 | Actual teams/population, provisioning-driven outcomes, timing, injury/death/recruitment, real returns and Dispatch/scavenger monitoring. | Loadout implements only the consumer side now. Full simulation remains later; no fake outcome benefits are added. |
| CF-15<br>GDD §§12–13; PF §34.7 | Real Medical demand/triage, Light/Severe treatment, Meal Coverage effects, complications and population consequences. | Controlled demands and simple results replace none of these rules; future producers/resolvers use the shared foundation. |
| CF-16<br>GDD §§12, 14–15, 20; PF §§19.4, 20.4 | Ration production/output blocking; Bunker Ops lanes/outages; salvage/incineration; Workshop and socket upgrades. | Later consumers/conversions/progression, not needed to establish the first three-way allocation test. |
| CF-17<br>PF §§19.4–19.5, 20.4; GDD §§7.5–7.6 | Player text labels; true containers/specialist storage; conditional unit/socket movement; initial stock and final capacity/progression. | Preserve supported surface names now. Detailed labels/movement/containers are not implied by save support. |
| CF-18<br>PF §§12.3, 14.5, 24–26 | Manual under-base insertion, multi-column packing, crouch and expanded display-rotation UX. | Remain separate deferred/open work. Existing mixed-stack automatic rejection and two-state packing stay intact. |
| CF-19<br>GDD §§19–21; PF §§20.4, 34 | Final loot bounds, balance, pacing, route costs, shipped deck/fixture roster and larger-scale item/furnishing validation. | Authored scenario values are test inputs. Current dimensions and reach remain the accepted baseline, not final balance. |

Optional condition/quantity, contamination, contextual PA and ambient-dog scope retain their GDD classifications; they are not prerequisites here. Contamination remains outside the Systems MVP. General climbing, free furniture placement, exterior exploration and combat are not silently promoted by the phase change. [GDD §§2, 6.7–6.8, 20.4–20.5]

Basis: [PF §§7, 12–16, 19–20, 24–26, 34]; [GDD §§2, 5–15, 18–21]; [D01–D03, D10].

**16.4  AUTHORING LIMITS AND HISTORICAL SUPERSESSIONS**

## 16. Carry-forward register

| ID / source | Retained disposition |
| --- | --- |
| CF-20<br>PF §§32.2, 34.3; VDD §34.7 | Dispatch furnishing and lighting, neighboring Backlog work and Receiving–Backlog sill material remain adjacent work. Cleaning-corner acceptance anticipated Dispatch spill; that spill is not implemented. |
| CF-21<br>PF §34.3; VDD §§34.7–34.8 | Faint residual shadow pattern was tolerated; excluded brace-junction artifact remains outside that fix. Pixel-identical 0.30/0.40 probe comparison is technically unexplained, although actual metallic appearance was human-accepted. |
| CF-22<br>PF §34.3; VDD §34.7 | W1 saved range 2.5 m versus runtime 1.8 m, attenuation −0.5, is a disclosed source/runtime precedence issue—not automatic authorization to retune. Ordinary numerical authoring remains adjustable. |
| CF-23<br>PF §§28, 32.5; VDD §§34.1–34.6 | UV is default; triplanar is reasoned opt-in. Separate 11 conventional wear presets and 16 scalar patterns retain their scoped uses; roughness.red patterns do not imply substrate roughness changes. Source approval is not scene-placement approval. |
| CF-24<br>PF §§2, 17, 28; H14 §13 | Preserve source provenance, licensed-local assets, configured guarded roots and ignored imports/caches. A Git checkout is not a complete asset archive. No new sourcing, redistribution decision or pipeline migration is authorized. |

### Do not resurrect closed or rejected work

Resolved/promoted: the recorded storage/Fuel/pose/ladder/rack and EAF/C1/Stage C foundations, intentional lighting, R-01–R-03, and M1’s bounded CF-01/R-04 repair. Historical pending text does not reopen them. M1’s acceptance is not a claim that all remaining rendering or full-game persistence work is complete. [PF; M1; PUB16]

Rejected/parked: irregular frozen piles remain rejected; C1A remains parked/unpromoted. Old room/deck dimensions, proof reach values, earlier palettes and A30WS practical/global settings are not current production targets. Initial wear counts and hidden alternatives are dated snapshots, not restoration quotas. Removed Road Dust placements, obsolete monitors and proposal infrastructure stay retired. [PF §§27–34; VDD §34]

Basis: [PF §§2, 14, 17, 24–34]; [VDD §§7, 34]; [H14 §§9–13]; [CR15]; [D10].

**APPROVED DESIGN / REMAINING DELIVERY CHOICES**

## 17. Current decisions &amp; implementation boundaries

M1 remains accepted/published/closed. M2 specification v0.2 remains the approved design; implementation 524edf1 and final c7bbf44 are independently accepted and human-promoted (§15). M3 Kitchen is next, NOT IMPLEMENTED; P01 and final M4 overfill remain open. This close-out introduces no new design gate. [D16–D21; M2]

| Decision | Current disposition / remaining boundary |
| --- | --- |
| Save foundation | M1 accepted. Existing exact codec, snapshot and save service extend to M2; no duplicate preservation system. |
| Player / storage recovery | M1 accepted: exact pose, ladder height, held selection and committed storage. No base fallback required. |
| Restore / lifecycle | M1 accepted: no reseeding, run identities and bounded R-04 repair. M2 must retain them. |
| Menu / controls | Accepted: F panel toggle; E single contribution; ESC panel-first then pause; one Save &amp; Exit; no selectable save history. |
| Timed Medical | M2 approved: three-hour occurrences, half-open acceptance window, fulfilled/expired history and automatic cue closure. |
| Cap / Utility policy | M1 cap-and-waste accepted; M3 reuses it. M4 overfill remains open. P01 estimator is still only a proposal. |
| Clock / ordering | M2 approved: 150 real seconds per game hour; causal prerequisites; independent closures first, initiation/departure then ID. |
| Lift / midnight | M2 approved: strict-before-midnight upstream admission; deposited cargo survives; no overnight mechanical fast-forward. |
| Report / auto-save | M2 approved: outcomes then same-path save then paused report; acknowledgment changes no outcome; warning only on failure. |
| Scenario / compatibility | M2 approved: three authored days, no refill after exhaustion; new schema/scenario, old M1 saves retained but not silently converted. |
| Full-game randomness | Settled principle (§19): continuous Ironman state, early natural commitment, narrow residual loss; incidental uncommitted rerolls tolerated. |

Next: M3 Kitchen, NOT IMPLEMENTED; no M3 design or implementation starts in this publication. M2 is HUMAN-PROMOTED / CLOSED (§15). Full-game continuous Ironman preservation, journaling, rotating recovery and the ideal 2–3-real-second loss target remain NOT IMPLEMENTED; M2’s midnight and Save &amp; Exit share the existing service. [D20–D21; M2 §§9–12]

Basis: [D02–D15; P01]; [GDD §§6, 8, 10, 19–21]; [ER14; WG].

**18.1  APPROVED M2 / ACCEPTED SCOPE IN §15**

## 18. M2 approved design

M2 extends accepted M1 with authoritative day/time, timed Medical, authored return attempts, a development clock, a resolved-results report and midnight auto-save. It does not build Kitchen, Loadout, patients, actual expeditions or continuous Ironman durability. Detailed authority: M2 specification v0.2. [D17–D20; M2 §§1–2]

### 18.1 Clock and calendar

| Setting | Approved initial behavior |
| --- | --- |
| Active day | 07:00–00:00; 17 active in-game hours. |
| Rate (provisional) | 1 game hour = 150 real seconds; 24 game seconds per unpaused real second; 42.5 real minutes per active day. |
| Ordinary request | Three game hours = 7.5 real minutes; opening &lt; deadline &lt; midnight. A whole-minute opening at 20:59 is valid; 21:00 is not. |
| Future morning trial | 06:00–00:00 day; 06:00–10:00 loadout; breakfast moves to 10:00. Retained for M4/M5, not enabled in M2. |
| Pause / closure | No time passes while paused, in a report, loading or outside the application. Calendar labels never maintain their own timer. |

One owner supplies active elapsed simulation time and calendar coordinates. At normal speed the 24× calendar conversion does not speed up player movement or lift audio. Record the rate/configuration with the run so reloading cannot reinterpret remaining deadlines.

The midnight calendar jump does not simulate seven unattended hours of mechanisms. Preserve in-flight lift work and its remaining duration; continue it when the next day is released. No automatic unloading, stock cleanup or extra FIFO retirement follows from the calendar jump. [M2 §§2.2–2.3]

These are approved design choices, not executed tests or permanent economy tuning.

**18.2  ORDERED TIME / CAUSAL OWNERS**

## 18. M2 approved design

### 18.2 Events and request boundaries

Causally connected operations retain their prerequisites in their existing owners. Last TAKE, closing, full outbound turnaround, retirement and FIFO promotion form a chain; a generic schedule must not give queued cargo an unrelated arrival-to-OPEN appointment. [D18; M2 §3]

| Coincidence | Required ordering |
| --- | --- |
| Independent closures / activations | Close due events before activating new events at the same exact timestamp. |
| Multiple closures | Earliest actual initiation first; if equal, lowest stable ID. Definition-load time is not initiation. |
| Simultaneous returns | Earliest actual departure first; if equal, lowest stable ID. Auto-dispatch can produce equal departures. |
| New arrival / existing waiter | Existing older Awaiting Lift commitments retain priority; no queue-jumping. |
| No semantic priority | Use stable case-sensitive, zero-padded textual IDs and ordinal order, not node or dictionary iteration order. |

Process every timestamp crossed by a time advance, including large test steps. Split at boundaries so all affected owners reach the same time. Settle logically due pre-midnight causal work before applying the cutoff; a delayed callback must not move its effective time across midnight.

A request accepts while opened_at ≤ now &lt; deadline. At the exact deadline, expiry wins over E: no item is consumed. Fulfilled or expired requests close the panel and cues. Preserve each occurrence’s opening, deadline, receipts, closure reason and result; later requests use new identities. An old fulfilled request’s scheduled expiry is inert.

Allow only one active Medical request; reject overlapping authored windows, but allow adjacent windows under close-before-open ordering. Retain partial/zero expired results for the report. This extends M1’s fulfilled-only closure rather than redefining its accepted behavior. [M2 §§2.4, 3–4]

Midnight: still-Awaiting cargo forfeits before same-time capacity release; only admission strictly before 00:00 protects it. Deposited cargo and FIFO survive.

**18.3  CONTROLLED MULTI-DAY INPUTS**

## 18. M2 approved design

### 18.3 Approved mechanical scenario

Capture the selected finite scenario, manifests and revision into the run at initialization. New Run creates the existing authored starting palette once. Continue restores occurred events and existing commitments rather than replaying definitions or adopting edited targets. These are test inputs, not final balance. [D20; M2 §5]

| Day | Medical window / target | Controlled incoming manifest |
| --- | --- | --- |
| 1 | 07:00–10:00; target 12 | 08:00 — one medkit, loot_000028. |
| 2 | 09:00–12:00; target 12 | 12:00 — one antibiotics, loot_000025, and one bandages, loot_000026. |
| 3 | 17:00–20:00; target 12 | 19:00 — one medkit, loot_000028. |

Use accepted M1 Medical overrides: antibiotics +5, bandages +3, medkit +8. No new item catalogue pass, footprint change or formula-based rebalance is authorized. Day 2’s arrival cannot retroactively rescue the request that expires at the same time. Day 3 tests later activation and reserves.

Each new cargo occurrence receives one namespace and deterministic preparation. Submit it through AwaitingLiftAdmission.submit_return(...) with a stable synthetic return label. Capacity-full pressure keeps that commitment upstream. Preparation failure is an error, not permission to reduce or reroll cargo. M2 does not infer a real expedition roster.

After the third authored day, keep the clock and existing run active but create no further requests or deliveries. Show “Authored scenario complete.” Do not loop supplies, reset inventory, declare victory or fabricate survival failure.

Dedicated fixtures test same-time returns, a full 1+2 deposited queue, Awaiting Lift and the midnight edge separately from this normal scenario. Validate controlled return attempts no later than the configured latest-return anchor, initially 23:40; later admission/presentation may occur after that anchor.

The later configurable generator remains a fallback only if authored scenarios prove too rigid. No new player time-skip control is included in this first clock slice. [M2 §§5, 7]

**18.4  RESOLVE FIRST / REPORT SECOND**

## 18. M2 approved design

### 18.4 Midnight, report and automatic preservation

The report describes an already-applied transition. Accepting, closing or reopening it never triggers resolution, changes outcomes or consumes another item. Midnight saving is triggered by coherent resolution, not report acknowledgment. [D19; M2 §6]

| Order | Behavior |
| --- | --- |
| 1 — Reach boundary | Finish logically due work before midnight; block input and hold the night-transition pause. |
| 2 — Cutoff | Forfeit still-Awaiting commitments before same-time capacity release. Settle preserved deposited mechanics without reviving forfeits. |
| 3 — Resolve | Aggregate old-day Medical results and Receiving admission/forfeiture/backlog; retain exact physical organization. |
| 4 — Prepare | Mark Day D resolved; establish Day D+1 at configured start, including start-time occurrences, without overnight mechanical advance. |
| 5 — Preserve | Set REPORT_PENDING with the immutable report and prepared state; invoke the SAME save service once. |
| 6 — Present | Show End of Day D while paused. Begin Day D+1 only releases the already-prepared state. |

The first read-only report has Medical requirements, credit, unmet amounts and fulfillment/expiry, plus Receiving admitted/forfeited hauls and carried-over deposited backlog. It has no patient effects, tabs, history browser or speculative outcome benefits. The clock may show next-day start with a night-report pause indication.

A post-resolution load restores the report and prepared day without resolving again. A recovered pre-resolution snapshot legitimately reaches midnight again; fixed M2 inputs yield the same logical result. Report acknowledgment is saved presentation state, not a gameplay gate.

Auto-save failure: retain the last valid state on disk, show a concise report warning and allow Begin Day. No retry button/loop or Continue Unsaved dialog. Save &amp; Exit retains its existing fail-paused behavior. Measure resolution, capture, write and display latency separately; 2–3 seconds is the stated practical transition-response target, not the full-game loss window in §19. [M2 §6]

**18.5  CONTINUATION / PROOF BOUNDARY**

## 18. M2 approved design

### 18.5 Integration and required evidence

Extend M1’s existing codec, state snapshot and preservation service with clock/configuration, timed occurrence history, scenario progress, day resolution and report phase. Keep exact item/receipt identity, storage policy/pose, player/ladder and Receiving ownership. Do not create another automatic-save serializer. [M2 §8; D21]

Use an explicit M2 schema/scenario revision. An untimed M1 save has no defined calendar placement: report incompatibility and preserve the file. A new run uses the existing confirmation; do not silently migrate/reset its stock or invent a date. A separately approved conversion remains possible.

The persistent DAY N · HH:MM:SS HUD reads the shared clock in every room. Medical shows deadline/remaining time without changing F/E/ESC, pips or invalid feedback. Menu, zoning, load and report own distinct pause reasons; closing one cannot release another. Continue establishes REPORT_PENDING before enabling gameplay.

| Proof area | Required observation |
| --- | --- |
| Clock / boundary | 150 seconds → one game hour; large advances process all events once; deadline/E and midnight order do not vary by node order. |
| Receiving | Before-midnight admission survives; exact-midnight release cannot rescue a waiter; no lost cargo or overnight fast-forward. |
| Requests / report | Partial and zero expiry, fulfilled expiry inert, new occurrence identity, immutable report and one next-day setup. |
| Cross-process save | Pre-midnight and report-pending round trips preserve chronology and ownership; failed auto-save leaves prior continuation intact. |
| Presentation / input | Visible clock, F/E/ESC, nested pause and cue continuity remain usable; no queued action on resume. |
| Scenario / preservation | No repeating refill after exhaustion; M1 ladder/storage/lifetime behavior preserved; CF-07 remains explicitly disclosed. |

This is the approved M2 evidence plan. Its execution, independent ACCEPT and final human promotion are attributed in §15 and the linked validation record; it is not a new run by this close-out. The approved contracts remain unchanged. M3/M4 implementation, broad audits, new frameworks and engine changes remain outside this publication. [M2 §10; WG]

**19.1  FULL-GAME IRONMAN CONTRACT**

## 19. Continuous state &amp; randomness

Assess this principle under the COMPLETE Ironman-style preservation system, not the intentionally limited M1/M2 saving cadence. The game maintains one advancing continuation per run continuously and invisibly, within practical technical limits. [D21]

### 19.1 One advancing game-state snapshot

Think of the preserved state as the current recoverable game-state snapshot, not a collection of classical save files the player can choose among. It is updated over and over every few real-time seconds. After a crash or forced termination, Continue restores the latest valid recoverable state, including journaled commitments as applicable.

The full-game target is ideally no more than about 2–3 REAL SECONDS of lost progress. That is the intended delivery target, not a measured guarantee and not an M2 requirement. It supersedes earlier minute-scale progress-loss illustrations. Snapshot/write cadence and actual durable recovery must be tested; they are not inferred from a timer setting alone.

Journaling, rotating copies and necessary integrity safeguards are internal parts of this same system. They are not player-visible alternate timelines, rollback menus or a reason to let the player preserve an earlier favorable checkpoint. Possible multiple independent runs remain distinct from multiple historical saves inside one run.

### 19.2 Shared state, multiple triggers

| Trigger | One common preservation path |
| --- | --- |
| Continuous internal updates | Keep current authoritative state and commitments recoverable during ordinary play without asking the player when to save. |
| Save &amp; Exit | Use the same current state/capture/validation/preservation path before leaving; no standalone Save/Quick Save or separate slot. |
| Midnight auto-save | Use that same path after resolutions are applied; report closure is not a save or outcome trigger. |

The internal work may differ by trigger—journal append, snapshot or final flush—but state ownership and the recoverable continuation cannot diverge. A second manual serializer or an independent automatic-save state is not the design. The exact later mechanism need not rewrite the whole scene every few seconds if it preserves the equivalent coherent state. [D21; M2 §9]

**19.2  NATURAL COMMITMENT / TARGETED REROLLS**

## 19. Continuous state &amp; randomness

### 19.3 Early backend commitment, later visible outcome

Prefer the natural backend compute-and-commit point after relevant player choices become fixed, generally separated from the visible result. The important distances are player-facing decision → backend commitment and player-facing decision → player-facing outcome. They need not match. [D21]

An expedition result calculated after dispatch can be preserved through many routine state updates before return reveals injuries or loot. Reloading near the return then restores the committed outcome. Next-day blackout timing computed during the previous night works similarly. No randomized calculation delays or artificial hidden-roll timers are needed.

The intended protection combines early commitment, continuous preservation, one advancing continuation and a narrow residual rollback window. Ordinary backend sequencing need not coincide with an obvious visual cue. The rejected analysis using “no save for twenty minutes since midnight” is not a valid full-game baseline.

### 19.4 Tolerance and preservation priority

Prevent convenient, reliable target-picking between random outcomes—not every incidental precommit reroll. If recovery lands just before an uncommitted calculation, a different valid unseen outcome can be acceptable when that interval is not reliably exploitable. Do not impose a perfect historical replay or a general anti-cheat/RNG framework merely to eliminate this tolerated case.

Once an outcome is preserved, loading, opening a report or rebuilding cargo must not reroll it. Early computation must also respect inputs the player can still legitimately change; it cannot silently freeze future meaningful choices. Exact gameplay-time and committed ownership restoration remain binding.

### 19.5 Implementation staging is not the design premise

M2 implements authored fixed scenarios and adds midnight saving to the existing path. It does not yet implement continuous Ironman durability, real expedition outcomes or random blackout generation. Those are delivery limits only. The broad randomness principle above must continue to be assessed under the fully developed preservation system.

M2 may replay an isolated pre-midnight test snapshot to verify deterministic schedule/accounting results. That is not a player checkpoint feature. The earlier M2 draft §9’s midnight-only counterexample and additional selective RNG recommendations are superseded by this clarification; they are not approved implementation requirements. [D21; M2 §9]

**15–17 OCTOBER 2026 / DATED DESIGN DECISIONS**

## Appendix A. Conversation decisions

These labels preserve explicit conversation decisions and their dates. D13/D15 retain the original E-opener discussion as history; D16 and current §§5/11 supersede it with accepted F/E/ESC and completed-request behavior. New D17–D21 record M2 approval and the full-game preservation/randomness clarification.

v0.1 and v0.2 remain approved historical checkpoints. P01 remains a proposal, not a final M4 overfill policy. M2 design approval and later technical verification, independent acceptance and human promotion are distinct; the final disposition is recorded in §15. [D16–D21]

| Key | Decision recorded |
| --- | --- |
| D01 | Medical first, then Kitchen, then Expedition Loadout within one persistent allocation test. A resetting isolated sink cannot establish the desired decision space. No real patient/Expedition simulation required yet. |
| D02 | Shared requirement source, request state, submission transaction and result/outcome separation. Preserve finite stock and organization; meaningful combined testing follows all three consumers. |
| D03 | One save slot; persistence across days; manual save, close, reopen and load the same state. Preservation inventory accepted. Crash safeguards and save-tamper protection excluded from the initial slice. |
| D04 | Automatic basic day clock comes after persistent Medical. Demand and deliveries stay scenario-controlled. Add midnight auto-save through the same save operation after coherent transition processing. |
| D05 | Gameplay time and deadlines are exact and authoritative; presentation is reconstructable. Reload at 10:02, not 10:00, in the example; preserve the original 10:04 endpoint. No accumulating drift. |
| D06 | Persistent development digital clock in the UI, independent of physical clock assets or room. Read authoritative time; seconds and pause/acceleration indications support validation. |
| D07 | Use authored deterministic multi-day scenarios initially. A configurable Bulk/Utility/etc. generator is a fallback only if those scenarios prove too rigid. |
| D08 | Use a minimal New Run / Continue / Save &amp; Exit interface rather than only developer keys; simple ESC-menu presentation with a translucent overlay and inexpensive optional blur. |
| D09 | ESC is a full pause. Agreed clarification: launch New Run/Continue; in-run Resume/Save &amp; Exit/New Run; confirm reset; save before returning to launch; failures stay paused. Pause resumes theatre rather than reconstructing it. |
| D10 | Create this major MVP-phase master. Retire Prototype Findings from active tracking, preserve history, and carry unresolved/confirmed-but-unimplemented work forward rather than discarding it. |

### 16 October — M1 approved refinements and provisional policy

| Key | Decision recorded |
| --- | --- |
| D11 | One ordinary Save &amp; Exit and midnight auto-save share a single active run slot; player-facing standalone Save is not required. Prefer a real-world-timestamped Save_&lt;RUN_ID&gt;_DDMMYY-HH-MM filename, with technical file format/location delegated. Continue disabled/grey if no valid save. Release-level Ironman safeguards remain later. |
| D12 | Preserve player position, view orientation, active held item and ideally exact fixed-ladder attachment/height; same-ladder attached-base fallback only when necessary and disclosed. Transient modals/open contribution panels need not persist. |
| D13 | Use existing MedicalInterface, KitchenInterface and DispatchWorkSurface proxies as the temporary E-operated physical collection points. M1 New Run begins with one open Medical request; the target closes it automatically; no pre-clock activation controls or balance trial. |
| D14 | Submission is deliberate, one whole selected item per distinct E press; holding E never repeatedly submits or chooses an optimal carried item. Credit is capped at remaining Utility, excess wasted and never retained; exact-sum matching unnecessary. Full or ineligible requests reject without consumption. |
| D15 | First E opens the non-pausing contribution panel without spending the held item; next E submits if eligible. Preview shows the selected item’s projected pips and total (e.g. Food 5/12 +3 → projected 8/12, +3). Ineligible selected item shows a red bar highlight/border and explicit ineligible text in place of the remaining-after-submission message; no projected gain. |
| P01 | PROPOSAL only: for each eligible Utility family, suggest U=max(1, round(U_ref × (A/A_ref)^0.4 × M_family)), with A=authored Footprint area. Example: 1×1 reference +3 Medical suggests ~+10 for a 20-cell medkit at M=1; it is not +20 by automatic area scaling. Effectiveness exceptions (such as a low-Utility tennis racket) use an intentional modifier or direct override. Values remain authored in ItemDefinition/context, never recalculated from size at runtime or retroactively after consumption. M1 needs only a small Medical fixture subset, not a 40-item rebalance. Loadout overfill/bonus removal is preferred, not yet approved for M4. |

**17 OCTOBER 2026 / APPROVAL &amp; FULL-GAME CLARIFICATION**

## Appendix A. Conversation decisions

| Key | Decision recorded |
| --- | --- |
| D16 | M1 human-promoted and published: F request-panel toggle, E distinct one-item contribution, ESC panel-first, centered panel, completion auto-close/no cues; ordinary exact continuation and bounded R-04 repair accepted. Publication is 36d527d. |
| D17 | M2 provisional rate: one in-game hour per 2.5 real minutes; retain 07:00–00:00. Requests provisionally last three hours and must end strictly before midnight. Future 06:00–10:00 provisioning also moves breakfast to 10:00; not yet active. |
| D18 | Keep causal prerequisites with their owners. Independent same-time closures precede activations; earliest actual initiation/departure then stable ID. Simultaneous auto-dispatch has the ID fallback. Midnight admission is a strict-before cutoff. |
| D19 | Apply resolutions before the informative report; auto-save follows applied state, not report closure. Restore the actual saved point. No auto-save retry workflow; ordinary warning and previous-save preservation suffice for M2. |
| D20 | M2 draft approved apart from corrected randomness framing. Approved details include the shared timeline/calendar, no overnight mechanical fast-forward, three-day fixture, compact report, M2 schema boundary and no new player time skip. |
| D21 | Full-game randomness assumes completed continuous Ironman preservation: one advancing snapshot per run, updates every few real seconds, ideal loss 2–3 real seconds, internal journal/rotating recovery only. Continuous updates, Save &amp; Exit and midnight invoke the same system. Natural early compute/commit is separated from visible outcome; no randomized roll delay is required. Incidental uncommitted rerolls are acceptable, reliable target-picking is not. |

D21 corrects the scope assumption in the first M2 draft; it does not request that full Ironman durability be implemented in M2. It also does not revoke committed-result, exact-time or ownership preservation. M1 stays closed, and P01/final M4 overfill stay provisional.

**B.1  DOCUMENT AND EVIDENCE REGISTER**

## Appendix B. Sources &amp; maintenance

References are project artifacts, not external research. Section citations identify the applicable passage within a master. Reported automated and human results remain attributed; this document does not convert them into new tests.

| Label | Source and use |
| --- | --- |
| GDD | Sorting_Apocalypse_Preliminary_GDD_v0.14.docx; approved 14 October. §§3–8, 9–13, 16, 18–21 supply full-game rules, common request grammar, persistence intentions, scope and validation limits. |
| VDD | Sorting_Apocalypse_Visual_Design_Direction_v0.11.docx; approved 14 October. §§7, 10–19, 24, 33–37 supply visual/spatial and authoring boundaries. |
| PF | Sorting_Apocalypse_Prototype_Findings_v0.14.docx; approved 14 October, now historical for active tracking. §§7, 12–16, 19–20, 24–30 and 32–34 provide inherited foundations, unresolved work and dated evidence. |
| H14 | Sorting_Apocalypse_Current_Operational_Handoff_14Oct2026.md; attached handoff, particularly §§1–5, 9–15, 17–18. Later conversation decisions supersede its then-pending audit status. |
| ER14 | Sorting_Apocalypse_Engineering_Review_Approach_14Oct2026.md; attached approved method, especially §§7–12. Its original audit-not-started status is historical. |
| ER-RESULT | pre-mvp-runtime-engineering-review.md; attached consolidated A/B report at bf26b53. Read findings through CR15 dispositions, not as four currently unresolved repairs. |
| CR15 | docs/testing/pre-mvp-runtime-corrections-2026-10-14.md at 800fd41; initial correction, 15 October manual-address follow-up and final human promotion/publication addendum. Attached (1) copy predates the last addendum. |
| WG | docs/AI_WORKING_GUIDELINES.md at 800fd41; proportionate execution, focused evidence, one implementer/default contextual review and explicit publication boundary. |
| SRC15 | item_definition.gd at 800fd41; read-only confirmation of Utility, contextual overrides, Bulk and separate Storage Category. No new content audit performed. |
| R15 | Historical read-only pre-MVP GitHub inspection. Its exact checkpoints remain in Appendix B.2; latest M1 publication is PUB16/R17. |

**B.1 CONTINUED / SOURCE AND EDITION PROVENANCE**

## Appendix B. Sources &amp; maintenance

| Label | Source / scope |
| --- | --- |
| M1 | Published docs/testing/m1-persistent-medical-validation-2026-10-16.md at 36d527d, read through final acceptance. Original and UI follow-up results are attributed evidence, not new runs. |
| PUB16 | Published M1 linear history: 4cdbb13 → 6c56edf → a7b764e → 36d527d. Main independently rechecked during this update. |
| M2 | Sorting_Apocalypse_M2_Day_Clock_Scheduling_Midnight_Design_v0.2.md, 17 October. v0.1 approved except randomness premise; v0.2 records that approval and D21’s correction. Standalone slice reference, not another active master. |
| R17 | Read-only GitHub main and published Systems MVP v0.2 generated companion at 36d527d. Used to reconcile the uploaded editable copy with its published M1 acceptance text; no local Windows verification. |
| D16–D21 | Explicit later conversation directions and approvals. Terminology, scope, targets and tolerances are recorded here; they are not invented repository evidence. |

### Current published M1 baseline

`36d527d9333a7fedafb803a262ab4a84059381db`

### Accepted final M1 code checkpoint

`a7b764ed4a8eddca25a409fa48646f1056abb9dc`

### Original M1 implementation

`6c56edff05b5e803ad9f17fc5f3b8467e7800f4e`

Old master and spec artifacts remain unchanged. This v0.3 is a newly generated editable edition; the Markdown companion is extracted from it. No claim is made of a byte-identical copy of the published v0.2 DOCX or native Word rendering.

**B.2  PINNED STATE AND FUTURE EDITING**

## Appendix B. Sources &amp; maintenance

### Published and accepted checkpoints

Earlier pre-MVP publication checkpoint (historical)

`800fd41a3073208c146af93dc2b9c84118c5f6f5`

Earlier storage manual-target follow-up (historical)

`7005de7385f155dc0235bfdc685d858a5d7421c6`

Initial R-02 / R-01 / R-03 correction

`a2afab1519448864146c5f0d1f8c03dc4a21856c`

Earlier three-master / pre-review base

`bf26b5320653cd452e99592ed176d0163d9e286f`

Receiving Stage C published closure

`bb6683d28539ff743bc480a9d5d68c4ef3d0ce87`

### Relevant dated records retained through PF

The established storage, ladder, Receiving and EAF validation records remain referenced by PF’s source registers. Key retained Receiving records include single-cycle validation (12 October), intentional lighting (13 October), queued deliveries (14 October) and Awaiting Lift validation (14 October), all under docs/testing and read through their final human dispositions. Their test runs, screenshots and costs were not reproduced to draft this master. [PF §§31–34]

### Maintain one active phase record

Future MVP progress updates modify this master and regenerate its readable extract. Do not append MVP milestones to Prototype Findings. Keep the old master and its mirrors unchanged unless a separately authorized historical correction is needed; any such correction must not rewrite the original evidence state. [D10]

The v0.2 pair recorded M1 acceptance; v0.3 was published at 2cad0d7 with approved M2 and full-game principles. This same-edition close-out records accepted M2 in §15 and corrects operational authority pointers. Older masters, Prototype Findings and the external M2 v0.2 specification remain preserved. Publication requires live remote verification; the executor’s final report records the resulting SHA.

### Edition 0.3 boundary

Edition v0.3 retains approved M2 design, the corrected full-game randomness contract, M1’s published acceptance and all CF-01–CF-24 obligations. The original uploaded-v0.2 reconciliation at 36d527d remains historical [R17]. This 17 October status-only close-out adds M2 human promotion without a new edition, production changes, Godot tests, save access or edits to other masters. [§15; D20–D21]
