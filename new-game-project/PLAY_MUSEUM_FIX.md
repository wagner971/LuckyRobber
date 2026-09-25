# Home Play and Museum movement — 0.9.60 / Android 77

Home's PLAY always opens Jobs / Location Select, including fresh profiles, pending Special Jobs and ready Apartment/Museum finales. It no longer substitutes a direct launch action. Choosing a mode on the selected location still starts the heist through the existing transition. Automatic first-launch practice and explicit tutorial replay remain available.

The Museum movement defect was reproduced through the real UI launch path: the scene transition temporarily disabled the player, then a first-heist briefing or focus-loss pause prevented the transition from restoring it. Resume restored input and the timer but did not restore the player's enabled flag. The pause/resume lifecycle now owns this flag: pause disables movement, resume enables it. This fixes the same path for all locations without bypassing pauses or changing timers/collisions.

## Verification

Before the fix, the new regression reproduced four failures: fresh/special Home Play bypassed Jobs, and Museum could not move after its first briefing or a pause during reveal. After the fix, all 13 checks pass, including actual touch-drag movement in Museum normal, Final Job, and focus-loss/resume paths.

324 passing checks across the new regression (13), screen motion (78), Home (29), Jobs (55), Museum routes (11), onboarding (50), core (87), fresh launch (1). Museum physical full clear: 55.40 / 85 seconds at MAX, Final Job 59.45 / 85 seconds at the tested intermediate tier. Rush, Small Van and Client Order routes also passed.

The Home and onboarding fixtures now exercise the intended navigation contract. The motion cleanup assertion waits for completion within a bounded deadline, allowing cold-renderer layout frames rather than assuming a fixed wall-clock frame count.

No economy, unlock rules or map geometry changes. Android device performance is not measured. Existing certificate-store and headless shutdown resource warnings remain.

All four Windows/Android DEV/Persistent builds exported. Both Windows executables pass packaged startup checks. Both Android APKs signed and verified; manifests report 0.9.60 / code 77 / arm64-v8a. DEV fresh-start setting restored to enabled.
