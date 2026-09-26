# EAF3A repository indexing and source triage validation

**Status: IMPLEMENTED / TECHNICALLY VERIFIED / HUMAN REVIEW PENDING**

- Date: 26 September 2026.
- Branch: `codex/eaf3a-material-repository-index`.
- Implementation HEAD verified: `d0081a86593bca9284fa54b426016b132ac1f853`.
- Baseline: clean `main`, `origin/main`, and HEAD all matched `b15f5bb3c5cd07f469986f055df99b55fd140dfd` before edits. The explicit EAF3A handoff supersedes the baseline's older EAF3 design-only wording for this scope.
- Runtime: bundled Python **3.12.14**, existing Pillow **12.3.0**. The bare `python` Windows Store alias could not start; the working absolute interpreter below was used. No installation or fallback image helper was needed.
- Executor: one primary implementer; one read-only agent explored six representative packages through the same source guard. No concurrent code writers. The primary performed the final code review.

## Human review package

All generated evidence below is local, ignored output under `reports/environment_material_catalog/`; commercial source bytes and derived thumbnails are not committed.

- [Scan summary](../../reports/environment_material_catalog/scan_summary.txt)
- [Aggregate statistics](../../reports/environment_material_catalog/aggregate_statistics.json)
- [Portable source index](../../reports/environment_material_catalog/source_index.json)
- [Current unchanged scan diff](../../reports/environment_material_catalog/scan_diff.json)
- [Initial all-new scan diff](../../reports/environment_material_catalog/initial_scan_diff.json)
- [Bounded candidate audit](../../reports/environment_material_catalog/sample_audit.json)
- [Performance evidence](../../reports/environment_material_catalog/performance.json)

| Review page | Selection | Batch / page manifest |
| --- | --- | --- |
| [Concrete sheet](../../reports/environment_material_catalog/concrete/page_01.png) | 24 concrete candidates, 2K, normal required | [Batch](../../reports/environment_material_catalog/concrete_batch.json) / [page](../../reports/environment_material_catalog/concrete/page_01.json) |
| [Cement/render sheet](../../reports/environment_material_catalog/render/page_01.png) | 24 cement/render candidates | [Batch](../../reports/environment_material_catalog/render_batch.json) / [page](../../reports/environment_material_catalog/render/page_01.json) |
| [Metal sheet](../../reports/environment_material_catalog/metal/page_01.png) | 24 metal candidates | [Batch](../../reports/environment_material_catalog/metal_batch.json) / [page](../../reports/environment_material_catalog/metal/page_01.json) |
| [Warnings sheet](../../reports/environment_material_catalog/warnings/page_01.png) | 24 candidates with warnings, including atlases/special maps/graphs | [Batch](../../reports/environment_material_catalog/warnings_batch.json) / [page](../../reports/environment_material_catalog/warnings/page_01.json) |

Each page is 1408 x 2680, with 24 tiles and 256 x 256 basecolor thumbnails. Tiles include display name, short identity, package/version, resolutions, channel abbreviations, family and warning marker. Each page JSON maps tile index to full stable ID and provides full warning/preview details. Four sheets were visually inspected; thumbnails, labels and manifests were checked. All 96 displayed tile previews decoded successfully (the selections may overlap). They are source-triage evidence only, never final PBR quality or VDD approval.

## Configuration and filesystem boundary

Tracked example/schema: `tools/environment_authoring/material_repository/local_config.example.json` and `local_config.schema.json`. The actual `local_config.json` is machine-local and ignored; its single field is:

```json
{"source_repository_root": "D:\\AssetPipeline\\KitBash_repository"}
```

No alternate roots, production root/config CLI overrides, parent searches, drive scans, profile searches or automatic discovery exist. Deliberate migration requires editing this single config. The project is separately used for code, synthetic fixtures and reports, and production config rejects it, its descendants and ancestors as source trees.

Every external enumeration/stat/open uses `path_guard.Repository`. The root and candidate are canonicalized; lexical containment is checked before candidate metadata reads and canonical containment is checked again. Every symlink/reparse entry is rejected, including junctions whose target remains inside the root. Such entries are skipped with warnings, never descended into. Source opens are binary read-only. Missing/unreadable source paths fail without fallback. The live scan recorded zero reparse skips. A real Windows directory junction to an outside synthetic directory was tested successfully; traversal, absolute outside-root and different-drive attempts were also rejected. The source repository was never written to.

This portable guard assumes a quiescent source tree; it is not a kernel sandbox against a malicious process concurrently replacing filesystem components. Quick preview signatures are rechecked before cache use/open. Source paths from a manipulated index still pass through the guard. Index/query/output CLI paths are restricted to the project report directory.

## Profile evidence and rules

`KITBASH_PROFILE_V1`, profile revision 1, recognizes `kb3d_*` top-level package directories case-insensitively, followed by semantic-version folders. Observed versions include 7.0.0, 7.0.1, 7.0.2 and 7.0.3. Case exceptions include `KB3D_Paris` and `KB3D_Stadiums`; source paths preserve spelling while package IDs are lowercased. Empty recognized package versions are retained.

Representative inspection covered Aftermath, American Neighborhoods, Apartment Interiors, Cyberpunk, Mission to Minerva, Paris, Stadiums and Wreckage. Actual texture folders were `Textures/png2k` and `Textures/exr2k`; the full scan confirms only 2K in this repository snapshot. Descriptors advertise other texture variants (and often default to png4k), but these declarations never establish available files/resolutions. Synthetic fixtures prove 1K/2K/4K grouping; the profile also recognizes plain and format-prefixed 8K/16K labels.

Descriptor convention: `Materials/<stem>/<stem>.usd` (also supported usda/usdc and optional logical grouping). ASCII descriptors start with `#usda` and `def Material`; optional KitBash display-name/ID/version hints come from at most the first 8192 bytes of descriptors no larger than 1 MiB. Binary files are never decoded as text. Paris descriptors lack display-name/version hints, so folder identity remains authoritative. No USD references are followed. Model files such as `Models/KB3D_API_PropBasketball_A/geo.usd`, `mtl.usd`, `payload.usd` and the model-named USD are `SCENE_OR_GEOMETRY`, never standalone material descriptors.

Observed PNG suffixes: basecolor, normal, roughness, metallic, ao, opacity, emissive and refraction. EXR height joins the same 2K material. Aliases additionally cover albedo/base_color, metalness, displacement and emission. Packed ORM/ARM/RMA, refraction/specular/glossiness, and unknown suffixes are retained without channel interpretation. Channel states are SUPPORTED, OPTIONAL, UNSUPPORTED, AMBIGUOUS or MISSING. Duplicate maps stay ambiguous. Substance graphs/dependencies are counted as UNKNOWN; matching top-level graphs also mark their candidate unsupported. Unknown future layouts are counted conservatively.

A texture-only candidate requires basecolor plus normal, roughness or metallic at the same resolution; a recognized descriptor independently establishes positive evidence. Arbitrary standalone images do not create candidates. The live snapshot has 687 candidates with `both` evidence. Atlas/trim/object-specific filename warnings do not reject candidates or prove tileability. The final warning heuristic excludes the package code, preventing Atlantis `ATL` from becoming an atlas warning; its failed-first regression test passes.

## Index, IDs and incremental behavior

Schema version 1, scanner revision `eaf3a-1`, profile revision 1. The index records start/end timestamps, a diagnostic root, packages, candidates, every file's classification/quick signature, non-material summaries and warnings. Package records include identity/version/root/profile, display/metadata hints, content summaries, warnings and quick fingerprint. Candidate records include identity/name/package/version, logical relative group, detection evidence, available resolutions, maps, channel states, descriptors, relevant source signatures, suggested family, quick fingerprint and warnings.

Stable identity: `kitbash:<package_id>@<version>:<material_stem>`. A nonempty logical material-group path precedes the stem; identity components are percent-encoded to prevent separator collisions. Duplicate stable material or package IDs are errors. Absolute roots never enter package/candidate records or IDs. Migration tests copy an unchanged relative tree and preserve IDs and fingerprints. Resolution variants do not create new material IDs. Same display names across packages and same-stem groups within packages remain distinct.

The quick fingerprint hashes sorted repository-relative path, size and mtime_ns facts plus interpretation metadata; routine scans never hash texture bytes. Package fingerprints include non-material files. This intentionally cannot detect same-size byte edits with preserved mtimes; EAF3B strong SHA-256 file fingerprints remain deferred. No human approval fields are stored.

`scan_diff.json` provides sorted new/changed/removed/unchanged candidate and package ID lists. Initial scan: 84 new packages, 687 new candidates. Unchanged rescan: all 84/687 unchanged. A development correction to atlas warnings changed 20 interpretation fingerprints and was preserved as `interpretation_revision_diff.json`; the final implementation rescan returned zero new/changed/removed and all 84/687 unchanged. Synthetic tests separately exercise actual changed/removed/new files, candidates and packages.

## Live counts and performance

| Measure | Result |
| --- | ---: |
| Total repository files | 5,856 |
| Package/version records | 84 |
| Material candidates | 687 |
| MATERIAL_DESCRIPTOR | 687 |
| MATERIAL_TEXTURE | 4,148 |
| SCENE_OR_GEOMETRY | 706 |
| UNKNOWN | 315 |
| MODEL / IMAGE_PREVIEW / DOCUMENTATION / METADATA | 0 each |
| Total non-material files | 1,021 |
| Initial scan | 8.8474 s |
| Initial unchanged rescan | 9.3756 s |
| Final implementation scan | 8.2360 s |
| Initial 24-tile concrete / render / metal / warnings sheets | 2.9239 / 3.1808 / 2.5793 / 2.5367 s |
| Unchanged concrete sheet, 24/24 thumbnails reused | 0.2959 s |

Zero MODEL means no FBX/OBJ/GLB/etc. files in this snapshot; the 706 model/scene USD files are explicitly counted under SCENE_OR_GEOMETRY. All 315 unknown files are Substance sources/dependencies: 171 `.sbs` and 144 `.sbsar`. No such content is fatal or silently ingested.

Suggested machine-only families: concrete 264; cement_render 81; metal 55; other 47; brick 35; wood 25; masonry_block 24; tile 21; paint 6; unknown 129. Final candidate warning occurrences: atlas/trim/object-specific name 85; unsupported refraction 22; unsupported Substance graph 45; missing metallic at 2K 1. Warnings may overlap. All 687 candidates have basecolor, normal, roughness and height; 686 metallic, 615 AO, 39 emissive, 38 opacity and 22 refraction. No packed map occurred live; synthetic fixtures cover it. There are no live scan or package warnings.

## Bounded candidate audit

For each identity below, checked the descriptor's actual Material declaration, all relevant file stat signatures, one coherent material stem, 2K grouping, correct channels, and absence of model/geometry paths. The audit JSON records exact relative paths. Eight packages span missing optional AO, Substance support warnings, trims/atlases, metadata fallbacks and mixed material/model content.

- `kitbash:kb3d_aftermath@7.0.2:KB3D_AFT_ConcreteA`
- `kitbash:kb3d_americanneighborhoods@7.0.0:KB3D_AMN_BRDirtyCeramicWhiteTiles`
- `kitbash:kb3d_apartmentinteriors@7.0.2:KB3D_API_ClothTrim`
- `kitbash:kb3d_paris@7.0.0:KB3D_PAR_ConcreteLeaked`
- `kitbash:kb3d_stadiums@7.0.1:KB3D_SDM_ATLSportA`
- `kitbash:kb3d_wreckage@7.0.3:KB3D_WRK_AsphaltDamaged`
- `kitbash:kb3d_missiontominerva@7.0.2:KB3D_MTM_ConcreteA`
- `kitbash:kb3d_beyondrepair@7.0.0:KB3D_BYR_BRDamagedPlasterBrickwall`

## Verification and reproduction

Run from `D:\Godot Projects\Sorting-apoc-PROTOTYPE` in PowerShell:

```powershell
$py = 'C:\Users\Boschetar\.cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe'
$tool = 'tools/environment_authoring/material_repository'
& $py -m unittest discover -s "$tool/tests" -v
& $py "$tool/scan_repository.py"
& $py "$tool/query_index.py" --family concrete --resolution 2K --required-channel normal --limit 24 --format batch --output reports/environment_material_catalog/concrete_batch.json
& $py "$tool/query_index.py" --family cement_render --limit 24 --format batch --output reports/environment_material_catalog/render_batch.json
& $py "$tool/query_index.py" --family metal --limit 24 --format batch --output reports/environment_material_catalog/metal_batch.json
& $py "$tool/query_index.py" --warnings any --limit 24 --format batch --output reports/environment_material_catalog/warnings_batch.json
foreach ($batchName in @('concrete', 'render', 'metal', 'warnings')) {
    & $py "$tool/build_triage_sheets.py" --batch "reports/environment_material_catalog/${batchName}_batch.json" --output "reports/environment_material_catalog/$batchName"
}
& $py "$tool/query_index.py" --package american --name concrete --format ids
& $py "$tool/query_index.py" --status changed --format json
& 'D:\AI Tools\Godot-4.7-Codex\Godot_v4.7-stable_win64_console.exe' --headless --editor --path . --quit
```

Synthetic suite: **22 tests, 0 failures, exit 0**; [full log](../../reports/environment_material_catalog/synthetic_tests.log). Coverage includes config, single-root and Windows junction containment, rejected root/config CLI overrides, package/classification rules, positive evidence, channel/resolution grouping, ID uniqueness/migration, fingerprints/diffs, query filters, stale/invalid batch rejection, thumbnail reuse/source changes/escape attempts, placeholders and page manifests. Fixtures contain only original tiny placeholder images and text and do not require the commercial repository. Initial missing-feature failures and both identified regression failures were observed before their implementations/fixes.

Godot editor import/parse: **exit 0**, no SCRIPT ERROR or FAIL markers. The log retains `ERROR: Failed to read the root certificate store`, the existing host certificate warning documented in EAF1/EAF2, unrelated to project parsing. An importer-only line-ending touch to the existing diagnostic grid import file was restored to baseline; no EAF1/EAF2 runtime source changed. No runtime suites were required. Generated reports have a local `.gdignore`; tool fixtures have a committed `.gdignore`.

Primary self-review covered guarded I/O, no source writes, profile/core separation, conservative association, stable identities, ambiguous channels, stale preview/batch handling, and ignored commercial outputs. Two concrete corrections were verified: project subdirectories cannot be configured as source roots, and atlas warnings do not inspect the package code. No outstanding technical blocker was found. This was an author review, not an independent code review.

## Human gate and limitations

Review boundary safety, mixed-content classification, understandable stable IDs, channel/resolution grouping, diff visibility and whether the four sheets/filter commands make triage practical. Filename families are not palette decisions. Normal-Y, physical scale, packed-map semantics, descriptor graph execution, full-resolution PBR quality and tileability remain unverified source facts for later work.

**Disposition: PROMOTE EAF3A / REVISE EAF3A.** No disposition has been selected. No merge or push was performed. EAF3B, EAF4, approval-catalog construction, EAF1 review-batch creation, material staging into Godot and Receiving Stage C1 remain untouched/out of scope. Stop at this human gate.
