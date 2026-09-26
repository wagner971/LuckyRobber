# Strength handling / early alarm pressure — 0.9.75, revizuit în Loadout Continuity

Pickup noise = weight base × Strength handling × Noise Control × handling gap.

## Curba curentă (Strength 1–27)

| STR | Handling multiplier |
| --- | --- |
| 0 (Weak Thief) | 2.40 |
| 1 | 1.20 |
| 2 | 1.10 |
| 3 … 26 | 1.10 − 0.01 × (STR − 2), adică 1.09 … 0.86 |
| 27 | 0.85 (podea) |

`Balance.strength_noise_multiplier(level)`; podeaua `STRENGTH_NOISE_FLOOR = 0.85`
garantează că un haul complet la Strength MAX + Noise MAX depășește în continuare
pragul alarmei în toate cele 13 locații.

## Handling gap (nou)

`Balance.handling_gap(location, strength) = 1 + 0.30 × max(0, top_strength(location) − strength)`,
unde `top_strength` este cel mai mare `required_strength` din inventarul locației.
Un hoț sub cerința de vârf a locației mânuiește neîndemânatic ceea ce poate ridica:
+30% zgomot per nivel lipsă. Astfel, cu Strength-ul cu care ajungi obligatoriu într-o
locație (două niveluri sub obiectul-semnătură) haul-ul scurt accesibil tot aleargă
contra alarmei, iar presiunea scade exact pe măsură ce cumperi Strength. Verificat
numeric pentru toate cele 13 locații: la sosire haul-ul accesibil depășește pragul
(ex. Prehistoric 75,1 vs 65,7), iar la MAX haul-ul complet îl depășește (69,5).

Noise Control păstrează multiplicatorul independent 100–81%. Strength se aplică
mânuirii obiectelor, nu detecției gardienilor și nici penalizărilor fixe Lucky.
Silent Heist/Double Noise se aplică după acest calcul; +35 Cursed rămâne fix.
Tutorialul nu generează zgomot la pickup.

Shop-ul afișează reducerea relativă a următorului nivel (`strength_noise_reduction`)
alături de loot-ul deblocat (`GameUI.strength_featured`: cele mai valoroase 3 obiecte
cu acel `required_strength`).

## Istoric (0.9.75, scară 1–5)

Vechea curbă era 2.00 / 1.10 / 1.04 / 1.00 / 0.96. Rutele fizice măsurate atunci
(starter route STR 1: alarmă după al patrulea obiect; STR 2: fără alarmă, 45,40 s)
rămân în `tests/test_strength_noise.gd` cu așteptările recalibrate pe curba nouă.
Legacy challenge_v2 conține aserțiuni pre-Speed-V2 și nu este gate de release.
