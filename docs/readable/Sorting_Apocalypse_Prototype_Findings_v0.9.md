# Sorting Apocalypse Prototype Findings v0.9

> Generated text/table extract of the same-named DOCX. Content order is retained; Word pagination, headers and text styling are not reproduced. Embedded images are linked below. Edit the master and regenerate; this is not an independently authored authority.

SORTING APOCALYPSE

PROTOTYPE FINDINGS

Technical, interaction, asset-pipeline and human-validation record

Version 0.9 | 20 September 2026

Evidence window: retained prototype history through the accepted continuing gameplay scene, default entry and F6 behavior, locker and Fuel maintenance, expanded editor-authored palette, and the completed shelf and ceiling ergonomics experiment. Historical reports retain their original evidence states; this revision consolidates current conclusions and the next bounded gates.

| Companion authority | Role |
| --- | --- |
| Preliminary GDD v0.9 | Current gameplay and scope authority. |
| Visual Design & World-Building Direction v0.6 | Current world, material, service-space and storage-installation authority; accepted in-engine spatial baseline, with final art and gameplay separate. |
| Receiving/Elevator design, 12 September 2026 | Approved subsystem contracts; physical presentation remains a separate validation gate. |

READING RULE Validated means observed in the stated prototype scope, not production-ready or balance-final. Reported tests, human gameplay results, human visual approval and unimplemented design decisions remain distinct.

Supersedes v0.8 current-status summaries. The continuing wing composition is the normal development launch, Fuel maintenance debt is resolved, the eligible palette is editor-authored in the live scene, and the shelf and ceiling comparison is completed evidence. The retained review scene and modular rack remain non-production tools. Receiving follows the storage authoring foundation and bounded ladder decision.

## Executive summary

The representative storage and content slice remains PROMOTED. The current live development palette covers every approved eligible type through direct editor-authored hosts. Fuel (loot_000015) is reconciled and eligible for correctly authored development hosts; Gloves and Pants remain blocked. The fixed twelve-host regression fixture remains separate from the accepted live arrangement.

Receiving/Elevator Stage A is implemented, reviewed, merged and technically verified: durable item identity, committed batches and snapshots, explicit 40-ID pool, seeded Bulk-budget source, profile/job/diagnostics contracts and a one-active/two-queued manager. Its 30/30 strict test result proves the data/lifecycle slice, not physical pile generation, a playable elevator or the full durable save/journal system.

Environment assets were migrated into a semantic hierarchy with no loot/HOLD relocation, then expanded to 408 imported environment GLBs. Migration passed technical checks and the developer's in-game smoke test. A first Stage-B shell subsequently passed its technical checks but failed human visual review: the metal-heavy, mismatched asset-led composition did not read as the intended repurposed underground facility.

Whole-wing construction converged through the accepted correction sequence and now continues as res://gameplay/logistics_wing/wing_gameplay.tscn, the normal development entry. The scene preserves the accepted geometry, normal player and HUD, twelve functional storage surfaces and the saved DevelopmentSetup palette. F6 remains available and default off; F7 is suppressed in this composition. Production furnishing, physical Receiving and integrated balance remain unvalidated. Current authority: GDD v0.9 and Visual Design Direction v0.6.

| Current gate | Evidence state |
| --- | --- |
| Storage/content and catalogue stress test | Historically human-validated / PROMOTE; preserve systems. Fuel is reconciled; Gloves and Pants remain excluded. |
| Receiving Stage A | Technically verified and merged; data-only lifecycle foundation complete. |
| Environment relocation | Technically verified, merged and human-validated; ignored physical asset state is local. |
| Receiving Stage B shell attempt 1 | Technical PASS under disclosed loot_000015 baseline exceptions; human visual NO-GO; do not merge composition. |
| Historical visual/world direction v0.5 + service spaces | Service rooms, open Ops landing and three boundaries are retained in current Visual Direction v0.6; the accepted in-engine layout supplies dimensions. Historical schematics are not final construction drawings. |
| Full-wing topology greybox | PROMOTED after developer round-three and Medical-tuning walkthroughs. Preserve accepted geometry and stop general correction rounds; later specific gameplay findings may justify bounded revisions. |
| Physical Stage B / Stage C / Systems MVP | Not yet passed. Physical pile/presenter work and economy-facing obligations remain pending. |
| Current storage authoring sequence | Repository/docs close-out, seeded wing integration and default entry are complete. Next: review-scene supply reuse -> reusable functional modular-rack authoring -> fixed-ladder proof -> human ladder decision -> Receiving. |

## 1. Evidence status and design authority

| Status | Meaning in this report | Examples |
| --- | --- | --- |
| Confirmed design | Explicitly accepted rule; not automatically implemented or tested. | Receiving contracts, authored-world rules, Foundation Gate and approved zone relationships. |
| Human validated | Observed by the developer in the stated gameplay/visual scope. | Storage stress and singleton fix; environment migration; accepted neutral wing and final Medical tuning. |
| Technically verified | Reported checks passed for a defined implementation and baseline. | Stage A data/snapshot/queue tests; migration tests; shell contract tests. |
| Visually rejected | Technical success did not meet human art-direction expectations. | First Receiving shell at c9752c8. |
| Provisional / unvalidated | Preferred direction or open question still needing evidence. | Physical hidden settling, furnished clearances/route balance, PBR-generated structural kit, machine unlock timing. |
| Deferred / bounded debt | Known work outside the active scope or awaiting a specific repair. | Gloves/Pants, held/HUD quality, multi-column support and physical Receiving evidence. |

### What remains authoritative in the GDD

- Sorting is the survival operation, not a minigame attached to another management layer.

- Items are physical and stateful; unrestricted floor drops and general rigid-body item worlds are out of scope.

- Bulk governs handling throughput while Footprint governs shelf occupancy; neither substitutes for the other.

- Placement must feel tactile and assisted, with mistakes caused by logistics rather than finicky collision or targeting.

- The GDD’s interaction-prototype gate is specifically to prove deterministic, no-drop 3D handling before large-scale art production.

Historical count discipline: Sections 10, 13 and 14 describe the clean 11 September authoring/gate checkpoint. Section 20 preserves the 17 September loot_000015 drift record and is superseded by the resolved maintenance result in §24.2. The 42-definition total, explicit 40-ID gameplay and Receiving pool, and blocked Gloves/Pants cases remain distinct quantities. [P04; D13B]

## 2. Art and asset-pipeline findings

### 2.1 Unreal Engine, GLB, and Godot

At the early test-room gate, direct UE static-mesh export to GLB imported into Godot with usable geometry, base materials and scale. The developer accepted the room's visual consistency for that test set. This establishes an import route, not general art-direction approval: the later Receiving composition failed visually despite healthy imports and plentiful environment assets (Section 18).

| Pipeline route | Finding | Disposition |
| --- | --- | --- |
| UE -> GLB -> Godot | Viable for straightforward import of the early tested assets. Their use in one accepted test room does not establish that arbitrary source families form a coherent production environment. | Import route validated for tested set; cross-kit art coherence requires human review. |
| UE -> FBX + source maps -> Blender -> GLB -> Godot | Deliberate cleanup/normalization route when an asset needs pivot, scale, component, geometry, normal, or material work. | Supported fallback |
| Unreal source/render mesh comparison | Useful content-import check for high-detail/Nanite-style assets; a broad final policy should not be inferred from one shelf. | Recommended per asset family |
| Raw material maps | BC/Normal/ORM-style maps are usable source material. Channel conventions must be checked, not inferred from names alone; DirectX-style normal Y inversion may be needed. | Technical note; not standardized |

### 2.2 Blender’s role

Blender successfully generated five GLB proof props through scripting: a soda can, pill bottle, cereal box, hammer, and tennis racket. Their scale survived import to Godot, and they coexisted acceptably with the UE-derived room. This demonstrates a productive hybrid art strategy, not a mandate to procedurally model all loot.

| Best role | Evidence / rationale |
| --- | --- |
| Procedural families | Cans, bottles, pill bottles, cartons, boxes, jars, packets, buckets, and standardized salvage can share geometry families and differ chiefly by dimensions, materials, and labels. |
| Sourced distinctive objects | Firearms, rackets, shoes, radios, power tools, intricate medical instruments, and identity-heavy hand tools benefit more from existing meshes than elaborate generators. |
| Variant production | A strong sourced base mesh can generate many game items through labels, material variants, and ItemDefinition data. One can or pill bottle can become many products. |
| Selective repair | Use Blender when direct GLB import has a genuine problem. It should not become compulsory friction in the environment-art pipeline. |

PRACTICAL IMPLICATION For broad loot content, the scalable unit is likely a data record plus a texture/material variant, not a fresh modelling session. Canonical dimensions should be kept alongside the visual definition so a future Footprint suggestion tool has a reliable starting point.

### 2.3 KitBash3D: licensing clarification supersedes the hold

Historical position: v0.4 kept KitBash production adoption pending written clarification of post-subscription project use. On 13 September the developer supplied a written support answer addressing that workflow. The correspondence states that work on projects created while subscribed can continue after expiry; release does not require an active subscription; assets included in those projects during the active subscription remain usable there; those Cargo files cannot then be used in other projects.

Disposition: the specific pending-clarification blocker is resolved on the basis of the supplied vendor answer. It is not a universal license interpretation and does not establish rights beyond the quoted project/incorporation conditions. Retain the original support correspondence, applicable license, subscription period and asset incorporation/acquisition records.

A focused sourcing period is now an available strategy, not a mandated purchase. The developer deferred a new subscription while evaluating already provisioned meshes and a free material sample. Do not turn “downloaded” or “bookmarked” into an assumption of incorporation, or claim a subscription/material acquisition occurred when it was only discussed. [K13]

### 2.4 Fab asset sourcing and license-record discipline

Fab free and paid packs can materially reduce content-production cost when the acquired listing is available under a usable project license and actual source/Unreal content is accessible. A tested free goods-and-supplies pack was successfully added to the user's Fab library under the Standard License and then added to the Unreal test project through the Epic/UE launcher. This establishes Fab as a practical candidate source for loot families such as cans and packaged food; it does not remove the need to retain per-asset source/license records.

- Production rule: record listing/source, publisher, acquisition date, and license state for every externally sourced production asset. Do not redistribute source assets independently from the game, and do not treat this report as legal advice or a substitute for current vendor terms.

- The KitBash-specific hold described in v0.4 is superseded by Section 2.3. Source/license records remain separate from gameplay-facing semantic asset organization. No vendor-specific dependency or entitlement is inferred from a file/folder name.

### 2.5 Canonical loot scale and transform normalization

A production loot asset should enter Godot at a plausible canonical world size with root scale approximately 1,1,1. Marketplace source scale is not gameplay data. When an imported object is obviously oversized or undersized, normalize it before production use: scale uniformly in Blender to a plausible real-world dimension, apply the scale, then export the normalized GLB.

This rule keeps mesh bounds meaningful for Footprint suggestions, held-item presentation, placement ghosts, storage fit, future thumbnail tooling, and any collision/inspection logic. Furniture may intentionally use visual scale variants; ordinary loot should generally not.

### 2.6 Skeletal clothing as static loot source

Marketplace clothing frequently arrives as Skeletal Meshes intended for humanoid rigs. Runtime skeletal deformation is unnecessary for ordinary Quartermaster loot. The tested authoring route is to repose the source garment into a compact neutral/hanging pose, freeze or convert that pose to a Static Mesh, normalize scale, and export the resulting static asset to Godot.

The source skeletal asset remains useful as an authoring source for alternate poses, but the shipped/storage representation can be static. Early tests with jackets, trousers, gloves, boots, protective vests, and similar gear showed that compact recognizable silhouettes are more valuable than realistic cloth simulation. Specialized clothing racks or mannequin-like containers remain possible future storage types, not a requirement for the current prototype.

### 2.7 KitBash PBR sample: inspected format, unproven production route

The supplied kb3d_americanneighborhoods.zip sample was inspected as source material. It contains 20 material families with 80 PNG maps under Textures/png1k (Base Color, Metallic, Normal and Roughness for each family), 20 Height EXRs under Textures/exr1k, USD material definitions, and Substance .sbs sources with .sbs/.sbsar dependencies. This is the contents of this sample, not a guarantee about every commercial kit.

The ready maps support a plausible Blender-scripted structural-kit route without making Substance processing mandatory: author simple metric walls/floors/ceilings/slabs/beams/pillars/openings, set usable pivots/UV scale, build materials, export GLB and inspect the imported Godot result. Sourced shutters, railings, cables, machinery and other irregular geometry remain useful.

Evidence limit: no new structural kit was generated from these maps in this session and no end-to-end in-game material result was validated. Map conventions, roughness, normal orientation, texture scale/repetition, optional height handling and export behavior need a focused proof. The 1K sample is enough to explore the route; required production resolution is not decided from filename resolution alone.

The layered finish language now required across the bunker makes a coherent material library potentially more important than more prefab geometry. The first shell failure exposed an art-direction/composition problem, not proof that all existing meshes are unusable. Select the source route after a small Foundation-Gate proof rather than treating either existing meshes or generated architecture as automatically sufficient. [M14; V02 §24]

## 3. Prototype Steps 1-6.3 (historical implementation sequence)

The prototype was deliberately built as a sequence of small gates. Each step answered a narrower question before the next system was attached. The status below distinguishes observed conclusions from implementation presence. Historical input/state descriptions below are not new scope commitments. Current controls and the later no-loose-world-item target take precedence where explicitly refined.

| Step | What was built | What the result established | Status |
| --- | --- | --- | --- |
| 1. Physical room and prop test | Human-scale CharacterBody3D controller; coarse runtime collision for floor, walls, shelves, lockers, crates, barrels, and major props. Blender loot imported beside environment assets. | First-person scale felt credible; simplified collision felt natural; environment and simple loot can coexist. The room can use separate visual, collision, and storage representations. | Validated |
| 2. Carried-items representation | ItemDefinition, ItemInstance, Bulk-limited carried queue, selection controls, and bottom HUD strip. Initial debug set totalled 9/10 Bulk. | A carried bundle can be legible without becoming a conventional abstract inventory. Bulk is practical for throughput and selection. | Validated |
| 2B. Visual identity experiment | Live 3D HUD previews with bounds framing, orientation heuristics, per-item rotation/zoom data, and tuning hooks. | Arbitrary assets need presentation metadata. Visual clarity was acceptable for uniform shapes, but the runtime preview architecture failed for lighting isolation. | Partially superseded |
| 3. World loot and pickup | Aim dot, contextual item data, E/left-click pickup, carried-slot filling, selected held model, dedicated loot interaction layer, and provisional item catalogue. | Only designated loot needs to be pickupable; carried selection and world removal feel responsive. Shelf contents can be targeted independently of coarse movement collision. | Validated |
| 4. Deterministic storage surface | StorageSurface grid, per-level profiles, reservations by item ID, footprint rotation, release, debug visualization, and distinct shelf interaction areas. | A shelf can be an authored deterministic data surface rather than physics. Scale-aware capacity and per-level profiling avoid treating a shelf as one AABB. | Implemented / validated in debug |
| 5. Full placement loop | World loot -> pickup -> carried strip -> selected model -> placement ghost -> exact reservation -> stored world item -> pickup/release. | The core no-rigidbody loop works and visually reads as objects arranged on a shelf. This is the most important confirmation so far. | Validated |
| 5A. Interaction and storage refinements | Separated pickup/retrieval from storage; stored-item reach uses storage interaction distance; actual placement ghost restored; shelf visual scale isolated from StorageSurface/placed items; manual placement retained as explicit precision mode. | Visual shelf variants can be scaled without distorting loot. LMB and E now support distinct muscle memory. Manual placement works, but precision targeting is slower than policy-driven storage. | Validated |
| 6.1-6.2 Storage-zone authoring | Paused flat 2D editor for one StorageSurface at a time; hidden-cell rectangular painting; General/Food/Hydration/Medical/Weapons/Protection/Fuel/Morale/Electronics categories; erase/clear; percentage feedback; allocation summary; first-use General 100%; editable surface name. | The player can author storage policy quickly without drawing directly on 3D shelf geometry. Rectangular zone editing is easy to understand, fast, and readable. | Validated |
| 6.3 Zone-aware auto-store | Primary Storage Category on ItemDefinition; E auto-stores into matching zone, then General. At the v0.2 checkpoint unassigned cells were also a fallback; later stabilization redefined blank/erased cells as disabled storage. M toggles manual placement; hold E repeats auto-store after a short delay. | Auto-placement remains decisively faster than manual sorting, especially with mixed bundles and dense shelves. The placement-policy result remains validated; the old unassigned-cell fallback is superseded. | Validated; fallback superseded |

### Controls and current interaction grammar

- Left Mouse Button: select / pick up / retrieve the loot item under the reticle. E: store / place / eventually submit the currently selected carried item.

- Mouse wheel or number keys: select a carried item. Hold E in zone-auto mode for repeated storage. M toggles manual placement. R rotates only in manual mode. O opens/reopens zoning. In the continuing wing, F6 developer grids are retained and default off; F7 is suppressed. Historical fixtures retain only their recorded debug behavior.

- The former dual-purpose interaction was rejected after playtesting. Left-hand keyboard input now expresses PUT/SUBMIT while right-hand mouse input expresses TAKE/SELECT, reducing accidental place-then-pick-up reversals.

## 4. Failures, bugs, and fixes

| Issue | Observed behavior | Resolution / lesson |
| --- | --- | --- |
| Runtime SubViewport lighting | Picking up the first item visibly brightened the room. Isolation showed both live HUD previews and held-item previews contributed; the HUD effect was stronger. | Reject the prototype implementation, not the technology categorically. The current game uses a camera-attached real mesh and temporary HUD presentation. A future release-quality pass may reconsider a fresh, rigorously isolated SubViewport approach alongside cached/offline thumbnails and authored held transforms. |
| Held-item clipping / overlap | Early viewmodel variants clipped and the held object could be obstructed by a growing HUD strip. | The final prototype uses a camera-attached visual with constrained screen layering. Per-item transform tuning remains a content task. |
| Shelf contents blocked by furniture collision | The pickup ray hit the shelf’s coarse movement collider before the stored item, making shelf loot unselectable. | Separate movement collision from dedicated loot-interaction collision. This validates visual mesh, coarse player collider, and storage/interactions as distinct layers. |
| Storage grids misaligned | Unit-wide AABB profiling left unused width, floated grids off surfaces, and misrepresented locker depth. | Profile each shelf level independently: width, depth, height, and front/back offset. Subsequent alignment is content tuning, not system surgery. |
| Rifle Footprint mismatch | The grid accepted a provisional 1 x 5 Footprint even though the visual rifle was longer, producing overlap. | Not a physics failure: Footprint must be authored to match intended occupancy. Future tooling can suggest a Footprint from mesh bounds, with override. |
| GDScript warnings-as-errors | Variant inference and a missing shared collision-layer constant stopped the project at parse time. | Use explicit types where required; maintain shared constants at the owning data class. These were implementation repairs, not design changes. |
| Scaled shelf distorted placed loot | Non-uniformly scaling a shelf also scaled child storage/loot, flattening or stretching item meshes. | StorageSurface now captures the shelf-relative world pose but operates at unit scale; placed loot preserves its own geometry. This also makes shallow shelf variants cheap to prototype. |
| Placement ghost lifecycle | An early scale-isolation refactor made the ghost and stored item invisible; a later ghost reparent path generated repeated parentless-node errors. | Restore the simple surface-local transform path, keep StorageSurface scale-isolated, and parent the ghost deterministically before reparenting. The green item silhouette now matches final placement. |
| Manual placement throughput | Rapidly storing mixed bundles required repeated visual category decisions and precise local placement; empty shelves lacked spatial category cues, while packed shelves made remaining gaps hard to judge. | Do not solve with more aiming assistance. Make zone-aware auto-placement the default and retain manual placement as an optional override/organization tool. |
| loot_000010 pickup registration | One dry-goods can could not be picked up reliably even though its authoring metadata and storage behavior were otherwise valid. | Debug separately from Auto Group authoring. The pickup-registration defect was fixed, regression-tested, and manually validated in game before the catalogue-scale stacking gate. |
| Singleton shelf vertical clearance | Automatic and manual empty placement could accept sufficiently tall standalone items whose seated visual penetrated the shelf or fixture above. Stack placement already rejected equivalent over-clearance cases. | Empty placement now uses a shared physical-clearance predicate based on the authoritative seated posed top and revalidates at commit. Singletons use physical clearance only; the separate 95 percent gameplay-headroom rule remains stack-specific. Human auto/manual validation passed. |
| Godot test false-PASS hazard | Stage A found helper errors could occur even when a harness eventually printed PASS or returned an apparently successful result. | Six focused harnesses were hardened; reported final evidence checks PASS/error output as well as exit status. Do not infer historical-suite failure merely because the hazard was found. |
| Receiving shell visual failure | Healthy imports, contract tests and a render produced a metal-heavy, mismatched composition. | Human NO-GO; no merge. Define world/art authority and independent shell/finish reviews rather than patching appearance with more props or warm light. |
| loot_000015 texture-driven reimport | Developer reimported Fuel Canister before Pass 1; fingerprint/pose-dependent assertions drifted. | Bounded debt at that checkpoint, not a new design decision. The later maintenance pass preserved the intended metadata and completed the reconciliation recorded in §24.2. |

## 5. Playtesting observations and conclusions

| Observation | Interpretation | Design consequence |
| --- | --- | --- |
| Coarse collision felt natural; plausible gaps remained passable. | Players accept collision simpler than visual geometry when it respects perceived object footprint. | Keep collision authored for movement ergonomics, not mesh literalism. |
| Selected held model, pickup feedback, and carried-slot changes read clearly with no noticeable performance issue in the small test. | The item-state loop is readable in first person. | Retain one source visual asset across world, held, and future thumbnail contexts. |
| Irregular objects were hard to identify in live thumbnails without a good angle. | Presentation is an asset-authoring problem, not something to solve with endlessly rotating thumbnails. | Keep optional per-item preview/held transforms and a future tuning tool. |
| High shelves and deep storage are awkward from a standing camera. | Reachability is not only collision. A small object can be physically valid but visually occluded. | Prefer accessible furniture geometry and test interaction proxies/range before traversal features. |
| Rapidly storing 5-6 items caused repeated place/pickup errors. | Grid precision and shared interaction meaning become friction at actual sorting speed. | Test assisted/automatic storage and a separate retrieve input. |
| Small items can be hidden behind tall or wide items on deep shelves. | Aim forgiveness, crouching, or a stool cannot reveal a fully occluded item. | Treat deep open shelving as a structural readability risk; one-depth usable surfaces are the leading mitigation. |
| Rectangular zone editing remained easy to use after repeated passes. | A flat modal representation of one shelf surface avoids the precision and perspective problems of drawing directly on world geometry. | Freeze the zoning authoring slice for prototype purposes; further visual polish is not a prototype priority. |
| Auto-placement was much faster than manual placement for 10-item mixed baskets. | The meaningful Quartermaster skill is deciding where categories belong, not remembering the exact local coordinates for each bean can, pill bottle, pistol, and drink. | Zone-auto placement becomes the current default interaction direction; manual mode remains available for exceptions and exact arrangements. |
| Holding E with a short repeat interval felt significantly better than repeated presses. | A well-organized shelf should convert planning into visible operational throughput. | Retain continuous E auto-store. Current 0.25 s initial delay / 0.12 s repeat are good prototype defaults and remain tuning handles. |
| Shelves can be visually rescaled to create shallow variants while stored loot keeps correct proportions. | Visual furniture geometry and gameplay storage geometry should remain separable. | Use cheap visual variants for prototype depth tests; make dedicated Blender variants only when visual deformation itself becomes objectionable. |

## 6. Storage-zone direction: validated prototype result

VALIDATED DIRECTION The player should author storage policy rather than manually target every ordinary item. Category zones plus automatic placement preserve the Quartermaster fantasy while removing precision friction. Manual placement remains an explicit override, not the default burden.

A zone is implemented as category metadata over hidden deterministic cells on one StorageSurface. The player edits zones through a paused flat UI rather than directly on shelf geometry. Each item has one primary Storage Category for storage policy even if it can provide different Utility at different destinations. Existing physical items do not teleport when zones are redrawn; zones steer future automatic placement.

| Candidate rule | Rationale | Evidence status |
| --- | --- | --- |
| Zones are snapped rectangles on one storage surface. | Matches the existing deterministic grid while keeping cell boundaries hidden from the player. | Validated |
| Auto-placement searches matching category -> General and stops; it never uses a different specific category or a blank/erased cell. | The v0.2 unassigned-cell fallback was superseded after stacking stabilization. General is the forgiving universal zone; blank/erased means deliberately disabled storage. | Validated; supersedes v0.2 fallback |
| Manual placement may ignore category zoning but cannot use disabled/erased cells. | Manual mode remains the Quartermaster's deliberate exception path without making No Zone synonymous with General. | Validated; refined after stacking stabilization |
| One cell belongs to zero or one zone. | Avoids priority ambiguity and makes rectangle repainting predictable. | Validated |
| Resizing, clearing, or recategorizing zones does not move existing items. | Zones guide future placement rather than performing magical cleanup. | Validated |
| Deterministic single-column support stacking provides vertical density; whether ordinary open shelves should also default to one shallow usable depth remains a separate furniture/readability question. | Representative content showed that vertical stacking solves much of the apparent wasted-height problem without a volumetric grid. Deep-shelf occlusion remains a distinct world-design risk. | Stacking validated; one-depth default still tentative |
| Untouched shelf surfaces initialize to General 100% on their first zoning interaction. | Players are introduced to zoning instead of receiving invisible automatic behavior they never authored. Clearing zones later does not re-trigger first-use initialization. | Validated |
| Default zone-auto mode shows no placement grid or green ghost; manual mode carries precision/debug presentation. | Trying to serve both workflows simultaneously created visual clutter and worse ergonomics. | Validated |
| Holding E repeatedly stores the current/next carried items using zoning policy. | Turns good organization into tactile throughput and reduces repetitive keypresses. | Validated |

### Why this remains compatible with the GDD

GDD v0.9 retains the zoning rules promoted in the earlier storage gate. The representative catalogue evidence supports preserving that policy; service-space, greybox and continuing-wing updates do not reopen storage mechanics.

## 7. Validated assumptions and unresolved questions

| Area | Current conclusion | Required next evidence |
| --- | --- | --- |
| Deterministic no-drop handling | Human-validated across the 40 eligible items within the 42-definition catalogue and the 14-scenario gate. No claim that Gloves/Pants passed gameplay eligibility. | Preserve regressions; reuse the review-scene supply setup and validate new furniture contexts rather than reinvent handling. |
| Shelf geometry | Per-level profiles and scale-isolated StorageSurfaces are workable. Closed/intermediate stack clearance is derived from adjacent authored shelf planes and Y scale; open-top clearance is explicitly authored per placed instance. Standalone empty placement now also rejects items whose authoritative seated posed top exceeds the surface physical clearance. | Approved visual direction favors shallow wall-fitted shelves and deeper multi-sided units. Exact depth/height and top-level visibility still require first-person tests; no universal one-item-depth rule is imposed. |
| Crouch / ladders | Crouch remains deferred. One fixed shelf-serving ladder is approved for a bounded proof; this does not approve general climbing, jumping, movable or sliding ladders, animation, visible hands or fall systems. | Run the single-rack fixed-ladder proof after reusable modular-rack authoring, then obtain the human ladder decision. Reassess crouch only if later evidence shows a specific low-shelf inspection problem. |
| Auto-placement / zones | Validated as the current direction, including catalogue-scale stacking and zone behavior. Exact item Storage Categories are Food, Hydration, Medical, Weapons, Protection, Fuel, Morale, and Electronics. General is a universal zone, not an item category; erased cells are disabled. | Observe category throughput, saturation, and player-authored organization under future random Receiving batches and timed system demands. No zoning redesign is currently indicated. |
| Asset authoring scale | Loot authoring/import pipeline remains viable. Environment relocation passed; 408 GLBs were inspected. KitBash support clarification is recorded, and a ready-map material sample was inspected. | Prove material coherence under the new visual authority. PBR/generated structural kit is available as a candidate, not validated production output. |
| Thumbnail presentation | The early live-preview implementation failed lighting isolation. Prototype held meshes/HUD remain temporary; SubViewport technology itself is not prohibited. | Defer offline/editor thumbnail baking until it blocks content readability or a later production-art pass. |
| Footprint authoring | The 11 September checkpoint approved 42 scales and 40 pose/Footprint/Stack Role/Auto Group decisions. Fuel's later reimport drift is reconciled and current; Gloves and Pants remain separate source/pose blocks. | Maintain the dependency chain Scale -> Storage Pose -> Footprint -> Stack Role -> Auto Group as content expands; downstream approval must still become stale when relevant upstream evidence changes. |
| Full game systems | Stage A data/lifecycle is complete. Neutral wing spatial gate is promoted. Physical Receiving, timed obligations, economy and full-system saves remain unvalidated. | Review-scene supply reuse -> reusable functional modular-rack authoring -> fixed-ladder proof -> human ladder decision -> functional Receiving, then timed obligations. Preserve storage mechanics and known debt. |
| Local AI / Godot integration | Local Codex access to the authoritative Windows Godot project, ignored assets/, .godot import state, and direct Godot CLI is established. The online GitHub repository is useful supplementary context but is not asset/import authority. | Continue asset-sensitive inspection and validation against the authoritative local project; use GitHub for tracked source/history and independent review where appropriate. |
| Deterministic support stacking | Promoted after the representative 14-scenario catalogue-scale gate: authored support roles, four strict Auto Groups, stack-first placement, smart insertion, auto-only base promotion, 95% stack headroom, visible-member retrieval, deterministic compression, reservation shrink/expand, and representative manual mixed stacking all passed mechanically and predictably. | Reopen only if materially expanded content or future system pressure exposes a specific failure. Mixed/non-auto-coherent auto behavior, manual under-base insertion, and multi-column support packing remain intentionally unchanged/deferred. |
| Human validation handoffs | A repo-local /docs/testing playtest handoff is now the standard delivery whenever player-facing evidence is required. The deterministic-support, catalogue-scale, pickup, and singleton-clearance gates all preserved automated correctness separately from human evidence. | Continue scaling evidence burden to task impact and require explicit promote/revise/reject questions for architectural gameplay gates. |
| Environment validation | Human-PROMOTED neutral wing after correction rounds and final Medical-only tuning. Supervised authoring feasibility and isolated revision demonstrated; art quality not established. | Use accepted geometry and the completed continuing gameplay integration. Test review-scene supply reuse, reusable rack authoring and bounded ladder interaction, not another abstract full-wing geometry gate. |

## 8. v0.2 recommended next prototype slice (historical checkpoint)

This slice has now been substantially completed or superseded. The mesh-bounds audit, persistent catalogue, pose/Footprint review, representative-content test, Auto Group authoring, catalogue-scale stacking gate, and subsequent singleton-clearance stabilization all progressed after v0.2. Sections 13-14 record the current validated state and prototype closure.

1.  Establish a local ChatGPT/Codex development session with direct access to the working repository and Godot project, using GDD v0.3 and Prototype Findings v0.2 as the context bootstrap. Prefer local filesystem/CLI access and add MCP-style Godot integration only where it materially improves inspection or execution.

1.  Build a temporary bounds/catalogue utility that enumerates loot assets actually used in main.tscn, measures aggregate imported mesh bounds in Godot, records source path/category, and produces raw Footprint suggestions from the current storage-cell scale.

1.  Review the suggestions rather than accepting them blindly. Apply storage-oriented rotation, safety padding, and authored overrides for long or irregular items such as rifles, paired boots, clothing, firewood, fuel containers, helmets, electronics, and the pig carcass.

1.  Bring the representative prototype catalogue to at least two items in every Storage Category and roughly 20-30+ meaningful unique assets. Normalize source scale before Footprint authoring and preserve license/source metadata for externally sourced production candidates.

1.  Run repeated mixed-basket and dense-shelf stress tests using zone-auto placement and hold-E throughput. Observe packing fragmentation, automatic 90-degree rotation, General/unassigned fallback, zone saturation, retrieval visibility, category recognition, and whether auto-placement remains trustworthy with all categories represented.

1.  Only after representative-content testing, decide whether ordinary open shelving should default to shallow/one-depth usable surfaces with vertical stacking, whether retrieval needs shelf-cell assistance, and whether crouch adds enough value to justify implementation. Do not spend prototype time on further zone-editor polish unless it blocks testing.

DECISION CHECKPOINT The storage-policy hypothesis has now passed its first dedicated test: category zones plus automatic placement are materially faster and more legible than precision manual placement, while manual mode preserves direct control. The next question is whether that result survives representative content: dozens of categories/shapes, geometry-informed Footprints, dense shelves, mixed baskets, and retrieval under clutter.

## 9. v0.2 implementation snapshot (historical)

### Current interaction grammar

- Left Mouse Button = TAKE: select / pick up / retrieve the item under the reticle.

- E = PUT: store / place and, by design direction, submit to facilities. In zone-auto mode E uses storage policy; holding E repeats after a short delay.

- M toggles manual placement. At the v0.2 checkpoint manual mode ignored category zones; later evidence refined this so manual mode may ignore category restrictions but cannot use deliberately disabled/erased cells.

- O opens the zoning editor explicitly. First E on an untouched auto-mode shelf opens zoning once and initializes that surface to General 100%.

- Zoning edits one shelf surface at a time through a paused flat UI. Rectangles are snapped to hidden cells; the player sees category colors and percentages, not cell counts.

### Current production/content snapshot

- The v0.2 scene contained dozens of candidate loot props across Food, Hydration, Medical, Weapons, Protection, Fuel, Morale, and Electronics. General/miscellaneous was used informally at that checkpoint; later authoring clarified that General is a zone type only, never an item Storage Category.

- The repository intentionally ignores the binary assets/ folder and .godot data. This makes remote repository inspection insufficient for mesh-bound and import-state tooling, motivating a local ChatGPT/Codex session with direct project access.

- Source assets should be normalized before production use: plausible real-world dimensions, root scale near 1,1,1, stable orientation, and a retained source/license record. Skeletal clothing should normally be reposed/frozen into static loot unless runtime deformation is genuinely required.

### Frozen prototype decisions for the next slice

- Do not add new storage interaction mechanics while footprint/content stress testing is underway.

- Do not spend prototype time polishing the zoning editor, held-item presentation, or HUD thumbnails unless a defect blocks the stress test.

- Zone-auto placement is the default test condition. Manual placement is a comparison/override mode, not the baseline throughput workflow.

- One-depth shelving, crouch, specialized racks, and retrieval proxies remained later validation items at v0.2. Vertical stacking has since passed its dedicated prototype gate.

## 10. Representative-content and scalable authoring findings

### 10.1 Persistent catalogue and audit pipeline

The prototype now uses a persistent Godot-native item catalogue rather than hard-coded prototype path branches. Forty-two unique loot definitions use opaque stable item IDs independent of filename and display name. A reusable schema-1.3 loot audit measures imported contributor bounds, canonical and posed geometry, raw Footprint suggestions, transform health, category-folder hints, and authoring anomalies without treating folder placement as gameplay authority.

A durable item-authoring review manifest tracks scale, storage pose, Footprint, Stack Role, and Auto Group decisions separately from gameplay data. Normal audits remain read-only; explicit seed/sync/apply tools change durable review state. This separation proved scalable and prevents tooling from silently turning suggestions into design authority.

### 10.2 Scale, storage pose and Footprint: 11 September checkpoint

- Canonical scale review is complete: 42/42 items are approved/current. Marketplace/source scale is not gameplay data.

- Storage pose is approved for 40/42 items. Gloves and Pants remain blocked because their current source meshes do not yet provide acceptable ordinary-shelf poses.

- Footprint is approved/current for the same 40/42 items: 28 geometry-approved and 12 deliberate overrides at the close of the Footprint gate.

- The storage model is a 2D surface reservation pretending to be 3D, not volumetric voxel packing. Bulk, Footprint, posed height, and stack support are separate authored concerns.

The successful dependency order is now explicit: Scale -> Storage Pose -> Footprint -> Stack Role -> Auto Group. A downstream approval becomes stale when a geometry-dependent upstream decision changes.

These approval counts describe the historical close of authoring, not the post-reimport current state. Section 20 records the later Fuel Canister drift without invalidating the completed architecture evidence.

### 10.3 Stack Role authoring: completed checkpoint

Stack Role is judged against the current approved stored pose and centered runtime model, not against abstract real-world possibility. The authoring rubric asks separately whether an item can plausibly rest on a sufficiently large support and whether it can plausibly support a smaller centered item. The representative eligible catalogue is complete: 40/40 Stack Roles are approved/current; Gloves and Pants remain blocked.

Pose choices may intentionally consider downstream stack usefulness, visual clarity, and physical credibility, but pose is still approved before Stack Role. The hammer/rifle review demonstrated why: a different pose can materially change whether stacking reads as physically plausible.

## 11. Storage-zone semantic revision

The zoning model was refined after v0.2. Item Storage Category is separate from Utility and has exactly eight values: Food, Hydration, Medical, Weapons, Protection, Fuel, Morale, and Electronics. General is not an item category; it is a universal storage-zone type.

- A zoned cell is either one specific category, General, or blank/erased. Blank/erased means disabled storage and accepts no item.

- Automatic placement searches the matching specific category, then General, and stops. It never uses a mismatched specific zone or disabled cell.

- Within an automatic tier, compatible stacks are preferred before empty placement.

- Manual placement may ignore category mismatch, but deliberately disabled/erased cells remain unavailable.

- Untouched surfaces initialize to General 100% only when the player first enters zoning. Later clearing does not restore General implicitly.

- Player-authored labels/surface names remain identification aids; Storage Zones are separate mechanical placement policy.

- The paused zoning editor is an intentional exception to the ordinary no-pause interface rule because it is modal and cannot advance world state or create a timing exploit.

## 12. Deterministic support-stacking findings

### 12.1 Validated stack model

The dedicated stacking gate validated a deterministic single-column support model without rigid-body physics. A stack is one base 2D reservation plus an ordered vertical list of physical WorldItems. Each item authors whether it may sit on another support, whether it may support another item, and one optional strict automatic compatibility group.

- Automatic placement is stack-first within the active zone tier. Compatible group members may smart-insert at the highest valid position without reordering or rotating existing members.

- Automatic base promotion is validated: a larger compatible incoming item may become the new base if the expanded reservation is valid. Manual under-base insertion remains deferred.

- Manual placement can create broader mixed stacks on the current top when support role, Footprint, orientation, and clearance permit; this is an intentional min-maxing tool rather than the default workflow.

- Any visible member may be retrieved. Top removal leaves lower items untouched; middle/base removal recompresses deterministically without falling physics, and base removal shrinks the reservation.

- Stack height uses a centralized 95% usable-height rule. Closed shelf levels derive physical clearance from adjacent authored shelf planes and Y scale; open-top levels use explicit per-instance world-context caps.

### 12.2 Human playtest conclusions

Playtesting found vertical stacks visually convincing rather than glued, floating, or chaotic. Book/CD and can stacks read naturally; stack-first auto-placement did not feel heavy-handed; smart insertion felt helpful; specific-member retrieval and compression felt smooth; and the system materially improved storage density while preserving visibility and item variation.

Manual mixed stacking created a useful effort-for-density tradeoff. Players can exploit spare headroom or unusual shapes for deliberate combinations without making mixed stacks the expected default. This adds a storage-efficiency lever: neat stackable forms can become valuable because of space ROI, while high-Utility irregular items may remain intentionally awkward.

### 12.3 Stabilization findings and open questions

A base-removal defect exposed a critical ownership invariant: when stack ownership changes, stack key, reservation owner, occupied-cell owner, lookup mappings, and surviving WorldItem metadata must transition atomically. The shared root cause was fixed and manually revalidated. Manual targeted-stack orientation now tries the player's preferred orientation and then the allowed 90-degree alternative without mutating persistent R preference.

- Mixed/non-auto-coherent stacks still reject automatic placement and smart insertion. The representative catalogue stress test found the manual-only / automatic-group distinction understandable in its tested cases, so the current rule is retained. Reconsider it only if later content or system evidence makes the distinction unpredictable.

- Manual under-base insertion remains deferred pending larger-scale playtesting.

- Multi-column/top-surface packing (for example many 1x1 items on one 5x5 support) is a separate architecture and is not implied by the validated linear-stack model.

- Very thin items may create targeting/occlusion problems; this is primarily a content/model selection issue and must be tested when such items enter the catalogue.

## 13. Validation delivery standard and completed interaction/content gate

### 13.1 Human validation handoff as a delivery artifact

The deterministic-support-stacking playtest document established a useful standard: when an update needs player-facing evidence, implementation delivery should include a reproducible /docs/testing handoff. The evidence burden scales with scope: narrow bug fixes need a short reproduction/fixed-path/regression check, while architectural gameplay gates require setup, isolated scenarios, expected observations, negative cases, regressions, and explicit promote/revise/reject questions.

Automated correctness and human playability evidence must remain distinct. The architecture/planning pass defines high-level evidence goals; Codex translates them into repo-specific steps and may add implementation-specific cases.

### 13.2 Readiness at the completed 11 September gate

- Scale: 42/42 approved/current.

- Storage Pose: 40/42 approved/current; Gloves and Pants remain blocked pending deliberate source/pose work.

- Footprint: 40/42 approved/current; Gloves and Pants remain blocked by unresolved Storage Pose.

- Stack Role: 40/40 eligible approved/current; Gloves and Pants remain dependency-blocked.

- Auto Group: 40/40 eligible approved/current. The controlled registry remains exactly four approved classes: boxed_food, flat_media, medical_boxes, and round_cans; explicit None is used for items that should not combine automatically.

- The loot_000010 pickup-registration defect was fixed separately, regression-tested, and human-validated before the formal catalogue-scale gate.

The formal catalogue-scale deterministic-stacking gate is complete and recorded as PROMOTE: 14/14 scenarios passed mechanically and all 14 predictability judgments were expected. A separate singleton empty-placement vertical-clearance defect discovered during that gate was then fixed and human-validated. The representative interaction/content storage slice is therefore complete; future prototype work can move into Receiving/Elevator and Systems-MVP domains without adding more storage mechanics by default.

Historical status qualifier: at the 13 September checkpoint, the content architecture remained promoted while loot_000015 still required an evidence refresh. Stage A was complete and the Stage-B shell described below was visually rejected. Section 24.2 records the later Fuel resolution; this section is not the latest milestone list.

## 14. Post-v0.3 catalogue validation and stabilization

### 14.1 Auto Group authoring completion

Auto Group review was completed for all 40 eligible items using the controlled mutually exclusive registry. The 31 items that remained after Stack Role authoring were reviewed against their approved pose, Footprint, and Stack Role: five were assigned to existing approved groups and 26 were deliberately approved as explicit None. No new registry class and no HOLD case was required.

The newly approved memberships were loot_000007 -> boxed_food and loot_000008, loot_000010, loot_000022, and loot_000023 -> round_cans. The registry remained boxed_food, flat_media, medical_boxes, and round_cans. Human approval was persisted through the established authoring workflow, leaving Auto Group at 40/40 eligible approved/current with zero unreviewed and zero stale records; Gloves and Pants remain blocked upstream.

### 14.2 loot_000010 pickup repair and baseline regression

The known loot_000010 pickup defect was kept separate from Auto Group authoring, repaired as a focused interaction bug, and manually validated in game. A subsequent storage/stacking baseline regression gate passed before catalogue-scale testing, covering pickup/carry/store/retrieve/re-store, zoning priorities and disabled cells, automatic/manual stacking, smart insertion, base promotion, orientation, visible-member retrieval, atomic base rekeying/reservation shrink, final cleanup, derived/authored clearance, and the centralized 95 percent stack boundary.

### 14.3 Formal catalogue-scale deterministic-stacking gate

The formal gate used a stratified 14-scenario human gameplay matrix rather than exhaustive pairwise testing. It covered every approved Auto Group, every physical Stack Role pattern present in the eligible catalogue, specific-category and General zones, cross-category can stacking, native/90-degree orientation, smart insertion, auto-only base promotion, blocked expansion, carry-order sensitivity, representative manual mixed stacks, top/middle/base retrieval, clearance boundaries, and dense/occluding cases.

Result: 14/14 scenarios passed mechanically and all 14 predictability judgments were expected. The four Auto Groups remained accepted with no authoring revision. Dimensional variation inside round_cans remained readable; dense can stacks retained sightlines; the largest visible 1x1 manual relationships such as Milk Carton on Soda Can were somewhat awkward but not sufficient evidence for a Footprint/Stack Role redesign. One cereal-box scenario was corrected because the existing enclosed fixture did not physically permit the originally requested three-box stack.

Decision: PROMOTE. The current deterministic single-column support-stacking architecture is gameplay-validated for the representative catalogue scope. Mixed/non-auto-coherent automatic behavior remains unchanged; manual under-base insertion remains deferred; multi-column/top-surface packing remains outside the validated architecture.

### 14.4 Singleton shelf vertical-clearance follow-up

The catalogue stress pass exposed a separate defect: automatic and manual empty placement checked horizontal footprint/occupancy but did not compare a singleton's authoritative seated posed top against StorageSurface physical clearance. Tall items could therefore penetrate the shelf or fixture above even though stack insertion correctly rejected equivalent over-clearance states.

The fix added one shared singleton physical-clearance predicate on StorageSurface, reused by automatic and manual empty-fit selection and revalidated during commit. It evaluates the final seated posed top using aligned bounds and the existing numeric tolerance. Singleton placement obeys physical clearance only; it does not inherit the stack-specific 95 percent gameplay-headroom factor. Stack behavior, Auto Groups, Stack Roles, promotion, authored metadata, and shelf profiles were unchanged.

Regression evidence distinguished valid and invalid singletons and included a nontrivial posed-bounds case to prevent height-only reconstruction. SM_ventilated_locker2 was confirmed to be physically enclosed, with its highest storage level remaining an interior surface; no exterior top storage grid was added. Automated verification passed and the resulting auto/manual behavior was then validated successfully in game.

### 14.5 Representative interaction/content prototype closure

The storage/content prototype has now answered its primary architecture questions: constrained no-drop item handling can feel physical; player-authored zoning can convert organization into throughput; a persistent catalogue and review manifest can scale content decisions; deterministic single-column stacking can create useful vertical density without physics; strict player-predictable automatic groups can coexist with broader manual stacking; and both stack and singleton vertical fit can remain deterministic and visually credible.

At this historical checkpoint, Gloves/Pants source work, held/HUD presentation, deep-shelf readability, crouch, specialist racks, thin-item targeting and deferred stack extensions remained separate work. The later world pass chose shallow wall-fitted storage plus selective multi-sided deeper units, while keeping exact metrics empirical. Receiving/Elevator became the next approved roadmap slice; its subsequent results are recorded in Sections 15-20.

DECISION CHECKPOINT The representative interaction/content storage slice is complete. The current evidence supports preserving the validated storage architecture and moving the next prototype work into dynamic Receiving/Elevator inflow and Systems-MVP survival obligations rather than adding more storage mechanics by default.

## 15. Post-11 September chronology and evidence boundaries

This revision preserves the earlier storage history and adds the following reported results. Commits identify evidence anchors; they are not a claim that the remote/local HEAD was freshly inspected for this document. Source IDs are resolved in Section 21.

| Date / event | Evidence and decision |
| --- | --- |
| 11 September: content closure | Auto Group completion, loot_000010 fix, 14-scenario catalogue PROMOTE, singleton clearance repair/human validation retained from v0.4. |
| 12 September: Receiving design and Stage A | Architecture/spec approved and deployed; data/lifecycle implementation completed, independently reviewed, merged and synchronized. |
| 12-13 September: environment normalization | Read-only inventory, approved path map, explicit duplicate retirement, manifest-driven migration and human smoke test. Later library expanded to 408 environment GLBs. |
| 13 September: first Stage-B shell | Asset preflight GO led to authored shell c9752c8. Technical contracts passed with documented pre-existing canister drift; human rejected the visual composition. |
| 13-14 September: world/art pass | Approved construction history, material/wear/lighting grammar, room production gates and all major zone relationships. |
| 14 September: Visual Direction v0.2 | Consolidated authority document drafted without a final schematic; developer continues layout sketches. |
| 15 September: topology/layout pass | Three concept families were compared and refined into an approved logistics-wing topology. Five Storage galleries, C<->D loop, service/inhabited branches, dog-legged Deeper-Bunker Approach, Bunker Ops/deeper-settlement separation and open-threshold policy were locked as the greybox baseline. |
| 15 September: Visual Direction v0.3 / schematics | Visual authority updated with the topology refinements and two complementary artifacts: Detailed Topology V3 (not to scale) and Basic Structural Schematic V2 (approximate wall/opening reference). No Godot greybox or new gameplay implementation is asserted. |
| 16 September: first full-wing delivery | Codex reported a complete separate greybox, 33/33 non-hanging scripts and 17 routes / 7 boundaries. Report verified through 7ba27a5; final handoff d81783f is user-reported. [W16] |
| 16 September: human/source review | Developer walked the wing and requested refinement. Archived evidence and source review identify geometry/fidelity defects; no new Godot run was performed here. [H16, S16] |
| 16 September: service-space approval | Dedicated Workshop/Kitchen service rooms, Medical Supply Anteroom and open Ops Transfer Landing approved, with distinct footprint character and three boundaries. Furnishing and delivery details deferred. [D16S] |

### 15.1 What the handoff must not imply

The old September 11 Auto Group next task is obsolete. Receiving Stage A does not prove physical piles or full save durability. The first Receiving shell remains visually rejected. The first-wing REVISE checkpoint is retained in Section 22; subsequent correction rounds and final Medical acceptance promote the neutral working spatial baseline in Section 23. [W17, H17, A17]

Architecture approval, implementation, technical verification, human spatial approval and production-workflow feasibility remain separate evidence classes. Corrected service spaces, openings and dimensions now exist and are human-accepted at neutral greybox fidelity; they do not prove furnished gameplay, physical Receiving or final route balance. [A17, D17B]

## 16. Receiving/Elevator architecture and Stage A results

### 16.1 Why Receiving precedes the wider Systems MVP

The systems roadmap remains Receiving/Elevator -> first real timed request -> expedition-produced batches -> broader Systems MVP. Bookkeeping, seeded wing integration and default entry are complete. Before physical Receiving, the current sequence is review-scene supply reuse, reusable functional modular-rack authoring, the fixed-ladder proof and the human ladder decision. The prototype source does not decide final expedition rewards. [R12 §§1-7; D12; D17B]

### 16.2 Approved subsystem separation

| Responsibility | Boundary |
| --- | --- |
| ItemDefinition / authoring manifest | Gameplay type truth versus authoring/evidence truth. No runtime eligibility query into the review manifest. |
| PrototypeLootPool / source | Explicit 40 eligible IDs, excluding Gloves/Pants; seeded Bulk-budget content. Future persistent loot tables can replace policy without changing Receiving. |
| LootBatch / entries | One durable identity per physical item; immutable content commitment; accepted local transforms and profile revision committed separately. |
| ReceivingManager | One active deposited batch plus two FIFO queued. Prepared undelivered content consumes no capacity. Deposits, release accounting and retirement/promotion are data ownership. |
| FreightBayPresenter | Separate arrival/reveal/open/close sequencing, shutter, cues, materialization and interaction gating; not yet physically validated. |
| Preparation job/profile | Isolated transient proxy work and shared geometry/validation contract; not a live-bay rigid-body subsystem. |

The preparation lifecycle is CONTENT_COMMITTED -> PREPARED. Same seed/config/Bulk repeats ordered content; a new commitment gets new batch/item identities. Reconstruction preserves existing identities. Retry changes arrangement only; revealed remaining transforms cannot be casually regenerated. [R12 §§5-6]

### 16.3 Implemented Stage A and technical evidence

Stage A was reported complete on codex/receiving-elevator-stage-a at 41415a4, then fast-forward merged and synchronized with all 14 commits preserved. The exact reported integrated SHA is 41415a4dbf204c9187874fd40f421183939d60f7. The record is docs/testing/receiving-elevator-stage-a-validation.md. [D12A]

| Delivered / checked | Reported result |
| --- | --- |
| Durable ItemInstance identity | Externally supplied IDs and snapshot reconstruction; repeated same-seed new batches do not collide in identity space. |
| Batch content / arrangement | Per-item entries, immutable content, atomic preparation commitment and snapshot/reconstruction contracts. |
| Pool and seeded source | 40-ID pool, blocked definitions excluded, catalogue resolution and deterministic Bulk-driven generation. |
| Profile / job / diagnostics | Schemas and preparation-work contracts; no physical settling implementation required. |
| Receiving lifecycle | One active + two queued, deposits/rejections, ownership/drain accounting and undeployed prepared-batch distinction. |
| Tests / audit | 30/30 strict suites; 42-asset audit with only Gloves/Pants blocked at that checkpoint; parser/diff/clean-tree checks. |
| Review / integration | Final review findings fixed/re-reviewed; post-merge integration suite, parser and diff checks passed; local main and origin matched. |

The task took approximately three hours and used 22 sub-agents according to the developer. This is an execution observation, not a required staffing pattern. Future tasks should keep review overhead proportional to change risk.

### 16.4 Rulings and test-infrastructure lesson

- An in-place feature branch retained authoritative ignored assets/import state instead of creating an asset-blind worktree.

- LootBatch.is_drained() was added when the manager required it; empty fresh batches and already-drained deposits are rejected to avoid dead Receiving states.

- Six focused harnesses were hardened after demonstrating that helper errors could produce false apparent passes. Final validation required explicit PASS plus error-output checks, not only exit 0.

- The recurring certificate-store diagnostic was treated as unchanged Windows host noise; no claim that the host TLS issue was repaired.

- The implementation plan was amended to record corrections; the validation report is the evidence of what actually ran.

### 16.5 What Stage A did not establish

No freight-bay gameplay, physical disorderly pile, actual hidden settle, drainability ray simulation, fallback quality, shutter/cue sequence, local Receiving reach or end-to-end TAKE presentation was implemented by Stage A. No full-game save slot, rotating snapshot store, durable transaction journal or crash-injection guarantee follows from serializable data contracts. Those remain separately tested work.

### 16.6 Approved physical and future-integration contract

Stage B will present one manually/debug-triggered batch behind a permanent barrier and shutter. The deck/walls remain static. Isolated simplified rigid bodies create a candidate pile; bounded retry and deterministic fallback preserve content. Destroy proxies and reconstruct ordinary WorldItems with their accepted orientations. Pickup is enabled only when OPEN; taking one item does not re-settle the others.

Conservative progressive drainability is the initial acceptance test: iterate targetable entries from authored apron viewpoints, remove them virtually and reject a deadlock. Log attempts, rejection reasons, fallback share and preparation duration. A generalized reachability solver or hard fallback percentage is not yet justified.

Stage C then enables physical one-active/two-queued pressure. Future expeditions may prepare immutable outcomes before return only after player influence ends; backend preparation consumes no slots. This supersedes the old GDD three-batches-in-existence / never-generated-forfeit wording while retaining capacity pressure and midnight haul loss. [R12 §§11-27; G05 §11]

## 17. Environment relocation and expanded asset library

### 17.1 Read-only inventory and approved scope

The initial local inventory counted 1,211 asset files: 110 primary GLBs, 495 PNGs and 606 .import sidecars. All 42 catalogue visual paths were excluded, including blocked Gloves/Pants; 50 environment primary candidates were mapped, while 18 non-environment/future-loot/character primaries remained HOLD. The orphan Gloves sidecar was explicitly left alone. [I12]

Classification uses physical identity, not vendor, folder stereotype, current collision role or gameplay function. Architecture, infrastructure, furniture and dressing live under assets/environment. A lighting mesh may anchor actual lights; rubble can be a traversal blocker. Source taxonomy does not constrain creative scene use.

Two identical SM_Hallway_Door_02b source families collided. The building_blocks family was selected as canonical after hash revalidation; the furniture duplicate was retired. A communications category was accepted for the fixed radio. The old loot relocation script was too hard-coded and count-specific, so a dedicated manifest-driven environment migration utility was used.

### 17.2 Migration evidence and integration

| Measurement / check | Reported result |
| --- | --- |
| Canonical relocated content | 49 GLBs + 264 PNGs + 313 sidecars = 626 files. |
| Duplicate family retired | 1 GLB + 4 PNGs + 5 sidecars = 10 files. Canonical migration plus retired duplicate accounts for the inventoried 636 environment-family files. |
| Excluded content | 42/42 loot paths unchanged; 18/18 HOLD primaries unchanged; orphan sidecar untouched. |
| Final migration tests | 31/31 passed; 42-asset audit output byte-identical; 40 approved Stack Role/Auto Group checkpoint preserved. |
| Runtime baseline | 30 trimesh collision registrations, 9 convex registrations, 16 deterministic storage surfaces. |
| Import/reference integrity | No UID conflicts or stale tracked/generated paths reported; root identity and measured storage/clearance regressions passed. |
| Human smoke test | Developer launched main and confirmed collisions, loot/shelf interactions, pickup and visual assets remained correct with no visible missing content. |

Commit series: c423d09 (tool/manifest dry-run work), 8bdcd96 (referenced architecture/infrastructure), 54a9954 (high-risk furniture paths/root identity), 602389b (validation), and bd468c7 (non-mutating verification allowed on main, Apply still blocked there). Last reported synchronized main is bd468c70e04c2742d42f270da7b00d35efdc35c9; original series remains in ancestry. Validation: docs/testing/environment-asset-relocation-validation.md. [D12E]

LOCAL ASSET CAVEAT The physical relocation is in ignored assets/ and its import state, not contained in the Git commits. A push/PR does not reproduce the asset library on another checkout. Preserve local backups and explicit move evidence; do not treat a tracked clean tree as proof about all ignored files.

### 17.3 Provisioning and Stage-B candidate preflight

After migration the developer imported additional environment candidates directly into semantic folders. The preflight counted 408 environment GLBs, a net increase of 359 over the 49 canonical migrated primaries. All 408 had matching sidecars, correct source paths and existing imported scenes. They were not pre-assembled into the world. [I13]

| Family | GLBs |
| --- | --- |
| Structural shell | 114 |
| Barriers / fences / railings | 45 |
| Shutter / door candidates | 9 |
| Lighting | 19 |
| Other infrastructure | 96 |
| Furniture and dressing | 125 |
| Total | 408 |

The preflight found no hard geometry-category gap and recommended a metal-led palette. That GO was evidence of candidate availability/import health, not art-direction success. The later human rejection directly limits any conclusion that this library already supplies a coherent shell/finish.

## 18. First Receiving shell: technical success, visual rejection

### 18.1 Implemented scope and reported geometry

Codex authored receiving/freight_bay_prototype.tscn on codex/receiving-elevator-stage-b-pass1-shell, commit c9752c8c68cd55b950dd588542ea271e1acc0aab, without merging. Work included shell geometry, empty future-pass containers, simple aligned collision, a separate neutral preview/capture setup and structural tests. main.tscn and gameplay behavior were not changed. [D13B]

| Measurement | Reported first-attempt value |
| --- | --- |
| Shell | 11.0 m wide x 8.5 m deep x 5.0 m high |
| Clear opening | 3.0 m x 4.488 m |
| Freight platform | 11.0 m x 1.8 m; recessed 0.3 m |
| Apron | 5.5 m usable depth |
| Player-area ceiling | 5.0 m |

These are measurements of the rejected attempt, not future target dimensions. The shortlist used SM_Hangar_floor_8x8, SM_MetalDoorOrWall_01, SM_MetalBeam01, SM_MetalBeam15 and SM_Delivery_8M; the facade was uniformly scaled to 0.75. No shutter, final barrier, infrastructure, dressing or physical loot-pile implementation was included.

### 18.2 Technical checks and disclosed baseline exception

The delivery report states both freight-bay contract suites passed, 31 unaffected regression suites passed, two already authorized loot_000015 symptoms reproduced, and no further drift was introduced. Editor/parser and real-render capture exited 0. Reported mesh-aligned collision/measurement review passed and tracked changes were clean.

The fresh audit was reported as 42 assets with “39 current, 1 stale, 3 dependency-blocked.” Those are the historical report's authoring-status figures, not a documented mutually exclusive partition summing to the catalogue size. Preserve that exact evidence without projecting the later Fuel resolution backward; §24.2 records the completed reconciliation.

Validation path: docs/testing/receiving-elevator-stage-b-pass1-shell-validation.md. Rendered evidence was local/ignored and regenerable from capture tooling, including reports/receiving/freight_bay_stage_b_pass1/contact_sheet.png. This report records the developer's visual findings; it does not pretend the local capture path is a newly inspected attachment.

### 18.3 Human visual findings

| Observed problem | Design interpretation |
| --- | --- |
| Materials/textures did not form a congruent interior | Geometry fit and imported AABBs were insufficient to choose a visual palette. |
| Corrugated steel dominated the walls | The room read as container/mobile shelter/warehouse rather than permanent underground civil infrastructure. |
| Side pillars left purposeless gaps | Wall mass and circulation logic were subordinate to arranging available assets. |
| Exposed beam/pillar intersections looked wrong | Permitted clipping was applied without believable visible join or concealment logic. |
| SM_Delivery_8M dictated the composition | A convenient doorway asset became the design anchor even though a suitable opening could be built from wall/lintel parts. |
| Surface character too clinical or mismatched | Asset selection lacked the approved warm, worn-but-maintained world and finish grammar. |

HUMAN VERDICT TECHNICAL PASS WITH DISCLOSED BASELINE EXCEPTIONS / VISUAL NO-GO. Do not merge the first shell composition or use it as the visual starting point by default.

### 18.4 Process diagnosis and reusable work

The failure arose from treating architecture as asset fitting, prescribing a shortlist before sufficient art direction, and accepting dimensional compatibility as material/style compatibility. The mismatched library contributed, but the evidence does not prove programmatic scene authoring is inherently unsuitable or that every existing structural asset must be replaced.

Retain the branch/evidence as history. Generic capture tooling, asset inspection and non-aesthetic structural checks may be reused after review, but the next composition starts fresh from the approved world brief. No new expensive solver, stronger-model assumption or additional pack automatically fixes art direction.

Hidden intersections are acceptable where unwanted geometry genuinely disappears into opaque structure. Exposed intersections must read as plausible construction. Asset categories are browsing aids, not exclusive scene roles. Simple generated/primitives-based walls may be preferable to forcing a prefab facade; exact source route remains to be proved.

## 19. Approved world-design synthesis and production changes

### 19.1 Resulting authority document

Visual Direction v0.6 retains the established world/material grammar and dedicated service spaces, records the accepted in-engine layout, and adds the current storage-installation and ergonomics direction. The original V3/V2 images and v0.5 record remain historical references. Human spatial promotion applies to the accepted geometry, not final art, furnished production storage or physical Receiving. [V05, A17]

### 19.2 Universal design decisions

| Topic | Approved rule |
| --- | --- |
| World premise | Unfinished/decommissioned metro-service/civil project, but no iconic passenger/rail infrastructure. Read as old underground municipal/service space. |
| Chronology | Mostly late-20th-century construction over 30-50 years of interruptions/upgrades; mixed maintenance before the apocalypse; survivors established for several years. No WWII or sci-fi envelope. |
| Construction hierarchy | Concrete/cement/masonry dominates; old tile/paint/patches overlay it; metal primarily belongs to services, equipment, shutters, barriers and limited reinforcement. |
| Occupation and mood | Skilled, resource-constrained adaptation; established Quartermaster workplace with incidental domestic traces. Core structure trustworthy; apocalypse implied, not a combat/decay spectacle. |
| Wear and lighting | Causal wear, localized dampness, useful quiet surfaces, warm-neutral practical coverage with varied fixture generations. Harsh uniform fluorescence is not the default. |
| Authored persistence | No ambient decorative prop simulation. Explicit player-legal or night progression states may change designated content. |
| Narrative | Administrator terminology; short one-way operational/tutorial messages, optional face cards, no branching replies or visible humans. Sparse occupational humor and legacy signage. |
| Architecture | Coherent service-space logic, larger than domestic but not warehouse scale; selective irregularities and modular repetition broken by plausible history. |

### 19.3 Foundation Gate

Production-art progression retains independent Structural Shell and Applied Finish reviews. Neutral seeded-storage integration and bounded Receiving gameplay may proceed before final materials; functional test fixtures do not constitute art promotion or general departmental furnishing. [D17B]

The gate is a human visual checkpoint, not an exact-transform test. Provisional dimensions must remain editable. Architecture should anticipate ergonomic opportunities, but not be bent around a mandated shelf or doorway asset. Later lighting may enhance valid materials, never serve as the fix for gloss, pristine surfaces or mismatched kits.

### 19.4 Current spatial and gameplay-facing synthesis

| Area | Approved consequence / open detail |
| --- | --- |
| Receiving / Sorting | Accepted cordoned freight bay, distinct Dispatch annex, Backlog and passage-like Sorting. The desk has partial aperture visibility and the two long vistas are interrupted. Preserve that reviewed geometry; actual pile-item recognition and reach remain future Receiving tests. [A17] |
| Main / satellite Storage | Current topology uses five main galleries A-E and a directional 85-90% capacity target, with one primary spine and one intentional C<->D secondary connection. Gallery shapes vary but should remain buildable; Gallery E is not a shortcut to the Deeper-Bunker Approach. Remaining 10-15% capacity is opportunistic/specialist satellite storage. |
| Sockets / progression | Moderate installed starting capacity; starting loot TBD. All units authored/socketed; movement remains open and restricted if retained. Implicit future sockets may contain designated clutter until night upgrades. Labels remain detailed design work. |
| Playable service spaces / unseen cores | Workshop/Kitchen service rooms and Medical Supply Anteroom are playable; Ops is an open Transfer Landing. Staffed cores remain off-map behind inner boundaries. Kitchen route uses B-east; Medical retains its protected shared-circulation spur. [H16, D16S] |
| Major machines | Salvager remains on a discoverable Workshop spur. Incinerator sits on a terminal spur distributed along the longer dog-legged Deeper-Bunker Approach, with ordinary shared-corridor buffer before Bunker Ops. Both remain massive, building-connected, front-operated landmarks. |
| Introduction | Incinerator not Day 1; offline/broken existing machine is preferred presentation. Exact unlock timing/cost and potential Salvager introduction remain open, not fixed at Day 5. |
| Dead spaces | Workshop abandoned continuation removed entirely by explicit scope change. No replacement stubs or reserved holes now. Later consider approximately two or three away from immediate/direct service-space or Ops adjacency. Machine spurs and settlement access are not abandoned routes. |

These remain design constraints rather than economic tuning. Greybox dimensions, openings, service-room footprints and reviewed sightlines are now a human-approved working baseline. Actual shelves, carried items, bay lining and later requests can expose specific new clearance or pacing issues. Use accepted source/geometry rather than reverting to V3/V2 pixels. [A17]

### 19.5 Superseded document wording

GDD v0.4's Surface Access-door suggestion is superseded by an unshown personnel route. Its total-batch-in-existence limit and never-generated Awaiting Lift forfeits are superseded by deposited capacity plus precomputation-compatible forfeiture. Night persistence now names designated upgrade/repair exceptions. Earlier rigid interpretation of fixed tabletop slots, labeling implementation and universal container movement no longer constitutes finalized implementation scope.

Smoke-and-mirrors production remains: staffed operational interiors stay off-map, while the dedicated support service rooms are playable. No visible human NPCs, latent playable-bay pile physics or ambient prop simulation are added. Identity-safe transactions and explicit off-screen state transitions remain. Facility equations are unchanged. [D16S]

### 19.6 Approved topology and schematic baseline (15 September)

The topology work compared multiple candidate arrangements, then combined/refined them into one approved greybox baseline. The locked relationship sequence is Receiving -> Backlog Passage -> Sorting / Quartermaster Central -> Main Storage Network -> Deeper-Bunker Approach, with dedicated Expedition, Workshop/Salvager, Medical, Kitchen/Mess, Incinerator and Bunker Ops branches/frontages.

Detailed Topology V3 is the high-level relationship/circulation/territorial reference and is intentionally not to scale. Basic Structural Schematic V2 is the simplified approximate-proportion walls/openings reference for Codex. Small image-generation or hand-edit artifacts are not authority; when the two images disagree materially, Visual Direction v0.3 prose and the approved topology rules take precedence.

Historical 15 September gate: construct a first complete neutral wing. The first-pass and intermediate REVISE states are preserved below as history. Subsequent round-three review and Medical tuning closed the spatial gate on 17 September; the current status is PROMOTED. [W17, H17, A17]

## 20. Historical 17 September debt checkpoint superseded by Section 24

### 20.1 Historical loot_000015 reconciliation checkpoint

Before Pass 1, the developer reimported Fuel Canister (loot_000015) to repair a texture issue. Subsequent source/fingerprint evidence changed. The developer states intended scale, Footprint, Storage Pose/orientation, Stack Role and Auto Group do not need redesign. Codex preserved the known mismatch while proving no extra shell-induced drift. [D13B]

At this checkpoint, the proposed next action was to inspect the source/import/runtime representation, verify intended geometry and pickup/catalogue registration, then use the established review/sync/apply workflow to restore valid evidence. Section 24.2 records that this reconciliation was later completed without silently changing the 40-ID runtime pool or altering gameplay to accommodate a fingerprint.

At the 17 September checkpoint, this did not need to interrupt layout or art discussion, but remained required before clean full-pool Receiving validation. Gloves and Pants were separate blocked content cases. Section 24.2 supersedes this pending status; no later result is projected backward into the historical reports.

### 20.2 Historical repository and artifact state

| Artifact / revision | Last reported status |
| --- | --- |
| Stage A 41415a4dbf204c9187874fd40f421183939d60f7 | Merged/synced; earlier 14 implementation commits retained. |
| Environment main bd468c70e04c2742d42f270da7b00d35efdc35c9 | Merged/synced, technical and human smoke checks passed; ignored relocated assets intact. |
| Pass 1 shell c9752c8c68cd55b950dd588542ea271e1acc0aab | Feature-branch commit; visually rejected. No later merge/repair is asserted. |
| Visual Direction v0.5 | Then-current spatial/art authority at the 17 September checkpoint: accepted greybox, retained service-space concept and dead-end deferral. Production materials and furnishing remained separate. |
| GDD / Prototype v0.8 | Then-current documentation pair at the 17 September checkpoint; human spatial acceptance, scoped runtime/static evidence and the seeded-storage prerequisite were consolidated. |
| Wing source aeb1ef2 / final docs 8d64086 | Accepted local checkpoint as reported; GitHub main was still 8ee62bd3 at that read-only inspection. Close-out publication had been requested but was not performed in that historical document edit. |

### 20.3 Historical recommended next evidence sequence

- Persist the developer acceptance, update current documents/status pointers, preserve dated evidence and integrate/publish the accepted wing from the authoritative checkout after fresh verification. No deletion of local reports, ignored assets or the rejected Receiving branch is needed for cleanliness. [D17B]

- After repository/documentation synchronization is verified, preflight and implement the seeded-storage bridge in a separate focused task: several real storage-capable shelves, a bounded pre-seeded functional item assortment and established pickup/carry/zoning/stacking/retrieval in the accepted wing.

- Keep the old main test-room scene intact and independently runnable. Keep the neutral review/capture harness and accepted geometry available. Exact gameplay composition and any default-launch switch require local dependency inspection and a focused bridge handoff; do not perform them during bookkeeping.

- Reconcile loot_000015 through the established authoring process before a physical Receiving test claims a clean full catalogue. For an earlier bounded seed fixture, use explicitly chosen current eligible representatives and disclose omissions; do not change the Receiving pool or stale approval flags. Gloves/Pants remain separate.

- Human-validate the seeded wing handling loop before functional Receiving. A small architectural/material proof remains a later separate production test; no full-wing art, service furnishing or delivery choreography is required for this bridge. [D17B]

The next task connects existing validated systems to the accepted environment rather than inventing new storage or Receiving mechanics. It adds a prerequisite gate, not a claim that functional shelves/loot are already present in the wing.

### 20.4 Deferred questions remain deferred

Production starting stock, final furnished capacity, request pacing, service devices, machine unlocks, physical pile performance, full saves, held/HUD polish and blocked-content debt remain separate. Greybox spatial approval is complete. Abandoned stubs are deferred; later placements must not directly connect to or be immediately adjacent to service spaces/Ops.

## 21. Revision and evidence-source register

### 21.1 How v0.8 updated the 17 September record

v0.8 preserved the earlier storage/content and visual-failure history, recorded three revision rounds plus the Medical-only success, and updated the then-current state to human spatial PROMOTE. It distinguished reported runtime results, independent archive checks and a read-only remote inspection. Its required sequence was bookkeeping/synchronization -> seeded storage integration -> Receiving. Section 24 supersedes that sequence and records the later completed steps.

### 21.2 Sources and verification scope

| Key | Source and what it supports |
| --- | --- |
| P04 | Supplied Prototype Findings v0.4, 11 September. Retained experiments, defects/fixes, authoring and human stress-test evidence. |
| G05 / G06 | Supplied Preliminary GDD v0.5 and v0.6. Historical design sources, not proof of implementation; GDD v0.8 was the then-current companion at the 17 September checkpoint. |
| R12 | Approved 12 September Receiving/Elevator architecture spec and Stage A plan. Intended contracts; actual results are separately reported. |
| D12 / D12A | 12 September discussion and developer-supplied Stage A completion/merge report: 30/30 strict suites, audit and integration status. |
| I12 | Attached read-only environment inventory (Pasted markdown.md): source counts, catalogue/HOLD exclusions, dependency and relocation-tool findings. |
| D12E | Developer-supplied migration, merge and human in-game reports around 12-13 September: 49 canonical primaries, duplicate retirement, 31/31 suites, collisions/surfaces and bd468c7. |
| I13 | Attached Stage-B candidate review (Pasted markdown(1).md): 408 environment GLBs, category counts, import health and candidate judgments. |
| D13B | 13 September Pass 1 report at c9752c8 plus developer visual rejection and explanation of prior loot_000015 reimport. |
| D13-14 / V02 | Approved 13-14 September world/zone discussion and Visual Design & World-Building Direction v0.2. Design intent and Foundation Gate, not built environment evidence. |
| K13 | KitBash support correspondence quoted by the developer. This report records the answer without extending its legal scope. |
| M14 | Uploaded kb3d_americanneighborhoods.zip and local archive inspection: material/texture/source-file inventory, not a rendered integration test. |
| D15 / D15T / V03 | 15 September handoff plus subsequent topology/layout session and Visual Direction v0.3: approved Topology V3, Basic Structural Schematic V2, branch/frontage refinements, open-threshold policy and full-wing greybox milestone. Design evidence only; no Godot greybox run. |
| G06 / P06 / V03 | Supplied source documents for this revision; retained historical evidence and pre-service-space wording. |
| G07 / V04 | Prior GDD v0.7 and Visual Direction v0.4: service-space agreement retained; their then-current status and roadmap were updated in G08/V05. |
| W16 | Supplied logistics-wing-greybox-validation.md and user-pasted completion report. Reported first-wing verification; report/capture/final commit identifiers differ and are preserved explicitly. |
| H16 | Developer's 20 round-one observations, expected/actual images and Greybox wing - 1st.mp4. Refine-not-rebuild disposition and geometry correction directions. |
| S16 | Supplied logistics_wing.zip plus archived source-review report/references. Static/source/video review of that snapshot, not a local runtime or Git audit. |
| D16S | Developer-approved dedicated service spaces, distinct footprint character, three boundaries, open Bunker Ops landing and explicit deferral of furnishing/delivery details. |
| D16P | Approved earlier session sequence separates low-fidelity spatial/gameplay tests from production-art Foundation Gates. |
| W17 | Supplied round01/02/03 and Medical review bundles/reports; final 22 routes, 12 boundaries, 113 classified junction pairs, 33 non-hanging regressions are reported local results. |
| H17 / A17 | Developer acceptance after Medical tuning plus the 17 September acceptance MD/static-check JSON. Human spatial promotion; zero non-Medical saved-scene differences in the scoped comparison. |
| D16-R02 | Approved removal of Workshop abandoned continuation and deferral of later opportunistic stubs away from service spaces. |
| D17B | 17 September developer request: repository/documentation stability and synchronization, then seeded functional storage in the wing, then Receiving. Preserve original main scene intact. |
| R17 | Read-only GitHub inspection at that checkpoint: the prototype repository listed only main at 8ee62bd3; the then-current tracked root/docs/player/storage bootstrap was inspected. No remote write or local-runtime verification was performed. |
| G08 / V05 | GDD v0.8 and Visual Direction v0.5 were the then-current scope and spatial authorities at the 17 September checkpoint; they did not establish that the next bridge was implemented. Current companions are GDD v0.9 and Visual Direction v0.6. |

### 21.3 Repo-local evidence paths

Receiving design: docs/superpowers/specs/2026-09-12-receiving-elevator-mvp-design.md. Stage A plan: docs/superpowers/plans/2026-09-12-receiving-elevator-stage-a-implementation-plan.md.

Validation records: docs/testing/receiving-elevator-stage-a-validation.md; docs/testing/environment-asset-relocation-validation.md; docs/testing/receiving-elevator-stage-b-pass1-shell-validation.md.

Current accepted wing: docs/testing/logistics-wing-greybox-medical-tuning-validation.md and the separate 17 September acceptance record. Historical first/round01/round02/round03 reports remain unchanged. Final source/evidence aeb1ef2; reported final docs 8d64086. Archive hashes and evidence paths are recorded in §23.

Historical player evidence: docs/testing/catalogue-scale-deterministic-stacking-stress-test.md; docs/testing/deterministic-support-stacking-playtest.md; docs/testing/singleton-shelf-vertical-clearance-follow-up.md; docs/testing/singleton-shelf-vertical-clearance-fix-playtest.md.

## 22. Historical first-wing review and service-space revision

### 22.1 Reported implementation and verification

The supplied report identifies local main/origin base 8ee62bd3bc4f23918717517e066d4c6a8cb565df and branch codex/logistics-wing-greybox. It states implementation verified through 7ba27a5 and captures refreshed at 21a2dba. The developer supplied final handoff commit d81783f. These are distinct evidence anchors; the archive has no Git metadata and does not independently establish their correspondence. No branch was pushed or merged according to the delivery report. [W16]

Reported checks: 33/33 non-hanging regression scripts, 17/17 controller-driven routes and 7/7 sustained-input boundary checks, parser/editor and independent/default-scene smoke checks. The known long-running audit reproduced three pre-existing assertions before bounded termination. These are reported results, not fresh test executions for this document. The original main scene, shared controller, default launch and rejected Receiving branch were reported unchanged.

Reported walk measurements include Receiving-to-Sorting 5.883 s, Sorting-to-Bunker Ops 19.983 s, and C-to-D 2.833 s through the secondary opening versus 4.600 s via the primary spine with common endpoints. These belong to the first-pass geometry, not tuned targets for the revised wing. [W16]

### 22.2 Human round-one disposition

HISTORICAL ROUND-ONE VERDICT: REVISE, NOT REBUILD. The developer confirmed a complete playable wing, but shapes, orientation, enclosure, openings and service spaces required correction. This paragraph records that checkpoint; current final acceptance is in §23. [H16]

The correction scope includes freight enclosure and room-wall separation; meaningful Receiving/Backlog/Sorting thresholds; Dispatch elongation; a deeper Sorting work pocket; Workshop footprint; Salvager reveal depth; differentiated galleries and A/B openings; a broader Storage spine; selective core sightlines; Kitchen-from-B-east routing; narrower Incinerator; clean dog-leg; a door-sized deeper closure; and complete walls/ceiling transitions. Percentage estimates are qualitative sizing direction, not uniform scale instructions. [H16]

### 22.3 Source / recording review: separate from runtime proof

The prior archived-source review inspected three GDScript files and five scenes and sampled the approximately 4m42s walkthrough recording. Its static comparison found all 196 generated boxes matched saved positions/sizes and their corresponding colliders. That establishes agreement within the supplied snapshot, not complete enclosure, correct design or a new Godot pass. The external shared scripts, project settings and test suite were not part of that source archive. [S16]

| Finding in supplied snapshot | Implication for correction |
| --- | --- |
| Missing construction | Receiving ceiling-step upper strip, Kitchen cross-leg closing wall and dog-leg return are absent geometry; do not hide gaps through lighting or camera changes. |
| Shared-wall ownership | 25 collinear overlapping wall pairs were reported. A-east/MedicalWest, B-west/MedicalEast and B-east/KitchenSouthWest duplicate meshes and collision. An opening in one owner can remain blocked by the other. |
| Frontage representation | Medical/Kitchen/Workshop route floors end at closure masses without the expected wider support-room floor. Ops does have playable terminal floor; its proportions/closure still require revision. |
| Capture aspect ratio | 1920x1080 images were resized to 480x360 tiles. Preserve aspect ratio in new sheets; use full-resolution originals for proportional comparison. |
| Coordinate-driven construction | Floors, walls, boundaries, proxies, anchors, captures and traversal waypoints have separate literal coordinates. Update the authoritative builder and all affected dependencies coherently; scene-only edits can be overwritten. |

At that first-pass checkpoint, none of these source findings was recorded as repaired. Later correction rounds addressed the construction and fidelity issues, followed by human review; §23 records the final acceptance. Retain the earlier record rather than retroactively changing its tests or verdict.

### 22.4 Approved concept: service spaces rather than corridor frontages

The developer approved dedicated Workshop and Kitchen service rooms, a Medical Supply Anteroom and a more open Bunker Ops Transfer Landing. Each is playable support territory with distinct footprint/arrival character. The staffed operational core stays unseen behind an opaque inner wall. This replaces both the blanket exclusion of all facility interiors and the interpretation that a labelled blocking plane alone is a frontage. [D16S]

Three boundaries are independent: territorial entry is traversable; material ownership changes only on explicit legal submission; the inner playable-world boundary excludes the staffed core. Department support equipment is non-loot by design and supplies no implicit Quartermaster storage or retrievable reserve. The developer considers existing distinct assets sufficient; exact furnishing and delivery choreography remain later milestones.

Reference conflict is explicit: prior prose and the original milestone forbade Kitchen access through Gallery B, while the structural drawing and round-one direction require B-east access. Record the Kitchen-only supersession in the revision plan and tests. A-east/B-west open onto shared circulation, which must be named separately from the protected Medical spur. Do not remove all Medical restrictions or create an unapproved gallery grid. [H16, D16S]

### 22.5 Historical first-pass evidence states and next gate

| Evidence class | Current disposition |
| --- | --- |
| First-pass implementation | Demonstrated in reported scope and developer walkthrough; not a production-quality claim. |
| Reported technical checks | Retained as first-pass scoped results; not independent fresh execution here. |
| Human spatial review | Completed round one: REVISE. Corrected layout not yet approved. |
| Service-space concept | Approved by developer; new footprint/boundary construction still pending. |
| Workflow feasibility | First whole-wing authoring shown, but design translation/self-inspection need improvement. Promotion remains pending. |
| Revision reliability | Untested until the actual feedback-driven correction is built and checked. |
| Art / Receiving / balance | No production-art promotion, physical Receiving validation or integrated balance approval claimed. |

At this historical checkpoint, the next gate was correction and human review, with no automatic merge/push/art/gameplay continuation. That restriction applied to the then-unaccepted build. The developer later accepted the final neutral layout and requested separate bookkeeping and integration; current sequencing is recorded in §24. [A17, D17B]

## 23. Greybox promotion and historical transition to seeded gameplay

### 23.1 Correction chronology and accepted checkpoint

First pass: d81783f. Round one: add47716 (reported final), introducing real service rooms and correcting major route/shape issues; human REVISE remained. Round two: source 13f45122 / final 66b7c18, removing the abandoned stub and completing much of the layout; further specific corrections were requested. Round three: source e2803cd / final f2fb9b0, resolving the outstanding corrections including missing corners. These are reported historical checkpoints, not inferred current HEADs.

Medical tuning: source/evidence aeb1ef27671f2f07d651e5064b00c3c77a06600b and documentation-only final 8d64086aa02ade21449af24dbc7742748115792c. The exclusive corridor doubled from 5 m to 10 m. The same-size 7.8 x 7.0 m nominal room moved 2.6 m west and 5 m north; its eastern wall continues the corridor, with a south-east entry. The A/B connector remains Main Storage.

HUMAN VERDICT: PROMOTE THE NEUTRAL WORKING SPATIAL BASELINE. The developer confirmed Medical was built and placed exactly as requested and identified no other visual changes or regressions. This closes the previous correction gate; it does not certify final furnishing, physical loot behaviour, production art or economy balance.

### 23.2 Evidence layers and verification limits

The accepted Medical bundle reports 22/22 normal-controller routes, 12/12 boundaries, 113 junction pairs with zero unresolved, all three focused suites and 33/33 established non-hanging regressions passing. It retains the bounded legacy audit exception. The final local tree was reported to contain only preserved untracked evidence; no merge/push was performed by that task.

Independent acceptance review recomputed the archive SHA-256 (ca98bb36be4b4cbb0bc0ef2e60199ca395b35f18920db3693b71f4fb62ca2490), matched all eight source/test hashes, checked bundled JSON consistency, compared the baseline/saved geometry and inspected the final Medical/overview images. Excluding the authorized Medical paths and root metadata, there were zero non-Medical saved-scene differences. These are static archive checks, not a new engine run or a live repository audit.

Runtime reports written before the developer walkthrough correctly say human review pending. Keep those historical reports intact and attach the new acceptance record; do not edit them to suggest earlier approval. Source/evidence revisions, documentation commits and later integration commits must remain distinguishable.

### 23.3 Production-workflow conclusion

The human-directed local Codex workflow demonstrated complete neutral scene authoring and eventual convergence on the intended wing. The Medical-only pass demonstrates bounded revision with unchanged neighbouring geometry. Earlier rounds still required substantial human clarification and source-level defect review. The supported conclusion is supervised iterative feasibility, not reliable unattended schematic interpretation or a measured production-time budget.

Workflow feasibility here means the human-Codex authoring/revision process. It is not facility delivery choreography. Some earlier reports used the latter meaning in their status table; this consolidation corrects the current interpretation without rewriting those reports. Coherent materials, asset composition and detailed furnishing remain for a separate small visual-construction proof.

### 23.4 Historical 17 September repository and documentation close-out

On 17 September the GitHub connector returned only main at 8ee62bd3bc4f23918717517e066d4c6a8cb565df for Navandis/Sorting-apoc-PROTOTYPE. The accepted wing branch therefore was not present in that remote branch listing. This read-only finding agrees with the developer reports that it remained local. No local checkout or Git object ancestry was available in this chat.

At the 17 September checkpoint, the developer had requested bookkeeping and publication before new game work. The local close-out was required to verify branch and remote identity, install the then-current documents and acceptance, retain ignored assets/imports and evidence, and synchronize without force or history loss. Section 24 supersedes that pending state and records the later accepted continuing composition and maintenance results.

### 23.5 Historical seeded-storage gate completed before Section 24

At that checkpoint, the next required step was to bring several existing storage-capable shelves and pre-seeded functional catalogue items into the accepted wing. It was an integration and fixture task, not another storage architecture gate or final furnishing plan. Section 24.1 records the later continuing gameplay and default-entry result.

The historical bridge requirement preserved the main scene, tunnel room and contents while keeping the neutral review scene available. The later implementation retained main.tscn as the legacy mechanics fixture and promoted the continuing wing separately. The review-player and old bootstrap details below remain evidence of the preflight constraints at that checkpoint. [R17; final bundle review_player.tscn]

The preferred candidate at that checkpoint was a gameplay wrapper sharing the accepted geometry and established gameplay components, with shelves and seed configuration outside the generated geometry subtree. Section 24.1 records that continuing composition and default entry as accepted. Facility gameplay, production art, abandoned stubs and freight lining remained outside the bridge.

## 24 20 September storage authoring consolidation

### 24.1 Continuing gameplay and default entry

The accepted whole-wing geometry is used by the continuing gameplay composition at res://gameplay/logistics_wing/wing_gameplay.tscn. Godot Run Project enters that scene through UID uid://bljf1nlhijej. The old main.tscn mechanics room and the neutral review scene remain explicit preserved alternatives. The default-entry transition and the developer's authored scene edits are accepted. F6 developer grids remain available and default off; F7 is suppressed in the continuing scene.

### 24.2 Palette and maintenance results

The DevelopmentSetup/SeedItems composition is the current palette authority. The developer accepted the saved manual table and item arrangement with at least one direct editor-authored host for every approved eligible type. The separate twelve-host fixture remains a regression sample. Fuel is present and eligible after the bounded locker and Fuel maintenance; Gloves and Pants remain excluded.

Locker level 2 now fits its measured support at both front and rear edges for the tested identity and legacy scales. The Fuel audit debt and timeout are resolved without redesigning Fuel's gameplay values, pose, footprint, stack roles or Auto Group. The accepted maintenance preserved the authored wing scene, other storage profiles, player and HUD, geometry, data and Receiving.

### 24.3 Shelf and ceiling experiment

The retained A, B and C shelf and ceiling scene established that technical shelf capacity and human usability are different evidence. Storage installation usability includes model geometry, level placement, room placement, approach space, player viewpoint, reach, lighting, target visibility and obstruction. A surface can accept an item technically while remaining difficult to inspect or use manually.

- Uniform Y compression of existing multi-level furniture is rejected as a general storage solution.

- In the tested corner-mounted modular-rack context, more than three ground-access levels compromised visibility and manual targeting unless the openings became too shallow or squat.

- The developer's three-level modular rack is a useful ground-access reference, not a universal production template. SM_Rack01.glb and SM_Rack02.glb remain static review assets without functional StorageSurface nodes.

- Open racks may tolerate more depth when approached from several sides. Wall and corner installations generally need shallower usable depth.

- Usable-area insets should be evaluated per edge. No single percentage is promoted and useful front-edge capacity should not be removed silently.

- Cabinet and opaque storage remain selective. Lighting alone did not make every divided compartment a reliable general-purpose storage backbone.

The 1.80 m eye-height trial helped some upper-level views but did not solve deep shelves or opaque dividers and could worsen low-level viewing. The 2.8 m ceiling looked more proportionate in the tested context. Neither finding changes the production camera or wing ceilings.

### 24.4 Authoring ownership and ladder proof

The developer retains final authority over functional storage model selection, installation placement, unit dimensions, level count and distribution, and ladder availability and placement. Codex may assist with tools, validation, decoration and later synthetic checks.

A fixed shelf-serving ladder is approved for one bounded proof because the current ergonomics evidence justifies testing that option. It is not production-approved. General climbing, jumping, movable or sliding ladders, animations, visible hands, fall systems and shelf-adjustment features remain outside the proof. Player-adjustable shelf levels remain post-release or expansion speculation and did not influence the ladder decision.

### 24.5 Process and next evidence

docs/AI_WORKING_GUIDELINES.md is the current process authority after the locker and Fuel maintenance post-mortem. It requires one implementer by default, testing matched to risk, existing evidence and commands reused where the state is unchanged, and no new review or evidence framework without a task-specific need.

1.  Review-scene supply reuse.

2.  Reusable functional modular-rack authoring.

3.  Single-rack fixed-ladder proof.

4.  Human ladder decision.

5.  Receiving, unless the storage work exposes another concrete blocker.

This order supersedes the v0.8 record where Fuel reconciliation, seeded storage integration and shelf ergonomics were still pending. This documentation delivery adds no gameplay implementation and does not change ceilings, camera height, gallery furnishing, Receiving, crouch, auto-placement or ladder movement.
