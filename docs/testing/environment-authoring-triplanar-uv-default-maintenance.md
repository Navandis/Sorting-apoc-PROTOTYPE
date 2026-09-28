# EAF5 triplanar investigation and UV-default maintenance

**Disposition: TRIPLANAR ARTIFACT REPRODUCED / BUILT-IN PATH LIMITATION OR ROOT CAUSE UNRESOLVED. UV PROMOTED AS DEFAULT. TRIPLANAR RETAINED ONLY AS EXCEPTIONAL, EXPLICITLY VERIFIED MODE.**

Branch: codex/eaf5-receiving-proof. Engine: Godot 4.7 stable, Compatibility renderer (gl_compatibility), OpenGL 3.3 on NVIDIA GeForce RTX 5060 Ti. The existing EAF1 WallGrazing shadow-acne correction remains in place. No production wing, Receiving runtime, catalog decision, renderer, camera, light, environment, exposure or tonemap was edited.

## Symptom and preserved evidence

The supplied 1920 × 1080 EAF1 Neutral/WallGrazing screenshots for KB3D_AFT_ConcreteB and FAB Dirty Concrete show a fine crosshatch/grid on large walls, floor and ceiling. It is absent from the raw source maps, dramatically reduced on the approximately 1 m beveled block, and absent on the UV comparison. The original Pass-2 capture packages are preserved as **SUPERSEDED — TRIPLANAR ARTIFACT INVESTIGATION EVIDENCE**:

| Original ZIP | Captures | Original bytes | SHA-256 |
| --- | ---: | ---: | --- |
| reports/environment_material_catalog/reviews/eaf5_receiving_pbr_01a_review.zip | 64 | 124,710,874 | ae1209cf425b54bd9a1f3138af94fd12b9e3faab0825a5f827df052f20508511 |
| reports/environment_material_catalog/reviews/eaf5_receiving_pbr_01b_review.zip | 60 | 95,119,067 | 65b8d8b9e96298293e28e04269708b2dc7c44ffddad0c66b5e6776aa1850206f |

No screenshot or pending decision template from those ZIPs may be used for artistic reconciliation.

## Mapping audit before the default change

The original two batch JSON files contain explicit mapping overrides for all 31 candidates. Batch A had 9 TRIPLANAR and 7 UV; batch B had 13 TRIPLANAR and 2 UV. WORLD_TRIPLANAR had zero. The original default alone did not cause the old mapping mix; the candidate overrides did.

| Batch | Stable ID | Old mapping | Cause |
| --- | --- | --- | --- |
| A | fab:ueypchdcw | TRIPLANAR | explicit candidate override |
| A | fab:uirleimn | UV | explicit candidate override |
| A | fab:vi4idbm | UV | explicit candidate override |
| A | kitbash:kb3d_aftermath@7.0.2:KB3D_AFT_ConcreteB | TRIPLANAR | explicit candidate override |
| A | kitbash:kb3d_americana@7.0.2:KB3D_AMC_ConcreteWhite | TRIPLANAR | explicit candidate override |
| A | kitbash:kb3d_apartmentinteriors@7.0.2:KB3D_API_ConcreteWallA | TRIPLANAR | explicit candidate override |
| A | kitbash:kb3d_archvogue@7.0.3:KB3D_ARV_ConcreteGray | TRIPLANAR | explicit candidate override |
| A | kitbash:kb3d_beyondrepair@7.0.0:KB3D_BYR_COReinforcedConcreteSlabs | UV | explicit candidate override |
| A | kitbash:kb3d_brooklyn@7.0.2:KB3D_BRK_ConcreteGrey | TRIPLANAR | explicit candidate override |
| A | kitbash:kb3d_brooklyn@7.0.2:KB3D_BRK_ConcreteWarmGrey | TRIPLANAR | explicit candidate override |
| A | kitbash:kb3d_brutalisttff@7.0.3:KB3D_BTL_ConcreteBlocksA | UV | explicit candidate override |
| A | kitbash:kb3d_brutalisttff@7.0.3:KB3D_BTL_ConcreteLightWall | TRIPLANAR | explicit candidate override |
| A | kitbash:kb3d_brutalisttff@7.0.3:KB3D_BTL_ConcreteNoiseFlat | TRIPLANAR | explicit candidate override |
| A | kitbash:kb3d_brutalisttff@7.0.3:KB3D_BTL_ConcreteRoughPanelBright | UV | explicit candidate override |
| A | kitbash:kb3d_cyberpunkinteriors@7.0.2:KB3D_CPI_CinderBlocksPDGray | UV | explicit candidate override |
| A | kitbash:kb3d_washingtondc@7.0.3:KB3D_WDC_ConcreteBlocksA | UV | explicit candidate override |
| B | fab:pjBkT0 | TRIPLANAR | explicit candidate override |
| B | fab:sl2qedtp | TRIPLANAR | explicit candidate override |
| B | fab:tixmdgdcw | TRIPLANAR | explicit candidate override |
| B | fab:ufmgaccg | TRIPLANAR | explicit candidate override |
| B | fab:ufvpdcxfw | TRIPLANAR | explicit candidate override |
| B | fab:ugkkedvlw | TRIPLANAR | explicit candidate override |
| B | fab:uikpbgjdy | TRIPLANAR | explicit candidate override |
| B | fab:virrebs | TRIPLANAR | explicit candidate override |
| B | fab:viyjde3 | TRIPLANAR | explicit candidate override |
| B | kitbash:kb3d_brutalisttff@7.0.3:KB3D_BTL_ConcreteBlocksB | UV | explicit candidate override |
| B | kitbash:kb3d_brutalisttff@7.0.3:KB3D_BTL_ConcreteNoiseFlatGrey | TRIPLANAR | explicit candidate override |
| B | kitbash:kb3d_constructionzone@7.0.3:KB3D_CSZ_ConcreteBlocksBPanels | UV | explicit candidate override |
| B | kitbash:kb3d_everycitypolicedept@7.0.2:KB3D_ECP_StuccoWhite | TRIPLANAR | explicit candidate override |
| B | kitbash:kb3d_neonyc@7.0.2:KB3D_NNY_ConcretePlasterWhite | TRIPLANAR | explicit candidate override |
| B | kitbash:kb3d_refineries@7.0.2:KB3D_RFS_ConcretePlasterWhite | TRIPLANAR | explicit candidate override |

## Controlled diagnostic

Tracked diagnostic runner: tools/asset_pipeline/tests/eaf5_triplanar_diagnostic.tscn and its GDScript. It regenerates ten local PNGs under reports/environment_lookdev/eaf5_triplanar_uv_diagnostic/. After preparing the original Pass-2 batch and its ignored texture cache, run Godot 4.7 with --path . and the tracked scene path to replay the matrix. It instantiates the existing EAF1 lookdev scene and its EAF3B resources; material property changes are transient and absent from production specs. The primary source is KB3D_AFT_ConcreteB, the unrelated package/profile check is FAB Dirty Concrete, and KB3D_BTL_ConcreteRoughPanelBright is a UV control. All use EAF1 geometry, Neutral Calibration, fixed WallGrazing, 1.5 m/repeat, and Compatibility.

| Variant | AFT large-wall result |
| --- | --- |
| 01 UV, full PBR | Clean; raw crack and mottling character visible |
| 02 local TRIPLANAR, full PBR | Dense high-frequency grid |
| 03 WORLD_TRIPLANAR, full PBR | Dense grid with changed alignment |
| 04 TRIPLANAR, albedo only, normal disabled | Grid remains |
| 05 TRIPLANAR, albedo + normal, scalar PBR neutral | Grid remains |
| 06 TRIPLANAR, full PBR, ordinary linear mipmap filtering | Grid remains |
| Additional sharpness 8 versus default 1 | One wall improves, another still shows conspicuous grid |

FAB Dirty Concrete repeats the clean UV versus gridded triplanar result. Godot 4.7 property inspection confirmed uv1_triplanar, uv1_world_triplanar, uv1_scale, uv1_triplanar_sharpness and texture_filter. The builder applies reciprocal metres to UV and triplanar, and uses anisotropic mipmap filtering. The grid survives normal and scalar PBR removal, so those channels are not required. It survives ordinary mipmap filtering and world triplanar. Sharpness 8 is not reliable across orthogonal walls. This isolates the current artifact to the built-in triplanar rendering path under this renderer/hardware; it does not prove a Godot engine bug or identify the shader-level mechanism. There is no small, evidence-based owner-system fix, so the bounded investigation stops here.

## UV default and exceptional triplanar policy

EnvironmentSurfaceMaterialSpec already defaulted to UV. EAF3B DEFAULT_PARAMETERS mapping now also defaults to UV. The MAPPINGS enum, batch/iteration overrides, and built-in triplanar builder path remain. Use TRIPLANAR or WORLD_TRIPLANAR only for a documented geometry/source reason, such as unusable UVs on irregular geometry, impractical planar continuity for a seamless mineral surface, or a verified multi-axis case. Concrete, plaster, quiet color, or non-directionality alone do not justify it. Every explicit triplanar review requires a large plane, corner/multi-axis form, and WallGrazing visual check before human approval.

All five current EAF3 approvals retain their explicit catalog mapping decisions. Three triplanar approvals — ConcreteRoughBright, ConcretePittedGrayMed and PlasterA — have separate UV policy-check evidence. Their approved source fingerprint, resolution, scale, normal strength/Y and other scalar parameters are unchanged in that check; it does not reconcile or migrate catalog decisions.

## UV sample gate and clean recapture

Before full packaging, 24 sample images covered three previously affected quiet surfaces (AFT ConcreteB, FAB Dirty Concrete and BTL ConcreteNoiseFlat), one panel/formwork source (BTL ConcreteRoughPanelBright), one floor (FAB Industrial Concrete Floor), and one applied finish (ECP StuccoWhite), across Neutral/Receiving and Hero/WallGrazing. Large walls show no false fine grid; source character remains legible. Hero framing, intentional cast shadows and Neutral/Receiving comparison remain useful. ECP StuccoWhite is very bright in Neutral; its artistic suitability is a later human decision.

The clean UV01 capture packages share one policy and freshly generated screens:

| Package | Sources | PNGs | ZIP bytes | ZIP SHA-256 |
| --- | ---: | ---: | ---: | --- |
| reports/environment_material_catalog/reviews/eaf5_receiving_pbr_01a_uv01_review.zip | 16 | 64 | 134,501,063 | d42265553a950158efc614f66962257e5ce5729636df14d528e34f43ef1cb875 |
| reports/environment_material_catalog/reviews/eaf5_receiving_pbr_01b_uv01_review.zip | 15 | 60 | 107,270,525 | dd8ce4481e1540254c5ba96daf516505daa44b138b03d10955ee35e6aed4f0be |
| reports/environment_material_catalog/reviews/eaf5_seed_uv_policy_check_01_review.zip | 3 approved seeds | 12 | 24,317,768 | f601859c09285bf7f3859076e5a62cf704da84e8202c9c2c98029cb5378aa0d8 |

All 31 stable IDs and their strong source fingerprints match the original staging; 142 selected staged maps and their cache bytes match source SHA-256. The 16/15 membership split is unchanged. Every UV01 generated spec and capture record maps UV. All 31 new decision entries remain PENDING. PNGs decode at 1920 × 1080 with four required combinations per candidate. The three seed checks also have four combinations each. No old screenshots were mixed into the new packages.

## Verification

- Artifact checks were run in strict local mode with EAF5_REQUIRE_LOCAL_EVIDENCE=1; a clean checkout without ignored captures reports skips in the normal Python suite and fails in strict mode until prepare/capture regenerates the evidence.
- EAF3B Python catalog/workflow: 17 passed, including no override, explicit TRIPLANAR, iteration WORLD_TRIPLANAR, staging reuse and human mapping preservation.
- EAF5 receiving proof Python: 10 passed; EAF3A repository Python: 36 passed.
- EAF1 Godot focused suite: EAF1_TESTS failures=0, including non-casting large receivers, casting beveled block and ShadowStructure, fixed cameras and WorldEnvironment.
- EAF3B Godot synthetic query and live catalog suites: EAF3B_QUERY_TESTS failures=0; EAF3B_LIVE_CATALOG_TESTS failures=0.
- Godot editor import/parse: exit 0. Capture commands and ten controlled diagnostic images: exit 0.
- Only the existing Windows root-certificate-store startup warning appeared. No script or parse error.
- Production wing files and gameplay/logistics_wing/receiving remain untouched; no Receiving proof room, palette combinations, EAF4 wear or Receiving C1 work.

**EAF5 Pass-2 status: IMPLEMENTED / TECHNICALLY VERIFIED / HUMAN PBR REVIEW PENDING.**
