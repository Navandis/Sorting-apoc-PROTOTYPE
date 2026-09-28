# EAF5 Pass 4 — Receiving wall/floor pair review validation

**Status: EAF5 PASS 4 IMPLEMENTED / TECHNICALLY VERIFIED / HUMAN WALL-FLOOR PAIR REVIEW PENDING.** EAF5 overall remains in progress.

## Authority

The room-specific decision record is data/environment/receiving_proof/decisions/eaf5_role_isolation_02_human_review_01.json. It contains all 33 decisions: WALL_PRIMARY 5 KEEP / 7 HOLD / 2 DROP_FOR_RECEIVING; FLOOR_PRIMARY 3 / 3 / 2; CEILING_PRIMARY 5 / 3 / 3. Empty individual notes mean the available human handoff gave no specific rationale; none was inferred. EAF3 catalog approvals remain unchanged.

Pass-3B role ZIP hashes remain unchanged: wall 2fbb4a646b2e48c742a901c0e650178ebb5e89e2c39bd3c964fcc32566946dcb; floor 75ccd8600d1f15e9030b87284bbda0bae1f3f5c362dfe35be02d3c0f80df538e; ceiling a666f59876a6b35112803f9c8a30995aac06cc9da81f4fe3f1a42c53c5e57c37. Accepted composition SHA-256 remains 8361ed7d1d211f40c253cc7bf76821b9d141ab303b0fe7a6573208216f05339d. All 14 EAF2 geometry fingerprints match the accepted shell.

Wall order: W01 Dirty Concrete (eaf3b_d335d94fd85c2c95c26b6b8b); W02 KB3D_BTL_ConcreteFloorPanelsRoughA (eaf3b_20c61bd1c85420be2f71a090); W03 KB3D_BTL_ConcreteRoughPanelBright (eaf3b_5a797fbdc766d7e3dc475abf); W04 Shuttered Concrete Wall (eaf3b_6bcd8f817ca2993433e217cc); W05 KB3D_BRK_ConcreteWarmGrey (eaf3b_2dc87647fd382ad8287a0280).

Floor order: F01 Concrete Floor (eaf3b_f10d218d1e8b7f09b7c2689c); F02 Worn Concrete Floor (eaf3b_bb32071987faae156ff2d4e8); F03 Concrete Floor (eaf3b_20e1005f19f39efb82251916).

The ceiling KEEP candidates retained for the next pass are eaf3b_2dc87647fd382ad8287a0280, eaf3b_6bcd8f817ca2993433e217cc, eaf3b_71edb3fc983ed8f7655d9523, eaf3b_d335d94fd85c2c95c26b6b8b and eaf3b_800060297ab83f24c0fb0d75. None is applied in Pass 4.

## Pair matrix and sanity gate

The 15 pair IDs are W01_F01, W01_F02, W01_F03, W02_F01, W02_F02, W02_F03, W03_F01, W03_F02, W03_F03, W04_F01, W04_F02, W04_F03, W05_F01, W05_F02 and W05_F03. No same-ID wall/floor collision exists.

Sanity capture covered W01_F01, W03_F02 and W05_F03: 12 images. Visual inspection showed intended wall/floor application, neutral ceiling/context and no unexpected UV phase or geometry artifact. Metadata matched the previous shell, context, environment, fixed cameras and light rigs, and all 14 geometry fingerprints. The known freight/elevator oddity remains a non-blocking deferred follow-up.

Full capture generated 60 PNGs: Neutral/EastApproachOverview, Receiving/EastApproachOverview, Neutral/WallDominant and Neutral/FloorRead per pair. Approved UV mapping and PBR settings are unchanged. Main walls, freight recess, apron and freight floor follow Pass-3 role rules. The east one-mesh opening remains controlled when opening_reveal approval is absent. Ceiling and context remain on EAF5 review control. EAF4 wear, applied finish and structural secondary are off.

## Package

The local review folder is reports/environment_receiving_proof/eaf5/wall_floor_pairs_01. It has the 60 full-resolution captures, three five-pair contact sheets, manifest, summary and a fresh all-PENDING pair decision template. The sanity subfolder holds the 12 gate images.

The shareable local ZIP is reports/environment_receiving_proof/eaf5/eaf5_wall_floor_pair_review_01.zip. SHA-256: fa32ebd095eddf14a3218740b089f61b8c83db8ae73a3b266e1fe1194e3f6353. ZIP integrity passed. Its allowlist is 60 PNGs, three sheets, manifest.json, summary.md and decision_template.json, with no commercial maps, caches or import sidecars. All 15 decisions are PENDING; approximately 4–8 KEEP_PAIR choices is a soft target, not a quota.

## Verification

- EAF5 Python suite: 36 passed.
- EAF3B material catalog Python suite: 17 passed.
- Godot EAF5 proof/capture and EAF3B query/live catalog suites: zero failures each.
- Godot 4.7 headless editor import/parse: exit 0. The recurring certificate-store warning did not fail the runs.
- Protected production wing paths, EAF3 catalog and accepted shell composition are unchanged.
- Captures and ZIP are local ignored review artifacts; source, tests and this validation are tracked on codex/eaf5-receiving-proof. No merge or push.

**EAF5 PASS 4 READY — HUMAN WALL/FLOOR PAIR REVIEW PENDING.**
