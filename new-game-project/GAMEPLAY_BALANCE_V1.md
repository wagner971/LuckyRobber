> **Actualizare V2 (0.3.0):** acest document păstrează specificația și măsurătorile istorice V1. Progresia de17 achiziții/$50.900, multiplicatorii Grip/Carry, capacitățile, schema3 și timpii de mai jos NU mai descriu versiunea curentă. Sunt înlocuite de [CHALLENGE_PROGRESSION_V2.md](CHALLENGE_PROGRESSION_V2.md): Noise+Alarm,80 achiziții/$224.700,5 categorii,tier caps globale și schema4. Catalogul, inventarele, obiectivele, trofeele, contractele și cosmeticele rămân valabile. Checkpointul V1 complet este în `../checkpoints/before-challenge-v2`.
# STEAL EVERYTHING — GAMEPLAY BALANCE V1

Stare: implementat în prototipul 0.2.0, Godot 4.7.1, 21 septembrie 2026. Valorile sunt un balans de lucru; fezabilitatea automată nu echivalează cu validarea prin playtest uman.

## Configurația și bucla

`scripts/balance.gd` este sursa centrală pentru loot, greutăți, formule, upgradeuri, cele șase inventare/poziții, obiective, contracte și cosmetice. `run_manager.gd` folosește o copie a upgradeurilor și regulilor modului la începutul rundei. `progression.gd` evaluează rezultatul; `save_store.gd` persistă progresul. Pereții/layouturile sunt în `level.gd`, modelele în `models.gd`.

NORMAL durează 60 s active, din prima intenție de mișcare. Înainte de start nu se colectează. Un obiect se ridică automat la oprire, este purtat vizibil și se încarcă la oprirea în zona dubei. Mișcarea anulează pickup/loading. DROP nu plătește, nu întoarce obiectul la spawn și are protecție de recolectare imediată. Un obiect blocat nu ascunde alte ținte eligibile; verificarea accesului folosește raycast și marginea obiectului.

Încărcarea, duba plină, un obiectiv și full clear nu declanșează plecarea. ESCAPE contextual confirmă succesul numai lângă dubă, fără obiect purtat și cu timp pozitiv; rezultatul/plata se fixează imediat și o singură dată. La timp <= 0 eșecul are prioritate. Eșecul pierde numai loot-ul rundei, nu portofelul/upgradeurile. Plecarea goală este permisă, fără bonus. Nu există taxe, energie sau cooldown.

## Mișcare și durate

- Viteză fără obiect: 5,0 unități/s; accelerație la țintă 0,175 s, oprire 0,10 s.
- Greutăți: LIGHT 0,95; MEDIUM 0,85; HEAVY 0,70; VERY_HEAVY 0,60.
- `carry_speed = min(5.0, 5.0 * weight_factor * carry_multiplier)`.
- `pickup_duration = max(0.25, base_pickup_duration * grip_multiplier)`.
- Încărcare: 0,30 s, independent de Grip.
- Strength afectează exclusiv eligibilitatea. Carry nu crește viteza fără obiect; UI afișează viteza efectivă pentru fiecare greutate, inclusiv plafonul.
- Deadzone joystick: 0,16; rază de interacțiune 0,62 de la margine. Mișcarea intenționată și oprirea fizică sunt verificate separat.

## Catalog

| type_id | $ | Cargo | STR | Pickup s | Greutate |
|---|---:|---:|---:|---:|---|
| chair | 50 | 1 | 1 | 0,5 | LIGHT |
| monitor | 70 | 1 | 1 | 0,5 | LIGHT |
| small_tv | 140 | 2 | 1 | 0,8 | MEDIUM |
| printer | 120 | 2 | 1 | 0,8 | MEDIUM |
| gaming_pc | 450 | 3 | 1 | 1,0 | MEDIUM |
| toilet | 220 | 3 | 2 | 1,1 | MEDIUM |
| fridge | 340 | 4 | 2 | 1,5 | HEAVY |
| small_safe | 500 | 4 | 3 | 2,5 | VERY_HEAVY |
| arcade_machine | 650 | 5 | 3 | 2,0 | HEAVY |
| vending_machine | 850 | 5 | 4 | 2,0 | HEAVY |
| piano | 1000 | 6 | 4 | 3,0 | VERY_HEAVY |
| large_statue | 1500 | 8 | 5 | 3,5 | VERY_HEAVY |
| pink_flamingo | 80 | 1 | 1 | 0,5 | LIGHT |
| golden_bust | 180 | 2 | 2 | 0,8 | MEDIUM |
| museum_artifact | 2500 | 8 | 5 | 3,5 | VERY_HEAVY |

Instanțele au ID/stare individuale. Trofeul are `trophy_id` separat; este marcat pe o instanță existentă, fără cargo suplimentar. Artefactul muzeului are model voluminos distinct.

## Upgradeuri

Nivelul 1 este gratuit. Cumpărarea verifică fonduri/MAX, se face între runde, salvează imediat și afectează următoarea rundă.

| Upgrade | Efectele nivelurilor | Costurile tranzițiilor în $ |
|---|---|---|
| Strength 1–5 | STR 1, 2, 3, 4, 5 | 250 / 750 / 3500 / 9000 |
| Grip 1–5 | 1 / 0,85 / 0,70 / 0,60 / 0,50 | 200 / 600 / 1500 / 4000 |
| Carry Speed 1–5 | 1 / 1,10 / 1,20 / 1,30 / 1,40 | 250 / 700 / 1800 / 4500 |
| Van Capacity 1–6 | 8 / 12 / 18 / 26 / 34 / 44 | 350 / 1000 / 2500 / 6000 / 14000 |

Total verificat: **17 achiziții, $50.900**. MAX nu are cost fictiv sau nivel suplimentar. Strength 2: toilet/fridge; 3: small_safe/arcade; 4: piano/vending; 5: statue/artifact.

## Locații, inventare, obiective

Ordinea este Apartment → Suburban House → Villa → Electronics Store → Mansion → Museum. Două obiective NORMAL din locația precedentă deblochează următoarea. Nu este obligatoriu full clear. Obiectivele sunt persistente și pot fi obținute în runde diferite; folosesc loot-ul, fără bonusuri.

| ID | Inventar | Obiecte | Cargo | $ total | Obiective 1 / 2 |
|---|---|---:|---:|---:|---|
| apartment | 2 chair, 2 small_tv, monitor, printer, toilet, fridge, pink_flamingo | 9 | 17 | 1210 | $300 / fridge |
| house | 2 small_tv, chair, monitor, printer, toilet, fridge, 2 small_safe, golden_bust | 10 | 25 | 2260 | $800 / minimum 1 small_safe |
| villa | piano, fridge, toilet, arcade_machine, small_safe, gaming_pc, 2 small_tv, monitor | 9 | 30 | 3510 | $1600 / piano |
| electronics | vending_machine, 2 arcade_machine, 3 gaming_pc, 3 small_tv, 2 monitor | 11 | 32 | 4060 | $2200 / vending_machine |
| mansion | large_statue, piano, 2 small_safe, fridge, 2 gaming_pc, small_tv, toilet, monitor | 10 | 38 | 5170 | $3000 / large_statue |
| museum | museum_artifact, 2 large_statue, piano, 2 small_safe, gaming_pc, toilet | 8 | 44 | 8170 | $4000 / museum_artifact |

Obiectivul 3: toate instanțele în dubă și evadare. Primul full clear NORMAL al fiecărei locații acordă $250 o singură dată; recordul poate fi îmbunătățit. Contractele nu completează cariera NORMAL și nu consumă bonusul/recordul ei.

Trofee, în ordine: flamingo, bust, pianul desemnat, automatul desemnat, statuia desemnată, artefactul. Se obțin numai după încărcare și evadare, în orice mod; repetițiile plătesc doar valoarea loot-ului.

## Cele 18 contracte

Se deblochează la CAMPAIGN CLEARED, independent de MAX. Folosesc aceeași scenă și aceeași buclă, cu reguli copiate pe rundă. Capacitatea efectivă este `min(capacitatea cumpărată, limita modului)`. SMALL VAN are 60 s. RUSH și CLIENT ORDER au 30 s în primele două locații, 35 s în celelalte.

| Locație | RUSH prag $ | SMALL VAN cargo / prag $ | CLIENT ORDER | Bonus unic per contract |
|---|---:|---|---|---:|
| Apartment | 800 | 8 / 600 | fridge + toilet + pink_flamingo | $500 |
| House | 1400 | 12 / 1200 | 2 small_safe + golden_bust | $500 |
| Villa | 2400 | 12 / 1600 | piano + arcade_machine + small_tv | $1000 |
| Electronics | 3000 | 12 / 1800 | vending_machine + 2 gaming_pc + arcade_machine | $1000 |
| Mansion | 3800 | 16 / 2400 | large_statue + piano + 2 small_safe | $1500 |
| Museum | 6000 | 16 / 4000 | museum_artifact + large_statue + piano + small_safe | $1500 |

Evadarea sub cerință încasează loot-ul fără medalie/bonus; nu este BUSTED. Timeoutul pierde loot-ul. Medaliile, bonusurile și recordurile sunt separate pe mod/locație. Bonusurile nu se repetă; rejucarea plătește loot normal. În NORMAL nu rămân limitele contractelor.

## După MAX și cosmetice

- CAMPAIGN CLEARED: două obiective Museum.
- ALL UPGRADES MAXED: toate cele patru categorii la maxim.
- MASTERY COMPLETE: 18 obiective NORMAL + 6 trofee + 18 contracte. Nu cere toate upgradeurile sau cosmeticele.

NEXT GOAL ține cont de Strength pentru obiectivul relevant, apoi de obiective/full clear, trofee, contracte și recorduri. După mastery recunoaște finalizarea versiunii și permite rejucarea. Fără prestige sau reset.

Cosmetice cumpărabile: două vopsele de dubă la $5000 fiecare, Plum Suit $10000, Midnight Set $20000, Sunrise Set $30000. Recompense exclusive: Collector Gold pentru 6 trofee; Silver Van pentru 6 contracte; Master Suit pentru 12; Legend Set pentru 18. Proprietatea și echiparea sunt salvate. Paletele se aplică efectiv modelelor la următoarea rundă; nu afectează statistici, economie, timer sau coliziuni.

## Salvare și migrare

Schema 3 în `user://progress.json`: wallet, cele patru upgradeuri, obiective pe ID stabil, locații deblocate, trofee, bonusuri full clear, contracte/bonusuri, recorduri pe mod, cosmetice owned/equipped, statistici. Fișier temporar, flush, backup și rename; fallback la `.bak` pentru JSON deteriorat, originalul păstrat `.corrupt`. Schemele necunoscute sunt păstrate și nu sunt suprascrise.

Schema 2 a acestui proiect este migrată cu copie `.schema2.bak`, păstrând banii, nivelurile compatibile, obiectivele, bonusurile, recordurile, trofeele și statisticile valide. Nu se taxează retroactiv diferența de preț și nu se interpretează un inventar/sac ca upgrade de dubă. Checkpoint anterior modificărilor: `../checkpoints/before-balance-v1`.

Testele folosesc profile separate. Opțiunea desktop `-- --test-profile` folosește `balance_v1_test_profile.json`, separat de progresul principal; la prima utilizare pornește de la $0 și își păstrează apoi propriul progres.

## Rezultate măsurate

**404 verificări automate, 0 eșecuri**: 77 în `balance_core_final.log`, 319 în `balance_v1_final.log`, 8 în `ui_v1_final.log`. Include configurațiile, formulele, cele 17 cumpărări, bani/MAX, selecție/anulare/drop/pereți/cargo/timeout/plată unică, trofee/obiective/endgame/cosmetice, migrare/corupție/reîncărcare, pauză/background, input emulat, 10 runde cu cleanup și semnale UI reale. Importul final trece pe Godot 4.7.1.

Timpii de mai jos includ deplasare fizică CharacterBody3D, coliziuni, oprire, pickup și loading. Pilotul folosește intrări de mișcare și rute prin spațiu accesibil, fără teleportare între obiecte. Timpul motorului este accelerat pentru QA menținând pasul fizic echivalent 1/60 s. Sunt rute automate valide, nu timpi umani, FPS sau retenție. Configurație MAX pentru tabel:

| Locație | NORMAL full clear s | Rezervă s | RUSH s / loot $ | SMALL VAN s / loot $ | CLIENT ORDER s / loot $ |
|---|---:|---:|---|---|---|
| Apartment | 38,70 | 21,30 | 16,03 / 840 | 10,43 / 620 | 14,83 / 640 |
| House | 48,15 | 11,85 | 21,37 / 1480 | 17,47 / 1220 | 17,75 / 1180 |
| Villa | 42,37 | 17,63 | 22,27 / 2440 | 11,90 / 1650 | 14,27 / 1790 |
| Electronics | 50,32 | 9,68 | 28,27 / 3050 | 18,92 / 1820 | 21,67 / 2400 |
| Mansion | 50,93 | 9,07 | 29,87 / 3900 | 14,13 / 2500 | 26,57 / 3500 |
| Museum | 46,90 | 13,10 | 26,48 / 6000 | 13,15 / 4000 | 25,42 / 5500 |

Toate cele 6 full clear-uri și 18 contracte s-au încheiat prin ESCAPE în termen. SMALL VAN a respectat limita efectivă. Datele complete, compoziția încărcăturii și fiecare circuit: `tests/balance_measurements.json`.

Prima rundă de $400 (2 small_tv + monitor + chair) a durat 16,38 s, cargo 6. Strength 2 costă $250 și lasă $150. A doua rută (fridge + small_tv + monitor + pink_flamingo) a produs $630 în 18,82 s, cargo 8. Portofel $780; Capacity 2 costă $350 și lasă $430. Ruta eficientă inițială de $550 a fost verificată în 22,67 s, cargo 8.

O campanie continuă, de la date implicite și exclusiv cu bani câștigați, a ajuns la Museum/CAMPAIGN CLEARED în **11 runde**: $400, $630, $950, $1340, $2080, $2080, $2600, $2600, $2540, $3020, $4000. La final: Strength 5, Capacity 3, Grip 1, Carry 1, portofel $7390; contractele deblocate fără MAX și fără full clear obligatoriu. Strength 3/4/5 și Capacity 3 au fost cumpărate cu economiile reale. Este o politică eficientă automatizată, nu durata tipică a campaniei.

Pentru ultimul upgrade de $14000, patru runde de câte $4000 ar fi suficiente de la $0, fără bonusuri; aceasta este o proiecție aritmetică pe ruta Museum verificată, nu un test separat al celor patru rejucări. Testul de cumpărare integrală a celor 17 upgradeuri folosește un profil QA finanțat și verifică costul total, nu pretinde o campanie umană până la MAX.

Randare desktop Compatibility inspectată la 450×800 și 450×1000: meniuri, cele șase locații, magazin, contracte/HUD, artefact transportat, rezultate, cosmetice aplicate, trofee și mastery. Capturile `tests/v1_*.png` folosesc stări QA de prezentare și nu sunt dovada măsurătorilor fizice.

## Abateri și limite

**Nicio modificare a prețurilor, valorilor, inventarelor, pragurilor sau termenelor din specificație.** Modelele/layouturile noi sunt greybox-uri funcționale care refolosesc stilul existent.

Țintele orientative de ritm nu sunt toate atinse: cel mai apropiat TV inițial are circuit 2,72 s (sub 4–7), frigiderul cu Strength 2 are 5,82 s (sub 7–10); pianul fără Grip/Carry durează 9,12 s, statuia 9,77 s, artefactul 9,72 s (sub ținta 12–14 pentru cele mai riscante obiecte). La MAX, patru locații lasă mai mult de 10 s. Cauza: spații compacte, acces direct și pilot eficient; Apartment trebuie să devină ușor. Nu s-au adăugat așteptări sau coridoare lungi și nu s-a încetinit mișcarea. Villa a produs $2600 după Strength 4, peste intervalul orientativ, care nu este plafon.

Rămân necesare playtest uman și decizii ulterioare de poziționare pe baza lui. Nu au fost testate Android pe telefon/emulator, touch hardware real, safe areas/notch fizice, FPS mobil, retenție sau dificultatea pentru utilizatori noi. Exportul APK nu reprezintă test pe dispozitiv. Sunetele și modelele sunt placeholder-uri originale. Nu există oraș, condus, AI/combat, multiplayer, etaje, procedural, monetizare sau progresie infinită.

## Livrabile verificate

Export Windows release și Android debug 0.2.0: cod de ieșire 0, jurnale `tests/export_windows_v1.log` și `tests/export_android_v1.log`. Executabilul Windows exportat a pornit atât headless, cât și cu randare Compatibility, cod de ieșire 0, fără erori, folosind profilul separat (`tests/packaged_v1_headless.log`, `tests/packaged_v1_render.log`). Cele 77 verificări de bază, cele 8 verificări UI și 11 verificări de settlement deja incluse în suita V1 au fost rerulate după ultimele ajustări; toate au trecut. Nu sunt adăugate încă o dată la totalul de 404.

APK-ul a fost aliniat, semnat și verificat de exportator. Manifest inspectat: `com.stealeverything.prototype`, versionCode 2 / versionName 0.2.0, ARM64, min SDK 24, target SDK 36, fără permisiune Internet. Avertismente rămase: Java native access în semnare și referința opțională `themed_icon.xml` absentă în template, semnalată de aapt2. Nu au împiedicat exportul; iconul tematic și rularea pe Android necesită verificare pe dispozitiv.

