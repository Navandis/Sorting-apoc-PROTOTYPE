# Deterministic Support Stacking Playtest

## Gate status

This is a prototype-evidence playtest. Passing the automated checks and completing these scenarios does not confirm the design. Record observations against the ten questions at the end, then decide separately whether to promote, revise, or reject stacking.

## Controls and setup

Run the current `main.tscn` with the authoritative ignored `assets/` and `.godot/` content present.

- `LMB`: pick up the visible item under the reticle, including any visible stack member.
- `E`: place the selected carried item. Holding it repeats only in automatic mode.
- `M`: toggle automatic/manual placement.
- `R`: rotate the selected item's packing footprint by 90 degrees in manual mode.
- Mouse wheel or number keys: select a carried item.
- `O`: edit zones on the looked-at shelf.
- `F6`: toggle storage grid/occupancy debug rendering.

Before each scenario, retrieve earlier test items or use a different empty shelf area. Upper stack members do not add occupancy cells; the highlighted reservation remains the base rectangle.

## A. Flat media automatic stack

1. Use `O` to assign a shelf area to `Morale`, or use an existing `General` area.
2. Pick up `SM_Book_01` and `SM_CDStack_01`.
3. In automatic mode, place the Book and then the CD Stack while looking at the same surface.
4. Repeat with another available Book/CD instance if one is present.
5. Confirm the items form one centered narrowing column, use one base reservation, retain their authored poses, and have no visible air gap or intersection.
6. Retrieve a visible member with `LMB` and confirm the exact item returns to the carried strip.

## B. Manual mixed terminal stacks

Run the Pistol and Bread cases separately so each begins with an uncapped MedKit.

1. Place `SM_MedKit_4` on an empty surface.
2. Switch to manual mode with `M` and aim at the stored MedKit.
3. Select `SM_Gun_Pistol`, preview both allowed packing orientations with `R`, and press `E` on a valid preview.
4. Confirm the Pistol is centered on the MedKit and that no later item can be added above it.
5. Clear the stack and repeat with `SM_Bread_1`.
6. Confirm automatic placement will not smart-insert into either manually mixed/terminal stack, while ordinary manual targeting still reports the terminal support rejection.

## C. PC Tower support and compact-shelf headroom

Use level 1 of `SM_MetalShelves2`, the narrow metal shelf whose world Y scale is `0.67`. Its authored clearance is approximately `0.55074 m`, and the 95% permitted top is approximately `0.52320 m`.

1. In manual mode, rotate `SM_ComputerTower_01` to its `3x5` packing orientation and place it on the compact shelf.
2. Aim at the Tower, preview `SM_Book_01`, and place it.
3. Confirm the Book remains readable and the combined posed top (approximately `0.51215 m` from the surface plane) retains visible headroom.
4. Clear the Book, aim at the Tower with `SM_MedKit_4`, and inspect both packing orientations.
5. Confirm placement is rejected. Record both facts: the approved `5x4`/`4x5` MedKit footprint does not fit the Tower's approved `5x3`/`3x5` support, and the combined posed top (approximately `0.61922 m`) also exceeds the compact shelf's 95% clearance.
6. Do not describe Tower→MedKit as a clearance-only test. The independent automated synthetic boundary is the clearance-only proof.

## D. Round cans and zone authority

1. Assign a shelf area to `General`.
2. Pick up at least two `SM_Metal_Can_01a` instances and `SM_Dry_Goods_01c`.
3. In automatic mode, store them while looking at the General surface.
4. Confirm Hydration and Food items join the same centered `round_cans` stack, each 1x1 member seats on the previous posed top, and height accumulates without drift.
5. Repeat on a category-specific zone: confirm an incoming item never enters a mismatched specific zone merely to join the other category's can stack.
6. Continue adding cans on a low-clearance level until the next placement is rejected below the upper shelf with visible headroom remaining.

## E. Exact smart-insertion evidence

The exact `5x5 → 1x1`, then `2x3`, then `4x4` case is synthetic by design; production footprints are not altered to manufacture it.

Run:

```powershell
& 'D:\AI Tools\Godot-4.7-Codex\Godot_v4.7-stable_win64_console.exe' --headless --path 'D:\Godot Projects\Sorting-apoc-PROTOTYPE' --script 'res://tools/asset_pipeline/tests/storage_stack_rules_tests.gd'
```

Require `PASS: storage stack rules tests`. The asserted final order is `5x5 → 4x4 → 2x3 → 1x1`; existing relative order and packing orientations remain unchanged, and the highest valid insertion wins.

## F. Visible-member retrieval and compression

1. Build a stack of three or more cans so the top, a middle can's side, and the base are separately visible from different view angles.
2. Retrieve the top and confirm lower members do not move.
3. Rebuild, retrieve a visible middle member, and confirm every member above moves straight down without physics or reordering.
4. Rebuild, retrieve the base, and confirm the next member becomes the centered base, the reservation shrinks within the old cells, and no new cell is claimed.
5. Retrieve the final member and confirm the reservation/debug occupancy disappears completely.
6. Confirm occluded members cannot be selected through geometry; only physically visible/targetable members qualify.

## G. Ordinary storage regression

1. Pick several items outside the nine-item spike set, including a non-square item such as `SM_ElectronicDevice_01`.
2. Store and retrieve them in automatic and manual modes, including manual `R` rotation.
3. Confirm their reservation, cell fit, authored pose, targetability, carry identity, and cleanup are indistinguishable from the pre-spike behavior.

The headless observational regression is:

```powershell
& 'D:\AI Tools\Godot-4.7-Codex\Godot_v4.7-stable_win64_console.exe' --headless --path 'D:\Godot Projects\Sorting-apoc-PROTOTYPE' --script 'res://tools/asset_pipeline/tests/storage_unstacked_equivalence_tests.gd'
```

## Developer success questions

Record an answer and concrete example for each question after the scenarios above:

1. Does vertical stacking look natural enough without physics?
2. Are Book/CD/can stacks visually convincing?
3. Is stack-first auto-placement trustworthy or too aggressive?
4. Does smart insertion feel helpful or magical/confusing?
5. Is arbitrary visible-member retrieval intuitive?
6. Is recompression after middle/base removal acceptable?
7. Does 5% headroom look sufficient?
8. Does Tower + small-item stacking remain readable?
9. Does manual mixed stacking add useful agency without becoming mandatory?
10. Does stacking meaningfully improve storage density without making shelf clutter unreadable?

Do not promote the design until these answers provide affirmative playtest evidence.
