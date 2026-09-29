# EAF5 Pass 7A — Receiving wear-calibration validation

**Status: EAF5 PASS 7A IMPLEMENTED / TECHNICALLY VERIFIED / HUMAN WEAR-CALIBRATION REVIEW PENDING.**

## Authority

Checkout: D:\Godot Projects\Sorting-apoc-PROTOTYPE. Branch: codex/eaf5-receiving-proof. Starting HEAD: ee5c93783b4ca9be88745b9b2712e83335ccd547. main and origin/main: ac12a51ce431f94c9a65a4e84edbf2f73bdf5c2c. Pass 7 human disposition: PRIMARY = REVISE_WEAR_COMPOSITION; ALTERNATE = REVISE_WEAR_COMPOSITION. Its architecture and causal placements are accepted.

The accepted Pass-3A v2 shell, geometry, materials, UVs, NO_FINISH base, no structural secondary, context, cause proxies, lighting, and camera transforms are unchanged. PRIMARY P01_C02 and ALTERNATE P05_C03 are the only palettes. The freight/elevator oddity remains deferred. Receiving Stage C1 remains paused.

## Sources and room-instance parameters

Pass 7A uses exactly three approved EAF4 sources. WEA02 crack is disabled for the maintained apron. Its catalog status and Pass-7 record remain untouched. The local source manifest is data/environment/receiving_proof/eaf5_receiving_wear_calibration_01.json. It copies the three Pass-7 placements exactly.

| Instance | Approved EAF4 catalog ID | Semantic category | Variant 0 catalog default (opacity / albedo) | Variant 1 opacity only | Variant 2 opacity + albedo |
| --- | --- | --- | --- | --- | --- |
| WEA01 leak | eaf4b_cd7701bd0cdb622c63628103 | WATER_MINERAL | L0 1.00 / 0.45 | L1 0.65 / 0.45 | L2 0.65 / 0.30 |
| WEA03 freight dust | eaf4b_7efdf22029c82320d62147c7 | GRIME | D0 1.00 / 0.40 | D1 0.65 / 0.40 | D2 0.65 / 0.25 |
| WEA04 rust debris | eaf4b_89c9cb7aa962b19eda21f278 | RUST_CORROSION | R0 1.00 / 0.75 | R1 0.60 / 0.75 | R2 0.60 / 0.40 |

Each placed overlay loads the approved spec, duplicates it deeply, and binds the duplicate to EnvironmentWearOverlay. Every capture resets duplicates from approved defaults before applying the active variant. Only opacity_multiplier and albedo_strength are changed. Physical size, surface offset, normal strength and flip, roughness strength, imperfection settings, position, orientation, rotation and mirror flags are preserved. The Pass-7 preflight requires APPROVED effective status, current/reviewed source fingerprints, current imperfection fingerprint where applicable, and a valid approved spec. The calibration preflight requires the three instance records to equal the corresponding Pass-7 records.

## Capture matrix and review package

PRIMARY P01_C02: WEAR_OFF on WallCausalDetail and FreightFloorDetail under both NEUTRAL_ARCHITECTURAL and RECEIVING_TARGET (4 PNGs); L0/L1/L2 on WallCausalDetail and D0/D1/D2/R0/R1/R2 on FreightFloorDetail under both lights (18 PNGs). Total 22.

ALTERNATE P05_C03: same two-camera, two-light OFF controls (4 PNGs); only L2, D2, R2 with their relevant cameras and both lights (6 PNGs). Total 10. All 32 PNGs show at most one source at a time and contain no crack. The alternate contact sheet includes both camera-specific OFF controls.

Review folder: reports/environment_receiving_proof/eaf5/wear_calibration_01/. It contains 32 capture PNGs, four labeled contact sheets, manifest.json, summary.md and decision_template.json. The ZIP allowlist contains exactly these 39 files; CRC and membership passed. No commercial maps, cache files or import sidecars are included.

ZIP: reports/environment_receiving_proof/eaf5/eaf5_wear_calibration_01_review.zip.

SHA-256: a8fba24901b7ccd94a68178294c08c7fa3e78c7ce05dc8518a72652a9d39efd2.

Decision template: WEA01, WEA03 and WEA04 each have selected_variant = PENDING and alternate_transfer = PENDING. Allowed final variant values are 0, 1, 2, DISABLED; allowed transfer values are ACCEPTABLE, NEEDS_SEPARATE_CALIBRATION, NOT_APPLICABLE. No final variant or combined wear state is selected.

## Technical verification

- EAF5 Python suite: 50 tests passed, including Pass 7A source and 32-capture contract.
- EAF4B Python suite: 12 tests passed.
- EAF3B material-catalog Python suite: 17 tests passed.
- EAF5 Godot proof, capture, finish-layout, Pass-7 wear, and Pass-7A calibration suites: exit 0 and zero failures.
- EAF4B Godot overlay, material-patch scale, human catalog and rerun suites: exit 0.
- EAF3B Godot catalog query and live-catalog suites: exit 0 and zero failures.
- Godot 4.7 headless editor import/parse: exit 0. The recurring Windows certificate-store warning is non-blocking.
- Review builder validated the source, 32-record split, variant values, visibility, camera/light/palette invariants, PNG integrity, and ZIP membership.
- Git diff checks confirm EAF4 catalog/spec paths and protected production paths are unchanged.

**EAF5 PASS 7A IMPLEMENTED / TECHNICALLY VERIFIED / HUMAN WEAR-CALIBRATION REVIEW PENDING.**