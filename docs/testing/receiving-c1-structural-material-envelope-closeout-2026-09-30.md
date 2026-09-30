# Receiving C1 structural/material envelope close-out — 30 September 2026

**Status: IMPLEMENTED / TECHNICALLY VERIFIED / HUMAN-PROMOTED.** This applies only to the Receiving C1 structural/material production envelope and shared EAF2 winding maintenance. Receiving Stage C1 overall remains open; current Receiving lighting is temporary and unpromoted.

## Verified source and publication baseline

- Feature branch: `codex/receiving-c1-production-envelope`.
- Verified implementation HEAD: `83853af0bea91c43045d9fe35470d170b6b92de6` (P05_C02 and Dispatch join correction).
- Preserved preceding implementation: `6aef97c428e012c31ffdedfefea6cad34b96fcf6` (shared EAF2 winding repair and C1 production shell).
- Local main and fetched origin/main before publication: `8f5988e44442ca02a4a028e3d4c48792ba90a080`; the feature is a clean descendant. Publication adds this focused documentation commit and uses a non-force fast-forward of main.
- Godot: `4.7.stable.official.5b4e0cb0f`, local executable `D:\AI Tools\Godot-4.7-Codex\Godot_v4.7-stable_win64_console.exe`.

Four pre-existing dirty paths are unrelated human/local editor work. Their content hashes match the preceding C1 task's starting hashes; none was changed, staged or committed by the implementation or this close-out:

- `data/environment/material_catalog/approved_specs/eaf3b_d335d94fd85c2c95c26b6b8b.tres`
- `data/environment/receiving_proof/eaf5_review_control.png.import`
- `data/receiving/receiving_deck_stage_b_proof.tres`
- `gameplay/logistics_wing/wing_gameplay.tscn`

## EAF2 repair and production substitution

The shared builder paired intended outward shading normals with counterclockwise emitted fronts, opposite Godot's clockwise front-face convention. `_emit_triangle()` now emits `[a,c,b]` while preserving outward normals and the UV belonging to each vertex; generator revision is 2. The owning regression derives the front convention independently from native Godot `BoxMesh`, covers plain/beveled/concealed solids and one/two-opening walls, and retains dimensions, UV, closure, reveal direction, tangent and collision checks. Historical EAF2 validation records are not rewritten as though they detected the defect.

All 14 current saved C1 meshes were regenerated through the EAF2 owner for the winding repair and verified after saving/reloading. Direct EAF2/EAF5 review consumers generate on demand. P05_C02 subsequently required regeneration of ten wall-role material bindings; all 14 geometry arrays/fingerprints remained unchanged. Ordinary back-face culling is verified; no Receiving-local double-sided/no-cull workaround exists.

`gameplay/logistics_wing/receiving/receiving_structural_shell.tscn` is a production-owned, visual-only 14-piece EAF2 shell. `wing_environment.tscn` instances it at `(-39,0,0)` with a unit root and suppresses exactly the intended 16 greybox mesh visuals. Greybox remains spatial/collision authority; structural collision is retained and EAF2 adds none. Accepted apertures and normal capsule circulation remain intact; no EAF5 runtime/proof dependency or C1A reuse exists.

The accepted Dispatch seam fix removes the redundant visual tail of `Environment/Greybox/Districts/Receiving/DispatchWest/Mesh`: its coplanar +Z cap formerly overlaid the Receiving through-wall at Z=-4.85. The production-only visual butt override ends at Z=-5.15, keeps the north extent/material and leaves full inherited collision unchanged. It does not migrate the Dispatch room or change the accepted Receiving composition.

## Human promotion and P05_C02 supersession

The human's 30 September close-out handoff explicitly accepts the repaired winding/culling result, removal of the earlier header/greybox-strip artifacts, the Dispatch overlap correction, and the P05_C02 wall at ordinary and close playable distance. Close-range inspection found no further semantic/material anomaly: the selected wall reads as credible vertical construction material.

EAF5 historically selected P01_C02 primary and P05_C03 alternate. C1 playable close-range evidence exposed P01_C02's Dirty Concrete wall as unsuitable for the approachable Receiving wall role because its scan cues read as horizontal ground/floor material. **Dirty Concrete remains an approved EAF3 source**; its catalog approval and historical EAF5 evidence are preserved. This is a room-role rejection, not a global source rejection.

The human deliberately selected P05_C02 from an existing Pass-5 KEEP_PALETTE candidate, rather than activating P05_C03. Active production palette:

| Role | Approved external spec ID | Material |
| --- | --- | --- |
| Wall / freight recess / reveals | `eaf3b_5a797fbdc766d7e3dc475abf` | KB3D_BTL_ConcreteRoughPanelBright |
| Floor, unchanged | `eaf3b_bb32071987faae156ff2d4e8` | Worn Concrete Floor |
| Ceiling, unchanged | `eaf3b_6bcd8f817ca2993433e217cc` | Shuttered Concrete Wall |

Base applied finish, structural secondary and fixed base wear preset remain **NONE**. UV remains the default environment mapping, with approved 1.5 m/repeat and recorded phase. No approved spec/catalog data was mutated by this task.

Existing ignored evidence is retained locally under `reports/logistics_wing/receiving_c1/2026-09-30/`: `winding_fix/result_record.txt`, `winding_fix/receiving_c1_winding_fix_review.zip`, `p05_c02/result_record.txt` and `p05_c02/receiving_c1_p05_c02_review.zip`. These preserve the prior technical runs and close/oblique/boundary captures. Human acceptance is recorded here from the explicit handoff; it is not inferred from automated traversal or images. No large capture package is committed or regenerated for this close-out.

## Fresh close-out verification

On current feature implementation HEAD `83853af`, all established checks exit 0. Test command: the executable above with `--headless --path . --script res://tools/asset_pipeline/tests/<identifier>.gd`, from the authoritative project root.

| Identifier / command | Result |
| --- | --- |
| `environment_substrate_authoring_tests` | PASS, failures=0; independent native front reference and current supported paths |
| `wing_gameplay_composition_tests` | PASS; saved/off-tree, direct and parent-hosted shell, normal production culling, parse/load, palette and join invariants |
| `receiving_freight_reach_tests` | PASS; real-ray exact-item TAKE/drain, maximum measured hit 3.299373865 m within 3.4 m |
| `receiving_freight_fixture_runtime_tests` | PASS |
| `receiving_deck_presenter_tests` | PASS; identity and TAKE-only preservation |
| `--headless --path . --editor --quit` | PASS, editor parse/load |
| `git diff --check` | PASS |

Fresh raw logs are ignored under `reports/logistics_wing/receiving_c1/2026-09-30/closeout/`. Inspection found no SCRIPT ERROR or failed assertion. Windows root-certificate-store errors are non-blocking; composition intentionally emits two duplicate seed-namespace rejection errors. No unrelated historical material matrix was rerun. Documentation-only changes do not alter the verified implementation.

Receiving gameplay remains preserved: fixture TAKE reach 3.4 m, loose reach 1.4 m, ordinary storage/manual reach 2.3 m, sixteen ordinary functional storage surfaces, no normal-launch synthetic batch, exact committed ItemInstance ownership, private TAKE-only presenter, barrier, SeedItems, normal Player/HUD and Gallery B rack/ladder foundations.

## Operational supersession and remaining boundaries

This record, [CURRENT_STATE](../CURRENT_STATE.md) and [CODEX_BOOTSTRAP](../CODEX_BOOTSTRAP.md) explicitly supersede the current masters' historical EAF5 production-default/alternate and next-C1 statements for this bounded slice. For example, VDD v0.8 §34 says “Use PRIMARY P01_C02 as Receiving's default production target” and records P05_C03 as fallback. That wording now describes the historical EAF5 decision; active production is P05_C02. GDD v0.11 / Findings v0.11 / VDD v0.8 retain their 29 September edition context. No DOCX refresh, version bump or independent readable-extract edit is part of this close-out.

Current Receiving lighting is temporary legacy/gameplay-test lighting and is **not promoted**. East-threshold sill/floor striping remains unchanged known visual debt. The roofed/inaccessible freight-enclosure oddity remains deferred. This close-out does not complete lighting, furniture, infrastructure/services, wear, Stage C queue/theatre or Dispatch production-room work; C1A remains parked.

**Next: human provisions additional light-fixture assets into Godot, then Receiving lighting design + fixture-layout pass.** Future sessions must inspect locally provisioned assets before beginning that separate handoff.
