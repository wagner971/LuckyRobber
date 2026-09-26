# Economy V3 — loadout per nivel, ~20 run-uri per locație

Obiectiv: fiecare dintre cele 13 locații (Chapter 1 + Chapter 2, inclusiv Pirate Ship, Viking Hall, English Pub și Prehistoric Era) să dureze în medie ~20 de run-uri până se deschide următoarea, iar upgrade-urile să nu mai fie ziduri lungi de economisire. Valorile loot-ului, inventarele, obiectivele, timerele și regulile Noise/Alarm nu s-au schimbat.

## Problema măsurată înainte

Simulare cu un jucător care alege loot-ul optim și cumpără ce cere `NEXT GOAL`: Apartment 11 run-uri, House 1, Villa 5, Electronics 1, Mansion 6, Laboratory 1, Museum 9, apoi **fiecare nivel din Chapter 2 într-un singur run**. Venitul per run creștea de la ~$550 la $25.700, iar prețurile (bazate pe nivel, nu pe locație) rămâneau mici față de el; în Chapter 1, în schimb, Strength 5 la $13.800 cerea 6 run-uri de economisire pentru o singură achiziție.

## Regulile noi (`scripts/balance.gd`, `scripts/progression.gd`)

1. **Loadout per tier.** Fiecare locație are un plafon pentru fiecare dintre cele 5 stat-uri (`TIER_CAPS`). Următoarea locație se deschide numai când **toate cele cinci** ating plafonul tier-ului curent, plus cele două obiective (cash + obiect semnătură) și Final Job-urile existente (Apartment, Museum). `Progression.powerups_ready` verifică tot loadout-ul; `Balance.required_level(key, location)` este cerința.

| Locație | STR | Pickup | Carry | Van (cargo) | Noise | Achiziții în tier | Cost tier |
|---|---:|---:|---:|---:|---:|---:|---:|
| Apartment | 3 | 2 | 2 | 4 (17) | 2 | 8 | $8.850 |
| Suburban House | 5 | 3 | 3 | 6 (23) | 3 | 7 | $18.850 |
| Villa | 7 | 4 | 4 | 8 (29) | 4 | 7 | $25.800 |
| Electronics Store | 9 | 5 | 5 | 9 (32) | 5 | 6 | $30.600 |
| Mansion | 11 | 6 | 6 | 11 (38) | 6 | 7 | $45.200 |
| Laboratory | 13 | 7 | 7 | 12 (41) | 7 | 6 | $63.900 |
| Museum | 15 | 8 | 8 | 14 (47) | 8 | 7 | $83.900 |
| Pyramid | 17 | 10 | 10 | 15 (50) | 10 | 9 | $103.550 |
| Dracula's Castle | 19 | 12 | 12 | 16 (53) | 12 | 9 | $106.050 |
| Pirate Ship | 21 | 14 | 14 | 17 (56) | 14 | 9 | $116.150 |
| Viking Hall | 23 | 16 | 16 | 18 (59) | 16 | 9 | $156.550 |
| English Pub | 25 | 18 | 18 | 19 (62) | 18 | 9 | $202.000 |
| Prehistoric Era | 27 | 20 | 20 | 20 (65) | 20 | 9 | $237.350 |

Cele 102 achiziții (Strength 26, celelalte 19 fiecare) sunt consumate exact pe parcursul celor 13 locații; la finalul Prehistoric totul este MAX.

**Continuitate Strength și Van (Loadout Continuity).** Strength merge acum de la 1 la **27**: fiecare locație cere exact **două** niveluri noi, pentru două obiecte diferite — unul „mic” la primul nivel al tier-ului și obiectul-semnătură la al doilea (Apartment: Toilet 2 / Fridge 3; House: Tool Cabinet 4 / Sofa 5; Villa: Small Safe 6 / Piano 7; Electronics: Arcade 8 / Vending 9; Mansion: Grand Piano 10 / Large Statue 11; Laboratory: Cryo 12 / Core 13; Museum: Time Machine 14 / Artifact 15; Pyramid: Throne 16 / Sarcophagus 17; Castle: Throne 18 / Coffin 19; Pirate: Figurehead 20 / Chest 21; Vikings: Runestone 22 / Throne 23; Pub: Clock 24 / Billiards 25; Prehistoric: Saber 26 / Skull 27). Obiectele mai ieftine ale fiecărei locații stau la nivelurile tier-urilor anterioare, deci ajungi cu Strength-ul de sosire și poți fura o parte din inventar, dar nu semnătura. Vanul crește **3 cargo/nivel** (`van_capacity = 8 + 3 × (L − 1)`, 65 la L20) și fiecare locație cere exact nivelul care încape inventarul ei complet (Chapter 2: 50 → 53 → 56 → 59 → 62 → 65 cargo, cu `expected_cargo` și `cargo_space` ajustate pe obiecte). Strength la MAX este permis doar prin DEV, Lucky „strength” (temporar) și upgrade-uri; `Balance.STRENGTH_MAX = 27`.

2. **Preț pe tier, nu pe nivel.** `upgrade_cost = round50(UPGRADE_UNIT[stat] × TIER_PRICE[tier-ul în care nivelul devine cumpărabil])`. `TIER_PRICE = [900, 2200, 3000, 4200, 5250, 8750, 9750, 10250, 10500, 11500, 15500, 20000, 23500]`; ponderi: Strength 1,6 · Van 1,3 · Pickup 1,0 · Carry 1,0 · Noise 0,8. Prețul unui tier ≈ 16 haul-uri medii ale locației, împărțite pe 6–9 achiziții, deci o achiziție la 1–3 run-uri în loc de un zid de 5–7. Total campanie: **$1.198.750** (Strength $400.900, Pickup/Carry $216.550 fiecare, Van $191.550, Noise $173.200).

3. **Carry Speed = viteză de mers + viteză cu obiect.** `walk_factor = 1 + 0,02 × (L−1)` (până la +38% la L20) se aplică și fără obiect; factorul de greutate rămâne `carry_factor` (recuperare 0,35/nivel). Shop-ul arată „WALK +x% · HEAVY LOOT +y%” și detaliile listează viteza de mers și pe fiecare clasă de greutate. Pickup Speed rămâne +12%/nivel.

4. **DEV · MAX ALL + UNLOCK ALL LEVELS** setează ambele Final Job-uri ca finalizate și deblochează toate cele 13 locații, inclusiv Chapter 2. Nu acordă bani sau obiective.

5. **Strength ↔ alarmă.** Curba de mânuire merge acum până la 27 (1,20 la STR 1, 1,10 la STR 2, apoi −0,01/nivel până la podeaua 0,85), iar un hoț sub cerința de vârf a locației primește `handling_gap` = +30% zgomot per nivel lipsă. Verificat numeric: cu STR-ul de sosire (două niveluri sub semnătură) haul-ul accesibil depășește pragul alarmei în toate cele 13 locații (ex. Prehistoric 75,1 vs 65,7), iar la Strength + Noise MAX haul-ul complet îl depășește în continuare (69,5). Detalii în `STRENGTH_NOISE_V1.md`.

## Pacing simulat cu tabelul real

Simulator offline (`knapsack` pe inventar, timp pe circuit calibrat pe rutele fizice măsurate, alarmă/fereastră, cumpărare a upgrade-ului cu cel mai bun câștig/$):

| Locație | Run-uri (jucător ~85% din optim) | Run-uri (optim) | Venit mediu/run |
|---|---:|---:|---:|
| Apartment | 16 | 15 | $470–1.030 |
| Suburban House | 17 | 13 | $1.110–1.820 |
| Villa | 15 | 13 | $1.500–2.770 |
| Electronics Store | 15 | 13 | $1.620–3.450 |
| Mansion | 15 | 14 | $2.270–4.560 |
| Laboratory | 17 | 13 | $3.700–6.160 |
| Museum | 17 | 15 | $4.420–8.250 |
| Pyramid | 16 | 14 | $5.950–8.930 |
| Dracula's Castle | 16 | 11 | $6.120–9.270 |
| Pirate Ship | 16 | 10 | $6.800–11.220 |
| Viking Hall | 17 | 15 | $8.670–14.450 |
| English Pub | 17 | 12 | $11.220–17.850 |
| Prehistoric Era | 16 | 10 | $13.770–21.850 |

Media: 16,2 (85%) / 12,9 (optim). Venitul pornește mai jos în fiecare locație decât înainte, pentru că la sosire lipsesc două niveluri de Strength (obiectul-semnătură nu poate fi ridicat) și vanul nu încape tot inventarul; crește pe măsură ce loadout-ul se completează. Un jucător real, cu rute imperfecte și run-uri pierdute, ajunge la ~20. Rush Hour, Daily Gift, Lucky Blocks și laboratorul idle nu sunt incluse; toate scurtează ușor.

## UI

- Jobs: „LOADOUT TO CLEAR · TAP TO UPGRADE” cu cinci chip-uri (PICKUP, CARRY, VAN, NOISE, STR), fiecare deschide cardul din shop; obiectivul 3 spune „UPGRADE LOADOUT” până e complet.
- Shop: eticheta „NEED n” apare pe orice stat sub cerința tier-ului; mesajul de tier („UNLOCK … FOR LEVEL a–b”) folosește noile plafoane.
- Home/Results `NEXT TARGET`: MOVE FASTER / PICK UP FASTER / FIT MORE IN THE VAN / MAKE LESS NOISE / LIFT HEAVIER LOOT, în această ordine.

## Salvări

Schema rămâne 16; nivelurile existente peste plafon rămân active (grandfathered). Locațiile deja deblocate nu se re-blochează; doar avansarea mai departe cere loadout-ul complet.
