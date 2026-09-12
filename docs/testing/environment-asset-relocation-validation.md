# Environment / Non-Loot Asset Relocation Validation

## Outcome

The approved environment/non-loot relocation completed on branch
`codex/environment-asset-relocation`. Stage B freight-bay construction did not
begin.

The authoritative migration manifest is `environment-relocation-v1` in
`tools/asset_pipeline/relocate_environment_assets.ps1`. It contains the exact
approved 50-primary source map: 49 canonical `Move` entries and one
`RetireDuplicate` entry.

## Commit series

| Commit | Purpose |
|---|---|
| `c423d09` | Add manifest-driven relocation utility and dry-run test |
| `8bdcd96` | Update referenced architecture/infrastructure paths in `main.tscn` |
| `54a9954` | Update high-risk furniture paths and add imported-root identity regression |

The final validation record is committed separately after all gates pass.

## Approved exclusions

- All 42 unique `ItemCatalog` visual paths remained outside the manifest and
  remained present at their original paths.
- All 18 approved `AMBIGUOUS/HOLD` primaries remained outside the manifest and
  remained present at their original paths.
- `res://assets/props/protection/SM_Gloves_02glb.glb.import` remained untouched.
- `loot_000034` Gloves and `loot_000036` Pants remain the only blocked catalogue
  items.

## Duplicate Hallway Door resolution

The canonical source was
`res://assets/building_blocks/SM_Hallway_Door_02b.glb`. Immediately before the
Batch 3 mutation, the utility rechecked SHA-256 hashes for the GLB and all four
supporting PNG sources against the duplicate family under `assets/furniture`.
Every source matched.

The canonical family moved to
`res://assets/environment/architecture/doors/SM_Hallway_Door_02b.glb`. The
byte-identical duplicate GLB, four duplicate PNG sources, and their five import
sidecars were retired. No destination was overwritten.

## File counts

| Operation | Primary GLBs | Supporting PNG sources | `.import` sidecars | Total files |
|---|---:|---:|---:|---:|
| Moved | 49 | 264 | 313 | 626 |
| Retired duplicate | 1 | 4 | 5 | 10 |
| Final `assets/environment` | 49 | 264 | 313 | 626 |

The six now-empty former source directories were removed after their emptiness
was verified. Godot then regenerated its filesystem cache; no old environment
source-directory paths remained in `.godot/editor`.

## Destination category summary

| Category | Canonical primaries |
|---|---:|
| `architecture/floors` | 6 |
| `architecture/walls` | 7 |
| `architecture/doors` | 2 |
| `infrastructure/lighting` | 4 |
| `infrastructure/pipes` | 9 |
| `infrastructure/electrical` | 2 |
| `infrastructure/communications` | 1 |
| `furniture/storage` | 4 |
| `furniture/work_surfaces` | 2 |
| `furniture/seating` | 1 |
| `furniture/miscellaneous` | 1 |
| `dressing/debris` | 4 |
| `dressing/decals` | 2 |
| `dressing/containers` | 3 |
| `dressing/decoration` | 1 |
| **Total** | **49** |

The approved classification count was 50 before the two identical Hallway Door
families collapsed to one canonical destination.

## Importer and UID handling

The utility moved each source beside its existing `.import` sidecar. It
preserved the complete importer parameter block and UID, changing only the
resource source path and the deterministic MD5-derived `.godot/imported` path
hash. Godot then performed the authoritative rescan/reimport after every batch
and after each high-risk family.

Final checks found:

- 313 environment sidecars and zero missing/mismatched source references;
- 601 asset import UIDs project-wide and zero duplicate UID groups;
- unchanged `uid=` values in the 19 updated `main.tscn` `ext_resource` entries;
- zero stale old environment paths in tracked `.gd`, `.tscn`, or `.tres` files;
- zero stale old environment paths in `.godot/editor` after regeneration.

Generated `.godot` cache files were never hand-edited.

## Execution batches

| Batch | Scope | Moved source files | Moved sidecars | Retired source/sidecars | Gate result |
|---|---|---:|---:|---:|---|
| 1 | Tooling, manifest, dry-run test | 0 | 0 | 0 | Dry-run preflight PASS; committed as `c423d09` |
| 2 | Low-risk unreferenced families | 117 | 117 | 0 | Godot reimport exit 0; dry-run contract PASS |
| 3 | Name-sensitive families and duplicate door | 84 | 84 | 5 / 5 | Immediate hash recheck PASS; Godot reimport exit 0 |
| 4 | Referenced architecture/infrastructure | 85 | 85 | 0 | Main parse, loot-audit integration, pickup registration PASS |
| 5a | Clothes Cabinet | 5 | 5 | 0 | Root identity, main, storage profile/clearance PASS |
| 5b | Table | 12 | 12 | 0 | Root identity, main, storage profile/clearance PASS |
| 5c | Metal Shelves | 5 | 5 | 0 | Root identity and exact surface/clearance regressions PASS |
| 5d | Ventilated Locker | 5 | 5 | 0 | Root identity and exact surface/clearance regressions PASS |

Batch 2 and Batch 3 changed only ignored asset state, so there was no tracked
content to commit for those individual gates. The project deliberately keeps
`assets/` ignored; the migration did not change that repository policy.

## Final verification

| Gate | Result |
|---|---|
| Manifest verify | 50 complete, 0 pending, preflight PASS |
| PowerShell dry-run contract | PASS |
| Asset-pipeline suites | 31/31 PASS; every suite exit 0; no `SCRIPT ERROR` or `FAIL:` |
| Fresh loot audit | 42 assets; exit 0; CSV/JSON SHA-256 unchanged |
| Stack Role reviews | 40 approved; Gloves/Pants only blocked |
| Auto Group reviews | 40 approved; Gloves/Pants only blocked |
| Main scene runtime | Exit 0 |
| Environment collision registration | 30 trimesh meshes; 9 convex meshes |
| Storage profile installation | 16 deterministic surfaces |
| Imported high-risk root names | Clothes Cabinet, Table, Metal Shelves, and Ventilated Locker unchanged |
| Environment sources | 49 GLB, 264 PNG, 313 sidecars present |
| Loot sources | 42/42 present at original paths |
| HOLD sources | 18/18 present at original paths |
| Duplicate UID groups | 0 |
| Stale tracked environment paths | 0 |
| `git diff --check` | PASS |

Godot consistently emitted the known local
`Failed to read the root certificate store` diagnostic. It did not affect exit
codes, imports, parsing, runtime initialization, audits, or tests.

## Deviations

There were no deviations from the approved map or duplicate-resolution policy.
The existing loot-specific `relocate_assets.ps1` was not generalized or used for
this migration.

## Stage B boundary

No freight-bay scene, hierarchy, geometry, presenter, shutter behavior, light
behavior, collision design, or Receiving Stage B functionality was created or
changed. This work only organized the approved source assets and updated their
existing authored paths.
