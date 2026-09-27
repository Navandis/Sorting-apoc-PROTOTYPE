# EAF4A wear source index and triage

Standalone Python/Pillow source discovery. Source facts and machine suggestions
are not artistic approval. EAF4B curation, Godot overlays, staging and EAF1 wear
reviews are outside this tool.

## Local configuration and commands

Copy `local_config.example.json` to ignored `local_config.json`. The only field is
`source_repository_root`, currently `D:\AssetPipeline\EAF4_repository`. There is
no root/config CLI override, alternate root list, parent search or fallback. A
deliberate future root migration changes this config, preserving relative layout.
The source root must be a real absolute directory outside the project. Examples
and synthetic tests never require or inspect the commercial repository.

From the project root in PowerShell:

```powershell
$py = 'C:\Users\Boschetar\.cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe'
& $py -m unittest discover -s tools/environment_authoring/wear_repository/tests -v
& $py -m tools.environment_authoring.wear_repository.scan_repository
& $py -m tools.environment_authoring.wear_repository.query_index --source-class MASKED_DECAL --family crack --has-normal --has-alpha-mask --format batch --output reports/environment_wear_catalog/crack_batch.json
& $py -m tools.environment_authoring.wear_repository.build_triage_sheets --batch reports/environment_wear_catalog/crack_batch.json --output reports/environment_wear_catalog/crack_shortlist
& $py -m tools.environment_authoring.wear_repository.build_triage_sheets --grouped
& $py -m tools.environment_authoring.wear_repository.query_index --profile UNREAL_EXTRACTED_ATLAS_PROFILE --opacity ATLAS_ALPHA --format ids
& $py -m tools.environment_authoring.wear_repository.query_index --status changed --format json
```

Other filters: `--profile`, `--opacity`, `--has-roughness`, `--tileable
true|false|unknown`, `--resolution`, `--warnings [any|none|substring]`,
`--directory`, `--name`, `--limit`. Boolean channel filters also accept their
`--no-has-*` inverse. Requested normal/roughness and resolution must coexist at
one resolution. `--directory` searches the logical relative group/family.
JSON, stable-ID list and stable-ID-only batch output are supported. Batches reject
extra source-path fields, duplicate/unknown IDs and stale index fingerprints.
CLI index, batch and output paths stay below `reports/environment_wear_catalog`.

## Source safety

The EAF4 guard independently follows EAF3A's proven design; EAF3 is unchanged.
Every enumeration/stat/open checks canonical root, lexical containment, every
candidate component for symlink/reparse attributes, and final canonical
containment. Reparse directories are skipped with warnings, never descended.
Configured-root reparse components are rejected too. Every source open is `rb`.
Missing paths fail with no fallback search. Like EAF3, this assumes a quiescent
tree and is not a kernel sandbox against concurrent malicious junction swaps.

ZIP/7z/RAR/TAR/GZ/BZ2/XZ/TGZ/TBZ2/TXZ/ZST/CAB/ISO/PAK are directory bookkeeping
only. No contents or members are opened, hashed or extracted. Only counts by
extension/top directory are reported; archives never enter content fingerprints,
candidates or previews. The guard rejects attempts to open them as well. macOS
resource forks (`__MACOSX`, `._*`) are ignored as platform bookkeeping.

The project is separately used for code, original tiny fixtures, schemas,
config and ignored generated reports. Report/cache output is never an external
source repository, and preview helpers reject writes into a source tree.

## Classification and source facts

- `FAB_DECAL_PROFILE`: positive Megascans `id`, `maps[]` and
  `semanticTags.asset_type=decal`. Existing filename channels are grouped; absent
  advertised master maps do not count as downloads. Missing mask/alpha evidence
  yields UNKNOWN with a warning, not an assumed decal.
- `IMPERFECTION_TEXTURE_PROFILE`: explicit Megascans imperfection type. Roughness,
  gloss and mask are useful without basecolor. JPG/EXR/UE-high export variants of
  the same recognized package share an identity; supplemental geometry/packed MR
  exports remain warning-bearing source facts, not new wear assets.
- `GENERIC_PBR_DECAL_PROFILE`: explicit map-suffix groups. A separate mask or
  nonopaque color alpha supports MASKED_DECAL. A scalar/packed-map alpha channel
  never becomes decal opacity merely because it exists.
- `FULL_SURFACE_PROFILE`: explicit surface metadata (unless tileability conflicts).
  Explicit tileable PBR with no localized opacity also routes to EAF3. Surface-like
  PBR sets without enough localization/tileability evidence stay UNKNOWN; there
  is no duplicate lookup against EAF3 or KitBash.
- `GENERIC_PHYSICAL_DAMAGE_PROFILE`: geometry plus explicit physical-damage source
  declaration. Unknown geometry never becomes physical damage from its name.
- `UNREAL_EXTRACTED_ATLAS_PROFILE`: bounded flat MaterialInstance notes under
  `unreal_extracted`, with a parent and texture reference. Exact sibling texture
  stems associate a family; metadata paths/URLs are not followed.
- `MIXED_UNKNOWN_PROFILE`: insufficiently recognized image/geometry content.

An optional explicit declaration JSON uses `eaf4_source_metadata_version: 1`,
`source_kind: physical_damage|material_patch`, and `localized: true` for patches.
This narrow supported format is exercised with original fixtures; no declaration
is written into the commercial repository. Physical damage/material patches are
classified only on positive source evidence.

Channels: basecolor/albedo/color/col/diffuse, normal (including named DirectX and
OpenGL variants), roughness, gloss/smoothness, metallic, AO, ORM,
height/displacement, bump, cavity, specular, opacity/alpha/mask, emissive and
base-opacity. Unknown images and unknown packed suffixes are preserved with
warnings. ORM is a source label; no final Godot channel mapping is specified.
MR/RSMO/ARM/RMA/packed never acquire inferred component semantics.

Every supported image header records dimensions/mode/alpha presence. Exact alpha
histograms use the smallest decodable variant of each color/base-opacity/unknown
image channel; stats identify their sampled source and do not claim every
resolution was decoded. Atlas alpha is analyzed once per source texture. Packed
and scalar channel alpha is not interpreted as opacity. This avoids decoding 8K
when a useful smaller variant exists. Unsupported EXR headers are retained with
warnings; no extra package is installed.

Physical metres come only from explicit `meta.scanArea`, e.g. `0.5x0.5 m`, with
provenance. Megascans displacement `height` is not planar size. Tileability uses
explicit booleans; category conflicts are visible. Conflicting export metadata
clears the disputed size/tileability fact and preserves all source variants.
Missing values remain null. Filename semantic-family suggestions are weak,
never wall/floor/ceiling placement restrictions.

## Unreal semantics and previews

Each parameter records `{recorded, override, value}`. Missing, literal None and
numeric zero remain distinct. The raw key/value record preserves all override
keys, including both OpacityOverride and OpacityLevelOverride spellings. Parent
defaults are never invented. Missing OpacityLevel does not remove atlas alpha.
Length/Height remain recorded Unreal values with unknown units unless a future
profile supplies verified conversion; they are not assumed to be metres.

Family identity includes relative directory, parent and atlas name. Each logical
ID also includes instance name. Atlas texture facts live once in the family;
logical entries retain their TXT signature and referenced atlas signatures.

SelectX/Y and CellSizeX/Y alone cannot establish the parent material's UV math.
Cropping requires an explicit `AtlasRegionConvention=normalized_offset_size_top_left`
record: SelectX/Y are normalized offsets, CellSizeX/Y normalized extents, no active
cell-step switches or disabled overrides, finite in-bounds values. This explicit
format is covered by synthetic tests. Current live exports lack this convention,
so all retain `NEEDS_MANUAL_METADATA` and show clearly labelled whole-atlas previews.
No cropped logical view is invented. Source images are never rewritten.

Previews composite color alpha or separate opacity on a checker. Imperfections
show labelled roughness, or inverted gloss for display, or mask. Normal variants
and unknown packed data are not silently used as color. Every source signature is
checked before cache reuse. Unsafe/manipulated-index paths are rejected at the
source boundary. Each page JSON resolves short display hashes to full stable IDs.

## Index, outputs and limits

Schema 1 and scanner/profile revisions are tracked. IDs percent-encode separate
logical components: `eaf4:<profile>:<relative-group>:<source-name>`, or
`eaf4:unreal_atlas:<encoded-family-id>:<instance-name>`. Group normalization removes
recognized resolution/export markers, preserving unrelated punctuation. IDs and
fingerprints exclude the absolute root. Duplicate IDs are errors.

Quick fingerprints hash sorted relative path/size/mtime_ns plus profile
interpretation. They do not hash texture bytes, and cannot detect same-size edits
that preserve mtimes; strong shortlisted fingerprints belong to EAF4B. Family
and candidate diffs record new/changed/removed/unchanged.

Default ignored outputs:

- `source_index.json`, `scan_diff.json`, `scan_summary.txt`, `aggregate_statistics.json`
- `triage/<group>/page_NN.png`, matching page JSON, batch and manifest
- `triage/city_be_selective_audit.json` and `.txt`
- `triage/unreal_atlas_summary.json`, `triage/triage_manifest.json`
- generated thumbnail cache; no commercial source textures are copied

Only populated sheet groups are generated. UNKNOWN and warning sheets make
unsupported source layouts visible. City audit separates usable EAF4 candidates,
definite EAF3 routing, unknown candidates, unsupported files and ignored archives;
the recommendation never deletes or moves source files. Historical generated pages
may remain after a smaller later batch; the latest manifest is authoritative.

Dependencies: Python 3.12 and existing Pillow 12.3 on the validated machine.
Run as modules (`python -m tools.environment_authoring.wear_repository...`).
No external source installation, Unreal installation, engine renderer or network
access is required for scanning/testing.
