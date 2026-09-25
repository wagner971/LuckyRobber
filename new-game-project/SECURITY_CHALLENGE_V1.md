# Security Challenge V1

Version 0.9.54 / Android code 71, 24 September 2026.

Adds a mild, readable surveillance challenge to Electronics Store, Mansion, Laboratory and Museum. The existing floor plans and item placements are preserved; these are the larger campaign locations, not newly enlarged maps.

## Placement and pacing

| Location | Cameras | Guards | Normal / Final Job timer | Maximum security loss |
|---|---:|---:|---:|---:|
| Electronics Store | 1 | 1 | 65 s | 4 s |
| Mansion | 2 | 1 | 85 s | 6 s |
| Laboratory | 2 | 1 | 90 s | 6 s |
| Museum | 2 | 2 | 85 s | 6 s |

Cameras sweep slowly; guards walk 0.7 units/s on short, deliberate routes, pause at their endpoints and turn before returning. Guards have a distinct navy uniform and cap, animated limbs and a contact shadow. They do not physically block the thief or doorways.

Vision is directional: camera range 3.8, half-angle 27 degrees; guard range 2.8, half-angle 37 degrees. Floor cones are clipped using the same collision rays as detection. Walls and solid furniture interrupt sight. Loose loot does not act as a hiding obstacle. Patrol paths were checked against walls, fixed furniture and all loot footprints.

## Fairness rules

- One shared exposure meter fills over 1.8 seconds, even with overlapping sensors.
- Leaving sight drains it at 2.4 seconds of exposure per second outside sight.
- Full detection costs two seconds. It does not confiscate loot, raise noise, summon police or end the run immediately.
- Global nine-second cooldown prevents chained penalties; inactive cones become faint blue-grey.
- Three-second grace at the beginning. Entrance / van approach (z >= 1.8) stays safe, and displayed cones end at this boundary.
- Security penalties stop during a police countdown and in the last ten seconds.
- Short contracts and Special Jobs allow only one catch (two seconds total); their original timers stay unchanged.
- Ready, pause and finish do not advance surveillance; app background pause therefore freezes it too.

The four normal map timers gain five seconds for reaction / detours. `economy_duration` preserves their original duplication calibration, so extra surveillance time does not silently change any replica prices. Loot values, cargo, speed requirements, progression and alarm rules remain unchanged.

## Presentation and mobile cost

A short Ready hint introduces vision cones. Exposure appears above the thief; detection temporarily uses the existing compact instruction chip. No new fullscreen alert or centre banner. The four Jobs previews were recaptured with the actual new models.

No pathfinding, chase AI, navigation mesh, extra lights or fullscreen effect. Maximum four sensors, 16 triangles per cone, with cone clipping refreshed at 10 Hz. Detection uses simple range / angle checks before collision rays. Mobile hardware performance still needs a device playtest.

## Validation

426 checks passed across the security suite (49), core gameplay (87), HUD (75), tutorial (50), Museum routes/finale (11), Electronics routes (7), Mansion routes (6), Laboratory (16), duplication idle economy (38), Jobs (51), and UI safe areas (36).

Physical full-clear routes with required Pickup/Carry levels and the other upgrades at MAX:

| Location | Route time | New timer | Worst penalty budget |
|---|---:|---:|---:|
| Electronics | 55.02 s | 65 s | 4 s |
| Mansion | 75.23 s | 85 s | 6 s |
| Laboratory | 68.65 s | 90 s | 6 s |
| Museum | 61.02 s | 85 s | 6 s |

All four passed with live surveillance and again with the maximum penalty already deducted. These automated routes had no full detections; they demonstrate an avoidable challenge, not an unavoidable toll. Separate continuous-exposure tests exercise real camera detection, guard vision, penalties, cooldown, pause, overlap protection, walls, safe approach and final-seconds protection. Museum Final Job also passed at moderate Grip/Carry/Noise levels. Contract routes in the affected maps remained solvable.

Screenshots: `tests/security_electronics.png`, `security_mansion.png`, `security_laboratory.png`, `security_museum.png`, `security_suspicion.png`, `security_spotted.png`. Four refreshed images in `assets/ui/jobs/`.

Windows and Android DEV / Persistent exports updated. Packaged Windows startup and Android version / architecture are checked separately; no physical-phone test was performed in this pass.