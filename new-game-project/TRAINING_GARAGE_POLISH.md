# Tutorial garage · 0.9.43

The tutorial is now a small electronics hobby workshop, with a readable storage wall and two work areas rather than three unrelated objects standing on the floor.

- The TV sits on a low media cabinet on the left, close to the initial player position.
- The gaming PC sits on the right end of a rear workbench. The other end has a repair mat, parts tray and screwdriver. The final chair faces the bench.
- Pegboard tools, drawer storage, a fuse box, conduit and wall hose belong to the workshop. These are fixed decoration, with no repeated loot models.
- Cabinet and bench have physical collision and participate in drop-position exclusion. Their contents are raised at the loot root, so reparenting to CarryAnchor removes the furniture elevation automatically.
- A central clear floor leads through the open threshold to the rear of the van. The garage has skirting, an exterior roof edge, threshold grips, a drain and fixtures that explain its warm interior light. Cool pavement, planting, boundary fences, neighboring garages, sidewalk and street surround it.

Only training uses `training_art.gd`. Apartment and all other location layouts are unchanged. The three tutorial items, order, 6 cargo, $640 reward, progressive HUD, absence of timer/noise and direct departure into Apartment are preserved. No additional shadow-casting local lights or post-processing effects were introduced.

Validation: 7 physical-route checks pass for all three pickups, deliveries and escape; automated traversal takes 13.35 s at uninterrupted input speed. All 27 onboarding checks and 87 core gameplay checks pass. Desktop rendered captures cover entry, highlighted TV, PC approach, van and 320×712 narrow framing. These are not physical-phone GPU measurements.

[Entrance](tests/training_art_entrance.png) · [TV](tests/training_art_tv.png) · [Workbench](tests/training_art_workbench.png) · [Narrow phone](tests/training_art_narrow.png).

Packages: Windows/Android DEV and persistent variants, 0.9.43 / Android code 60. DEV reset remains enabled in the project.
