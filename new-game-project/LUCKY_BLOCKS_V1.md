# Lucky Blocks — 0.9.71

Every non-tutorial run rolls a 30% chance for one optional golden pixel-question
block. Its actual 3D mesh is batched into shared-color surfaces. Spawn positions
come from a collision-tested flood fill from the entrance, preferentially inside
the loot layout. It costs zero cargo, grants no base cash/noise and is excluded
from standard item counts, blueprints, objectives and Full Clear.

Pick up the block, load it and escape. Busted loses it. After Results has shown
the cash count, a short 3D reveal announces one of 40 equally likely outcomes
(20 positive, 20 negative). A pending level-completion gift follows separately.
The outcome is saved before the reveal, acknowledged on Continue, displayed on
Home/Jobs and consumed when the next non-tutorial run actually starts moving.
It remains active for that run only, including a failure or abandonment; nothing
stacks and permanent upgrades are untouched. Schema 16 migrates existing saves
with backup and preserves the pending outcome across restarts in persistent mode.

## Effects

The complete names and player-facing descriptions are in `scripts/lucky_effects.gd`.
`scripts/lucky_run.gd` supplies live gameplay modifiers to `RunManager`.

- Movement, pickup, load duration, cargo, Strength, noise, alarm and starting time
  change for the current run, without buying or refunding upgrades.
- Magnet attracts one eligible, unobstructed item within 2 m while moving.
- Bottomless displays infinity; Vacuum loads within 2 m while moving.
- Golden guarantees Rare/Epic. Lucky House multiplies the existing 20% combined
  rarity chance by five (100%, at most one replacement). Bad Luck suppresses it.
- Jackpot marks one normal item and multiplies its cash by five. Cursed Object
  marks one normal item and adds 35 pickup noise once. Treasure Vision labels
  rare loot through walls. Dark Heist slightly dims lighting and normal highlights.
- Big Haul adds 50% of loaded-loot value above 75% of standard item count.
- Noisy Shoes adds 2 noise per 3 seconds of moving with heavy loot; Loud Load adds
  4 noise per delivery. Slippery drops once after 8 moving carry seconds.
- Bad Route relocates a valuable floor object farther from the van, on a reachable
  floor position with room for its footprint.

**Curses are not softened for Final Job.** Tiny Van removes 30% cargo (rounded
down), Weak Thief removes one Strength level (including 1 → 0), Short Clock
subtracts 15 seconds and Alarm Rush subtracts four alarm seconds. They can prevent
a full clear. This is intentional, per the user's follow-up.

## Validation

- `test_lucky_blocks.gd`: 117 checks covering modifiers, persistence, optional item
  accounting and reachable spawn / Bad Route relocation on all 13 maps.
- `test_lucky_flow.gd`: 13 checks for delivery, successful settlement, reveal order,
  first-movement consumption, failed-run loss and reset on the following run.
- Core gameplay, onboarding, level gifts and daily reward regression suites.
- Actual Compatibility renderer captures: `tests/lucky_block.png`,
  `tests/lucky_curse.png`, `tests/lucky_world.png`, `tests/lucky_narrow.png`.
- Windows and Android DEV / Persistent exports: version 0.9.71, Android code 88.

Automated core economy/route fixtures now explicitly disable random encounters;
dedicated rarity and Lucky tests cover their random behavior independently.
Physical Android performance and touch testing remain device-side checks.
