# Sorting Apocalypse — Incinerator and Deliberate Disposal

**Implementation brief v0.1 · 8 November 2026 · Draft for review**

**Status:** Gameplay and interaction decisions below are developer-approved standing design. This implementation brief has not been executed. Proposed technical choices are labeled; no implementation, verification or publication is claimed.

**Goal:** Make the existing Incinerator a reliable, deliberate way to permanently remove one carried item, free space and resume receiving/organizing, with exact continuation and a once-per-run warning.

**Architecture:** A small Incinerator owner records the warning state and destruction receipts. Its live panel uses the existing carrying transaction and the established player/wing/shell input route. The existing run snapshot, validator and save service preserve the new state; storage scoring and Receiving remain their own owners.

**Tech stack:** Existing Godot/GDScript project and Compatibility renderer. Verify the local executable rather than changing engine versions.

**Execution:** Fresh local Codex session; same coding-model choice as the accepted expedition task, High reasoning effort where selectable. One implementer, focused tests, one consolidated independent review if available, then developer playtest. Record actual model/effort or state unavailable. `docs/AI_WORKING_GUIDELINES.md` takes precedence over generic workflow ceremony. Use the installed plan-execution/testing skills where available, without creating additional approval stages.

**Spec:** This brief incorporates the developer's approved Incinerator decisions and subsequent approved interaction refinements from the conversation. It supersedes the previously open Incinerator restrictions in GDD v0.16 §15.3 and any Fuel/outage dependency that contradicts them. It does not settle Salvager or other departmental design.

## 1. Baseline, authority and execution boundary

Read `docs/AI_WORKING_GUIDELINES.md`, `docs/CURRENT_STATE.md`, `docs/CODEX_BOOTSTRAP.md`, relevant GDD v0.16 §§5, 8, 14–15 and 18, and the current MVP progress/continuation notes. Read the expedition and furniture-repair result records only for affected contracts and known limitations; no repeated milestone audit is requested.

Read-only repository inspection on 8 November found `main` at `90c5fc6beabaa5403629f4a45c97a380f36d39ec`. This is a source anchor, not a reset target. The collection foundation, expedition loop and furniture collision repair are already accepted and published. Inspect the actual asset-equipped checkout and any later changes before editing. The historical asset-equipped path is `D:\Godot Projects\Sorting-apoc-PROTOTYPE`; verify it locally.

When this handoff is supplied to Codex as the work order, bounded implementation, affected documentation and scoped local commits are permitted. Do not merge, push, open a PR, delete branches, reset unrelated work, alter real saves, or start the next milestone. Use a safe task branch with the existing local assets; do not create an asset-blind or duplicate-script worktree. Stop with a technically verified result and a focused developer playtest. Human acceptance and publication remain separate.

### Scope

Included: one-item Incinerator interaction, permanent loss of the selected carried item, per-run warning, input safety, disposal receipts, save/load validation, existing-location integration, focused congestion and regression checks, and targeted documentation.

Excluded: mass incineration, Salvager/output, Rations implementation, Workshop, recurring services, injuries/recruitment, production tuning, collection-target changes, new art/audio/PA, machine animation or processing queues, new navigation/room geometry, time acceleration, release-durability work, or a generic disposal/request framework.

The standing conditional design for possible future mass incineration is recorded only: it would consume the entire carried inventory, not a cherry-picked subset, with confirmation on every invocation. Do not implement its button, API or dormant scaffolding now.

## 2. Confirmed standing design

| Concern | Binding behavior |
| --- | --- |
| Availability | Usable from the beginning, no unlock/repair, Fuel cost, cooldown or throughput cap. Fuel/energy blackouts cannot disable it. No dependency on another service being satisfied. |
| Eligibility | All valid portable loot actually carried by the player. No category, positive-Utility, affinity or salvage-yield requirement. Future carried Rations/Salvage are eligible when those objects exist; do not introduce them now. |
| Transport | Ordinary carrying capacity and pickup rules remain unchanged. No remote disposal from storage, seed hosts, Receiving, pending cargo or expedition commitments. Retrieve/TAKE normally and physically approach the machine. |
| Commitment | One distinct deliberate E press per item, after F opens the panel. Opening, inspecting, selecting, closing and holding E do not destroy items. |
| Outcome | Instant permanent destruction of exactly one whole item. No physical/virtual output, refund, reversible reserve or furnace inventory. |
| Presentation | Prominent, legible red action label with explicit text; color is not the only warning. Show the selected item's identity/name, category, Utility and Bulk using existing item data. |
| Time | Panel and first-use warning are live. The clock, expeditions, autosave and lift keep operating. Normal ESC/zoning/menu pauses remain intact. |
| Goal | Disposal does not independently change collection totals or first-completion time. Retrieval from qualifying storage has already removed its live contribution. |

Suggested action copy is **`[E] Incinerate — permanently destroy; no output`**. Exact layout/typography is delegated, but clarity, the red action label and selected-item information are required. Keep the panel open after success so the player can inspect and destroy another selected item with a new press. Selection advances only through the existing carrying behavior, not an Incinerator-specific search for another item.

## 3. Once-per-run warning and input contract

The warning text is exact:

> Incinerated items are permanently destroyed! This is a one-time warning.

Use **Back** and **Continue** actions. It appears on the first **valid** E incineration attempt in each new run, not on panel opening, an empty inventory, or a rejected attempt.

| Event | Item and warning state |
| --- | --- |
| First valid E, warning not yet shown | Display warning for the exact selected item. Remove nothing. Mark `warning_shown = true` when actually displayed. |
| Back, or ESC while warning is open | Remove nothing; clear pending confirmation. Keep the underlying panel open and `warning_shown = true`. |
| Continue | Revalidate the original item, current selection/ownership, live panel and physical station access. Destroy only that exact item if still valid; otherwise reject with no destruction. |
| Later valid E in the same run | Destroy the selected item directly, without another popup. |
| Save/load after the warning was displayed | Restore the flag. Do not restore a pending destructive command or reopen/auto-confirm the popup. |
| New independent run | Reset the warning flag and receipts. |

The developer explicitly approved **once displayed**, not once destruction succeeds. Back still uses the one-time warning. An accepted confirmation must not accidentally trigger another destruction when the modal disappears.

Reuse distinct-key-edge guards. E must never both open and confirm the warning. While it is visible, suppress underlying incineration and carry-selection commands; Continue is a separate deliberate button activation, not a repeat of the opening E. Ordinary keyboard button navigation is permissible. Refresh key-release guards on opening/closing so a held E/F/ESC or an input crossing a pause/modal boundary is not replayed. Selection/ownership changes through another path still require confirmation-time revalidation; never substitute a different item.

ESC order: warning → Incinerator panel → ordinary pause menu, on separate presses. F may close the top Incinerator layer consistently with the existing Dispatch convention. Closing any layer clears its transient confirmation target. Only one service panel owns input; opening Incinerator must not leave Dispatch accepting the same E press. World movement/handling is blocked while the panel owns input, as with Dispatch, but this is not a simulation pause.

Persistence follows the existing snapshot cadence. No extra forced save on warning display or destruction, separate settings file, or anti-rollback mechanism is requested. A crash before the next successful save can lose an unsaved flag/action just as it can lose other recent progress; do not claim stronger durability.

## 4. Observed source seams and proposed owning files

These observations come from the pinned source, not a local runtime inspection. Verify current signatures and scene paths before editing. New filenames below are proposed organization, not files claimed to exist.

| File / owner | Intended change or reuse |
| --- | --- |
| `carried_items.gd` | Reuse `commit_selected_consumption(expected, commit_receipt, validate)` and normal selection/capacity. It removes the selected object, invokes the receipt callback, then emits carrying notifications. Do not fork raw removal logic. |
| `gameplay/requests/contribution_request.gd` | Reference its receipt-before-notification pattern. Do not model unlimited incineration as a fulfilled Utility request: its lane/positive-Utility checks would reject valid disposal items. |
| **New** `gameplay/disposal/incinerator_operations.gd` | Own warning flag, exact destruction receipts, revalidation and transaction guard. No live inventory, time processing or production queue. |
| **New** `gameplay/disposal/incinerator_panel.gd` | Own live presentation, selected-item preview, warning modal, transient exact-item confirmation and input guards. Mirror the established panel conventions, not Dispatch-specific rules. |
| `gameplay/expeditions/dispatch_panel.gd` | Reference the live warning, F/E handling and `is_open`/`close_top` conventions. Change only if shared input integration genuinely requires it. |
| `player_controller.gd` | Add the targeted Incinerator interaction through the established reach/line-of-sight path. Do not change movement, carry capacity or storage commands. |
| `gameplay/logistics_wing/wing_gameplay.gd` | Attach owner/panel, bind the existing machine and route mutually exclusive service input. Restore state before enabling interaction. |
| `gameplay/run/run_shell.gd` | Extend top-layer closure and world-input blocking narrowly to the new panel. Keep pause ownership and autosave policy. |
| `gameplay/run/run_snapshot.gd` | Capture, validate and restore disposal state through the existing service; reconcile destruction with live ownership and cargo history. |
| `gameplay/expeditions/expedition_snapshot.gd` | Accept correctly validated external disposal receipts when accounting for released expedition cargo, without changing journey outcomes or treating destruction as loadout credit. |
| `gameplay/run/run_save_service.gd` | Reuse, normally unchanged. Inspect current incompatible-snapshot preservation before the schema transition. |
| `greybox/logistics_wing/wing_geometry.tscn` | Existing proxy `Proxies/IncineratorMachine`; gameplay path is beneath `Environment/Greybox`. Verify the existing body locally before binding. No geometry regeneration or room relocation. |

A small factored service-layer helper is acceptable if needed for Dispatch and Incinerator. Do not turn this into a generic UI router or refactor all interaction owners. Keep the existing collision repair, canonical wing identity, authoring palette, physical item definitions and Receiving theatre intact.

## 5. Destruction transaction and continuation

### Exact once-only commitment

The operation validates a selected, actually carried item and an active reachable station. It uses `commit_selected_consumption` with a callback that publishes the destruction receipt **before** carrying notifications. During a destructive transaction, saves must see either the full pre-state or the full post-state, never a missing item without its receipt. Reentrant/stale/double submissions reject. No successful or failed path selects a replacement item to satisfy the original action.

Use a small durable receipt per destroyed identity. A sufficient proposed record is `{item_id, definition_id, at}`, where `at` is active elapsed time. Retain enough existing provenance to validate the source; do not fabricate request targets, credited Utility, expedition supplies or a new item identity. The Incinerator owns these receipts. It must not keep ItemInstance references as a retrievable inventory.

Cross-check uniqueness with live items and accepted expedition contribution receipts. A destroyed ID cannot still belong to carrying, seed hosts, storage, Away/pending/deposited cargo, or another consumption receipt. Duplicate IDs, unknown/mismatched definitions, invalid timestamps and inconsistent origin/handover claims must reject rather than be silently repaired.

### Critical cargo-history integration

Current snapshot validation expects released active cargo to have either a live owner or an expedition consumption receipt. Expedition validation also accounts for cargo after the physical batch has retired. Incineration therefore needs a new legitimate terminal disposition in those existing checks.

For a taken expedition item, the receipt must match its committed definition and occur no earlier than cargo handover. A receipt must never excuse an entry still marked `remaining_in_batch`, an Away commitment or a waiting/deposited object that was never taken. Preserve rejection of genuinely missing cargo—the gap fixed in the foundation must not be reopened by allowing arbitrary absent IDs.

Keep disposal and loadout receipt collections distinct in saved state. At validation time they can supply a shared read-only terminal-item lookup after cross-checking disjointness. Do not grant Receiving ownership of disposal, edit the committed manifest, remove cargo-history checks, or add incineration receipts to an expedition's five supply lanes.

Loose seed items must also remain gone after restoration. Do not reseed them to satisfy a historical identity check. Existing normal origin and allocator invariants remain applicable. Future Rations/Salvage origins can extend provenance when implemented; no current eligibility filter should preclude them merely because they lack positive Utility or belong outside the acquisition test pool.

### Save-version recommendation — technical draft choice

At the inspected baseline schema 6 has no disposal state. This draft recommends the next unused schema revision (**7 if still available**) for required warning/receipt state, using the same `user://saves/collection/` namespace, codec and service. No second save implementation or automatic conversion is requested.

Reject incompatible schema-6 continuation explainably. Confirmed New Run may repoint the collection slot through the existing UI, while retaining its incompatible snapshot file. Merely loading/inspecting an old save must never modify it. Preserve the separate M4 slot and any retained schema-5 snapshot. Do not overwrite, delete or use the developer's real saves for tests.

This is a proposed implementation choice, not a new gameplay rule or an already executed migration. If local source has advanced, use its current version convention and report the actual change; do not collide with a later schema. No migration framework is justified for this task.

Persist `warning_shown` and destruction receipts even if the current inventory is empty. Validate the flag's type; nonempty destruction receipts require `warning_shown = true`. On restoration keep panels closed and transient command targets cleared; restore physical owners/receipts before resuming gameplay. A saved flag from a canceled warning remains true.

## 6. Implementation sequence

The following are work blocks within one milestone, not separate review or human-acceptance gates. Write focused failing checks first, verify the relevant failure, then implement and rerun the affected checks. Use scoped commits when each coherent block works; do not stage unrelated files.

### Task 1 — Incinerator ownership and transaction

**Create:** `gameplay/disposal/incinerator_operations.gd`; `tools/asset_pipeline/tests/incinerator_operations_tests.gd` (plus normal UID sidecars).

**Reuse:** `CarriedItems.commit_selected_consumption`, existing item accessors and active clock. Inspect the carrying implementation completely before connecting irreversible consumption.

- [ ] Establish the accepted local base, protected files/saves and actual engine. No re-audit of completed milestones.
- [ ] Add failing tests for exact-item removal, no Utility/category filter, first-warning gating, rejection/no-op, identity disjointness and notification-time coherent state.
- [ ] Implement the small owner with explicit preview/attempt, warning-displayed state, validated single-item commit, receipt capture/restore and a transaction guard. APIs may follow existing project idioms; do not fork carry state.
- [ ] Verify one successful action removes one object and releases exactly its Bulk, while failed actions preserve slots, selection, goal, receipts and stock. Add no reward or request credit.

### Task 2 — Existing-machine live interaction

**Create:** `gameplay/disposal/incinerator_panel.gd`; `tools/asset_pipeline/tests/incinerator_interaction_tests.gd`.

**Modify narrowly:** `player_controller.gd`, `gameplay/logistics_wing/wing_gameplay.gd`, `gameplay/run/run_shell.gd`; existing scene only if binding cannot be expressed through current runtime setup.

- [ ] Add failing interaction checks for F/no-spend, first E/warning, Back, Continue, stale exact target, held/repeated input, ESC order and service-panel mutual exclusion.
- [ ] Bind the real Incinerator approach using ordinary reach and occlusion; add a readable F cue and the red destructive-action label. No opening through walls or arbitrary global access.
- [ ] Implement the approved once-displayed warning, live panel/modal and suppressed underlying input. Keep travel/lift/clock advancing while interacting; preserve ESC's later full pause.
- [ ] Exercise opening, selection, cancel/confirm and a second deliberate incineration through actual input paths, not just backend methods. Confirm ordinary Dispatch still works.

### Task 3 — Durable disposal and integration

**Modify:** `gameplay/run/run_snapshot.gd`, `gameplay/expeditions/expedition_snapshot.gd`, restore wiring in the wing and any genuinely necessary existing save compatibility message.

**Create:** `tools/asset_pipeline/tests/incinerator_continuation_tests.gd`.

- [ ] First reproduce snapshot rejection of a legitimately destroyed released expedition item, and pin malformed missing-owner rejection separately.
- [ ] Add required warning/receipt state, the agreed version boundary and the narrow terminal-disposition validation. Preserve exact existing cargo commitments, player/storage state, goal and time.
- [ ] Verify flag states and destroyed items through save/load before and after victory, while a source batch is still OPEN and after it retires. Test observers cannot capture a half-committed removal.
- [ ] Finish the focused physical/congestion witness and affected regressions below. Update the owning documentation and produce one result record for developer testing. No full economy or performance project.

## 7. Required evidence and regression focus

Tests must use isolated save directories/redirected application data before constructing the normal run shell. Read-only hashes of the current real save pointers and their referenced snapshots before/after the task should confirm preservation; old result-record hashes are not substitutes for the current baseline. Locate the actual installed Godot path. Typical headless form, following existing suites:

```powershell
& $Godot --headless --path $Project --script res://tools/asset_pipeline/tests/incinerator_operations_tests.gd
& $Godot --headless --path $Project --script res://tools/asset_pipeline/tests/incinerator_interaction_tests.gd
& $Godot --headless --path $Project --script res://tools/asset_pipeline/tests/incinerator_continuation_tests.gd
```

New suites must terminate with meaningful nonzero failures. Successful exit alone is insufficient: inspect script errors and PASS/check counts. Reuse existing helpers rather than creating another runner. The native proof may use the interaction script's established native mode rather than another test framework.

| Proof | Minimum useful cases |
| --- | --- |
| Warning | Opening/empty E do not mark seen. First valid E displays exact text with no spend. Continue destroys once. Back/ESC retain item and mark seen. A later E has no warning. New Run resets. Save/load after Back, after Continue and while warning was visible preserves the correct logical state without replay. |
| Input and station | F never destroys; E echo/hold does not repeat; opening E cannot confirm; leaving modal/pause cannot carry E into destruction or storage. Selection change/replacement rejects a stale confirmation. Blocked/remote station interaction rejects. Dispatch and Incinerator cannot both consume. |
| Eligibility and capacity | Representative items from all eight categories; any current zero-Utility portable item or an isolated test instance; empty carry; full 20-Bulk carry. Disposal is not restricted to the 16-item acquisition pool. Over-capacity pickup remains forbidden; there is no disposal bypass. Do not edit production item definitions for these checks. |
| Ownership | Receipt precedes notifications. Repeated command, duplicate receipt, overlap with a live owner or loadout receipt, mismatched definition and false cargo receipt reject. No phantom output, retained inventory or refunds. |
| Goal | Store → retrieve → incinerate removes score only at retrieval; a loose never-scored item changes no total. Other items/categories are unchanged. After victory, first-completion time stays fixed. |
| Continuation | Seed-origin and expedition-origin destruction persist. Take and destroy one item while other items remain on its active deck, then round-trip. Repeat after batch retirement; preserve Away/waiting/delivered trips and receipt facts. Incompatible saves and failed saves remain protected. |
| Live time | Clock/expeditions/lift advance while panel and warning are open. ESC menu freezes the coherent timeline; resume does not confirm or consume. Automatic snapshots with the panel open preserve coherent state. |
| Congestion | In an isolated fixture, create limited spare storage/full carrying and a genuine awaiting crew. Carry selected items to the Incinerator, destroy them, return and TAKE cargo. Existing full lift turnaround and admission release the crew. Disposal itself neither unloads cargo nor releases personnel. |
| Physical/regression | Native approach/F/E/buttons, readable warning/action label, ordinary pickup/place/retrieve, and existing furniture collision remain correct. Test normal New Run and Continue. |

Use the smallest relevant regression set from the current suites: collection goal/continuation, expedition operations/continuation, affected contribution/carry tests, Receiving admission/pause, and the recently accepted furniture-collision test where interaction integration touches its owners. Discover exact current script names; do not resurrect retired M4 suites. Run unaffected proofs once where appropriate and reuse same-state evidence. Do not automatically repeat all former suites, every shelf geometry case or full catalog presentation checks.

A short native Compatibility check must include the actual front interaction and real input; report any backend/button-signal shortcuts separately. Current 1280×720 native coverage is a useful baseline; also check the developer's ordinary display if available. Keep the red label readable without making color the only cue. One consolidated independent review should focus on destructive input and save consistency; corrections receive affected reruns only.

## 8. Documentation and result boundary

Record these as standing design, not provisional fixture rules. Make targeted updates in the owning GDD sections (especially §15.3 and conflicting §14.2 Fuel wording) and the MVP progress/continuation record; retain unrelated open entries and historical evidence. DOCX masters are edited first, companions regenerated and changed blocks checked for text/table parity and layout using the local established document workflow. Do not hand-edit companions independently. VDD needs only a targeted correction if a current operative restriction conflicts; no visual/spatial redesign.

Update current-facing pointers only where actual implementation/status changed. Conditional mass disposal remains deferred. No locked balance values, final collection target, salvage category, Kitchen consequences or release durability follow from this slice.

Write `docs/testing/2026-11-08-incinerator-deliberate-disposal-result.md` (or the actual execution-date equivalent) with exact source/engine, changed paths, technical choices, schema behavior, checks and raw evidence references, defects/corrections, preserved-save evidence and known limits. Copy useful evidence out of temporary-only storage; no new archive platform. Preserve existing suspension/autosave/material diagnostic limitations as attributed prior debt, not new measurements or proof of repair.

Return the branch and commit(s), clean/dirty state with explanations, tested behavior, untested edges and this short human playtest:

1. Carry an item normally to the machine. F opens without spending; first E shows the exact warning while active time continues. Choose Back, then E again: only the selected item is destroyed, without a second warning.
2. On another fresh run, confirm the warning; try holding E and closing/reopening. No other item should disappear without another deliberate press.
3. Retrieve an item from a qualifying shelf, note the score decrease, destroy it and verify no second decrease. Repeat with a loose seed item and an expedition item. Check normal shelf use and collision still work.
4. Save/Continue after canceling the first warning and after destruction, including cargo still on the lift. Warning state and absence of destroyed items persist; other goods, expeditions and first-completion time are unchanged.
5. With a backed-up lift/full carrying, use ordinary trips to dispose of chosen items and resume unloading. Verify normal admission—not incineration—releases waiting personnel.

**Exit:** Technically ready for developer playtest. No automatic human promotion, merge/publication or next-milestone work. This packet itself changes no repository or save.

## 9. Source anchors and provenance

The confirmed design derives from the developer's Incinerator A–D decisions and explicit approval of once-displayed warning semantics, live warning, exact-item confirmation and scope separation. No quotation or date for those messages is invented beyond this document's preparation date. The technical observations below are pinned to the inspected commit; future executors verify their actual source.

- [Working guidelines](https://github.com/Navandis/Sorting-apoc-PROTOTYPE/blob/90c5fc6beabaa5403629f4a45c97a380f36d39ec/docs/AI_WORKING_GUIDELINES.md)
- [Current-state routing](https://github.com/Navandis/Sorting-apoc-PROTOTYPE/blob/90c5fc6beabaa5403629f4a45c97a380f36d39ec/docs/CURRENT_STATE.md)
- [GDD v0.16 reading companion](https://github.com/Navandis/Sorting-apoc-PROTOTYPE/blob/90c5fc6beabaa5403629f4a45c97a380f36d39ec/docs/readable/Sorting_Apocalypse_Preliminary_GDD_v0.16.md)
- [Atomic carrying consumption](https://github.com/Navandis/Sorting-apoc-PROTOTYPE/blob/90c5fc6beabaa5403629f4a45c97a380f36d39ec/carried_items.gd)
- [Contribution receipt pattern](https://github.com/Navandis/Sorting-apoc-PROTOTYPE/blob/90c5fc6beabaa5403629f4a45c97a380f36d39ec/gameplay/requests/contribution_request.gd)
- [Live Dispatch panel/input precedent](https://github.com/Navandis/Sorting-apoc-PROTOTYPE/blob/90c5fc6beabaa5403629f4a45c97a380f36d39ec/gameplay/expeditions/dispatch_panel.gd)
- [Shell modal/pause ownership](https://github.com/Navandis/Sorting-apoc-PROTOTYPE/blob/90c5fc6beabaa5403629f4a45c97a380f36d39ec/gameplay/run/run_shell.gd)
- [Run snapshot and released-cargo validation](https://github.com/Navandis/Sorting-apoc-PROTOTYPE/blob/90c5fc6beabaa5403629f4a45c97a380f36d39ec/gameplay/run/run_snapshot.gd)
- [Expedition identity and historical cargo validation](https://github.com/Navandis/Sorting-apoc-PROTOTYPE/blob/90c5fc6beabaa5403629f4a45c97a380f36d39ec/gameplay/expeditions/expedition_snapshot.gd)
- [Existing Incinerator proxy](https://github.com/Navandis/Sorting-apoc-PROTOTYPE/blob/90c5fc6beabaa5403629f4a45c97a380f36d39ec/greybox/logistics_wing/wing_geometry.tscn)
