# Three-master editorial refinements — 10 October 2026

Disposition: **PASS for programmatic integrity, derived-text parity and full-document headless PDF visual QA; human PDF review pending.** This is the narrow editorial follow-up to the [reconciliation matrix](three-master-document-reconciliation-2026-10-10.md) and [original QA record](three-master-document-qa-2026-10-10.md), both preserved unchanged. For this follow-up, PDF review replaces the earlier native-Word review requirement: the user has no Word capability. No art/gameplay milestone is promoted.

## Preflight and authority

The existing branch was `codex/three-master-reconciliation-2026-10-10`, clean worktree/index, HEAD `f55646ad727d656ad13d82095626d85a0834f995`. Local main, origin/main and live remote main were verified as `e314c41ef9acfde45632bd8ad4275702e103dcc4` (`git -c http.sslBackend=openssl ls-remote origin refs/heads/main`). Repository guidance, operational summaries, current masters/mirrors and prior QA records were read before edits. No applicable AGENTS.md was found. No checkout reset/switch, stash, rebase or historical-record rewrite occurred.

The existing GDD v0.12 remains design/scope authority; VDD v0.9 owns environment/material direction; unchanged Findings v0.12 records evidence, including §32.6's separate future scopes. All retain 10 October 2026 dates. Changes implement the user's human editorial review, using existing accepted palette and status decisions. DOCX remains canonical; Markdown is derived and PDFs are review copies.

## Precise changes and allowlist

- GDD, **Document purpose and status → Decision-status legend**: replaced `Deferred` / “Intentionally outside the first-release target unless later reassessed” with `Deferred / later work` / “Outside the current prototype/milestone; may still be intended for the initial release. The relevant roadmap or section determines release status; this label alone does not exclude it from launch.” Added `Beyond first release` / “Explicitly outside the initial-release target unless separately reconsidered.” Confirmed, Provisional, Validate and Fallback rows are XML-identical. No other design/scope/historical passage changed.
- VDD **§34.4**: inserted `ACTIVE RECEIVING C1 — P05_C02` first, with the exact requested wall/floor/ceiling names and IDs. Existing P01_C02 and P05_C03 material cells are XML-identical; role labels now explicitly say HISTORICAL EAF5. The adjacent paragraph points to the first active row, avoids repeating its values and retains “P05_C03 is not an active production alternate.” Existing table styles/widths and all other policies remain intact.
- Operational summaries: replaced generic “elevator lighting” with state-dependent lift warning/light/audio theatre, optional bulb emitter/self-light treatment and proportionate evidence-led contextual refinements. Split “further C1 detail and live display data open” into C1 contextual finish **IN PROGRESS**, separately deferred CRT/lift/queue data, vocabulary/maximum text block and requirement-driven sizing, and future Stage C pressure/activation/shutter pickup gating/theatre. Accepted four-spot lighting, shaft, passive CRT, completed EAF4 tooling and **18 accepted/merged initial wear layers (17 scalar + one conventional, including hidden alternatives)** remain unchanged. README was already clear and is unchanged.

Exactly seven owned documentation files are allowed:

1. `docs/Sorting_Apocalypse_Preliminary_GDD_v0.12.docx`
2. `docs/Sorting_Apocalypse_Visual_Design_Direction_v0.9.docx`
3. `docs/readable/Sorting_Apocalypse_Preliminary_GDD_v0.12.md`
4. `docs/readable/Sorting_Apocalypse_Visual_Design_Direction_v0.9.md`
5. `docs/CURRENT_STATE.md`
6. `docs/CODEX_BOOTSTRAP.md`
7. This addendum.

## Verification evidence

| Check | Result and evidence |
| --- | --- |
| Snapshots and preservation | PASS: baseline DOCX/mirrors/operational text and tracked-file SHA-256 inventory retained externally. All 1,094 protected tracked files unchanged, including 917 non-document files, earlier editions, Findings, README, original QA/matrix and media exports. |
| DOCX ZIP/XML | PASS: all three packages valid; only `word/document.xml` changed in GDD/VDD. Package member lists, every other package part, styles, relationships, headers/footers, numbering, fonts, fields and hyperlinks unchanged. Only the legend table and VDD palette table/adjacent paragraph differ. |
| Logical structure | PASS: ordered headings unchanged: GDD 185, VDD 82, Findings 137. Tables remain 50/34/27; sections remain 1/2/1. Section properties, table grids/properties and drawings are XML-identical. |
| VDD media | PASS: all five extracted `word/media/*` SHA-256 values and drawing/relationship/crop/orientation data match the snapshot exactly. Five ordered readable image references match extracted originals. |
| Findings control | PASS: DOCX and mirror byte-identical. DOCX SHA-256 `a90e1a143711a5f5fa003818ee8fe9f11c95cac4c9a95633823a0762b26d788f`. No exception needed. |
| Mirror regeneration | PASS: only GDD/VDD mirrors regenerated from actual edited DOCX using the prior reconciliation's OOXML body/table exporter. Ordered paragraph/table parity passes for all three masters; relative link targets, fences and Markdown structure pass. |
| Full rendering | PASS: bundled `render_docx.py`, LibreOffice **26.2.5.2** (`cd7284b4cbbfeb507e630c1aac019f4157393acb`), Poppler **26.07.0**, PDFplumber **0.11.9**, disposable LibreOffice profiles; original DOCX not saved through LibreOffice. Full before/after PDF plus every page PNG at **100 dpi**. |
| Full-page visual inspection | PASS: every revised GDD page **1–62** and VDD page **1–27** inspected individually at original readable resolution, including all five images, wide schematics (18–19), overview (21), section transitions and final pages. No clipping, overflow, missing glyphs, accidental blank pages, broken headers/footers or improperly split rows observed. PDF text/page-bound checks also pass. |
| Before/after layout | PASS: page counts and page geometry unchanged (**62→62**, **27→27**). Pixel comparison differs only on GDD **2** and VDD **25–26**. The expanded legend stays on page 2; the added active palette row moves the intact CRT paragraph to page 26. All other page pixels match, including figures and final registers. No document-wide compression or page-setup change. |
| Diff/ownership | PASS: explicit seven-file allowlist, protected-file hashes and `git diff --check`; staged contents checked against that allowlist before the local commit. |
| Native Word | **NOT RUN / unavailable**: no Word Print Layout, field update, repagination or native acceptance claim. PDF review is the practical substitute for this task. |
| Godot/gameplay | **NOT RUN / unnecessary** for these editorial edits. No scene, code, art, data or asset changes. |

Edited DOCX SHA-256: GDD `06c1ae2b112cbafd7736582e454212f35e9c7135a907eb92fd425798a6a3a662`; VDD `9a560a3c8b5b8b8299b86e1c47f1c761e9423b10b6321ce8b16a38ec86d87b43`.

## Review artifacts and stop gate

Snapshots, inventories, `verification.json`, `render_verification.json`, PDF copies and before/after page PNGs are outside the repository/Godot resource scan, uncommitted, under:

`C:\Users\Boschetar\.codex\attachments\2fe57231-ad2d-49ed-8393-bf95d2c95e89\editorial-refinements-qa-2026-10-10`

Exact PDF review-copy paths:

- `C:\Users\Boschetar\.codex\attachments\2fe57231-ad2d-49ed-8393-bf95d2c95e89\editorial-refinements-qa-2026-10-10\Sorting_Apocalypse_Preliminary_GDD_v0.12.pdf`
- `C:\Users\Boschetar\.codex\attachments\2fe57231-ad2d-49ed-8393-bf95d2c95e89\editorial-refinements-qa-2026-10-10\Sorting_Apocalypse_Visual_Design_Direction_v0.9.pdf`

Open the PDFs in an ordinary viewer; review GDD page 2 and VDD pages 25–26, then the [CURRENT_STATE changes](../CURRENT_STATE.md) and [bootstrap changes](../CODEX_BOOTSTRAP.md). No Word installation is required. Stop after the authorized local documentation commit on the existing branch for human review; no push, merge, publication or C1/Stage C implementation is authorized by this follow-up.
