# Daily Gift V1 — 0.9.63

Home has two compact optional daily actions: **DAILY GIFT** and **FREE SPIN**. There is no calendar or streak. A red badge marks an available gift. One tap awards $300 and one diamond; every fourth total claim awards two diamonds. The brief reward text changes to a small countdown. The next gift becomes available 24 hours after the previous claim, regardless of missed days.

The spin wheel keeps its existing once-per-UTC-day schedule. Neither reward is required for campaign progression. Both use the same shared daily ledger, so DEV's fresh heist progress does not reset claim cooldowns or diamonds. Schema 10 saves migrate to schema 11 with a backup.

Validation: `tests/test_daily_gift.gd` (14 checks), `tests/test_daily_wheel.gd` (17 checks), Home/studio UI and onboarding route checks. Captures: `tests/daily_gift_ready_450x800.png`, `tests/daily_gift_reward_450x800.png`, and `tests/daily_gift_claimed_360x640.png`.
