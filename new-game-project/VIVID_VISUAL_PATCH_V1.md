# Vivid visual patch — 0.9.80 / Android 97

A strongly saturated mobile/Roblox-inspired color pass, using the existing wheel
and gift icons as the visual reference. The new look is implemented in the live
renderer and UI rather than swapping the scene for artwork.

Home: royal-blue garage structure, cobalt floor, cyan podium, stronger gold van
paint, vivid mint PLAY and saturated blue secondary buttons. Warm/cool lighting
is retained with cleaner white highlights. The previous extra darkening is reduced.

Menus/HUD: blue panels/buttons/nav and semantic mint/gold/orange/purple/pink/cyan
accents are more saturated. Player, garage, vehicle and item previews share the
new grade; rendered cash previews use it as well. Existing wheel/gift illustrations
and Results backgrounds are not run through a second global saturation filter.

Runs: a single screen-color sample before the HUD applies the shared color grade
to every location. Atmosphere and alarm overlays draw afterwards. There is no blur,
no new lights per level and no per-prop material cloning. Actual device performance
has not been benchmarked; the shader was tested on the project's GL Compatibility
renderer. It is hidden with the HUD while menus are open.

The grade increases saturation while preserving the maximum channel/highlights
and protecting nearly neutral colors. The math explicitly bounds saturation and
protects the power-function input, preventing invalid dark pixels at saturated
edges. Whites, grays, blacks and fully saturated primaries were checked using
actual GPU-rendered patches, not just duplicated CPU formulas.

Validation: test_vivid_color 20/20; test_suite 87/87 — 107 checks passed.
Rendered comparisons: tests/vivid_home_before.png / vivid_home_after.png;
additional captures for Upgrades, Jobs, Apartment, Electronics, Pyramid and Castle.
The source names use before/after so the visual comparison can be reproduced with
Godot --path . --script tests/capture_vivid_patch.gd [-- --before].
No image-generation assets were required for this patch.

Windows and Android DEV/Persistent exports completed successfully. APK versions verified as 0.9.80 / code 97. Source development mode restored to enabled=true.
