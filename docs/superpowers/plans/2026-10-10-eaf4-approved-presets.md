# EAF4 Approved Presets Implementation Plan

> **For agentic workers:** Use superpowers:executing-plans to implement inline. The user explicitly requested direct continuation of an approved design.

**Goal:** Make all current approved floor/wall wear reusable through Task 1 controls in the canonical wing.

**Architecture:** Deterministic one-shot preset wrappers reference existing approved sources. An empty, directly scene-owned AuthoredWear root organizes user placements. Test-only branch validation allows exactly the established visual helper and plain organization nodes, without gameplay/physics/light authority.

**Tech Stack:** Godot 4.7 Compatibility, GDScript, Python standard library.

**Spec:** User attachment `C:/Users/Boschetar/.codex/attachments/390a39cc-aa12-4b2d-8240-436984073d1a/Pasted text.txt` plus dirty-file preflight requirement.

## Global Constraints

- Continue `99fc745`; retain Task 1 and accepted signage.
- Preserve all four protected dirty contents; stage only the additive wing block.
- Reuse textures/specs/catalog, no approval edits or artistic wear arrangement.
- Local task-only commit; no push, merge, publish or acceptance declaration.

## Review Focus

- Catalog drift/missing asset/fingerprint: report explicit failure, no fallback.
- Sources with identical display names: stable IDs still distinguish mappings.
- Root instance overrides and script-default-valued edits survive save/reopen.
- Nested scripted/physics/light content is rejected while ordinary groups/duplicates work.
- Existing scene overrides and generated legacy previews remain unchanged without double geometry.

### Task 1: Audit and presets

Files: `tools/environment_authoring/wear_catalog/build_presets.py`, its Python tests, `environment_authoring/wear/presets/*.tscn`, coverage README; `environment_wear_authoring.gd` read-only usage notes; `test_wear_presets.gd`.
Interface: audit catalog effective approval, stable identity/fingerprint/dependencies; wrapper uses Task 1 approved_source and flat instance-root properties. Eligible patch paths use EnvironmentMaterialPatch's supported mode; none is presumed eligible.
- [x] Write and run missing-library/coverage and invalid-dependency tests (RED).
- [x] Implement small deterministic audit/build; generate wrappers with floor-only X=-90 degrees, others upright, source-specific restrictions.
- [x] Instantiate every preset and prove live/duplicate/switch/default/save/reopen isolation (GREEN).

### Task 2: Wing groups and guard

Files: additive canonical wing block; `tools/asset_pipeline/tests/support/wear_branch_guard.gd`, `wear_authoring_workspace_tests.gd`, narrow infrastructure-suite call.
Interface: AuthoredWear direct root with plain room groups; exact authoring script helper and unsaved generated Quad only. Existing Receiving allowance stays narrow.
- [x] Write and run missing-root/forbidden-content tests (RED).
- [x] Add empty Receiving/Storage/OtherRooms groups and narrow recursive validation.
- [x] Test legitimate additions/reparent/hide/duplicate and negative script/physics/light injection (GREEN). Compare all protected bytes and prior scene content.

### Task 3: Editor, regressions and handoff

Files: practical `docs/environment-authoring/eaf4-wear-authoring-guide.md`, Task 2 report and genuine captures if available.
- [ ] Actual canonical editor floor/wall live edits, duplicate, switch, undo/redo, save/reopen; old Road Dust and wear-only visibility. Keep validation edits in ignored copy, preserve canonical bytes.
- [x] Run all Task 1 relevant EAF4/Python/wing suites and real OpenGL CRT; record limitations honestly.
- [x] Fresh independent read-only review; fix blockers with regression tests.
- [x] Prove index is task-only, commit locally and preserve the original unstaged wing diff plus other dirty files. Stop for human authoring review.

## Rulings

Use the user's existing checkout and implement directly: required by explicit continuation, so no additional worktree or plan approval pause. Record red/green and final evidence in the Task 2 report. Use one final commit to keep the wing index isolation reviewable.

## Execution ledger

Library and wing tasks complete: RED/GREEN logs and 224/30 focused assertions in Task 2 report. No artistic placements; exact dirty-byte preservation verified. Native interaction blocked by two documented window-capture failures; manual acceptance remains open. Prior EAF4/wing suites and 60 Python tests pass, real OpenGL CRT and floor/wall pixel assertions pass. Shutdown diagnostics retained as unresolved. Fresh independent review and correct-owner negative-test mutation proof completed; local task-only commit isolation checked separately.
