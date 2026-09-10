# Stack Metadata Authoring Pipeline Phase 1 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add reusable Stack Role and Auto Group review infrastructure, migrate the nine validated items, seed 31 conservative Stack Role candidates, and stop at deterministic Stack Role Batch 1.

**Architecture:** Extend the existing pure manifest helper to schema `2.0`, add a separate pure registry helper, and isolate the exact 31-item catalogue decisions in one-time `stack_role_authoring.gd` Phase 1 scaffolding. The existing explicit seed/sync command is the only manifest/content writer; the normal audit remains read-only and advances to schema `1.4`.

**Tech Stack:** Godot 4.7, typed GDScript, JSON, `ResourceLoader`/`ResourceSaver`, SHA-256 fingerprints, headless SceneTree tests.

**Spec:** `docs/superpowers/specs/2026-09-10-stack-metadata-authoring-pipeline-phase-1-design.md`

## Global Constraints

- `ItemDefinition` remains runtime/gameplay truth for `can_be_stacked`, `can_support_stack`, and `auto_stack_group`.
- The manifest is the only per-item durable review authority; do not add a second item-review manifest.
- The exact 31-entry table is one-time Phase 1 seed/evidence scaffolding and is not the future 500+ item authoring mechanism.
- Preserve opaque `loot_NNNNNN` keys, absent-scene records, fingerprints, and every scale/pose/Footprint decision and note.
- Normal audit never writes manifest, registry, or item resources.
- Gloves (`loot_000034`) and Pants (`loot_000036`) remain upstream-blocked and receive no provisional role decision.
- Do not author new Auto Groups, add runtime registry management, change stacking algorithms, change pose/Footprint/category/Bulk/Utility data, or begin catalogue gameplay stress testing.
- Phase 1 summaries are exact: Stack Role `42/40/9/31/0/2`; Auto Group `42/9/9/0/0/33`; Registry `4 approved/0 unknown`.
- GDScript warnings are errors.

---

### Task 1: Manifest 2.0 migration and validation

**Files:**
- Modify: `tools/asset_pipeline/authoring_review_manifest.gd`
- Modify: `tools/asset_pipeline/tests/authoring_review_manifest_tests.gd`

**Interfaces:**
- Consumes legacy schema `1.0` or current schema `2.0` dictionaries.
- Produces `migrate_manifest(manifest: Dictionary) -> Dictionary`, `validate_manifest(manifest: Dictionary) -> PackedStringArray`, normalized new review records, and deterministic schema `2.0` serialization.

- [ ] Write failing migration tests that preserve literal non-default old review dictionaries, add both new review defaults, and prove repeated migration/serialization is byte-stable.

```gdscript
var migrated: Dictionary = AuthoringReviewManifestScript.migrate_manifest(legacy)
assert(String(migrated["schema_version"]) == "2.0")
assert((migrated["assets"]["loot_000001"] as Dictionary)["scale_review"] == old_scale)
assert(AuthoringReviewManifestScript.serialize_manifest(migrated) == AuthoringReviewManifestScript.serialize_manifest(AuthoringReviewManifestScript.migrate_manifest(migrated)))
```

- [ ] Run `authoring_review_manifest_tests.gd` and verify RED because `migrate_manifest` and schema `2.0` are absent.
- [ ] Implement minimal pure migration and normalization: duplicate every legacy review field, add literal new defaults, sort keys/flags, and never resnapshot completed reviews.
- [ ] Add failing validation tests for unknown statuses, both unknown flag classes, non-array flags, and non-string notes; each assertion names the malformed field.
- [ ] Run and verify RED, then implement the two status values and eleven exact flag values from the spec with structured errors.
- [ ] Run the focused suite and verify GREEN without warnings.

### Task 2: Approved Auto Stack Group registry

**Files:**
- Create: `tools/asset_pipeline/auto_stack_group_registry.gd`
- Create: `tools/asset_pipeline/auto_stack_group_registry.json`
- Create: `tools/asset_pipeline/tests/auto_stack_group_registry_tests.gd`

**Interfaces:**
- Produces `load_registry`, `serialize_registry`, `validate_registry`, `validate_reference`, and `compatibility_revision` pure APIs.
- Classes are keyed by stable ID and contain `approval_status`, `compatibility_revision`, and `description`.

- [ ] Write failing tests proving the literal four-class fixture validates, empty string is valid, unknown string fails, an array of two IDs fails as multiple, malformed class records fail, and serialization is deterministic.

```gdscript
assert(AutoStackGroupRegistryScript.validate_reference("", registry).is_empty())
assert(not AutoStackGroupRegistryScript.validate_reference("unknown_group", registry).is_empty())
assert(not AutoStackGroupRegistryScript.validate_reference(["flat_media", "boxed_food"], registry).is_empty())
```

- [ ] Run the new suite and verify RED because the helper is absent.
- [ ] Implement schema `1.0` validation with lowercase snake-case IDs, status `APPROVED`, positive integer revisions, non-empty descriptions, and exactly zero or one string reference.
- [ ] Add the four revision-1 production entries with the exact approved descriptions; add no proposal or runtime mechanism.
- [ ] Run the suite against synthetic and production registries and verify GREEN.

### Task 3: Stack Role and Auto Group currentness

**Files:**
- Modify: `tools/asset_pipeline/authoring_review_manifest.gd`
- Modify: `tools/asset_pipeline/tests/authoring_review_manifest_tests.gd`

**Interfaces:**
- Extends `review_evidence(record, current_asset, registry = {})` with eligibility/current/stale/blocked fields.
- Produces `stack_role_snapshot(current_asset)` for explicit approval operations.

- [ ] Write failing tests proving unresolved pose and unresolved/stale Footprint block Stack Role and unreviewed records are not stale.
- [ ] Write failing snapshot tests that separately mutate source fingerprint, rotation, Footprint, and each role boolean; add display-name and category/Bulk/Utility mutations that remain current.
- [ ] Run and verify RED, then implement exact five-field snapshot comparison gated by current approved pose and Footprint.
- [ ] Write failing Auto Group tests for missing current Stack Role, changed group, changed copied Stack Role snapshot, unknown class, compatibility revision change, description-only edit, and approved empty group at revision `0`.
- [ ] Run and verify RED, then implement Auto Group comparison without consulting registry descriptions.
- [ ] Run all manifest and registry suites and verify GREEN.

### Task 4: One-time Phase 1 evidence and candidate seed

**Files:**
- Create: `tools/asset_pipeline/stack_role_authoring.gd`
- Modify: `tools/asset_pipeline/seed_or_sync_item_authoring_review.gd`
- Create: `tools/asset_pipeline/tests/stack_role_authoring_tests.gd`
- Modify: `tools/asset_pipeline/item_authoring_review.json`
- Modify: the exact 31 eligible, non-grandfathered `data/items/definitions/loot_*.tres` resources.

**Interfaces:**
- Produces one-time `apply_phase_1(manifest, current_assets, registry)` evidence and `candidate_for(item_id)`.
- Adds explicit command switch `--apply-stack-metadata-phase-1`; ordinary sync never calls the Phase 1 table.
- Validates the complete set before the first resource or manifest save.

- [ ] Write failing exact-set/guardrail tests: nine grandfathered, 31 candidates, two blocked, union equals literal 42 IDs, no Gloves/Pants candidate, every candidate group empty, and generic future `loot_999999` review flow independent of the Phase 1 table.
- [ ] Write failing table-driven tests using the exact decisions below; every literal expected value is independent of production code.

| ID | stacked / supports | Flags | Batch |
|---|---|---|---|
| `loot_000001` | `true / false` | `IRREGULAR_SHAPE`, `SUPPORT_SURFACE_AMBIGUOUS` | irregular rigid |
| `loot_000003` | `true / false` | `SUPPORT_SURFACE_AMBIGUOUS`, `VISUAL_REVIEW_RECOMMENDED` | rigid flat / box-like |
| `loot_000004` | `true / false` | `IRREGULAR_SHAPE`, `SUPPORT_SURFACE_AMBIGUOUS` | irregular rigid |
| `loot_000007` | `true / true` | none | rigid flat / box-like |
| `loot_000008` | `true / true` | none | cylindrical / container-like |
| `loot_000010` | `true / true` | none | cylindrical / container-like |
| `loot_000011` | `false / false` | `IRREGULAR_SHAPE`, `RESTING_STABILITY_AMBIGUOUS`, `SOFT_OR_DEFORMABLE_FORM`, `VISUAL_REVIEW_RECOMMENDED` | soft / apparel-like |
| `loot_000012` | `false / false` | `IRREGULAR_SHAPE`, `RESTING_STABILITY_AMBIGUOUS` | irregular rigid |
| `loot_000013` | `true / false` | `IRREGULAR_SHAPE`, `RESTING_STABILITY_AMBIGUOUS`, `SUPPORT_SURFACE_AMBIGUOUS` | long / narrow |
| `loot_000014` | `true / false` | `IRREGULAR_SHAPE`, `SUPPORT_SURFACE_AMBIGUOUS`, `VISUAL_REVIEW_RECOMMENDED` | irregular rigid |
| `loot_000015` | `true / false` | `SUPPORT_SURFACE_AMBIGUOUS` | cylindrical / container-like |
| `loot_000016` | `true / false` | `SUPPORT_SURFACE_AMBIGUOUS`, `VISUAL_REVIEW_RECOMMENDED` | cylindrical / container-like |
| `loot_000017` | `true / false` | `SUPPORT_SURFACE_AMBIGUOUS` | cylindrical / container-like |
| `loot_000018` | `true / false` | `SUPPORT_SURFACE_AMBIGUOUS` | cylindrical / container-like |
| `loot_000020` | `true / false` | `SUPPORT_SURFACE_AMBIGUOUS` | rigid flat / box-like |
| `loot_000021` | `true / false` | `SUPPORT_SURFACE_AMBIGUOUS` | rigid flat / box-like |
| `loot_000022` | `true / true` | none | cylindrical / container-like |
| `loot_000023` | `true / true` | none | cylindrical / container-like |
| `loot_000024` | `true / true` | none | cylindrical / container-like |
| `loot_000025` | `true / true` | none | cylindrical / container-like |
| `loot_000026` | `true / false` | `SOFT_OR_DEFORMABLE_FORM`, `SUPPORT_SURFACE_AMBIGUOUS` | soft / apparel-like |
| `loot_000027` | `true / true` | `VISUAL_REVIEW_RECOMMENDED` | cylindrical / container-like |
| `loot_000029` | `false / false` | `IRREGULAR_SHAPE`, `RESTING_STABILITY_AMBIGUOUS` | irregular rigid |
| `loot_000032` | `false / false` | `IRREGULAR_SHAPE`, `RESTING_STABILITY_AMBIGUOUS`, `SOFT_OR_DEFORMABLE_FORM`, `POSE_DEPENDENT`, `VISUAL_REVIEW_RECOMMENDED` | soft / apparel-like |
| `loot_000033` | `true / false` | `IRREGULAR_SHAPE`, `SUPPORT_SURFACE_AMBIGUOUS` | irregular rigid |
| `loot_000035` | `true / false` | `IRREGULAR_SHAPE`, `SUPPORT_SURFACE_AMBIGUOUS` | irregular rigid |
| `loot_000037` | `true / false` | `IRREGULAR_SHAPE`, `SUPPORT_SURFACE_AMBIGUOUS` | long / narrow |
| `loot_000038` | `true / false` | `IRREGULAR_SHAPE`, `SUPPORT_SURFACE_AMBIGUOUS` | long / narrow |
| `loot_000040` | `true / false` | `IRREGULAR_SHAPE`, `SUPPORT_SURFACE_AMBIGUOUS` | long / narrow |
| `loot_000041` | `false / false` | `IRREGULAR_SHAPE`, `RESTING_STABILITY_AMBIGUOUS`, `POSE_DEPENDENT`, `VISUAL_REVIEW_RECOMMENDED` | long / narrow |
| `loot_000042` | `true / false` | `IRREGULAR_SHAPE`, `SOFT_OR_DEFORMABLE_FORM`, `SUPPORT_SURFACE_AMBIGUOUS` | long / narrow |

- [ ] Run the new suite and verify RED because the Phase 1 helper is absent.
- [ ] Implement the one-time helper with explicit comments forbidding future catalogue use. Store the full one-sentence rationales from the physical rubric alongside the table rows.
- [ ] Add synthetic missing/extra eligible-ID tests and verify the helper returns errors with no proposed writes.
- [ ] Run tests and verify GREEN before production mutation.
- [ ] Invoke the explicit command twice. First run reports `9/31/2`; second run reports no semantic writes. Inspect that only the exact 31 `.tres` role values changed, no group was assigned, and Gloves/Pants did not change.
- [ ] Re-run content suites and verify exact runtime values and preserved upstream evidence.

### Task 5: Read-only audit and deterministic Batch 1

**Files:**
- Modify: `tools/asset_pipeline/loot_audit_core.gd`
- Modify: `tools/asset_pipeline/run_main_scene_loot_audit.gd`
- Modify: `tools/asset_pipeline/tests/loot_audit_core_tests.gd`
- Modify: `tools/asset_pipeline/tests/main_scene_loot_audit_integration_tests.gd`
- Create: `tools/asset_pipeline/tests/stack_role_batch_tests.gd`
- Generate: `reports/asset_pipeline/stack_role_batch_1.md`
- Create only if required: `docs/testing/stack-role-batch-1-visual-review.md`

**Interfaces:**
- Audit schema `1.4`, manifest schema `2.0`, registry schema `1.0`.
- Summary keys: `total`, `currently_eligible`, `approved_current`, `unreviewed`, `stale`, `dependency_blocked`.
- Batch 1 IDs: `loot_000003`, `loot_000007`, `loot_000020`, `loot_000021`.

- [ ] Write failing per-item audit and exact production summary tests: Stack Role `42/40/9/31/0/2`, Auto Group `42/9/9/0/0/33`, Registry `4/0`.
- [ ] Add read-only integration coverage comparing manifest and registry bytes before and after ordinary audit.
- [ ] Write failing Batch 1 tests for exact IDs/order, byte-stable repeated Markdown, required evidence columns, one-sentence rationales, and exact APPROVE/ADJUST/HOLD contract.
- [ ] Run focused suites and verify RED against audit `1.3` and absent batch APIs.
- [ ] Implement audit `1.4`, current role fields, review/registry evidence, exact summaries, deterministic JSON/CSV data, and no writes.
- [ ] Implement Batch 1 Markdown and generate only the four rigid package/appliance rows. Add a focused visual handoff only if local evidence remains insufficient.
- [ ] Re-run focused suites, audit, and batch generation twice; verify GREEN and byte equality.

### Task 6: Full regression and completion evidence

**Files:**
- Modify only when a failing regression identifies an in-scope defect; add its failing regression test before the fix.

**Interfaces:**
- Produces fresh verification evidence and the final Phase 1 handoff.

- [ ] Run all new manifest, registry, role-authoring, batch, audit-core, and integration suites.
- [ ] Run existing authoring-review, catalogue/coverage/seed, scale/pose/Footprint, and definition-seeder suites.
- [ ] Run support metadata, stack rules/surface/clearance/interaction, unstacked equivalence, category/zoning, interaction smoke, and storage visual pose suites.
- [ ] Run the 42-item main-scene audit and inspect exact Phase 1 summaries and zero unknown references.
- [ ] Run the Godot parser/editor scan:

```powershell
& 'D:\AI Tools\Godot-4.7-Codex\Godot_v4.7-stable_win64_console.exe' --headless --editor --path 'D:\Godot Projects\Sorting-apoc-PROTOTYPE' --quit
```

- [ ] Run `git diff --check`, inspect the full diff and final `git status --short`, and verify the completion gate line by line.
- [ ] Request focused code review; fix Critical/Important findings test-first and rerun affected plus full verification.
- [ ] Stop after presenting Stack Role Batch 1 and explicitly confirm Auto Group candidate authoring and catalogue-scale gameplay stress testing did not begin.
