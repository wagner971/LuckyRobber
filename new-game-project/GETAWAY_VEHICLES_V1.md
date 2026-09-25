# Getaway vehicles — 0.9.68

Eight cash cosmetics join the three daily offers in Cosmetics / Today's Shop.
Vehicles are not sold from a separate permanent shop. Every paid cosmetic in the
catalog participates in the shared UTC daily rotation, including future entries;
earned cosmetics remain rewards. Purchased vehicles stay owned and equippable
when their offer rotates out. No capacity, movement, noise or progression benefit.

| Vehicle | Cash |
| --- | ---: |
| Black Van | 8,000 |
| Pickup | 15,000 |
| Box Van | 25,000 |
| Armored Van | 50,000 |
| Luxury Getaway Van | 80,000 |
| Dracula Hearse | 100,000 |
| Pirate Van | 120,000 |
| Pharaoh Van | 150,000 |

Each offer opens a live 3D preview. Buy & Equip saves the charge, ownership and
selection together; a save failure rolls all three back. Vehicles reuse the van's
loading orientation, cargo anchor and gameplay behavior. Home, menus and heists
use the equipped visual shell. Static offer previews redraw only when needed;
the selected preview animates at 30 fps and pauses with the menu.

Validation: `test_vehicle_cosmetics.gd` covers exact prices, purchase guards,
persistence, failure rollback, model variants, cargo preservation and the real
shop-to-heist flow. `test_play_rewards.gd` covers rotation and existing rewards.
Rendered preview captures cover the daily list, 360×800 portrait and all 8 models.
