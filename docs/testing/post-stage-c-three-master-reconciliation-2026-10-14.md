# Post–Stage C three-master reconciliation — 14 October 2026

Documentation-only review editions: **GDD v0.14 / VDD v0.11 / Findings v0.14**. Human document review remains pending. Receiving Stage C overall remains **HUMAN-PROMOTED / CLOSED in its agreed prototype scope**; C1, Stage A/B, single-cycle, intentional lighting and two-batch acceptance retain their dispositions. This edit selects no next milestone.

## Authority and preflight

- Verified origin identity: `https://github.com/Navandis/Sorting-apoc-PROTOTYPE.git`. Local HEAD, `origin/main`, live remote HEAD and live remote main all matched `bb6683d28539ff743bc480a9d5d68c4ef3d0ce87` before editing. The Schannel remote query failed with a host credential/certificate-store error; a command-scoped OpenSSL query succeeded, without changing Git configuration.
- Verified linear ancestry: single-cycle publication `eee1be5`, lighting integration `fe5372b`, manual scene authoring `9ede796`, two-batch implementation/publication `83cbed1` / `3be0c1c`, and Awaiting Lift implementation/closure `907c665` / `bb6683d`.
- The checkout started clean, with no DOCX locks or running Word/LibreOffice process and no newer-edition collision. Created `codex/post-stage-c-master-documentation` from that checkout. Four other existing worktrees were left intact. No reset, stash, clean, lock deletion or unrelated-edit absorption.
- Read the working guidelines, operational entry points, complete input masters, and the records below through their later human disposition/publication addenda. Focused current source resolved exact behavior/settings. One executor performed one consolidated editorial/layout review, with corrections rechecked.

## Source-to-change matrix

| Source / decision | Reconciled destination |
|---|---|
| [Single cycle, 12–13 October](receiving-stage-c-single-cycle-validation-2026-10-12.md), final contact/promotion addenda | GDD §§4–5, 9, 11, 20–21; VDD §§7, 13, 28, 34.7; Findings §§34.1–34.2: stationary TAKE-only bay, autonomous six states, fully OPEN gate, last successful TAKE, ~3.40 s contact, full cue, busy departure and outbound retirement. |
| [Intentional lighting, 13–14 October](receiving-intentional-lighting-candidate-2026-10-13.md), later integration and human authoring `9ede796` | VDD lighting/Receiving/authoring passages and §§34.7–34.8; Findings §34.3; operational fronts: disabled ambient, KeyLight off, retained Environment/probe, warm practicals/cage/bounce, overrides, tunable baselines and tolerated residual shadow pattern. |
| [Two FIFO deliveries, 14 October](receiving-stage-c-queued-deliveries-validation-2026-10-14.md), final acceptance/publication | GDD §11 and roadmap; VDD theatre/CRT; Findings §34.4: distinct preserved batches, indefinite OPEN waiting, full outbound handoff and no opposing travel overlap. |
| [Awaiting Lift and overall closure](receiving-stage-c-awaiting-lift-validation-2026-10-14.md), final publication `bb6683d` | GDD §§5, 9, 11, 20–21 / Appendix B; Findings §§30, 34.5–34.7; all current summaries: one active plus two deposited queued, team-linked upstream submissions, capacity versus invalid refusal, oldest-first recovery, simulated midnight and terminal identity. |
| Current Receiving manager, lift coordinator/display, Awaiting Lift and runtime sources | Findings §34.5 exact interfaces/statuses/owners; VDD §34.7 exact footer wording, live read-only CRT and W1. Future production returns use `AwaitingLiftAdmission.submit_return(...)`; real clock/Expedition/Dispatch/population/save work remains future. |
| Current lighting/reflection and wing Environment/gameplay scenes | VDD distinguishes promoted inherited settings from later transforms/material/W1 overrides. Current eleven scalar wear instances plus one conventional OilStain supersede the 17+1 snapshot; removed monitor alternatives are not restoration targets. |
| [11 October C1 close-out](receiving-c1-human-promotion-documentation-closeout-2026-10-11.md), [A30WS evidence](receiving-a30ws-reflection-integration-2026-10-11.md) | Historical boundaries preserve C1 acceptance, former lighting context, unexplained probe comparison and accepted performance debt. Old registers/figures retain dates/context. |
| User's 14 October brief | Cleaning-corner balance accepted with future Dispatch spill in mind; no implemented spill claimed. Ordinary reviewed tuning does not automatically reopen completed milestones. |

## Changed files and review guide

| New authoritative master | Generated mirror | Substantive review locations |
|---|---|---|
| [GDD v0.14](../Sorting_Apocalypse_Preliminary_GDD_v0.14.docx) | [GDD mirror](../readable/Sorting_Apocalypse_Preliminary_GDD_v0.14.md) | Front/status, §§4–5, 9, 11 throughout, 16.9, 18, 20–21, Appendix B and R14. Design/night/balance intentions remain distinct from accepted implementation. |
| [VDD v0.11](../Sorting_Apocalypse_Visual_Design_Direction_v0.11.docx) | [VDD mirror](../readable/Sorting_Apocalypse_Visual_Design_Direction_v0.11.md) | §§7, 13, 28, 34.7–34.8 and §37; intentional lighting, overrides, theatre/W1/CRT, authoring policy and retained historical figures. |
| [Findings v0.14](../Sorting_Apocalypse_Prototype_Findings_v0.14.docx) | [Findings mirror](../readable/Sorting_Apocalypse_Prototype_Findings_v0.14.md) | Cover/executive status, evidence §30, historical boundaries, new §§34.1–34.7: progression, interfaces, dated evidence and limits. |

Other changed files: [CURRENT_STATE](../CURRENT_STATE.md), [README](../README.md), [CODEX_BOOTSTRAP](../CODEX_BOOTSTRAP.md), narrowly corrected [wear guide](../environment-authoring/eaf4-wear-authoring-guide.md), [scalar guide](../environment-authoring/eaf4-imperfection-audition-guide.md), and this record. **Twelve intended documentation paths.** Present-state fronts replace active stale gate/CRT/W1/lighting claims; dated history remains explicit.

## Actual document QA

- Edited new DOCX copies first using the established XML-preserving ZIP workflow; previous editions, mirrors and validation records were not edited. Regenerated mirrors from those masters with the established extraction approach and derived/not-independent-authority notice.
- Rendered all final masters through the available Documents skill's `render_docx.py` using installed LibreOffice **26.2.5.2** at **110 dpi**. Visually inspected **every page at readable resolution: GDD 64, VDD 28, Findings 52 — 144 pages total**. Portrait pages were inspected in native-size pairs; all VDD landscape pages were also inspected individually at native size. Checked tables, headings, breaks, images/captions, glyphs and headers/footers.
- Corrected a Findings historical heading/body placement and moved the GDD clock-boundary paragraph outside its timetable cell. Kept four GDD Appendix E orientation-table body rows together; moved the standalone Appendix F break onto its heading to avoid a blank page. Rerendered/reinspected affected pages. Final GDD pages 60–64 changed; earlier reviewed pages were confirmed unchanged by image hashes.
- Final PDF geometry checks: **zero text characters outside page bounds, zero replacement glyphs, no empty/low-content pages**. Visual review found no remaining clipping, broken tables, orphan headings, missing images or header/footer defect. Existing visual identity and deliberate part breaks were retained.
- Final package verification **passed**: ZIP integrity, XML parsing and all internal relationship targets; unchanged styles, numbering, section properties, table/cell properties and field instructions. Retained **50 / 34 / 27 tables** and **1 / 2 / 1 sections** (GDD/VDD/Findings). The four documented row-keep properties are the sole table-structure formatting exception. All five VDD embedded images retain their bytes and drawing order. Only document content, edition/date metadata and applicable headers/footers changed package parts; all untargeted source paragraphs remain byte-identical. Original master SHA-256 hashes still match preflight.
- Mirror verification **passed**: complete source paragraph/table order, heading counts **187 / 84 / 151**, image references and existing media files; **zero broken relative links** in the updated entry points, guides, mirrors and this record. Existing update-fields-on-open settings and page field instructions remain intact; rendered pagination/edition/date were visually checked. Native Microsoft Word rendering was not separately tested.
- Content audit attributes reported **25 / 8 / 12 / 14** suites by date/scope; they are overlapping historical results, not additive unique tests or new runs. The two-batch complete audiovisual demonstration, Awaiting A-unblock capture and deterministic five-cycle coverage remain distinct; midnight remains explicit simulation.
- No Godot regression, scene/runtime tuning, screenshot, asset/import change, push, merge, history rewrite or branch/worktree cleanup. Temporary scripts, internal PDFs and PNGs are outside the repository in the task attachment's `post-stage-c-qa` directory.

## Evidence limits and source ambiguity

- Saved human W1 override is **range 2.5 m / attenuation −0.5**. `ReceivingLiftCycle.configure()` resets range to exported default **1.8 m**; no owning scene override was found. Attenuation remains −0.5. VDD/Findings distinguish saved and configured behavior without retuning or claiming effective 2.5 m runtime range.
- Technical **.30/.40 probe images were pixel-identical and unexplained**; later human visual review accepted actual metallic appearance. No cause is claimed solved and no visual blocker reopened. Essential .30 probe/refresh ownership and accepted one-machine costs remain, without fresh profiling under the later rig.
- Held-item material-null diagnostics, unrelated `gallery_a_fixture_front` failure, unrun editor-capture checks and excluded brace-junction/Backlog/Dispatch work retain their scopes. Intentional invalid-return diagnostics and host certificate-store warnings are not new game defects.
- Return statuses/events are in-memory integration seams, not a roster, actual clock, Medical/recruitment/population execution, durable save/journal recovery or time-pressure play. Overall game/Systems MVP completion is not claimed.
- Optional local illumination diagnostic exists; its images were not needed to establish tracked decisions. No measurements or recovered screenshots are invented.

Delivery stops at one local documentation-only commit and human document review. That review does not reopen accepted gameplay or lighting.
