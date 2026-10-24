# M4 Expedition Loadout Implementation Plan

> Execute inline with superpowers:executing-plans. One implementer; stop locally for independent contextual review and developer playtest.

**Goal:** Implement the approved M4 loadout consumer and exact three-day fixture.
**Architecture:** Extend the existing contribution transaction, schedule/clock, seed/storage, Receiving, snapshot and reporting owners. No parallel inventory or time system.
**Tech stack:** Installed Godot 4.7, GDScript, Compatibility; existing test scripts, no dependencies.
**Spec:** `data/scenarios/m4/Sorting_Apocalypse_Codex_M4_Implementation_Handoff_24Oct2026.md`; locked JSON and README beside it.

## Constraints and preservation

Base `71101cf6bd6302842e7c7090a0849b25ef9b75a5` on the authoritative asset-equipped checkout. Ancestry includes `3bb69a9 → e8ed120 → a669c0d → 71101cf`. Local branch `codex/m4-expedition-loadout`. Preserve all physical fields, licensed assets and other worktrees. Apply only locked numbers: 167 rows, carry 20, member Bulk 28, lanes 12/12/6/12/12. Exact 85-item/240-Bulk seed, twelve ordered 16-item deliveries, 06:00 day, rate 24, cutoff 10:00. No balance changes, supply substitutions, geometry changes, merge/push/PR/publication or M5.

## Review focus

- Physical mixed-manifest feasibility and legal initial storage are prerequisites; report an obstruction without changing content.
- Destructive receipt and terminal facts must precede carry observers, with revalidation and global spent identity guarding.
- Input press/release guards, transition rejection, menu/report pause ownership and >10 carried-item selection must work through controllers.
- Clock coordinates, simultaneous cutoff/breakfast, fractional boundaries and report restoration must retain once-only effects.
- Invalid or incompatible snapshots must fail before replacing live state; remaining inventory and saved motion must survive.

## Tasks

### 1: Locked data and physical fixture

- [x] Read handoff/README and verify packet checksums, clean checkout, full ancestry, remote main, worktrees, engine/renderer and processes. Freeze packet; capture external physical/asset baseline.
- [x] Write `m4_baseline_tests.gd` comparing all IDs/values/routes and carry capacity; run RED on old data.
- [x] Exercise all twelve locked manifests through existing preparation and progressive production TAKE/storage tests. Stop/report concrete geometric blockers.
- [x] Apply exact numeric fields in `data/items/definitions/*.tres`, reconcile medical overrides, carry capacity and explicit top-up scale approvals through current metadata helpers; preserve group approvals pending.
- [x] Extend existing seed/setup path with deterministic production-surface placement for exact initial stock; no extra M3 stock. Capture inventory/arrangement and verify ownership and physical preservation.
- [x] Run affected catalogue, physical and content checks; commit cohesive data/fixture result.

### 2: Loadout accounting and schedule

- [x] Write/run failing real-carry tests for formation 0, 1–4, 12–17, 21; five lanes/caps; recipient isolation; full Bulk; reject intact; double-spend and observer ordering; full/manual/cutoff dispatch exactly once.
- [x] Add focused `dispatch_loadout.gd` extension of `contribution_request.gd`, using the receipt-before-notification transaction boundary; durable identity/member count, raw/applied/wasted/Bulk receipts and immutable result.
- [x] Extend `run_scenario.gd`/`run_schedule.gd` with M4 fixture, full-team-first daily activation, concurrent Dispatch requests and stable team access; preserve Medical/Kitchen single-request APIs.
- [x] Verify cutoff before breakfast, exact/fractional/bulk boundaries, finite exhaustion, no repeat seeding/teams; commit.

### 3: Dispatch station and carousel

- [x] Add failing integration/input checks using real player/interface paths.
- [x] Bind existing DispatchWorkSurface using existing station interface contract; add `dispatch_carousel.gd` with centered actionable team, subdued distinct side cards, arrows, position and stable wrapping.
- [x] Add navigation/transition press guards, E recipient revalidation, F/ESC/modal behavior, read-only whole-card light-blue terminal treatment and all-done cue suppression. Preserve movement fix.
- [x] Adapt existing carried strip to keep selected items beyond ten visible/reachable. Render 1920×1080 and 1280×720; commit.

### 4: Persistence and reporting

- [x] Write/run failing snapshot and separate-process continuation tests for partial, mixed terminal/open, post-cutoff and report-pending states, plus invalid/tampered data.
- [x] Extend existing snapshot/codec/timed validator with team/Bulk/dispatch facts and explicit schema incompatibility. Restore before activation; preserve all existing physical, storage, ladder, Receiving and save owners.
- [x] Extend midnight report with completed-day Dispatch results, reason/time, lanes, outgoing/return Bulk. Preserve meals/Medical/coverage/backlog/forfeits/autosave.
- [x] Run continuation and affected runtime checks; commit.

### 5: Final affected verification and delivery

- [x] Inspect combined diff and relevant callers; run one focused final affected regression pass, inspect markers/errors/exits and capture both resolutions, report and seed.
- [x] Record exact candidate commits, evidence commands and limitations in `docs/testing/m4-expedition-loadout-validation-2026-10-24.md`; produce full base-to-candidate patch excluding licensed assets.
- [x] Stop at technically verified local candidate, independent contextual review and human playtesting pending. If any required check fails, label incomplete and report the concrete blocker.

## Execution ledger

Preflight: all implementation tasks share the existing request/clock/snapshot owners. Use selected Dispatch recipient rather than fake destinations; no API conflict identified. Physical feasibility is checked first to avoid building atop an unproven fixture.
Executor: Codex (GPT-6 family; no specific variant asserted).
Evidence root: `C:/Users/Boschetar/.codex/attachments/m4-2026-10-24`.

Progress: locked rows RED→GREEN; all 167 physical definition fields preserved. Twelve mixed manifests pass 192 TAKE/shelf handoffs after explicitly authorized vertex-based vertical seating correction (horizontal bounds unchanged). Seed passes 173 checks / 85 items / 240 Bulk. Loadout passes 49 checks; schedule passes 28 checks. Scale review counts 167 current; top-up group approval remains pending. UI/persistence/reporting still in progress.

Progress: carousel/input tests 22/0; loadout 51/0; schedule 28/0; report 0 failures; witness 1174/0 (81 obligations, 211 spends, 66 items/234 Bulk left). Separate continuation writer 27/0 and reader 21/0 preserve zoning, actual ladder, partial Receiving and mixed loadouts. Native main 228/0 with both resolutions and 15-item strip captures. Seed access 85/85 through production rays; Receiving lifecycle 32 exact TAKEs/FIFO/full outbound passes. Final supplemental fresh-Continue-at-1280 report layout exposes a transient minimum-size clamp leaving card height 1008 instead of 660; investigating/repairing before completion. No numeric/geometry scope expansion.

Final checkpoint: fresh native 1280 Continue/report and held-W across closing pass 8/0 after deferred minimum-size relayout; affected report tests pass. All required technical checks are complete, with failed intermediate runs and the retired 42-item fixture distinguished from passing evidence. Two cohesive code commits end at f5eae9b89f208033c34013a15b178ce9745c7c8a. The validation record and external selected-results summary capture preservation, commands, diagnostics, captures and review/playtest limits. Final delivery includes a full local base-to-candidate patch and exact revision metadata. Independent contextual review and developer playtesting remain pending; no merge/push/PR/publication/M5.
