# Results motion — 0.9.78 / Android 95

Success Results now consists of independent live layers:
- Clean alley background, with no baked title, cash, banknotes or reward rays.
- Separate transparent ESCAPED sprite: 0.62 → overshoot → 1.0 entrance in 0.58s,
  small initial tilt, followed by a restrained 3.2-second breathing loop.
- Existing Meshy cash mesh in a transparent 512×384 3D viewport. Real subtle yaw
  and roll, a 1.9-second small/big/small scale loop (±6.5%), and light hovering.
- 22 bounded banknotes falling, tumbling and flipping, drawn behind the UI.
  Center opacity is reduced and particles fade before the buttons. No input capture.
- Slowly rotating green rays and a breathing halo rendered by a lightweight shader.
- Money amount pops by 11% after count-up, then breathes by ±1.8%.

Only successful Results celebrate. The failure presentation and yellow replay / mint
Home colors are preserved. Menu teardown releases the 3D viewport and animation;
hidden views stop CPU animation. Other CashVisual uses keep their static update mode.
The view does not grant money, change timers, or delay either action button.

Validation: test_results_v2 82/82 (including movement, overshoot, complete pulse,
non-interception, cleanup and failure), test_lucky_flow 13/13, test_level_gifts 59/59.
154 checks passed. Rendered screenshot captures and a 64-frame live game capture
reviewed. tests/results_animated.gif is the animated preview, assembled from those
captured frames; tests/capture_result_motion.gd can reproduce the capture.

## Art tools / saved assets
Built-in image_gen.imagegen edited the previously supplied result reference.
assets/ui/results/alley-clean.png and assets/ui/results/escaped-title.png are the
new background and separate alpha sprite. The cash is the existing 3D mesh;
assets/ui/results/banknote.svg is a native vector currency particle.

Background prompt:
Edit the reference into a CLEAN BACKGROUND PLATE for an animated game screen.
Keep only the dark navy nighttime police alley, left police car, duffel bag,
right door, wet asphalt, overhead cyan lighting. Completely REMOVE the ESCAPED
lettering, central money stack, every airborne green banknote, green sparkles,
and ALL radial green rays/glows. Fill their areas seamlessly with the dim alley.
No text, icons, UI, money floating or rewards anywhere. Center dark uncluttered
navy, not green. Portrait same framing and aspect as reference. Final asset will
have live moving text, 3D money and particles composited by game engine.

Title prompt:
Extract/recreate ONLY the exact large green glossy extruded 3D word ESCAPED!
from this reference, isolated on genuine transparent alpha background. No
background, no alley, no cash, no rays, no stars. Keep the rich mint-green beveled
lettering, deep dark green extrusion, small luminous edge and original fun chunky
lettering shape/arrangement. Wide horizontal asset, very tight crop around the
word with small transparent margin for the soft glow. This is a separate sprite
to animate in Godot, not a screen mockup.

All four Windows/Android DEV and Persistent exports completed successfully. Both APKs verified: 0.9.78, versionCode 95. Source development mode restored.
