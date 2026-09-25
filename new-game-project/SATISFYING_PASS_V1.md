# STEAL EVERYTHING — Satisfying Pass V1

Build **0.8.0**, Godot 4.7.1, 21 septembrie 2026. Checkpoint înainte de modificări: `../checkpoints/before-satisfying-v1`. Proiectul păstra deja animațiile blocky IDLE/RUN/CARRY/HEAVY/PICKUP/LOAD, panic cadence, onboardingul, Noise/Alarm, camera ortografică și cash-ul 3D cu burst, magnet, pooling și economie separată. Aceste sisteme nu au fost reconstruite. `thief_visual.gd` a rămas neschimbat; doar obiectul primește un mic pop vizual la pickup.

## Audio

**PLACEHOLDER SFX — REPLACE BEFORE FINAL RELEASE.** Nu existau fișiere WAV/OGG utilizabile în proiect; `tools/generate_sfx.py` produce 27 WAV mono locale, 22,05 kHz, cu noise filtrat, transient, thump și strat tonal discret. `SoundBank` le încarcă prin sistemul audio Godot. Fiecare variantă poate fi înlocuită individual cu același nume. Pitch-ul repetitiv variază controlat între 0,94 și 1,06. Maximum trei voci coexistă; o voce veche cedează locul uneia noi. Fișierele au peak maxim măsurat 0,464 înainte de atenuarea pe categorii.

| Eveniment | Cue-uri locale | Mix relativ |
|---|---|---:|
| Pickup light / heavy | câte 3 variații | −15 / −12 dB |
| Van impact light / medium / heavy / very heavy | câte 2 variații | −13 / −10 / −6 / −4 dB |
| Cash burst / colectare | 1 fiecare, o dată per load/burst | −11 / −10 dB |
| Noise tick / warning | 1 fiecare | −18 / −11 dB |
| Alarm trigger / ultimele 5 secunde | 1 fiecare | −5 / −16 dB |
| Escape / Busted | 1 fiecare | −6 / −8 dB |
| Upgrade / Strength unlock / Special reveal | 1 fiecare | −10 / −7 / −9 dB |

Load-ul folosește un stack scurt: cash burst la validarea load-ului, impactul corespunzător greutății când obiectul atinge duba, colectare cash o singură dată după magnet. Nu există sunet per bancnotă. Settings salvează SOUND ON/OFF și SFX VOLUME 0–100% în fișierul de preferințe separat de progres.

## Haptics și cameră

`HapticManager` este singurul loc care cheamă API-ul de vibrație; pe desktop nu face nimic. Default ON pe mobil, OFF disponibil în Settings și păstrat între lansări. Pattern-uri: pickup 18/28 ms; load light/medium/heavy/very heavy 25/34/42/52 ms; alarmă 55 ms; upgrade 38 ms; Strength 44 ms + 18 ms; escape 30 ms + 18 ms; busted 40 ms. Nicio vibrație per dolar, cash piece sau pas. Callback-ul secundar verifică din nou setarea ON înainte de a vibra.

`CameraJuice` păstrează poziția și mărimea de bază a camerei ortografice. Impulsurile au maximum 0,06 unități și zoom sub 1,5%, fără schimbarea poziției playerului sau a vitezei. Setarea CAMERA EFFECTS OFF restaurează imediat camera de bază. Intensitățile pentru load sunt 0,08 / 0,30 / 0,60 / 0,85 pentru LIGHT / MEDIUM / HEAVY / VERY_HEAVY, timp de 0,10 s; alarma are un singur impuls 0,72 / 0,16 s; succesul 0,38 / 0,22 s; busted 0,50 / 0,09 s. Nu există shake continuu.

## Load, pickup și rewards

`LootVan` păstrează arcul de 0,26 s și load-ul de 0,30 s din gameplay. Numai compresia/revenirea vizuală diferă: LIGHT 0,6×, MEDIUM 1,0×, HEAVY 1,45×, VERY_HEAVY 1,8×. WHAM este ascuns la LIGHT, THUNK la MEDIUM, WHAM la HEAVY, WHAM!! la VERY_HEAVY. `LootItem` face un pulse 1,035× la target și un pop 1,075× pentru pickup ușor / settle 1,035× pentru pickup greu. Coliziunea și modelul de mișcare nu se schimbă.

Cash-ul procedural, grosimea, rotația, burst-ul, magnetul și pool-ul sunt păstrate. Pragurile vizuale sunt 9 piese sub $150, 12 la $150–499, 16 la $500–1499 și 19 la cel puțin $1500. Schimbarea la $1500 privește numai intensitatea VFX; recompensa reală rămâne aceeași. `+$valoare` apare lângă dubă, iar VAN LOOT crește vizual fără a decide suma.

## HUD și progresie

Noise bar trece spre noua valoare în aproximativ 0,16 s și pulsează discret la increment. Warning are un singur accent și un sunet. Alarm afișează `ALARM! GET OUT!` timp de 0,8 s, apoi rămân doar `NOISE · ALARM`, timerul urgent și CTA `ESCAPE NOW · BANK $...` când playerul poate evada. Instrucțiunea contextuală duplicată se ascunde lângă dubă, dar rămâne `GET TO THE VAN` când playerul este departe. Ultimele cinci secunde au câte un mic pulse și tick; timpul real nu este modificat.

Success/busted se validează și se salvează imediat prin logica existentă. Un panou scurt, compact, arată `ESCAPED! / +$... BANKED` sau `BUSTED! / $... LOST`; pe eșec, o linie de VAN LOOT se golește vizual. Wallet-ul din rezultate face count-up aproximativ 0,48 s. Full clear poate adăuga numai `FULL CLEAR!`. Special Job disponibil are un badge scurt, fără modificarea schedulerului.

Purchase folosește în continuare `SaveStore.purchase()` o singură dată. După reconstrucția cardului, doar prezentarea animă butonul, wallet-ul, nivelul, progress bar și un flash mint în 0,3–0,4 s. Strength afișează timp de aproximativ 1 s numele reale ale loot-ului deblocat. Atingerea unui tier afișează `TIER MAX` discret; nu este tratată drept final de joc. Tween-urile sunt legate de controalele lor și dispar la schimbarea paginii.

## Performanță și verificare

Fără rig nou, fizică pe bancnote, blur, postprocesare sau particule suplimentare. Cash VFX rămâne limitat la 40 piese; audio la trei voci; UI folosește tween-uri scurte legate de controale. Capturi portret: `tests/satisfying_chair_50_impact.png`, `satisfying_fridge_340_impact.png`, `satisfying_safe_500_impact.png`, `satisfying_piano_1000_impact.png`, `satisfying_artifact_2500_impact.png`, `satisfying_noise_safe.png`, `satisfying_noise_warning.png`, `satisfying_alarm_trigger.png`, `satisfying_alarm_settled.png`, `satisfying_escape_150.png`, `_1000.png`, `_5200.png`, `satisfying_upgrade_grip.png`, `_van.png`, `_strength.png`, `satisfying_settings.png` (și cadre burst pentru cele cinci încărcări). Capturile escape folosesc sume sintetice pentru a inspecta prezentarea la trei valori; testul dedicat verifică separat încasarea reală și lipsa dublării.

Înainte de editări, toate cele 20 de scripturi `test_*.gd` existente au ieșit cu cod 0. După editări, toate cele 20 existente plus `test_satisfying_pass.gd` au ieșit cu cod 0: **21 suite, 2.207 verificări raportate, 0 eșecuri**. Două teste de integrare ies cu cod 0 fără a imprima un număr de verificări, deci nu sunt incluse în 2.207. Testul nou are 31 de verificări pentru camera, haptics OFF, SFX zero, variații, limită de voci, greutăți, cumpărare unică, cleanup la schimbarea paginii, alarmă simplificată, escape unic și busted. Logurile finale nu conțin erori Godot. Importul editor a trecut; exporturile Windows 0.8.0.0 și Android debug 0.8.0/code 16 au trecut. Buildul Windows pornește cu profil QA, iese cu cod 0 și lasă `progress.json` principal cu hash identic.

Playtestul uman și telefonul real rămân necesare: tactilitatea pickup-ului, diferența Chair/Piano, lizibilitatea cash magnet, oboseala produsă de alarmă/cameră/haptics și repetitivitatea audio după zece runde nu pot fi evaluate de testele automate. SFX-urile placeholder trebuie ascultate și înlocuite înainte de release.
