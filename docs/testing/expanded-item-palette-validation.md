# Expanded item-palette validation

**Status:** Technical checks complete; stop for human review. This is a saved editor-authored development setup expansion, not a palette UI, production inventory, height revision, or Receiving work. It follows the deployed [AI working guidelines](../AI_WORKING_GUIDELINES.md). Model and reasoning effort are unavailable from this session's exposed runtime.

## Scope and preservation

- `wing_gameplay.tscn` retains its fourteen pre-existing direct `DevelopmentSetup/SeedItems` hosts, including their host and Visual-child transforms.
- Thirty-two new direct hosts extend the live scene from eight represented eligible types to all forty eligible catalogue types. `loot_000015` Fuel Canister is included. `loot_000034` Gloves and `loot_000036` Pants remain absent and blocked.
- `development/seeded_storage_setup.tscn` remains the separate, unchanged twelve-host regression fixture.
- The physical-arrangement correction consolidates the additions from seven new `SM_Table` instances to four (nine tables total before, six now). The original two tables remain untouched. The retained additions are direct children of `DevelopmentSetup/Tables`, retain their existing collision, and receive no `StorageSurface`, zoning, or PUT behavior. The twelve functional shelf surfaces remain empty.
- New hosts are compactly mixed across the four retained tables in the existing development staging bay: Food/Fuel, Electronics/Medical/Hydration, Fuel/Morale/Protection, and Weapons. All use canonical scale, the existing `seed_host.gd`, the shared `SeedRegistrar`, and a single matching imported Visual.

## Added ID-to-host map

| IDs | Hosts |
| --- | --- |
| 000001–000004 | `Electronics_ComputerMouse`, `Electronics_ComputerTower`, `Electronics_Device`, `Electronics_Phone` |
| 000006, 000008–000012 | `Food_Bread`, `Food_DryGoodsA`, `Food_DryGoodsC`, `Food_DryGoodsG`, `Food_PigCarcass`, `Food_Watermelon` |
| 000013–000018 | `Fuel_Firewood`, `Fuel_FirewoodPile`, `Fuel_Canister`, `Fuel_GasCanister`, `Fuel_GasCylinder`, `Fuel_PropaneTank` |
| 000019–000021 | `Hydration_FoodCan`, `Hydration_MilkCarton`, `Hydration_OrangeJuice` |
| 000024–000027 | `Medical_Painkillers`, `Medical_Antibiotics`, `Medical_Bandages`, `Medical_CoughSyrup` |
| 000029, 000032, 000033, 000035 | `Morale_Ball`, `Protection_Armor`, `Protection_Boots`, `Protection_HardHat` |
| 000038–000042 | `Weapons_AssaultRifle`, `Weapons_Pistol`, `Weapons_Shotgun`, `Weapons_Hammer3`, `Weapons_TennisRacket` |

To edit a type, select its named direct child under `DevelopmentSetup/SeedItems`, change only its `item_id` together with its one matching Visual instance, and retain a unique host name. The registrar derives the runtime identity as `wing_seed_v1:<host name>`.

## Checks run

Using `D:\AI Tools\Godot-4.7-Codex\Godot_v4.7-stable_win64_console.exe` (4.7.stable.official.5b4e0cb0f):

1. `wing_gameplay_composition_tests.gd` — PASS after the arrangement correction. The existing live-palette assertion still covers all eligible catalogue types without a host-count quota; it checks blocked-type absence, matching ID/Visual pairs, distinct runtime identities, one registered owner per host, collision-only tables, Fuel and Computer Tower handling, and a temporary Fuel host move/save/reload.
2. Focused transformed-bounds inspection — PASS. All four added table extents clear the walls, columns, original furniture, and one another. Each added visual rests just above its tabletop (about 4–5 mm), stays within its assigned tabletop, and has no pairwise visible-bounds intersection.
3. Focused player-access inspection — PASS. In the running scene, every one of the 32 added `WorldItem` pickup areas was acquired by the real player controller's 1.4 m ray at its normal 1.716 m camera height and 75° FOV, from a collision-free walking position connected to the normal player start; its neighbours remained present. This was a temporary inspection script, not a new project test harness.
4. Normal renderer launch and three review captures — PASS. One above view and two normal-height/FOV views were inspected; the roof was hidden only for the above view.
5. `git diff --check` — PASS.

Each Godot invocation retained the known Windows root-certificate diagnostic. The fixture and composition suites also intentionally emit named invalid-declaration or duplicate-namespace diagnostics while exiting successfully with their `PASS` marker; no unexpected assertion was observed.

## Human review gate

Focused human review: assess compactness, table/wall clearances, walking lanes, and normal-input pickup feel with all neighbours present. The saved composition, identities, registration, collision-only table behavior, and editor reload preservation are already covered above. This correction does not change heights, storage rules, production art, or start Receiving.
