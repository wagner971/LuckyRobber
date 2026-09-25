# Daily Wheel V1 — 0.9.62

Home has an optional Daily Spin button. Each profile can spin once per UTC day. The limit and wheel rewards survive relaunches; the wheel's separate ledger also preserves diamonds and jackpot tickets while the DEV build resets heist progress. There is no paid-spin path and no heist, upgrade, or location depends on using the wheel.

The wheel sectors reflect their actual odds:

| Prize | Chance |
| --- | ---: |
| Cash, 1× / 2× / 3× | 38% / 22% / 8% |
| 3 / 8 diamonds | 20% / 10% |
| Character / van skin ticket | 1% / 1% |

The cash unit is 30% of the highest full-haul value among unlocked locations, rounded to $50. This makes the common prize $350 in Apartment and $1,200 by Electronics Store. A jackpot saves a future skin ticket and grants 10 diamonds immediately (20 for a repeat ticket). The skin models and equip actions are deliberately absent; the wheel explicitly says they arrive later. The existing Plum Suit in Cosmetics costs 50 diamonds. No cash-to-diamond or paid-spin purchase was added.

The new save schema (10) preserves schema-9 progress with a backup. The HUD, Home entry, wheel, and Cosmetics display diamonds. The wheel fits 360×640 and 450×800 portrait captures; both jackpot slices are 1% of the actual circle. Tests cover same-day blocking, next-day reset, reload, DEV reset, prize odds, the 50-diamond purchase, and schema migration. Existing Home, Jobs, HUD, Upgrades, UI, Duplication and live-menu checks pass.
