# Strength handling / early alarm pressure — 0.9.75

Pickup noise = weight base × Strength handling × Noise Control.

| STR | Handling multiplier | Reduction from preceding level |
| --- | --- | --- |
| 1 | 2.00 | — |
| 2 | 1.10 | 45% |
| 3 | 1.04 | 5.45% |
| 4 | 1.00 | 3.85% |
| 5 | 0.96 | 4% |

Weak Thief at STR 0 uses 2.40. Noise Control retains its independent 100–81%
multiplier. Strength applies to object handling, not guard detection or fixed
Lucky penalties. Silent Heist/Double Noise still apply after this calculation;
the +35 Cursed penalty remains fixed. Tutorial still generates no pickup noise.
No save migration, price changes, threshold changes or timer extensions.

Measured physical starter route (TV, chair, lamp, desk fan): 14.60 s / 6 cargo.
STR 1: warning after the third pickup, alarm after fourth, 44 / 36.4 noise;
10.73 s left at the van, escape succeeds.
STR 2: same route 24.2 / 36.4 noise; no alarm, 45.40 s left.
Shop displays the next relative handling reduction alongside heavier-loot unlocks.

Full clear routes with minimum speed requirements and legal Strength/Noise tiers:
Apartment STR2 / speed2 / Noise4: 39.08 s, 4.35 s alarm margin.
House STR3 / speed3 / Noise7: 56.30 s, 0.17 s margin.
Villa STR4 / speed4 / Noise10: 62.63 s, 0.07 s margin.
Capacity was sufficient for each full inventory. These are deterministic optimal
routes, not a claim of comfortable human margins: House/Villa benefit from further
speed upgrades or route optimization. STR5 + Noise20 full inventories still exceed
the alarm threshold in all 13 locations.

Validation: 138 new handling/physical starter checks, 3 complete physical routes,
87 core checks, 23 shop checks, 50 onboarding and 117 Lucky Blocks checks.
Narrow portrait shop screenshot: tests/strength_noise_shop.png.
Legacy challenge_v2 contains obsolete pre-Speed-V2 price/speed/route assertions;
it is not a release gate for this patch. Dedicated current checks above pass.
