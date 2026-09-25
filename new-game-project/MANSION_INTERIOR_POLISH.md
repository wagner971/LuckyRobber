# Mansion interior polish — 0.9.48

Only Mansion was changed. The ten existing loot instances, $5,170 / 38 cargo,
statue objective/trophy, contracts and progression are preserved.

- Library: monitor and PC share a real writing desk along the side wall. Keyboard,
  leather desk mat, archive shelves and books give the safe a private-office setting.
- Front salon: permanent upholstered seating faces the TV on a console. A low
  stone-topped coffee table and art book complete the group.
- Private suite: bed, headboard, pillows, throw, writing nook and separate safe.
  The second PC has moved out of the kitchen into this room.
- Bathroom: tiled floor, two privacy partitions, toilet backed onto the side wall,
  vanity, basin, mirror and towel rail. The entrance from the hall stays open.
- Kitchen: fridge beside fitted sink/counter and a small breakfast table. No
  computer is left beside the fridge.
- Gallery: statue centered on a rug with portraits and a viewing bench, replacing
  empty decorative plinths. The statue keeps its own integrated base.
- Music room: piano near the rear window, bench at the keyboard, drapes and
  sheet-music cabinet.
- Great Hall and exterior estate remain recognizable. The low portico roof across
  the entrance was removed so it no longer hides the player. Rear wall height now
  supports the gallery portraits and music-room window.

Furniture and hall columns have real collision/drop footprints. Displayed
electronics use elevated loot roots, avoiding permanent offsets when carried.
Room lights are restrained, shadowless local lights; no new post-processing is added.

## Verification

- **87/87 core checks** passed.
- **6/6 Mansion regression checks** passed, through actual movement and pickup/load
  interactions: MAX full clear **76.60 / 80 s**; Rush **44.02 / 55 s**;
  Small Van **21.50 / 60 s**; Client Order **40.68 / 50 s**.
- **3/3 added checks** passed: solid bed/desk footprints, support elevations, and
  full clear at Mansion's own upgrade tier (Strength 5, Grip/Carry/Van/Noise 16).
  That route takes **78.38 / 80 s**, with $5,170 and all 38 cargo delivered.
  This is an uninterrupted automated route, not a beginner completion estimate;
  the existing 80-second limit remains tight for full clear.
- Inspected 450×800 room captures, 320×712 portrait framing and the actual-map Jobs
  preview. No physical-phone GPU benchmark was performed.

[Entrance](tests/mansion_polish_entrance.png) · [Salon](tests/mansion_polish_lounge.png) · [Library](tests/mansion_polish_library.png) · [Suite](tests/mansion_polish_suite.png) · [Bath](tests/mansion_polish_bath.png) · [Gallery](tests/mansion_polish_gallery.png) · [Music](tests/mansion_polish_music.png) · [Narrow](tests/mansion_polish_narrow.png) · [Jobs](tests/mansion_jobs_polish_450x800.png).

Windows and Android packages: DEV and persistent variants, **0.9.48 / Android code 65**.
Source DEV reset remains enabled.
