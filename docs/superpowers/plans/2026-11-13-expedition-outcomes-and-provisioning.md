# Expedition outcomes and provisioning — implementation plan

> **For agentic workers:** execute inline using `superpowers:executing-plans` where installed. One implementer; apply the project's proportionality rules. One consolidated contextual review at the final candidate, not a review chain for each administrative checkpoint.

**Goal:** replace the mechanical Expedition fixture with the agreed five-lane/full-catalogue outcome system, real injuries and recruitment, natural recovery, truthful feedback and continuation.

**Architecture:** extend existing Dispatch, shared selected-item transactions, active timeline, Receiving handover and save service. Add small pure outcome/acquisition helpers and a Medical-owned natural-recovery component. Keep one authoritative crew/draft/cargo lifecycle; no parallel inventory, roster, scheduler or save system.

**Tech stack:** the installed Godot/GDScript project and Compatibility renderer; existing tests and document-generation tools. Use the actual published branch's versions and interfaces, not assumptions from old source copies.

**Spec:** [Agreed decision record](../../design_history/2026-11-13-expedition-outcomes-and-provisioning-decisions.md). That record owns all numeric and behavioral details below.

## Scope and baseline

Start only after the separate publication task has verified remote main containing `6c82e59ffa00f1f63cda78ebf5a0a127aa049e26` and the resolved full `ed521a2` adoption commit. Use a new local branch from that successor. The architect read code at the preceding `57b217d...`; inspect actual successor interfaces before editing. Preserve user changes, ignored assets, saves, image/UID sidecars and all historical evidence.

Authorized: documentation, scoped gameplay integration, new current-invariant tests, targeted old-path retirement, local commits. Not authorized: publish, implement treatment purchases, Workshop, full Journal, catalogue tuning, retune outcome coefficients, rework Receiving packing, split cargo, or solve all extreme hauls. No old/new gameplay toggle.

Use fresh isolated save/application-data paths for engine checks. Old save compatibility is waived; no destructive cleanup. New-build save correctness is not waived. Packaging and document work do not become separately reviewed milestones.

## Owning files and proposed additions

Verify this map against the actual published checkout. Existing paths were inspected remotely or identified by accepted records. New names below are proposed small owners, not assertions that those files already exist.

| Owner | Planned action |
| --- | --- |
| `gameplay/expeditions/expedition_test_config.gd` | Replace its production role with `expedition_config.gd`; update all actual consumers, remove or move unused fixture-only definitions. Keep eight starting Ready and the separate six-point test goal explicit. |
| `gameplay/expeditions/expedition_outcome_rules.gd` (new) | Pure lane-derived effects, Food count resolution, duration, mutually exclusive injury outcome and recruitment calculations. No scene/tree dependency. |
| `gameplay/expeditions/expedition_loot_generator.gd` (new) | Active catalogue pool, category-first ordinary fill and unrestricted bonus draws, exact manifest component data. |
| `gameplay/expeditions/expedition_loadout.gd`, `expedition_operations.gd` | Five targets, atomic contribution, staged departure, original-member outcomes, destination and personnel handover. Retain no-Ready safeguards. |
| `gameplay/expeditions/dispatch_panel.gd` | Morale row, current/projected effects, truthful capacity warning, bounded activity/outcome history. |
| `gameplay/medical/medical_recovery.gd` (new) | Anonymous patients, natural deadlines, exactly-once recovery; no contribution/treatment methods. |
| `gameplay/medical/medical_recovery_panel.gd` (new) | Read-only live patient information at existing Medical frontage; reuse station interaction conventions. |
| `gameplay/run/collection_timeline.gd` | Include recovery deadlines and settlement without breaking Fuel/Receiving/Kitchen causal ordering. |
| `gameplay/expeditions/expedition_snapshot.gd`, `gameplay/run/run_snapshot.gd`, actual save codec/service | Replace fixed-roster/single-budget/fixture-pool assumptions; compose exact outcome, patient and existing ownership validations. Add a small Medical snapshot helper only if it keeps owners clearer. |
| `gameplay/logistics_wing/wing_gameplay.gd`, existing run shell/HUD/station owners | Bind new owners/panel; 22 normal player Bulk and Kitchen 105 cap/35% setting; keep other services live. |
| `receiving/` and wing Receiving runtime | Reuse exact-manifest/admission/stack history. Narrow accounting adaptation only if needed to preserve ordinary/bonus validation; do not reinterpret physical cargo Bulk as ordinary capacity. |
| `data/items/item_catalog.tres` and definitions | Read-only canonical inputs, including adopted Fedora. No item edits. |
| GDD v0.16, MVP v0.5 and VDD v0.11 DOCX/Markdown; current entry points | Intended design first, implementation status/evidence at finish. Historical claims remain attributed. |

Useful pure helper contracts to expose, adapting names to local conventions: `effects(members, credits)`, `resolve_bonus_count(food_credit, rng)`, `sample_injury(protection_per_member, rng)`, and `generate(ordinary_budget, affinities, weapons_bias, bonus_count, rngs, catalogue)`. Returned data must distinguish ordinary from bonus identities and original members from recruits. Do not create a generic plug-in effects framework.

## Review focus

1. Bonus items exceed ordinary capacity legitimately, but cannot allow overpacked outgoing loadout or arbitrary saved extra cargo. Cover in tasks 2 and 4.
2. Handover may occur while emergency freight is waiting to start; patients/recruits cannot release early from upstream waiting or release twice. Cover in tasks 3 and 4.
3. An all-injured population must recover from real active-time deadlines with no supplies, no Fuel dependency and no offline progress. Cover in tasks 3 and 4.
4. Deferred layout failure must preserve draft, receipts, RNG and personnel without hidden rerolls or duplicate outcomes. Cover in tasks 2 and 4.
5. Medical-lane retirement and new catalogue generation must not undo zero-Ready preparation, terminal-item receipt checks, mixed-stack reconstruction or stable Kitchen scheduling. Cover in tasks 4 and 5.

## Task 1 — baseline and documentation checkpoint

- [ ] Read `docs/AI_WORKING_GUIDELINES.md`, actual current state/bootstraps, the supplied decision record, and targeted GDD/MVP sections. Use the v0.2 workbook/report only as capacity rationale; do not rerun a global loadout study.
- [ ] Verify branch, ancestry, catalogue revision/adopted Fedora and current tests. List actual legacy/config references. Capture the small preservation set once, using existing tools.
- [ ] Reconcile GDD §§8–13 and relevant status sections, MVP implementation/future-work sections and relevant VDD presentation wording. Explicitly replace Food-as-capacity and Medical-as-loadout; record real injury/recruitment/recovery, 23 Bulk, full catalogue, 22/35%/105, and the deferred presentation limitation. Preserve source history rather than overwrite old milestone evidence.
- [ ] Edit DOCX masters before generating Markdown; preserve embedded media/styles and verify changed text/tables, links and affected render pages. Update current-facing pointers as needed, marked implementation pending. Do not claim this candidate already exists or bump document versions gratuitously.
- [ ] Commit this bounded documentation checkpoint. No new human gate is needed before proceeding with the approved implementation.

## Task 2 — lane rules and full-catalogue departure

- [ ] Add failing focused tests in `tools/asset_pipeline/tests/expedition_outcomes_tests.gd` and `expedition_acquisition_tests.gd` (proposed new files), reusing the project test conventions. Pin the exact examples below, rather than generating an arbitrary assertion-count target.
- [ ] Implement real provisional config, pure rules and generator, then run those tests to green. Use stable ordering and isolated randomness families. Preserve whole-item contributions and no-Ready behavior in the owning operations.
- [ ] Stage the complete outcome and exact presentation before final departure commitment. Commit once; failure rolls back staging without undoing previously accepted supply. Keep unsuccessful preparation visible and known limits explicit.

Required rule checks:

| Input | Expected behavior |
| --- | --- |
| Crew 1–4 | Raw ordinary capacity 23/46/69/92; lane targets F10/H5/P12/W10/M15 multiplied by n |
| Food 0, 6, 8, 10, 20, 30, 33, 40 | Expected counts 0, .75, 1, 1.25, 2.5, 3.75, 4.125, 5; forced fractional roll boundaries and exact-integer behavior correct |
| Food contribution beyond cap | Whole item spent only if eligible, capped credit/waste exact, full outgoing Bulk charged; no bonus for waste |
| Hydration zero/full for each n | 210–300 and 157.5–225 ranges; partial effect linear; increasing n without more H dilutes reduction |
| Weights with all categories | Two affinity probabilities .15 each; six others 7/60 each; no item-count category bias |
| Ordinary budget near zero | Remove only categories lacking fitting items; fill until none fits, including Bulk-1 candidates; no arbitrary early stop |
| Bonus draw at zero ordinary budget | Still considers the full eligible catalogue, including a 14-Bulk item; count bounded by Food and n, not ordinary Bulk |
| Weapons q=[1,3,5,7], a=.5 | Probabilities [.15625,.21875,.28125,.34375]; at zero bias all .25; equal q gives equal weights |
| Injury at P=0, 6n, 12n | (Light,Severe) = (.20,.10), (.15,.075), (.10,.05); one result per original, never both |
| Morale M=0 and 15n | Per-original chance 0 and .05; four independent maximum opportunities allow 0–4 recruits, not a one-recruit cap |
| Failed cargo preparation | No successful journey, occupied pair, personnel decrement, new supply consumption, partial cargo owner or RNG advancement; same unchanged retry is not a new outcome |

No 500-item expansion, item-value change or added catalogue rarity data. Validate same-family probability independence without requiring one fixed seed to mimic long-run proportions. A compact seeded sampling sanity check may supplement formula/support checks.

## Task 3 — actual personnel outcomes and natural recovery

- [ ] Add `medical_recovery_tests.gd` and extend the real Expedition lifecycle tests. Demonstrate missing injury/recruitment/recovery behavior before adding it.
- [ ] Implement Medical-owned intake/deadlines and exact once-only completion. Original-member health and recruitment rolls are independent. Recruits are healthy, do not affect the completed journey and join only at normal handover.
- [ ] Integrate original/recruit/patient accounting into nonempty admission, upstream waiting, empty returns and the active timeline. Include recovery in next-boundary selection and no-progress detection.
- [ ] Add the live read-only Medical panel and basic workforce/outcome feedback through existing interactions. No treatment contribution, queue-management or patient-avatar scope.

Required transition witnesses: a formed last crew still dispatches at zero Ready; an injured original can recruit; destination frees at return while personnel wait; deposit during emergency pending-start releases personnel normally; empty cargo creates patients/recruits without lift activity; patients recover after exactly 120/300 active seconds from handover; pauses/offline do not advance them; simultaneous recoveries and returns settle once; every available original injured still has a recovery route. Verify the conservation invariant before and after each meaningful boundary.

## Task 4 — live integration, player/Kitchen values and continuation

- [ ] Update Dispatch previews and the zero-ordinary-capacity confirmation without pre-rolling hidden outcomes. Preserve F/E/ESC, partial draft persistence and availability refresh.
- [ ] Apply 22 normal player Bulk, 105 Kitchen demand cap and 35% maximum loss. Keep schedules/grace/clipping/sprint semantics unchanged. Check D=105 permits 14, all prior carried items remain grandfathered, and new pickups enforce the effective limit. Verify adopted maximum item Bulk remains 14.
- [ ] Extend schema/content and snapshot owners for the full model. Use the next unused revision, preferably 11; reject older content with the existing confirmed-New-Run behavior, no conversion. Preserve current mixed-stack removal history and all three service/disposal receipt families.
- [ ] Add `expedition_outcomes_continuation_tests.gd` and update existing continuation tests that encoded the superseded roster/pool/capacity assumptions. New rules are not a reason to weaken validators.

Continuation cases: unformed preference, formed partially supplied draft, away exact outcomes, Awaiting Lift with injured originals and pending recruits, admitted emergency load, partially unloaded mixed cargo, active patients, recovery completion and post-victory operation. Restore the exact outcomes/deadlines, not equivalent random replacements.

Reject concrete malformed variants: duplicated bonus identity; ordinary item over budget or unfinished fill; impossible Food count; invalid duration/provision combination; both injuries on one original; extra recruitment roll for a newcomer; patient before handover; duplicate recruit/recovery release; an already-recovered patient made unavailable again; missing/incorrect terminal cargo disposition; corrupted Receiving support/removal history. Sampling validation may replay isolated stored seeds, but must never advance live streams or reveal future results.

## Task 5 — targeted cleanup, final evidence and stopping point

- [ ] Trace live references to old fixture config/pool, Medical loadout, 90–180 duration, fixed-eight population validation and no-outcome mocks. Classify actual paths as reused, refactored, removed, already retired or historical. Delete only truly obsolete owners/UIDs; migrate useful tests to real rules. No catalogue-authoring cleanup, schema migration, survival hooks or old/new toggle.
- [ ] Run one final affected regression sweep selected from actual caller changes: Expedition math/operations/UI; Medical recovery; new continuation; shared contribution/receipt ownership; Kitchen and Fuel; Incinerator; Receiving mixed-stack/admission/emergency timing; ordinary storage/failed-placement rollback; F5/F6 startup. Reuse same-state evidence only where justified. After a review correction rerun affected tests, not every unchanged suite automatically.
- [ ] Run native Compatibility at 1280×720 and one actual larger viewport. Exercise real preparation, all five lanes, an actual generated full-catalogue ordinary+bonus haul, injuries/recruitment and natural recovery, queue congestion/zero Fuel, and current-build Save/Continue. Use reproducible seeds through production rules; clearly distinguish injected deterministic boundary fixtures and controlled player positioning. No return-item injection can stand in for proof of the new generator.
- [ ] Obtain one consolidated contextual review of the candidate, prioritizing the five review risks above. Avoid chained spec/quality reviewers per checkpoint. If a reviewer is unavailable, report that limitation rather than fabricate a review.
- [ ] Finalize `docs/testing/2026-11-13-expedition-outcomes-and-provisioning-result.md` (proposed result path), documentation status/master-companion parity and changed links. Record commands, exits, logs, native viewports, source SHAs, warnings, preservation, precise retired paths and remaining limits. Preserve the fixture six-Utility goal and explain continued play for longer checks.
- [ ] Make scoped local commits with explicit staging. Report TECHNICALLY READY FOR DEVELOPER PLAYTEST, not human-promoted or published. Provide a short manual sequence covering effects, authentic return, patient recovery, recruits, zero-Ready formed crew, queue handover and Continue. No automatic merge/push/next milestone.

## Command and evidence discipline

Use the installed engine executable discovered in preflight and the project's existing isolated-profile launcher/test convention. A typical GDScript invocation is:

```text
<verified-godot-console> --headless --path <asset-equipped-project> --script res://tools/asset_pipeline/tests/<focused_test>.gd
```

Add any required isolated-save arguments from the actual existing suite. Inspect error output as well as PASS/exit codes; incorrect invocations are not green baselines. Engine/version, actual preset and reasoning effort are reported only if observable.

Source anchors from the architect's read-only review: `gameplay/expeditions/expedition_operations.gd` already stages a result and restores RNG on preparation failure; `expedition_snapshot.gd` currently has fixed initial-roster, fixed-pool and single-Bulk-budget assumptions; `collection_timeline.gd` already settles lift/returns/Kitchen/Fuel. Modify those live contracts coherently instead of bolting a second model onto them. Inspect their post-publication versions before execution.

## Final acceptance boundaries

A successful candidate proves the implemented paths and tested samples, not production balance, universal all-haul presentation, final population pacing, all catalogue recovery states, large-stock save performance or release crash durability. The meat and long-object failures stay developer-deferred. Known certificate-store/held-material diagnostics and active-clock suspension limits remain attributed. If ordinary play reveals materially broader presentation failures, report the actual evidence and scope rather than quietly filtering loot or automatically resuming the deferred investigation.
