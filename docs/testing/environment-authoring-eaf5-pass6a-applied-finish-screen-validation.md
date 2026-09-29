# EAF5 Pass 6A — Receiving applied-finish screening validation

**Status: EAF5 PASS 6A — HUMAN APPLIED-FINISH SCREEN REVIEW COMPLETE.** EAF5 overall remains in progress.

## Authority and scope

Branch: `codex/eaf5-receiving-proof`. Pass 6A started from HEAD `73f0481e3a48f4ce0d019a086b13166dc1e758d4`. Accepted shell composition: `data/environment/receiving_proof/eaf5_receiving_proof_composition_v2.json`, SHA-256 `8361ed7d1d211f40c253cc7bf76821b9d141ab303b0fe7a6573208216f05339d`. All 14 EAF2 geometry fingerprints match the accepted shell. The known freight/elevator enclosure oddity remains a non-blocking deferred follow-up.

Pass-5 human decisions are recorded in `data/environment/receiving_proof/decisions/eaf5_structural_palettes_01_human_review_01.json`, against the preserved `eaf5_structural_palette_review_01.zip` SHA-256 `97034dbad91328f1d53531e3cf2b1816ac63ccf33d14a8e033495aaec61ba748`. Counts: 6 KEEP_PALETTE, 9 HOLD_PALETTE and 20 DROP_PALETTE. The advancing structural finalists, in deterministic review order rather than rank order, are S01=P01_C02, S02=P05_C02, S03=P04_C02, S04=P05_C03, S05=P01_C01 and S06=P01_C05. Only these six are screened.

The five current approved wall finish IDs are A01 `eaf3b_7b12b8b3a2e05c502801d22f` (KB3D_RFS_ConcretePlasterWhite), A02 `eaf3b_8d5f0cf5add98dfe0a58f18a` (KB3D_AFT_PlasterA), A03 `eaf3b_9297ffec71774317b0627951` (Painted Concrete Wall), A04 `eaf3b_b395eb3943870fbfd262e8ce` (KB3D_ECP_StuccoWhite) and A05 `eaf3b_c29826cd934f1534ecfb48c5` (KB3D_NNY_ConcretePlasterWhite). All retain current approved PBR settings. A02 alone retains a triplanar approved catalog spec and uses a transient UV review clone with the same textures, source fingerprint and parameters. One finish source produces six transient-UV configurations (24 captures); no approved spec or catalog record was changed. All effective review mappings are UV.

## Fixed region and capture matrix

`FINISH_SOUTH_WALL_FIELD` is the existing `ReceivingSouth/GeneratedMesh` only. A01–A05 are material overrides built through the existing `EnvironmentMaterialBuilder` from current approved EAF3 specs. No new finish geometry, material patch, wear overlay, or raw texture definition was created. A00 NO_FINISH leaves ReceivingSouth on the structural wall material. The other wall pieces, both floors, both ceilings and review-only context retain their structural/control materials. Structural secondary and EAF4 wear remain OFF.

The existing WallDominant view cropped part of ReceivingSouth, so the proof has one fixed `FinishField` camera. It is centered at local `(5.25, 2.1, 0.0)`, aimed at `(5.25, 2.1, 5.0)`, with 65° FOV. This transform is identical for all 36 configurations; existing camera transforms, lighting and WorldEnvironment are unchanged.

The 36 configuration IDs are:

- S01_A00, S01_A01, S01_A02, S01_A03, S01_A04, S01_A05
- S02_A00, S02_A01, S02_A02, S02_A03, S02_A04, S02_A05
- S03_A00, S03_A01, S03_A02, S03_A03, S03_A04, S03_A05
- S04_A00, S04_A01, S04_A02, S04_A03, S04_A04, S04_A05
- S05_A00, S05_A01, S05_A02, S05_A03, S05_A04, S05_A05
- S06_A00, S06_A01, S06_A02, S06_A03, S06_A04, S06_A05

Each configuration has Neutral/EastApproachOverview, Receiving/EastApproachOverview, Neutral/FinishField and Receiving/FinishField captures: 144 full-resolution PNGs. Six A00 controls and 30 finish variants are present. No automated artistic ranking or winner selection was made.

## Sanity gate

S01_A00, S01_A02, S02_A03 and S04_A04 were rendered first, four views each. The 16 images show the no-finish structural control, A02 transient UV, painted finish and a light finish. Visual inspection showed the fixed full-wall field and no material leak to other surfaces or context. Godot tests verified that only ReceivingSouth changes material and that the A02 review material uses UV while its approved spec stays triplanar. Both S01_A00 overall images were pixel identical to the Pass-5 P01_C02 structural captures. Sanity metadata matched all 14 piece fingerprints, review context, environment, existing overall camera and light settings. The gate passed before full capture.

## Review package

The local review folder is `reports/environment_receiving_proof/eaf5/applied_finish_screen_01`. It contains 144 full-resolution captures, six one-finalist contact sheets, manifest, summary and a fresh decision template with six `CONTROL_NO_FINISH` records and 30 `PENDING` finish variants. The sanity subfolder holds 16 gate images and is excluded from the shareable ZIP.

Shareable ZIP: `reports/environment_receiving_proof/eaf5/eaf5_applied_finish_screen_01_review.zip`. SHA-256: `e8bfa330e836687b2fe869a938bf7ed3181ca1a0f076d0d531a32293e6bda66b`. ZIP CRC and exact allowlist passed: 144 captures, six contact sheets, `manifest.json`, `summary.md`, and `decision_template.json`. No commercial texture maps, staging cache, or import sidecars are included.

## Verification and protection

- EAF5 Python suite: 41 passed, including A00 pixel equality and package integrity.
- EAF3B Python material catalog suite: 17 passed.
- Godot EAF5 proof/capture and EAF3B query/live catalog suites: zero failures each.
- Godot 4.7 headless editor import/parse: exit 0. The recurring Windows certificate-store warning did not fail the run.
- Accepted composition and Pass-5 ZIP hashes remain unchanged. No protected production wing path has a diff. EAF2 and EAF4 code was not changed.
- Review artifacts are local ignored files. Source, tests, decisions and validation are tracked on `codex/eaf5-receiving-proof`; no merge or push.

## Human review closure

The human Pass 6A disposition is recorded in `data/environment/receiving_proof/decisions/eaf5_applied_finish_screen_01_human_review_01.json`. All six A00 controls remain `CONTROL_NO_FINISH`. The 30 finish variants resolve to **4 KEEP_FINISH_VARIANT, 7 HOLD_FINISH_VARIANT and 19 DROP_FINISH_VARIANT**. The four kept source combinations are S01_A01, S05_A04, S06_A01 and S06_A05. The two small-patch-only held probes are S01_A02 and S01_A03.

Broad finish fields were rejected for S02/S03/S04 because the structural palettes already carry pronounced seam/panel wall language. A02/A03 full-wall use was held or rejected because source repetition dominates. The selected S01/S05/S06 variants proceed only to bounded Layer-2 layout testing. NO_FINISH remains fully competitive and is a valid final direction; no applied finish is mandatory. These room-level decisions do not modify EAF3 approvals. EAF4 wear, structural secondary, production Receiving and Receiving C1 remain untouched.

**EAF5 PASS 6A — HUMAN APPLIED-FINISH SCREEN REVIEW COMPLETE.**
