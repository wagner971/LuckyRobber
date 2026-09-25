# Toon halftone — 0.5.2

Notă: această implementare pe fiecare obiect a fost înlocuită în versiunea 0.9.3 de [Camera Toon](CAMERA_TOON.md), iar halftone-ul a fost eliminat complet din jocul activ în 0.9.5. Textul de mai jos documentează varianta istorică.

The entire procedural 3D presentation now uses a cartoon shader adapted from the user-provided UltimateToon package and the tuned implementation in the cartoon Neon Harbor project.

## Rendering

`assets/shaders/toon_halftone.gdshader` keeps the visual core of that implementation: three-step lighting, a blue shadow tint, hardened cast shadows, a warm rim and procedural round halftone dots. Dots are rendered in screen space and react to the main directional light. They grow only through midtones and shadow, leaving illuminated surfaces clean. Subpixel cells converge to average coverage to avoid crawling dots at distance.

The project uses only solid-colour procedural meshes, so texture, normal-map and triplanar branches from the large Neon Harbor shader were intentionally removed. This avoids unused texture fetches on Android while retaining the requested style.

`scripts/toon_material.gd` provides four profiles:

| Profile | Use |
| --- | --- |
| GROUND | Reduced halftone, no rim or outline, preventing floor moiré |
| PROP | Stronger shadow dots, subtle rim and thin outline |
| CHARACTER | Softer dots and shadows, stronger rim, slightly wider outline |
| MARKER | Clean color without dots or outline for gameplay zones |

Props and characters receive a small shared inverted-hull outline pass. Ground and markers skip it. The profile distinction mirrors Neon Harbor's per-surface tuning but is specialized for the fixed orthographic camera and small rooms in STEAL EVERYTHING.

`ToonMaterial.albedo_color` remains the color authority. Existing suit and van cosmetics update the shader uniform in place, reset correctly and persist unchanged. The pulsing van zone also remains synchronized. Physics, collision, interaction timing, camera, economy and save schema are untouched.

## Verification

391 checks passed with zero failures:

| Suite | Checks |
| --- | ---: |
| Toon materials and cosmetics | 139 |
| Core gameplay | 78 |
| Gameplay HUD | 57 |
| Live menu | 35 |
| Character and animation | 32 |
| Variety / Special Jobs UI | 29 |
| Challenge UI | 21 |

Visual captures cover Home, Upgrades, NORMAL, RUSH HOUR, pickup, heavy carry, loading, warning and alarm. The complete runtime level is checked recursively so every 3D mesh has a ToonMaterial. Ground, character and marker profiles are asserted independently, including live cosmetic recoloring.

Windows version:0.5.2.0. Android version:0.5.2/code10, ARM64 debug-signed. Windows is smoke-tested headlessly and with actual rendering on a separate QA profile. Android export succeeds but has not been tested on a physical device.

Pre-change source checkpoint: `../checkpoints/before-toon-halftone`.
