# Run loot readability — 0.9.74

Normal loot now has a permanent mint silhouette and a small ground ring, visible
from the start of a run. Focus increases the outline from 3.5 to 5 viewport pixels
with a short eased transition. Strength-locked loot uses warm gold with its existing
lock; Rare/Epic/Legendary keep their blue/purple/gold palette and existing sweep.

The effect is installed by RunManager after rarity/Lucky replacements, including
the tutorial. Decorative furniture and menu dioramas remain unmarked. Carrying,
loading, loaded and finished states hide it; dropping restores it. Dark Heist
still suppresses ordinary loot highlights. Walls continue to occlude silhouettes.
Item values, cargo, collision, noise and pickup reach are unchanged.

Mobile cost: two extra draw calls per available item (one batched outline mesh
for the whole prop, one flat ring). No additional lights, particles, shadow maps,
screen textures or per-part outline materials. Geometry is built once when the
run starts. Compatibility renderer screenshots verified in Apartment, Laboratory,
Dracula's Castle and narrow tutorial. Physical phone performance not benchmarked.

Validation: 120 highlight checks across all 13 locations; core gameplay,
onboarding, Lucky Blocks and HUD regression suites. Screenshots:
tests/highlight_apartment.png, tests/highlight_laboratory.png,
tests/highlight_castle.png, tests/highlight_training_narrow.png.
