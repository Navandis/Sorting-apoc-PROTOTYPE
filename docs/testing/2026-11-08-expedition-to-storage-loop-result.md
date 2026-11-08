# Expedition-to-Storage Loop Result

**8 November 2026 · HUMAN-ACCEPTED / CLOSED IN ITS BOUNDED SCOPE · Local checkpoint / publication pending**

F5 New Run now starts with the authored loose palette and eight Ready scavengers. A single persistent preparation supports one to four members, five supply lanes and two affinities. Explicit Dispatch commits the trip and its cargo. The expedition releases its destination at return, and healthy crew members become Ready when Receiving admits their cargo or when an empty trip returns. The original two scripted hauls are retained in the isolated collection-goal test.

- Accepted base `a1d1db4494347e0dfb4dfb653ed71b2abaf76ce5` was clean in the asset-equipped checkout. The runtime and test diff is local commit `66a7f863e5cf6f2f2c9e8f7f34de99885fa76612` on `codex/expedition-to-storage-loop`. Technical verification and its documentation were recorded at `11f95354119058fe2ec90796d09e2c28c046a885`. [Approved brief](../superpowers/plans/2026-11-07-expedition-to-storage-loop.md) · [Foundation closure](2026-11-07-continuous-run-collection-goal-closure.md).
- `gameplay/expeditions/` owns draft, personnel, sampling, committed trips, Dispatch UI and expedition validation. The contribution request and carry transfer still commit whole items. The wing and run shell route input, pause, time and saves. Receiving owns the admitted cargo and existing lift presentation.
- Schema 6 extends the existing codec and service at `user://saves/collection/`. The launch screen explains incompatible schema 5. Confirmed New Run can replace the active pointer while retaining its incompatible snapshot file. M4 remains in its separate slot.

## Provisional test configuration

Revision 1 starts with 8 healthy Ready scavengers and a fresh draft of 1 member with no affinities. Each member adds 8 Bulk and lane targets of Food 5, Hydration 3, Medical 4, Weapons 4 and Protection 6. Maximum return budget is 32 Bulk and the minimum item Bulk is 2, so a haul has at most 16 entries. Duration is uniform from 90 through 180 active seconds. The live collection target is 6 Utility per category.

The sampler gives the two affinities weight 9 each and the other six weight 7 each. That is 15% per affinity and 7/60 per other category before fit filtering. It removes categories with no fitting item and chooses uniformly among fitting definitions within the drawn category. Dispatch commits the exact manifest, identities, duration and MainDeck arrangement.

| Category | Pool definition, authored Utility / Bulk | Pool definition, authored Utility / Bulk |
| --- | --- | --- |
| Electronics | `loot_000004` Old Phone, 6 / 3 | `loot_000122` Old Laptop, 24 / 3 |
| Food | `loot_000007` Cereal Box, 12 / 2 | `loot_000045` Smoked Sausage, 14 / 2 |
| Fuel | `loot_000013` Firewood Piece, 4 / 2 | `loot_000164` BBQ Charcoal Bag, 10 / 3 |
| Hydration | `loot_000020` Milk Carton, 6 / 2 | `loot_000075` Apple Juice, 8 / 2 |
| Medical | `loot_000127` Saline Solution, 7 / 2 | `loot_000028` Med Kit, 24 / 4 |
| Morale | `loot_000031` CDs Stack, 12 / 2 | `loot_000129` Coffee Tin, 18 / 2 |
| Protection | `loot_000033` Work Boots, 7 / 2 | `loot_000035` Hard Hat, 8 / 2 |
| Weapons | `loot_000039` Pistol, 16 / 2 | `loot_000084` Cleaver, 10 / 2 |

The one-member zero-capacity recipe used Cereal Box, Cola Can, Antibiotics, Pistol and Work Boots. Bread Loaf, Milk Carton, Bandages and Hard Hat left one Bulk, too little for the pool. Both used the original palette and ordinary contribution rules.

## Executed verification

Godot `4.7.stable.official.5b4e0cb0f` ran with isolated temp save directories and redirected application data. All fourteen focused scripts, editor import and configured launch exited 0. Headless scripts used `--headless --path . --script res://tools/asset_pipeline/tests/<name>.gd`. Startup parity received `--m1-save-dir=<temporary directory>`.

| Proof | Observation |
| --- | --- |
| `expedition_operations_tests` | Draft count, canonical 28 pairs, exact weights and fit draws, whole-item credit and waste, failed first supply, locked formation, explicit and stale Dispatch, atomic planner rejection, deposit ownership and malformed Away deck rejection. |
| `collection_continuation_tests` | 136 checks. Exact draft, receipt, Away, Awaiting, deposited and completed states. Tied returns matched across ordinary and large steps. Two crews waited from one destination. Zero and unfillable trips left both queues intact. Active, queued and delayed deposit observers saw coherent crew state. Valid receipts preserved spent cargo, and malformed ownership and roster data rejected. [Continuation log](evidence/expedition-to-storage-2026-11-08/continuation.log). |
| `expedition_physical_tests` | Headless and native Compatibility at 1280×720. Native F, E and mouse TAKE exercised the player input path. Dispatch controls used button signals, and shelf placement used the production placement command. One-member and four-member trips yielded 3 items at 7 Bulk and 13 items at 31 Bulk. All reached qualifying storage. The clock advanced 1.205 s with Dispatch open. The CRT reported OPEN and one queued deposit. |
| Presentation | 16 homogeneous maximum-count arrangements and 16 mixed seeds prepared on MainDeck. Three 16-item extremes, all Cleavers, all Work Boots and all Cereal Boxes, drained through progressive production reticle/TAKE. Furthest measured TAKE was 1.731 m with the existing 3.4 m reach. [Native log](evidence/expedition-to-storage-2026-11-08/native-compatibility.log) · [Dispatch](evidence/expedition-to-storage-2026-11-08/dispatch-preparation.png) · [Receiving](evidence/expedition-to-storage-2026-11-08/receiving-expedition-open.png). |
| Foundation regressions | `collection_goal_tests` repeated the 12-item fixture, qualifying/excluded storage, zone independence and the eight-target win at 144.25 active seconds. `continuous_run_foundation_tests`, all three affected Receiving scripts, M1/M3 contributions, M1 pause admission, startup parity, storage command validation and seed fixtures passed. |
| Save and document checks | Minute and first-victory attempts, coalescing, recovery after failed saves and incompatible-slot preservation passed. GDD and MVP changed Word blocks matched their generated reading copies. LibreOffice rendered 49 and 50 pages respectively. Affected pages were inspected. |

The initial behavior test failed on the missing expedition owner. Follow-ups corrected a typed-array error when validating retired cargo and fixed test probes for headless mouse capture, camera restoration, and lift observation timing. The independent read-only reviewer identified deposit notification ordering, out-of-bounds saved cargo and selected-count highlighting. The two state failures were reproduced, corrected and retested. Count choices now use a mutually exclusive button group. Logs retained the baseline Windows certificate-store and known held-material diagnostics, plus deliberate malformed fixture, preparation and failed-save diagnostics.

Successful synchronous autosave samples took 51.1–84.0 ms including capture. Samples with expedition history and cargo took 70.3–84.0 ms on this machine. The accepted foundation recorded 55.7–63.7 ms on its workload. Short silent Windows suspensions and release crash durability retain their foundation limits.

## Protected saves

The SHA-256 values below matched before and after implementation testing for the M4 and schema-5 files in the developer's roaming Godot profile. The temp-slot tests verified that confirmation repoints the slot and preserves the incompatible snapshot. Current schema-6 progress may have advanced during developer play.

| Path relative to the real saves directory | SHA-256 |
| --- | --- |
| `active-slot.json` | `4159CE329A1EAC5CC539D915446CB45A531FC6057B1FD73E6B2EDD5528045B63` |
| `Save_341c889e7e8615bdfd79ea00_251026-17-33.json` | `0EE5AF7408DFC0EC4435C4CF4D890DE54F50C9EAA6D2F56B7D8E60D93E65E168` |
| `collection/active-slot.json` | `8370F655632271A94E9568C5FE6FD15E03F45FC8072763455FD811679A509A73` |
| `collection/Save_a0dc0071dd2ff3fbf82d0dd1_071126-22-07.json` | `C2C4E88CB3BC8A9BF3F44A1DC8473294524C2C5C6F902E6704B8ADE724257944` |

## Developer acceptance

On 8 November 2026 the developer accepted the Expedition-to-Storage Loop in its agreed scope after in-game play. The following are the developer's observations.

- Crew count, affinity selection, Dispatch eligibility, and draft choices through panel close and reopen worked as expected.
- Accepted contributions locked the crew count and allowed affinity changes before dispatch.
- Departures with zero, partial and full provisioning worked, with correct remaining capacity. A zero-return-capacity departure attempt displayed the warning.
- Lift delivery and queuing worked, including Awaiting Lift. Personnel became available at the expected triggers.
- Zero-loot returns bypassed the lift queue, used zero deposited slots and caused no empty lift journeys.
- Save/Continue worked during preparation, Away travel, active delivery and Awaiting Lift.
- The developer noticed no pause, stutter or lag from autosaves in the tested sessions. The synchronous timings above remain the measured evidence. Large-stock performance remains unverified.
- Live collection progress and victory remained correct.

Production balance, economic benefits of provisioning, full-catalogue cargo generation, injuries and treatment, recruitment, recurring services, progression, a full Journal and release durability remain outside this acceptance.

## Open furniture movement collision follow-up

The developer reported ineffective player movement collision at these seven wing-relative paths during the playtest. At the time of the report, the cause, introduction date and presence or absence of collision nodes were unverified. Other walls, proxies, Receiving decoration and elevator components, and the ladder-served modular rack were outside the reported affected set. The separate repair is technically verified and awaits developer retest. [Furniture collision repair result](2026-11-08-furniture-collision-repair-result.md).

```text
DevelopmentSetup/Tables/SM_Table_SeedWest
DevelopmentSetup/Tables/SM_Table_SeedEast
DevelopmentSetup/Tables/SM_Table_Palette_Food
DevelopmentSetup/Tables/SM_Table_Palette_Hydration
FunctionalFixtures/SM_ventilated_locker_GalleryC_West
FunctionalFixtures/SM_MetalShelves_GalleryA_West
FunctionalFixtures/SM_MetalShelves_GalleryB_North
```

## Checklist supplied for developer playtest

This is the original handoff checklist. The observations above record what the developer reported.

1. Use F5 and choose **New Run** if you want to replace the active continuation. Aim at the Dispatch counter in the Receiving annex and press **F**. Select a crew count and one affinity, close and reopen, and check both values persist and Dispatch stays disabled.
2. Carry an eligible item and press **E** once in Dispatch. Check the full Bulk charge, applied credit and waste. Change the affinities after the count locks. Use **ESC** to close the panel, then **ESC** again for **Save & Exit**. Continue and check the partial preparation.
3. Select two affinities and dispatch. Prepare another crew immediately and send it with zero loadout. Save and continue while a crew is away. For the zero-capacity warning, use the one-member recipe above in a fresh preparation. Back out once, then confirm departure and watch for the empty-return notice.
4. To observe a waiter, leave the first haul OPEN and return four one-person crews before unloading. Check the CRT counts two deposits and Dispatch shows a crew Awaiting Lift. Its destination can be used again. Save and continue with a waiter if convenient. Unload the active deck and let the lift finish the outbound leg. Confirm the oldest waiting crew becomes Ready on admission and can be reused.
5. Take expedition goods and place them in qualifying storage. Check the live totals and the first completion time. Move a qualifying item back to carry after completion and check that its Utility drops from the live total while the completion time stays fixed.
