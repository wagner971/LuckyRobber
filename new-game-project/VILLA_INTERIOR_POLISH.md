# Villa interior · 0.9.46

Scope: **Villa only**. Its four wings, broad central hall, formal gardens, reflecting pool, forecourt and rear-facing van remain. Furniture now forms usable groups instead of scattered floor objects.

- **Salon:** TV on a permanent media credenza, sofa facing the screen, a shared rug, coffee table, art book, side table and lamp. The approach from the hall stays clear.
- **Study:** monitor on a real desk with keyboard and desk mat, PC beside the desk, safe backed toward the partition and books stored in a low bookcase. The equipment belongs to one workstation, with the safe accessible separately.
- **Music room:** piano moved toward the rear wall; the chair sits in front of the keyboard, facing it. A rug, window, curtain panels and sheet-music storage establish a practice room.
- **Master bath:** freestanding tub below the rear window; double vanity, taps and mirrors aligned with the outer wall; toilet backed onto that wall, facing the open aisle. Towels, a bench, a rail and a bath runner finish the room.
- **Circulation:** the low canopy across the entrance was removed to keep the player visible. Columns and lanterns still mark the arrival. Hall sconces now attach to the partition instead of floating away from it. No furniture occupies the central hall or the four room openings.

Fixed furniture has physical collision and excludes invalid loot drops. TV and monitor elevations are set on the loot root, so CarryAnchor removes the support height when picked up. Windows, skirting, restrained timber/stone seams and shadowless local lights tie the furniture to each room. The Jobs preview is rendered from the actual new layout.

The same **nine unique loot types**, **$3,260 / 28 cargo**, piano objective/trophy, 70-second Normal duration and existing alarm rules are preserved. No economy or progression changes were made.

## Validation

- **87/87 core checks** pass.
- Existing Villa physical routes: **6/6 checks**. Full clear at MAX takes **61.17 / 70 s**. Rush **27.90 / 35 s**, Small Van **22.85 / 60 s**, Client Order **20.93 / 35 s** remain solvable.
- **3/3 additional checks**: nine unique types; local upgrade tier earns both progression objectives in **52.33 s** with **$3,140 / 26 cargo**; full clear at Strength 4, Grip/Carry/Noise 10 and Van 11 takes **64.07 s**, banking **$3,260 / 28 cargo**. Existing progression opens Electronics after cash + piano, making Van 11 available. These are uninterrupted automated routes, not novice completion estimates.
- Rendered 450×800 entrance and all four rooms, 320×712 portrait framing and the updated Jobs card. No physical-phone GPU benchmark was performed.

[Entrance](tests/villa_polish_entrance.png) · [Salon](tests/villa_polish_lounge.png) · [Study](tests/villa_polish_study.png) · [Music](tests/villa_polish_music.png) · [Bath](tests/villa_polish_bath.png) · [Narrow](tests/villa_polish_narrow.png) · [Jobs](tests/villa_jobs_polish_450x800.png).

Packages: Windows/Android DEV and persistent variants, **0.9.46 / Android code 63**. DEV reset remains enabled in the source project.
