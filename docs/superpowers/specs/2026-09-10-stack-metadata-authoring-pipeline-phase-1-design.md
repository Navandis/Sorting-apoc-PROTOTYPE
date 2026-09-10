# Stack Metadata Authoring Pipeline Phase 1 Design

## Purpose and scope

Phase 1 extends the existing durable item-authoring review pipeline with Stack Role and Auto Group review dimensions, creates an approved auto-stack-group registry, migrates the nine playtested spike items as explicit evidence, and seeds conservative Stack Role candidates for the other 31 eligible items. It stops after producing Stack Role Batch 1 for human authoring review.

`ItemDefinition` remains runtime truth for `can_be_stacked`, `can_support_stack`, and `auto_stack_group`. Review state, approval snapshots, flags, and notes remain authoring evidence and never participate in runtime stacking. This phase does not change stacking mechanics, upstream pose or Footprint decisions, Auto Group authoring beyond grandfathering, or catalogue-scale gameplay validation.

## Chosen architecture

The implementation extends the existing manifest and audit seams instead of creating a second item-review store:

- `authoring_review_manifest.gd` owns manifest migration, normalization, Stack Role and Auto Group freshness, dependency state, validation, and deterministic serialization.
- `auto_stack_group_registry.gd` owns registry parsing, normalization, and validation. It has no runtime manager or gameplay dependency.
- `stack_role_authoring.gd` contains the explicit Phase 1 evidence migration, the exact 31-entry conservative candidate table, eligibility checks, and deterministic Batch 1 row generation.
- `seed_or_sync_item_authoring_review.gd` remains the only durable manifest writer. New Phase 1 behavior is available only through an explicit command-line switch; ordinary sync does not approve, resnapshot, or seed Stack Role values.
- `run_main_scene_loot_audit.gd` reads manifest and registry state and reports evidence without writing either file.

This keeps the manifest helper focused on reusable review semantics, the registry independently testable, and catalogue-specific candidate judgment outside generic schema code.

## Durable manifest schema 2.0

`tools/asset_pipeline/item_authoring_review.json` advances from schema `1.0` to `2.0`. Existing opaque `loot_NNNNNN` keys and all existing record fields remain unchanged. Each asset record adds the following dimensions:

```json
{
  "stack_role_review": {
    "status": "UNREVIEWED",
    "reviewed_source_fingerprint": "",
    "reviewed_rotation_degrees": [0.0, 0.0, 0.0],
    "reviewed_footprint": [0, 0, 0],
    "reviewed_can_be_stacked": false,
    "reviewed_can_support_stack": false,
    "flags": [],
    "notes": ""
  },
  "auto_group_review": {
    "status": "UNREVIEWED",
    "reviewed_stack_role_snapshot": {},
    "reviewed_auto_stack_group": "",
    "reviewed_registry_compatibility_revision": 0,
    "flags": [],
    "notes": ""
  }
}
```

Both dimensions accept only `UNREVIEWED` and `APPROVED`. An `APPROVED` empty Auto Group stores an empty `reviewed_auto_stack_group` and compatibility revision `0`; it is a complete deliberate decision, not missing data.

The Stack Role snapshot contains the current source fingerprint, approved storage rotation, approved Footprint, and both current role booleans. A current Stack Role approval requires current approved Storage Pose and Footprint plus an exact match to every snapshot field. Display name, Storage Category, Bulk, and Utility are deliberately absent from this snapshot.

The Auto Group snapshot stores a copy of the approved Stack Role snapshot, the current group ID, and compatibility revision. A current Auto Group approval requires the Stack Role approval to remain current, the copied Stack Role snapshot to match it, the current group value to match, and a non-empty referenced registry class to remain approved at the snapshotted compatibility revision. Registry description text is deliberately absent.

Migration is a pure `1.0 -> 2.0` transformation followed by deterministic normalization. It copies every prior scale, pose, Footprint, identity, path, fingerprint, note, and absent-scene record before adding the two new dimensions. Loading legacy data may migrate it in memory for read-only consumers, but only the explicit Phase 1 seed/migration command may persist schema `2.0`. Reapplying migration to `2.0` is byte-stable and does not rewrite any approval snapshot.

## Auto Stack Group registry schema 1.0

`tools/asset_pipeline/auto_stack_group_registry.json` uses a keyed object so stable IDs are unique by construction:

```json
{
  "schema_version": "1.0",
  "classes": {
    "flat_media": {
      "approval_status": "APPROVED",
      "compatibility_revision": 1,
      "description": "Compatible flat media intended to form predictable narrowing automatic stacks."
    }
  }
}
```

Class IDs must match lowercase snake case, descriptions must be non-empty, approval status must be `APPROVED`, and compatibility revisions must be positive integers. Candidate generation never adds registry entries. Registry validation rejects malformed class records, unknown item references, non-string or multiple group references, and invalid compatibility revisions. Empty string is the valid zero-group representation.

The initial registry contains these four approved revision-1 classes:

- `flat_media`: compatible flat media intended to form predictable narrowing automatic stacks.
- `round_cans`: standard cylindrical canned goods intended to stack vertically even across Storage Categories where zone policy permits.
- `boxed_food`: compatible rigid boxed-food packages intended to auto-stack.
- `medical_boxes`: compatible rigid medical packages intended to auto-stack.

Only `compatibility_revision` expresses semantic compatibility change. Editing `description` alone cannot stale an item approval.

## Structured review evidence

Stack Role flags are restricted to:

- `IRREGULAR_SHAPE`
- `SUPPORT_SURFACE_AMBIGUOUS`
- `RESTING_STABILITY_AMBIGUOUS`
- `SOFT_OR_DEFORMABLE_FORM`
- `POSE_DEPENDENT`
- `VISUAL_REVIEW_RECOMMENDED`

Auto Group flags are restricted to:

- `NEW_GROUP_CANDIDATE`
- `GROUP_MEMBERSHIP_AMBIGUOUS`
- `PLAYER_EXPECTATION_AMBIGUOUS`
- `CROSS_CATEGORY_REVIEW`
- `VISUAL_REVIEW_RECOMMENDED`

Flags are sorted in vocabulary order during normalization; duplicates are removed. Unknown flags, non-array flags, non-string flag values, and non-string notes fail validation. Notes are short authoring evidence only.

## Eligibility, state, and staleness

Each audit record exposes `eligible`, `status`, `current`, `stale`, and `dependency_blocked` evidence for each new dimension.

Stack Role is eligible only when Storage Pose is approved/current and Footprint is approved/current. An approved Stack Role becomes non-current when the source fingerprint, approved storage rotation, approved Footprint, or either role boolean differs. An approved record that no longer matches its snapshot is stale; loss of an upstream dependency also marks it dependency-blocked.

Auto Group is eligible only when Stack Role is approved/current. It becomes non-current when Stack Role becomes non-current, the current group value changes, the snapshotted Stack Role dependency changes, the registry reference becomes invalid or unapproved, or the referenced compatibility revision changes. A description-only registry change has no effect.

Unreviewed decisions are never reported as stale. Dependency blocking and staleness are separate booleans, allowing an old approval to be both stale and currently blocked while summary counts remain explicit.

## Explicit evidence migration and candidate seeding

The Phase 1 apply command operates from a fixed catalogue evidence table and refuses to mutate if the current eligible, grandfathered, blocked, or registry sets differ from expectations. It is deterministic and idempotent.

The exact grandfathered decisions are:

| Item ID | Asset | can_be_stacked | can_support_stack | auto_stack_group |
|---|---|---:|---:|---|
| `loot_000002` | `SM_ComputerTower_01` | false | true | empty |
| `loot_000005` | `cereal_box` | true | true | `boxed_food` |
| `loot_000006` | `SM_Bread_1` | true | false | empty |
| `loot_000009` | `SM_Dry_Goods_01c` | true | true | `round_cans` |
| `loot_000019` | `SM_Metal_Can_01a` | true | true | `round_cans` |
| `loot_000028` | `SM_MedKit_4` | true | true | `medical_boxes` |
| `loot_000030` | `SM_Book_01` | true | true | `flat_media` |
| `loot_000031` | `SM_CDStack_01` | true | true | `flat_media` |
| `loot_000039` | `SM_Gun_Pistol` | true | false | empty |

For those records only, the command snapshots the current Stack Role and Auto Group decisions as `APPROVED`. The remaining 31 eligible items receive explicit, visually informed conservative role values in their `.tres` resources and durable Stack Role flags/notes, while their Stack Role status stays `UNREVIEWED`. Their Auto Group review remains untouched and dependency-blocked; no group is proposed or assigned.

`loot_000034` (Gloves) and `loot_000036` (Pants) are asserted to remain upstream-blocked. The command neither changes their `.tres` role fields nor writes candidate flags or notes for them.

Candidate decisions apply the centered, single-column stored-pose rubric. A fixed per-item table records the booleans, flags, one-sentence rationale, physical-form batch, and stable order. Geometry and bounds are supporting evidence only; no shape rule infers approval or creates a group.

## Batch 1 handoff

The authoring helper groups the 31 candidates primarily by stored physical form and generates only Batch 1 during this phase. The first batch is the rigid flat/box-like group because it presents the clearest high-confidence role decisions before ambiguous irregular and soft forms.

The disposable report is `reports/asset_pipeline/stack_role_batch_1.md`. Each deterministic row contains only stable ID, display name and asset, Storage Category, approved Footprint, approved rotation, the two candidate booleans, flags, and one-sentence rationale. It ends with the exact response contract:

```text
loot_XXXXXX — APPROVE
loot_XXXXXX — ADJUST: true / false
loot_XXXXXX — HOLD
```

No absent response is interpreted as approval. If local visual inspection leaves any Batch 1 decision dependent on in-game evidence, a proportional fixture and document is added under `docs/testing/`; this is authoring evidence, not the deferred catalogue stress test.

## Audit output

The main-scene audit advances from schema `1.3` to `1.4` and records manifest schema `2.0` and registry schema `1.0`. Per-item output adds current runtime role values, both review dimensions and flags, registry reference validity, and dependency evidence. Summary output adds Stack Role and Auto Group counts for eligible, approved/current, unreviewed, stale, and dependency-blocked, plus registry approved class count, unknown references, invalid/multiple references, compatibility-revision issues, and zero pending candidate-group proposals.

Normal audit loads and validates data without invoking any writer. A focused test hashes or compares manifest and registry bytes before and after audit execution.

## Error handling and validation

Pure helpers return structured errors for invalid schemas, statuses, flags, snapshots, registry records, and group references. Explicit mutating commands print all errors and exit non-zero before their first write. Resource changes are computed and validated as a complete set before saving, so a catalogue-set mismatch cannot partially seed candidates.

Serialization sorts authoring keys, registry IDs, and flag arrays. Batch rows use fixed form order and stable item ID order. Existing warnings-as-errors discipline remains unchanged.

## Test strategy

Implementation follows red-green-refactor cycles with synthetic dictionaries and temporary files for stale and invalid cases. Tests cover:

- `1.0 -> 2.0` preservation, deterministic serialization, and idempotent migration;
- registry acceptance of the four initial classes and rejection of malformed, unknown, or multiple references;
- empty approved groups and the complete review flag vocabularies;
- Stack Role upstream dependencies and every snapshot stale trigger, with unrelated display/category/Bulk/Utility changes proving irrelevant;
- Auto Group dependency currentness, Stack Role changes, registry compatibility revisions, and description-only edits;
- exact-nine grandfathering and proof that no tenth item is approved;
- exact 31 candidate records, unchanged blocked Gloves/Pants, and no new group assignments;
- deterministic Batch 1 generation and required row evidence;
- read-only audit execution and exact Phase 1 summary counts;
- all existing scale, pose, Footprint, catalogue, stacking, category/zoning, audit, interaction, main-scene, and parser/editor regressions requested by the task.

Completion claims require a fresh full verification run and `git diff --check`. Phase 1 stops at the Batch 1 authoring handoff; it does not begin Auto Group review or catalogue-scale gameplay stress testing.
