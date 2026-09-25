# Rarity highlight V1 — 0.9.67

Rare world loot gets a shared rim/sweep material overlay and one soft additive ground plane. No screen texture reads, extra lights, particle emitters, or normal-loot overlays.

| Tier | Color | Sweep interval | Sweep duration |
| --- | --- | --- | --- |
| Rare | Cyan blue | 3.8 s | 0.45 s |
| Epic | Purple | 3.2 s | 0.55 s |
| Legendary | Warm gold | 2.7 s | 0.65 s |

The diagonal sweep uses one coordinate space across all pieces of the model. Rarity already replaces at most one slot in a Normal run, so only one complete highlight can appear. Pause freezes the visual clock. Pickup removes the overlay pass and ground glow; dropping restores them. Cargo, price, rarity odds, and objectives are unchanged by this visual pass.

Within accessible pickup range, the rim eases up and the existing contextual label shows rarity, name, price, cargo, and any Strength restriction. Names use measured line breaks to avoid an auto-wrap sizing cycle in a hidden panel. No persistent floating rarity label or hard floor ring remains.

Validation: rarity state/regression tests, gameplay HUD tests, and actual OpenGL Compatibility captures at 450×800 and 360×800. Capture fixture: `tests/capture_rarity_highlight.gd` (requires a rendering window, not headless).
