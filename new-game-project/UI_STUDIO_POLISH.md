# UI studio polish · 0.9.42

All player-facing menu families were reviewed: Home, Jobs and chapter locks, Upgrades and details, Collection, Cosmetics, Settings, records, mastery contracts, Duplication Lab, onboarding, gameplay HUD, alarms/full van, pause, abandonment, and results. The existing art direction and live Home diorama remain intact.

## Changes

- Results separates success, arrest and abandonment. Cash dominates the page, with a live 3D bundle, a half-second count-up and restrained background rays on success. Failure has its own illustrated badge and reassuring banked-cash copy. Trophy presentation follows the cash animation. Final Job completion offers **Next Job** and selects House or Pyramid, instead of repeating the completed finale.
- Result variants with a full clear, unlocked location, special offer and new trophy use compact spacing on shorter displays. No Results scroll container was added. Buttons and navigation stay within the safe area.
- Shared menus have a dark radial background, lighter panel borders, consistent blue hover/pressed states, cash chips, centered navigation icons and equal-width tabs. Home shortcut icons are centered too. Repeated quick presses cancel the preceding touch tween.
- Jobs keeps its hero preview in the space left by the actual controls. Rush Hour + Replay Final Job + Contracts uses two rows, preventing the entire page from becoming wider than the phone. Locations without a separate finale say **Ready to clear**, rather than promising a nonexistent Final Job mode.
- Collection uses compact 3D trophy rows and an owned/total counter. Locked models are shaded recursively, including nested mesh parts. Static trophy viewports still render only once.
- Duplication has a legible selector, processing bars and green claim actions. Its rules, timings, payouts and manual collection are unchanged.
- Settings uses consistent secondary buttons and a visible volume track. Release builds no longer show the DEV reset explanation. Contracts have identifying icons, clearer completion states and shared navigation. Records have objective progress bars.
- Abandoning a run requires confirmation; Keep Playing resumes the paused run. Tutorial result screens no longer get a duplicate reward overlay. The tutorial no longer promises immediate noise onboarding. HUD copy now says **Escape to bank**, matching the current economy after removal of stash/pawn shop.

## Validation

90 final-state captures across simulated 360×640, 360×720 and 320×712 viewports, including top and bottom safe insets. Inspected both ordinary flows and late-game combinations, million-dollar wallets, maxed upgrades, all Jobs previews, tutorial replay/failure, alarms, full van, reward stacks and confirmation dialogs.

Regression suites passed: `test_ui_studio` (36), `test_ui_v2` (25), `test_home_v2`, `test_live_menu` (50), `test_upgrades_shop` (19), `test_gameplay_hud` (75), `test_jobs_v1` (51), `test_museum_final_job_ui` (6), `test_variety_ui` (31), `test_satisfying_pass` (35), `test_onboarding` (27), `test_duplication_v1` (19), and core `test_suite` (87). New regression checks exercise the actual Next Job and abandon/resume actions as well as safe bounds in crowded states.

Examples: [success](tests/studio_after_success_360x720.png), [failure](tests/studio_after_busted_360x720.png), [chapter unlock](tests/studio_after_museum_final_360x720.png), [dense rewards on 16:9](tests/studio_after_reward_dense_360x640.png), [three Jobs actions](tests/studio_after_jobs_apartment_360x640.png), [Collection](tests/studio_after_collection_owned_320x712.png), [Duplication](tests/studio_after_duplication_320x712.png), [Settings](tests/studio_after_settings_muted_320x712.png), [Contracts](tests/studio_after_contracts_320x712.png).

Godot Compatibility renderer. The new menu shader performs no texture reads; rays are evaluated only on successful results. No toon or halftone treatment was added. Mobile GPU performance and physical notch shapes still require device testing; the aspect ratios/safe areas above are simulated desktop checks.

Windows and Android packages: version 0.9.42, Android versionCode 59. DEV and persistent variants are exported separately; project DEV reset remains enabled.
