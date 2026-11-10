# Continuous Kitchen Service — Implementation Plan

> **For agentic workers:** Use `superpowers:executing-plans` for one-implementer execution, or the equivalent available execution workflow. Follow the project's proportionate guidelines ahead of generic per-step review ceremony. Checkboxes below track work; they are not separate review gates.

**Date:** 9 November 2026 · v0.1 execution draft

**Goal:** Add one continuous Food/Hydration service whose bounded demand and predictable contributions affect player carrying capacity and sprint, while preserving the accepted expedition, Incinerator, storage and continuation loops.

**Architecture:** One Kitchen state owner uses the existing active clock, item-consumption transaction and save service. Its schedule and amounts have isolated random state. Kitchen drives a derived carrying limit and sprint permission; it never modifies expedition outcomes or physical item definitions.

**Tech stack:** Existing asset-equipped Godot/GDScript project and native Compatibility renderer; current configured Godot version and existing test tools, verified at local preflight. No new library, generic buff framework or scheduling service.

**Spec:** [Contribution decisions and full Kitchen contract](../../design_history/2026-11-09-contribution-effects-and-kitchen-decisions.md). Read it completely, including the explicitly labeled draft-author defaults A1–A7.

## 1. Execution order and permissions

Use one **fresh local Codex session**, the same coding-model choice successful on the preceding slices, High reasoning effort where selectable. Record actual metadata or unavailable; do not invent a model label. Work in `D:\Godot Projects\Sorting-apoc-PROTOTYPE` with its licensed local assets, on a dedicated branch such as `codex/continuous-kitchen-service`.

First reconcile the approved contribution-design decisions and make a documentation-only checkpoint. Then implement Kitchen on the same branch/session in cohesive local commits. One consolidated review covers the completed behavior; do not commission separate reviews of baseline capture, document routing or packaging. Documentation work alone does not require another gameplay suite.

The developer authorized this Kitchen iteration and the decision reconciliation. Scoped local commits are permitted. **No merge, push, PR, destructive cleanup, automatic human promotion or later milestone.** Stop at technically ready for developer playtest.

## 2. Baseline and preservation

Read `docs/AI_WORKING_GUIDELINES.md`, current state/bootstrap and the relevant owning source. Online `main` was read at `856353ef7fef957e1b3b8dd1b8c607df4aff2c17` during drafting; verify current local/remote ancestry and inspect later relevant changes rather than resetting to that SHA. The accepted Incinerator result and close-out already exist. Do not reopen accepted foundation, expedition, collision or disposal reviews.

Preserve authored item definitions, physical geometry, saved poses/zones/stacks, fixed-ladder behavior, live goal/first victory, exact committed cargo, FIFO and crew handover. Preserve source assets, ignored caches, existing evidence and unrelated untracked work (including any Godot image sidecars). Never use a broad clean/reset/stage-all to manufacture cleanliness.

Use isolated save paths/application data for all executions, including import/native launches. Record hashes of real pointer/snapshot files before and after without running against them. Existing schema-7 and older files must survive even when incompatible. The recommended schema boundary is A7; inspect `run_save_service.gd` before changing compatibility text or replacement behavior.

## 3. Global requirements

- Proposed demand is uniformly 60–80 total Utility; first-iteration lane rule is the explicitly disclosed `larger <= 1.25*smaller` interpretation.
- One cumulative obligation, one 60-active-second grace from opening. Additions do not renew it. Overdue additions apply immediately.
- Ratio 3 Utility / percentage point; maximum penalty 50%; outstanding Utility capped at 150. Food and Hydration are separate lanes with equal per-Utility relief.
- Independent uniform integer 180–300-second event intervals, including first trigger for this iteration. Anchored to scheduled timestamps, unaffected by player actions/caps/other random systems.
- Cap overflow is proportionally clipped with integer conservation; no leftover debt or later catch-up. Live remaining lane balances are never rebalanced.
- Capacity is the floor of normal upgraded capacity times the retained percentage. Sprint blocked only while overdue and uncleared. Ordinary walking and ladders unchanged.
- Items already carried remain valid above the effective limit. New pickups must fit; legal failed-transfer rollback restores exact prior ownership.
- Whole selected item, one fresh E, capped lane credit and waste, distinct terminal receipt before notifications. No item category substitution, refund, double goal deduction or invisible reserve.
- Panels remain live; ESC/zoning/menu/offline pauses retain their existing contracts. Schedules continue after victory without replacing the first-completion time.
- Keep all expedition test parameters and Medical fixture lane unchanged. Document future Morale/bonuses but do not implement them now.
- No Energy machinery work, lighting edits, heal/recruit simulation, Workshop implementation, Rations, mass disposal or balance tuning.

## 4. Review focus

1. **Schedule isolation and cap behavior:** identical timing seeds must produce identical scheduled timestamps despite different contributions, fully capped triggers, reloads and expedition RNG draws. No owed demand is secretly preserved.
2. **Over-capacity is legal ownership:** entering the penalty, continuing a save or rejecting a placement must not lose, duplicate or relocate carried items; ordinary pickup must still enforce the effective limit.
3. **Cross-owner terminal identities:** Kitchen spending cannot also be live, incinerated or loadout credit. Released cargo needs a valid exact receipt both while its source is OPEN and after retirement.
4. **Boundary and input ordering:** due demand/grace, preview updates, repeated E, panel switching and same-timestamp submissions settle once with no stale credit or accidental storage input.
5. **World keeps running:** a live Kitchen panel, an overdue obligation and first victory must not pause expeditions, lift theatre, natural active time or automatic saves, and must not disable unrelated UI or the Incinerator.

## 5. Inspected integration points

The paths below are observed source owners at the baseline, not an instruction to rewrite them wholesale. Locate equivalent owners if the checkout advanced.

| Path | Relevant integration / risk |
| --- | --- |
| `gameplay/run/collection_timeline.gd` | Add Kitchen due boundaries to the same active timeline. Existing zero-step guard only considers lift state/batch; make forward-progress detection recognize settled Kitchen work without hiding stuck boundaries. Preserve admission/return ordering. |
| `carried_items.gd` | Retain `max_bulk` as the normal maximum or use an equivalently explicit distinction. Add/query a derived effective limit. `can_add` is for new ownership; `restore_removed_item` currently calls it and needs narrow legal-rollback treatment. Reuse `commit_selected_consumption(expected, commit_receipt, validate)`. |
| `carried_items_hud.gd` | Currently reads `max_bulk` directly. Show the effective denominator and refresh when penalty changes without inventing a physical contents mutation. |
| `player_controller.gd` | Bind the existing Kitchen frontage with normal reach/occlusion. Gate the ordinary sprint multiplier; do not change base speed, ladder movement or physics. Preserve service input guards and collision repair. |
| `gameplay/logistics_wing/wing_gameplay.gd` | Configure/restore Kitchen, replace the inactive station text, attach panel and status, keep only one service panel active, apply derived state before play resumes. Kitchen proxy is `Environment/Greybox/Proxies/KitchenInterface`; verify its collision child locally. |
| `gameplay/run/run_shell.gd` | Extend existing service-layer closure/pause ownership, not a second menu or clock. Keep autosave cadence and errors. |
| `gameplay/requests/contribution_request.gd` | Reuse its cap/waste/receipt principles and common transaction; do not assume its close-on-full fixed-target lifecycle alone implements cumulative Kitchen demand. Avoid duplicating carry removal. |
| `gameplay/run/run_snapshot.gd` | Current schema 7 hard-requires capacity 20 and rejects load above saved maximum. Validate normal vs effective capacity explicitly; add Kitchen schedule/obligation/receipts, and compose terminal validation. |
| `gameplay/expeditions/expedition_snapshot.gd` | Recognize legitimate Kitchen terminal disposition of exact returned cargo, alongside existing disposal/loadout receipts, without weakening manifest/remaining-entry checks. |
| `gameplay/disposal/incinerator_operations.gd`, expedition operations | Include Kitchen spending in cross-consumer terminal guards only as needed. No redesign of their accepted gameplay. |
| `gameplay/expeditions/expedition_test_config.gd` | Read-only recovery/fixture check: 8 Ready, 8 Bulk/member, sixteen-item pool; `build_pool` bounds each item to at most 8 Bulk. Do not retune it. |

Suggested new owners: `gameplay/kitchen/kitchen_test_config.gd`, `kitchen_operations.gd`, `kitchen_panel.gd`, and a small `kitchen_snapshot.gd` if needed to keep validation focused. A compact status display can stay in the panel file. Adapt exact names to the project, recording departures; do not create a general service director or modifier stack.

Proposed narrow interfaces (new, not existing APIs): Kitchen exposes `next_boundary_at() -> float`, `settle_due() -> void`, `preview(item: ItemInstance) -> Dictionary`, `contribute(carry, expected, has_access) -> Dictionary`, `effective_capacity(normal: int) -> int`, `sprint_allowed() -> bool`, `capture_state() -> Dictionary`, `restore_state(state) -> void`, and a change notification. Use the injected active clock. New-run initialization alone seeds/draws randomness; constructors used for Continue must not generate events. The carrying owner exposes its effective limit without replacing the normal maximum with an already-penalized value. Equivalent smaller interfaces are acceptable; behavioral contracts are binding.

## 6. Work block A — reconcile design before gameplay edits

**Files:** the accompanying record; GDD/MVP and relevant VDD master/companion sections; four existing entry points.

- [ ] Verify branch/worktree, source ancestry, file status and the current Incinerator result. Preserve all unrelated changes. Incorporate this package's two Markdown documents without duplicating existing approved copies.
- [ ] Reconcile all decisions in record §2 and Kitchen §§3–4 into the owning GDD sections, explicitly separating future target loadout from current fixture. Do not present the broader effect map as implemented.
- [ ] Update MVP current direction/future scope and any affected VDD text. Preserve historical metrics, numerical fixtures and approval records; no version bump or layout re-authoring solely for this update.
- [ ] Edit DOCX masters first, regenerate companions with the established method, check changed paragraph/table text and local references, and inspect affected rendered pages. If Word tooling/source is unavailable, report the documentation limitation rather than editing only the generated reading copy or rebuilding the master from an extract.
- [ ] Make one scoped documentation checkpoint. This does not claim Kitchen technical completion, human acceptance or publication. Continue within the same session; no new administrative approval gate.

## 7. Work block B — schedule, outstanding state and exact contribution

**Create:** Kitchen config/operations and `tools/asset_pipeline/tests/kitchen_operations_tests.gd` (plus normal UID sidecars). **Modify:** timeline and narrow terminal-identity integration as necessary.

- [ ] Write focused failing checks for opening/grace/overdue/clearance; separate lane cap-and-waste; exact bound/clipping; schedule independence and preview arithmetic. Run with the existing headless approach and retain the actual failure output.
- [ ] Implement the config and sampling rules from record §4. Initialize each run's timing and demand streams independently. Draw each scheduled proposal even when capped, advance the event counter and schedule normally, then apply only admitted Utility. Do not expose or use hidden overflow later.
- [ ] Implement one live obligation with stable identity, issued/credited accounting, opening/deadline and historical terminal receipts. Store only the facts needed for exact continuation/validation; do not serialize the entire world as a replay or build an event-sourcing framework. Closed-request receipts remain valid terminal evidence.
- [ ] Integrate `next_boundary_at` and `settle_due` into the common timeline, including all crossed timestamps. Use the documented expiry→addition→input ordering for Kitchen. Preserve lift/return causal order and avoid false zero-progress errors when only Kitchen changes. No node-local drifting timer.
- [ ] Implement revalidated selected-item transactions using `commit_selected_consumption`. Record credit/waste and receipt, update obligation/derived penalty coherently, then notify. Saving cannot observe a spend with old credit or a restored capacity with uncommitted credit. Rejection does not form or mutate unrelated state.
- [ ] Run the operations checks to green, inspect logs and make a cohesive local commit. No review gate per small function.

**Exact arithmetic witnesses (fixture calls, not default request sizes):**

| Case | Expected |
| --- | --- |
| Overdue Food 50 / Hydration 40, normal capacity 25 | P=30%, capacity17, sprint false. |
| Contribute exactly 25 Food +20 Hydration | Remaining25/20, P=15%, capacity21, sprint false. |
| Add35/40 to that remainder | Remaining60/60, P=40%, capacity15; no grace renewal. |
| At D=45, credit9 Food | D=36, P=12%, C=25→effective22. |
| Food remaining3, selected Food Utility9 | Applied3, wasted6, penalty drops1 point; no Hydration credit. |
| D=1 overdue | P=1/3 point, sprint still false; no rounded-zero UI or premature closure. |
| At D=120, proposed35/40 | Add14/16, D=150; discard45 permanently. |
| Cap 150, next event | Add 0; advance schedule exactly once. A later contribution does not resurrect it. |
| Headroom1, balanced proposed addition | Add exactly1 to the deterministic tie/rounding lane; other0, no extra debt. |
| Total72 generation | Food 32..40 inclusive, Hydration 72−Food; endpoints satisfy the selected 25% interpretation. |

Use deterministic tests across every total 60..80 and valid split, with representative cap headrooms. Avoid statistical acceptance thresholds that make tests flaky; check the probability construction and deterministic bounded draws directly.

## 8. Work block C — carrying, sprint and live interaction

**Modify:** carrying/HUD, player, wing and shell. **Create:** Kitchen panel and `kitchen_interaction_tests.gd`.

- [ ] Write failing checks for `20/10` grandfathered inventory, rejected new pickup, exact failed-placement rollback, sprint state and non-pausing F/E/ESC behavior.
- [ ] Preserve the authored normal maximum (20 in this runtime). Apply overdue capacity using integer/rational arithmetic: at R=3, integer floor of `normal*(300-D)/300`. Refresh actual carrying HUD on capacity changes even when no item is consumed. Keep displayed Kitchen penalty independent of normal-capacity changes.
- [ ] Audit direct reads of `max_bulk` in gameplay callers. New pickup and displayed remaining space use effective capacity. Restore and failed-transfer rollback must not call ordinary capacity rejection to delete or strand a previously legal item. Keep rollback narrowly bound to an actual failed transfer with exact previous item/slot/selection; do not expose a general over-capacity pickup path.
- [ ] Gate the player's existing sprint condition without altering ordinary walk speed or ladder rules. Kitchen must not change expedition capacity, trip clocks, recruitment, Medical or lift operation.
- [ ] Bind the existing station via ordinary production ray/reach. F opens/toggles without spending, distinct E commits one item, wheel/numbers change selection, and ESC closes the service before the normal pause menu. Respect release guards when entering/leaving service or zoning. The panel stays live and cannot share input with Dispatch or the Incinerator.
- [ ] Implement record A5's minimal status/notices and percentage previews. Display admitted amounts, not discarded proposals. Grace displays current 0% plus pending percentage and time left. Once overdue show active loss and unavailable sprint. Clearance shows no demand; E is inert. Keep essential goal/queue information intact and do not build PA/Journal.
- [ ] Run focused tests and a native Compatibility witness at the project's normal test resolutions. Demonstrate a real approach/F/E path, live time, sprint vs ordinary walking, and normal item handling around penalty changes. Make the cohesive implementation commit.

**Special input/ownership checks:** preview never spends; held E and key echoes never repeat; the E that closes or completes service must not trigger held shelf placement afterward; invalid category/full lane/changed selected item/inaccessible station rejects; no passive spending of any other carried item; no forced unload or inventory rearrangement at grace expiry or added demand.

## 9. Work block D — continuation, integration proof and delivery

**Modify:** snapshot/codec/service only as needed; expedition/disposal terminal validation. **Create:** `kitchen_continuation_tests.gd`, one result record at `docs/testing/2026-11-09-continuous-kitchen-service-result.md` and focused evidence folder.

- [ ] Implement A7's compatibility boundary through the existing service. Preserve prior incompatible snapshots and real pointers. Save current normal capacity separately from/reconstructably with Kitchen effective state. Normal capacity remains the authorized 20 in the default fixture; don't accept arbitrary forged upgrade state merely to pass a 25-capacity unit test.
- [ ] Persist timing initialization/first trigger/next trigger/event progress, both relevant RNG states, captured config/revision, obligation identity/open/deadline/balances, and exact Kitchen receipts. Validate no past due unprocessed work, no duplicate occurrence, no inconsistent penalty/phase, and no live plus terminal double ownership. Restore effects before enabling gameplay. Do not persist/replay an E press or force a transient panel to reopen.
- [ ] Add Kitchen receipts to the validated terminal union alongside loadout and disposal. Preserve definition/identity/time/origin/prior-handover checks for seeds and expedition items, including source batch OPEN and retired. Do not give consumed cargo a fake physical owner or excuse missing items globally.
- [ ] Prove save/Continue before first trigger, during grace, overdue over-capacity, after partial relief, after a capped event, after clearance, after victory, and while genuine cargo remains OPEN/queued/away. A paused/offline interval changes neither deadlines nor RNG. A failed save retains the prior valid continuation. Run the capped-event/contribution branches against identical seeds to prove timing independence after continuation.
- [ ] Prove recovery under the actual 10-Bulk worst-case limit: collect real Food/Hydration from a legal generated haul, contribute at the actual Kitchen, observe relief, then clear and sprint again. The local pool bounds must remain at most 8. No direct inventory injection may substitute for the native recovery witness; controlled fixture setup may place stock/position the start and must be disclosed.
- [ ] Run one selected final regression sweep covering collection/first victory, expedition operations and continuation, Incinerator transaction/interaction/continuation, storage rollback and physical movement collision, plus pause/Receiving causal behavior reached by the changes. Select exact existing commands after inspection; do not rerun all historical daily scenarios or invent a suite-count quota. Log actual errors as well as PASS/exit codes. After a correction rerun affected checks, not the full project automatically.
- [ ] Obtain one consolidated independent review if available, focused on the five risks in §4. Address concrete findings with targeted verification. Record unavailable review honestly rather than simulating it.
- [ ] Update current implementation status and evidence in masters/companions and entry points, without converting developer-approved future-system directions into implemented claims. Preserve the documentation-first checkpoint and exact test configuration. Check changed Word/Markdown paragraphs/tables, links and affected pages; do not rerun unchanged game tests for documentation-only changes.
- [ ] Return exact commits, branch/status/untracked files, test/evidence locations, schema boundary, native observations, known debt and the developer checklist below. Stop at **TECHNICALLY READY FOR DEVELOPER PLAYTEST**, not human-promoted/published.

## 10. Developer playtest checklist

1. New Run in an isolated slot: no instant Kitchen obligation. Receive the first notification after the configured 180–300 active seconds. Open at the Kitchen; verify actual lane requirements and 60-second grace while capacity/sprint remain normal.
2. Let grace expire with a full carried bundle. Capacity drops and sprint stops; walking and every held object remain intact. Check `current/effective` HUD and that new pickups cannot refill beyond the reduced limit.
3. Preview and submit selected Food/Hydration, including an oversized-Utility contribution to a nearly full lane. Percentage relief matches applied credit; no cross-lane spill. Partial relief does not restore sprint. Full clearance restores both baseline capacity and sprint.
4. Leave a request overdue through a later demand. The balance and penalty increase without new grace. At the bound further demand adds nothing; contributing afterward does not immediately refill it. Exact future trigger times are development evidence, not a new UI countdown requirement.
5. Save/Continue in grace, overdue with grandfathered over-capacity goods, and after partial/complete service. Check time left, balances, warning state at the Incinerator, items, ongoing expeditions/lift cargo and goal/first victory. No reroll or duplicate submission.
6. With congestion, use ordinary Incinerator trips and Kitchen contributions to resume pickup/organization. Normal shelf/ladder interaction and furniture collision remain. Continue after victory if the short six-per-category objective completes before sufficient service cycles.

## 11. Sources inspected during drafting

All remote source observations above are at `856353ef7fef957e1b3b8dd1b8c607df4aff2c17`:

- `docs/AI_WORKING_GUIDELINES.md`: task sizing, one implementer, focused evidence and publication boundaries.
- `gameplay/run/collection_timeline.gd`: active chronology, lift-boundary progression and return ordering.
- `gameplay/expeditions/expedition_test_config.gd`: retained fixture and item-Bulk bounds.
- `carried_items.gd`: current capacity checks, selection, rollback and atomic consumption.
- `carried_items_hud.gd`: direct normal-capacity display identified by code search.
- `gameplay/run/run_snapshot.gd`: schema7, capacity-20 validation and terminal union.
- `gameplay/disposal/incinerator_operations.gd`: disposal receipt owner and cross-consumer guard.
- `gameplay/logistics_wing/wing_gameplay.gd`: current service binding, inactive Kitchen and live panel input ownership.
- `player_controller.gd`: sprint integration identified by source search; executor reads the complete affected methods before editing.

The brief was drafted from source and conversation, not by running Godot or inspecting the developer's actual save bytes. The attached Incinerator close-out is attributed evidence of prior acceptance, not a fresh game test. The plan's names, exact new helper signatures and A1–A7 are author-proposed execution defaults, distinct from confirmed mechanics and reported implementation facts.
