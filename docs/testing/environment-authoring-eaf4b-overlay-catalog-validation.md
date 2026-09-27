# EAF4B — Wear Overlay, Review, and Curated Catalog Validation

Status: **IMPLEMENTED / TECHNICALLY VERIFIED / HUMAN REVIEW PENDING**

- Branch: codex/eaf4b-wear-overlay-catalog
- Baseline main/origin/main: 06153075bb77564c2ac12161bce62ca60439a4a0
- Implementation commit tested: 29a428f45a2958e8e3936c81aeef41d307b5e5b7
- EAF4A source-index revision: eaf4a-1
- EAF4A source-index fingerprint: ac8a65aa3f0552e8c70824e842a5ac4716988785bf20125c17ddc4c65271944c
- Source authority: EAF4A configured D:\AssetPipeline\EAF4_repository, through its stable-ID index and Repository path guard.
- Review batch: wear_foundation_01
- Live catalog approvals: **zero**. All 14 decision-template entries remain PENDING.

## Scope and source triage

The shortlist came from the promoted EAF4A contact sheets and the EAF4A stable source IDs. City-be_selective, Metal Drain Cover, and Truncated Domes Pad were excluded. No KitBash repository scan or live Unreal atlas interpretation was added. The xetubap source remains technically MASKED_DECAL in EAF4A and is reviewed here as an EAF4 material patch.

| Stable EAF4 source ID | Review role | Selected | Maps |
| --- | --- | ---: | ---: |
| eaf4:FAB_DECAL_PROFILE:concrete_crack_sf2moag:sf2moag | Branched crack / portability | 2K | 4 |
| eaf4:FAB_DECAL_PROFILE:concrete_crack_sfhmrfg:sfhmrfg | Long crack / aspect ratio | 2K | 4 |
| eaf4:FAB_DECAL_PROFILE:concrete_damage_sfcmkbg:sfcmkbg | Compact spall | 2K | 4 |
| eaf4:FAB_DECAL_PROFILE:damaged_concrete_tbqmbayr:tbqmbayr | Broad broken edge | 2K | 4 |
| eaf4:FAB_DECAL_PROFILE:concrete_leakage_tk3jej1c:tk3jej1c | Tight vertical leak | 2K | 2 |
| eaf4:FAB_DECAL_PROFILE:leakage_tculfbnc:tculfbnc | Tapered stain | 2K | 2 |
| eaf4:FAB_DECAL_PROFILE:leakage_skiubhzc:skiubhzc | Broad mineral stain / imperfection A/B | 2K | 2 |
| eaf4:FAB_DECAL_PROFILE:road_dust_sgzh1so:sgzh1so | Floor grime | 2K | 4 |
| eaf4:FAB_DECAL_PROFILE:rust_debris_ugxhbh0h:ugxhbh0h | Corrosion flecks | 2K | 4 |
| eaf4:FAB_DECAL_PROFILE:oil_stain_semlsbi:semlsbi | Floor oil | 2K | 4 |
| eaf4:FAB_DECAL_PROFILE:chipped_paint_patch_ui2ncdjfw:ui2ncdjfw | Chipped old finish | 2K | 4 |
| eaf4:FAB_DECAL_PROFILE:industrial_abandonedfactory_wall_concrete_painted_xetubap:xetubap | Bounded EAF4 paint patch | 4K | 4 |
| eaf4:IMPERFECTION_TEXTURE_PROFILE:grunge_tedxadjc:tedxadjc | Nondirectional scalar breakup | 1K | 1 |
| eaf4:IMPERFECTION_TEXTURE_PROFILE:scratched_metal_vdekebbc:vdekebbc | Directional scratch mask | 1K | 2 |

Total: 14 candidates and 45 selected source maps. The batch records each candidate's available resolutions, selected resolution, rationale, source class, practical primitive, base context, and nonauthoritative starting parameters. xetubap uses 4K because that is its only indexed resolution and its broad patch needs the detail. Each imperfection package stages only its chosen 1K maps. Archives, height, unused resolutions, and full source packages are not copied.

## Staging and fingerprints

The Python workflow resolves every live map as stable source ID → EAF4A index → guarded repository-relative map → EAF4A Repository.open. Batch, decision, and catalog records reject absolute/resource paths and path/root fields. Staging uses a deterministic hashed ID and resolution under ignored res://assets/environment/wear/eaf4_cache/. Each staged byte stream is checked against its source SHA-256; all 45 staged-map hashes matched in the final audit.

Each strong review fingerprint hashes the stable ID, selected resolution, selected map names and source-relative identities, the SHA-256 of each selected map's bytes, EAF4A interpretation facts, and profile revision. Unselected resolution map bytes do not enter the fingerprint. Changing a selected map changed the fixture fingerprint. A stale EAF4A index identity blocks preparation. Optional imperfection dependencies carry their own fingerprint; a changed dependency derives STALE for a catalog entry that uses it.

## Godot 4.7 import and render policy

The existing EAF3 import normalizer is reused for staged EAF4 maps. The final Godot 4.7 import sidecars showed:

- Basecolor: texture import, compress/mode=0, mipmaps/generate=true, normal_map=0, process/hdr_as_srgb=false; sampled with the shader's source_color hint. Embedded alpha remains in the color texture.
- Normal: compress/normal_map=1, mipmaps/generate=true, process/normal_map_invert_y=false. Normal-Y flip is a shader parameter, preserving source bytes.
- Roughness/opacity/data: compress/normal_map=0, mipmaps/generate=true, process/hdr_as_srgb=false; sampled without source_color.
- Source file bytes remain untouched. Sidecars and staged maps remain ignored local cache.

EnvironmentWearOverlaySpec stores source identity/fingerprint separately from review parameters, textures, surface capabilities, physical size, atlas region, and optional imperfection controls. Validation bounds physical dimensions, 0.0005–0.01 m offset, opacity, albedo/normal/roughness strengths, atlas UV rectangle, alpha source, and imperfection controls.

EnvironmentWearOverlay generates one QuadMesh at exact dimensions in metres, keeps its root scale at Vector3.ONE, applies a default 0.002 m normal offset, and binds independent rotation/mirror controls. Regeneration is deterministic. CUTOUT uses alpha scissor with opaque depth behavior; SOFT_BLEND uses alpha depth prepass plus a narrow UV edge feather. Both support separate opacity or embedded alpha, color contribution 0–1, tint, normal strength/Y, roughness, optional metallic, and atlas UV rectangle. No displacement, projected volume, or Godot Decal node is used.

EnvironmentMaterialPatch is a distinct node. EAF3_MATERIAL resolves only a current approved EAF3 catalog ID through the promoted query and builder. EAF4_SOURCE accepts a bounded wear spec for xetubap. The four base contexts in the review scene are the current approved EAF3 ConcreteRoughBright, ConcretePittedGrayMed, ConcreteFloorPanelsRoughA, and PlasterA specs.

## Review and visual evidence

The review scene composes the promoted EAF1 lookdev scene and its light rigs, environment, camera/shadow fix, and injection seam. Fixed wear cameras and wall/floor placements support close inspection. Bounded keys cycle candidates, light rig, camera, base material, opacity, albedo, normal, rotation, mirror, imperfection, and reset. The scene is a review tool, not a production room.

Reproduction from the project root:

    python -m tools.environment_authoring.wear_catalog.cli prepare --batch wear_foundation_01
    python -m tools.environment_authoring.wear_catalog.cli capture --batch wear_foundation_01

The capture produced 81 PNGs: four per candidate (Neutral/Receiving × Hero/WallGrazing), 16 shared base-only references, and nine extra proofs. The manifest records source ID/fingerprint, practical primitive, patch mode where relevant, EAF3 base ID, physical size and offset, rotation/mirror, opacity, albedo/tint, normal/Y, roughness, imperfection mask/settings, camera/light mode and light settings. Imperfection candidate captures explicitly identify the real stain used as their proxy. The deterministic package has 84 allowlisted members: 81 PNGs, manifest.json, batch_summary.md, and decision_template.json. It contains no source map or import sidecar.

- Review package: reports/environment_wear_catalog/reviews/wear_foundation_01_review.zip
- Expanded review: reports/environment_wear_catalog/reviews/wear_foundation_01/
Both are ignored local evidence. The package is about 244 MB because it contains 81 lossless 1920×1080 PNG captures.

Visual checks:

- Hard mask: sf2moag's crack silhouette has no visible source rectangle at Hero or WallGrazing. Physical size and 0.002 m offset remained stable in Neutral and Receiving. Normal and roughness map bindings were tested.
- Soft blend: real leakage and floor stains retain the EAF3 substrate; narrow feathering removes a hard card edge. No isolated sorting failure appeared in the reviewed nonoverlapping placements.
- Portability: sf2moag on light ConcreteRoughBright and dark ConcretePittedGrayMed was captured at full versus 0.25 source albedo. Reduced color leaves the base substrate more coherent.
- Imperfection: leakage_skiubhzc with and without real grunge_tedxadjc gives a visible, localized breakup; the difference image bounding box was x=804–1143, y=339–753 in the 1920×1080 capture.
- Patches: PlasterA over concrete resolves through EAF3; xetubap renders as a broad EAF4 paint region through the separate patch primitive. xetubap is deliberately review pending.
- Synthetic Unreal atlas: original 256×128 RGBA fixture contains two independent logical regions with UV rectangles [0,0,0.5,1] and [0.5,0,0.5,1]. Both colors and feathered alpha appeared in one capture. No unresolved live Unreal atlas entry was rendered.
- Causality: a simple metal service proxy sits above two sparse, nonoverlapping soft leakage layers. This proves placement control without dressing a production room.

## Catalog and synthetic state proof

Tracked data/environment/wear_catalog/catalog.json is separate from EAF3 and has no live entries yet. Decision templates remain PENDING. Human decisions can record APPROVED, REJECTED, or DEFERRED with a positive revision. Reconciliation preserves human fields, rejects same-revision edits, emits an audit, and derives STALE, SOURCE_MISSING, or UNSUPPORTED from current indexed inputs. Default query returns current APPROVED only and filters semantic category, cause tag, surface capability, and render mode.

Synthetic fixtures proved APPROVED → guarded restaging → generated WearOverlaySpec, including an optional guarded imperfection mask. A changed primary or dependent mask becomes STALE and disappears from the default query. A missing source becomes SOURCE_MISSING. REJECTED and DEFERRED states remain distinct. Idempotent reconciliation emits no new audit. Godot tests loaded/rendered synthetic overlay specs and checked shader bindings and independent atlas regions. No synthetic decision was applied to the live catalog.

## Verification

- EAF4B Python unit suite: 10 tests passed.
- EAF4B Godot spec/overlay/patch/query/atlas test: EAF4B_GODOT_TEST_PASS.
- EAF4A synthetic suite: 23 tests passed.
- EAF3B Python catalog suite: 15 tests passed.
- EAF3B Godot query and live catalog suites: failures=0 in each.
- EAF1 Godot focused lookdev/capture suite: failures=0, including promoted WallGrazing shadow invariants and injection restoration.
- Godot headless review-scene parse: exit 0, no script errors.
- Compatibility capture: OpenGL 3.3/NVIDIA, 81 records, capture command exit 0.
- Final package audit: 84 unique members, only manifest-listed PNGs and three allowed metadata files; every staged-map byte hash matched its source anchor.
- Windows Godot startup printed a root certificate-store warning in these runs; it did not affect local import, tests, or capture.

## Human review and limitations

Human review must decide the final source set, sizes, categories, strengths, and approvals. In particular, xetubap's bright paint region and subtle floor grime/oil need artistic judgment. Soft transparent planes should stay sparse and separated; prefer CUTOUT for hard masks, avoid coincident soft planes, and retest any production placement under its actual lighting. The 0.002 m default is technically stable in the review scene, but tight production geometry may need a local offset check.

The tracked .tres review specs reference ignored staged assets. A fresh checkout needs the EAF4A root/config and a prepare/import run before those specs can load. The review ZIP contains captures and decisions only, so it can be shared without the commercial map cache. No live wear entry was approved, no EAF4B or overall EAF4 promotion occurred, and Receiving C1 and EAF5 remain untouched.
