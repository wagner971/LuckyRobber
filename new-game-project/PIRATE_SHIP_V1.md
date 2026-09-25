# Pirate Ship — 0.9.55 / Android 72

Added after Dracula's Castle in Chapter 2, using stable `pirate_ship` save IDs. Museum's Final Job still gates the entire chapter; Castle's two objectives and its existing speed requirement unlock the ship. Old save wallets, unlocks and objectives survive validation.

## Play space

Tapered wooden hull, two masts with furled sails, Jolly Roger, rigging, lanterns, flush deck hatch, a cutaway captain's cabin and port-side cargo area. The central lanes stay clear. The van is parked on the pier with its rear toward the boarding ramp, farther forward so its roof does not hide the starting player. Ship rails, pier edges and the ramp have real collision; dropping into the sea is rejected.

The surrounding sea fills the camera view and uses one inexpensive unshaded animated material. No screen-space reflections or volumetric fog. Lanterns have no additional shadow maps. Modern surveillance remains limited to Electronics Store through Museum.

## Loot and progression

| Item | Value | Cargo |
|---|---:|---:|
| Spyglass | $350 | 1 |
| Brass Sextant | $450 | 1 |
| Captain's Compass | $500 | 1 |
| Pirate Parrot | $850 | 2 |
| Aged Rum | $750 | 3 |
| Deck Cannon | $1,900 | 8 |
| Iron Anchor | $1,800 | 8 |
| Ship's Wheel | $1,400 | 5 |
| Captain's Chest | $3,000 | 8 |
| Golden Kraken | $2,200 | 7 |
| **Total** | **$13,200** | **44** |

All ten are new models/types. Navigation instruments sit on a desk; cannon and anchor flank the deck; the golden figurehead is at the bow; chest and rum belong to the cargo area. The parrot is an eighth collection trophy, awarded only on escape. The existing seven-trophy cosmetic reward threshold is retained for save compatibility.

Normal duration: 80 seconds. Alarm escape window: 26 seconds. Objectives: escape with $5,500, steal the Captain's Chest, steal everything. Full clear requires Pickup Speed and Carry Speed level 11; Strength 5 and 44 cargo are needed for all loot. Duplication uses the existing replica discount, 20–45-second cycle and bounded storage without increasing existing items' yield.

## Verification

366 passing checks: Pirate Ship 65, core 87, idle economy 38, onboarding 50, idle UI 24, Jobs 52, security 50. Actual physics routes (no teleporting to collect):

- Full clear: 63.87 s at maximum upgrades.
- Full clear: 66.47 s with Pickup/Carry 11 and Noise 1.
- Special Job: parrot + wheel + chest, $5,250 / 15 cargo in 17.22 s of 35 s.

Checks cover chapter gate, Castle unlock, prior-save migration, item models, trophy settlement, water boundaries, short Special Job, paging through the third Chapter 2 location and previous gameplay systems. Rendered Jobs tested at 450×800, 720×1280 and 720×1600; additional 360×800 capture. Desktop Compatibility renderer used; physical Android performance not measured.

Jobs preview is captured from the actual map. Screenshots: `tests/pirate_gameplay.png`, `tests/pirate_bow.png`, `tests/pirate_jobs.png`, `tests/pirate_jobs_tall.png`. Four DEV/Persistent Windows/Android builds refreshed; DEV continues to reset at launch.
