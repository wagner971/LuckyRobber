# Violet menu and HUD — 0.9.84

All twelve supplied PNGs from `C:/Users/trash/Downloads/JOC/main menu` are copied into `assets/ui/menu_violet/` and integrated by role: Title → Home logo, ruleta → wheel entry, home/jobs/upgrades/garaj/Cosmetics → navigation and shortcuts, five powerups → their upgrade cards and related upgrade icons.

Home shortcuts and bottom navigation contain only icons. Tooltips and accessibility names retain destination labels. Touch targets, upgrade badges, active-tab indication and button animations remain functional. `MenuArt` caches textures and fits their transparent bounds without modifying the original pictures.

Blue UI surfaces, outlines, neutral information text, modal controls, wallet shells and gameplay HUD now use violet/lavender. Home studio geometry, podium and accent lights follow the new palette. A neutral ambient fill preserves the character skin and white clothes. Play/confirm, money and warning colors retain their meaning; world level materials and rarity palettes are not globally filtered.

Validation: 66 navigation/accessibility/safe-bottom checks across 360×640, 360×800 and 450×800; 87 core gameplay checks. Captures `tests/violet_*_after.png`, `tests/violet_home_narrow.png`, `tests/violet_jobs_narrow.png`.

Android version code 101. Windows and Android DEV/Persistent exports.
