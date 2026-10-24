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
