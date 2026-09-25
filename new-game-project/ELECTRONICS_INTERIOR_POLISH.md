# Electronics Store — interior polish, 0.9.47

Scope: Electronics Store only. The extended commercial exterior, van orientation,
inventory IDs, contracts, trophy, progression and economy are preserved.

- TV department: three screens aligned on a continuous cabinet, with a backing panel and price tickets. Only the products are stealable.
- Desktop demos: two monitors on a shared desk, with keyboards, desk mats and cable tray. Products can be reached from the customer aisle.
- Arcade: paired cabinets face the same open play area, with carpet and standing mats. The vending machine sits against the side wall facing the arcade customers.
- Service area: PCs sit on rear workbenches; accessories and cartons occupy a fixed rack. The central stockroom doorway remains clear.
- Checkout: one till and card reader on a solid counter by the exit. The low header across the entrance has been removed so it does not hide the player.
- Restrained tile joints, matching fixtures, localized lighting and lower global illumination replace scattered floor pads and loose sample boxes.

Display furniture has physical collision and is excluded from loot-drop locations.
Loot support heights are applied to item roots, so picking an item up does not
leave it offset above the CarryAnchor. The Jobs image is captured from the real map.

All **11 items, $4,060 and 32 cargo** are unchanged. Retail duplicates are grouped
as stocked product departments. The 60-second Normal timer and existing alarm
windows remain unchanged.

## Validation

- **87/87 core checks** passed.
- **7/7 existing Electronics checks** passed, using physical movement through showroom and service aisles. Full clear at MAX: **53.68 s**. Rush: **26.65 / 35 s**. Small Van: **19.95 / 60 s**. Client Order: **21.30 / 35 s**.
- **3/3 additional checks** passed: support elevations, solid furniture footprints, full clear at the Electronics upgrade cap (Strength 4, Grip/Carry/Noise/Van 13).
- The local-tier full clear takes **55.30 s**, with **4.70 s** left. Taking quiet service stock first and bulky arcade items last delays the alarm until **47.60 s**. These are uninterrupted automated routes, not beginner completion estimates.
- Rendered entrance, arcade, displays and service area at 450×800, narrow portrait at 320×712, and the Jobs card. No physical-phone GPU benchmark was performed.

[Entrance](tests/electronics_polish_entrance.png) · [Arcade](tests/electronics_polish_arcade.png) · [Displays](tests/electronics_polish_displays.png) · [Service](tests/electronics_polish_service.png) · [Narrow](tests/electronics_polish_narrow.png) · [Jobs](tests/electronics_jobs_polish_450x800.png).

Packages: Windows and Android, DEV and persistent variants, **0.9.47 / Android code 64**. DEV reset remains enabled in the source project.
