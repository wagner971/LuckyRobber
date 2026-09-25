# Suburban House interior · 0.9.45

Scope is **Suburban House only**, as clarified by the user. Villa is unchanged.

The house retains its long cutaway footprint, lateral garage, parked car, driveway, open entrance, rear-facing van, extended lawn, neighboring houses and street. Interior furnishing now explains each space:

- **Garage:** the rolling tool cabinet backs onto the work wall beside a real workbench, vise and pegboard. Spare wheels share a side rack; the electrical panel belongs to the wall. Loose miniature blocks and the scattered floor props were removed.
- **Kitchen/dining:** fitted cupboards, a sink and a chopping board sit beside the fridge. The existing stealable chair faces a properly sized dining table, with a placemat and plate. An entry bench sits against the front wall, outside the main lane. The wall below the kitchen remains absent; the lounge divider above it remains present.
- **Lounge:** the TV sits on a rear media cabinet facing the sofa. A shared rug, coffee table, magazine, side table and small lamp form a single seating area. The TV is raised at the item root instead of the visual child, preventing the furniture offset from following it into CarryAnchor.
- **Bathroom:** the bathtub and trophy duck are grouped together, with the duck on a small cabinet. The toilet still backs onto the right wall and faces left, away from the entry. A wall-aligned vanity/mirror, linen cabinet, towels and toilet-roll holder give the remaining fixtures a purpose. Larger, quieter tile joints replace the strong blue grid.

Fixed furniture has collision and drop-position exclusion. The two circulation lanes remain usable. Eight unique loot types, **$2,140 / 23 cargo**, the sofa objective, duck trophy, timer, alarms and upgrade economy are unchanged. No new loot types or post-processing effects were added. Room lights remain shadowless.

Jobs and the Suburban unlock thumbnail both use the actual updated map.

## Verification

- Core gameplay: **87/87**; House identity/placement regression: **0 failures**.
- Physical full clear at MAX: **53.90 s / 60 s**.
- Local-tier progression run: **44.77 s**, **$1,950**, sofa collected, **20 cargo** (Strength 3, other upgrades 7).
- Full clear with moderate movement upgrades: **57.52 s**, **$2,140 / 23 cargo** (Strength 3, Grip/Carry/Noise 7, Van 9). This is a tight route, not a novice completion estimate. It clears the rear rooms first, then the dining chair, tool cabinet and fridge. The existing progression makes Van 9 available after unlocking Villa through the House cash + sofa objectives.
- Contracts remain physically solvable: Rush **27.87 / 30 s**, Small Van **21.93 / 60 s**, Client Order **22.90 / 30 s**.
- Rendered entrance, garage, kitchen, bathroom, lounge, narrow **320×712** view and Jobs preview. These checks use desktop rendering, not a physical phone.

[Entrance](tests/house_polish_entrance.png) · [Lounge](tests/house_polish_lounge.png) · [Bath](tests/house_polish_bath.png) · [Narrow](tests/house_polish_narrow.png) · [Jobs](tests/house_jobs_polish_450x800.png).

Packages: Windows and Android, DEV and persistent variants, **0.9.45 / Android code 62**. Source project keeps DEV reset enabled.
