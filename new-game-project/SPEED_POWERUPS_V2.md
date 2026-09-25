# Required, useful speed upgrades — 0.9.52

Pickup Speed (the former `GRIP` shop title) and Carry Speed now have larger early effects, lower entry prices and explicit campaign requirements. Internal upgrade IDs and saved levels remain unchanged; there is no save reset, automatic purchase, retroactive charge or change to loot prices/timers.

## Effects and prices

- Pickup rate: `1 + 0.12 × (level − 1)`, replacing 0.03. Pickup duration still respects the 0.25-second floor. First purchase increases rate 12%, reducing duration 10.71%. Quantum Core pickup goes from 2.8 to 2.5 seconds.
- Carry factor: `1 − (1 − base_weight_factor) / (1 + 0.35 × (level − 1))`. Each level reduces the carrying penalty in every class without reaching/exceeding empty speed. Empty movement is unchanged. First purchase improves Light speed 1.36%, Medium 4.58%, Heavy 11.11%, Very Heavy 17.28%; the shop accurately labels the advertised benefit as **heaviest loot**, not all movement.
- First Pickup purchase costs $250, first Carry $300 (previously $600/$650). Later prices are base × 1.18^(current level−1), rounded to the nearest $50. Both retain 20 levels; required campaign levels stop at 10, so remaining purchases are optional.
- At level 20 the carrying factors are approximately 0.9935 Light, 0.9804 Medium, 0.9608 Heavy, 0.9477 Very Heavy. Every purchase helps rather than saturating Light/Medium at the empty-speed cap after a few levels. Compared to the old maxed Carry, the Light class is slightly slower (<1%); heavier classes are substantially faster.

## Progression requirements

Both Pickup Speed **and** Carry Speed must meet the following level to earn `STEAL EVERYTHING`/its clear bonus and unlock the next location. Ordinary farming runs and original loot payments remain available below the threshold. Strength, cargo and objective requirements remain in effect.

| Current location | Both speed levels | New pair cost from previous requirement | Cumulative pair cost | Full haul | Pair / full haul |
|---|---:|---:|---:|---:|---:|
| Apartment | 2 | $550 | $550 | $1,210 | 45.5% |
| Suburban House | 3 | $650 | $1,200 | $2,140 | 30.4% |
| Villa | 4 | $750 | $1,950 | $3,260 | 23.0% |
| Electronics Store | 5 | $900 | $2,850 | $4,060 | 22.2% |
| Mansion | 6 | $1,100 | $3,950 | $5,170 | 21.3% |
| Laboratory | 7 | $1,250 | $5,200 | $7,250 | 17.2% |
| Museum | 8 | $1,450 | $6,650 | $9,700 | 14.9% |
| Pyramid | 9 | $1,750 | $8,400 | $10,500 | 16.7% |
| Dracula's Castle | 10 | $2,100 | $10,500 | $10,900 | 19.3% |

Every required level can be purchased within that location's existing tier cap. This table compares upgrade costs to a theoretical complete haul, not earnings guaranteed from one beginner run. Strength/Van/Noise remain separate expenses. The goal is an affordable, visible progression step rather than making normal farming impossible.

Enforcement is in `Progression.refresh`, `Progression.settle`, and the run's full-clear result; hiding/disabling a button alone is not the gate. Special Jobs cannot bypass it. Apartment and Museum Final Jobs also validate before entering. Other locations retain their existing two-objective unlock rule **plus both speed requirements**. Buying the last missing upgrade refreshes already-earned unlocks immediately; it does not retroactively award a full-clear medal/bonus.

Previously unlocked locations and completed finale flags remain grandfathered. Old Museum saves still gain the inserted Laboratory. New profiles cannot advance without the required purchases. DEV MAX remains an explicit testing bypass; release/Persistent gameplay gets the same authoritative requirements.

## Presentation

Jobs shows `CLEAR REQUIREMENTS` and two level chips; tapping either opens its upgrade directly. The crown says `UPGRADE SPEEDS` when cargo is sufficient but speed is not. Locked-location text includes the previous location's required speed level. The large PLAY button continues to offer money-earning normal runs while Final Job is unavailable.

Shop displays `PICKUP SPEED`, actual next-purchase benefits, required-level tags and new prices. Once a campaign objective has been earned, Home/Results/Shop Next Target directs the player to the missing speed upgrade. Carry is suggested first, then Pickup. Both retain their existing animated purchase feedback and live preview.

## Verification

Dedicated progression tests cover each missing stat separately, direct settlement, Special Job bypass attempts, exact full-value loot payout, legitimate completion/unlocks, every tier cap, actual purchasing and monotonic Carry benefits. The UI test presses real buttons at 450×800 and 320×712 with safe areas, checks blocked/ready Final Job states, required upgrade focus, wallet deductions and starting immediately after the second purchase.

All nine locations were physically traversed with exactly the required Pickup/Carry levels and other stats at MAX. Full-clear times: Apartment 39.08/60 s; House 56.30/60; Villa 62.63/70; Electronics 55.02/60; Mansion 75.23/80; Laboratory 68.65/85; Museum 61.02/80; Pyramid 45.60/60; Castle 47.50/60. These are automated route feasibility checks, not a prediction of first-time player performance or proof that every low-stat combination works.

Regressions include the core gameplay suite, upgrade shop, safe-area UI, Final Job, DEV, onboarding, Jobs, Laboratory and idle economy. Dedicated logs use the `tests/speed_` prefix. The old Challenge V2 suite's exact +3%/+1.5% formula assertions are historical and do not describe this balance revision; it was not used as a passing regression claim.

Passing checks: speed progression 134, actual speed UI 20, core 87, upgrade shop 19, studio UI 36, idle economy 38, Final Job 25, first launch 1, DEV 24, Laboratory 16, onboarding 27, Jobs 51: **478 total**. Old Final Job/Jobs fixtures were updated to supply the newly required speeds in their ready-state cases; their earlier failures were not treated as passes.

Economy output: `tests/speed_progression_economy.csv`. Screenshots: `tests/speed_blocked_jobs_320x712.png`, `tests/speed_ready_jobs_450x800.png`, `tests/speed_shop_required_450x800.png`, `tests/speed_home_target_450x800.png`.

Delivery: Windows and Android DEV/Persistent packages exported as 0.9.52 (Android code 69, arm64-v8a). Both Windows packaged startup checks exited 0; Android manifests and export signature checks passed. Source remains `development/enabled=true`; Persistent builds retain saves across launches. Android hardware playtesting was not performed in this pass. The known environment certificate-store warning remains in Godot's logs.
