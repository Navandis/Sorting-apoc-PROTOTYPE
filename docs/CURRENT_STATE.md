# Sorting Apocalypse — current development state

**Document update: 7 November 2026. Intended game: developer-approved GDD v0.16. Local build: Continuous Run and Collection Goal Foundation.**

## 1. At a glance: approval is not implementation

| Area | Current disposition |
| --- | --- |
| GDD v0.16 | **APPROVED IN ITS ENTIRETY** by the developer. Single current authority for intended gameplay, with its provisional and open classifications retained. |
| Collection foundation | **HUMAN-ACCEPTED / CLOSED IN ITS BOUNDED SCOPE.** [Result and developer acceptance](testing/2026-11-07-continuous-run-collection-goal-result.md). |
| M1 / M2 / M3 / M4 | **HUMAN-PROMOTED / PUBLISHED / CLOSED**, each in its accepted bounded scope. No acceptance, publication or re-review backlog is reopened. |
| Next planned gameplay slice | Expedition-to-storage under a separate brief. M5’s former combined daily scenario is historical. |
| ADR cycle | Parked historical design, preserved for deliberate reuse or a possible survival mode. Not the current economy or immediate design priority. |
| Local checkpoint | See the commit introducing the [closure record](testing/2026-11-07-continuous-run-collection-goal-closure.md). Pre-edit `main` was `d802de64bf7a28bdf9d410be2c87d9dcf306b3d2`. |
| Earlier publication | M4 acceptance is pinned at `c9f9417a97cf65ef416c58189ca1f741b6a90406`. Publication of the local collection checkpoint is pending. |

This file replaces current-facing routing, not historical evidence. The later [MVP/VDD compatibility completion](testing/2026-11-07-mvp-vdd-compatibility-consistency.md) records both targeted master edits and their checks; it does not change the implemented checkpoint. The [approval record](design_history/2026-11-07-gdd-v0.16-approval-and-authority-transition.md) records this task. The complete [pre-adoption CURRENT_STATE snapshot](https://github.com/Navandis/Sorting-apoc-PROTOTYPE/blob/c9f9417a97cf65ef416c58189ca1f741b6a90406/docs/CURRENT_STATE.md), dated validation reports and prior masters remain available. Their then-pending statements do not undo later promotions.

The repository may advance after manual provision. Verify its actual ref and relevant changes before execution; the SHA above is an evidence anchor, never a reset target. Do not create a housekeeping commit merely to remove a time-local pre-publication qualification.

## 2. Authorities and source roles

Read [AI_WORKING_GUIDELINES](AI_WORKING_GUIDELINES.md), this record, [README](README.md), then targeted owning sections. [CODEX_BOOTSTRAP](CODEX_BOOTSTRAP.md) supplies execution safeguards; the [7 November conversation bootstrap](Sorting_Apocalypse_Bootstrap_Prompt_Next_Session_07Nov2026.md) replaces the 25 October handoff for new ChatGPT sessions.

| Source | Authority and limit |
| --- | --- |
| [GDD v0.16 DOCX](Sorting_Apocalypse_Preliminary_GDD_v0.16.docx) / [generated reading copy](readable/Sorting_Apocalypse_Preliminary_GDD_v0.16.md) | Current intended collection-and-organization game. Governs replacements and explicit open mechanics. |
| [Systems MVP v0.5](Sorting_Apocalypse_Systems_MVP_Foundation_Design_and_Progress_v0.5.md) | Accepted implementation/contracts/progress and CF-01–CF-24 evidence. Its obsolete forward gameplay instructions are superseded where v0.16 changes them. The dated 7 November compatibility update now reconciles its current direction and future-work wording; implementation, milestones and attributed evidence are preserved. |
| [VDD v0.11](readable/Sorting_Apocalypse_Visual_Design_Direction_v0.11.md) | Retained world/material/art and authored spatial context. Survival/night/socket gameplay assumptions cannot veto v0.16; actual layout changes still need explicit scope. The dated 7 November compatibility update reconciles presentation and spatial assumptions; no scene changes or new dimensions are authorized. |
| [Findings v0.14](readable/Sorting_Apocalypse_Prototype_Findings_v0.14.md) | Historical prototype evidence, not active progress tracking. |
| [Approved pivot record](design_history/Sorting_Apocalypse_Design_Pivot_Record_05Nov2026.md) | Rationale/provenance. Its team-tabs passage is superseded by the approved single-current-team addendum in v0.16. |
| [Approved ADR archive](design_history/Sorting_Apocalypse_ADR_Design_Archive_05Nov2026.md) / [GDD v0.15](readable/Sorting_Apocalypse_Preliminary_GDD_v0.15.md) | Historical survival design; not parallel current requirements. |

DOCX masters govern; Markdown is generated. Approval of the whole document does not convert DIRECTION, PROVISIONAL, OPEN or HISTORICAL entries into fully specified mechanics. Undefined post-pivot behavior must not be supplied from old survival rules. Code establishes actual behavior, not automatic design intent.

## 3. Target design changes that affect further work

The purpose is to restore collecting, hoarding and organizing as the main experience. Supporting services and expeditions should make physical sorting more meaningful, not replace it with a survival simulator. The old day-count goal repeatedly demanded enough consumption to keep survival challenging, undermining resident stock and storage pressure. The approved pivot changes that objective rather than extending the parked ADR repair.

| Subject | Approved v0.16 rule or explicitly qualified direction |
| --- | --- |
| Victory | Eight simultaneous **live** qualifying stored-Utility totals; immediate success, no hold interval or permanently banked category. 2,000/category is illustrative. |
| Eligible stock | Valid player storage only. Sorting table, carried items, lift/deposited/waiting cargo and expedition commitments do not count. No requirement to clear requests or other inventory before winning. |
| Storage experience | Substantial hoard, uneven category accumulation and useful disposal choices. Roughly 80% occupancy is an aspiration, not a second objective or verified balance. Preserve maneuvering room and assisted placement. |
| Run/time | Active real-world completion time, no calendar/day cycle, no completion deadline or designed terminal failure. Continue after victory or begin an independent run. |
| Pause | ESC, main menu, application off and zoning pause. Preparation tentatively remains live. Time acceleration set aside. Focus/loading/modal edges remain open. |
| Items | Eight shared categories, no first-release dual/multi-use category profiles. Definitions stay stable; buffs affect composition or systems, not silent item Utility/Bulk rewrites. |
| Preparation | One current team: choose 1–4 Ready scavengers, equip/select destination, explicitly dispatch; optionally repeat consecutively. No prebuilt roster, preparation tabs, parallel prepared loadouts or full-loadout auto-send. |
| Destinations | Preferred two-distinct-unordered-affinity model, 28 combinations; favored one-concurrent-team-per-destination restriction, no depletion. Appendix A fixes away-only occupancy, from successful Dispatch to return. Availability-event system and generic fallback are disfavored/no longer needed, not hidden release obligations. |
| Receiving | Preserve exact cargo; uncapped pending returns occupy personnel until delivery. No midnight/overflow forfeiture in target design. Appendix A fixes future personnel release at successful cargo admission into a deposited or active slot. The physical deck remains finite. |
| Requests | Bounded outstanding work and escalation. Brief deferral legitimate, routine indefinite neglect generally costly. Exact cadence, partial effects, penalty ceilings and restoration are open. No request-completion victory gate. |
| Medical | Preferred slower natural recovery and much faster treated recovery. No injured-away mechanic adopted. No-dead-end requirement is not guaranteed quick recovery or adaptive catch-up. Full injury/treatment rules remain open. |
| Progression/layout | All storage from start is favored, not a finalized production roster. Carrying/expedition/information improvements remain candidates. Workshop/Training and spatial compression require further design. |
| Information | Goal progress is baseline, never upgrade-gated or disabled by penalties/events. Journal/notification/overview roles survive; a daily report does not. |

Read the GDD for the actual detail and source distinctions. This table is routing, not a substitute specification. No code change follows from it without an agreed task.

## 4. Local playable collection foundation

Normal F5 entry is `res://gameplay/run/run_shell.tscn`. New Run starts with authored loose stock and two exact development hauls at 3 and 45 active seconds. The HUD tracks six authored primary Utility per category across eight simultaneous targets. The first completion time remains recorded as the player keeps organizing. Medical, Kitchen and Dispatch display inactive service labels.

Schema 5 uses the existing save service under `user://saves/collection/`. Ordinary Save & Exit, 60-active-second automatic attempts and the first victory use that one continuation. The M4 slot under `user://saves/` is historical and remains separate.

Standalone F6 retains the authoring palette and canonical UID `uid://bljf1nlhijej`. The [survival-era archive](design_history/survival-era/README.md) holds the frozen M4 inputs and earlier plans. Read the [local result](testing/2026-11-07-continuous-run-collection-goal-result.md) for the exact fixture, eligibility, proof and limits.

Stage A catalogue reuse and Stage B geometry-measurement reuse remain part of the accepted historical evidence.

## 5. Retained physical and continuation contracts

Physical items retain one durable `ItemInstance` identity and one authoritative owner. Definitions supply authored data; WorldItem/held/HUD representations do not create extra ownership. Accepted submission, TAKE, storage placement and conversion boundaries must be atomic, including rejected and stale interactions. Carrying mutation notifications alone are not a successful consumption receipt.

Collection Continue restores exact stock, player/camera/ladder pose, selected carried item, zones and disabled cells, stacks, reserved cells, orientations, Receiving state, fixture progress, active time and completion. It restores committed ownership and placement before play resumes. Stored orientation is restored rather than recomputed from changed unit Front. A failed load does not create a new run; failed Save & Exit does not abandon the active state.

One coherent logical time source remains useful even though calendar days are removed from target gameplay. Presentation may reconstruct approximately without changing logical deadlines or accumulating load drift. Nested pause ownership must not release another active pause. M4’s midnight/report semantics remain evidence of its fixture, not successor requirements.

The inherited 2–3 second durability aspiration remains future work. The collection foundation uses ordinary schema-5 continuation with one 60-active-second attempt cadence and a first-victory attempt. M4 saves stay in their existing namespace for historical preservation.

## 6. Storage, catalogue and developer authoring

Promoted foundations include representative carrying/storage/retrieval, zoning, support stacking, canonical pose and unit orientation, the shelf-empty ModularRack grammar, selected fixed ladders and the Gallery B rack/ladder bridge. They are not pending milestones.

Automatic storage searches matching category then General, preferring compatible stacks within each tier; erased cells are disabled. Manual placement may ignore category mismatch but not disabled cells. Zoning does not move existing objects. Unit-owned Front and ItemDefinition canonical +Z Front are distinct from the separate 90-degree packing turn. Stack headroom is 95%; singletons use full physical clearance. No arbitrary floor dropping, general rigid-body piles, multi-column support packing or automatic global repacking is introduced.

The saved `DevelopmentSetup/SeedItems` palette in `wing_gameplay.tscn` remains the authoring authority, distinct from the frozen M4 starting manifest and fixed twelve-host regression fixture. The wing has sixteen ordinary functional storage surfaces, including the developer-positionable temporary Gallery B four-level ModularRack and independent FixedLadder. Receiving-private surfaces do not add ordinary player storage.

Developer authoring owns furniture, placement, dimensions, per-edge insets, level distribution, Front and ladder access. Judge visibility, reach, lighting, obstruction and approach together. Open modular shelves are the backbone; deep wall storage and opaque units have context-specific limits. The 1.80 m camera and 2.8 m ceiling observations were trials, not production changes. Fixed ladders do not authorize jumping, general climbing, sliding ladders, fall systems or shelf-top traversal. Full 0/90/180/270 display rotation and crouch remain separate questions.

Current physical approvals cover scale, pose/+Z Front, Footprint and support roles for 167 active definitions. Exactly twelve later additions, `loot_000163`–`loot_000174`, retain saved Auto Stack Group None with separate review approval pending. Do not call the whole physical-metadata gate closed. Approved groups are `boxed_food`, `flat_media`, `medical_boxes`, `round_cans` and `folded_clothing`; the latter applies exactly to 152–155 without bypassing fit/support/clearance.

Retired IDs stay reserved and excluded: `loot_000005`, `000023`, `000024`, `000034`, `000036`, `000037`, `000042`. Old Gloves 034/Pants 036 are retired, not repaired; active Leather Gloves 173 and Rubber Wellies 174 are distinct. `loot_000019` is Cola Can, Hydration +3. Preserve source-confirmation history for 008/009/010/043/044 and accepted scale factors 025 = 1.50, 027/075/129/141 = 1.20. Intentional Footprints 027 = 1×1, 154/155 = 3×4, plus top-up overrides 163 = 13×5, 166 = 3×2 and 168 = 3×3 retain their accepted overhangs and warnings.

Use the existing workbench `res://gameplay/dev/item_storage_pose/item_storage_pose_authoring.tscn` and recorded dependency chain Scale → Pose → Footprint → Stack Role → Auto Group. Review metadata is evidence, not runtime loot eligibility. Preserve saved human `.tres` fields; do not derive new values or Footprints from mesh size just because the goal changes. P01 remains historical/proposed; no formula regenerates the accepted 167 rows automatically.

## 7. Receiving: baseline machinery versus changed policy

The stationary deck/bay/permanent barrier and moving shutter remain accepted. Only fully OPEN enables targeting and TAKE. The cycle is:

```text
SEALED_EMPTY → ARRIVAL → SEALED_READY → REVEALING → OPEN → CLOSING → SEALED_EMPTY
```

OPEN waits for every active item to be successfully removed. Last TAKE starts closing, approximately 3.40-second contact, reverberation/latch and the full cue. Retirement, FIFO promotion and resulting new admission follow complete outbound turnaround. IDLE during outbound is not a free lift. There is no call button, player close/confirmation or automatic unload timer.

Exact outcome content belongs upstream. Receiving may arrange/present but may not add filler, omit awkward items, replace, reroll or bias a haul. Content and accepted placement commitment remain distinct. Repeated seeds do not reuse item identity. Private surfaces are TAKE-only: no PUT, zoning, labels, manual placement, ordinary storage registration, grid or fixture prompt. Front crates/rear pallets and legal stack TAKE/compression remain; no fixture starts empty and emptied fixtures remain through retirement.

**Local collection foundation:** one active plus two deposited FIFO batches and oldest-first upstream admission through `AwaitingLiftAdmission`. Waiting commitments persist across play and continuation.

**Later expeditions:** destination occupancy ends on return. Healthy personnel become Ready and injured personnel enter Medical after cargo admission. The [approved brief’s Appendix A](superpowers/plans/2026-11-07-continuous-run-collection-goal-foundation.md#appendix-a--confirmed-expedition-lifecycle-decisions-for-the-next-milestone) records these decisions and the remaining zero-item and incomplete-affinity questions.

The curved CRT is live/read-only `FREIGHT LIFT / ONLINE`, with STATUS/DECK/QUEUE. At the inspected baseline QUEUE 00–02 counts deposited waiting batches only, not active cargo or upstream crews. The 704×400 green viewport, Surface 1 binding, fonts, mounting and subdued bezel are accepted. W1 is amber during arrival/staging/reveal, green when OPEN, off during closing/idle. Emergency-stop control remains decorative. New crew/backlog monitoring is future design, not evidence that current CRT data should be removed or resold.

## 8. Spatial, art and source safeguards

The accepted builder and saved scene govern **current** geometry, not old schematic pixels. v0.16 permits deliberate future compression; this package moves no walls, lighting, shelves or scene nodes. C1/Stage C and EAF1–EAF5 remain promoted in their recorded scopes; C1A remains parked/unpromoted, and irregular frozen piles remain rejected production research.

| Current authored reference | Value / preservation boundary |
| --- | --- |
| Receiving | 8.00 × 7.50 m / 60 m² nominal; clear 7.70 × 7.20 m; floor Y 0; height 4.20 m; thickness .30 m. World nominal X −36…−28.50, Z ±4. |
| Dispatch | 6.50 × 3.50 m nominal, clear about 6.20 × 3.20 m; 2.40 m doorway. Furnishing not finalized. |
| Backlog opening | X −28.50, centered Z ±1.42; 2.84 × 3.40 m. Geometry resolved; walking material remains adjacent work. |
| Lift transforms | Installation (3,0,0); ReceivingRuntime (−37.41487,.82,0) with original nonuniform basis. Preserve manual installation nodes, cage/shaft overrides and barriers. |
| Shutter | Closed Y .086, open marker 3.1416707; art collisionless, actual TAKE gated separately. |
| MainDeck | 3.30 × 2.00 m / 33×20 cells at .10 m; revision 4, layout_version 3. Support about 3.441×2.100 m; side margins .0705 m, front/rear about .05 m. |
| Reaches | Receiving fixture TAKE 3.4 m; loose 1.4 m; ordinary storage/manual 2.3 m. No proof-only 3.5 m override. |
| Materials | Active P05_C02; reinforced-concrete shaft `eaf3b_1beac3a311a480af8844ea89`, 3 m/repeat. P01_C02/P05_C03 and Dirty Concrete wall/shaft directions are historical. |

`wing_environment.tscn` disables ambient and hides KeyLight; `receiving_lighting.tscn` owns practicals and ceiling bounce, with saved `wing_gameplay.tscn` human overrides taking precedence. Reviewed G1/G2 values 2.60/(1,.84,.68), T1/T2 .75/.85/(1,.91,.77), bounce .45/(1,.88,.75), five shadowed sources plus non-shadowed W1 and one .30 UPDATE_ONCE reflection probe remain adjustable baselines, not immutable numerical gates. W1’s saved range 2.5 m versus coordinator 1.8 m and retained attenuation −.5 is disclosed, not automatic permission to retune.

Preserve coalesced batch/TAKE/settled-shutter reflection refresh ownership, current emitter/lens states and authored audio. Human art at `9ede796` has eleven scalar instances plus one conventional OilStain; the original 18-layer snapshot is not a restoration quota. Removed monitors, `ReceivingInfrastructure`, seven Codex Road Dust placements and `receiving_finish_pass.tscn` remain retired. Retained hidden alternatives stay collisionless. Move/refit mapped movement proxies deliberately when authorized visuals change; visibility alone does not control collision. The independent emergency-stop plaque is retained.

Use the promoted structural/material/wear/lighting owners, UV-default workflow and guarded EAF3/EAF4 sources. EAF3 uses the configured `D:\AssetPipeline\KitBash_repository`; EAF4 uses `D:\AssetPipeline\EAF4_repository`, verified locally before use. No alternate-root searches, licensed-binary staging or new redistribution assumptions. EAF4’s eleven conventional presets and sixteen scalar patterns (eleven opacity.red/five roughness.red) have separate scopes; scalar roughness inputs do not authorize substrate roughness/normal changes. Modulation remains limited to approved soft Leakage effects. Source approval is not room placement approval.

Ordinary appropriate light/wear/furnishing tuning needs version control and focused review, not automatic reopening of C1/Stage C or a new three-master cycle. Major spatial or policy changes require their own scope. Dispatch spill, neighboring room lighting and the sill material remain unimplemented/unfinished where recorded.

## 9. Known debt and carry-forward interpretation

Systems MVP §16 remains the full CF-01–CF-24 register. This entry-point update does not erase technical debt or approve every obsolete future mechanic listed there.

| Scope | Current interpretation |
| --- | --- |
| CF-01–CF-04 | Preserve bounded lifetime repair, ordinary continuation, durable run identity and transaction-boundary evidence. Broader delivery limits remain. |
| CF-05 | Admission/fairness/ownership survive. The archived M4 evidence includes the old midnight rule. |
| CF-06–CF-12 | Retain current interfaces/art evidence and renderer/content/ergonomics debt. No fresh fixes or approvals are claimed. |
| CF-13 | Continuous durability remains future and must use coherent existing ownership. |
| CF-14–CF-15 | Actual expeditions/population/Medical remain future; daily formation, mortality and next-day treatment must not be inherited as target rules. |
| CF-16–CF-17 | Conversions, Workshop, labels/containers/progression require v0.16 scope. Night progression and storage expansion are not default requirements. |
| CF-18–CF-19 | Preserve explicit interaction deferrals; economy, loot bounds and routes now serve the collection objective. |
| CF-20–CF-24 | Retain adjacent art work, measured limitations, saved/runtime distinctions, authoring and source/license safeguards. |

Known remaining items include CF-07 held-material diagnostics, Windows certificate-store diagnostics, Pickaxe 108 co-located LOD, twelve pending Auto Stack Group approvals, loading investigation, baseline cross-wing awareness, final furnishing/interface work and continuous durability. Historical reflection costs (~3.56 s cold addition, 125–132 ms first cargo, 8–10 ms later on the measured machine), unrelated `gallery_a_fixture_front` failure, tolerated residual shadow and unexplained .30/.40 comparison retain their original evidence limits. Unrun editor captures remain unrun. No universal error-free or release-performance claim is made.

The old Fuel/locker maintenance, EAF1 WallGrazing repair, R-01–R-03 and bounded M1 R-04 repair are completed, not recurring work orders. New credible defects can receive focused repair without repeating the entire engineering audit.

## 10. Execution and next-work boundary

The authoritative asset-equipped checkout is `D:\Godot Projects\Sorting-apoc-PROTOTYPE`; reported engine baseline is Godot 4.7 Compatibility. Verify actual branch/tree/worktrees/engine before writing. The prior publication report’s clean tracked state, eighteen preserved untracked sidecars and protected saves are historical local reports, not this task’s inspection.

No reset, stash, clean, force-push, rebase/squash, branch/worktree deletion, untracked staging sweep or ignored-asset cleanup is authorized. Preserve local evidence and human `.tres`/scene edits. A remote clone is not a runnable licensed-art backup. Git ignore is not Godot scan exclusion: keep checkpoint scenes with production UIDs and duplicate global classes outside scanned paths. Preserve startup parity checks and avoid concurrent Godot/import writers on one mutable checkout.

The next planned gameplay slice is expedition-to-storage. Begin from the local checkpoint and the separate expedition brief under GDD §21. Appendix A resolves the stated portions of O-02–O-04 for later expedition work. O-06/O-07 replacement service rules remain open. Follow proportionate evidence: documentation QA is not a gameplay test; code assertions are not human acceptance; publishing requires the actual authorized action and verification.

## 11. Focused evidence navigation

| Topic | Existing record |
| --- | --- |
| M1 / M2 / M3 | [M1 Medical](testing/m1-persistent-medical-validation-2026-10-16.md), [M2 clock/midnight](testing/m2-day-clock-midnight-validation-2026-10-17.md), [M3 Kitchen](testing/m3-kitchen-meal-service-validation-2026-10-17.md). |
| M4 and publication | [Loadout acceptance](testing/m4-expedition-loadout-validation-2026-10-24.md), [publication](testing/m4-publication-2026-10-25.md), [document semantic reconciliation](testing/m4-documentation-semantic-reconciliation-2026-10-25.md). |
| Catalogue | [155-item close-out](testing/pre-m4-catalogue-expansion-validation-2026-10-20.md), [twelve-item top-up](testing/pre-m4-catalogue-topup-validation-2026-10-24.md). |
| Performance / UI | [Stage A](testing/m4-startup-catalogue-reuse-validation-2026-10-25.md), [Stage B](testing/m4-geometry-measurement-reuse-validation-2026-10-25.md), [final UI](testing/m4-ui-refinements-validation-2026-10-25.md). |
| Storage / ladder | [Orientation](testing/storage-unit-orientation-zoning-validation.md), [canonical pose](testing/canonical-item-storage-pose-validation.md), [fixed ladder](testing/fixed-ladder-proof-validation.md), [wing integration](testing/wing-modular-rack-ladder-integration-validation.md), [ergonomics](testing/shelf-ceiling-ergonomics-comparison.md). |
| Receiving | [Deterministic presenter](testing/receiving-deterministic-deck-presenter-validation.md), [freight fixtures](testing/receiving-functional-freight-fixtures-validation.md), [single-cycle](testing/receiving-stage-c-single-cycle-validation-2026-10-12.md), [two-batch](testing/receiving-stage-c-queued-deliveries-validation-2026-10-14.md), [Awaiting Lift closure](testing/receiving-stage-c-awaiting-lift-validation-2026-10-14.md). |
| Current physical envelope / art | [Lift/deck](testing/receiving-c1-lift-enclosure-deck-closeout-2026-10-01.md), [compact retrofit](testing/receiving-c1-compact-retrofit-closeout-2026-10-03.md), [dressing/proxies](testing/receiving-c1-set-dressing-collision-closeout-2026-10-09.md), [C1 closure](testing/receiving-c1-human-promotion-documentation-closeout-2026-10-11.md), [intentional lighting](testing/receiving-intentional-lighting-candidate-2026-10-13.md). |
| EAF authoring | [Wear guide](environment-authoring/eaf4-wear-authoring-guide.md), [imperfection guide](environment-authoring/eaf4-imperfection-audition-guide.md), [EAF4 closure](testing/environment-authoring-eaf4-imperfection-authoring-milestone-closeout-2026-10-10.md). |

Read relevant dated records through their later human dispositions. The complete older evidence index remains in the pinned pre-adoption snapshot and the historical masters. These links reuse prior evidence; no linked gameplay test was rerun for this update.
