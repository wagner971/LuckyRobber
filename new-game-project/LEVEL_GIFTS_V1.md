# 3D gifts — 0.9.70

The three-successful-escapes crate and its tracker are removed. Each location
awards one prototype outfit card on its first full clear. Apartment and Museum
use their explicit Final Job completion gates. Replays, incomplete escapes,
failures, tutorial runs and challenge contracts cannot generate another card.
Existing locations can earn their card on their next qualifying clear.

The result and its rarity are saved with the heist. Unacknowledged presentations
resume on Home after a restart, using the saved rarity. Continue marks only the
presentation seen; the card remains in Garage → Trophies & Rare Loot. These are
clearly labeled PROTOTYPE cards, not equippable skins or future entitlement
promises. No additional cash, diamonds or stats are paid for this placeholder.

Visual flow: glossy cubic box with separate gold ribbon lid, 0.25-second entrance,
anticipation, then a short upward lid launch. The level card emerges at 1.05s,
cycles green Common / blue Uncommon / purple Rare / gold Legendary for 3 seconds,
then fixes its border to the saved rarity with a small confetti burst. Animated
gold stars and purple squares stay inside the card. Existing live thief is used
as the placeholder. Prototype rarity weights: 50 / 30 / 16 / 4 percent.

Daily Gift keeps its existing $300 and 1–2 diamonds. Its cyan/gold 3D box reveals
the cash and a Claim button at 1.8s. Currency is secured before animation, so
closing the app cannot lose the award. Claim dismisses the presentation.

DEV enables unlimited gifts and wheel spins, with overlap/double-tap protection.
After each DEV Daily Gift claim, the prototype level-gift preview follows.
These previews never consume level rewards or modify wardrobe ownership.
DEV reward writes do not update the shared production daily ledger. Normal
builds retain the 24-hour gift cooldown and one free spin per UTC day.

Schema 15 migrates older saves with a backup, removes obsolete getaway progress,
and validates saved per-location rarity. Effects suspend while unfocused and
render in their own small viewport at 30fps; confetti/stars are procedural UI.

Validation: level-gift settlement for every location, duplicate prevention,
pending save/reload, schema migration, real full-clear-to-results flow, production
cooldowns, repeated DEV claims, the chained DEV preview, and shop regression.
Screenshots checked at 450×800 and 360×800, with simulated safe insets.
