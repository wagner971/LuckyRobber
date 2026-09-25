# Prehistoric Era — 0.9.58 / Android 75

New `prehistoric` location after English Pub in Chapter 2. An irregular cutaway cave and woodland camp replace the rectangular house footprint. Mossy boulders form continuous collision walls, with an open entrance toward the van. A central hearth, hide-working area, sleeping mat, stone display supports, ferns and trees give the objects a reason to be there. The van's rear faces the entrance.

## Unique inventory

| Object | Value | Cargo |
|---|---:|---:|
| Mammoth Skull | $5,200 | 8 |
| Saber-Tooth Skull | $4,300 | 7 |
| Cave Painting | $3,600 | 6 |
| Hide Drying Rack | $2,800 | 6 |
| Stone Mortar | $2,500 | 6 |
| Ancient Amber | $1,900 | 1 |
| Hide Drum | $1,700 | 3 |
| Fur Bedroll | $1,400 | 3 |
| Shell Necklace | $1,200 | 2 |
| Flint Spear | $1,100 | 2 |
| **Total** | **$25,700** | **44** |

Ten new models and item types. Ancient Amber is trophy eleven, awarded only after escape. The existing seven-trophy cosmetic reward is unchanged. The necklace and amber stand on fixed stone supports that remain after pickup.

## Progression and economy

Museum's finale continues to gate Chapter 2. Prehistoric Era unlocks after two English Pub objectives and its speed requirements. Existing saves preserve wallet and prior unlocks while receiving new objective defaults. Full clear requires Pickup Speed and Carry Speed 14, Strength up to 5, and 44 cargo space.

Normal duration: 85 seconds. Alarm window: 34 seconds. Objectives: escape with $10,000, steal the Mammoth Skull, steal everything. Special Jobs remain 35 seconds.

New loot uses the existing bounded duplication economy: 20–45 second cycles, replica value capped at 20% of the original and 6% of the source map's value-per-second benchmark per chamber. Three chambers and three stored replicas per chamber remain unchanged. No inflation changes to older levels or items.

## Verification

397 passing checks: Prehistoric 57, English Pub 57, core 87, idle economy 38, Jobs 55, onboarding 50, security 53.

Measured routes use actual character movement, physics, pickup and delivery:

- Full clear at speed 20, Noise 1: 68.37 / 85 seconds.
- Full clear at required speed 14, Noise 1: 69.87 / 85 seconds.
- Special route: mortar, drum and bedroll, $5,600 / 12 cargo in 16.03 / 35 seconds.

Jobs snap paging includes the sixth Chapter 2 page and stops correctly at it. UI layout checks cover 450×800, 720×1280 and 720×1600. Additional 360×800 Jobs and gameplay captures were visually inspected, including the camera toward the rear of the cave. Preview is rendered from the actual level: `assets/ui/jobs/prehistoric.png`.

All four Windows/Android DEV/Persistent builds were refreshed. Both packaged Windows executables passed headless startup smoke checks. Both Android APKs signed and verified, with manifest version 0.9.58 / code 75 / arm64-v8a. DEV launch reset remains enabled; Persistent builds retain progress. Desktop Compatibility renderer inspected. Physical Android performance has not been measured.
