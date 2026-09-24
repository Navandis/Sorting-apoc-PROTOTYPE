# Receiving Deck Promotion Closure Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Record the human PROMOTE decision for the deterministic Receiving deck, verify the reviewed branch, and safely fast-forward and synchronize `main`.

**Architecture:** This is a documentation-only closure over the already reviewed feature branch. Preserve all earlier implementation and correction history, add a final human-promotion section and concise current-state guidance, then use an ancestry-guarded fast-forward merge with pre/post verification before pushing `main`.

**Tech Stack:** Markdown, Git, Godot 4.7 headless regression scripts.

**Spec:** `C:/Users/Boschetar/.codex/attachments/ff7877cd-a84a-4c5d-a9b6-f0a80a4877a1/Pasted text.txt`

## Global Constraints

- Do not implement any new Receiving feature or alter gameplay code.
- Preserve original implementation, correction, and validation chronology; create one new promotion documentation commit without amending or squashing.
- Treat 3.00 m × 2.00 m usable, 3.10 m × 2.10 m support, 0.05 m border, and 2.1 m Receiving reach as the current approved Stage B baseline, not immutable final values.
- Retain Stage A/Expedition ownership, exact-content presentation, TAKE-only behavior, private surfaces, explicit/atomic capacity failure, and absence of PUT/zoning/labels/grids/F6 Receiving surface.
- Preserve irregular frozen piles as rejected historical research and keep follow-on freight fixtures, theatre, capacity tuning, lighting review, and Stage C out of scope.
- Merge only with `git merge --ff-only`; push only `main`; never rebase, force-push, or create a merge commit.

## Review Focus

- Earlier provisional geometry and 3.6 m reach evidence must remain historical rather than being rewritten.
- Human findings and caveats must be recorded without turning current tuning into permanent production constants.
- Concise operational docs must agree that the presenter is live, private, TAKE-only, and does not synthesize a normal-launch batch.
- Pre/post merge verification must show the presenter still coexists with exactly 16 ordinary functional storage surfaces.
- Feature-branch deletion may occur only after `main` and `origin/main` are proven identical.

---

### Task 1: Record human promotion and verify the feature branch

**Files:**
- Modify: `docs/testing/receiving-deterministic-deck-presenter-validation.md`
- Modify: `docs/CURRENT_STATE.md`
- Modify: `docs/CODEX_BOOTSTRAP.md`
- Modify: `docs/README.md`
- Create: `docs/superpowers/plans/2026-09-24-receiving-deck-promotion-closure.md`

**Interfaces:**
- Consumes: reviewed correction branch at `e2a79b137e54e82cc3a8eb525d72e9fb631d0cbd` and the final human PROMOTE decision.
- Produces: one documentation-only promotion commit that Task 2 can fast-forward onto `main`.

- [ ] Preserve all existing validation history, update the current status, and append the final human-review findings, accepted baseline, caveats, disposition, and commit chronology.
- [ ] Replace stale current-state and bootstrap statements with the promoted presenter invariants and conservative next-gate wording.
- [ ] Refresh the README summary and add the focused deterministic-deck validation link without duplicating the validation record.
- [ ] Run the three focused test scripts, editor smoke, and ordinary launch smoke; require exit 0 with no unexpected `SCRIPT ERROR` or `FAIL:` and no synthetic normal-launch batch.
- [ ] Run `git diff --check`, confirm only the five documentation files changed, and commit `docs: promote deterministic Receiving deck presenter`.

### Task 2: Fast-forward, verify, push, and clean up

**Files:**
- No content changes expected.

**Interfaces:**
- Consumes: Task 1's promotion commit and safe direct ancestry from `main`.
- Produces: synchronized `main`/`origin/main`, a deleted local feature branch, and a clean main worktree.

- [ ] Recheck `main`, feature tip, merge base, branch identity, and clean status; stop if fast-forward ancestry is no longer safe.
- [ ] Switch to `main` and run `git merge --ff-only codex/receiving-deterministic-deck`.
- [ ] Run the three focused suites and ordinary launch smoke on merged `main`; require exit 0, no unexpected failure markers, 16 ordinary functional surfaces, a present/private Receiving presenter, and no synthetic normal-launch batch.
- [ ] Push `main` to `origin`, verify `main == origin/main`, then delete `codex/receiving-deterministic-deck` with `git branch -d`.
- [ ] Confirm a clean final worktree on `main` and report the promoted SHA and next active gate.
