# Strength Power-Up Reveal — 0.9.65

Buying Strength now shows a roughly 0.8-second **POWER UP!** reveal with the new level and up to three newly available loot items. The cards pop in sequentially with the existing item icons. Strength 2 shows **Fridge, Toilet, Sofa**; higher tiers use their own featured items, filtered against the actual `required_strength` data so the reveal never claims an item at the wrong tier. `NEW LOOT UNLOCKED` closes the moment. Existing wallet, bar, and card animations continue underneath. Other upgrades retain their compact purchase feedback.

The overlay ignores touch input and is removed when the player changes menus. It fits 450×800 and 360×640 portrait captures. Validation: `tests/test_upgrades_shop.gd` (22 checks), including level-specific content, automatic cleanup, and immediate menu navigation. Visuals: `tests/strength_powerup_450x800.png` and `tests/strength_powerup_360x640.png`.
