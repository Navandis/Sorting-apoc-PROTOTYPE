# EAF3 FAB surface profile refresh validation

**Status: FAB PROFILE EXTENSION IMPLEMENTED / TECHNICALLY VERIFIED / HUMAN REVIEW PENDING**

- Date: 27 September 2026.
- Branch: codex/eaf3-fab-surface-profile-refresh. Implementation started from HEAD 0903e776604c6495b25c65a23635ed177f8c3a51; final branch HEAD is in the handoff.
- Baseline main and origin/main: 0903e776604c6495b25c65a23635ed177f8c3a51.
- Source-index schema 1; scanner revision eaf3a-2; KITBASH_PROFILE_V1 revision 1; FAB_SURFACE_PROFILE_V1 revision 1.
- The single read-only source root remained D:\AssetPipeline\KitBash_repository.

## Live FAB findings

The FAB subtree contained 28 flat asset directories, 28 JSON files and 251 local JPG textures. All 28 JSON files declared semanticTags.asset_type = surface. No local EXR, glTF or bin exports were found. Metadata advertises some 4K EXR variants, while actual local availability is 2K JPG only. The damaged concrete pkngj0 and weathered wall vi4idbm samples qualify by positive full-surface evidence. Live IDs were unique.

Recognition requires Megascans-style JSON with a stable id, maps list, asset_type = surface and coherent local PBR textures. Synthetic decal, imperfection, 3d and unknown kinds are excluded. IDs use fab:<source-id> independent of root and resolution. Resolution exports merge under one ID; duplicate IDs in distinct logical groups or at one resolution fail. FAB package compatibility is fab / source. Existing KitBash candidate fields and IDs were preserved.

Records retain metadata provenance, tileability and explicit metre-labelled scanArea as source facts. Of 28 surfaces, 27 declare tileable true and one is unknown; all 28 have parsed scan areas. Scan area is not reviewed meters_per_repeat. Unsupported local bump, cavity, gloss and specular maps are recorded but not staged. Every live normal is generically named, so all 28 carry normal_convention_unverified. EAF1 normal_y_flip remains the human review control. A synthetic GL/DX pair selects the explicitly labelled OpenGL variant; ambiguous sets remain explicit. No source maps were edited.

## Refresh and diff

| Measure | Previous | Refreshed |
| --- | ---: | ---: |
| Files | 5,856 | 8,864 |
| KitBash package/version records | 84 | 93 |
| KitBash candidates | 687 | 983 |
| FAB surface candidates | 0 | 28 |
| Total candidates | 687 | 1,011 |

The initial full scan took 13.7553 seconds; the final profile pass took 11.7674 seconds. It found 296 new KitBash candidates and 28 newly recognized FAB surfaces. Of 687 prior KitBash candidates, 683 were unchanged. Four have descriptor timestamp changes with identical recorded sizes and unchanged interpretation fields; historical descriptor byte hashes are unavailable, so byte equality is unverified. None is an approved material. Nine KitBash package/version records are new. The final unchanged second scan took 11.4562 seconds: zero new, removed or changed candidates; 1,011 unchanged candidates and 93 unchanged packages.

Family counts: concrete 330, cement_render 98, masonry_block 30, brick 39, tile 23, metal 149, wood 37, paint 8, other 92, unknown 205. FAB contributes 24 concrete and four cement_render suggestions. All 1,011 candidates have actual local 2K availability. The review ZIP contains the warning statistics and profile-separated diff summary.

## Catalog and FAB smoke

Live reconciliation found five approved, four rejected and three deferred decisions, all with matching reviewed strong fingerprints and current effective statuses. The default query returned five approvals. Restaging completed five approved specs with zero refusals; no FAB approval was created.

Technical smoke IDs: fab:pkngj0, fab:vi4idbm, fab:pjBkT0. Each resolved, staged actual local 2K basecolor, normal, roughness and AO, computed a FAB_SURFACE_PROFILE_V1 revision 1 strong fingerprint, and generated EnvironmentSurfaceMaterialSpec text. No artistic decision was made.

## Sheets and review package

Ignored source-triage sheets under reports/environment_material_catalog/fab_refresh/ use 24 candidates per page: FAB overview 2 pages, concrete 14, cement_render 5, masonry_block 2, brick 2, tile 1, metal 7 and FAB warnings 2. Every folder has page and batch manifests. These are basecolor triage, not final PBR evidence.

The ignored reports/environment_material_catalog/eaf5_source_refresh_review.zip includes scan summaries, refreshed statistics, diff summary, FAB and Receiving-relevant family sheets/manifests, FAB smoke summary and this validation record. It contains no commercial maps or staged cache. Human review of FAB recognition and refreshed triage remains pending before promotion. No EAF5 palette or Receiving C1 work was performed.

## Verification

- EAF3A repository Python suite: 31 tests passed, including eight FAB tests and a pinned KitBash quick fingerprint.
- EAF3B Python suite: 16 tests passed, including a pinned KitBash strong fingerprint.
- EAF3B synthetic Godot query: EAF3B_QUERY_TESTS failures=0.
- EAF3B live Godot catalog/spec query: EAF3B_LIVE_CATALOG_TESTS failures=0.
- Godot 4.7 editor import/parse during approved restage: exit 0; no script parse errors.
- Live full scan and unchanged second scan: succeeded with no source-boundary warnings.
- FAB staging smoke: three candidates succeeded.
- ZIP integrity and full pagination: checked by the review-package builder.

A read-only code review identified foreign-map ownership and partial-resolution staging edge cases. Regression tests reproduced both failures before the fixes; the final suites and live refresh passed. The package builder now verifies each declared sheet page.

Godot emitted its existing Windows root-certificate-store warning during headless runs; it did not affect tests or imports. Remaining uncertainties are live FAB normal-Y convention and descriptor byte equality for the four timestamp changes.
