# Continuing wing — F6 developer-grid validation

**Validated:** 18 September 2026
**Branch:** `codex/wing-storage-bridge`
**Task start:** `69078edd0b197e582edc246eae6bfbff58d18de5`
**Implementation/evidence revision:** `1830488a8d4056ef6cdab6c8297022d10d1cbaff`
**Main and origin/main observed:** `1491fd729f3237706ad9533274b7525f6b058932`

## Result and scope

F6 developer visualization is restored in the continuing wing. Fresh instances start quiet. One non-repeat F6 key-down applies a local, presentation-only override to all twelve real `StorageSurface` instances; a second press removes it. Manual targeting and the developer override coexist through an effective `normal/manual request OR developer override` rule. F7 is inert in this composition and the legacy main fixture retains its inherited F6/F7 behavior.

This is technically verified and awaiting the focused human check. It does not change default launch, storage policy, fixture profiles, shelf or ceiling heights, catalogue content, the seed palette, accepted wing geometry or Receiving.

## Diagnosis and correction

The continuing wrapper had two independent input blocks: its manager implemented a no-op `_unhandled_input()`, and `FunctionalFixtures` disabled unhandled input processing. Merely re-enabling the inherited handler would also have exposed destructive F7 behavior. A single shared visibility flag also allowed Manual's target transition to clear an F6 request.

The bounded correction is:

- `functional_storage_manager.gd`: owns a default-OFF, session-local F6 state, accepts only key-down/non-echo F6 and never forwards F7;
- `functional_fixtures.gd`: enables that manager's key-specific input path and reports F7 occupancy-demo capability as false;
- `storage_surface.gd`: adds a default-false presentation request and resolves existing visuals as normal/manual OR developer. Callers that never opt in retain their prior default and behavior;
- `wing_storage_debug_f6_tests.gd`: exercises the real input route, visual nodes, Manual coexistence, refreshes, zoning and nonmutation;
- composition and bridge tests: preserve the editable live scene while substituting the committed twelve-host sample only where exact regression membership is required;
- the gated `wing_storage_debug_f6_capture.tscn`: produces this follow-up's matched evidence without touching default launch or the accepted initial evidence.

No surface is recreated to toggle the overlay. The implementation uses the existing `StorageDebugGrid` and `StorageDebugOccupancy` nodes.

## Behavior matrix

| Case | Fresh result |
|---|---|
| Empty-hand Auto, OFF → F6 ON → OFF | 0 → 12 → 0 developer-visible surfaces; all real visual nodes match. |
| F6 repeat and key-up | Ignored; one toggle per intentional press. |
| ON → Manual target A → target B → look away → Auto | Override remains visible on all twelve surfaces across normal process/physics updates. |
| OFF while Manual targets a surface | The legitimate target grid remains; leaving Manual returns non-targeted Auto presentation to quiet. |
| Store/retrieve while ON | Occupancy refresh remains visible; item identity and ownership are conserved. |
| Populated/zoned surfaces, F6 and F7 | Full item, reservation, stack, zone, transform, surface-name/grid/capacity/clearance snapshots are unchanged. F7 never clears or injects occupancy. |
| Zoning open/close | Existing modal/pause semantics remain; the developer override survives closing the modal. |
| Fresh, setup-free and parent-hosted instances | Start OFF with twelve surfaces and no global state leak or seed dependency. |
| Ordinary tables | No `StorageSurface`, developer grid or PUT behavior is added. |
| Legacy `main.tscn` | Loads with its existing 16 surfaces and historical F6/F7 controls. |

## Automated verification

The focused F6 test was first run against the blocked baseline and failed on input routing, initial state and missing independent visibility ownership. After the correction:

- `wing_storage_debug_f6_tests.gd`: exit 0, exactly one `PASS:`;
- `wing_gameplay_composition_tests.gd`: exit 0, exactly one `PASS:` and the two intended duplicate-namespace rejection diagnostics;
- `wing_storage_bridge_interaction_tests.gd`: exit 0, exactly one `PASS:` against the isolated twelve-host regression sample;
- `wing_gameplay_capture_tests.gd`, `wing_gameplay_navigation_tests.gd` and `wing_seed_fixture_tests.gd`: exit 0 with one `PASS:` each;
- all **39/39** established non-hanging `*_tests.gd` scripts except the known legacy integration audit: exit 0 with exactly one `PASS:` each.

The expanded run emitted 52 expected `ERROR:` lines: 39 recurring Windows root-certificate diagnostics plus two deliberate catalogue duplicate diagnostics, one Receiving duplicate-source diagnostic, eight seed rejection/lifecycle diagnostics and two active-namespace rejection diagnostics. There were no unexpected assertions.

The separately bounded `main_scene_loot_audit_integration_tests.gd` run was terminated after 25 seconds, printed no PASS and reproduced exactly its inherited three assertions: `_assert_summary` line 179 twice and `_init` line 95 once. This remains an exception, not a pass.

Parser/editor initialization exited 0 without a parse/resource failure. Bounded smokes of the continuing gameplay scene, `main.tscn` and `wing_review.tscn` each exited 0; only the known Windows certificate diagnostic appeared, plus each scene's normal summary output.

## Rendered evidence

The focused capture used `gl_compatibility` on an NVIDIA GeForce RTX 5060 Ti at 1920×1080. All matched fixture views use the normal player-eye reference (1.72 m, 75° FOV). The scene is gated by `--capture-f6` and writes only under `reports/logistics_wing/storage_bridge/f6_followup/`.

| F6 OFF | F6 ON |
|---|---|
| ![Gallery A F6 OFF](../../reports/logistics_wing/storage_bridge/f6_followup/gallery_a_f6_off.png) | ![Gallery A F6 ON](../../reports/logistics_wing/storage_bridge/f6_followup/gallery_a_f6_on.png) |

The [contact sheet](../../reports/logistics_wing/storage_bridge/f6_followup/contact_sheet.png) contains OFF/ON pairs for Gallery A, Gallery B and Gallery C. The [capture manifest](../../reports/logistics_wing/storage_bridge/f6_followup/capture_manifest.json) hashes the live edited scene and focused sources. The [transition sequence](../../reports/logistics_wing/storage_bridge/f6_followup/transition_sequence.json) records:

`startup 0/12 → F6 down 12/12 → repeat ignored 12/12 → key-up ignored 12/12 → F7 ignored 12/12 → F6 down 0/12`.

## Preservation and hashes

The live, user-edited `wing_gameplay.tscn` SHA-256 was `eb260b07795edc0975e7c1a21706ef72a6494b9ceb8ccde24cc5f43f6f66d3e9` before implementation, after all tests and after rendering. It still has fourteen seed hosts, including `Book2` and `CDStack_B2`, and the saved East-table transform. It remains intentionally modified and unstaged.

Between task start and implementation revision, the Git object IDs for `main.tscn`, `project.godot`, `greybox/logistics_wing/`, `receiving/`, `data/`, `item_catalog.gd`, `player_controller.gd` and `storage_placement_controller.gd` are byte-identical. The six pre-existing untracked `.import` files remain untracked and unstaged. No asset/content repair or imported-asset migration was performed.

Focused SHA-256 values:

| Path | SHA-256 |
|---|---|
| `storage_surface.gd` | `ca070f7aadca92952e005dc91fb2fd7ec204b647ab6087fa4c77462c251cdc9d` |
| `gameplay/logistics_wing/functional_storage_manager.gd` | `fcf8fa82ef0583f4d47a254654502cea361efb36a0372b167c219df225784672` |
| `gameplay/logistics_wing/functional_fixtures.gd` | `39897b41b5c4fcc3d75cb5548835f8b664285f3d795e2ec5ab6608afe58746e4` |
| `tools/asset_pipeline/tests/wing_storage_debug_f6_tests.gd` | `7d26cbb16ab0e56dc7a3832540bbe8d00ac87a8621717ef4520a7f122db10abf` |
| `capture_manifest.json` | `94e9760bcb35a4ced856f5f4a39ba653f16abbc653053d9775cff159ac94498c` |
| `contact_sheet.png` | `df09dabdc5c04ff3050968eafcd52c0fb4171fb46dbf09ad172145cbe30bdfd6` |

Authoritative handoff hashes were verified locally: execution handoff `b657484899e56baf8182051edd56318acf812a7b928638c72db1c05f128ce6d0`, approved sequence `8adf50bbb2cf1be41f0c8343aea0c56671c9d62b491594f046b9a685ccd68e63`, and kickoff `d9cfa94ff1606c9f812fb6b188c431a2ff4646aad94df3b436f3fbc9988140a6`.

## Focused human check

Run `res://gameplay/logistics_wing/wing_gameplay.tscn`, then answer **PROMOTE** or **REVISE** for F6 only:

1. Empty-handed and outside Manual, does F6 show/hide all real shelf grids?
2. Does the toggle survive switching modes and aiming between shelves, and does OFF restore normal presentation?
3. With real stored items and zoning present, does F7 do nothing, with ordinary handling unchanged?

The original integration is human-validated. F6 is technically verified but this focused check is pending. Default-entry integration, merge and push were not performed.
