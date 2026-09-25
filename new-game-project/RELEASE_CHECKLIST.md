# Release checklist

## Before release

- Set `[development] enabled=false` in `project.godot`. It remains `true` in this development build.
- Verify a production launch reads the persistent main profile, does not reset progress, and hides DEV MAX and all test-only controls.
- Replace every file in `assets/sfx` with final licensed WAV/OGG art. Current files are **PLACEHOLDER SFX — REPLACE BEFORE FINAL RELEASE**.
- Listen to at least ten consecutive runs for repetition, clipping and relative volume, including light/heavy pickup and every van weight.
- On a physical Android device, verify touch controls, HAPTICS ON/OFF, CAMERA EFFECTS ON/OFF, SFX slider, orientation, frame rate and heat.
- Recheck the full Godot test suite, then export/sign the release package with an incremented version code.
