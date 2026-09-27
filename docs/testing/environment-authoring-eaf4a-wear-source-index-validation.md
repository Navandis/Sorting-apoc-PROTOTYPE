# EAF4A wear source index and triage validation

**Status: IMPLEMENTED / TECHNICALLY VERIFIED / HUMAN REVIEW PENDING**

- Date: 27 September 2026.
- Branch: `codex/eaf4a-wear-source-index`.
- Verified implementation HEAD: `926eb5985e1b0aa144808475f6fc94585a91c2c6`.
- Starting HEAD/main/origin/main: `ff49662e26f84048150fc1d720fc6186d743cb2d`, clean.
- Runtime: bundled Python **3.12.14**, existing Pillow **12.3.0**; no packages installed.
- One primary implementer and one read-only source explorer; final code review was by the implementer.
- The explicit EAF4A handoff supersedes older design-only wording for this slice. EAF4B, EAF5 and Receiving C1 remain outside scope.

## Human review package

All generated evidence is ignored local output under `reports/environment_wear_catalog/`. The shareable ZIP contains derived contact pages, manifests, source facts, statistics and this validation record. It contains no commercial source textures or thumbnail cache. Committed image/model/archive fixtures are tiny original placeholders. ZIP integrity and the exact allowlist passed: **95 entries**, including **26 current contact pages**, with no source textures. The external [package manifest](../../reports/environment_wear_catalog/review_package_manifest.json) records size and SHA-256.

- [Shareable review ZIP](../../reports/environment_wear_catalog/eaf4a_human_review.zip)
- [Start here](../../reports/environment_wear_catalog/review/START_HERE.md)
- [Scan summary](../../reports/environment_wear_catalog/scan_summary.txt)
- [Statistics](../../reports/environment_wear_catalog/aggregate_statistics.json)
- [Source index](../../reports/environment_wear_catalog/source_index.json)
- [Unchanged diff](../../reports/environment_wear_catalog/scan_diff.json)
- [Bounded audit](../../reports/environment_wear_catalog/bounded_live_audit.json)
- [City audit](../../reports/environment_wear_catalog/triage/city_be_selective_audit.json)
- [Unreal summary](../../reports/environment_wear_catalog/triage/unreal_atlas_summary.json)
- [Page manifest](../../reports/environment_wear_catalog/triage/triage_manifest.json)
- [Performance](../../reports/environment_wear_catalog/performance.json)

| Representative page | Evidence |
| --- | --- |
| [Cracks](../../reports/environment_wear_catalog/triage/cracks/page_01.png) | Separate opacity, physical dimensions, grouped resolutions |
| [Damage/spall](../../reports/environment_wear_catalog/triage/damage_spall/page_01.png) | Megascans damage plus generic TGA alpha/mask |
| [Imperfections](../../reports/environment_wear_catalog/triage/imperfections/page_01.png) | Sixteen logical sources, labelled scalar previews, consolidated exports |
| [Water/mineral](../../reports/environment_wear_catalog/triage/water_mineral/page_01.png) | Leakage/stains and explicit tileability conflicts |
| [Unreal](../../reports/environment_wear_catalog/triage/unreal_extracted/page_01.png) | Thirteen instances, three atlases; unresolved whole-atlas views |
| [City](../../reports/environment_wear_catalog/triage/city_audit/page_01.png) | First of four pages; opaque surface-like PBR |

There are **26 current pages across 14 populated groups**, with **326 tiles including overlap**. All current pages decoded; zero preview decode failures. Representative cracks, damage, imperfections, Unreal and City pages were visually inspected. Physical size, channels, opacity, resolution, tileability and warning markers are readable; page JSON resolves short display hashes to full IDs. Historical pages remain ignored; the current manifests govern the ZIP contents.

## Configuration and safety

Tracked example/schema and ignored actual config are under `tools/environment_authoring/wear_repository/`. The actual `local_config.json` contains only:

```json
{"source_repository_root": "D:\\AssetPipeline\\EAF4_repository"}
```

There is no production root/config CLI override, alternate root list, parent search or fallback. Future migration changes only this local config while preserving relative layout. The project is separately used for code, original fixtures, schemas, config and reports. No KitBash or other AssetPipeline sibling was scanned.

The independent EAF4 guard follows EAF3A's model without modifying EAF3: canonicalize root and candidate, check lexical containment before candidate reads, reject symlink/junction/reparse components, and check canonical containment. Reparse directories are skipped, never descended. Tests include a real Windows junction, traversal, absolute outside-root and different-drive paths, manipulated index paths, and project-root config rejection. Every source open is binary read-only. No source was written, deleted or moved. The guard assumes a quiescent tree; it is not a kernel sandbox against hostile concurrent path replacement.

Archive extensions are bookkeeping only: never opened, enumerated internally, extracted, content-hashed, previewed or used as candidates. The guard also rejects archive opens. Live: **92 ZIPs ignored**. Synthetic ZIP/7z/RAR/TAR/GZ changes cannot affect family/candidate fingerprints. One macOS resource-fork file is separately ignored. Output/cache paths cannot target the source tree.

## Profiles and source facts

Scanner `eaf4a-1`, source-index schema 1, profile revisions 1. The tracked index schema describes the contract; runtime validation checks version and duplicate IDs. Full JSON Schema validation is not a dependency.

| Profile | Positive evidence | Live entries |
| --- | --- | ---: |
| FAB_DECAL_PROFILE | Megascans ID/maps/type and actual local map files | 65 |
| GENERIC_PBR_DECAL_PROFILE | Recognized channel-suffix groups | 76 |
| IMPERFECTION_TEXTURE_PROFILE | Explicit imperfection metadata | 16 |
| UNREAL_EXTRACTED_ATLAS_PROFILE | Instance note, parent, sibling texture association | 13 |
| FULL_SURFACE_PROFILE | Explicit surface/tileability metadata | 0 |
| GENERIC_PHYSICAL_DAMAGE_PROFILE | Geometry with explicit physical-damage declaration | 0 |
| MIXED_UNKNOWN_PROFILE | Insufficiently recognized content | 0 |

Source classes are separate from profiles. Recognized PBR layout can remain UNKNOWN. Separate mask or nonopaque color alpha supplies opacity evidence; declared decals without opacity remain UNKNOWN with a warning. Imperfections need no basecolor. Explicit tileable full-surface PBR without localized opacity routes to EAF3, with no EAF3 duplicate search. Physical damage and bounded material patches require positive geometry/metadata declarations. These three absent live classes are covered by original synthetic fixtures.

Maps cover basecolor/albedo, normal (including separate named DirectX/OpenGL variants), roughness, metallic, AO, ORM, height/displacement, bump, cavity, specular, opacity/alpha/mask, emissive, gloss and base-opacity. RSMO/MR remain unknown packed semantics. ORM is a source label; no Godot component mapping is inferred. City ORM alpha is not decal opacity.

Image headers record dimensions, mode and alpha presence. Exact 8-bit alpha histograms record opaque/transparent/partial fractions on the smallest usable variant of each color/base-opacity channel, naming the sampled source. They do not claim all 8K maps were decoded. Atlas alpha is analyzed once per source texture; all three live histograms were independently checked.

Available resolutions come from existing files, never absent advertised masters. Recognized JPG/EXR/UE-high exports of the same Megascans package share one ID. Grunge has 1K/2K/4K/8K and previews 1K roughness; unknown EXR headers and supplemental glTF/bin/MR remain warnings. Preview gloss is inverted for display only. Sources are never rewritten.

Physical metres come only from explicit `meta.scanArea`, with provenance; displacement height is not planar size. Tileability uses explicit booleans. Conflicting export metadata clears disputed facts and retains source variants. Three live category/tileability conflicts preserve explicit false and warnings. One source has unitless `2x2`; no metre size is invented. Semantic-family suggestions use metadata then weak filename fallback. No wall/floor/ceiling restrictions or causes are inferred.

## Unreal semantics

**3 atlas families / 13 logical entries.** Families use relative directory + parent + atlas identity; logical IDs also include instance name. Atlas facts live once in the family; entries reference it and retain TXT/atlas quick signatures.

The parser stores raw assignments plus `{recorded, override, value}` for SelectX/Y, CellSizeX/Y, Length, Height, OpacityLevel, Roughness and both UseCellSizeStep switches. Missing, None and numeric zero remain distinct. Both opacity override spellings are retained. **Four live entries omit OpacityLevel and still retain ATLAS_ALPHA.** No parent defaults are invented. Length/Height units are absent, so they are not labelled metres.

**All 13 live regions are NEEDS_MANUAL_METADATA.** Select/CellSize values alone do not establish parent UV equations, grid/index origin or defaults. Whole-atlas previews carry a prominent unresolved label. Cropping is proven synthetically only when an explicit normalized-offset/size convention exists, with finite bounds and no conflicting switches/disabled overrides. Alpha survives the crop; no logical live crop is guessed.

## Identity, diff and query behavior

IDs percent-encode separate components: ordinary `eaf4:<profile>:<relative-group>:<logical-name>`; Unreal `eaf4:unreal_atlas:<encoded-family-id>:<instance-name>`. Paths are root-relative and identities exclude the absolute root. Resolution/export variants share identity; duplicates are errors. Fixture migration preserves IDs and fingerprints.

Quick fingerprints hash sorted relative path/size/mtime_ns and interpreted facts with revisions, not source texture bytes. Same-size edits preserving timestamps are undetectable; strong shortlist hashing belongs to EAF4B. Diffs record new/changed/removed/unchanged at family and candidate levels. Final scan: **0 new, 0 changed, 0 removed; 160 families and 170 entries unchanged**.

Queries cover class, profile, semantic family, opacity, normal/roughness, alpha/mask evidence, tileability, resolution, warnings, relative directory/family and new/changed status. Outputs: JSON, ID list, ID-only batch. Extra path fields, stale fingerprints and duplicate/unknown IDs are rejected. Preview signatures and guarded paths are checked before cache reuse.

## City disposition

**NEEDS MORE PROFILE SUPPORT.** City has 315 files forming 63 coherent opaque PBR sets: **0 proven EAF4, 0 definite EAF3 routes, 63 UNKNOWN, 0 unsupported files, 0 archives inside the directory**. Four audit pages show likely full-surface material content, but no explicit tileability/localization metadata was found. Human review can request additional evidence/profile support or decide repository handling. Nothing is deleted or moved.

Seven other surface-like UNKNOWNs are six Metal_Textures_Pack sets and rusted_metal_chunks. No route-to-EAF3 sheet is fabricated for an empty category; its generation and routing behavior are proven synthetically.

## Counts and performance

| Measure | Result |
| --- | ---: |
| Indexed content files, excluding archives/resource fork | 1,221 |
| Ignored ZIPs / resource forks | 92 / 1 |
| Families / logical candidates | 160 / 170 |
| MASKED_DECAL | 71 |
| IMPERFECTION_MASK | 16 |
| UNREAL_ATLAS_DECAL_FAMILY | 13 |
| UNKNOWN | 70 |
| MATERIAL_PATCH_SOURCE / PHYSICAL_DAMAGE_MODEL / FULL_SURFACE_MATERIAL | 0 / 0 / 0 |
| Initial discovery scan | 5.9023 s |
| Final unchanged scan | 3.4231 s |
| Current grouped sheets | 16.0054 s |
| Cache hits during grouped generation, including overlaps/prior cache | 169 |
| Eight-candidate shortlist, first generation | 0.6297 s |
| Same shortlist, 8/8 cached | 0.1557 s |

The bounded audit checks **22 entries**, all 13 Unreal notes, all three atlas alpha histograms, actual signatures and independently read Megascans sizes/tileability. Representative IDs:

- `eaf4:FAB_DECAL_PROFILE:concrete_crack_sf2moag:sf2moag`
- `eaf4:FAB_DECAL_PROFILE:concrete_damage_sfcmkbg:sfcmkbg`
- `eaf4:IMPERFECTION_TEXTURE_PROFILE:grunge_tedxadjc:tedxadjc`
- `eaf4:FAB_DECAL_PROFILE:leakage_tculfbnc:tculfbnc`
- `eaf4:FAB_DECAL_PROFILE:tileable_leakage_tc1fdi2c:tc1fdi2c`
- `eaf4:GENERIC_PBR_DECAL_PROFILE:T_Damaged_Concrete_01_TGA:T_Damaged_Concrete_01_TGA`
- `eaf4:GENERIC_PBR_DECAL_PROFILE:City-be_selective%2FCement%2FCracked_wall_1:Cracked_wall_1`
- `eaf4:unreal_atlas:eaf4%3Aunreal_atlas_family%3Aunreal_extracted%252FFactoryEnvironment%252FLeaks%3AM_DecalMap_Leaks%3AT_Decals_Leaks_BCO:MI_Decal_Leaks3`

## Verification and human gate

| Check | Result |
| --- | --- |
| Synthetic Python suite | **23 tests, zero failures, exit 0** |
| Live scan / unchanged rescan | exit 0; all 160/170 unchanged |
| Query/batch CLI | eight crack selections; changed query empty |
| Contact sheets/cache | 26 pages decoded; zero failed previews; 8/8 cache reuse |
| Bounded audit | PASS, 22 entries |
| Godot 4.7 headless editor parse | exit 0; no SCRIPT ERROR or FAIL |
| EAF3 regression | not required; no shared/EAF3 code changed |
| Git whitespace check | passed |

[Test log](../../reports/environment_wear_catalog/synthetic_tests.log), [Godot log](../../reports/environment_wear_catalog/godot_parse.log), and reproduction commands in the [tool README](../../tools/environment_authoring/wear_repository/README.md) are retained. Godot emitted the previously documented Windows root-certificate-store error only. Its importer-only line-ending touch was restored. No runtime scene/script, material catalog or staged asset changed. A local audit probe initially used Windows' default encoding for a Unicode manifest; explicit UTF-8 reading passed.

Known limitations: City/other surface tileability, all live atlas regions, Unreal units/defaults, unknown RSMO/MR packing, two EXR headers, supplemental glTF/bin interpretation, one unitless scan area, and weak semantic suggestions. These remain explicit facts/warnings, not inferred approval.

Human review must assess source safety/archive exclusion, classification, None/zero/missing semantics, understandable triage and the City result. No artistic wear approval state exists.

**Disposition: PROMOTE EAF4A / REVISE EAF4A. Neither selected.**

No merge/push, EAF4B, Godot wear staging, EAF5 or Receiving C1 work is authorized by this technical close-out.
