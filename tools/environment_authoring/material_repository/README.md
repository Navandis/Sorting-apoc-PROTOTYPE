# EAF3A material repository tools

Standalone source discovery and triage. These tools never stage materials, build EAF1 batches, store approval state, or change Godot materials.

## Setup and boundary

Use Python 3.12+ and Pillow. The validated installation is Python 3.12.14 / Pillow 12.3.0 bundled with Codex. No dependency was installed. The Windows `python` alias was unusable, so these PowerShell examples select the working interpreter explicitly:

```powershell
$py = 'C:\Users\Boschetar\.cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe'
$tool = 'tools/environment_authoring/material_repository'
```

Copy `local_config.example.json` to the ignored `local_config.json`, then deliberately set its one absolute `source_repository_root`. The schema describes this single field; runtime validation additionally requires an existing directory and excludes drive roots, the project, its parents and its descendants. There is no production `--root` or `--config` option and no filesystem discovery. Only this configuration may change after a deliberate repository migration.

`path_guard.py` owns every source enumeration, stat and binary open. It checks lexical containment before source metadata reads, resolves canonical paths, checks containment again and rejects every symlink/reparse entry (including in-root junctions). Skips are warnings. Missing/unreadable source directories fail the scan without fallback. Keep the source tree quiescent during scanning; this portable guard does not claim protection against malicious concurrent filesystem replacement. Tests inject a synthetic Repository/config; production entry points always load the fixed local config.

## Scan and query

Run from the Godot project root:

```powershell
& $py -m unittest discover -s "$tool/tests" -v
& $py "$tool/scan_repository.py"
& $py "$tool/query_index.py" --package american --name concrete --resolution 2K --required-channel normal --format ids
& $py "$tool/query_index.py" --family concrete --limit 24 --format batch --output reports/environment_material_catalog/concrete_batch.json
& $py "$tool/query_index.py" --warnings any --format json
& $py "$tool/query_index.py" --status changed --format ids
& $py "$tool/build_triage_sheets.py" --batch reports/environment_material_catalog/concrete_batch.json --output reports/environment_material_catalog/concrete
```

Repeat `--required-channel` to require several unambiguous supported/optional channels at the same resolution. `--warnings` accepts `any`, `none`, or a substring. Status accepts new/changed/unchanged; removed IDs are in the diff because they have no current candidate. Outputs are sorted by stable ID; `--limit` is applied last. The default query output is JSON; `ids` prints one identity per line; `batch` contains stable IDs and a source-index fingerprint, never source paths. Stale/unknown/duplicate batches and stale status diffs fail explicitly. CLI index/batch/output paths must stay inside the project's report directory.

Sheets accept the same query filters directly, or a batch. Default pagination is 24 materials; maximum 40. Full identities, preview paths and warning details are in each page JSON and combined manifest. Basecolor previews use the lowest available unambiguous decodable resolution; EXR and ambiguous basecolors receive placeholders. Only the selected basecolor is decoded. The 256-square cache key includes stable ID, candidate quick fingerprint, preview path/resolution, size and thumbnail revision. Every request checks the source stat signature before reusing its cache; changed/missing source previews require a rescan. Sheets are source triage only, never final PBR evidence.

## Profile and portable index

`KITBASH_PROFILE_V1` recognizes top-level case-insensitive `kb3d_*` packages with semantic-version subdirectories. A material descriptor requires `Materials/[optional group/]<stem>/<stem>.usd|usda|usdc`. Model/scene USD, even `Models/.../mtl.usd`, stays scene/geometry content. Optional ASCII USD metadata is read from at most 8 KiB of descriptors no larger than 1 MiB, only after checking the `#usda` signature. Folder identity wins over metadata. Other formats/layouts remain conservative.

Textures require `Textures/[group/]png2k/...`, analogous format-prefixed labels, or plain 1K/2K/4K/8K/16K directories. Groups exclude resolution/format directories. Actual files, never advertised descriptor variants, determine availability. A texture-only candidate requires basecolor plus normal/roughness/metallic in the same resolution. Descriptor-backed candidates may have missing maps. Bare images do not become candidates.

Aliases cover basecolor/base_color/albedo, normal, roughness, metallic/metalness, AO, height/displacement, opacity, emissive/emission. Packed ORM/ARM/RMA, refraction/specular/glossiness and unknown suffixes remain unsupported facts. Duplicate channel files are ambiguous. Height/AO/opacity/emissive are optional source channels; no runtime behavior is implied. Substance graphs/dependencies remain UNKNOWN and are not interpreted. Filename-derived family and atlas/trim warnings are triage hints only. Nothing establishes tileability, normal-Y orientation, physical scale or VDD approval.

The schema-1 index includes scanner/profile revisions, scan timestamps, one diagnostic root, packages, candidate facts, per-file classifications/signatures, summaries and warnings. Only the diagnostic header contains the absolute source root. Each material has `maps_by_resolution` containing channel lists of `{relative_path, size, mtime_ns}`, plus per-resolution channel states, descriptor paths and relevant source signatures.

IDs are `kitbash:<lowercase-package-id>@<version>:<material-stem>`, with a percent-encoded logical group path before the stem when needed. Case of material names is preserved. IDs do not depend on absolute roots or available resolutions, and existing ungrouped IDs do not change when another group adds a same-named material. Duplicate material or package IDs fail validation.

Quick fingerprints hash sorted relative-path/size/mtime_ns facts and interpretation metadata; they never hash texture contents. They are intentionally not cryptographic proof of source bytes: equal-size edits with preserved mtimes can be missed. EAF3B must compute strong fingerprints later. Package fingerprints include non-material files. Diff output is deterministic new/changed/removed/unchanged ID lists against the previous index. A changed interpretation can legitimately change quick fingerprints.

## Files and evidence

All derived artifacts are ignored under `reports/environment_material_catalog/`: `source_index.json`, `scan_diff.json`, `scan_summary.txt`, thumbnails, batches and sheets. Do not commit commercial textures or generated commercial thumbnails. The committed fixture tree contains only original 8x8 placeholder PNGs and synthetic text; `tests/make_fixtures.py` regenerates it. `.gdignore` keeps tool fixtures outside Godot import.

See `docs/testing/environment-authoring-eaf3a-repository-index-validation.md` for the live counts, timings, sampled IDs, review sheets and human gate.
