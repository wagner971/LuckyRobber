# Apartment interior · 0.9.44

Apartment is a small furnished flat with three readable spaces and a clear central route to the van.

- Living: one TV on a permanent media cabinet, a chair facing it, a floor lamp and a restrained rug. The right side is a compact work nook with a laptop and desk fan on a desk. The flamingo remains the eccentric collectible, displayed beside the front window rather than in the main walkway.
- Kitchen: fridge, continuous base cabinets, sink, tap, backsplash, chopping board and a microwave on the counter. The old monitor and printer no longer occupy the kitchen.
- Bathroom: toilet facing the open aisle, rear vanity and mirror, shower tray with a transparent screen, towel rail, toilet-roll holder and bath mat.
- Flooring, skirting, windows and small household details tie the props to the room. Two inexpensive shadowless fill lights support the warm interior. The existing surrounding street and neighborhood remain intact. The low canopy over the player has been removed so the doorway stays visible.

The apartment now has nine different loot types. The duplicate TV/chair and misplaced monitor/printer were replaced by a floor lamp, desk fan, laptop and microwave. Their values, cargo, strength requirements, pickup durations and weight classes match the four replaced entries. The level still totals **$1,210 / 17 cargo**, with the same fridge objective, flamingo trophy and 60-second timer. Other location inventories and the tutorial are unchanged.

Fixed cabinets, desk, vanity and shower tray have physical collision and exclude invalid drop positions. Elevated loot uses its root height so pickup to CarryAnchor removes the supporting-surface offset. The Jobs preview is rendered from this actual layout instead of the old illustrative reference.

Validation:

- Physical full clear: **36.37 s** at maximum upgrades; **39.35 s** at the Final Job entry profile (Strength 2, Grip 4, Carry 4, Van 6, Noise 4). All nine pickups, loading trips and escape passed, without teleporting the route.
- Core gameplay: **87/87**; onboarding: **27/27**; Jobs navigation/layout: **51/51**.
- The core test placement helper now stands on reachable floor beside furniture rather than placing the player on top of a cabinet or inside neighboring loot.
- Rendered gameplay checks at **450×800** and **320×712**, plus a Jobs card capture. These are desktop-rendered mobile layouts, not physical-phone performance measurements.

[Entrance](tests/apartment_polish_entrance.png) · [Kitchen](tests/apartment_polish_kitchen.png) · [Bathroom](tests/apartment_polish_bath.png) · [Narrow](tests/apartment_polish_narrow.png) · [Jobs](tests/apartment_jobs_polish_450x800.png).

Build version: **0.9.44**, Android code **61**. DEV reset remains enabled in the source project; separate persistent packages preserve saves.
