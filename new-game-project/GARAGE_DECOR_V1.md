# Garage decor — 0.9.69

The original Home scene remains: thief on the illuminated podium, fridge and
equipped getaway van. Its Collection shortcut and the shared Collection tab are
now Garage. Legacy Collection navigation also opens Garage. Trophies and rare
loot remain available through a button inside Garage.

Garage is a separate live 3D diorama. A new profile has a concrete floor, basic
van, one bulb and a table. Seven furniture pieces occupy fixed, distinct slots;
the eighth purchase replaces the floor with dark tiles and gold trim. This is
pure decoration: no income, cargo, noise, speed or other stat changes.

| Decor | Cash |
| --- | ---: |
| Sofa | 2,000 |
| Big TV | 4,000 |
| Arcade Machine | 7,500 |
| Pool Table | 12,000 |
| Jukebox | 15,000 |
| Giant Safe | 25,000 |
| Gold Statue | 40,000 |
| Luxury Garage Floor | 50,000 |

All decor is permanently available in Garage, separate from the rotating cosmetic
vehicle shop. Selecting an offer shows an explicitly labeled, unowned preview.
Buy & Place charges cash once, saves ownership, and animates the new furniture.
Leaving a preview never grants ownership. Purchased furniture appears whenever
Garage opens, while Home keeps its original composition.

Save schema 14 adds validated garage ownership. Schema 13 migration preserves the
old profile in a backup. Purchase failure rolls back both cash and ownership.
DEV still resets the session as previously requested; persistent builds retain
the garage between launches.

Validation: tests/test_garage.gd covers pricing, purchase guards, unchanged stats,
save rollback, relaunch, migration, previews, navigation and restored Home.
Rendered screenshots cover 450×800, 360×800 and 450×1000. Desktop renderer checked;
Android package verification does not replace a physical-device playtest.
