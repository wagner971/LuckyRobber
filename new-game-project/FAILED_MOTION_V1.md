# Failure Results live animation — 0.9.79 / Android 96

BUSTED now uses the same independent-layer animation approach as ESCAPED:
- The clean police alley contains no baked title or emblem.
- A separate transparent BUSTED sprite stamps in (1.30 → settle), tilts into place,
  and gets a brief 5-design-pixel impact shake. The shake ends by 0.65 seconds.
- The separate red shield enters with a pop and loops small/big/small (±5.5%)
  over 2.3 seconds, with gentle hover and rotation.
- The lost amount pops after its count-up, then breathes very subtly.
- Red rays rotate slowly behind the shield. Twelve low-opacity particles drift up.
- Red/blue police reflections alternate softly at the edges, with a clean center
  and feathered boundaries. No fullscreen flashing or celebratory money rain.

RETRY remains yellow, Home mint. Cash and diamonds, retry mode, tutorial navigation,
reward persistence and banked balances are unchanged. All decoration ignores input.
Leaving Results frees the animated view and particles; hidden views stop CPU motion.

Validation: test_results_v2 100/100, test_onboarding 51/51, test_lucky_flow 13/13.
164 checks passed, including actual animated transforms, ended shake, safe-area
bounds at 320×712/360×800, action routing, unchanged balances and cleanup.
A 64-frame live rendered capture is available as tests/failed_animated.gif.
Capture command: Godot --path . --script tests/capture_result_motion.gd -- --failed.

## Assets and prompts
Built-in image_gen.imagegen, edited from assets/ui/results/busted.png (the user's
previous failure-screen reference). Saved assets:
- assets/ui/results/busted-title.png
- assets/ui/results/busted-emblem.png
The existing assets/ui/results/alley-clean.png is reused as the background.

Title prompt:
Extract/recreate ONLY the exact large glossy red-orange extruded 3D word BUSTED!
from this reference, on genuine transparent alpha background. No alley, no shield,
no rays, no UI. Preserve the chunky tilted lettering, salmon-red face, deep burgundy
extrusion and delicate bright edge. Wide horizontal sprite, tight crop with small
transparent margin. This is a separate game-engine animated title asset, not a
screen mockup.

Emblem prompt:
Extract/recreate ONLY the central red shield with the dark navy thief-mask face
and white eyes and crossed mouth from this reference. Isolate on genuine transparent
alpha background. Preserve the red/coral beveled shield rim and face, dark navy
inner border, subtle red edge glow and exact emblem shape. No title, no text, no
background, no rays, no police car. Tight square/portrait crop around the shield
with a small transparent margin for glow. A separate mobile game animation sprite,
not a full screen.
