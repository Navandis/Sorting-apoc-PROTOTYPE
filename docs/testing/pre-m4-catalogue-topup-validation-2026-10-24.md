# Pre-M4 twelve-item physical catalogue top-up — 24 October 2026

**CATALOGUED / TECHNICALLY CHECKED / HUMAN PHYSICAL REVIEW PENDING — NOT PUBLISHED.**

Executed the developer-approved twelve-item handoff with one executor in the authoritative asset-equipped checkout, on local branch `codex/pre-m4-catalogue-topup-12`. Base: `3bb69a906e921f06dd12c61bd4d8f33db35d6fce`; clean `main` and independently queried remote `main` matched before execution. The read-only remote query used per-command OpenSSL after Schannel credential failure. No other worktree was switched, reset, stashed, cleaned or edited. Commit/HEAD and final Git state are recorded in the delivery and external `final-git.txt`.

Evidence: `C:/Users/Boschetar/.codex/attachments/pre-m4-topup-2026-10-24`. Engine **4.7.stable.official.5b4e0cb0f**, Compatibility; engine processes ran serially. `baseline.json`, `imported.json`, individual `.log`/`.result.json` files, `final-results.json`, `physical-results.json`, `idempotence-preservation.json` and `preservation-results.json` hold the actual commands, exit codes, completion markers, diagnostics, source hashes and comparisons. Raw evidence stays outside the project.

## Exact inventory and preservation

**174 source models = 162 existing + exactly twelve authorized additions; 167 active definitions; seven permanently retired IDs** (`005/023/024/034/036/037/042`). No missing, extra, broken, dependency-blocked or ambiguous showcase source was found. IDs **163–174** follow the actual inventory/manifest/retirement high-water mark; next sequence is **175**. Compound assets remain single entities. No Fuel→Energy change, M4 implementation, numerical calibration, normal incoming-content addition or source-art repair occurred.

Active category totals: **Electronics 13, Food 33, Fuel 12, Hydration 19, Medical 8, Morale 18, Protection 27, Weapons 37**. The twelve contribute Food **1**, Fuel **2**, Hydration **5**, Protection **4**.

All **155 original definition files** remain byte-identical. All **162 prior inventory records and 162 prior review records**, including seven retired records, remain identical in content; original review text is retained and twelve records appended. All five approval stages remain current for the **155 human-approved items**. The five accepted scales, 027/154/155 Footprint overrides, exact 152–155 `folded_clothing` membership, Cola Can 019/Hydration +3 and the source-confirmation history are preserved. All twelve new records are **UNREVIEWED at all five stages**. Their Utility **None/0**, Bulk **1** and scale **1.0** are temporary/default physical-onboarding values, not calibration.

The retirement ledger, production scenarios, normal manifests, starting items, 35-member recurring pool, scenes and runtime owners are unchanged. All **2,421 existing files under `assets/props`**, including all 174 source models and associated textures/import sidecars, match baseline hashes; none were added, deleted, renamed or rewritten by this execution. Git is not their protection. Other asset roots were not edited. The four other worktree registrations/HEADs are unchanged.

Every engine launch redirected `APPDATA` and `LOCALAPPDATA` into the external evidence root. Normal default saves resolve below `%APPDATA%/Godot/app_userdata/Sorting-apoc-PROTOTYPE/saves`; continuation and startup tests additionally injected explicit external service directories. The developer's continuation was never opened, migrated, overwritten or deleted. The catalogue content fingerprint changes as designed; incompatible physical snapshots still reject explainably.

## Twelve-item physical review guide

Every source below is relative to **`res://assets/props/`**; each external definition is **`res://data/items/definitions/<ID>.tres`**. Pose is XYZ degrees, with intended Front at canonical **+Z**. Footprint is width × depth in **0.10 m cells**; the third component stays **1**. **R/S** means can rest on support / can support another item. All groups are explicitly **None**, independently of category. All root transforms are identity; internal source transforms remain intact. Every row still needs human scale, pose/Front, Footprint, roles and group review.

| ID | Exact source | Name / category | Pose XYZ | Footprint | R/S | Group | Review flags |
|---|---|---|---|---|---|---|---|
| `loot_000163` | `Food/SM_MysteryMeat_Carcass_Large_01.glb` | Large Mystery-Meat Carcass / Food | 0, 0, 90 | 13×6 | Yes/No | None | 1.226 m long; side-resting contact/Front; venison reference only; distinct from piglet/smaller meat |
| `loot_000164` | `Fuel/SM_Charcoal_Bag_03.glb` | BBQ Charcoal Bag / Fuel | 0, 0, 0 | 3×2 | Yes/No | None | Soft bag; crimped top; two attached label meshes; flame graphic Front |
| `loot_000165` | `Fuel/SM_Lighter_Fluid_Can_02.glb` | Lighter Fluid Can (330 ml) / Fuel | 0, 0, 0 | 1×1 | Yes/No | None | Upright; +Z label; nozzle/cap prevent flat supporting top |
| `loot_000166` | `Hydration/SM_6L_Water_Bottle_02.glb` | Water Bottle (6 L) / Hydration | 0, 0, 0 | 3×3 | Yes/No | None | 0.42 m height; handle/Front and capacity plausibility; narrow cap |
| `loot_000167` | `Hydration/SM_Bottles_Crate_01.glb` | Soda Bottle Crate (20 Bottles) / Hydration | 0, 0, 0 | 5×5 | Yes/No | None | One crate, twenty bottles, intended 6.6–10 L total; internal mesh scale 0.8 preserved; protruding bottles; no `round_cans` inference |
| `loot_000168` | `Hydration/SM_Juice_BagBox_01.glb` | Apple Juice Bag-in-Box (7-8 L) / Hydration | 0, 0, 0 | 3×4 | Yes/Yes | None | Body plus four attached label planes; labels extend beyond body; conservative full-source bounds; top rigidity/contact and supporting role especially need review |
| `loot_000169` | `Hydration/SM_OJ_LargeJug_01.glb` | Orange Juice Jug (4-5 L) / Hydration | 0, 180, 0 | 2×2 | Yes/No | None | Yaw puts source −Z orange label at +Z; 0.28 m height/capacity plausibility; handle/cap |
| `loot_000170` | `Hydration/SM_Water_6Pack_03.glb` | Water Bottle Six-Pack (9-12 L) / Hydration | 0, 0, 0 | 4×3 | Yes/No | None | One six-bottle bundle; broad row Front; wrap stability; uneven capped top |
| `loot_000171` | `protection/SM_Cosplay_helmet_01.glb` | Cosplay Helmet / Protection | 0, 0, 0 | 3×3 | Yes/No | None | Four complementary pieces; rim/face contact, projecting wings; source face at +Z |
| `loot_000172` | `protection/SM_Fedora_Hat_01.glb` | Fedora / Protection | 0, 0, 0 | 4×4 | Yes/No | None | Brim-down; soft crown; three assembled meshes; internal centimetre conversion preserved; semantic Front provisional |
| `loot_000173` | `protection/SM_LeatherGloves_01.glb` | Leather Gloves (Pair) / Protection | 80.2063, −105.0137, −104.8046 | 2×3 | Yes/No | None | One offset pair; derived broad-face resting correction, fingers +Z; inspect both contacts; no retired 034 reuse or `folded_clothing` inference |
| `loot_000174` | `protection/SM_Wellies_01.glb` | Rubber Wellies (Pair) / Protection | 0, 0, 0 | 4×4 | Yes/No | None | One pair, soles down; confirm toes/+Z; two open shafts are not a supporting top |

There is **no proposed reservation overhang** among these twelve: measured canonical bounds fit all authored horizontal reservations. This does not remove source-label, soft-contact or semantic-Front warnings. `topup-proposals.png` is a rendered inspection aid, not human acceptance. Source fingerprints, mesh/submesh counts, materials, dependencies, imported dimensions/root transforms and per-stage machine rationale are retained in the inventory/evidence.

## Focused technical proof

All selected final runs below **completed with exit 0**; `final-results.json` records 22 selected engine runs and diagnostics. No script/assertion error is accepted as PASS.

| Proof | Actual completion / result |
|---|---|
| Current catalogue | `PRE_M4_CATALOGUE_COMPLETE failures=0`: 167 active, exact 35 retained + original 120 + twelve top-ups, seven retired; exact authorized mapping and 155 current human approvals |
| Physical top-up | `PRE_M4_PHYSICAL_COMPLETE candidates=12 ordinary_surface_blockers=0 failures=0`: finite nonzero bounds, unit source roots, actual loose TAKE/carry, production placement/retrieval with identity retained, actual workbench preview |
| Receiving top-up | `PRE_M4_RECEIVING_COMPLETE manifests=3 takes=12 shelf_handoffs=12 ordinary_surface_blockers=[] failures=0`: exact ordered prepared content, progressive production rays, fully OPEN TAKE, ordinary shelf store/retrieve; strict vertex seating and barrier clearance retained |
| Save / Continue | Separate `PRE_M4_CONTINUATION_COMPLETE` writer **7** / reader **18** checks, zero failures: eight controlled top-up cargo identities, remaining A cargo, last-TAKE closing, full outbound ownership, FIFO B activation, capacity 10 and Save & Exit |
| Idempotence | `PROPS_ONBOARDING_COMPLETE` dry-run **false / additions=0 / total=167** and apply **true / additions=0 / total=167**; **170 protected files / zero changed** across both passes; all source fingerprints checked |
| Retained contracts | Catalogue unit/35-source registration, review-manifest, group registry, Stage A integration and exact 35-member pool, stacking interaction, orientation, corrected relationship and external workbench roundtrip fixtures: PASS / zero failures |
| Medical/Kitchen/scenario smoke | `M3_KITCHEN_COMPLETE checks=69 failures=0`; `M3_SCHEDULE_COMPLETE checks=43 failures=0`: retained Medical/Kitchen values, twelve exact normal baskets and substitutions, contribution ownership and scheduled boundaries |
| Startup / render / import | `wing_startup_parity_tests: PASS`; `TOPUP_PREVIEW_COMPLETE candidates=12`; editor/import reaches `[ DONE ] loading_editor_layout`, exit 0 |

The exact Receiving test batches are **163/164/165/166**, **167/168/169/170**, **171/172/173/174**. All twelve reached `SM_MetalShelves_GalleryA_West_level_1` in the separate physical test, with its legitimate **0.822046 m** clearance. Receiving's original deck/profile, stances, 1.4/2.3/3.4 m loose/storage/Receiving reach, geometry, capacity and turnaround remain unchanged; no item substitutions, shrink or wider reach were used.

The existing fixtures now distinguish the **original 120** from this **top-up 12**: physical defaults to 132 and supports `--original-120` / `--topup` / `--item-id=...`; Receiving defaults to the original thirty exact four-item manifests plus three top-up manifests and supports `--original-120` / `--topup`. The original 120-item full physical/Receiving sweep and unchanged-state 21 October follow-up remain attributed to the [20–21 October record](pre-m4-catalogue-expansion-validation-2026-10-20.md), not presented as fresh runs. This task did not reproduce the old 34-run sweep.

**Rejected attempts remain separate:** initial unaccounted-source/catalogue REDs; stale 155-count assertions (including a misleading exit-0 script assertion); the first glove pose's **20.456 mm** actual seating gap versus required **6 mm**; an invalid off-tree diagnostic probe; the first continuation attempt with a missing external output directory; stale basketball-role expectation; and startup invoked without its required save-directory argument. The refined glove pose aligns its first local broad face while preserving source-node transforms and passes the original strict seating check. The basketball fixture now tests the saved human-approved resting role and an isolated duplicated definition with resting denied; no accepted definition was reverted. Corrected final runs above support PASS claims.

The known Windows certificate-store message appears in final engine runs. Catalogue unit tests deliberately emit duplicate-ID/source diagnostics for negative cases. No other final errors were found. CF-07 and pickaxe 108's co-located-LOD caveat remain the previously documented debt; this task does not resolve or expand their acceptance. One consolidated self-review was used under the handoff's one-executor rule; human physical approval is still outstanding.

## Review in the retained workbench

1. Open `res://gameplay/dev/item_storage_pose/item_storage_pose_authoring.tscn` in Godot 4.7. Select its root and load each external `loot_000163.tres` through `loot_000174.tres` into **Item Definition**, using the mapping above.
2. Review **scale → resting pose/+Z Front → Footprint → stack/support roles → Auto Group**. Keep source geometry/transforms intact. Inspect the carcass, offset gloves, carton labels/top and helmet contact especially. Packing Rotated is a separate preview of the packing turn.
3. Compare the suggested Footprint with the authored reservation. **Apply Suggested Footprint** updates width/depth; save the **external ItemDefinition `.tres`** in the Inspector. Saving only the workbench scene does not save item authoring. Reopen each saved definition to verify persistence.
4. Review real support relationships where needed; the workbench is not a complete stack simulator. Keep temporary Utility/Bulk unchanged. Report source/representation issues instead of repairing licensed art silently.

Next step: **developer physical review, subsequent reconciliation of actual saved values and explicit decisions, then separate publication authorization**. Saving a resource alone is not recorded human approval. No merge, push, PR or publication is included here.

## 24 October 2026 — human-review checkpoint and reconciliation addendum

**HUMAN .TRES AUTHORING CHECKPOINTED / REVIEW EVIDENCE RECONCILED / TARGETED TECHNICAL CHECKS RECORDED / NOT PUBLISHED.** This addendum supersedes the initial candidate's pending-review status and proposal table above; its earlier technical evidence remains historical.

**Human authority:** the developer personally reviewed all twelve additions' orientation, Footprint and stacking capability, edited as needed and saved the external definitions. Local commit **`a669c0d5c218696d9f977a505551063e0160b69f`**, directly after `e8ed1200019cd1206a303e1c9e524899d96948e3`, checkpoints all fourteen dirty files with committed SHA-256 equal to captured working-file bytes. Branch/parent matched the handoff; read-only remote `main` still matched `3bb69a906e921f06dd12c61bd4d8f33db35d6fce`. No Godot process was running at capture. Existing 081/110 changed display names only: **Watercooler Bottle / Revolver**.

The twelve saved names are **Mystery Meat Large; BBQ Charcoal Bag; Lighter Fluid Can; Water Bottle (6 L); Soda Bottle Crate; Juice Bag-in-Box; Orange Juice Jug; Water Bottle Six-Pack; Cosplay Helmet; Fedora Hat; Leather Gloves; Rubber Wellies** (163–174 in order). Actual physical changes from the proposal are 163's pose **(0.025, 0, 90)** and Footprint **13×5**, 166's **3×2**, and 168's **3×3**; other saved poses/Footprints and all twelve rest/support/group values are unchanged. Editor-authored resource UIDs are retained exactly. Every addition can rest on support; only 168 can support another item; every saved Auto Stack Group remains None.

**Approval precision:** existing `AuthoringReviewManifest` snapshot, schema, evidence and serialization machinery was used; only the affected records were transferred back to avoid reserializing old numerical evidence. Prior notes and proposal rationale remain. Under its existing contract, pose, Footprint and stack-role currency are independently provable without scale approval. The reported review supports these three stages; it does **not** establish separate human scale or Auto Group acceptance. Source fingerprints and `visual_scale=1.0` are unchanged, and observed None is recorded without approving it. No accepted definition was regenerated.

| Active review stage | Current | UNREVIEWED | Exact approved status counts |
|---|---:|---:|---|
| Scale | 155 | 12 | APPROVED 155 |
| Pose / +Z Front | 167 | 0 | DEFAULT_POSE_APPROVED 68; CUSTOM_POSE_APPROVED 99 |
| Footprint | 167 | 0 | GEOMETRY_APPROVED 118; OVERRIDE_APPROVED 49 |
| Stack role | 167 | 0 | APPROVED 167 |
| Auto Stack Group | 155 | 12 | APPROVED 155 |

The three saved Footprints are retained as **OVERRIDE_APPROVED**, with these total depth excesses (not per-edge measurements):

| Item | Saved cells | Measured depth | Depth beyond reservation |
|---|---|---:|---:|
| `loot_000163` | 13×5 | 504.583 mm | 4.583 mm |
| `loot_000166` | 3×2 | 205.401 mm | 5.401 mm |
| `loot_000168` | 3×3 | 300.418 mm | 0.418 mm |

These supersede the initial proposal's no-overhang statement. No neighboring-placement visual approval is inferred. The developer's remaining decisions are to confirm world/source scale plausibility and explicitly accept None (or identify an intended registered group) for each of 163–174. These pending decisions do not require regenerating the accepted pose/Footprint/roles. Utility **None/0**, Bulk **1**, capacity **10**, Fuel naming, and M4 remain unchanged.

**Fresh Codex technical evidence:** Godot **4.7.stable.official.5b4e0cb0f**, explicit `gl_compatibility`, serial headless processes, external APPDATA/LOCALAPPDATA. Nine selected final runs completed with **exit 0**, expected completion markers and no script/assertion errors; all engine ERROR diagnostics were the acknowledged certificate-store message.

| Focused check | Recorded result |
|---|---|
| Catalogue / review; manifest schema; group registry | `PRE_M4_CATALOGUE_COMPLETE failures=0`; exact stage counts above; manifest and registry suites PASS |
| Physical bounds / workbench / real loose TAKE / production shelf store and retrieval, all twelve | `PRE_M4_PHYSICAL_COMPLETE candidates=12 ordinary_surface_blockers=0 failures=0`; all reach registered `SM_MetalShelves_GalleryA_West_level_1`, clearance 0.822046 m. Existing strict bounds/pose checks retained. Twelve actual support-fit checks; 168 supports a retained small can through real manual placement/retrieval, rejects an oversized crate, and an automatic duplicate with None occupies a separate reservation. |
| Three exact Receiving manifests | **163/164/165/166**, **167/168/169/170**, **171/172/173/174**; `PRE_M4_RECEIVING_COMPLETE manifests=3 takes=12 shelf_handoffs=12 ordinary_surface_blockers=[] failures=0`. Ordered prepared identities, progressive production rays, fully OPEN TAKE, strict vertex seating/barrier checks and real shelf placement/retrieval; unchanged entry paths, stances, reach and deck. |
| Isolated continuation | Writer **7**, separate reader **18** checks, zero failures. Fresh run warranted because saved pose/Footprints participate in `RunSnapshot.content_fingerprint()`: exact eight cargo identities, remaining A ownership, last-TAKE closing, full outbound, FIFO B, capacity and Save & Exit preserved; incompatible content rejects. Only injected external service directories were used. |
| Onboarding dry-run and apply | Both `PROPS_ONBOARDING_COMPLETE`, **additions=0 / total=167**. Consistent exact source set and fingerprints checked first. **172 protected files / zero hash changes** across both passes: definitions, catalogue, review manifest, inventory, retirement ledger and group registry. |

**Preservation:** **167 active / seven retired / 174 accounted source models**, next reserved ID **175**. All 155 original physical definitions preserved except the two name-only edits; all 162 original inventory/review records retain physical/numerical data, fingerprints and decisions, including seven retirements (081/110 receive appended naming evidence only). All **2421 prop files**, including all 174 GLBs/textures/import sidecars, match captured working hashes. Four other worktree registrations/HEADs are unchanged. Scenes, normal manifests/scenario, the exact 35-member M3 pool and runtime/save owners were untouched. Prior M3 Kitchen/Schedule (69/43 checks) and original 120-item/155-item evidence above are reused with their original attribution, not claimed as fresh runs; the changed-fingerprint continuation is fresh. The developer's actual continuation was never accessed.

Rejected/pre-write checks are separate from the final results: catalogue expectations before reconciliation correctly reported missing scoped approvals; a whole-record normalization preflight rejected JSON integer/float representation changes, so unrelated records were retained from their originals; a raw Git/worktree byte comparison encountered existing CRLF checkout versus LF blob differences and was corrected using the captured working hashes plus content comparison. None caused a definition rewrite. One executor performed the focused final self-review; no extra independent review was initiated. **CF-07, Windows certificate-store diagnostics and pickaxe 108 co-located-LOD representation debt remain acknowledged and unresolved.**

Evidence: `C:/Users/Boschetar/.codex/attachments/pre-m4-human-reconciliation-2026-10-24`: `baseline.json`, `human-checkpoint.json`, `reconciliation.json`, `metadata-preservation.json`, individual final `.log`/`.result.json`, `final-results.json`, `physical-results.json`, `idempotence-before.json`, `idempotence-preservation.json`, `preservation-results.json` and `final-git.json`. Logs/results contain actual arguments, exit codes, completion markers and diagnostics. Full protected-file hashes remain external.

**Commit 1 exact changed-file list and SHA-256 (saved bytes = committed blobs):**

| Path | SHA-256 |
|---|---|
| `data/items/definitions/loot_000081.tres` | `fc5f4b452ba1c9672fa3ec7e0cf289ee33d4a09f6109bbc26a719d1606377967` |
| `data/items/definitions/loot_000110.tres` | `e2037529d2598933d65a9dbd18bfef35dca9e6bba429c5939dde7d1055bcdcf7` |
| `data/items/definitions/loot_000163.tres` | `eafc40973d1608a7dbd116873d518720debf85cbd76644af725ba2a9a21e3bb2` |
| `data/items/definitions/loot_000164.tres` | `4bb0e7f5d886fc6e892eb1f6ebe6bb31906284a5126e028234a78b6c90b76d20` |
| `data/items/definitions/loot_000165.tres` | `e1ce71ebf392878aeee5dec0ae9f2ffd98c10eb3526f7d1b975a673cea78fe4c` |
| `data/items/definitions/loot_000166.tres` | `bd6d4cca4af15dcb303caba7f5935467bdad0d645e926df52814091584d86622` |
| `data/items/definitions/loot_000167.tres` | `e9a6109ceab8593b02d3aaa6d3483467b7c9afa6e2eb1ad07bad863cb7720bc5` |
| `data/items/definitions/loot_000168.tres` | `d56b4d237c851ddecf3e999314a2b98b03887af943455c9ffc5fcf65763cccb9` |
| `data/items/definitions/loot_000169.tres` | `bc138deb6c43014fdb440be35a1b38ca67065fe361ab1a4a9006b3bef2bc3eb4` |
| `data/items/definitions/loot_000170.tres` | `e641d92e37b94c965d17757924e620c61dfe56a0f5f56bc729c5c286208521e6` |
| `data/items/definitions/loot_000171.tres` | `a61083e5d7d0cbf220dc598040ddfaf20986588b0913f059aaa0eb34f63b8b05` |
| `data/items/definitions/loot_000172.tres` | `dbb4060eb558ef8e2e45cc2bbf9ff3ebe069cb2357a5bd8faa4a7803e9f0d238` |
| `data/items/definitions/loot_000173.tres` | `ee559d34e9beb454f0666c6960ebd8c01dbbb97703b83e3c45d8f769802054e7` |
| `data/items/definitions/loot_000174.tres` | `814196a6196ad9cab95b4401b7a5c02ba3cc9072237284c7d9c1a416e1ee84f8` |

**Commit 2 exact changed-file list:**

- `tools/asset_pipeline/props_inventory.json`
- `tools/asset_pipeline/item_authoring_review.json`
- `tools/asset_pipeline/tests/pre_m4_catalogue_tests.gd`
- `tools/asset_pipeline/tests/pre_m4_physical_tests.gd`
- `docs/CURRENT_STATE.md`
- `docs/testing/pre-m4-catalogue-topup-validation-2026-10-24.md`

Both commits are local. Publication remains a separate developer decision; no merge, push, PR, publication, Utility/Bulk authoring, Fuel→Energy rename or M4 implementation was performed.
