# EAF5 promoted-system reuse matrix

| EAF5 capability | Promoted owner | Exact reusable implementation | EAF5 use | New EAF5 code? |
| --- | --- | --- | --- | --- |
| PBR material contract and construction | EAF1 | `EnvironmentSurfaceMaterialSpec`, `EnvironmentMaterialBuilder.build` | Bind approved specs to EAF2 pieces with metre scale and normal-Y choice | No |
| Fixed Neutral/Receiving material evidence | EAF1 | `environment_material_lookdev.gd` review-set injection and light modes; `environment_material_lookdev_capture.gd` fixed cameras and manifest | Later PBR review of newly staged sources | No |
| Exact generated walls, slabs, reveals and collision | EAF2 | `EnvironmentSubstratePieceSpec`, `EnvironmentSubstrateBuilder`, `EnvironmentSubstratePiece`, `EnvironmentSubstrateRecipeRegistry` | Compose 19 mapped Receiving pieces at unit root scale; use `rect_solid` and `wall_with_rect_opening` | No |
| Recipe seeds and fingerprints | EAF2 | `data/environment/substrate/seed/`; `environment_substrate_builder.gd` fingerprint/validation; substrate review capture | Seed future pieces and verify shell geometry | No |
| Guarded source discovery and structural eligibility | EAF3A | `source_index.load_index`, `query_index.query`, stable-ID `batch_manifest`/`select_batch` | Filter five mineral source families and exclude warned trim/object atlases | No |
| Source contact sheets | EAF3A | `build_triage_sheets.build_sheets`, guarded thumbnail cache | Four role batches with source facts and basecolor previews | Small owner-system extension: optional role label and EAF3 state/profile tile annotation. No image loading fork. |
| Selective PBR staging and review | EAF3B | `material_catalog.catalog.make_batch`, `workflow.prepare`, EAF1 batch capture, `catalog.reconcile` | Next pass stages only human SHORTLIST IDs | No |
| Existing approved specs and freshness | EAF3B | `catalog.query`, `fingerprint_candidate`, `approved_specs`, `EnvironmentMaterialCatalogQuery` | Five current approvals enter role review without re-staging | No |
| Localized causal wear | EAF4 | `EnvironmentWearCatalogQuery`, `EnvironmentWearOverlaySpec`/`EnvironmentWearOverlay`, `EnvironmentMaterialPatch`, wear catalog workflow and fixed review scene | Later room pass selects approved wear by cause and surface capability | No in pass 1 |
| Receiving-specific composition and review package | EAF5 | Source manifest, role assignments, thin EAF3A orchestration | Preserve authority dimensions and prepare human shortlist | Yes: room-specific data and package assembly only |

No new EAF2 recipe is required for the saved Receiving shell. The two full-height apertures are composed from separate `rect_solid` wall segments; the east opening and 0.8 m header fit `wall_with_rect_opening` as one owner. The saved 0.15 m corner join extensions are intentional authored joins. No mesh-generation rule moves into EAF5.
