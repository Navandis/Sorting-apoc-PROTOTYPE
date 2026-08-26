# Authoring Review Manifest Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a durable authoring-review manifest, a separate seed/sync command, and read-only audit evidence for stale human reviews.

**Architecture:** A new pure `AuthoringReviewManifest` helper handles JSON, SHA-256 fingerprints, conservative correlation, monotonic keys, and freshness. The audit enriches measured records from this helper but never writes it; a separate scene-driven command seeds or syncs it.

**Tech Stack:** Godot 4.7, GDScript, JSON, `FileAccess`, SHA-256 `HashingContext`.

**Spec:** `docs/superpowers/specs/2026-08-26-authoring-review-manifest-design.md`

## Global Constraints

- Preserve `main.tscn`, `prototype_item_catalog.gd`, and all gameplay ItemDefinitions.
- Manifest schema is exactly `1.0`; audit schema is exactly `1.2`.
- Only the explicit seed/sync command writes `tools/asset_pipeline/item_authoring_review.json`.
- Existing authoring keys never renumber or reuse a lower missing suffix.
- Unreviewed dimensions must not emit stale-decision flags.

---

### Task 1: Manifest helper and unit tests

**Files:**
- Create: `tools/asset_pipeline/authoring_review_manifest.gd`
- Create: `tools/asset_pipeline/tests/authoring_review_manifest_tests.gd`

**Interfaces:**
- Produces `empty_manifest()`, `seed_or_sync()`, `correlate_records()`, `review_evidence()`, `fingerprint_for_path()`, and deterministic JSON methods.

- [ ] Write failing tests for monotonic keys, repeat sync, unique/ambiguous fingerprint matching, completed-decision freshness, and deterministic serialization.
- [ ] Run the test script and confirm it fails because the helper is absent.
- [ ] Implement the smallest helper API needed for each failing behavior, including SHA-256 fingerprints and tolerant rotation comparison.
- [ ] Re-run the helper tests until they pass without warnings.

### Task 2: Explicit manifest seed/sync command

**Files:**
- Create: `tools/asset_pipeline/seed_or_sync_item_authoring_review.gd`

**Interfaces:**
- Consumes scene records and ItemDefinition correlation values; calls `AuthoringReviewManifest.seed_or_sync()` and writes only the manifest path.

- [ ] Extend the test fixture to run sync against controlled scene-like records and assert initial records are unreviewed.
- [ ] Run the fixture and confirm the seed-command-facing behavior is initially unavailable.
- [ ] Implement the command using the existing main-scene adapter and catalogue lookup, preserving absent manifest records and reporting updates/ambiguities.
- [ ] Run the tests and command against the current project.

### Task 3: Read-only audit enrichment

**Files:**
- Modify: `tools/asset_pipeline/run_main_scene_loot_audit.gd`
- Modify: `tools/asset_pipeline/loot_audit_core.gd`
- Modify: `tools/asset_pipeline/tests/loot_audit_core_tests.gd`

**Interfaces:**
- Consumes manifest records and exposes audit record fields `authoring_key`, `source_fingerprint`, three review status/current values, plus deterministically ordered review flags.

- [ ] Add failing assertions for schema `1.2`, output fields, and stale/ambiguous flags.
- [ ] Run the existing audit test script and confirm the new expectations fail.
- [ ] Enrich audit records from a read-only loaded manifest and append review flags through the centralized flag ordering helper; extend CSV fields.
- [ ] Run all audit tests and generate the reports twice to compare byte-for-byte.

### Task 4: Seed, regression verification, and scope audit

**Files:**
- Create: `tools/asset_pipeline/item_authoring_review.json`
- Modify: generated audit reports under `reports/asset_pipeline/`

- [ ] Run seed/sync twice and confirm the second run makes no duplicate keys or writes semantic changes.
- [ ] Run the main-scene audit twice and compare reports.
- [ ] Run storage-category tests, audit-core tests, manifest tests, Godot parser/editor scan, and `git diff --check`.
- [ ] Inspect the final diff to confirm no gameplay files or user-authored scene/catalogue values changed.
