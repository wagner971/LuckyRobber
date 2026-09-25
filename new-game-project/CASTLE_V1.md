# DRACULA'S CASTLE V1 — Chapter 2, după Pyramid

Aceeași logică backward ca Pyramid: loot → cargo → Noise → obiectul care declanșează alarma → traseul final → măsurare → decor.

## Buget

| Obiect | Cargo | STR | Greutate | Noise | Valoare | Pickup |
|---|---|---|---|---|---|---|
| Crown Display | 1 | 1 | LIGHT | 4 | $700 | 0,8 s |
| Blood Chalice | 1 | 1 | LIGHT | 4 | $400 | 0,5 s |
| Vampire Portrait | 2 | 1 | LIGHT | 4 | $600 | 0,6 s |
| Skull Candelabrum | 2 | 1 | LIGHT | 4 | $500 | 0,6 s |
| Relic Chest | 3 | 2 | MEDIUM | 7 | $850 | 1,0 s |
| Bat Idol | 3 | 2 | MEDIUM | 7 | $650 | 1,0 s |
| Gargoyle Statue | 5 | 3 | MEDIUM | 7 | $900 | 1,2 s |
| Gothic Mirror | 6 | 4 | HEAVY | 12 | $1.200 | 2,0 s |
| Pipe Organ | 6 | 4 | HEAVY | 12 | $1.400 | 2,0 s |
| Vampire Throne | 7 | 5 | VERY HEAVY | 18 | $1.700 | 2,5 s |
| Dracula Coffin | 8 | 5 | VERY HEAVY | 18 | $2.000 | 2,0 s |
| **Total** | **44** | | | **97** | **$10.900** | |

- Pragul de alarmă: 97 × 65% = **63,05**. Fără Throne și Coffin rămân **61 Noise**.
- Noise MAX: 61 × 0,81 = 49,41, apoi +14,58 la Throne = 63,99. Alarma pornește și la MAX, dar la limită.
- 60 s, alarmă 12 s, fără override-uri. Se deblochează cu 2 obiective Pyramid.
- Obiective: ESCAPE WITH $4000 · STEAL THRONE + COFFIN IN ONE RUN · STEAL EVERYTHING. Obiectivul 2 folosește câmpul nou `signature_items`: ambele obiecte trebuie să ajungă în dubă în aceeași rundă.
- Pickup-ul Coffin e 2,0 s, ca sprintul de după alarmă să rămână în ținta de 4–6 s cu Coffin-ul mutat spre centrul Crypt-ului.

## Layout (production brief)

```
                  THRONE CHAMBER (roșu regal, 80%)
       PORTRAIT        THRONE pe 3 trepte        ORGAN
   ──────────────┐    CROWN pe piedestal    ┌──────────────
   TREASURY      │                          │  CRYPT
   (auriu, 85%)  │   GREAT HALL (70%)       │  (mov rece, 60%)
   chalice  idol │   covor roșu continuu,   │  candelabru  MIRROR
   gargoyle chest│   2 armuri decor         │     COFFIN (centru-jos)
   ──────────────┴───────── BREACH ─────────┴──────────────
                      VAN (cu spatele în breșă)
```

- **O cameră = 1 erou + 2–3 obiecte de suport.** Throne Chamber: tron, cu orga și portretul ca suport. Crypt: coșciug, cu oglinda și candelabrul. Treasury: grilă 2×2, cu obiectele mici sus și cele mari jos. Great Hall: axa, cu coroana pe piedestal sub intrarea în Throne Chamber.
- **Mărimi:** foarte mari sunt Coffin (×1,4) și Throne (×1,5). Mari: Organ (×1,35) și Mirror (×1,3). Medii: Gargoyle, Relic Chest, Portrait, Bat Idol. Mici: Crown, Chalice, Candelabrum.
- **Decor only:** torțe, stindarde, gargui pe creasta zidului și pe turnulețele porții, turnuri, dărâmături, armuri, fereastră gotică, crucea de piatră fixată pe peretele Crypt-ului, nișe. Niciun gargui decorativ nu stă pe podea.
- Throne Chamber e mai puțin adâncă, ca tronul să stea pe axă, aproape de peretele de sus. Cele 4 obiecte erou au o lumină discretă care se mișcă odată cu ele.
- Pereți gri-albăstrui reci. Podele: piatră caldă cu roșu (Hall, Throne), bej auriu (Treasury), mov-albastru rece (Crypt). Exterior navy, noapte.
- **Lighting Pass V1** (doar vizual; loot-ul, coliziunile și rutele sunt neschimbate):
  - **Mediu:** ambient albastru-gri `#29344A`, cu energie 2,4. Există o singură lumină de lună globală, rece (`#B4C2E0`, energie 0,55), care acum intră și în interior și dă formă zidurilor, turnurilor, podelei și dubei. Umbrele ies albăstrui, nu negre. Afară se adaugă o umplere rece și largă peste curtea dubei.
  - **Torțe:** toate cele 18 au flacără conică, în formă de limbă (nu sferă), cu halou mic și discret. Doar 10 emit lumină reală: chihlimbar `#FFB866`–`#FFD095`, rază 2,6–3,0, energie 0,8–1,2 (aplicele din hol 1,6), atenuare mare. Pâlpâirea e lentă, desincronizată, de aproximativ ±6%.
  - **Umplere pe camere:** câte o lumină largă, slabă și fără umbre: neutră în Hall, chihlimbar-burgundy desaturat în Throne, auriu moale în Treasury, albastru-violet desaturat în Crypt. În Crypt, o flacără caldă lângă Coffin face contrast cald-rece.
  - **Obiecte erou:** Throne, Coffin, Organ și Mirror au un accent mic, alb-cald, care se mișcă odată cu ele, plus un rim cald mai puternic decât la props.
  - **Materiale:** negrurile sunt nuanțate (mov, maro, albastru), nu negru pur. Catifeaua tronului e crimson, separată de covorul burgundy și de treapta de sus, burgundy închis. Crypt-ul are piatră albastru-gri. Oglinda are ramă argintie și sticlă albastru-violet stinsă. Aurul e controlat, iar podelele sunt mai deschise decât zidurile.
  - **Umbre de contact:** 7 umbre ieftine sub loot-ul mare, care dispar când obiectul e ridicat, plus una sub dubă. Nu au coliziune.
  - **Buget pentru mobil:** 1 lumină direcțională cu umbră, 0 lumini locale cu umbră, fără bloom, SSAO sau ceață.
  - Capturi: `tests/castle_lighting_before*.png` / `tests/castle_lighting_after*.png` (plan întreg, alarmă, Throne, Treasury, Crypt, exterior).

## Măsurători (harness fizic, `tests/test_castle_v1.gd`)

| Configurație | Rută | Rămas după full clear |
|---|---|---|
| S5 · Grip 1 · Carry 1 · Van 19 · Noise 1 | inteligentă (61 Noise → Throne → Coffin) | **4,13 s** |
| aceeași | Coffin înaintea Throne | 2,78 s |
| aceeași | lacomă (Throne + Coffin primele) | alarmă cu 6/11 încărcate → **BUSTED** |
| Grip 8 · Carry 8 | inteligentă | 4,65 s |
| MAX | inteligentă | 5,05 s |

Alarma pornește pe Throne, cu 9/11 obiecte încărcate. Pentru un jucător real pe telefon, ținta de 1–3 s trebuie confirmată prin playtest.

## Ce NU include V1

Fără contracte Mastery și fără trofeu nou. Modelele sunt procedurale, în stilul toon existent.

Captură: `tests/castle_v1.png`. Măsurători: `tests/castle_v1_measurements.json`.
