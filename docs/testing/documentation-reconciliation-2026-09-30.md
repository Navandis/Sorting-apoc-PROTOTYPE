# Documentation reconciliation validation — 30 September 2026

## Baseline and ancestry

- Authoritative checkout: D:\Godot Projects\Sorting-apoc-PROTOTYPE.
- Baseline local main and fetched origin/main: 7b77fc969fd8e0408e71327f88d81ecb7211419c. Origin had not advanced at the preflight fetch.
- Reviewed documentation chain from that baseline: Findings draft be43075bf18689fda8dd6bc76cbc5d5031f65c77 → Findings supersession correction 9ef866bca98a6d16482c73bd4b7121e7cdcb9525 → VDD draft 0fc4c3d4e1a720a0207ae3f03399ba4690c14646 → GDD draft 2afcc892cc6c29b55ea49ba2bbbe3b6c20f740ef → reconciliation branch codex/docs-reconciliation-2026-09-30.
- The reconciliation branch was created from the exact expected GDD HEAD. Main is its ancestor.

## Final current masters

| Authority | Source | Final DOCX SHA-256 |
| --- | --- | --- |
| Overall gameplay, design and scope | docs/Sorting_Apocalypse_Preliminary_GDD_v0.11.docx; GDD draft source 2afcc892cc6c29b55ea49ba2bbbe3b6c20f740ef | 92BA37E95CBD1C86F5A33B5ACA7C4EE0D1F2DAB2E0C3F8F70F87E45D04F851CA |
| Implementation, technical verification and human evidence | docs/Sorting_Apocalypse_Prototype_Findings_v0.11.docx; Findings draft/correction sources be43075bf18689fda8dd6bc76cbc5d5031f65c77 and 9ef866bca98a6d16482c73bd4b7121e7cdcb9525 | C2EE4F9EE4E7232FCD6E5B3EF3356E15D5068C0B810147AE55A921FF9A377FDD |
| Environment, world, spatial and material direction | docs/Sorting_Apocalypse_Visual_Design_Direction_v0.8.docx; VDD draft source 0fc4c3d4e1a720a0207ae3f03399ba4690c14646 | 01C3E4D1752CF7BF58FF8BB8027BCE06D416088625370CD682C207CD57751557 |

The approved GDD §20.1 correction now calls the Gallery B rack/ladder bridge “the promoted real-wing Stage B storage-destination baseline.” The ambiguous “movable Stage B storage-destination baseline” wording is absent. This does not promote movable or sliding ladder gameplay.

## Reconciliation and factual gate

- The three masters and derived readable extracts now call GDD v0.11, Findings v0.11 and VDD v0.8 the current authorities. Historical editions were preserved.
- Current gate order agrees: EAF1–EAF5 human-promoted, EAF5 closed; Receiving Stage C1 next; C1A parked and unpromoted; remaining Stage C queue, delivery choreography and theatre later.
- Current ladder, Gallery B bridge, Stage A identity/content, deterministic TAKE-only Stage B and freight fixtures, rejected irregular frozen piles, one active plus two FIFO queued deposited batches, prepared-undelivered distinction and Awaiting Lift pressure were compared across the final extracts. No material contradiction was found.
- Prototype Receiving dimensions and reaches agree where stated: 3.00 × 2.00 m usable, 3.10 × 2.10 m support, 0.05 m border, 3.4 m fixture TAKE, 1.4 m loose and 2.3 m ordinary storage/manual; all remain prototype values.
- Environment direction agrees: UV default with reviewed triplanar opt-in; PRIMARY P01_C02, ALTERNATE P05_C03, NONE / NO_FINISH base finish, no structural secondary by default, no fixed base wear preset, and later causal/contextual wear against actual room causes.
- The global current-status scan found no live pending-review, pending-refresh, pre-promotion ladder, physical Stage B, PBR-route or EAF5 contradictions. Two older “no ladder implementation is promoted” statements remain inside explicitly marked historical checkpoints and were preserved as dated evidence.

## DOCX and readable verification

| Master | Rendered pages | Body paragraphs and table cells present in extract | Heading order | Embedded images |
| --- | ---: | ---: | --- | ---: |
| GDD v0.11 | 61 | 1,751 / 1,751 | 184 ordered | 0 / 0 |
| Findings v0.11 | 44 | 1,054 / 1,054 | 129 ordered | 0 / 0 |
| VDD v0.8 | 26 | 521 / 521 | 81 ordered | 5 / 5 |

All three DOCX masters rendered through the packaged document renderer to page PNGs and PDF. Every rendered page was reviewed in contact sheets; the edited front matter, roadmap, §30–31, §34.8–34.9 and Appendix F pages were checked at original size. The Findings §30 current-state date was corrected to 30 September, re-rendered and checked. No clipping, broken tables, orphaned headings, blank spill pages, header/footer collisions, missing or distorted images, or broken captions were observed. PDF text-bound checks found zero empty pages and zero text glyphs outside page bounds across 131 pages. The GDD contents pages and all master version labels were reviewed; the masters retain their 29 September v0.11/v0.8 edition date while this reconciliation record is dated 30 September.

All DOCX body text and table-cell text is represented in the respective readable extract after whitespace normalization. Heading order, version/date lines and VDD image count agree. The readable files are derived companions, not independent authorities.

## Entry points, links and diff protection

- docs/README.md points to the three promoted masters and readable extracts and links to this record, EAF5 promotion and the C1 handoff.
- docs/CURRENT_STATE.md carries the 30 September decision record, promoted authority set, C1 gate, C1A parking and EAF5 production-facing recipe.
- docs/CODEX_BOOTSTRAP.md names the same masters, retains the startup order and Receiving invariants, and gives the concise C1 handoff recipe.
- Relative Markdown links in these entry points and extracts were checked for existence. The historical DOCX editions remain untouched.
- The complete main-to-reconciliation diff is confined to docs/. No gameplay, greybox, environment-authoring, data/environment, project, test or asset file changed. No gameplay or environment implementation was performed by this task.
- Proportional verification used document renders, visual review, DOCX/readable parity, link checks, consistency and stale-status scans, diff scope, and Git ancestry. The Godot/EAF gameplay regression matrix was not rerun.

## Publication

The approved documentation chain is to be fast-forwarded to main and pushed to origin/main without force. The reconciliation commit, final main and origin/main SHA values are reported in the final publication report; a committed file cannot contain its own final commit SHA without changing that SHA. Publication verification requires equal local/remote main refs and a clean worktree. Local documentation branches are deleted only after their tips are reachable from main. No documentation remote branches were present at preflight. The parked codex/receiving-c1a-structural-shell branch is retained.

**Status: DOCUMENTATION REFRESH — RECONCILED / HUMAN-APPROVED / PUBLISHED.**

**Next implementation gate: Receiving Stage C1.** C1 implementation, C1A resumption and remaining Stage C gameplay are outside this documentation task.
