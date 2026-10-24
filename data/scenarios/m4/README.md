# Sorting Apocalypse — locked M4 baseline
## M4-2026-10-24-R1 · 24 October 2026

**HUMAN-APPROVED M4 STARTING SET / LOCAL IMPLEMENTATION NEXT / NOT IMPLEMENTED OR PUBLISHED**

The developer approved the reviewed v0.3 values and the Day 2 lunch allocation repair, and instructed that further tuning follow in-game playtests. This packet consolidates those approvals; it does not propose new values, expand the catalogue or reopen calibration.

## Use

Give the complete packet to a fresh local Codex session at High reasoning effort. Start with `Sorting_Apocalypse_Codex_M4_Implementation_Handoff_24Oct2026.md`. Local execution is the intended next step; no merge/push/publication is authorized.

| File | Purpose |
|---|---|
| `Sorting_Apocalypse_Codex_M4_Implementation_Handoff_24Oct2026.md` | Bounded implementation contract, ownership guidance, preservation, tests and stopping point |
| `Sorting_Apocalypse_M4_Locked_Baseline_24Oct2026.json` | Exact approved 167-item values, all 85 seed entries, twelve ordered delivery manifests, requests and repaired analytical example |
| `Sorting_Apocalypse_M4_Locked_Baseline_24Oct2026.csv` | Flat ID-keyed item values for inspection/authoring |
| `SHA256SUMS.txt` | Delivered-file checksums |

## Frozen numerical contract

- **20** player Bulk; **28** raw Bulk per scavenger.
- Per member: **Food 12 / Hydration 12 / Medical 6 / Weapons 12 / Protection 12**.
- Main fixture: **16 Ready → four four-person teams**. Fill full teams first; at most one remainder, no independent team-count cap.
- **06:00–10:00** preparation, **06:00–00:00** day; **2.5 real minutes/game hour**.
- Kitchen: Breakfast F48/H40, Lunch F60/H48, Dinner F60/H48, at 10:00/14:00/18:00 with three-hour windows.
- Medical: Day 1 07:00–10:00/24; Day 2 09:00–12:00/36; Day 3 17:00–20:00/48.
- **85 items / 240 Bulk** starting stock; **four 16-item deliveries per day**, daily Bulk **244 / 257 / 271**.
- All reviewed values remain intact, including the six reductions: 011 Food66, 046 Food58, 049 Food74, 080 Hydration70, 081 Hydration54, 163 Food72.
- Day 2 lunch proof repair uses the **existing** pumpkin 066/token SEED:020 after the corn sack, not extra supply.

The inherited score rationales are not execution rules. In particular, the large carcass's irregular Footprint does not imply much more edible food than the roast piglet. Do not re-inflate its approved 72, automatically reduce other values by a waste threshold, or enlarge requests/carrying to preserve an earlier estimate. Lock means an M4 test baseline, not permanent release balance.

## Data contract and time interpretation

`approved_items` contains the only item values to apply. `destinations` are logical routing requirements, not automatically inferred Storage Categories or an obligation to add a Bunker Ops consumer. Source geometry and accepted physical fields come from the actual local definitions, not this data export.

`scenario.seed` is the complete initial item-definition manifest. `scenario.manifests` contains one entry per delivery, with the exact ordered `path`. Repeated definition IDs represent distinct runtime instances. Seed and witness tokens are analytical identities, not production IDs.

`scenario.runtime_events` groups request targets with **day index and local seconds of day**, suitable for explicit mapping to the existing scenario interface. It does not encode the engine clock's elapsed-time unit. The witness's `open`, `deadline` and supply `available` values use full **24-hour calendar hours from Day 1 00:00**. They must not be copied into compressed gameplay elapsed seconds.

The half-hour supply-availability allowance belongs only to the numerical proof. Do not implement an extra 30-minute delay, auto-admission or auto-unloading. Actual receiving/theatre/queue readiness still controls availability.

`scenario.witness` is **an example of manual allocation**, not a gameplay script or promised player strategy. The approved repair changes only that example. Seed, manifests, request amounts and times are otherwise unchanged. `named_loadouts` are review/test examples, not recommendations shown to players.

## Fresh consolidation checks

All 167 ID/name/lane/Bulk/Utility rows were read from the reviewed workbook and matched. Exactly six Utility cells differ from the earlier v0.3 JSON; no Bulk differences. Seven retired IDs are absent.

The 21 named loadouts were replayed against those numbers. The repaired example was replayed for **81/81 fulfilled lane obligations, 211 uniquely consumed tokens, no double spending, timely source availability under the stated allowance, and all twelve team capacity limits**. Day 1 Dispatch uses starting stock only. Remaining inventory is **66 items / 234 Bulk**. Wasted Utility by lane is Food55, Hydration51, Medical25, Weapons10, Protection22; these are not summed into a universal score.

This is data consolidation and arithmetic verification, not fresh optimization, real-time route testing, physical setup validation or a Godot run. The prior optimization history is attributed, not reported as rerun.

## Repository and physical-approval boundaries

Read-only remote verification during preparation found `main` at `3bb69a906e921f06dd12c61bd4d8f33db35d6fce`. The reported local 167-item candidate is `71101cf6bd6302842e7c7090a0849b25ef9b75a5`. The executor must verify its exact local ancestry and branch state, preserving the developer checkpoint. No local state is inferred from the remote read.

The twelve top-up scales have been explicitly approved. Their separately recorded Auto Stack Group approvals remain outstanding; saved None is preserved. Numerical approval does not silently mark those group reviews accepted or authorize publication. M4 can be implemented locally from the candidate without another content-review cycle.

No source workbook/JSON, item definition, asset, master document, save, Git branch or remote was modified while making this packet.

## Numerical input fingerprints

- `Sorting_Apocalypse_M4_Expanded_Catalogue_Calibration_v0.3 - reviewed.xlsx`: `12fa4c2deaa0756d4fe3a5b88c6271002d422ac61cbb6456bfd4aaa7721f82bd`
- `Sorting_Apocalypse_M4_Expanded_Catalogue_Calibration_v0.3.json`: `58c9f7274d9897f5be5da56609333af36f68ee2b23c1a94a583482e73c33b747`
- `Sorting_Apocalypse_M4_v0.3_Reviewed_Workbook_Checks_24Oct2026.json`: `b57b0df3584c38ebfaa5688e2b7dc072ab6cb8edee4c8852c2160fb2a011c1af`

The approved workbook remains a human-editable input source. Its static descriptions/old example allocation are not the consolidated execution authority. Use this packet for the reviewed values plus approved repair; do not accidentally implement the earlier 96-Food carcass or the stale single-corn-sack lunch example.
