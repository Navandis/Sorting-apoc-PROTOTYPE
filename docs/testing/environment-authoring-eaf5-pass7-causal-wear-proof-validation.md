# EAF5 Pass 7 — causal-wear proof validation

**Status: EAF5 PASS 7 IMPLEMENTED / TECHNICALLY VERIFIED / HUMAN FINAL WEAR-PROOF REVIEW PENDING.**

## Authority and selections

Authoritative checkout: D:\Godot Projects\Sorting-apoc-PROTOTYPE, branch codex/eaf5-receiving-proof. Starting HEAD: 7104085eb1b9dda0f217d0f2d3b0e153af779a8b. main/origin/main: ac12a51ce431f94c9a65a4e84edbf2f73bdf5c2c. No merge, push, promotion, production migration or Receiving C1 resume.

Accepted Pass-3A v2 composition SHA-256: 8361ed7d1d211f40c253cc7bf76821b9d141ab303b0fe7a6573208216f05339d. All 14 EAF2 pieces and geometry fingerprints match prior evidence (13 rect_solid, one wall_with_rect_opening). The inaccessible freight/elevator enclosure oddity remains deferred.

Pass 6B human decisions: data/environment/receiving_proof/decisions/eaf5_applied_finish_layouts_01_human_review_01.json. Disposition: 0 KEEP, 5 HOLD, 5 DROP, 3 CONTROL. Base applied finish = NONE / NO_FINISH. Structural secondary = NONE. Selection source: data/environment/receiving_proof/eaf5_receiving_palette_selection_01.json, linked to Pass-5 human evidence.

| Role | Palette | Wall | Floor | Ceiling |
| --- | --- | --- | --- | --- |
| PRIMARY | P01_C02 | Dirty Concrete (eaf3b_d335d94fd85c2c95c26b6b8b) | Worn Concrete Floor (eaf3b_bb32071987faae156ff2d4e8) | Shuttered Concrete Wall (eaf3b_6bcd8f817ca2993433e217cc) |
| ALTERNATE | P05_C03 | KB3D_BTL_ConcreteRoughPanelBright (eaf3b_5a797fbdc766d7e3dc475abf) | Worn Concrete Floor (eaf3b_bb32071987faae156ff2d4e8) | KB3D_AMC_ConcreteWhite (eaf3b_71edb3fc983ed8f7655d9523) |

## EAF4 authority and exact placement

EnvironmentWearCatalogQuery reported 12 APPROVED and 2 DEFERRED. All four selected IDs have APPROVED effective status, matching current/reviewed source fingerprints and loadable approved specs. WEA01 also has a current approved imperfection-mask fingerprint. EnvironmentWearOverlay uses every approved physical size, offset, opacity, albedo/normal/roughness setting and mask unchanged. No raw EAF4 source path was accessed.

The single deterministic composition is data/environment/receiving_proof/eaf5_receiving_wear_proof_01.json; SHA-256 4ef63b72be3826bd4749dadd59121dab949821921ad6d099a281e9b19fdc8179. It is identical for both palettes. Mirror U/V is false for every source.

| Instance / catalog ID | Category and approved spec | Cause / target | World root (m), normal, rotation (degrees) | Size and offset |
| --- | --- | --- | --- | --- |
| WEA01 / eaf4b_cd7701bd0cdb622c63628103 | WATER_MINERAL; res://data/environment/wear_catalog/approved_specs/eaf4b_cd7701bd0cdb622c63628103.tres; fingerprint 1e37850ee5fd45ceba6a5619e92bc6703d0eea4028f7593bd7fafda35458fe4c | service pipe penetration on ReceivingSouth; ReceivingSouth (occupied face) | [3.1, 2.08, 4.85]; [0, 0, -1]; [0, 180, 0] | [0.25, 0.5] m; 0.002 m |
| WEA02 / eaf4b_c3b63b5da3fbdda32be47bd0 | CRACK; res://data/environment/wear_catalog/approved_specs/eaf4b_c3b63b5da3fbdda32be47bd0.tres; fingerprint 8da6c186f20805a003062c4c11e364a9b842ed715d202a6701195d1f891a864e | upper south corner of east Backlog opening; ReceivingEastOpeningWall (occupied west face) | [10.35, 3.28, 1.93]; [-1, 0, 0]; [0, -90, 0] | [0.5, 0.5] m; 0.002 m |
| WEA03 / eaf4b_7efdf22029c82320d62147c7 | GRIME; res://data/environment/wear_catalog/approved_specs/eaf4b_7efdf22029c82320d62147c7.tres; fingerprint c470c5179d1907452e27be387f2ba5ba53f19aa253a7166df6fed2b0103b3342 | freight/cart turning zone just inside west aperture; Floor_ReceivingApron (top floor) | [1.4, 0, 0.15]; [0, 1, 0]; [-90, 0, 0] | [1.0, 1.0] m; 0.002 m |
| WEA04 / eaf4b_89c9cb7aa962b19eda21f278 | RUST_CORROSION; res://data/environment/wear_catalog/approved_specs/eaf4b_89c9cb7aa962b19eda21f278.tres; fingerprint 672077321a4479887bfbfed7969e846b1099c9d02fda0ae0e2eca05b8e583c21 | existing BarrierProxy_Post02 metal foot; Floor_ReceivingApron (top floor) | [0.45, 0, 0.75]; [0, 1, 0]; [-90, 0, 0] | [0.5, 0.5] m; 0.002 m |

WEA01 starts immediately beneath the two fixed dark service-pipe proxy boxes, both tagged CONTEXT_ONLY / CAUSE_PROXY. WEA02 lies on the occupied east Backlog opening wall at its upper corner and does not bridge the aperture in the final render. WEA03 is one Receiving-apron freight-path patch. WEA04 sits against existing BarrierProxy_Post02; no new rust-source proxy was added. No other mark, finish patch, EAF4_SOURCE patch, structural secondary or scatter was added.

## Fixed cameras, lights and capture evidence

EastApproachOverview is unchanged. WallCausalDetail and FreightFloorDetail were added once. The full transform and FOV are recorded for every capture:

| Camera | Origin (m) | Basis X / Y / Z | FOV |
| --- | --- | --- | --- |
| EastApproachOverview | [8.0, 2.5, 3.5] | [0.400818884372711, 0.0, -0.916157364845276] / [-0.073207788169384, 0.99680233001709, -0.0320284105837345] / [0.913227736949921, 0.0799074396491051, 0.399537175893784] | 75.0 degrees |
| WallCausalDetail | [6.5, 2.0, -1.0] | [-0.993883728981018, 0.0, 0.110431432723999] / [-0.0156927593052387, 0.989851713180542, -0.141234964132309] / [-0.109310753643513, -0.142104133963585, -0.983797550201416] | 70.0 degrees |
| FreightFloorDetail | [3.20000004768372, 2.29999995231628, 1.0] | [0.648466467857361, 0.0, -0.761243224143982] / [-0.414179891347885, 0.839031040668488, -0.352819919586182] / [0.638706743717194, 0.544083595275879, 0.544083535671234] | 65.0 degrees |

NEUTRAL_ARCHITECTURAL and RECEIVING_TARGET use the prior WorldEnvironment, exposure, filmic tonemap, light transforms, colors, energies and shadow settings. The Pass-7 test compares environment, shell and both light-rig records directly to Pass 6B. No camera or light moves between palette and wear states.

PRIMARY Neutral first produced six sanity PNGs: three cameras × OFF/ON. The gate passed: OFF hides all four overlays; ON shows exactly four; pipe and barrier remain; leak starts beneath its pipe; crack stays on the corner wall; dust is in the freight zone; rust is adjacent to Post02. No z-fighting, wrong-plane overlay or raw-source material leak was visible. WEA01 is deliberately faint at its approved defaults, and the floor still has large quiet areas.

The final manifest has 24 PNG capture records, 12 per palette. All 12 OFF/ON pairs have identical geometry fingerprints, palette, cause proxies, camera transform/FOV, lighting and wear transforms; only overlay visibility changes. Every pair has a nonempty pixel difference.

## Review package and human gate

Local folder: reports/environment_receiving_proof/eaf5/final_wear_proof_01/. It holds 24 final PNGs, two labeled contact sheets, manifest.json, summary.md, decision_template.json, plus the separate six-image sanity folder. The ZIP allowlist contains exactly 29 review members (24 captures, two sheets, three review files); CRC passed. It excludes commercial maps, cache/import files and sanity diagnostics.

ZIP: reports/environment_receiving_proof/eaf5/eaf5_final_wear_proof_01_review.zip. SHA-256: 341a6ce171483b7c6f3bb3a00fbc0b096c59d1fbf91ec49c380189862d36a4da. The reports folder and ZIP are local ignored artifacts, consistent with prior EAF5 report policy. PRIMARY and ALTERNATE decisions remain PENDING. Allowed values: ACCEPT_WEAR_PROOF, REVISE_WEAR_COMPOSITION, REJECT_FINAL_PALETTE. The last is reserved for a genuinely blocking palette problem.

## Regressions and production protection

- EAF5 Python: 47 tests passed, including currentness, 24-record parity and ZIP integrity.
- EAF5 Godot proof, capture, finish-layout and new wear suites: zero failures.
- EAF4B Python: 12 tests passed. Godot overlay, material-patch scale, human-catalog and rerun suites passed.
- EAF3B Python: 17 tests passed. Godot query and live-catalog suites: zero failures.
- Godot 4.7 headless editor import/parse exited 0; its recurring Windows certificate-store warning was non-blocking.
- Protected production paths have no diff: gameplay/logistics_wing/wing_gameplay.tscn, gameplay/logistics_wing/wing_environment.tscn, greybox/logistics_wing/wing_geometry.tscn, greybox/logistics_wing/build_wing_geometry.gd, gameplay/logistics_wing/receiving/*. EAF2 code did not change.

**EAF5 PASS 7 IMPLEMENTED / TECHNICALLY VERIFIED / HUMAN FINAL WEAR-PROOF REVIEW PENDING.**
