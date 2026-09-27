# EAF5 Pass 2 — Receiving material PBR review

**Status: 31 SOURCES STAGED / 124 CAPTURES VERIFIED / HUMAN PBR REVIEW PENDING.** The source-shortlist record preserves an unresolved per-ID HOLD/DROP split because the handoff provided counts but not the 26 identities.

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

## Human gate

All 31 EAF3B decision templates remain PENDING. Review color/value, roughness, normal direction and strength, physical repeat, visible tiling, directionality, baked history and Neutral versus Receiving response. Wall and ceiling candidates need quiet large-area coverage; floors need to avoid dominant grids and baked traffic motifs; applied finishes should read over structure; patterned structural secondary materials may still suit reveals/recesses. Decide APPROVE/REJECT/DEFER or request a parameter-only rerun through the promoted EAF3B mechanism. EAF5 proposed roles are not EAF3 approved roles; Receiving room-scale suitability is a later gate.
