# Tutorial V3 — clear teaching, explicit navigation

Version 0.9.53 / Android code 70, 24 September 2026.

The tutorial previously redirected Jobs to Play until the noise lesson flag was set. Garage success and the guided Carry purchase also started Apartment automatically. Those hidden transitions made the location selector appear broken.

## Player flow

- A fresh launch still enters the separate three-object garage immediately.
- Four short step labels accompany the existing hand and world highlights: move, stop to pick up, deliver, escape. Pause is available throughout.
- Cash appears after the first delivery; cargo space appears at 5/6; Escape appears at 6/6. No timer or noise pressure in practice.
- Escape animates the van departure, banks the existing $640 once, then shows the reward. Choose a Job, Upgrades and Home are explicit choices.
- Jobs always opens the location selector. Home, Results, practice replay and incomplete noise teaching no longer override this action.
- The first explicitly selected normal job shows a short paused briefing: timer, finite cargo, noise/police, and Strength locks. Start Heist acknowledges it; Back to Jobs cancels without a failure. Movement starts the clock afterward.
- Apartment uses its complete normal map and real noise rules immediately. The earlier hidden two-run curriculum and temporary removal of locked loot are gone.
- The first noisy pickup adds a brief hint inside the noise HUD, with alarm warnings taking priority.
- Buying the suggested Carry upgrade stays in the shop. The player chooses when to return to Jobs or start another run.

## Persistence and compatibility

Added validated boolean `heist_briefing_seen`; existing experienced saves infer acknowledgement when the field is missing. Tutorial and noise flags remain independent. Neither noise acknowledgement nor the new flag gates menu navigation or Special Job access. Existing upgrade requirements, payouts, item values and progression remain intact.

DEV continues to reset on launch as requested. Persistent builds retain tutorial acknowledgement and all progression. Practice replay grants no extra cash and does not reset the briefing.

## Verification

500 passing checks in the final runs:

| Suite | Checks |
|---|---:|
| Tutorial flow, navigation, pause, persistence, replay | 50 |
| Physical garage route | 7 |
| Actual fresh launch | 1 |
| Core gameplay / input / pause | 87 |
| HUD / alarm / touch actions | 75 |
| Game feel / results | 35 |
| Development and persistent profiles | 24 |
| Speed progression, including all nine physical clears | 134 |
| Jobs carousel and actions | 51 |
| UI safe areas and Results | 36 |

Rendered and inspected tutorial Move, first delivery, Escape, reward and briefing; briefing checked at 450×800 and 320×712 with simulated safe areas. Six captures: `tests/tutorial_v3_*.png`. The direct automated garage route takes 13.35 seconds; this is a reachability measurement, not a novice completion-time claim.

All four exports updated: Windows/Android DEV and Persistent. Packaged Windows launch and Android manifest verification are recorded in `tests/tutorial_*`. Android has not been tested on a physical phone in this pass.