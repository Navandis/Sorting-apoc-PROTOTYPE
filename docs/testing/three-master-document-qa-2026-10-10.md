# Three master document QA — 10 October 2026

**PASS for local documentation review.** Receiving C1 remains **IN PROGRESS**; Stage C physical queue pressure, activation and theatre remain future. The initial manual wear composition is human-reviewed/merged and currently has **18 saved layers (17 scalar plus one conventional preset)**, including hidden alternatives. This inventory is neither a quota nor acceptance of every hidden alternative. Completed EAF4 tooling remains separate from editable room art.

Clean-main preflight and live remote query agreed at `e314c41ef9acfde45632bd8ad4275702e103dcc4`, including manual art commit `c160ae8684c0037091503232d0645281f85365fd`. Review branch: `codex/three-master-reconciliation-2026-10-10`. The [dated matrix](three-master-document-reconciliation-2026-10-10.md) was written before master edits and records exact sources, status classifications and historical supersessions. No substantive editorial conflict remains unresolved.

## Outputs and changed sections

| New Word master and derived mirror | Changes and source mapping |
| --- | --- |
| [GDD v0.12](../Sorting_Apocalypse_Preliminary_GDD_v0.12.docx) / [readable](../readable/Sorting_Apocalypse_Preliminary_GDD_v0.12.md) | Cover/authority; §11 Stage A/B versus intended Stage C; §16.9 visual direction; §18 production; §20.6 roadmap; §21.1–21.3 risks/next evidence; dated register. Appendix F gains a historical supersession note. Sources: matrix; [compact retrofit](receiving-c1-compact-retrofit-closeout-2026-10-03.md); [lift/deck](receiving-c1-lift-enclosure-deck-closeout-2026-10-01.md); accepted EAF4 milestone and human composition clarification. Established mechanics, balance and deferrals retained. |
| [VDD v0.9](../Sorting_Apocalypse_Visual_Design_Direction_v0.9.docx) / [readable](../readable/Sorting_Apocalypse_Visual_Design_Direction_v0.9.md) | §1 authority; §5–6 broad scalar/local wear grammar; §10.3 Foundation Gate progress; §13 current Receiving; §25–28 checks/summary; §31 spatial authority; §34 actual P05_C02, lighting, furnishings, passive CRT/plaque and authoring order; §35 register. Sources: matrix; [envelope](receiving-c1-structural-material-envelope-closeout-2026-09-30.md); compact/lift records; [dressing](receiving-c1-set-dressing-collision-closeout-2026-10-09.md); [CRT](receiving-c1-lift-crt-visual-closeout-2026-10-09.md); [wear](../environment-authoring/eaf4-wear-authoring-guide.md) and [scalar](../environment-authoring/eaf4-imperfection-audition-guide.md) guides/canonical approvals. Original images, schematics, world history and proof palettes retained with historical labels. |
| [Findings v0.12](../Sorting_Apocalypse_Prototype_Findings_v0.12.docx) / [readable](../readable/Sorting_Apocalypse_Prototype_Findings_v0.12.md) | Cover/executive/current-status tables; §27.3 deck supersession; §28.6 catalog supersession; §29 proof and §31 register labeled historical; §32 dated C1/EAF4 evidence, source register and remaining work. Sources: all matrix close-outs; [EAF4 milestone](environment-authoring-eaf4-imperfection-authoring-milestone-closeout-2026-10-10.md); [retirement](environment-authoring-eaf4-imperfection-approvals-and-receiving-finish-retirement-2026-10-10.md); live scene/catalog and verified Git history. Automated assertions, render evidence and human editor/in-game acceptance remain distinct. Earlier negative results preserved; Windows certificate/ObjectDB-RID diagnostics are not declared fixed. |

Operational updates: `docs/README.md`, `docs/CURRENT_STATE.md`, `docs/CODEX_BOOTSTRAP.md` and the two live EAF4 guides above. Navigation points to the new editions; formerly unpublished seventeen-layer/empty-root guidance is superseded. Past close-outs remain untouched. The new editions await human documentation review and approve no new gameplay or visual milestone.

## Preservation and export checks

Copied the source masters and patched selected XML text nodes; appended text uses existing paragraph/heading styles. The masters were not rebuilt from Markdown. ZIP integrity and XML checks **PASS**. Package part names/counts, styles, numbering, font tables, all relationships, section properties, table geometry, drawings and embedded media remain byte-identical outside the explicitly changed text/property parts. Unedited original paragraph XML remains identical (GDD 1,768; VDD 517; Findings 1,056). Credits/licensing and untouched captions remain preserved.

| Document | Rendered pages, old → new | Tables, old = new | Sections, old = new | Media/drawings, old = new | Headings, old → new |
| --- | --- | --- | --- | --- | --- |
| GDD | 61 → 62 | 50 | 1 | 0 | 184 → 185 |
| VDD | 26 → 27 | 34 | 2 | 5 | 81 → 82 |
| Findings | 44 → 47 | 27 | 1 | 0 | 129 → 137 |

**PASS:** SHA-256 comparison preserves all six previous DOCX/readable editions and all **170 historical/protected documentation files**. All five VDD media parts and drawing relationships match the source exactly, without recompression; existing readable media links match their Word targets in order, including table-cell drawings. No new/orphaned media introduced.

**PASS:** new mirrors generated directly from new DOCX using the established paragraph/table/image extract convention. Full body/table paragraph order, ordered headings, titles/versions, table text, figures and image hashes agree. Nonempty paragraph counts are 1,760 / 532 / 1,085. Original mirrors also match source text/media after normalizing line breaks. Headers/footers use current version/date; PAGE instructions remain intact, with `updateFields=true` requested on open. GDD's original contents table is static and has no page-number TOC field.

## Visual inspection and validation limits

**PASS:** all six editions rendered with the bundled `render_docx.py`, LibreOffice **26.2.5.2** (`cd7284b4cbbfeb507e630c1aac019f4157393acb`), and Poppler at **100 DPI**. Inspected all **267 pages** in page contact sheets, with full-size inspection of changed GDD pages 2/26/27/48, VDD 5/7/25/27 and Findings 2/44–47. No clipping/overlap, broken table geometry, missing/displaced original figures or visible glyph problems found. Inherited intentional page breaks and sparse historical pages retained. The added VDD register was tightened to avoid an almost-empty continuation page. PDF checks across all pages report zero off-page text, empty pages or replacement-character pages; page-image counts equal PDF counts. Render evidence and task scripts remain outside Godot-scanned directories in the task attachment QA folder.

**PASS:** repository-specific Markdown structural checks (relative links, balanced fences, no conflict markers/trailing whitespace), version/status review and Git diff whitespace/scope checks. No configured repository Markdown/document linter was found; a named external lint suite is **NOT RUN**. All **917 tracked non-document files** match preflight hashes; no scene, script, shader, material, catalog, approval, asset or tracked import/cache changed. Only thirteen documentation files are included in the local review change.

**NOT RUN:** native Microsoft Word rendering, manual Word field refresh, fresh Godot/editor interaction or gameplay tests. Runtime checks are unnecessary for this documentation-only change; recorded historical tests are not presented as rerun results.

Before publication, the human should open the three new Word masters in Print Layout, allow/update fields, and check Word pagination/page numbers, GDD contents/§11/§21, VDD all five images/§34–35, and Findings §30–32/source register. Review the authority split, 18-layer initial baseline, C1-open/Stage-C-future boundary and historical labels. Native Word pagination can differ from LibreOffice. No push, merge, publication or further C1 implementation belongs to this task.
