# Home showcase

Home now uses one 3D scene for the garage background, thief, fridge and van. The older warehouse illustration and the separate desaturation/darkening pass on the models are no longer used by this screen. Warm fixtures, blue ambient light, a cool rim and contact shadows share a coherent palette with the game models.

The faceted display platform has luminous cyan inserts, two visible upward projector cones and 44 small rising particles. The particles use a single MultiMesh with billboard scale preserved; all animation shares the menu preview clock. The garage adds utility lockers, a shutter, crates, warm fixture haze and a tiled floor with restrained light pools. Background lighting is kept lower than the player lighting to preserve focus.

The live viewport fills the menu background. Its camera framing follows the existing hero layout slot, including safe-area changes, so the buttons retain their existing layout and input behavior. Resolution is capped at 576×1152, with 2× MSAA and 30 render updates per second. Only the key light casts shadows; projector cones do not ray-march or sample the screen. Preview animation and rendering stop when the menu is suspended or removed. Physical Android GPU performance has not been measured.

Captures: [reference-size composition](tests/home_showcase_reference.png), [narrow portrait](tests/home_showcase_320x712.png), [20:9 with simulated safe area](tests/home_showcase_360x800.png), and consecutive animation samples [A](tests/home_showcase_motion_a.png) / [B](tests/home_showcase_motion_b.png).

Regression coverage includes Home navigation, actual pointer interaction, equipped costume/van synchronization, portrait resizing, suspension/resumption and repeated menu cleanup. Other menu previews retain their existing framing and render budget.

Results: Home V2 passed; Live Menu 50/50, UI V2 25/25 and Upgrades Shop 19/19 passed. Both Windows executables and both Android debug APKs were exported successfully as 0.9.41 (Android versionCode 58). The project remains in DEV mode after building the persistent variants.
