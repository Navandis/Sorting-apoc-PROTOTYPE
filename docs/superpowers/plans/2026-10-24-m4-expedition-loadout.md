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
- [ ] Write `m4_baseline_tests.gd` comparing all IDs/values/routes and carry capacity; run RED on old data.
- [ ] Exercise all twelve locked manifests through existing preparation and progressive production TAKE/storage tests. Stop/report concrete geometric blockers.
- [ ] Apply exact numeric fields in `data/items/definitions/*.tres`, reconcile medical overrides, carry capacity and explicit top-up scale approvals through current metadata helpers; preserve group approvals pending.
- [ ] Extend existing seed/setup path with deterministic production-surface placement for exact initial stock; no extra M3 stock. Capture inventory/arrangement and verify ownership and physical preservation.
- [ ] Run affected catalogue, physical and content checks; commit cohesive data/fixture result.

### 2: Loadout accounting and schedule

- [ ] Write/run failing real-carry tests for formation 0, 1–4, 12–17, 21; five lanes/caps; recipient isolation; full Bulk; reject intact; double-spend and observer ordering; full/manual/cutoff dispatch exactly once.
- [ ] Add focused `dispatch_loadout.gd` extension of `contribution_request.gd`, using the receipt-before-notification transaction boundary; durable identity/member count, raw/applied/wasted/Bulk receipts and immutable result.
- [ ] Extend `run_scenario.gd`/`run_schedule.gd` with M4 fixture, full-team-first daily activation, concurrent Dispatch requests and stable team access; preserve Medical/Kitchen single-request APIs.
- [ ] Verify cutoff before breakfast, exact/fractional/bulk boundaries, finite exhaustion, no repeat seeding/teams; commit.

### 3: Dispatch station and carousel

- [ ] Add failing integration/input checks using real player/interface paths.
- [ ] Bind existing DispatchWorkSurface using existing station interface contract; add `dispatch_carousel.gd` with centered actionable team, subdued distinct side cards, arrows, position and stable wrapping.
- [ ] Add navigation/transition press guards, E recipient revalidation, F/ESC/modal behavior, read-only whole-card light-blue terminal treatment and all-done cue suppression. Preserve movement fix.
- [ ] Adapt existing carried strip to keep selected items beyond ten visible/reachable. Render 1920×1080 and 1280×720; commit.

### 4: Persistence and reporting

- [ ] Write/run failing snapshot and separate-process continuation tests for partial, mixed terminal/open, post-cutoff and report-pending states, plus invalid/tampered data.
- [ ] Extend existing snapshot/codec/timed validator with team/Bulk/dispatch facts and explicit schema incompatibility. Restore before activation; preserve all existing physical, storage, ladder, Receiving and save owners.
- [ ] Extend midnight report with completed-day Dispatch results, reason/time, lanes, outgoing/return Bulk. Preserve meals/Medical/coverage/backlog/forfeits/autosave.
- [ ] Run continuation and affected runtime checks; commit.

### 5: Final affected verification and delivery

- [ ] Inspect combined diff and relevant callers; run one focused final affected regression pass, inspect markers/errors/exits and capture both resolutions, report and seed.
- [ ] Record exact candidate commits, evidence commands and limitations in `docs/testing/m4-expedition-loadout-validation-2026-10-24.md`; produce full base-to-candidate patch excluding licensed assets.
- [ ] Stop at technically verified local candidate, independent contextual review and human playtesting pending. If any required check fails, label incomplete and report the concrete blocker.

## Execution ledger

Preflight: all implementation tasks share the existing request/clock/snapshot owners. Use selected Dispatch recipient rather than fake destinations; no API conflict identified. Physical feasibility is checked first to avoid building atop an unproven fixture.
Executor: Codex (GPT-6 family; no specific variant asserted).
Evidence root: `C:/Users/Boschetar/.codex/attachments/m4-2026-10-24`.

Progress: locked rows RED→GREEN; all 167 physical definition fields preserved. Twelve mixed manifests pass 192 TAKE/shelf handoffs after explicitly authorized vertex-based vertical seating correction (horizontal bounds unchanged). Seed passes 173 checks / 85 items / 240 Bulk. Loadout passes 49 checks; schedule passes 28 checks. Scale review counts 167 current; top-up group approval remains pending. UI/persistence/reporting still in progress.
