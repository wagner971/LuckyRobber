# UI motion — 0.9.59 / Android 76

## Presentation

- Shared 240 ms menu dissolve for Home, Jobs, Upgrades, Collection, Cosmetics, Settings, Stats and the duplication lab. The outgoing tree remains visible while the new layout settles; its input and 3D preview rendering are disabled, then it is released. No screenshot readback, blur pass or second continuously rendered scene is needed.
- Jobs retains discrete snap paging. The outgoing card shifts 12 units and shrinks to 96% while fading fully out in 120 ms. The incoming card then restores scale, position and opacity in 180 ms. Preview and text stay clipped; two readable titles never overlap. Rapid changes cancel old tweens and restore the final card's exact resting position.
- UI-triggered map starts, retries, Special Jobs, Final Jobs and tutorial replay use a 120 ms navy fade-in, scene construction while covered, then a 240 ms reveal. Input is blocked during this transition; duplicate Play is ignored. Run physics, movement and the timer stay held until the reveal finishes. A focus-loss pause during reveal is preserved.
- Success/failure and tutorial results fade in without replacing the reward count-up or trophy timing. Pause and first-heist briefing fade and scale gently into place; closing them fades out for 120 ms. Buttons now ease into the pressed scale before their existing release pop.
- Ordinary shop purchases and settings toggles update in place rather than replaying a whole-page transition.

## Copy cleanup

Removed the locked-location paragraphs such as `Complete 2 Villa objectives`, replacing them with a compact action to play the preceding job. The authoritative unlock conditions are unchanged. Museum's explicit chapter gate remains. Removed `NORMAL BEST · NO FULL CLEAR YET`; Stats shows a best-clear time only after one exists.

The user's last phrase was incomplete (`Nu vreau`) and the follow-up question remained unanswered. The two attached snippets were treated as text to remove, while preserving progression rules and existing records.

## Verification

454 passing checks: motion 78, Jobs 55, safe-area UI 36, core 87, onboarding 50, fresh-launch 1, DEV 24, Home 29, shop 19, HUD 75.

Motion tests render 360×640 and 360×800 with simulated top/bottom safe areas. Existing UI checks also cover 320×712, 360×720, 450×800, 720×1280 and 720×1600. Checked normal/rapid menu navigation, rapid swipes, double Play, timer preservation, restoring movement, pause during reveal, success and failure. Mid-transition and settled screenshots are under `tests/motion_*.png`.

Home's old Final Job test fixture was updated to satisfy the already-existing Pickup/Carry requirement before testing the van-capacity gate. Tests that activate Play now wait for the presentation transition. No gameplay balance, save schema or unlock rules changed.

Desktop Compatibility rendering inspected. Android device performance remains unmeasured. The existing local certificate-store warning and shutdown-only resource reports in core/onboarding tests remain; rendered motion/UI tests have no script errors.

All four Windows/Android DEV/Persistent builds refreshed. Both packaged Windows executables passed startup smoke checks. Both Android APKs signed and verified; manifests report version 0.9.59, code 76, arm64-v8a. Source DEV reset setting restored to enabled.
