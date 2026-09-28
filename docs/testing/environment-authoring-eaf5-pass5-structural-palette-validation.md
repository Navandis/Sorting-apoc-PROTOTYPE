# EAF5 Pass 5 — Receiving structural palette validation

**Status: EAF5 PASS 5 IMPLEMENTED / TECHNICALLY VERIFIED / HUMAN STRUCTURAL-PALETTE REVIEW PENDING.** EAF5 overall remains in progress.

## Authority and scope

Branch: `codex/eaf5-receiving-proof`. Pass 5 started from HEAD `4c09a3fb0b6955ca7b9a29b777e9fb29b62b48e2`. Accepted shell composition: `data/environment/receiving_proof/eaf5_receiving_proof_composition_v2.json`, SHA-256 `8361ed7d1d211f40c253cc7bf76821b9d141ab303b0fe7a6573208216f05339d`. The 14 EAF2 piece geometry fingerprints match the accepted shell. The known freight/elevator enclosure oddity remains a non-blocking deferred follow-up.

Pass-4 human decisions are recorded in `data/environment/receiving_proof/decisions/eaf5_wall_floor_pairs_01_human_review_01.json`, against `eaf5_wall_floor_pair_review_01.zip` SHA-256 `fa32ebd095eddf14a3218740b089f61b8c83db8ae73a3b266e1fe1194e3f6353`. Counts: 7 KEEP_PAIR, 2 HOLD_PAIR, 6 DROP_PAIR. The advancing pairs, in deterministic review order only, are W01_F02, W01_F03, W02_F02, W03_F01, W03_F02, W04_F01 and W04_F02. HOLD and DROP pairs were not expanded.

The five ceiling survivors are C01 `eaf3b_2dc87647fd382ad8287a0280`, C02 `eaf3b_6bcd8f817ca2993433e217cc`, C03 `eaf3b_71edb3fc983ed8f7655d9523`, C04 `eaf3b_d335d94fd85c2c95c26b6b8b` and C05 `eaf3b_800060297ab83f24c0fb0d75`. All are current APPROVED UV materials with valid approved specs. No HOLD ceiling was added. No transient mapping override or parameter tuning was used.

## Matrix and sanity gate

Exactly 35 palette IDs are generated in pair-major order: `P01_C01` through `P07_C05`. The palette manifest lists every ID. Four combinations intentionally share one wall and ceiling material: P01_C04, P02_C04, P06_C02 and P07_C02. They are flagged for human review; they are not ranked or excluded.

The sanity gate captured P01_C03, P04_C01 and P07_C02, four fixed views each. All 12 full-resolution images were checked for the intended wall, floor and ceiling application, neutral review context, plausible same-material application, and absence of a new UV phase issue. Metadata matched the accepted shell and all 14 geometry fingerprints, fixed environment, cameras and light settings. The images were nonblank at 1920×1080. The gate passed before full capture.

Full capture uses Neutral/EastApproachOverview, Receiving/EastApproachOverview, Neutral/CeilingRead and Receiving/CeilingRead per palette: 140 PNGs. Approved wall, floor and ceiling PBR parameters and UV mapping remain unchanged. Main walls, freight recess, opening-reveal approval and the east-opening composite-mesh limitation follow Pass 3/4 rules. Both floor pieces and both ceiling pieces receive their selected role material. Review-only context remains neutral. Structural secondary, applied finish and EAF4 wear remain OFF.

## Review package

The local review folder is `reports/environment_receiving_proof/eaf5/structural_palettes_01`. It contains 140 full-resolution palette captures, seven five-palette contact sheets, manifest, summary and a fresh 35-entry all-PENDING decision template. The sanity subfolder holds 12 gate images and is excluded from the shareable ZIP.

Shareable ZIP: `reports/environment_receiving_proof/eaf5/eaf5_structural_palette_review_01.zip`.

ZIP SHA-256: `97034dbad91328f1d53531e3cf2b1816ac63ccf33d14a8e033495aaec61ba748`.

ZIP integrity and allowlist: `passed: ZIP CRC test and exact allowlist verified`. The allowlist includes only 140 PNGs, seven contact sheets, `manifest.json`, `summary.md` and `decision_template.json`; no commercial texture maps, staging cache or import sidecars.

## Verification

- EAF5 Python suite: `38 passed`.
- EAF3B Python material catalog suite: 17 passed.
- Godot EAF5 proof/capture and EAF3B query/live catalog suites: zero failures each before full capture; final rerun `zero failures each`.
- Godot 4.7 editor import/parse: `exit 0; recurring Windows certificate-store warning did not fail the run`.
- Accepted composition and Pass-4 ZIP hashes matched the expected values before capture. Production wing paths had no diff before capture; final check `no protected production path diff`.
- Pass-5 review remains a human decision. Do not select finalists or add later layers in this pass.

**EAF5 PASS 5 READY — HUMAN STRUCTURAL-PALETTE REVIEW PENDING.**
