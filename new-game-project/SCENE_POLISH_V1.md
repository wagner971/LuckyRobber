# Scene Polish V1

One visual pass serves every playable level on Godot Compatibility, including Android. The shared `WorldEnvironment` now adds restrained contrast/saturation and a low-intensity highlight glow. A single transparent `canvas_item` shader beneath the gameplay HUD adds a soft vignette and a pair of warm or cool light shafts. It does not sample the screen, blur the scene, add shadow-casting lights, or require per-object material edits.

Warm shafts are used for homes, the museum and pyramid; cool shafts are used for the electronics store, laboratory and castle. Settings → VISUAL EFFECTS turns off the pass and the existing camera shake. The old toon and halftone rendering remain absent.

Portrait comparison captures: `tests/scene_polish_apartment_before.png` / `tests/scene_polish_apartment_after.png`, with additional after-captures for Laboratory, Pyramid and Castle. The final intensity was chosen after comparing the four locations; an earlier filmic curve made white props too bright and was discarded.

Verification: project import, startup smoke, gameplay HUD touch/readability, and gameplay regression tests. Windows and Android packages export with the Compatibility renderer. Android GPU performance should be checked on a device; the added shader itself is one transparent full-screen draw with no texture reads.
