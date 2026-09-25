# Final UI polish

The same 18-unit outer gutter is applied to menus and gameplay HUD. On Android and iOS it is added to the display safe-area insets after converting physical screen pixels to canvas units. The background still fills the full display; controls, pause/trophy dialogs, reward banners and cash labels stay inside the safe area. A simulated 72-unit top cutout and 54-unit bottom navigation area were used for portrait checks.

Jobs now draws the Apartment name as live UI text. The title baked into the supplied illustration is omitted from the crop, so narrow-screen framing does not cut off its first letters. Menu buttons have a restrained press/release scale response.

Visual QA captures: `tests/final_polish_safe_<screen>_<width>x<height>.png` at 320×712, 360×720 and 360×800. Screens covered: Home, Jobs, Upgrades, Collection, Cosmetics, Settings, HUD, Pause, Results and Trophy. The safe-area QA is simulated on Windows; physical Android devices should still be checked for OEM-specific cutouts and gesture bars.

Regression results: UI V2 25/25, gameplay HUD 75/75, Home V2, Jobs card swap 51/51, Live Menu 50/50, and core suite 87/87.

Version 0.9.40 exports succeeded: Windows DEV and persistent executables, plus Android DEV and persistent debug APKs. The project's `development/enabled=true` setting was restored after building the persistent variants. The Android release template is not installed, so the Android packages use the available debug template.
