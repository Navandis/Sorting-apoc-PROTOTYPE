# EAF5 Pass 6B Finish Layouts Implementation Plan

> **For agentic workers:** Use superpowers:executing-plans to implement this plan task by task. The supplied Pass 6B request is the approved design.

**Goal:** Record Pass 6A decisions and produce a verified 13-configuration bounded finish-layout review package.

**Architecture:** Correct physical UV scale inside the existing EnvironmentMaterialPatch EAF3 mode, leaving EAF4 source mode intact. Add room-specific composition and capture to the existing EAF5 proof, then validate and package captures with the existing Python/Pillow workflow.

**Tech Stack:** Godot 4.7 GDScript, Python unittest and Pillow, PowerShell, Git.

**Spec:** User-provided Pass 6B request attached to this task.

## Global Constraints

- Work on `codex/eaf5-receiving-proof`; no merge or push.
- Preserve accepted composition hash `8361ed7d1d211f40c253cc7bf76821b9d141ab303b0fe7a6573208216f05339d` and 14 geometry fingerprints.
- Preserve Pass 6A ZIP hash `e8bfa330e836687b2fe869a938bf7ed3181ca1a0f076d0d531a32293e6bda66b`.
- EAF4 wear, structural secondary and Receiving C1 remain off.
- Do not modify protected production Receiving and wing paths.

## Review Focus

- Patch UVs must span metres for EAF3 and stay normalized for EAF4 source.
- A02 transient UV must preserve its approved triplanar catalog resource.
- L01/L02 must fit on the occupied ReceivingSouth face with structural margins.
- Each capture must use the same fixed placement, camera and lights within its layout.
- Controls must reproduce the accepted no-finish structural images.

### Task 1: Human decisions and owner scale

- [x] Add Pass 6A decision record; verify 6 controls, 4 KEEP, 7 HOLD, 19 DROP.
- [x] Add failing Godot mesh UV tests for EAF3 at 1.5×1.5, 3.0×1.5 and 4.2×2.4 m and EAF4 normalized semantics.
- [x] Correct EAF3 patch mesh in its owner class; run EAF4B tests and commit the bounded fix.

### Task 2: Layout composition and proof tests

- [x] Add failing tests for exact matrix, receiving-only patch, unchanged structure, UV mapping and layout geometry.
- [x] Extend the existing proof and capture tooling with fixed L01/L02 placement, a fixed FinishPatch camera and 13 configurations.
- [x] Run Godot proof/capture tests and technical material-scale sanity.

### Task 3: Sanity, package and validation

- [x] Render and inspect the 20-image artistic sanity gate; stop on failure.
- [x] Render 52 final captures; validate four views each and control equality.
- [x] Build three contact sheets, manifest, summary, decision template and allowlisted ZIP.
- [x] Run EAF5, EAF3B and EAF4B suites, Godot parse/import and production diff checks.
- [x] Close Pass 6A, document Pass 6B, commit locally and report ZIP hash and review gate.
