# M4 publication and final documentation close-out

25 October 2026. **M4 HUMAN-PROMOTED / CLOSED IN ITS BOUNDED SCOPE / PUBLICATION CANDIDATE.** The developer accepts the documentation re-review for publication and explicitly authorizes the two factual corrections, bounded documentation commit, fast-forward local main and normal push.

**PUBLISHED is conditional on successful normal push and independent live remote main matching final local main in external completion evidence and the delivery report. Until those steps succeed, this record describes a local publication candidate.** The final commit cannot record its own hash; actual final local/remote SHA and command outcomes are recorded externally at `C:/Users/Boschetar/.codex/attachments/m4-publication-20261025/` and in the completion report. No recursive evidence commit is required.

## Verified starting checkpoints

| Checkpoint | Full SHA |
| --- | --- |
| Local main and independently queried remote main | `3bb69a906e921f06dd12c61bd4d8f33db35d6fce` |
| Accepted gameplay and final UI | `844d0d4adaa5a2d601f04954bb61ad7a5c316589` |
| Initial documentation close-out | `3a496c00a40bb822e17354059b7362b633d539ff` |
| Reviewed reconciliation / exact starting feature HEAD | `180dcf597ff699149d6335df57e31c313d3b19af` |

Authoritative project: `D:/Godot Projects/Sorting-apoc-PROTOTYPE`, starting branch `codex/m4-expedition-loadout`, remote `https://github.com/Navandis/Sorting-apoc-PROTOTYPE.git`. Tracked tree and index were clean. The 18 untracked import/UID sidecars match the previous inventory and hashes exactly. Five registered worktrees were inventoried and retained; main was not checked out in another worktree. Fetch and independent `git ls-remote origin refs/heads/main` agree on the starting main above.

Ancestry checks retain the complete linear twelve-item top-up and M4 history: `3bb69a9` → `e8ed120` → `a669c0d` → `71101cf` → `d81d48a` → `f5eae9b` → `3a57177` → Stage A `a0d4a8a` → Stage B `7ebc571` → UI `80ab28c` → accepted `844d0d4` → documentation `3a496c0` → reviewed `180dcf5`. Each of the two commits after accepted gameplay changes only documentation. No intervening feature change was accepted or discarded.

## Bounded document correction and status

GDD v0.15 §21.4 now states: “The developer fully provisioned and dispatched all four teams before the 10:00 cutoff, but only narrowly. The 08:30 scripted supply helped, while unfamiliar, unorganized seed stock and text parsing added friction.”

Systems MVP v0.5 §21.4.1 now states: “In the normal-speed playtest the developer fully provisioned and dispatched all four teams before cutoff, but only narrowly.” The remaining assistance/confounders, Medical 0/24/expired, uncertain ordinary opening balance and bounded acceptance are unchanged. No raw historical log or conversation reconstruction was edited.

The existing DOCX editions were edited first, preserving their runs and formatting. Both companions were regenerated using the established paragraph/table exporter. Current-facing status text references later PUB25 publication authority and its remote-confirmation condition. Earlier dated no-publication instructions, local-closure and reconciliation records retain their historical scope. The validation record receives only a dated publication addendum.

Expanded Workshop, Training and whole-experience pacing sections are retained without condensation or redesign. Publication grants no design or implementation approvals. M1–M3 remain HUMAN-PROMOTED / PUBLISHED / CLOSED. The 167-item values and scenario remain locked M4 testing content, not final economy. Twelve Auto Stack Group approvals remain pending with saved None. One guaranteed Training day/following-morning benefit is confirmed within a tentative unimplemented feature; other choices remain open. CF-07, certificate-store diagnostics, Pickaxe 108 LOD, full-game Ironman durability and deferred non-blocking catalogue/wing loading investigation remain disclosed.

## Validation and preservation evidence

Package/XML/relationships and ordered companion parity pass for all 1,998 GDD and 1,084 MVP nonblank paragraph/table-cell units. All 54 GDD and 36 MVP tables retain geometry and order. Only `word/document.xml` changed in each DOCX; other package parts, styles, numbering, headers/footers and section geometry remain unchanged. Paragraph changes are restricted to the two factual corrections and publication-status text; no concept content or table structure was removed.

Fresh renders use the established Documents `render_docx.py`, native Windows LibreOffice and bundled Poppler at 100 dpi: **77 GDD pages / 49 MVP pages**. All 21 changed pages were inspected at full rendered size, with neighboring transitions on contact sheets; no clipping, overlap or broken tables was found. The other **105 pages are pixel-identical** to accepted reconciliation renders. Native Microsoft Word rendering is not claimed. Run/paragraph formatting structures and the full Workshop, Training and pacing sections remain unchanged; retained word counts are **1,097 / 1,522 / 1,502**. All **227 local links / 24 heading anchors** resolve.

The existing preservation approach checked **24,987 baseline files**: **24,979 protected files unchanged**, eight intended existing-document changes, zero missing files, plus this new publication record. All **18 original sidecars** and **two actual save files** retain their hashes. Ignored/licensed assets, source models, ItemDefinitions, locked M4 JSON/CSV, authored scenes, source reconstruction, prior masters and existing evidence remain unchanged. All five worktree registrations and other-worktree HEADs are retained; sidecars remain uncommitted. A final scope review confirms only the two factual corrections and bounded publication bookkeeping. No repository audit tooling or new review cycle was introduced. No gameplay, Godot import, performance, hardware/audio, balance or save exercise is run by this publication task. Accepted executor, independent and human evidence is reused with its existing attribution: [M4 validation and promotion](m4-expedition-loadout-validation-2026-10-24.md), [Stage A](m4-startup-catalogue-reuse-validation-2026-10-25.md), [Stage B](m4-geometry-measurement-reuse-validation-2026-10-25.md), [UI follow-ups](m4-ui-refinements-validation-2026-10-25.md), [initial document QA](m4-human-promotion-documentation-2026-10-25.md) and [accepted semantic reconciliation](m4-documentation-semantic-reconciliation-2026-10-25.md).

## Commit and integration boundary

Only these nine documentation paths may be staged explicitly:

- `docs/Sorting_Apocalypse_Preliminary_GDD_v0.15.docx`
- `docs/readable/Sorting_Apocalypse_Preliminary_GDD_v0.15.md`
- `docs/Sorting_Apocalypse_Systems_MVP_Foundation_Design_and_Progress_v0.5.docx`
- `docs/Sorting_Apocalypse_Systems_MVP_Foundation_Design_and_Progress_v0.5.md`
- `docs/README.md`
- `docs/CURRENT_STATE.md`
- `docs/CODEX_BOOTSTRAP.md`
- `docs/testing/m4-expedition-loadout-validation-2026-10-24.md`
- `docs/testing/m4-publication-2026-10-25.md`

A normal new documentation commit follows reviewed `180dcf5` on the retained feature branch. Immediately before integration, live remote main must still equal preflight main. Local main may advance only along the verified ancestry to that exact feature tip. Since main is not owned by another worktree, a guarded compare-and-swap ref update after an explicit ancestor check is the fast-forward equivalent; switching to the already-identical main tip does not rewind or rewrite the asset-equipped working tree. No new Godot-scanned duplicate or worktree is needed. Normal `git push origin main` is followed by an independent `git ls-remote origin refs/heads/main`; remote SHA must equal local main. Final tracked/index state, sidecar hashes, saves and worktree registrations are rechecked externally.

If any guard fails, retain the actual state and report it without force, reset, rebase, squash, conflict resolution, broad staging or cleanup. The feature branch and all worktrees remain. No unrelated branch push, tag or PR is authorized. **M5 NOT IMPLEMENTED / NOT STARTED BY THIS TASK.**
