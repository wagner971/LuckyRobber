# Home reward icons — 0.9.72

Home now uses large, standalone image buttons for Daily Wheel (left) and Daily
Gift (right). Both occupy 176×176 layout units, with no panel, visible caption,
badge or timer. Existing actions and press animation remain. A claimed gift dims;
its cooldown remains in the tooltip. No reward/economy changes.

Assets saved in this project:

- `assets/ui/home/daily-gift.png` — original user-provided transparent gift.
- `assets/ui/home/daily-wheel.png` — supplied wheel with exterior white background
  removed using the built-in ImageGen tool. Transparent alpha preserved.

Both originals are retained at full resolution. Godot imports at up to 384 px,
with mipmaps for clean small-screen display.

Final ImageGen edit prompt:

> Use case: background-extraction. Edit target: attached wheel icon. Remove ONLY
> the exterior white background and replace it with genuine transparent alpha.
> Preserve the exact wheel silhouette, red pointer, gold rim, all colorful wedges,
> proportions and internal white specular highlights. No redesign, no text, no new
> details. Square PNG, tight clean cutout for a game UI.

Checked actual renderer captures at 450×800 and 360×800. Daily Gift and Daily Wheel
regressions: 31 checks passed. Windows/Android DEV and Persistent builds updated;
Android version code 89.
