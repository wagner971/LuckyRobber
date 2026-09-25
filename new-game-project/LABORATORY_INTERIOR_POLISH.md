# Laboratory interior polish — 0.9.49

Scope: Laboratory only. The symmetric research institute, extended campus,
nine unique instruments, $7,250 / 39 cargo, contracts and duplication economy remain intact.

- Front analysis stations: microscope and chemical analyzer on permanent drawer
  benches, with sample trays/vials and nearby wash sinks with drying pegs.
- Processing stations: centrifuge paired with sample cassettes and refrigerated
  storage; data rack paired with cooling grille and a low cable duct.
- Engineering stations: robotic arm faces a calibration worktable within reach;
  laser faces a fixed beam stop aligned with its emitter.
- Rear containment: sealed cupboards, pressure panels and overhead light strips
  frame the specimen tank and cryo pod. The recovered duplicator remains centered
  behind the Quantum Core.
- Perimeter services and matched floor insets replace identical little equipment
  pads. Cooler ambient light and neutral local lights reduce the cyan wash.
- The rear divider segments extend from the rear wall, opening the approach to
  both containment stations in front of the permanent duplicator dock.

Benches, cabinets, calibration table and rear dock have actual collision and
drop-exclusion footprints. Small instrument elevations are applied to loot roots,
so the height is removed correctly when carried. All other instruments retain
their integrated floor stands. The Jobs preview shows the actual updated level.

## Validation

- **87/87 core checks** and **19/19 duplication checks** passed.
- **16/16 Laboratory regression checks** passed, including unique inventory,
  progression/save compatibility, van orientation and physical routes.
- MAX routes: full clear **70.35 / 85 s**, Rush **35.27 / 55 s**, Small Van
  **18.35 / 75 s**, Client Order **19.20 / 60 s**.
- **4/4 added checks** passed: solid benches, supported loot roots, local-tier full
  clear and duplication unlock after escape. Strength 5 and Grip/Carry/Van/Noise
  18 clear all nine items in **71.23 / 85 s**, banking $7,250 / 39 cargo.
  These are uninterrupted automated routes, not novice completion estimates.
- Visually inspected 450×800 analysis/engineering/containment views, 320×712
  portrait framing and Jobs. No physical-phone GPU benchmark was performed.

[Entrance](tests/laboratory_polish_entrance.png) · [Analysis](tests/laboratory_polish_analysis.png) · [Processing](tests/laboratory_polish_processing.png) · [Robotics](tests/laboratory_polish_robotics.png) · [Containment](tests/laboratory_polish_containment.png) · [Narrow](tests/laboratory_polish_narrow.png) · [Jobs](tests/laboratory_jobs_polish_450x800.png).

Windows/Android DEV and persistent packages: **0.9.49 / Android code 66**.
Source DEV reset remains enabled.
