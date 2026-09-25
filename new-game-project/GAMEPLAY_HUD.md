# Gameplay HUD — 0.5.1

The in-run interface now follows the blue / green / gold mobile-game presentation of the menus. The 3D world, camera, progression and gameplay timing are unchanged.

- Compact timer and unbanked van loot cards, with clock and cash icons.
- Cargo count and capacity bar; FULL is explicit. Noise has a separate meter and switches to a warning icon and text near the alarm threshold.
- Urgent timer treatment at ten seconds or during an alarm.
- Contextual pickup, carrying, loading and blocked-item presentation. Progress appears only while an interaction is advancing.
- Large DROP and ESCAPE buttons. The escape card shows the actual amount that will be secured.
- Short-lived feedback banner, matching pause overlay and blue floating joystick.
- All decorative Controls ignore pointer events. Only real buttons consume touches. Joystick geometry, deadzone and movement remain unchanged.

## Assets

Six unchanged 256px PNGs are copied from the user-provided `UI/Free Icon Pack v3.1 (Basic)` by **gvesster**: Golden Clock 1st Outline, Green Cash 1st Outline, Box 1st Outline, Sound ON Outline, Warning 1st Outline and Arm 1st Outline. The supplied license is retained at `assets/hud/LICENSE-gvesster.txt`. Credit is optional under that license; commercial use is permitted. These icons are not claimed as original project artwork.

Five small project-native SVG icons provide pause, play, drop, escape and touch-hand symbols. The shipped game uses only assets inside the project and has no dependency on the original UI folder.

`scripts/hud_style.gd` owns the icon map, panel/button styles and input pass-through helper. `scripts/game_ui.gd` owns the presentation and uses the existing RunManager fields/signals. `scripts/move_input.gd` changes only joystick drawing.

## Verification

220 checks passed, zero failures:

| Suite | Checks |
| --- | ---: |
| test_gameplay_hud.gd | 57 |
| test_suite.gd | 78 |
| test_ui_v2.gd | 21 |
| test_variety_ui.gd | 29 |
| test_live_menu.gd | 35 |

The HUD suite exercises actual viewport touch routing for pause, drop and escape; real pickup/load progress fractions; unbanked cash/cargo; warning, full van, alarm and feedback expiry. Bounds are verified at 450×800, 360×800 and 600×800. Visual snapshots cover these states; wider portrait screens may have the brief floating feedback banner overlay the lower playfield. Special Jobs retain 35 seconds and the +40% label, and existing tests cover persistent DEV progression and menu transitions. QA uses separate profiles; the player's saved progress is untouched.

Snapshots: `tests/hud_ready.png`, `hud_pickup.png`, `hud_carry.png`, `hud_loading.png`, `hud_warning.png`, `hud_alarm.png`, `hud_alarm_tall.png`, `hud_alarm_tablet.png`, `hud_pause.png`, `variety_hud.png`.

Windows export: 0.5.1.0, embedded resources. Android export: 0.5.1/code9, debug-signed ARM64. Windows startup is smoke-tested headlessly and with rendering on a separate test profile. Android export succeeds; physical-device validation remains unperformed.

Pre-change source checkpoint: `../checkpoints/before-gameplay-hud`.
