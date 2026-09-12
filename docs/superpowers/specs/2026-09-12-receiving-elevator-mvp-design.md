# Sorting Apocalypse — Receiving / Elevator MVP Architecture Design

**Date:** 12 September 2026  
**Status:** Proposed architecture — approved in design discussion, pending repository integration/user review  
**Design authority:** `Sorting Apocalypse — Preliminary GDD v0.4`  
**Prototype evidence baseline:** `Sorting Apocalypse — Prototype Findings v0.4`  

## 1. Purpose

Define the architecture for the next prototype milestone after the validated storage/content slice:

**validated storage/content slice → Receiving/Elevator MVP → first real timed request/system vertical slice → scavenger/expedition production of elevator batches → broader Systems MVP**

The Receiving/Elevator MVP must create a representative source of physical loot without prematurely implementing expedition simulation or full survival balance. It should validate the physical world boundary through which future expedition loot reaches the Quartermaster.

The design deliberately separates:

- **what loot exists**;
- **when/where that loot is prepared**;
- **when it begins consuming Receiving capacity**;
- **how the active batch is physically presented**;
- **how the player transfers items from Receiving into the validated logistics loop**.

This separation is intended to allow later expedition integration without refactoring the Elevator subsystem end-to-end.

---

## 2. Core design principles

1. **Smoke and mirrors over literal simulation.**
   The elevator need not physically travel. Arrival is conveyed through shutter state, lights, audio, impacts, cable/motor sounds, and other cues.

2. **Backend preparation must not create frontend gameplay consequences.**
   A future batch may be generated and prepared early, but it consumes Receiving capacity only when it is actually deposited into the bunker Receiving system.

3. **Item identity begins at generation and survives the full lifecycle.**
   A physical item receives a durable identity when its batch content is committed. That identity is preserved through Receiving, carry, storage, and any later valid gameplay state.

4. **ItemDefinition remains gameplay truth.**
   The authoring-review manifest remains evidence/authoring truth only and is never consulted by runtime loot generation.

5. **No unrestricted loose WorldItem state.**
   A physical item may exist only inside a legitimate bounded gameplay state, including Receiving/elevator or storage/container. Carried items are represented by their ItemInstance rather than as arbitrary world objects. Submitted/consumed/incinerated/salvaged items cease to exist as ordinary physical loot as appropriate.

6. **Temporary rigid-body physics is presentation-generation tooling only.**
   Physics may be used in a hidden isolated preparation environment to create a plausible pile. No dormant/sleeping rigid bodies survive into the playable world.

7. **The three-batch Receiving lifecycle is modeled from the start but implemented in stages.**
   The data architecture supports one active/visible batch plus two deposited queued batches immediately. Physical queue gameplay is enabled only after the single-batch gate passes.

---

## 3. High-level architecture

Use four principal responsibilities.

### 3.1 `LootBatch`
Owns durable committed batch content and accepted frozen presentation data.

It does **not** own Receiving slot position or arrival theatre.

### 3.2 Temporary prototype loot source
Generates reproducible prototype batches using a seeded Bulk budget and an explicit 40-item eligible pool.

It is temporary upstream generation policy, not permanent expedition logic.

### 3.3 `ReceivingManager`
Owns the bunker Receiving lifecycle:

- one active batch;
- up to two deposited FIFO queued batches;
- deposit acceptance/rejection;
- drained-batch retirement;
- FIFO promotion.

It does not generate loot or manipulate individual WorldItems.

### 3.4 `FreightBayPresenter`
Owns the active freight-bay presentation:

- arrival/reveal/closing state machine;
- shutter animation;
- audio/light cue hooks;
- reconstruction of committed frozen piles;
- enabling/disabling Receiving item interaction.

It does not decide queue order or batch content.

### 3.5 Data flow

Prototype phase:

```text
PrototypeLootSource
    → LootBatch CONTENT_COMMITTED
    → hidden pile preparation
    → LootBatch PREPARED
    → debug delivery/deposit event
    → ReceivingManager
    → FreightBayPresenter
    → frozen ordinary WorldItems
    → player TAKE
    → carried ItemInstances
```

Future expedition phase:

```text
Expedition outcome
    → LootBatch CONTENT_COMMITTED
    → optional early hidden preparation
    → LootBatch PREPARED
    → expedition return/deposit event
    → ReceivingManager
```

Receiving therefore consumes prepared batches from any upstream producer.

---

## 4. Effective catalogue and prototype generation pool

The persistent catalogue currently contains **42 ItemDefinition resources**, but the effective gameplay-ready pool for this milestone contains **40 items**.

Blocked from downstream gameplay:

- `loot_000034` — Gloves
- `loot_000036` — Pants

They remain excluded until their unresolved Storage Pose and downstream authoring chain are repaired and re-approved.

### 4.1 Runtime eligibility boundary

Do **not** add development-state flags such as `authoring_complete` or `receiving_eligible` to `ItemDefinition`.

Instead, author a prototype-only generation pool containing exactly the stable IDs currently allowed for prototype loot generation.

Conceptually:

```text
PrototypeLootPool
  item_definition_ids[40]
```

Requirements:

- resolves IDs through the persistent `ItemCatalog`;
- fails loudly on missing/duplicate/invalid IDs;
- contains no Gloves/Pants entries;
- never reads the authoring-review manifest;
- can later be superseded by authored destination-specific loot tables using the same stable IDs.

The long-term goal is persistent catalogue(s) plus scalable authored loot tables so newly approved items can enter generation without changing Receiving architecture.

---

## 5. Durable item identity

The current prototype ItemInstance tick-time identity is insufficient for committed random outcomes.

`ItemInstance` must support an externally supplied durable ID.

### 5.1 Identity invariant

**Generation creates the identity. Representations only carry it forward.**

A newly committed batch must receive a unique `batch_id`. Each entry then receives a unique durable item identity within that batch (for example, derived from `batch_id + entry ordinal`), so two separate same-seed batches can coexist without identity collisions.

The ID must never change across:

```text
LootBatch entry
→ revealed WorldItem
→ carried ItemInstance
→ stored WorldItem
→ later valid destination ownership
```

### 5.2 Batch entry identity

Each physical generated item is represented by one batch entry, never an aggregate `{definition_id, quantity}` count.

Conceptually:

```text
LootBatchEntry
  item_instance_id
  definition_id
  frozen_transform
  remaining_in_batch
```

Future per-instance state may extend the entry, but condition/contamination/etc. are not added merely for this MVP.

---

## 6. `LootBatch` model

The batch model owns **preparation state**, not Receiving occupancy state.

Do not combine queue/visibility into the batch enum.

Conceptually:

```text
LootBatch
  batch_id
  source_kind
  source_ref

  target_bulk
  actual_bulk

  content_seed
  presentation_seed

  preparation_state
  presentation_profile_id
  presentation_profile_revision

  entries[]
```

### 6.1 Durable preparation states

Only two durable states are required initially:

```text
CONTENT_COMMITTED
    ↓
PREPARED
```

`ARRANGING` is disposable work state, not durable gameplay state.

### 6.2 Content commitment

Content commitment fixes:

- batch ID;
- individual item IDs;
- definition IDs;
- Bulk totals;
- content seed;
- presentation seed.

Once committed, batch content is immutable.

### 6.3 Arrangement commitment

Hidden settling and validation may retry freely without changing content.

Only a validated accepted layout atomically commits:

- one frozen transform per remaining entry;
- presentation profile ID/revision;
- PREPARED status.

`frozen_transform` is relative to a stable freight-bay presentation coordinate root, never global world coordinates.

### 6.4 Crash/recovery contract

- Crash before arrangement commit → batch remains `CONTENT_COMMITTED`; presentation can be regenerated.
- Crash after arrangement commit but before reveal → exact pile reconstructs from committed transforms.
- Crash after reveal → exact remaining pile reconstructs from committed transforms and entry ownership state.
- Never persist transient velocities, contacts, or half-settled rigid-body state.

---

## 7. Prototype seeded Bulk-budget generator

Stage A uses a temporary prototype source.

### 7.1 Generation method

Inputs:

```text
content_seed
target_bulk
PrototypeLootPool
```

The generator samples from the eligible 40-item pool until it approximately fills the provisional target Bulk.

Exact packing is unnecessary; small over/undershoot is acceptable.

This generator is explicitly **not** future expedition reward balancing.

### 7.2 Reproducibility

Same:

- content seed;
- pool revision/config;
- target Bulk;

must produce the same ordered definition/content result and Bulk outcome. Each newly committed batch still receives a unique `batch_id`, and each physical item identity is unique to that batch commitment (for example, derived from `batch_id + entry ordinal`). Reconstructing an already committed batch preserves its existing identities exactly; creating a second new batch from the same seed does not reuse them.

### 7.3 Stage B debug trigger

Manual/debug-triggered deliveries only.

Suggested controls:

```text
generate/deliver(seed, target_bulk)
force_new_presentation_attempt
force_fallback
```

No automatic delivery cadence in Stage B.

---

## 8. Receiving occupancy model

`ReceivingManager` owns deposited bunker Receiving capacity.

Conceptually:

```text
ReceivingManager
  active_batch_id: optional
  queued_batch_ids: FIFO, max 2
```

### 8.1 Deposit rules

When a PREPARED batch is physically delivered:

- no active batch → becomes active;
- active exists and queue has <2 → append FIFO;
- active + two queued already exist → reject deposit without mutation.

The future expedition system maps rejected deposit to `Awaiting Lift`.

### 8.2 Prepared future batches do not consume slots

A batch may be generated and prepared long before its delivery event.

Until deposit occurs, it remains outside Receiving capacity.

This preserves the rule:

**backend preparation lifecycle ≠ Receiving occupancy lifecycle**.

### 8.3 Drained batch promotion

When the final active entry transfers out of Receiving:

1. presenter runs its short delay and closing sequence;
2. only after the shutter is fully closed does the manager retire the drained batch;
3. first queued batch promotes to active;
4. promoted batch receives its own arrival/reveal theatre.

A queued batch never materializes magically behind an already-open shutter.

---

## 9. Freight-bay spatial model

Preferred prototype layout:

**Receiving Apron → permanent safety barrier → shutter → recessed freight bay/lift deck**

The Quartermaster never boards the lift.

### 9.1 Permanent barrier

The fixed barrier is the true player collision boundary.

Benefits:

- player cannot enter elevator;
- cannot enter shaft;
- cannot stand underneath lift;
- cannot obstruct shutter;
- cannot collide with/fall through loot pile;
- no dynamic invisible blocker is required;
- architecture itself explains the restriction.

The concept is intentionally wide and shallow to improve readability and reach.

### 9.2 Shutter

The shutter sits behind the permanent barrier.

It controls reveal/hide, not player access.

Nothing except the shutter needs actual movement animation.

### 9.3 Recommended runtime scene hierarchy

Exact names may change after local inspection, but preserve separation of responsibilities.

```text
FreightBayPrototype
├── Architecture
│   ├── BayShell
│   │   ├── FloorDeck
│   │   ├── BackWall
│   │   ├── SideWalls
│   │   └── CeilingFrame
│   ├── PermanentBarrier
│   └── StaticCollision
│
├── ShutterAssembly
│   ├── ShutterVisual
│   ├── ShutterCollision
│   └── AnimationPlayer
│
├── PresentationRoot
│   └── LootPileRoot
│
├── PresentationMarkers
│   ├── PileBounds
│   ├── DeckPlane
│   ├── SpawnVolume
│   └── ReachEnvelope
│
├── ApronInteraction
│   └── DrainabilityViewpoints
│
├── CueNodes
│   ├── WarningLights
│   └── AudioAnchors
│
└── FreightBayPresenter
```

Temporary settle proxies do not live in this runtime scene.

### 9.4 Scene-authoring workflow

Stage B must not begin until Stage A is closed and the developer has provisioned candidate local building-block assets.

After assets exist locally:

1. Codex performs read-only inspection of candidate meshes/pivots/dimensions.
2. Codex reports whether the available set is sufficient.
3. Codex assembles the first structurally correct dedicated freight-bay scene.
4. Developer visually tunes dimensions/composition in Godot.
5. Codex reconciles structural requirements with approved manual adjustments.

Codex owns initial hierarchy/logic; human visual judgment remains authority for composition.

Do not build the bay ad hoc under `main.tscn` unless needed for a brief sketch. The preferred implementation is a dedicated scene instanced into main.

---

## 10. Presenter state machine and cue hooks

The presenter state machine is authoritative for audio/light/animation cue sequencing.

```text
SEALED_EMPTY
→ ARRIVAL
→ SEALED_READY
→ REVEALING
→ OPEN
→ CLOSING
→ SEALED_EMPTY
```

### 10.1 Intended cue use

- `ARRIVAL` → warning lights, motor/cable/rattle/creak sequence.
- `SEALED_READY` → arrival impact complete; pile already available behind closed shutter.
- `REVEALING` → shutter animation/unlock cue.
- `OPEN` → Receiving loot interaction enabled.
- `CLOSING` → interaction disabled; shutter closes; departure cues may begin.

The state machine must not infer state from door position or elapsed audio time.

No actual lift deck/wall movement is required.

---

## 11. Freight-bay presentation profile

Pile preparation must not depend directly on decorative runtime scene geometry.

Use a shared authored `FreightBayPresentationProfile` describing the geometry contract required by both preparation and presentation.

Conceptually:

```text
FreightBayPresentationProfile
  profile_id
  revision

  pile_bounds
  deck/support_plane
  settle_spawn_volume
  temporary_proxy_collision_envelope
  barrier_side_reach_envelope
  drainability_viewpoints
  validation_tolerances
  fallback_layout_definition/version
```

A prepared batch records profile ID/revision so saved transforms cannot be silently interpreted against incompatible bay geometry.

---

## 12. Hidden pile preparation architecture

Pile settling must occur in an **isolated staging environment**, not inside the live freight bay.

This is necessary because a future batch may be prepared while another batch is still visible in Receiving.

### 12.1 Isolation guarantee

Temporary settle proxies must never interact with:

- player;
- live bunker physics;
- visible freight-bay contents;
- runtime WorldItems.

Exact Godot mechanism is left to local Codex inspection. A dedicated isolated World3D/SubViewport-like staging context or another rigorously isolated approach is acceptable.

The architecture requirement is isolation, not a prematurely mandated engine trick.

### 12.2 “Async” interpretation

Preparation may be time-decoupled from delivery, but does not require multithreaded Godot physics.

A preparation job may advance across ordinary frames whenever convenient before delivery.

---

## 13. Hybrid hidden-settle pipeline

Preferred path:

```text
CONTENT_COMMITTED
  ↓
instantiate temporary proxies
  ↓
seeded initial scatter
  ↓
hidden temporary rigid-body settle
  ↓
stability detection
  ↓
validate frozen candidate
  ↓
accept OR retry with derived attempt seed
  ↓
if bounded retries exhausted → deterministic fallback
  ↓
capture PresentationRoot-local transforms
  ↓
destroy every temporary physics proxy
  ↓
atomic arrangement commit
  ↓
PREPARED
```

### 13.1 Attempt seeds

Presentation retries preserve:

- batch ID;
- item identities;
- definitions;
- content seed.

Retry layout variation may derive from:

```text
presentation_seed + attempt_index
```

The physics trajectory is never gameplay authority; accepted final transforms are.

### 13.2 Settle completion

Do not rely on a blind fixed delay.

Candidate becomes eligible for validation when:

- all proxies remain in valid preparation volume;
- linear/angular velocities remain below thresholds for a continuous stability window;
- maximum preparation duration has not expired.

Timeout/numerical escape rejects the attempt.

---

## 14. Frozen-pile validation

A candidate pile must pass four validation classes.

### 14.1 Containment

- every item inside authored pile bounds;
- no severe deck/wall/ceiling penetration;
- no obvious unsupported/floating impossible state beyond tolerance.

### 14.2 Representation integrity

- exactly one result per committed remaining entry;
- finite/sane transforms;
- correct presentation profile revision.

### 14.3 Interaction envelope

- the deepest legal item location must fall inside the authored Receiving interaction envelope;
- freight-bay reach may differ from shelf reach;
- this must not globally enlarge storage interaction distance.

### 14.4 Progressive drainability

Temporary layered occlusion is explicitly allowed.

The pile need not expose every item at reveal.

However, the full frozen pile must be drainable through successive visible/targetable TAKE interactions without reactivating physics.

Use a conservative iterative simulation based on a small authored set of apron-side viewpoints/rays approximating the existing player targeting rules:

1. identify currently targetable entries;
2. virtually remove them;
3. repeat against remaining frozen geometry;
4. if entries remain and no progress is possible, reject the pile.

Do not build a general 3D accessibility solver without evidence this conservative method is insufficient.

Human testing and fallback statistics determine whether future refinement is warranted.

---

## 15. Deterministic fallback

After a bounded number of rejected hidden-settle attempts, use a conservative deterministic fallback layout.

Fallback must guarantee:

- same committed batch content and identities;
- containment;
- non-catastrophic overlap;
- full progressive drainability;
- reproducibility;
- no runtime rigid-body state.

Where safe, use seeded orientation/offset variation so fallback does not necessarily look perfectly aligned.

Fallback must be invisible as a concept to the player.

If the guaranteed fallback itself fails, treat that as a development error rather than silently mutating batch contents.

---

## 16. Freeze boundary and final WorldItem representation

“Freeze” means replacement, not sleeping physics.

For each accepted entry:

```text
committed item identity
→ temporary settle proxy
→ accepted frozen transform
→ destroy proxy
→ instantiate ordinary WorldItem using same ItemInstance identity
```

No RigidBody, latent velocity, sleeping body, or residual physics ownership remains in the playable world.

The visible elevator pile consists only of ordinary deterministic WorldItems parented beneath the runtime `LootPileRoot`.

WorldItems reconstruct from committed presentation-local transforms on reveal/load.

---

## 17. Interaction contract

The freight bay is **not a StorageSurface**.

It supports only:

**LMB / TAKE** → transfer active Receiving loot to carried bundle.

It never supports:

- E/PUT into Receiving;
- manual arrangement inside Receiving;
- zoning;
- player-authored storage;
- returning carried items to the pile.

### 17.1 Legitimate physical WorldItem contexts

There is no permanent generic loose-floor loot context.

Relevant physical contexts are:

```text
Receiving WorldItem → freight-bay pickup context/range
Stored WorldItem    → storage pickup context/range
```

The current pre-seeded prototype-world registration may temporarily retain generic handling during migration, but it is not a target gameplay state.

### 17.2 Same targeting grammar, contextual reach

Reuse the existing WorldItem targeting/raycast system.

Do not create a special elevator selection UI.

Freight-bay interaction may use a separate authored pickup reach because the bay depth/barrier differs from shelf geometry.

The raycast/query may search far enough to discover Receiving targets, but legality remains target/context-specific so ordinary storage interactions do not inherit exaggerated range.

### 17.3 Materialization timing

Final WorldItems may reconstruct while the shutter is still closed so reveal cannot expose pop-in.

Interaction is state-gated:

```text
SEALED_READY  → visuals exist, pickup disabled
REVEALING     → pickup disabled
OPEN          → pickup enabled
CLOSING       → pickup disabled
```

---

## 18. Receiving ownership transfer transaction

Pickup should remain transactional.

Conceptually:

```text
LMB target
  ↓
carried_items.can_add(exact ItemInstance)
  ↓
add exact ItemInstance to carried bundle
  ↓
ReceivingManager.release_entry(batch_id, entry_id, item_instance_id)
  ↓
success → destroy visible host / entry leaves Receiving
failure → rollback carried addition
```

`ReceivingManager.release_entry()` must verify:

- batch is active;
- entry belongs to active batch;
- entry remains owned by Receiving;
- durable identity matches.

Duplicate interaction must never duplicate an item.

Final active entry removal emits the drained event that begins presenter closing.

---

## 19. Observability and preparation diagnostics

Collect structured debug evidence per preparation job.

Suggested fields:

```text
batch_id
content_seed
presentation_seed
target_bulk
actual_bulk
item_count

attempts_used
accepted_via_physics
fallback_used
preparation_duration_ms

rejection_counts_by_reason:
  escaped_bounds
  unstable_timeout
  invalid_penetration
  invalid_transform
  drainability_deadlock
  other

accepted_drain_iterations
accepted_profile_revision
```

Aggregate session metrics should include:

```text
batches_prepared
physics_accept_rate
fallback_rate
mean_attempts
p95_preparation_time
rejection_reason_distribution
```

Do not define a hard fallback-rate threshold before evidence.

Use metrics to determine whether problems are best solved by:

- bay geometry changes;
- reach changes;
- validator tuning;
- content breadth;
- settle tuning;
- preparation-system redesign.

Separate **preparation cost** from **front-end delivery latency**. Early preparation may make a multi-second backend job irrelevant to the visible player experience.

---

## 20. Failure handling

The system fails closed.

### 20.1 Batch content creation

Reject before commitment on:

- invalid pool entry;
- missing ItemDefinition;
- duplicate durable item identity;
- impossible generator state;
- malformed seed/config.

After `CONTENT_COMMITTED`, content is immutable.

### 20.2 Pile preparation

Reject/retry on:

- escaped item;
- unstable timeout;
- invalid transform;
- severe penetration;
- failed drainability.

Bounded retries then use fallback.

### 20.3 Receiving deposit

Fourth physical deposited batch is rejected without queue mutation.

Future expedition integration maps this to Awaiting Lift.

### 20.4 Reconstruction/profile mismatch

`PREPARED` batch with matching presentation profile revision reconstructs directly.

Profile mismatch must never silently reinterpret old transforms.

Prototype may fail loudly and require explicit migration or unrevealed regeneration.

A revealed arrangement is never casually regenerated.

---

## 21. Implementation stages

### Stage A — data/lifecycle foundation

No physical elevator gameplay required.

Implement:

- externally supplied durable ItemInstance identity;
- LootBatch / LootBatchEntry;
- two-phase content/arrangement commitment;
- three-slot ReceivingManager model;
- explicit 40-ID PrototypeLootPool;
- seeded Bulk-budget PrototypeLootSource;
- content/presentation seeds;
- FreightBayPresentationProfile schema;
- pile-preparation job interface/state;
- structured diagnostics;
- saveable/serializable batch representation and reconstruction tests.

#### Stage A verification

Automated tests prove:

- identity survives reconstruction;
- one entry = one physical item;
- deterministic content generation;
- exact intended 40-ID pool;
- Gloves/Pants excluded;
- no authoring-manifest runtime dependency;
- retries do not change content;
- atomic CONTENT_COMMITTED → PREPARED;
- incomplete arrangement work is disposable;
- first deposited batch active;
- next two FIFO queued;
- fourth rejected atomically;
- PREPARED-but-undelivered batches consume no slots;
- ownership/drain accounting works;
- diagnostics do not influence gameplay state.

#### Stage A exit criteria

- all lifecycle/identity/queue tests pass;
- generator reproducible over 40-item pool;
- batch data safely serializable/reconstructable;
- no physical freight-bay assets required;
- minimal/no human gameplay evidence needed.

**STOP after Stage A.**

The developer then provisions candidate freight-bay building-block meshes in the authoritative local project.

---

## 22. Stage A → Stage B asset-provisioning checkpoint

Stage B must not begin until candidate assets exist locally.

Codex performs read-only preflight and reports:

- floor/wall/ceiling candidates;
- shutter/door candidates;
- barrier/rail candidates;
- warning-light candidates;
- dimensions/pivots/transform health;
- missing pieces, if any.

If sufficient, Codex proposes and assembles the first dedicated `FreightBayPrototype` scene.

Developer visually tunes proportions/composition before deeper pile tuning.

This checkpoint is intentionally separate from Stage B gameplay implementation.

---

## 23. Stage B — single physical batch gate

Stage B validates the highest-risk physical presentation.

Add:

- dedicated freight-bay prototype scene;
- Receiving apron;
- permanent barrier;
- shutter;
- presentation root / LootPileRoot;
- presenter state machine and cue hooks;
- isolated preparation rig;
- seeded scatter;
- hidden temporary rigid-body settle;
- stability detection;
- containment/representation/drainability validation;
- retry logic;
- deterministic fallback;
- atomic transform commitment;
- exact reconstruction;
- ordinary WorldItem materialization;
- contextual freight-bay pickup reach;
- TAKE-only transfer;
- reproducible manual debug delivery trigger;
- diagnostic controls and statistics.

Underlying manager still supports three slots, but Stage B playable delivery uses only one deposited batch at a time.

### 23.1 Stage B validation question

> Can the 40-item eligible catalogue reliably produce disorderly, believable, fully drainable frozen piles that feel good to cherry-pick from the Receiving apron?

### 23.2 Stage B exit criteria

Repeated representative seeds/Bulk budgets demonstrate:

- disorderly piles plausibly read as returned loot;
- accepted physics/fallback piles fully drain;
- targeting remains intuitive;
- deepest legal items remain reachable;
- player cannot enter/interfere with freight bay;
- shutter/cue sequencing reads clearly;
- no reveal pop-in;
- frozen piles never move/re-settle;
- committed transforms reconstruct exactly;
- metrics reveal accept/fallback/preparation behavior.

Possible outcomes:

- **PROMOTE**
- **REVISE PROFILE/CONTENT**
- **REVISE PREPARATION SYSTEM**

Only PROMOTE proceeds to Stage C.

---

## 24. Stage C — three-slot Receiving pressure

Enable the already-modeled queue physically.

Add:

- one active/visible batch;
- two deposited queued batches;
- FIFO promotion;
- rejection of fourth physical deposit;
- next-batch theatre after prior shutter closure;
- synthetic/debug delivery sequences;
- queue-state debug/readout;
- repeated throughput playtests.

No expedition simulation is required.

### 24.1 Stage C validation questions

- Is the three-batch physical capacity understandable?
- Does it create useful Receiving pressure?
- Is sequential arrival theatre too slow/repetitive?
- Does unloading throughput remain manageable across mixed batch sizes?
- Do bay dimensions/reach remain effective across repeated heterogeneous loads?

### 24.2 Stage C exit criteria

The Receiving lifecycle is reliable and ready for future expedition-produced PREPARED batches.

---

## 25. Explicit non-goals

Do not add during this milestone:

- expedition simulation;
- destination loot tables beyond prototype pool;
- requests;
- salvage/incineration;
- global day clock;
- full ironman/save-slot implementation;
- production-final elevator art;
- player access to freight bay;
- PUT/storage into Receiving;
- arbitrary floor drops;
- unrestricted loose WorldItem state;
- runtime rigid-body loot;
- manual pile rearrangement;
- generalized delivery/job framework beyond the Receiving boundary;
- new storage mechanics;
- changes to validated stacking/Auto Group architecture.

---

## 26. Future expedition integration

The architecture intentionally allows expedition outcome preparation to occur long before delivery.

Once an expedition becomes outcome-committed and no longer player-influenceable, the backend may:

- generate the final batch;
- commit individual item identities;
- prepare/freeze its pile;
- reach PREPARED state;

at any convenient time before expedition return.

This work does **not** consume Receiving capacity.

At actual return/deposit time:

- if capacity exists → prepared batch enters Receiving;
- if three deposited slots are occupied → expedition remains Awaiting Lift.

This optimization is optional and should be used only if profiling indicates meaningful benefit.

---

## 27. MVP completion definition

The Receiving/Elevator MVP is complete when:

1. deterministic committed batch content exists independently of presentation;
2. durable item identity survives from generation through TAKE/storage;
3. a PREPARED batch can be reconstructed exactly without physics;
4. physical pile generation is isolated, bounded, observable, and fallback-safe;
5. the freight bay presents disorderly but fully drainable frozen loot without player/pile physics interaction;
6. the full one-visible/two-queued deposited lifecycle works reliably;
7. Receiving accepts future upstream PREPARED batches without knowing how they were generated;
8. the system is ready for the next roadmap step: attaching the validated physical item loop to the first real timed survival obligation.

