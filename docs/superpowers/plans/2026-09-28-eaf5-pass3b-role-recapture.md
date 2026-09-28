# EAF5 Pass 3B Role Recapture Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task by task. Steps use checkbox syntax for tracking.

**Goal:** Produce v2 role evidence against the accepted Pass-3A shell and leave human survivor decisions pending.

**Architecture:** Reuse the existing proof scene, live EAF3 query, fixed cameras and lighting, and allowlisted Python package builder. Gate role capture on the v1 candidate IDs and accepted v2 shell fingerprints; run a 12-image sample before the full matrix.

**Tech Stack:** Godot 4.7 GDScript, Python 3, Pillow, unittest.

**Spec:** The user's attached Pass-3B request at `C:/Users/Boschetar/.codex/attachments/91af9f81-fb1a-4b14-8e6d-f518fb12bbd6/Pasted text.txt`.

## Global Constraints

- Work on `codex/eaf5-receiving-proof`; no merge or push.
- Keep composition v2, all 14 EAF2 specs/fingerprints, and the accepted shell ZIP unchanged.
- Preserve all v1 role ZIPs; create only new `*_role_review_02.zip` packages.
- Keep wear, applied finish, structural secondary, palette pairing, and Receiving C1 off.

## Review Focus

- Catalog membership or approval drift aborts before image capture.
- Sample captures use the same renderer and role application as full captures.
- Other roles and review-only context stay neutral.
- Every new role manifest carries the accepted v2 composition hash and 14 fingerprints.
- ZIPs contain only allowlisted review evidence and fresh PENDING templates.

### Task 1: Capture gate and sanity set

**Files:** `gameplay/dev/environment_receiving_proof/environment_receiving_proof_capture.gd`; `tools/asset_pipeline/tests/environment_receiving_capture_tests.gd`; `tools/environment_authoring/receiving_proof/tests/test_pass3_evidence.py`.

**Interfaces:** `role_capture_records(sample_only: bool)`, `role_capture_directory(sample_only: bool)`, `validate_role_candidates()`, and `validate_accepted_shell()` feed the existing capture path.

- [x] Write and run the failing Godot test for sample records and v2 gate.
- [x] Implement the gated sample/full route and rerun the Godot test.
- [x] Write and run the failing sanity-manifest regression test; make it pass.
- [x] Capture and visually inspect 12 sample images.

### Task 2: Full role packages

**Files:** `tools/environment_authoring/receiving_proof/build_pass3_review.py`; `tools/environment_authoring/receiving_proof/tests/test_pass3_package.py`; `reports/environment_receiving_proof/eaf5/role_isolation_02/`.

**Interfaces:** Existing `build_role_package(folder, output)` writes contact sheets, summaries, decision templates, and allowlisted ZIPs.

- [x] Write and run the failing package-summary test; update metadata and summary content.
- [x] Capture all 132 images with the gated full route.
- [x] Build three role ZIPs and verify record counts, pending decisions, hashes and integrity.

### Task 3: Validation and local commit

**Files:** `docs/testing/environment-authoring-eaf5-pass3-shell-role-isolation-validation.md`; `tools/environment_authoring/receiving_proof/tests/test_pass3_evidence.py`.

- [x] Record human shell acceptance, deferred oddity, superseded v1 evidence, and v2 lineage.
- [x] Run EAF5/EAF3B Python and Godot proof/capture/query/live tests plus editor import.
- [x] Verify protected production files and shell hashes before the local commit.
