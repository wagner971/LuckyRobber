# Results reference polish — 0.9.77 / Android 94

Win and loss now use portrait artwork matching the supplied police-alley references.
PLAY AGAIN and RETRY are yellow; RETURN TO HOMESCREEN is mint in both states,
following the explicit instruction rather than the success reference's colors.
Live location, cash/loss amount, cash wallet, diamonds and buttons remain native UI.
The main screen has no scrolling, upgrade cards or bottom navigation.

The reward counts up in 0.55 seconds; the wallet completes in 0.60 seconds.
A compact reward/status line fades in afterwards. Tapping it opens optional run
details (haul, trophies, rare loot, final clear, location unlocks and Rush/contract
rewards). Existing Lucky Block and level-gift presentations still follow Results.
The view never changes currency or rewards. Failed runs leave banked money intact.

Replay stays at the same location. Completed Final Jobs and Rush Hour replay as
normal runs; failed Final Jobs retain that mode. Tutorial success keeps CHOOSE A
JOB, opening Jobs rather than starting another run. Tutorial Retry and Home remain
available. This replaces the prior forced upgrade/next-job primary action.

The 941×1672 composition scales uniformly inside the safe area. The surrounding
background fills tall screens without duplicating the baked headline. Long names,
large balances and seven-digit rewards shrink to fit. PNG imports use mipmaps.

Validation: test_results_v2 72/72, test_suite 87/87, test_onboarding 51/51,
test_lucky_flow 13/13, test_level_gifts 59/59 — 282 checks, zero failures.
Rendered views reviewed at 720×1280, 450×800 and 360×800 with simulated safe insets;
layout tests also cover 320×712 and 720×1100. Physical device testing was not run.
Screenshots: tests/results_escaped.png, results_busted.png, results_final_job.png,
results_trophy_mobile.png, results_narrow_safe.png, results_busted_narrow_safe.png.

## Art provenance and prompt

Tool: image_gen.imagegen, two reference-image edits via the ImageGen skill.
Sources supplied by the user:
- C:/Users/trash/Downloads/JOC/ChatGPT Image Sep 25, 2026, 12_14_02 AM.png
- C:/Users/trash/Downloads/JOC/ChatGPT Image Sep 24, 2026, 11_12_32 PM.png
Saved project assets:
- assets/ui/results/escaped.png
- assets/ui/results/busted.png

Prompt (separately substituted ESCAPED/green cash or BUSTED/red shield):
Edit this supplied portrait mobile-game results screen into a reusable game
background plate. Preserve the original composition, dark nighttime police alley,
colors, lighting, and exact large 3D ESCAPED!/BUSTED! lettering around 18–30% of
image height, and preserve the central green cash bundle and green rays / red
shield with thief mask and red rays at 32–49% height. IMPORTANT remove ALL OTHER
text and interface elements: remove the top-left close button, top-right wallet
if present, APARTMENT and its horizontal divider lines, the cash caption, all
dollar signs and amounts including $50, and BOTH bottom buttons completely
including their text, frames and glows. Fill those removed areas seamlessly with
the same dark atmospheric alley background and subtle existing central lighting.
The only text remaining anywhere must be ESCAPED!/BUSTED!. Do not move or enlarge
the existing title or central icon. Keep bottom 30% dark and uncluttered for live
buttons that will be drawn by the engine. Keep empty top 15% for live wallet/location.
No new objects or symbols. Match portrait aspect ratio of reference. This is a
project asset, not a new UI mockup.

All four Windows/Android DEV and Persistent exports completed with exit code 0. Both APKs verified as version 0.9.77, versionCode 94. Source development mode restored to enabled=true.
