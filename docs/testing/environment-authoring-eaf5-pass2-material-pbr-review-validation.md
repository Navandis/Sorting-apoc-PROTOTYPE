# EAF5 Pass 2 — Receiving material PBR review

**Status: EAF5 PASS 2 — 24 MATERIAL DECISIONS RECONCILED / 7 HUMAN PBR DECISIONS PENDING.** The source-shortlist record preserves an unresolved per-ID HOLD/DROP split because the handoff provided counts but not the 26 identities.

- Branch: `codex/eaf5-receiving-proof`; pre-edit HEAD `64d99fc884c5d19b42b7b334cab97d3a3d457304`; `main` and `origin/main` `ac12a51ce431f94c9a65a4e84edbf2f73bdf5c2c`; pre-edit tree clean. No merge or push.
- Pass-1 accepted. [Shortlist manifest](../../data/environment/receiving_proof/eaf5_material_source_shortlist_01.json) and [human decision record](../../data/environment/receiving_proof/decisions/eaf5_source_shortlist_01_human_review.json) anchor the reviewed source snapshot. EAF3A index fingerprint `e6398707ff5a1f47d1be2855ad04986a5ba39eb8fbc04fbc107f1a01479de23d` still matches; 31/31 IDs exist and have no EAF3 catalog decision.
- Human counts: 31 SHORTLIST, 15 HOLD, 11 DROP; the handoff explicitly named only the 31 SHORTLIST IDs. The other 26 are recorded as `HOLD_OR_DROP_UNSPECIFIED` and excluded from both batches. This is an outstanding record-completeness item, not an inferred decision. Five existing current EAF3 approvals are retained without recapture.

## Batch membership and staging

Both tracked batches were generated through promoted `catalog.make_batch` and staged with `material_catalog.cli prepare`. The EAF3B batch schema, cache, spec generator, fingerprinting, import normalization, EAF1 review-set injection and packaging were reused. EAF3B sorted IDs by stable ID in each batch. All 31 requested and received local 2K; no fallback or changed source was found. Roles and Pass-1 rationale accompany every source in the [EAF5 review summary](../../reports/environment_receiving_proof/eaf5/pbr_review_01_summary.md).

### `eaf5_receiving_pbr_01a` — 16 sources

- Membership: `fab:ueypchdcw`; `fab:uirleimn`; `fab:vi4idbm`; `kitbash:kb3d_aftermath@7.0.2:KB3D_AFT_ConcreteB`; `kitbash:kb3d_americana@7.0.2:KB3D_AMC_ConcreteWhite`; `kitbash:kb3d_apartmentinteriors@7.0.2:KB3D_API_ConcreteWallA`; `kitbash:kb3d_archvogue@7.0.3:KB3D_ARV_ConcreteGray`; `kitbash:kb3d_beyondrepair@7.0.0:KB3D_BYR_COReinforcedConcreteSlabs`; `kitbash:kb3d_brooklyn@7.0.2:KB3D_BRK_ConcreteGrey`; `kitbash:kb3d_brooklyn@7.0.2:KB3D_BRK_ConcreteWarmGrey`; `kitbash:kb3d_brutalisttff@7.0.3:KB3D_BTL_ConcreteBlocksA`; `kitbash:kb3d_brutalisttff@7.0.3:KB3D_BTL_ConcreteLightWall`; `kitbash:kb3d_brutalisttff@7.0.3:KB3D_BTL_ConcreteNoiseFlat`; `kitbash:kb3d_brutalisttff@7.0.3:KB3D_BTL_ConcreteRoughPanelBright`; `kitbash:kb3d_cyberpunkinteriors@7.0.2:KB3D_CPI_CinderBlocksPDGray`; `kitbash:kb3d_washingtondc@7.0.3:KB3D_WDC_ConcreteBlocksA`.
- Staged maps: 76, 371,676,607 bytes. EAF1 capture records: 64; four fixed light/camera combinations per source.
- [ZIP](../../reports/environment_material_catalog/reviews/eaf5_receiving_pbr_01a_review.zip): 124,710,874 bytes; SHA-256 `ae1209cf425b54bd9a1f3138af94fd12b9e3faab0825a5f827df052f20508511`; 67 allowlisted entries (captures, manifest, summary, pending decision template).

### `eaf5_receiving_pbr_01b` — 15 sources

- Membership: `fab:pjBkT0`; `fab:sl2qedtp`; `fab:tixmdgdcw`; `fab:ufmgaccg`; `fab:ufvpdcxfw`; `fab:ugkkedvlw`; `fab:uikpbgjdy`; `fab:virrebs`; `fab:viyjde3`; `kitbash:kb3d_brutalisttff@7.0.3:KB3D_BTL_ConcreteBlocksB`; `kitbash:kb3d_brutalisttff@7.0.3:KB3D_BTL_ConcreteNoiseFlatGrey`; `kitbash:kb3d_constructionzone@7.0.3:KB3D_CSZ_ConcreteBlocksBPanels`; `kitbash:kb3d_everycitypolicedept@7.0.2:KB3D_ECP_StuccoWhite`; `kitbash:kb3d_neonyc@7.0.2:KB3D_NNY_ConcretePlasterWhite`; `kitbash:kb3d_refineries@7.0.2:KB3D_RFS_ConcretePlasterWhite`.
- Staged maps: 66, 230,326,221 bytes. EAF1 capture records: 60; four fixed light/camera combinations per source.
- [ZIP](../../reports/environment_material_catalog/reviews/eaf5_receiving_pbr_01b_review.zip): 95,119,067 bytes; SHA-256 `65b8d8b9e96298293e28e04269708b2dc7c44ffddad0c66b5e6776aa1850206f`; 63 allowlisted entries (captures, manifest, summary, pending decision template).

## Review parameters and controls

- Initial mapping: 22 TRIPLANAR and 9 UV; 30 use 1.5 m/repeat and one FAB plaster uses 1.0 m/repeat. These are review hints. All specs start with source normal Y (`normal_y_flip=false`), normal strength 1.0 and albedo/roughness/metallic multipliers 1.0. The 4×2 m and 2×1 m FAB scan areas cannot map faithfully into the scalar repeat setting; exact scale remains a human/room review question. FAB normal convention is unlabelled.
- Promoted EAF3B selected only basecolor, normal, roughness, metallic and AO where supported. Height remains reference-only; unsupported packed/specular/cavity/gloss channels are facts, not staged interpretations. One KitBash source reports an unsupported Substance graph.
- Strong SHA-256 source fingerprints were regenerated and matched for all 31 at reviewed 2K. The fingerprint anchors stable ID, actual resolution, selected repository-relative map names and hashes, channel states, and source profile/revision. All cached map hashes match the selected source map hashes.
- The existing five approvals are current: `eaf3b_1435ce254f04bb8e61bd3e96`, `eaf3b_20c61bd1c85420be2f71a090`, `eaf3b_39b926e570fb3824019aade2`, `eaf3b_bd0940113f04f3d3784629e7`, `eaf3b_8d5f0cf5add98dfe0a58f18a`. Each has a tracked approved spec and matching live strong fingerprint; default approved query returns exactly five. No candidate was reconciled into the catalog.

## Capture, package and regression verification

- 142 maps / 602,002,828 bytes staged in the existing ignored cache. 142 Godot `.import` records checked: lossless compression, mipmaps, normal-map mode for normals, no green-channel inversion and 3D compression disabled. The two capture commands normalized 76 and 66 records respectively.
- All 124 PNGs decode at 1920×1080, and the capture manifests contain exactly Neutral/Hero, Neutral/WallGrazing, Receiving/Hero and Receiving/WallGrazing once per candidate. One representative Hero capture was visually inspected. Both ZIPs passed integrity and exact allowlist checks; no maps, cache, vendor metadata or `.import` records are inside.
- EAF5 Pass-2 focused Python tests: 4 passed. EAF3A repository: 36 passed. EAF3B catalog/workflow: 16 passed. EAF1 Godot: `EAF1_TESTS failures=0`. EAF3B synthetic/live Godot: `EAF3B_QUERY_TESTS failures=0`, `EAF3B_LIVE_CATALOG_TESTS failures=0`. Godot 4.7 editor import/parse exited 0.
- The existing Windows root-certificate-store startup warning appeared; tests, import and captures exited 0. Production wing scene/builder paths and Receiving runtime paths were not edited. No proof room, palette combination, wear or C1 work began.


## Supersession and UV01 review lineage

The initial 22 triplanar / 9 UV review mix showed a systemic high-frequency grid on large EAF1 surfaces. The original Pass-2 packages above are **SUPERSEDED — TRIPLANAR ARTIFACT INVESTIGATION EVIDENCE**. Keep their exact ZIP bytes and hashes; do not use their pending decision templates for human material decisions. The [UV-default maintenance validation](environment-authoring-triplanar-uv-default-maintenance.md) records the controlled diagnostic.

All 31 sources were recaptured under UV with the same strong source fingerprints and unchanged starting parameters other than mapping. Both new packages have wholly regenerated screenshots and fresh PENDING templates.

| Batch | Capture count | ZIP SHA-256 |
| --- | ---: | --- |
| [eaf5_receiving_pbr_01a_uv01](../../reports/environment_material_catalog/reviews/eaf5_receiving_pbr_01a_uv01_review.zip) | 64 | d42265553a950158efc614f66962257e5ce5729636df14d528e34f43ef1cb875 |
| [eaf5_receiving_pbr_01b_uv01](../../reports/environment_material_catalog/reviews/eaf5_receiving_pbr_01b_uv01_review.zip) | 60 | dd8ce4481e1540254c5ba96daf516505daa44b138b03d10955ee35e6aed4f0be |

The three current triplanar-approved EAF3 seeds were separately captured with only mapping changed to UV in [eaf5_seed_uv_policy_check_01](../../reports/environment_material_catalog/reviews/eaf5_seed_uv_policy_check_01_review.zip): 12 images, SHA-256 f601859c09285bf7f3859076e5a62cf704da84e8202c9c2c98029cb5378aa0d8. Their catalog mappings remain unchanged. No material decision was reconciled.

**EAF5 Pass-2 disposition: IMPLEMENTED / TECHNICALLY VERIFIED / HUMAN PBR REVIEW PENDING.**

## Human gate

All 31 UV01 EAF3B decision templates remain PENDING. Review color/value, roughness, normal direction and strength, physical repeat, visible tiling, directionality, baked history and Neutral versus Receiving response. Wall and ceiling candidates need quiet large-area coverage; floors need to avoid dominant grids and baked traffic motifs; applied finishes should read over structure; patterned structural secondary materials may still suit reveals/recesses. Decide APPROVE/REJECT/DEFER or request a parameter-only rerun through the promoted EAF3B mechanism. EAF5 proposed roles are not EAF3 approved roles; Receiving room-scale suitability is a later gate.

## UV01 human review and parameter rerun — 2026-09-28

The clean UV01 packages were the sole artistic evidence for this decision round. [Tracked decision input](../../data/environment/material_catalog/decisions/eaf5_receiving_pbr_uv01_human_review_01.json) copies review resolution, strong source fingerprint, display name and every mapping/PBR parameter from the clean pending templates. It records 18 APPROVED, 4 DEFERRED and 2 REJECTED. Seven additional sources remain undecided. Reconciliation through the EAF3B CLI created 24 records; a second run reported 36 unchanged with no stale or missing source. The catalog now contains 36 final decisions: 23 APPROVED, 7 DEFERRED and 6 REJECTED. Default current-approved query returns 23. Approved restaging completed 23 specs with zero refused.

The seven undecided sources have one [rerun batch](../../data/environment/material_catalog/review_batches/eaf5_receiving_pbr_01_rerun_01/batch.json) and a separate [parameter-only iteration](../../data/environment/material_catalog/review_batches/eaf5_receiving_pbr_01_rerun_01/iteration.json). The clean UV01 parameters, including UV mapping, 2K review resolution, normal Y/strength and all other multipliers, are the baseline. The only changes are:

| Source | Sole parameter change |
| --- | --- |
| KB3D_BYR_COReinforcedConcreteSlabs | meters_per_repeat = 3.0 |
| KB3D_WDC_ConcreteBlocksA | albedo_multiplier = 0.75 |
| fab:ugkkedvlw | albedo_multiplier = 0.65 |
| KB3D_CSZ_ConcreteBlocksBPanels | albedo_multiplier = 0.75 |
| KB3D_ECP_StuccoWhite | albedo_multiplier = 0.70 |
| KB3D_NNY_ConcretePlasterWhite | albedo_multiplier = 0.70 |
| KB3D_RFS_ConcretePlasterWhite | albedo_multiplier = 0.70 |

Before capture, all seven rerun stable IDs, selected map records and SHA-256 hashes, strong reviewed source fingerprints, and actual review resolutions matched the clean UV01 staging. The deterministic cache reused source maps; no source bytes needed copying. The unchanged EAF1 scene captured Neutral/Hero, Neutral/WallGrazing, Receiving/Hero and Receiving/WallGrazing for each material: 28 PNGs. All seven new decision-template entries remain PENDING. The [shareable rerun ZIP](../../reports/environment_material_catalog/reviews/eaf5_receiving_pbr_01_rerun_01_review.zip) contains only the 28 captures, manifest.json, batch_summary.md and decision_template.json; no maps or .import files. SHA-256: `625fe5cdd5f84a393749c3ada6868a895e701f0b66b6bd3ef8941a2388922465`.

UV is the **permanent default environment material mapping policy**, confirmed by human review. Triplanar and world triplanar remain supported only for an explicit, documented geometry/source reason and representative large-plane, multi-axis and WallGrazing visual verification. The three historical triplanar seed approvals (ConcreteRoughBright, ConcretePittedGrayMed, PlasterA) retain their catalog parameters. Their UV policy-check captures are separate evidence; no parameter-revision decision has been made for them. Original triplanar packages, clean UV01 A/B packages, seed policy-check package and diagnostic captures remain preserved. The clean UV01 ZIP SHA-256 values are still `d42265553a950158efc614f66962257e5ce5729636df14d528e34f43ef1cb875` and `dd8ce4481e1540254c5ba96daf516505daa44b138b03d10955ee35e6aed4f0be`.

Verification: EAF3B Python 17 passed; EAF5 Receiving Python 12 passed in strict local-evidence mode; EAF3B Godot query and live catalog tests, EAF1 lookdev tests, Godot editor import/parse and the rerun capture exited 0. The package integrity and 28-record matrix passed focused tests. EAF3A index/query files were untouched. Production wing, Receiving runtime, EAF4 and C1 files remain untouched; room and palette work remain paused.

**EAF5 PASS 2 — 24 MATERIAL DECISIONS RECONCILED / 7 HUMAN PBR DECISIONS PENDING.**
