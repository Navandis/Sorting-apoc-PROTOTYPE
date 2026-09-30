# Sorting Apocalypse documentation index

## Read first

[AI working guidelines](AI_WORKING_GUIDELINES.md) define the proportionate execution and evidence standard. [Current project state](CURRENT_STATE.md) records promoted evidence, current debt and gate order. [Codex bootstrap](CODEX_BOOTSTRAP.md) is the concise entry point for a new architect or local Codex session.

| Current authority | Editable document | Derived readable text |
| --- | --- | --- |
| Overall game design | [GDD v0.11](Sorting_Apocalypse_Preliminary_GDD_v0.11.docx) | [Text and tables](readable/Sorting_Apocalypse_Preliminary_GDD_v0.11.md) |
| Visual, world and spatial direction | [VDD v0.8](Sorting_Apocalypse_Visual_Design_Direction_v0.8.docx) | [Text, tables and images](readable/Sorting_Apocalypse_Visual_Design_Direction_v0.8.md) |
| Implementation and human evidence | [Findings v0.11](Sorting_Apocalypse_Prototype_Findings_v0.11.docx) | [Text and tables](readable/Sorting_Apocalypse_Prototype_Findings_v0.11.md) |

The Markdown editions are generated extracts of the listed DOCX masters. Edit the master and regenerate its extract; do not maintain an independent Markdown authority. Older DOCX editions remain historical records.

## Current playable and spatial baseline

The normal development entry is `res://gameplay/logistics_wing/wing_gameplay.tscn` through UID `uid://bljf1nlhijej`. It reuses the accepted whole-wing geometry and contains the normal player and HUD, sixteen ordinary functional storage surfaces, the saved editor-authored palette, and the private deterministic seeded TAKE-only Receiving deck presenter. Normal launch does not synthesize a Receiving batch. `main.tscn` remains the legacy mechanics fixture. `res://greybox/logistics_wing/wing_review.tscn` remains the neutral spatial review entry.

The accepted in-engine builder, saved scene and [overview](testing/evidence/greybox-accepted-2026-09-17/overview_debug_topdown.png) govern working dimensions. The retained Topology V3 and Structural Schematic V2 images explain design history and relationships but do not override the accepted geometry.

## Current records

- [Receiving C1 structural/material envelope close-out](testing/receiving-c1-structural-material-envelope-closeout-2026-09-30.md): implemented, technically verified and human-promoted bounded slice; EAF2 winding repair, accepted Dispatch join and active P05_C02. Current Receiving lighting is temporary/unpromoted; C1 overall remains open, with light-fixture asset provisioning then lighting design + fixture layout next.

- [Continuing gameplay foundation design](superpowers/specs/2026-09-18-wing-gameplay-foundation-design.md): approved composition and editor-authored seed contract.
- [Continuing gameplay and F6 acceptance](testing/wing-gameplay-foundation-acceptance-2026-09-18.md): developer promotion and its limits.
- [Default-entry close-out](testing/wing-gameplay-default-entry-closeout-validation.md): saved-scene authority, launch promotion and guarded synchronization.
- [Locker and Fuel maintenance](testing/locker-fuel-maintenance-validation.md): promoted locker containment, Fuel reconciliation and Fuel eligibility.
- [Expanded item palette](testing/expanded-item-palette-validation.md): promoted editor-authored eligible-type coverage and accepted manual arrangement.
- [Shelf and ceiling ergonomics](testing/shelf-ceiling-ergonomics-comparison.md): completed ground-access experiment, retained review scene and bounded fixed-ladder status.
- [Review-scene supply reuse](testing/review-scene-supply-reuse-validation.md): promoted reuse of the authored wing palette in the retained shelf-ergonomics review.
- [ModularRack authoring](testing/modular-rack-authoring-validation.md): promoted shelf-empty reusable scaffold, scene-local editable levels and Rack02 calibration.
- [Storage unit orientation and zoning](testing/storage-unit-orientation-zoning-validation.md): promoted unit-owned Front semantics and authored-Front zoning view without physical-cell migration.
- [Canonical item storage pose](testing/canonical-item-storage-pose-validation.md): promoted canonical +Z Front, separate packing turn and the full 40-eligible-item human reconciliation.
- [Fixed-ladder proof validation](testing/fixed-ladder-proof-validation.md): technically verified and human-promoted standalone fixed ladders for selected taller storage installations.
- [Wing Modular Rack + Ladder integration](testing/wing-modular-rack-ladder-integration-validation.md): technically verified and human-promoted temporary Gallery B storage-destination baseline for Receiving Stage B.
- [Receiving A/B/C geometry comparison](testing/receiving-abc-geometry-comparison.md): completed isolated precursor; useful review history, with no case promoted as final production geometry.
- [Receiving real-item physics pile proof](testing/receiving-real-item-physics-pile-proof.md): completed and technically verified research; human review rejected irregular frozen piles for production.
- [Receiving deterministic deck presenter](testing/receiving-deterministic-deck-presenter-validation.md): implemented, technically verified and human-promoted in its tested Stage B scope; includes the original proof, spatial correction and accepted current baseline.
- [Receiving and Elevator design](superpowers/specs/2026-09-12-receiving-elevator-mvp-design.md): historical subsystem contract; the focused deterministic-deck record now governs the promoted Stage B presenter baseline.
- [EAF1 Material + Lighting Lookdev Foundation](testing/environment-authoring-eaf1-lookdev-validation.md): human-promoted material-review system and process; samples are workflow fixtures.
- [EAF2 Structural Substrate Authoring](testing/environment-authoring-eaf2-substrate-validation.md): human-promoted generated structural authoring rules, reusable seeds and incremental extension workflow.
- [EAF3A Repository Indexing + Source Triage Foundation](testing/environment-authoring-eaf3a-repository-index-validation.md): human-promoted single-root source discovery, mixed-content classification, stable source indexing and triage sheets; EAF3A itself makes no individual material approval decisions.
- [EAF3B Selective Staging + Curated Catalog](testing/environment-authoring-eaf3b-curated-catalog-validation.md): human-promoted selective PBR staging, deterministic EAF1 review, human decisions, approved-spec restaging and query; five approved seed materials.
- [EAF3 FAB profile refresh](testing/environment-authoring-eaf3-fab-profile-refresh-validation.md): human-promoted maintenance extension of the same single EAF3 source root; `KITBASH_PROFILE_V1` and `FAB_SURFACE_PROFILE_V1` revision 1 under scanner `eaf3a-2`. The corrected EAF5 structural-source sheets exclude warned trim/object-specific candidates by default, while raw discovery retains them. The original five approved EAF3 materials were unchanged by that maintenance; EAF5 later reviewed 30 current approved materials and selected a Receiving palette.
- [EAF4B Wear Overlay, Review, and Curated Catalog](testing/environment-authoring-eaf4b-overlay-catalog-validation.md): human-promoted causal wear workflow; 12 current approved sources and two deferred sources.
- [EAF4B diagnostic rerun](testing/environment-authoring-eaf4b-human-review-rerun-validation.md): historical review calibration and preserved original/rerun packages.
- [EAF4A Wear Source Index + Triage Catalog Foundation](testing/environment-authoring-eaf4a-wear-source-index-validation.md): human-promoted guarded source discovery and triage; records City/Unreal limits and EAF4B shortlist guidance.

The fixed-ladder proof, temporary Gallery B wing integration, deterministic seeded TAKE-only Receiving deck presenter, functional freight fixtures, EAF1, EAF2, EAF3A, EAF3B, EAF3 overall, and EAF4A are human-promoted in their recorded scopes. Receiving Stage A remains upstream batch/lifecycle authority: Expedition owns the exact batch contents while Receiving presents that batch without filler, omissions, replacements or loot bias. The presenter's promoted baseline and current reach values are in [Current project state](CURRENT_STATE.md). It uses private surfaces, fills local `+Z` FRONT toward local `-Z` REAR, and exposes no PUT, zoning, labels, manual placement, visible grids, F6 Receiving surface, or ordinary storage registration. The irregular frozen-pile presenter remains human-rejected. The three-master documentation refresh is complete. Receiving C1 structural/material envelope is human-promoted with P05_C02; C1 overall remains open. Next is light-fixture asset provisioning, then Receiving lighting design + fixture layout. Its C1A shell remains parked as unpromoted research. EAF1 provides a self-contained Neutral/Receiving Target material comparison scene and deterministic capture evidence, with 1K samples limited to workflow proof rather than final palette approval. **EAF4B, EAF4 overall, and EAF5 are HUMAN-PROMOTED; EAF5 is CLOSED.** The EAF3 approved vocabulary is intentionally compact and can grow through its promoted triage → staging → EAF1 review → human decision → catalog workflow without reopening EAF3. EAF3A scans only the configured machine-local root, currently `D:\AssetPipeline\KitBash_repository`, with repository-relative source IDs/paths and no alternate-root discovery; it does not approve materials. EAF2 is closed by its non-exhaustive authoring grammar, useful seed collection, deterministic validation, and two-opening incremental extension proof. Future missing shapes follow that promoted process without reopening EAF2; see [Current project state](CURRENT_STATE.md). Ladder promotion still does not approve universal coverage, general climbing/jumping, movable/sliding ladders or shelf-top traversal.

The current masters are GDD v0.11, Prototype Findings v0.11 and VDD v0.8. Older editions remain historical. See the [documentation reconciliation validation](testing/documentation-reconciliation-2026-09-30.md), [EAF5 promotion validation](testing/environment-authoring-eaf5-promotion-validation.md) and [C1 handoff recipe](../data/environment/receiving_proof/eaf5_c1_handoff.json).

The [30 September C1 close-out](testing/receiving-c1-structural-material-envelope-closeout-2026-09-30.md), CURRENT_STATE and CODEX_BOOTSTRAP supersede the masters' historical EAF5 P01_C02 default / P05_C03 alternate and next-C1 statements for current production. P05_C02 is active; Dirty Concrete remains approved in the EAF3 catalog but is rejected for the approachable Receiving wall role. No DOCX master or readable extract refresh is part of this close-out. EAF2 winding maintenance is technically verified and human-promoted; east-threshold striping and the roofed freight-enclosure oddity remain known debt.

Historical plans, validation reports and earlier master editions retain their original dates and evidence states. Later acceptance records and current authorities supersede stale pending conclusions without rewriting history.
