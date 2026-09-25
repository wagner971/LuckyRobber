# Viking Hall — 0.9.56 / Android 73

New stable location ID `vikings`, after Pirate Ship in Chapter 2. Museum's finale still gates the chapter. Two Pirate Ship objectives and its speed requirement unlock Viking Hall. Existing saves receive the new objectives without losing wallet, inventory or earlier progress.

The longhouse has snowy exterior eaves, carved entry posts, a rear gable, hearth, feast table with benches, armourer's worktop, forge, weaving corner and a raven display. Trees, snow banks, stones and palisades surround the camera. Loot is staged by purpose; two lanes around the hearth stay open. The van's rear faces the entrance, with space between its roof and the starting player.

## Inventory

| Object | Value | Cargo |
|---|---:|---:|
| Jarl's Throne | $3,600 | 8 |
| Runic Stone | $3,200 | 8 |
| Nordic Loom | $1,800 | 5 |
| Iron Helmet | $650 | 1 |
| Drinking Horn | $600 | 1 |
| Bearded Axe | $850 | 2 |
| Round Shield | $1,000 | 3 |
| Feast Cauldron | $1,600 | 5 |
| Forge Anvil | $2,400 | 8 |
| Gilded Raven | $1,300 | 3 |
| **Total** | **$17,000** | **44** |

All ten models/types are new. The Gilded Raven becomes the ninth trophy only after escape. Existing seven-trophy cosmetic unlock remains compatible. Helmet, horn and raven roots are elevated onto their supporting furniture; carrying correctly removes this elevation.

85-second Normal run; 30-second alarm escape window. Objectives: escape with $7,000, steal Jarl's Throne, steal everything. Full clear requires Pickup Speed and Carry Speed 12. Loot requires up to Strength 5; 44 cargo fits the existing van progression. Special Jobs retain their 35-second timer. Duplication automatically applies the existing 20–45-second cycle, replica discount and per-chamber economy cap; no changes to older items' earnings.

## Verification

401 passing checks: Viking Hall 57, Pirate Ship 65, core 87, idle economy 38, Jobs 53, onboarding 50, security 51. Real movement, collision and pickup/load routes:

- Full clear at MAX: 73.13 / 85 s.
- Full clear at Pickup/Carry 12, Noise 1: 75.47 / 85 s.
- Short Special Job route: cauldron, anvil, raven; $5,300 / 16 cargo in 16.80 / 35 s.

Rendered Jobs checks cover 450×800, 720×1280 and 720×1600. Additional actual gameplay and 360×800 screenshots: `tests/vikings_gameplay.png`, `tests/vikings_bow.png`, `tests/vikings_jobs.png`, `tests/vikings_jobs_tall.png`. Jobs artwork is captured from the actual level.

Windows and Android DEV/Persistent builds refreshed. DEV still resets on launch. Desktop Compatibility rendering inspected; physical Android performance not measured.
