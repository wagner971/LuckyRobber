# Lucky Wheel PNG presentation — 0.9.76

The two supplied PNGs are copied unmodified to assets/ui/wheel:
lucky-wheel-stage.png and lucky-wheel-disc.png. Native canvas shaders mask the
disc interior and keep the stage's gold frame/red pointer fixed in front of it.
No generated replacement art. Labels, hit targets and cooldown remain real UI.

The 8 illustrated sectors clockwise from the top represent: 3 diamonds, van
ticket, 8 diamonds, large cash, medium cash, character ticket, medium cash,
small cash. Existing 7 award definitions and all probabilities are preserved.
The info button discloses exact odds and explicitly states that sector geometry
does not represent odds; the two medium-cash sectors share the 22% outcome.
Actual cash amounts scale with the profile. Jackpot skin tickets remain prototypes.

Spins ease out over 3.4 seconds, land centrally on a valid illustrated sector,
and reveal the matching reward/balances with audio and haptics at the end.
Rewards are still saved before the animation, so leaving mid-spin is safe.
DEV unlimited spins and the production UTC cooldown remain unchanged.
Spin artwork dims during a spin/cooldown. Back/info and the wallet remain available.

The complete art preserves aspect ratio inside the safe area. Verified rendered
at 450×800 and 360×800 with simulated top/bottom insets; no circle distortion.
Disc import is capped at 1024 pixels with mipmaps; source PNG remains full quality.

Checks: test_lucky_wheel_art 165, test_daily_wheel 17, test_daily_gift 14.
Coverage: all 100 random buckets, both medium-cash art sectors, every animated
award category, balance timing, safe areas, navigation mid-spin and cooldown.
Screenshots: tests/lucky_wheel_ready.png, lucky_wheel_spinning.png,
lucky_wheel_jackpot.png, lucky_wheel_narrow_used.png, lucky_wheel_odds.png.
