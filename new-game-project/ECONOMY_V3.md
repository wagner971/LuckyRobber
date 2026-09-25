# Economy V3 — loadout per nivel, ~20 run-uri per locație

Obiectiv: fiecare dintre cele 13 locații (Chapter 1 + Chapter 2, inclusiv Pirate Ship, Viking Hall, English Pub și Prehistoric Era) să dureze în medie ~20 de run-uri până se deschide următoarea, iar upgrade-urile să nu mai fie ziduri lungi de economisire. Valorile loot-ului, inventarele, obiectivele, timerele și regulile Noise/Alarm nu s-au schimbat.

## Problema măsurată înainte

Simulare cu un jucător care alege loot-ul optim și cumpără ce cere `NEXT GOAL`: Apartment 11 run-uri, House 1, Villa 5, Electronics 1, Mansion 6, Laboratory 1, Museum 9, apoi **fiecare nivel din Chapter 2 într-un singur run**. Venitul per run creștea de la ~$550 la $25.700, iar prețurile (bazate pe nivel, nu pe locație) rămâneau mici față de el; în Chapter 1, în schimb, Strength 5 la $13.800 cerea 6 run-uri de economisire pentru o singură achiziție.

## Regulile noi (`scripts/balance.gd`, `scripts/progression.gd`)

1. **Loadout per tier.** Fiecare locație are un plafon pentru fiecare dintre cele 5 stat-uri (`TIER_CAPS`). Următoarea locație se deschide numai când **toate cele cinci** ating plafonul tier-ului curent, plus cele două obiective (cash + obiect semnătură) și Final Job-urile existente (Apartment, Museum). `Progression.powerups_ready` verifică tot loadout-ul; `Balance.required_level(key, location)` este cerința.

| Locație | STR | Pickup | Carry | Van (cargo) | Noise | Achiziții în tier |
|---|---:|---:|---:|---:|---:|---:|
| Apartment | 2 | 2 | 2 | 6 (18) | 2 | 9 |
| Suburban House | 3 | 3 | 3 | 8 (22) | 3 | 6 |
| Villa | 4 | 4 | 4 | 10 (26) | 4 | 6 |
| Electronics Store | 4 | 5 | 5 | 12 (30) | 5 | 5 |
| Mansion | 5 | 6 | 6 | 14 (34) | 6 | 6 |
| Laboratory | 5 | 7 | 7 | 16 (38) | 7 | 5 |
| Museum | 5 | 8 | 8 | 20 (46) | 8 | 7 |
| Pyramid | 5 | 10 | 10 | 20 | 10 | 6 |
| Dracula's Castle | 5 | 12 | 12 | 20 | 12 | 6 |
| Pirate Ship | 5 | 14 | 14 | 20 | 14 | 6 |
| Viking Hall | 5 | 16 | 16 | 20 | 16 | 6 |
| English Pub | 5 | 18 | 18 | 20 | 18 | 6 |
| Prehistoric Era | 5 | 20 | 20 | 20 | 20 | 6 |

Cele 80 de achiziții sunt consumate exact pe parcursul celor 13 locații; la finalul Prehistoric totul este MAX.

2. **Preț pe tier, nu pe nivel.** `upgrade_cost = round50(UPGRADE_UNIT[stat] × TIER_PRICE[tier-ul în care nivelul devine cumpărabil])`. `TIER_PRICE = [850, 3600, 4500, 8500, 8500, 16500, 16500, 25000, 27000, 32000, 41000, 51000, 62000]`; ponderi: Strength 1,6 · Van 1,3 · Pickup 1,0 · Carry 1,0 · Noise 0,8. Prețul unui tier ≈ 16 haul-uri medii ale locației, împărțite pe 5–9 achiziții, deci o achiziție la 1–3 run-uri în loc de un zid de 5–7. Total campanie: **$1.725.300** (înainte: $224.700, din care Chapter 2 nu consuma aproape nimic).

3. **Carry Speed = viteză de mers + viteză cu obiect.** `walk_factor = 1 + 0,02 × (L−1)` (până la +38% la L20) se aplică și fără obiect; factorul de greutate rămâne `carry_factor` (recuperare 0,35/nivel). Shop-ul arată „WALK +x% · HEAVY LOOT +y%” și detaliile listează viteza de mers și pe fiecare clasă de greutate. Pickup Speed rămâne +12%/nivel.

4. **DEV · MAX ALL + UNLOCK ALL LEVELS** setează ambele Final Job-uri ca finalizate și deblochează toate cele 13 locații, inclusiv Chapter 2. Nu acordă bani sau obiective.

5. **Strength ↔ alarmă (neschimbat).** Verificat numeric: cu STR-ul cu care ajungi obligatoriu într-o locație (2 la House, 4 la Electronics, 5 de la Mansion), haul-ul complet accesibil depășește pragul alarmei în toate cele 13 locații, chiar și la Noise Control MAX (ex. Pub 72 vs prag 59,8; Prehistoric 79 vs 65,7). La STR 1 multiplicatorul 2,0 face ca 4 obiecte din Apartment să declanșeze alarma. Mecanica este corectă; nu a fost modificată.

## Pacing simulat cu tabelul real

Simulator offline (`knapsack` pe inventar, timp pe circuit calibrat pe rutele fizice măsurate, alarmă/fereastră, cumpărare a upgrade-ului cu cel mai bun câștig/$):

| Locație | Run-uri (jucător ~85% din optim) | Run-uri (optim) | Venit mediu/run |
|---|---:|---:|---:|
| Apartment | 19 | 14 | $560–780 |
| Suburban House | 16 | 14 | $1.700–1.900 |
| Villa | 16 | 13 | $2.000–2.400 |
| Electronics Store | 15 | 13 | $3.100–3.800 |
| Mansion | 19 | 16 | $3.200–3.700 |
| Laboratory | 17 | 14 | $5.600–6.600 |
| Museum | 17 | 15 | $7.600–9.000 |
| Pyramid | 16 | 14 | $8.900–10.500 |
| Dracula's Castle | 17 | 14 | $9.300–10.900 |
| Pirate Ship | 16 | 13 | $11.200–13.200 |
| Viking Hall | 16 | 14 | $14.500–17.000 |
| English Pub | 16 | 14 | $17.900–21.000 |
| Prehistoric Era | 16 | 14 | $21.800–25.700 |

Media: 16,6 (85%) / 14,0 (optim). Un jucător real, cu rute imperfecte și run-uri pierdute, ajunge la ~20. Rush Hour, Daily Gift, Lucky Blocks și laboratorul idle nu sunt incluse; toate scurtează ușor.

## UI

- Jobs: „LOADOUT TO CLEAR · TAP TO UPGRADE” cu cinci chip-uri (PICKUP, CARRY, VAN, NOISE, STR), fiecare deschide cardul din shop; obiectivul 3 spune „UPGRADE LOADOUT” până e complet.
- Shop: eticheta „NEED n” apare pe orice stat sub cerința tier-ului; mesajul de tier („UNLOCK … FOR LEVEL a–b”) folosește noile plafoane.
- Home/Results `NEXT TARGET`: MOVE FASTER / PICK UP FASTER / FIT MORE IN THE VAN / MAKE LESS NOISE / LIFT HEAVIER LOOT, în această ordine.

## Salvări

Schema rămâne 16; nivelurile existente peste plafon rămân active (grandfathered). Locațiile deja deblocate nu se re-blochează; doar avansarea mai departe cere loadout-ul complet.
