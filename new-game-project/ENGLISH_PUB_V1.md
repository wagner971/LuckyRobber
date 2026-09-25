# English Pub · 1932 — 0.9.57 / Android 74

New `english_pub` location after Viking Hall in Chapter 2. The fictional Brass Fox is a 1930s-inspired English pub with a green-and-brick frontage, brass fittings, wooden counter, back-bar shelving, darts corner, partitioned billiard room, upholstered snug, fireplace and neighbouring terraced facades. Pavement, streetlights, planters and street extend around the moving camera.

No entrance door blocks the player. The van is outside, rear toward the entrance. The counter faces the aisle; register and hand pumps are accessible from its front. Gramophone, radio and trophy sit on supporting furniture with correctly elevated item roots. Furnishings have collisions, and both walking lanes stay open.

## Unique inventory

| Object | Value | Cargo |
|---|---:|---:|
| Billiard Table | $4,200 | 8 |
| Grandfather Clock | $3,600 | 7 |
| Leather Settee | $2,800 | 7 |
| Gramophone | $1,500 | 3 |
| Valve Radio | $900 | 2 |
| Dartboard | $800 | 2 |
| Golden Tankard | $1,200 | 1 |
| Brass Cash Register | $2,400 | 5 |
| Beer Engine | $2,000 | 5 |
| Brass Fox Sign | $1,600 | 4 |
| **Total** | **$21,000** | **44** |

Ten new models/types. Golden Tankard is trophy ten and is awarded only after escape. The existing seven-trophy cosmetic reward is retained. No changes to the economy of older objects; new loot uses the established bounded idle duplication rules.

## Progression and balance

Museum's finale gates all of Chapter 2. The pub unlocks after two Viking Hall objectives and its existing speed requirement. Old saves keep their wallet and prior unlocks and receive the new objective defaults. Pub full clear requires Pickup Speed and Carry Speed 13; all loot requires up to Strength 5 and 44 cargo.

Normal duration: 85 seconds. Alarm window: 28 seconds. Objectives: escape with $8,500, steal the Billiard Table, steal everything. Special Jobs retain the 35-second duration.

## Verification

395 passing checks: pub 57, Viking Hall 57, core 87, idle economy 38, Jobs 54, onboarding 50, security 52.

Actual physics routes, including pickup and van delivery:

- Full clear at MAX: 66.80 / 85 s.
- Full clear at Pickup/Carry 13, Noise 1: 68.77 / 85 s.
- Short Special Job: register + pumps + sign, $6,000 / 14 cargo in 15.82 / 35 s.

Jobs paging includes the fifth Chapter 2 location. Rendered checks cover 450×800, 720×1280 and 720×1600; additional 360×800 capture. Real map artwork: `assets/ui/jobs/english_pub.png`. Screenshots: `tests/english_pub_gameplay.png`, `tests/english_pub_jobs.png`, `tests/english_pub_jobs_tall.png`.

Four DEV/Persistent Windows/Android builds refreshed. DEV launch reset remains enabled. Desktop Compatibility rendering inspected; physical Android performance not measured.
