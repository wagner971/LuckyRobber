# Alarm presentation — 0.9.51

Replaced the continuously pulsing red damage vignette with a quiet, fixed amber corner frame. The shader draws short thin strokes and a small local feather at the four corners only. The playfield center and most of the edges remain completely transparent. No screen texture, TIME animation, blur pass, added light or geometry is required. Widths are measured in logical canvas units so the frame remains fine on different aspect ratios.

`Alarm close` now stays in the existing noise HUD with its amber icon/bar. It does not activate any screen overlay. Once the alarm actually triggers, the timer's caption becomes `POLICE IN`, with warm-white whole-second digits, a neutral dark panel, amber border and a draining time strip. The noise card reads `ALARM · RETURN TO VAN`, avoiding a second copy of the countdown. The tiny final-five-second numeric emphasis is reduced. The static corner frame is hidden during pause and outside ACTIVE gameplay, and is reset with the HUD.

Existing short alarm callout, sound, haptics, escape action, countdown duration and alarm rules remain unchanged. No economy or level changes.

Validation: 75 gameplay HUD checks, 35 satisfying-pass checks and 87 core checks passed. Actual captures at 450×800, 360×800 and 600×800 were generated; portrait and tall warning/alarm states inspected. Shader compiled successfully on the project's Compatibility renderer. All changes share the common HUD and therefore apply to every level.

Capture files: `tests/hud_warning.png`, `tests/hud_alarm.png`, `tests/hud_alarm_tall.png`, `tests/hud_alarm_tablet.png`, `tests/hud_alarm_settled.png`. Logs: `tests/alarm_polish_*.log`.

Windows and Android DEV/Persistent exports completed. Both Windows packages pass headless startup smoke checks. Android APKs report 0.9.51 / code 68, arm64-v8a, and pass export signature verification. DEV reset remains enabled in source. Android was not tested on a physical phone in this pass. Only the existing environment certificate-store warning appears in the engine logs.
