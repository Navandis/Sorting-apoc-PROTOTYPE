# Receiving C1 emergency stop label and localized wear

10 October 2026. Implemented and technically verified on `codex/receiving-c1-label-wear-pass`; human visual review pending. Base: `a331b6175fb0bda0f2fac7ce89744c321088c675`. Local commit only; no merge or push.

## Added visuals

A shaded, non-emissive 320 × 140 mm QuadMesh plaque identifies the existing decorative red button with **EMERGENCY STOP**. The cream and muted red SVG uses outlined lettering, small screw marks and restrained edge wear. It sits above the button on the yellow column, without modifying the column, button or CRT. No interaction or collision was added.

Seven independent instances of approved EAF4 **Road Dust** (`eaf4b_7efdf22029c82320d62147c7`) provide light operational contact and accumulation. The configured source fingerprint matches its current approved record. Opacity is 0.22–0.38, with warm mineral tint, softened edges and reduced normal/roughness contribution. Base materials and catalog defaults are unchanged.

| Group | Individual elements | Concentration |
| --- | --- | --- |
| ReceivingWear_LiftZone | Threshold_Left, Threshold_Right | Separated freight contact patches outside the barrier |
| ReceivingWear_Floor | Traffic_Approach | One faint patch along the room-to-lift approach |
| ReceivingWear_Floor | Stool_Contact | Foot/stool contact beneath the desk return |
| ReceivingWear_Floor | Equipment_Service | Service contact beneath the electrical cabinet |
| ReceivingWear_Floor | PalletJack_Turn, Barrel_Base | Wheel turning and small hard-to-clean accumulation |

Wall expanses, cleaning nook, yellow frame, warning signs and monitor remain quiet.

## Organization and manual tweaks

`wing_gameplay.tscn` adds one editable helper instance at `ReceivingSetDressing/ReceivingDecals/ReceivingFinishPass`. Its source is `gameplay/logistics_wing/receiving/receiving_finish_pass.tscn`; children are grouped under `ReceivingWear_Floor`, `ReceivingWear_LiftZone` and `ReceivingSignage`.

Toggle the helper root, a group or an individual overlay through **Visible**. Editable children are enabled in the wing scene. Each overlay owns its own scene-local **Spec**: adjust `physical_size_m`, `opacity_multiplier` or `albedo_strength` there. Move/rotate the overlay root; keep its scale at one because the existing EAF4 helper resets scale when regenerating. The generated Quad sits 2 mm above the floor. Edit the helper scene for shared changes, or use wing-local child overrides for placement adjustments. No broad intensity increase is recommended before a moving-camera review.

## Verification

Godot 4.7 Compatibility / OpenGL runtime captures were inspected from six angles: room overview, button, lift floor, desk, equipment corner and pallet area. Local images and raw logs are in `reports/logistics_wing/receiving_label_wear/2026-10-10/`, with `final_*.png` as the reviewed result.

- Final editor parse/load and explicit canonical scene startup: exit 0, no errors or warnings.
- Startup parity, wing composition, dressing collision, lighting (126 checks), lift installation, infrastructure, deck presenter and real OpenGL CRT suites: PASS. Composition includes its two intentional duplicate-seed rejection diagnostics. CRT retains 704 × 400 and 4,041 sampled green pixels for configured and explicit launches.
- Before/after runtime comparison: all 1,918 prior nodes retain identical transforms, visibility, geometry, materials, physics and lighting properties; 38 hidden Receiving alternatives remain hidden. Only the expected ReceivingDecals child count changes, with 19 new visual nodes.
- Seven overlay quads face upward at floor Y + 0.002 m; no new collision, light, area or gameplay authority. The infrastructure guard allows only the exact established EAF4 visual helper inside the two named wear groups and rejects scripts elsewhere.
- Both pre-existing dirty resource files remain byte-identical and unstaged. Diff whitespace check passes.

The final artistic preference and moving-camera editor review remain with the human; Receiving C1 is not promoted or closed by this pass.
