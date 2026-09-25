> **0.9.85:** textul copt în cadrele generate („LUCKY BLOCK / ONE HEIST. ONE TWIST.”) a fost șters din PNG-uri; titlul este acum text simplu desenat de `lucky_reveal.gd`, fără outline. Aceeași regulă pentru ESCAPED!/BUSTED! (Results), logo-ul Home și scena Lucky Wheel: fără text generat de AI în imagini.

# Purple Lucky Blocks — 0.9.83

Same layout, animation timings, interactions, spawn probability and effect mechanics. Positive card background, cube and ring recolored purple with ImageGen. Negative card retains warning red, with purple cracked cube and fragments. Live 3D model and run marker now purple with white question marks.

Project assets:
- assets/ui/reward_cards/purple-lucky-frame.png
- assets/ui/reward_cards/purple-lucky-cube.png
- assets/ui/reward_cards/purple-unlucky-cube.png

Built-in ImageGen edits; genuine alpha retained for both sprites. Source references were existing UI textures. Images use mipmaps with maximum 1024 imported dimension.

## Prompts

### purple-lucky-cube
Reference: assets/ui/reward_cards/lucky-cube.png

Edit this existing game sprite ONLY by recoloring: every yellow/gold surface of the cube AND circular ring becomes vivid saturated royal PURPLE/violet (#9b22ff main faces, bright lavender bevel highlights, deep plum shadows). Raised question marks remain pearl white with cool lavender shadows, rivets lavender. Preserve EXACT cube design, shape, camera, ring, composition, material gloss and transparent alpha background. No new shapes, text, background, stars or redesign. This is the same icon in purple instead of yellow. Genuine transparent alpha outside the ring.

### purple-unlucky-cube
Reference: assets/ui/reward_cards/unlucky-cube.png

Edit this existing cracked cube game sprite ONLY by recoloring: all gold/yellow surfaces of cube and floating fragments become vivid saturated royal PURPLE/violet (#9b22ff main faces, lavender highlights, deep plum shadows). Raised question marks stay pearl white. Keep dark cracks, exact shape, perspective, shards arrangement and composition, glossy material, and subtle red-orange edge accent for the unlucky state. No gold/yellow cube surfaces remain. No new text, frame, or background. Preserve genuine transparent alpha background. Same icon and cracks, only purple.

### purple-lucky-frame
Reference: assets/ui/reward_cards/lucky-frame.png

Edit this existing portrait game UI background ONLY by changing its gold/yellow palette to vivid saturated PURPLE/violet: royal purple background, softly brighter violet center, dark plum shadows, luminous lavender double beveled border, subtle violet question-block pattern. Title LUCKY BLOCK becomes bright pearl-lavender with purple extrusion; ONE HEIST. ONE TWIST. remains white. Preserve EXACT layout, typography, positions, empty space for live UI, frame dimensions, pattern shapes, glossy high quality. No cube, no extra text, no buttons, no added content. It must be the same UI background recolored purple, not redesigned. Preserve portrait aspect ratio.

