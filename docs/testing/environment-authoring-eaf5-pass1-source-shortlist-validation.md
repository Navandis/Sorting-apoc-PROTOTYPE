# EAF5 pass 1 — Receiving architectural source and material shortlist

**Status: EAF5 PASS 1 IMPLEMENTED / TECHNICALLY VERIFIED / HUMAN SOURCE-SHORTLIST REVIEW PENDING**

- Branch: codex/eaf5-receiving-proof, local only; no merge or push.
- Baseline main, origin/main and pre-edit HEAD: ac12a51ce431f94c9a65a4e84edbf2f73bdf5c2c, clean. At technical verification HEAD remained the baseline while implementation was staged; the final handoff reports the local commit SHA.
- Read-only authority: gameplay/logistics_wing/wing_gameplay.tscn → wing_environment.tscn → saved greybox/logistics_wing/wing_geometry.tscn. The greybox builder and accepted validation explain joins. These production paths and Receiving runtime files are unchanged.
- The attached EAF5 pass-1 instruction authorizes this bounded work over older design-only status text. Receiving C1 stays paused.

## Promoted-system reuse

The tracked [reuse matrix](../../data/environment/receiving_proof/eaf5_reuse_matrix.md) names each exact implementation seam and new-code need. EAF1 owns material specs, PBR construction and fixed Neutral/Receiving lookdev. EAF2 owns generated substrate, collision, metre UVs, recipes, seeds and fingerprints. EAF3A owns guarded indexing, eligibility queries, stable-ID batches and sheets. EAF3B owns selective staging, strong fingerprints, EAF1 review and current-approved catalog/spec query. EAF4 owns causal wear overlays and patches for later room work. EAF5 adds Receiving manifests and package assembly. A small EAF3A extension adds optional role/profile/catalog-state annotations to its existing sheet builder; it adds no image loader.

## Saved geometry and EAF2 mapping

The [shell manifest](../../data/environment/receiving_proof/eaf5_receiving_shell_source.json) uses local origin world (-39, 0, 0), +X east, +Z south, Y up and Y=0 finished floor. It records source blobs, all 21 saved floor/ceiling/wall boxes and six freight-barrier context boxes, exact saved sizes/centers, apertures, and 19 planned EAF2 pieces. Saved scene and builder agree:

| Structure | Nominal authored dimensions | Saved/face detail |
| --- | --- | --- |
| Apron | 10.50 × 10.00 m, 4.20 m clear | Floor/ceiling 0.30 m thick; south joined wall is 10.80 m across 0.15 m corner joins. |
| Freight enclosure | 5.00 m deep west × 7.00 m wide, 4.20 m clear | Separate slabs; side-wall joins extend 0.15 m at accepted corners. |
| West freight aperture | 5.00 m, full 4.20 m height | Two 2.50 m returns, no header. Barrier context envelope: local X ±0.17, Y 0–1.50, Z ±2.40 m. |
| East Backlog opening | 3.84 m, 3.40 m clear | Side walls 3.08 m each; upper closure 0.80 m from Y 3.40 to 4.20. Backlog ceiling is 3.40 m. |
| Dispatch opening | 2.40 m, full 4.20 m height | Local X 4.80–7.20 m at Z=-5; Dispatch annex context 9.50 × 3.50 m. |

The [recipe summary](../../reports/environment_receiving_proof/eaf5/source_shortlist_01/eaf2_recipe_mapping.md) and shell JSON list dimensions, rotations, source components, seeds and collision policy. Eighteen rect_solid pieces and one wall_with_rect_opening piece cover the 21 saved boxes. The east opening becomes one EAF2 wall with reveals and one structural owner. West freight and Dispatch are two SUPPORTED_BY_COMPOSITION full-height apertures because the EAF2 opening spec requires a header. All 19 pieces are SUPPORTED_BY_EXISTING_RECIPE; GENUINELY_MISSING_TOPOLOGY count is zero. The 0.15 m perpendicular corner joins are intentional, and no duplicate coplanar slab or wall owner is proposed. Future rendering must verify contacts.

## EAF3A source shortlist

The ignored current index has 1,011 candidates (983 KitBash, 28 FAB), fingerprint e6398707ff5a1f47d1be2855ad04986a5ba39eb8fbc04fbc107f1a01479de23d. The tracked [shortlist](../../data/environment/receiving_proof/eaf5_material_source_shortlist_01.json) has 57 unique unapproved proposals plus five EAF3 approvals. It uses promoted queries for concrete, cement/render, masonry/block, brick and tile, excluding the atlas_trim_or_object_specific_name;tileability_unverified structural warning. Metal is not a shell-palette proposal. All 12 EAF3 historical decisions were checked: four rejected and three deferred are absent from the new PBR-pass proposal; no deferred note explicitly warranted Receiving re-review.

| Role | Unapproved | Approved seed | Sheet tiles |
| --- | ---: | ---: | ---: |
| WALL_CEILING_MINERAL | 23 | 4 | 27 |
| SERVICE_FLOOR | 16 | 1 | 17 |
| APPLIED_FINISH | 10 | 1 | 11 |
| STRUCTURAL_SECONDARY | 11 | 3 | 14 |

Role overlap is intentional. All five named approvals resolve as current APPROVED, have tracked approved specs, and live source-byte strong fingerprints equal their reviewed fingerprints. The EAF3B current-approved query returns five. They enter room-role review without staging or PBR re-review. Unapproved stable IDs can enter EAF3B after human decisions. FAB names containing damaged, weathered or worn were not automatically excluded; baked history and normal convention remain review questions.

## Human package and verification

- Ignored local [review ZIP](../../reports/environment_receiving_proof/eaf5/eaf5_source_shortlist_01_review.zip) and [README](../../reports/environment_receiving_proof/eaf5/source_shortlist_01/README.md). They contain four role sheets, stable-ID batches/pages, candidate and shell manifests, reuse matrix, recipe summary and decision template. Unapproved decisions default to HOLD; choose SHORTLIST, DROP or HOLD. Approved seeds have optional role notes.
- EAF3A's basecolor thumbnail/sheet functions generated the pages. Tiles show name, compact ID, family, resolution, profile, EAF3 state and warning indicator. Representative pages were visually inspected. They do not establish normal quality, roughness, normal-Y, physical scale or room suitability.
- The builder verifies sheet IDs against each stable-ID batch, ZIP integrity and exact membership. The ZIP contains only JSON, Markdown and generated page PNG sheets, with no commercial maps or staged cache.
- EAF5 manifest tests: 3 passed. EAF3A repository suite: 36 passed. EAF3B catalog/workflow suite: 16 passed. EAF2 focused Godot: EAF2_TESTS failures=0. EAF3B synthetic/live Godot: EAF3B_QUERY_TESTS failures=0; EAF3B_LIVE_CATALOG_TESTS failures=0. The existing Windows certificate-store startup warning did not affect exits.
- No tracked Godot resource/script changed, so editor import and unrelated Godot suites were not run. Production wing/gameplay paths have no diff.

**Known uncertainty:** Basecolor cannot establish physical behavior or room-scale repetition. Several proposals have strong baked pattern/damage and may be dropped by the human. Future EAF2 contacts and room roles have not been rendered. No new material was staged, no EAF5 room scene was built, and no palette-combination or EAF4 wear pass began. Receiving C1 remains paused.
