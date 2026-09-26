# EAF3B selective staging and curated catalog validation

**Status: IMPLEMENTED / TECHNICALLY VERIFIED / HUMAN REVIEW PENDING**

- Date: 26 September 2026.
- Branch: `codex/eaf3b-material-curated-catalog`.
- Verified implementation HEAD: `b2145e34657442a35d4809125548962334c78775`.
- Starting clean `main` and `origin/main`: `26d1a297f260c7a18b1c0d8a9d90683ac8159514` (EAF3A promotion merge).
- EAF3A baseline: source-index schema 1, scanner `eaf3a-1`, profile `KITBASH_PROFILE_V1` revision 1; **HUMAN REVIEW COMPLETE / PROMOTED**.
- EAF3 overall remains in progress. Receiving C1 remains paused. This branch has not been merged or pushed.

## Source snapshot and boundary

At EAF3B start the normal EAF3A scan indexed 5,856 files, 84 package/version records, and 687 stable material candidates. This checkout initially lacked its ignored machine-local `local_config.json`; the tracked example was copied to that location with the stated single root, `D:\AssetPipeline\KitBash_repository`. No alternate root search occurred. `scan_diff.json` reported **0 new, 0 changed, 0 removed, 687 unchanged** candidates and **84 unchanged** packages. Actual indexed texture availability remains **2K only**; advertised 4K descriptor variants were not treated as available files.

Only stable material IDs identify external sources in EAF3B. The batch, decision template, catalog, CLI, and restaging command accept no source-root paths. Every source open uses promoted EAF3A `Repository` and repository-relative paths from its index; traversal, absolute paths, out-of-root paths, and reparse entries are rejected. Source files were read only. EAF3A quick signatures remain discovery/diff signals, while SHA-256 is the EAF3B approval provenance.

## Live Foundation Mineral batch

Tracked batch: [batch.json](../../data/environment/material_catalog/review_batches/foundation_mineral_01/batch.json). It records schema/revision, scan ID and fingerprint, 12 stable IDs, source-triage rationale, 2K policy, and initial mapping/scale hints. Names and triage semantics justify *review selection only*. None is a final VDD or material verdict.

| Group | Stable source IDs |
| --- | --- |
| Structural/rough concrete | `kitbash:kb3d_aftermath@7.0.2:KB3D_AFT_ConcreteA`; `kitbash:kb3d_brooklyn@7.0.2:KB3D_BRK_ConcreteFormed`; `kitbash:kb3d_brutalisttff@7.0.3:KB3D_BTL_ConcreteGrayIndustrial`; `kitbash:kb3d_constructionzone@7.0.3:KB3D_CSZ_ConcreteRoughBright`; `kitbash:kb3d_dtla@7.0.3:KB3D_DLA_ConcretePittedGrayMed`; `kitbash:kb3d_atompunk@7.0.2:KB3D_ATP_ConcreteGrunge` |
| Service-floor concrete | `kitbash:kb3d_brutalisttff@7.0.3:KB3D_BTL_ConcreteFloorGrayA`; `kitbash:kb3d_brutalisttff@7.0.3:KB3D_BTL_ConcreteFloorPanelsRoughA`; `kitbash:kb3d_cyberpunkinteriors@7.0.2:KB3D_CPI_ConcreteFloorDGray` |
| Cement/render | `kitbash:kb3d_aftermath@7.0.2:KB3D_AFT_PlasterA`; `kitbash:kb3d_dieselpunk@7.0.2:KB3D_DPK_PlasterGray`; `kitbash:kb3d_beyondrepair@7.0.0:KB3D_BYR_CODamagedPlasterWallA` |

The first six compare plain, formed, industrial, bright rough, pitted, and grungy concrete source names. The next three compare plain, panelled, and dark floor names. The final three compare plaster/render across packages, including a damaged-wall source with an unsupported Substance graph warning. Per-ID rationale and warnings are in [batch_summary.md](../../reports/environment_material_catalog/reviews/foundation_mineral_01/batch_summary.md).

All 12 requested and received **2K**, with no fallback. The default policy is 2K → indexed 4K → indexed 1K. Explicit 4K re-review requires a new EAF3A scan, confirmed indexed 4K files, and a batch resolution override. The stage record names requested/actual resolution, fallback, available resolutions, channels, unsupported facts, and warnings.

## Staging, fingerprint, and Godot import

The ignored cache is `res://assets/environment/materials/kitbash_cache/<stable-ID-hash>/<resolution>/`. The batch rejects cache/catalog ID collisions. Candidate and later approved specs reuse this single cache. It contains **59 PNGs**, **253,615,056 bytes**, from indexed basecolor, normal, roughness, metallic, and available AO maps. No model, USD, Substance source, preview, vendor metadata, or height EXR was copied. Height is reference-only and excluded from the normal review fingerprint because it is not staged. The staged hashes match the copied bytes for all 59 maps.

The strong review fingerprint is SHA-256 over canonical JSON containing stable ID, actual resolution, each selected map's repository-relative path, SHA-256 and channel-state interpretation, plus profile identity/revision. No source-root path enters it. A source change at the reviewed resolution changes the fingerprint. Parameter adjustments retain source identity and cached bytes.

Godot 4.7's generated ignored `.png.import` state was inspected. Normalization sets `compress/mode=0` (lossless), `mipmaps/generate=true`, `detect_3d/compress_to=0`, and `process/normal_map_invert_y=false` on every staged map; normals use `compress/normal_map=1`, basecolor and scalar maps 0. The final 59 import records and cache SHA-256 values were checked. Basecolor binds to `StandardMaterial3D.albedo_texture`; normal, roughness, metallic and AO bind to data slots. [Godot 4.7's material reference](https://docs.godotengine.org/en/4.7/classes/class_basematerial3d.html) documents albedo sRGB handling, and its [shader reference](https://docs.godotengine.org/en/4.7/tutorials/shaders/shader_reference/shading_language.html#using-source-color) distinguishes color from normal/roughness/metallic data. The [image-import guide](https://docs.godotengine.org/en/4.7/tutorials/assets_pipeline/importing_images.html) documents mipmaps for 3D. The promoted EAF1 builder applies a transient per-spec normal-Y inversion; source PNG bytes remain unchanged. Initial normal Y is SOURCE/not flipped, pending visual confirmation.

## Generated EAF1 review and package

`prepare` generated 12 `EnvironmentSurfaceMaterialSpec` resources and an ordered `EnvironmentMaterialReviewSet` from batch data. Initial 1.0 or 1.5 m per repeat values are **review hints**, not vendor-proven physical scale. Formed and panelled/floor named sources begin in UV mode; quieter non-directional concrete/render begins triplanar. A project-local iteration JSON can change mapping mode, metres per repeat, normal-Y flip, normal strength and roughness/metallic/albedo multipliers. The synthetic test changes two parameters and confirms the cached source map timestamp is unchanged.

EAF1 has a small optional review-set injection seam. Without injection, its promoted four-spec default and 16-record capture matrix remain. Injection changes only the spec list; EAF1 lighting, geometry, cameras/FOV, WorldEnvironment, exposure, and tonemap stay fixed. Its focused test covers both paths and invariants.

```powershell
$py = 'C:\Users\Boschetar\.cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe'
& $py -m tools.environment_authoring.material_catalog.cli prepare --batch foundation_mineral_01
& $py -m tools.environment_authoring.material_catalog.cli capture --batch foundation_mineral_01
```

The capture command ran Godot editor import, normalized import settings, reimported, and invoked EAF1 with `--eaf3b-batch foundation_mineral_01`. It produced **48 decoded 1920×1080 PNGs** under Compatibility (`gl_compatibility`): per candidate Neutral/Hero, Neutral/WallGrazing, Receiving/Hero, Receiving/WallGrazing. Paired lighting records preserve camera transform/FOV, mapping, and scale. All 48 images decoded at the specified dimensions and had distinct image statistics; one Hero capture was visually inspected.

Human review files:

- [Shareable ZIP](../../reports/environment_material_catalog/reviews/foundation_mineral_01_review.zip): exactly 48 captures, `manifest.json`, `batch_summary.md`, and `decision_template.json`. ZIP integrity passed; no commercial maps, `.import` files, or cache directory are inside.
- [Capture manifest](../../reports/environment_material_catalog/reviews/foundation_mineral_01/manifest.json): ordered camera/light evidence and source snapshot anchors.
- [Batch summary](../../reports/environment_material_catalog/reviews/foundation_mineral_01/batch_summary.md): IDs, package/version, channel/warning facts, resolution, hints and rationale.
- [Pending decision template](../../reports/environment_material_catalog/reviews/foundation_mineral_01/decision_template.json): 12 `PENDING` entries with captured strong fingerprints.

These are local ignored reports; tracked batch and generators can reproduce them on this configured machine. The ZIP contains 51 entries and has no bad file.

## Catalog and synthetic technical proof

Tracked schema-1 [catalog.json](../../data/environment/material_catalog/catalog.json) begins empty. Human statuses are APPROVED, REJECTED, DEFERRED. Each record separates source identity/facts, reviewed strong fingerprint/resolution, human fields/revision/date, and current fingerprint/match/effective status. Derived STALE, SOURCE_MISSING, UNSUPPORTED preserve historical human status. Availability changes update source facts and appear in the audit. Existing human fields are preserved without a new decision; same decision/revision reapplies idempotently, while conflicting same-revision content is rejected and logged. Commands use a project-local decision file, never a source root:

```powershell
& $py -m tools.environment_authoring.material_catalog.cli reconcile --decisions <project-local-human-decisions.json>
& $py -m tools.environment_authoring.material_catalog.cli restage-approved
```

Synthetic fixtures produced simultaneous APPROVED, REJECTED and DEFERRED entries, then changed an approved source to STALE and removed it to SOURCE_MISSING. The approved/current entry generated a `.tres` spec, reused the single cache, restaged, and appeared in family/layer/role queries. Stale approved entries refused current restaging. Duplicate catalog IDs, cache-ID collisions, unsafe paths, invalid overrides, same-revision conflicts and unsupported source maps were exercised. The GDScript query defaults to current APPROVED only and can include noncurrent states explicitly. These are synthetic technical fixtures, not KitBash decisions. Running live `restage-approved` found **0 current approved** and created no live approved spec.

## Verification and human gate

| Check | Result |
| --- | --- |
| EAF3B Python synthetic suite | 14 tests, 0 failures, exit 0 |
| EAF3A synthetic regression suite | 22 tests, 0 failures, exit 0 |
| EAF1 focused Godot suite including injection | `EAF1_TESTS failures=0`, exit 0 |
| EAF3B GDScript query test | `EAF3B_QUERY_TESTS failures=0`, exit 0 |
| Godot 4.7 editor import/parse | exit 0; no script parse errors |
| Final EAF3B capture command | 48 records, exit 0, ZIP produced |
| Stage/import/package audit | 59 cache hashes/import records, 48 images and 51 ZIP entries checked |

Godot printed the existing host root-certificate-store warning noted in earlier EAF validation; it did not prevent import, tests or capture.

**No live KitBash material has been human-approved by Codex.** The human/ChatGPT reviewer should inspect paired Neutral and Receiving captures; compare scale, tiling, color, roughness and normal orientation; then mark candidates APPROVED, REJECTED, DEFERRED or request a parameter-only rerun. A later bounded task can reconcile those human decisions and seek EAF3B promotion. This record does not promote EAF3B or EAF3 and does not begin EAF4 or Receiving C1.
