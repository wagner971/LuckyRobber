# Reward cards V2 — 0.9.81

Lucky/Unlucky reference-driven ImageGen art, separate animated cube/halo/stars, dynamic effect names/descriptions, native green acknowledgement button inside card. Gold positive, crimson/orange negative. Effects, odds, progression and saved rewards unchanged.

Outfit: latest user correction followed: existing gift opening, three-second color cycle, silhouette, character idle, star/square motion and confetti retained. Only background, frame, particles, header and text shadow colors follow common green / uncommon blue / rare purple / legendary gold. Character remains live 3D; no replacement portrait.

Validation: 59 level gift + 13 Lucky flow + 117 effect checks; 360 layout checks across all 40 effects at 360×640, 360×800, 450×800, with top/bottom safe insets. Long descriptions automatically fit above footer. Actual rendered captures: tests/card_v2_*.png. Images imported with mipmaps and 1024 maximum dimension for clean scaling and bounded texture memory.

Assets (project-relative): assets/ui/reward_cards/lucky-frame.png, unlucky-frame.png, lucky-cube.png, unlucky-cube.png. Generated using built-in image_gen; transparent sprites retain alpha. No API CLI used.

## Final prompt set

### lucky_frame
Reference: C:/Users/trash/AppData/Local/Temp/codex-clipboard-27f90770-faa5-4bec-a371-522581f6de63.png

Create a production game UI background asset based precisely on this gold Lucky Block card. Portrait 9:16. Retain the luminous rounded double gold beveled frame close to edges, saturated yellow gold background with subtle question-block pattern, and the exact chunky dimensional LUCKY BLOCK title plus smaller ONE HEIST. ONE TWIST. at top 5%-16%. REMOVE ALL other content: no cube, no coin, no stars, no radial rays, no LUCKY badge, no effect title, no explanation, no footer, no button. Entire area below 18% is empty patterned gold background, gently brighter at 38% height and less patterned in lower half for live text overlay. No black margins; frame spans 98% width and height. This is a reusable background only, live animated cube and text are added in game. Match reference material, polish, bevels and vivid golden color.

### unlucky_frame
Reference: C:/Users/trash/Downloads/JOC/ChatGPT Image Sep 25, 2026, 10_41_18 AM.png

Create a production game UI background asset based precisely on this red Unlucky Block card. Portrait 9:16. Retain luminous rounded double red orange beveled frame close to edges, deep saturated crimson red background with subtle large question marks, and exact chunky dimensional gold LUCKY BLOCK title plus pale ONE HEIST. ONE TWIST. at top 5%-16%. REMOVE ALL other content: no cube, shards, stars, radial rays, badge, effect title, description, footer, button. Entire area below 18% is empty patterned crimson background, gently brighter red at 38% height and less patterned in lower half for live text overlay. No black margins; frame spans 98% width and height. This is reusable background only, live animated hero and text added in game. Match reference material, polish, bevels and color.

### unlucky_cube
Reference: C:/Users/trash/Downloads/JOC/ChatGPT Image Sep 25, 2026, 10_41_18 AM.png

Extract/recreate ONLY the large central cracked golden question-mark cube from this reference as a premium game sprite on genuine transparent alpha background. Square canvas. Match exactly the gold beveled cube with white raised question marks, deep dark cracks, tilted three-quarter perspective and red-orange rim light. Include the few small surrounding gold shards, tightly composed around cube. No radial rays, no background, no card frame, no text or badges, no floor. Cube fills 78% canvas, shards within 95%. Crisp saturated glossy 3D game render. Genuine transparent background, not checkerboard.

### lucky_cube
Create a premium transparent game UI hero sprite matching the central icon of this reference: glossy golden question-mark cube with large raised cream white question marks, inside a thick shiny gold coin ring. Three-quarter view, cube and ring centered, crisp saturated gold bevels and highlights. Extract ONLY cube and ring, no title, text, card background, rays, sparkles, stars, button or shadow outside ring. Square canvas, circular ring fills 90%, genuine transparent alpha outside. This will be animated over a gold card in game. Match the reference central asset very closely.

