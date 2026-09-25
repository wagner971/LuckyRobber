# Duplication Lab V1

The Pawn Shop, stash, Hideout, offline register, and post-run loot disposition have been removed. A successful escape now deposits the value of every loaded object directly into the wallet. Collection remains the trophy display.

The first successful Laboratory heist recovers the HELIX duplicator. Its dock is visible in the laboratory's rear isolation bay; the Laboratory card in Jobs opens the interactive machine screen after recovery. The screen shows a live 3D preview of the selected object, available scans, chamber timers, claim buttons, and chamber upgrades.

Every successful heist after recovery gives one scan, regardless of the number of items carried. It also records the types of objects that actually escaped in the van. One scan starts one copy of any recorded type. The copy takes `clamp(20 + ceil(value / 80), 22, 55)` real seconds; for example, a $2,000 item takes 45 seconds. The player collects one copy at its normal cash value. It does not repeat automatically. Scans cap at 12. The second and third concurrent chambers cost $3,000 and $8,000. No copy can start without another successful heist, so the machine assists the active game loop rather than replacing it.

Save schema 8 preserves current campaign progress and active copy completion times. On the first load of an older save, unsold pending/kept loot, stocked shelves, and register cash are converted into wallet value; the retired economy data is then omitted from the new save. The conversion is one-time.

Verification: onboarding, live menu, Home, Jobs, satisfying pass, Variety, full gameplay suite, and Duplication V1 tests passed. Campaign, Laboratory, and migration regressions were also run. The portrait machine and Laboratory Jobs page were captured for visual review.
