> **Mod de dezvoltare activ — build 0.3.2:** fiecare pornire începe cu $0, toate abilitățile la L1 și progres nou. Progresul se păstrează doar în sesiunea curentă. Butonul **DEV · MAX ALL ABILITIES**, din meniul principal și upgradeuri, setează Strength5 / Grip20 / Carry20 / Van20 / Noise20, fără a modifica banii sau obiectivele. Salvarea veche rămâne intactă. Acest comportament înlocuiește încărcarea/persistența normală descrisă mai jos cât timp `development/enabled=true` în `project.godot`.
> **Versiunea curentă: V2.1 / build 0.3.1.** Secțiunea „V2.1 — balance patch” de la final conține regulile și măsurătorile actuale. Secțiunile V2 de mai jos sunt păstrate ca istoric: pragul de 80%, cargo Museum 44, Small Van Museum 16 și concluzia despre Van L20 redundant sunt înlocuite explicit în V2.1.
# STEAL EVERYTHING — CHALLENGE + PROGRESSION V2

Implementat în proiectul existent, versiune 0.3.0, Godot 4.7.1, 21 septembrie 2026. Documentul este sursa actuală pentru challenge, upgradeuri, migrare și măsurători. Catalogul de loot, cele șase inventare, obiectivele, trofeele, contractele și cosmeticele V1 sunt păstrate.

## Noise + Alarm

Fiecare instanță generează Noise numai la prima ridicare finalizată din rundă. Flag-ul `noise_generated_this_run` rămâne setat după DROP și reculegere; apropierea, începutul/anularea pickup-ului, încărcarea și DROP nu adaugă zgomot. O rundă nouă resetează flag-urile, zgomotul, avertizarea și alarma.

| Weight class | Base Noise |
|---|---:|
| LIGHT | 4 |
| MEDIUM | 7 |
| HEAVY | 12 |
| VERY_HEAVY | 18 |

`noise_multiplier = max(0.81, 1 - 0.01 * (noise_level - 1))`

`effective_noise = base_noise * noise_multiplier`

Calculul/acumularea sunt float, fără rotunjire per obiect. UI afișează două zecimale în mesajul scurt de creștere; logurile și testele păstrează precizia.

`base_location_noise = suma Base Noise a tuturor instanțelor din inventar`

`alarm_threshold = base_location_noise * 0.80`

Pragul este independent de upgradeuri, modul de joc și obiectele deja livrate. La aproximativ 75% din prag apare o avertizare discretă, o singură dată. La `current_noise >= threshold`, alarma pornește o singură dată și aplică `remaining_time = min(remaining_time, 12.0)`. Nu adaugă timp și nu înlocuiește termenul contractului. După alarmă sunt disponibile pickup, transport, load, DROP și ESCAPE. Noise continuă să crească fără retrigger. Pauza suspendă timpul; timeoutul păstrează prioritatea față de ESCAPE.

HUD-ul are bară compactă, text SAFE / ALARM CLOSE / ALARM GET OUT și culori distincte; nu depinde numai de culoare. Creșterea de zgomot este afișată separat de bannerul scurt ALARM! GET OUT! (1,4 s). Există sunet distinct, timer de urgență, zona dubei pulsantă și ESCAPE NOW. Bannerul este sub zona hărții și nu acoperă bara de Noise. Fără overlay permanent, AI sau sistem de chase.

## Cele 80 de upgradeuri

Cinci categorii, nivelul 1 gratuit. Nu există alte statistici permanente sau niveluri după MAX.

| Stat | Niveluri | Achiziții | Efect | Cost total |
|---|---:|---:|---|---:|
| Strength | 1–5 | 4 | eligibilitate discretă STR | $23.000 |
| Grip | 1–20 | 19 | `pickup_speed = 1 + 0.03*(L-1)` | $42.450 |
| Carry | 1–20 | 19 | `carry_multiplier = 1 + 0.015*(L-1)` | $46.050 |
| Van | 1–20 | 19 | `cargo = 8 + 2*(L-1)` | $63.600 |
| Noise | 1–20 | 19 | `noise_multiplier = 1 - 0.01*(L-1)` | $49.600 |
| **Total** | | **80** | | **$224.700** |

`pickup_time = max(0.25, base_pickup_time / pickup_speed)`

`carry_speed = min(5.0, 5.0 * weight_factor * carry_multiplier)`

Greutățile rămân 0,95 / 0,85 / 0,70 / 0,60. Mișcarea fără obiect rămâne 5,0 unități/s, accelerație 0,175 s, oprire 0,10 s. Loading rămâne 0,30 s. Strength nu modifică viteze sau zgomot; Grip, Carry și Noise au responsabilități separate. Efectele V2 cerute înlocuiesc multiplicatorii V1, fără penalizări suplimentare ascunse.

| Nivel | Grip speed | Carry multiplier | Van cargo | Noise generated |
|---:|---:|---:|---:|---:|
| 1 | 100% | 100% | 8 | 100% |
| 5 | 112% | 106% | 16 | 96% |
| 10 | 127% | 113,5% | 26 | 91% |
| 15 | 142% | 121% | 36 | 86% |
| 20 | 157% | 128,5% | 46 | 81% |

Strength: L2 deblochează toilet/fridge, L3 small_safe/arcade_machine, L4 piano/vending_machine, L5 large_statue/museum_artifact. Flamingo rămâne STR1, bust STR2, ca în catalogul existent. Costurile sunt $1000 / $2400 / $5800 / $13800.

Pentru celelalte patru categorii:

`upgrade_cost = floor((base_cost * pow(1.13, current_level - 1)) / 50.0 + 0.5) * 50`

Baze: Grip $600, Carry $650, Van $900, Noise $700. Exponentul folosește nivelul DIN CARE cumpăr. Cele 76 de prețuri sunt calculate; nu există o listă manuală. `Balance.COSTS` este doar o vedere derivată pentru compatibilitatea testelor, generată din aceeași funcție. Magazinul și tranzacția folosesc direct `upgrade_cost`.

Magazinul are cinci carduri, nivel/maxim, efect actual/următor, cost și BUY. La MAX afișează numai efectul actual și MAX, fără $0 sau nivel 21. Carry arată vitezele efective pe greutăți/plafon. Noise arată explicit procentul generat. Exemplul de text Grip L7 din cerere era inconsistent cu formula: afișăm **118% → 121%**, conform +3% per nivel, nu 130% → 133%.

## Tier caps globale

| Cea mai avansată locație deblocată | Grip / Carry / Van / Noise | Strength |
|---|---:|---:|
| Apartment | 4 | 2 |
| Suburban House | 7 | 3 |
| Villa | 10 | 4 |
| Electronics Store | 13 | 4 |
| Mansion | 16 | 5 |
| Museum | 20 | 5 |

Cap-ul depinde de locațiile deblocate, nu de locația rejucată. Blochează numai achizițiile viitoare, nu efectul nivelurilor deținute. Shop afișează CURRENT TIER MAX și locația necesară pentru intervalul următor. Tranzacția verifică și ea cap-ul, fondurile, MAX și faptul că jucătorul este între runde; un semnal direct nu ocolește limita.

Apartment rămâne 17 cargo, peste Van L4=14; după House poate fi cumpărat L7=20. House rămâne 25 cargo, peste L7; după Villa poate fi cumpărat L10=26. Celelalte inventare rămân 30/32/38/44. Două obiective din trei sunt suficiente pentru progres, fără full clear obligatoriu.

Modelul dubei folosește același interval vizual de dimensiuni ca V1, repartizat pe 20 de niveluri. Nu a fost lăsat să crească accidental de trei ori prin vechea formulă vizuală. Camera, coliziunile și layouturile sunt păstrate.

## Campanie, MAX și mastery

CAMPAIGN CLEARED rămâne două obiective Museum. ALL UPGRADES MAXED verifică acum 5/20/20/20/20. MASTERY COMPLETE rămâne 18 obiective NORMAL + 6 trofee + 18 contracte. Contractele se deblochează la Campaign, fără MAX. Cosmeticele nu sunt cerute pentru mastery. După Campaign se pot cumpăra în continuare upgradeuri; după MAX rămân full clear-uri, trofee, contracte, recorduri și cosmetice, fără prestige/perks/reset.

## Migrare și persistență

Schema nouă: **4**. Înainte de schema3 → schema4, salvarea sursă este copiată în `.schema3.bak`. Schema2 este încă acceptată și trece prin conversia vechiului format, apoi prin maparea V2, cu backup `.schema2.bak`.

Strength este păstrat în 1–5. Grip/Carry folosesc vechiul maxim5, Van vechiul maxim6:

`new_level = 1 + round(((old_level - 1) / (old_max - 1)) * 19)`

Noise începe la1. Wallet, locații, obiective, trofee, contracte/bonusuri, cosmetice, recorduri și statistici valide sunt păstrate. Nu se percep diferențe de preț. Recordurile istorice V1 rămân chiar dacă noul challenge face unele dintre ele mai greu de depășit.

**Grandfathered progression:** nivelurile migrate peste cap nu se reduc, rămân active și sunt explicate în shop; cumpărarea următorului nivel cere un cap global suficient. Reloadul unei salvări schema4 nu remapează din nou nivelurile.

Checkpoint complet înaintea update-ului: `../checkpoints/before-challenge-v2`, inclusiv salvarea reală și suita V1. Testul pe copia acestei salvări a păstrat **$9700**, obiectivele, cele patru locații deblocate, cele trei trofee și restul progresului, convertind **Strength4 / Grip4 / Carry3 / Van4 → Strength4 / Grip15 / Carry11 / Van12 / Noise1**. Grip15 depășește cap-ul Electronics13, deci rămâne activ și poate avansa după deblocarea Mansion.

La verificarea finală era încă deschisă o instanță V1 în editor. Nu am scris profilul principal în timp ce acea instanță îl putea suprascrie. Migrarea profilului principal se execută automat la pornirea V2 după închiderea jocului V1. Conversia și backupul au fost validate pe copia reală; această diferență dintre test și salvarea live este intenționată.

Scrierea temporară/flush/backup/rename și recuperarea din backup sunt păstrate. Schemele necunoscute nu se suprascriu. Profilul QA desktop folosește `user://challenge_v2_test_profile.json`, separat de `progress.json` și de profilul QA V1.

## Măsurători fizice: full clear la MAX

Pilot automat cu CharacterBody3D, coliziuni, oprire, pickup, transport și loading reale. Fără teleportare între obiectele rutelor. Timpul de execuție QA este accelerat, păstrând pasul de simulare echivalent 1/60 s. Testele unitare folosesc separat fixture-uri de poziție/stare; acestea nu sunt prezentate ca rute fizice. Nu sunt timpi de jucător uman sau măsurători FPS.

| Locație | Base Noise | Prag | Full clear s | Alarmă la s active | Timp rămas la ESCAPE | Noise final |
|---|---:|---:|---:|---:|---:|---:|
| Apartment | 56 | 44,80 | 39,87 | 37,77 | 9,90 | 45,36 |
| House | 91 | 72,80 | 50,25 | 47,62 | 9,37 | 73,71 |
| Villa | 92 | 73,60 | 44,72 | 43,67 | 10,95 | 74,52 |
| Electronics | 86 | 68,80 | 52,22 | 50,32 | 7,78 | 69,66 |
| Mansion | 116 | 92,80 | 54,12 | 53,03 | 5,88 | 93,96 |
| Museum | 122 | 97,60 | 50,60 | 48,78 | 9,40 | 98,82 |

Toate cele șase au reușit, cu plata/bonusul/recordul corecte. Ruta ia inventarul în ordinea instanțelor din configurație, folosind culoarele centrale și alegând un punct de apropiere accesibil în care obiectul dorit este cel mai apropiat eligibil. ID-urile exacte, tipurile și durata fiecărui circuit sunt în `tests/challenge_v2_measurements.json` (`route_instance_ids`, `types`, `circuits`).

Comparație pe aceleași trasee, toate celelalte staturi MAX, dar **Noise L1**: toate au reușit; timpul rămas a fost Apartment **5,48 s**, House **3,57 s**, Villa **0,77 s**, Electronics **1,55 s**, Mansion **0,17 s**, Museum **0,90 s**. Această comparație arată efectul alarmei și al upgradeului; nu garantează că un utilizator uman poate repeta traseele.

## Contracte revalidate

Toate cele **18** contracte au soluție fizică la MAX. Pragurile de loot, timpii, limitele cargo și comenzile au rămas exact cele din V1. Zgomotul se aplică prin același RunManager. Nicio rută de contract aleasă la MAX nu a atins pragul alarmei; testele unitare verifică separat tăierea timpului și continuarea jocului după alarmă în contract.

| Locație | RUSH timp s | SMALL VAN timp s | CLIENT ORDER timp s |
|---|---:|---:|---:|
| apartment | 16.73 | 10.97 | 15.4 |
| house | 22.82 | 18.62 | 18.82 |
| villa | 23.75 | 12.82 | 15.3 |
| electronics | 29.43 | 19.73 | 22.8 |
| mansion | 31.85 | 15.37 | 28.77 |
| museum | 28.82 | 14.38 | 27.67 |

Cel mai strâns RUSH dintre rutele testate este Mansion: 31,85 / 35 s, rezervă 3,15 s. Nu am identificat contracte imposibile. Fezabilitatea la MAX nu dovedește accesibilitate cu orice echipament la momentul deblocării; cumpărarea upgradeurilor și alegerea încărcăturii rămân necesare.

## Economia începutului și campania simulată

Cu $400 per rundă, Strength2 cere **3 runde**; cu selecția eficientă verificată de $550/cargo8, cere **2**. Nu există recompensă artificială pentru a asigura upgradeul.

Primele costuri granulare sunt Grip600, Carry650, Van900, Noise700. De la $0, la $400/rundă înseamnă 2/2/3/2 runde; la $550/rundă înseamnă câte2. Sunt calcule aritmetice pe câștiguri din încărcături testate, fără bonus repetabil. Cumpărările concurează pentru același portofel.

Simularea continuă fizică a folosit politica explicită: economisește întâi pentru Strength cerut de obiectivul principal, apoi cumpără capacitatea-țintă (Apartment1, House3, celelalte6), fără bani injectați. Fiecare rundă încasează numai obiectele livrate și evadarea reală. Rezultat:

- Strength2 cumpărat înainte de runda3, după două runde de $550, sold $100.
- Runda3 Apartment: $640; trei runde House de $660 acumulează bani pentru Strength3, cumpărat înainte de runda7. Prețul $2400 cere aproximativ4 runde de $660 de la zero, dar economiile existente reduc așteptarea la3 runde House în această campanie.
- Strength4 cumpărat înainte de runda13; cinci runde Villa de $1100 au contribuit la economisire.
- Strength5 cumpărat înainte de runda22; șase runde Mansion de $2040 au completat soldul. De la zero, $13800 ar cere7 astfel de runde.
- Campaign încheiat după **24 runde**, Strength5 / Grip1 / Carry1 / Van6 / Noise1, portofel **$8760**. Achiziții:4 Strength +5 Van = **9/80 (11,25%)**, fără MAX.

Nicio rundă a acestei politici economice nu a declanșat alarma: se alege loot valoros, limitat de cargo, nu full clear. Acesta este un rezultat de balans relevant. Campania automatizată nu este o estimare de retenție sau durată tipică pentru oameni. Alte priorități (de exemplu cargo înainte de Strength) ar schimba ritmul și procentul cumpărat; 11,25% descrie politica testată, nu o valoare universală.

## Teste și livrare

**613 verificări automate, 0 eșecuri:**

- `tests/core_v2.log`:78 — regresii de transport, pickup/load/drop, pereți, selecție, timeout/ESCAPE, plată unică, progres, save/corupție, input emulat, background și cleanup.
- `tests/challenge_v2_final.log`:514 — cele80 costuri/formule/totaluri, limite, responsabilități, migrare reală pe copie și schema2, grandfathering, zgomot unic/repickup/reset, alarmă30→12 și7→7, pauză/drop/load/escape după alarmă, contracte/bonusuri, șase full clear-uri MAX, șase comparații Noise1,18 contracte și24 runde de campanie.
- `tests/ui_v2_final.log`:21 — pornire/rejucare NORMAL/contract, cosmetice,10 cicluri de noduri/semnale/audio, cele5 carduri, cap global și tranzacții, grandfathering, bară/text/banner/ESCAPE, sunet distinct și MAX fără nivel21/$0.

Randare desktop Compatibility pe RTX2050 verificată prin capturi reale 450×800 și450×1000: SAFE, warning, alarmă cu artefact purtat, ESCAPE, pauză, tier caps și toate cele5 categorii MAX. Capturile `tests/v2_*.png` folosesc stări pregătite, distincte de dovada rutelor fizice.

Pentru reproducere: Godot4.7.1 cu `--headless --path <proiect> --script res://tests/test_suite.gd`, apoi `test_challenge_v2.gd` și `test_ui_v2.gd`. Pentru capturi se folosește `capture_v2.gd` fără headless. Testele folosesc profile QA; testul migrării citește copia din checkpoint. Intrările vechi `test_balance_v1.gd`/`test_ui_v1.gd` trimit acum la verificările actuale; istoricul V1 este în checkpoint, nu se confundă cu rezultatele V2.

## Probleme, recomandări și abateri

**Nicio abatere de la valorile Noise,80% threshold,12s window,60s NORMAL,procentele upgradeurilor,prețuri sau inventare. Nu au fost schimbate layouturile.** Exemplul textual Grip din cerere a fost corectat conform formulei cerute.

1. **Ținta MAX de0–5 s rămase nu este atinsă** pe aceste trasee: rezervă5,88–10,95 s. La MAX, alarma pornește la ultimul pickup: full noise=81% din bază, prag=80%; diferența este mai mică decât zgomotul oricărei instanțe. Prin urmare, alarma nu poate cere încă un circuit complet pe aceste inventare la MAX. În Electronics/Mansion/Museum, la declanșare sunt deja sub12 s, astfel încât alarma nu scurtează deloc cronometrul. Nu declar challenge-ul validat doar pentru că testele trec.
2. **Noise Control contează puternic la full clear**, după comparația L1/MAX, dar aproape deloc pe rutele economice selective testate. Pentru o etapă viitoare recomand playtest uman care compară exact aceste două stiluri; dacă MAX rămâne prea relaxat, trebuie decis explicit dacă se schimbă relația prag/multiplicator sau se repoziționează unele obiecte. Nu am aplicat această recomandare fără un nou acord asupra valorilor.
3. **Van L20 este momentan redundant pentru loot-ul actual:** L19=44 încape deja tot Museum; L20=46 nu permite un obiect suplimentar, iar contractele au limite mult mai mici. Am păstrat nivelul/costul/formula cerute. Recomand reevaluarea lui când se decide conținut suplimentar sau o altă progresie, fără a inventa acum loot suplimentar.
4. Carry atinge plafonul pentru LIGHT laL5 și MEDIUM laL13; nivelurile următoare ajută în continuare HEAVY/VERY_HEAVY. Shop arată plafonul, fără promisiuni false. Grip rămâne util tuturor obiectelor reale: pickup minim de catalog0,5/1,57≈0,318 s, peste limita0,25.
5. **Ritmul de2–4 runde nu este uniform:** ultimele Strength au cerut economisire mai lungă cu politica testată; upgradeurile granulare pot fi cumpărate mai des după accesul la loot valoros. Nu s-au modificat recompensele/prețurile ca să forțeze țintele.
6. **Neverificat:** Android pe telefon/emulator, touch hardware real, FPS mobil, safe areas/notch fizice, retenție și playtest uman complet. Evenimentele touch/Back sunt emulate. Exportul APK nu echivalează cu testarea pe dispozitiv.

## Fișiere principale

`balance.gd`: toate formulele/costurile/caps/noise; `run_manager.gd`: noise/alarmă/rezultat/logging; `loot_item.gd`: flag per instanță; `save_store.gd`: schema4/migrare/tranzacție; `progression.gd`: MAX cu5 staturi și next goal; `game_ui.gd`: HUD/shop; `sound_bank.gd`: alarmă/avertizare; `van.gd`: scalarea vizuală compatibilă cu20 niveluri; `main.gd`: profil QA V2. Layouturile și player movement au rămas neschimbate.

Logging local, fără analytics: noise_added, alarm_warning, alarm_triggered și run_ended cu location,mode,success,active_time,cash_escaped_with,cargo,noise_control_level,final_noise,alarm_threshold,alarm_triggered,time_when_alarm_triggered,remaining_time_at_escape,upgrade_levels. Banii evadați reprezintă loot-ul, separat de bonusurile de progres.

## Verificarea exporturilor 0.3.0

Windows release și Android debug au fost exportate cu cod de ieșire 0. Executabilul Windows exportat a pornit headless și cu randare Compatibility, folosind profilul separat, cod de ieșire 0 și fără erori. Jurnale: `tests/export_windows_v2.log`, `export_android_v2.log`, `packaged_v2_headless.log`, `packaged_v2_render.log`.

APK-ul a fost aliniat, semnat și verificat de exportator. Manifest inspectat: versionCode 3 / versionName 0.3.0, ARM64, min SDK 24, target SDK 36, fără permisiune Internet. Avertismentele Java native access și referința opțională `themed_icon.xml` absentă în template nu au împiedicat exportul; testarea launcherului și gameplay-ului Android rămâne necesară pe dispozitiv.


## V2.1 — balance patch

Aplicat în proiectul existent, build **0.3.1**, 21 septembrie 2026. Checkpoint anterior: `../checkpoints/before-challenge-v21`, inclusiv surse, teste, documentație și o copie a salvării disponibile. Schema de salvare rămâne 4; acest patch nu remapează niveluri, nu taxează și nu resetează progresul. Testele folosesc profile QA separate.

### Schimbările exacte

În `scripts/balance.gd` sunt schimbate numai patru linii de configurație:

1. `ALARM_THRESHOLD_FACTOR`: **0.80 → 0.65**.
2. `ITEMS.museum_artifact.cargo_space`: **8 → 10**.
3. `LOCATIONS.museum.expected_cargo`: **44 → 46** (totalul derivat este verificat automat).
4. `CONTRACTS["museum.small_van"].capacity_limit`: **16 → 18**.

Artefactul păstrează valoarea $2500, Strength 5, pickup 3,5 s, VERY_HEAVY și dimensiunea. Museum păstrează inventarul și valoarea totală **$8170**. SMALL VAN Museum păstrează ținta **$4000**, timpul **60 s** și bonusul unic **$1500**. Celelalte 17 contracte sunt neschimbate.

Compararea cu checkpointul confirmă că toate celelalte scripturi de gameplay sunt identice. Nu au fost modificate layouturile, mișcarea, pickup/load, prețurile, procentele upgradeurilor, obiectivele, deblocările, trofeele, cosmeticele sau salvarea. Metadatele exportului sunt actualizate la 0.3.1 (Android code 4). Nu s-au adăugat sisteme.

### Noise și formule păstrate

`alarm_threshold = base_location_noise * 0.65`

Base Noise rămâne LIGHT 4 / MEDIUM 7 / HEAVY 12 / VERY_HEAVY 18. Noise Control rămâne -1% per nivel, de la 100% la L1 până la 81% la L20, cu acumulare float. Pragul este independent de upgrade. Totalul unui inventar complet este 100% din Base Noise la L1, respectiv 81% la L20.

`threshold / effective_full_clear_noise_at_MAX = 0.65 / 0.81 = 0.802469...`

La MAX, pragul reprezintă aproximativ **80,25% din zgomotul efectiv al unui full clear**. Instanțele sunt discrete: momentul concret depinde de ordinea obiectelor și de pickup-ul care depășește pragul.

Alarma rămâne unică pe rundă, cu `remaining = min(remaining, 12.0)`: 30 → 12, 7 → 7. DROP și reculegerea nu dublează zgomotul. După alarmă se poate continua pickup/load/drop/escape; pauza suspendă timerul. NORMAL rămâne 60 s. Nicio altă limită de timp nu a fost ajustată.

### Full clear fizic la MAX — toate cele șase locații

Același pilot și aceeași ordine de loot ca în V2: mișcare CharacterBody3D cu coliziuni, oprire, pickup, transport și load reale, fără teleportări între obiectele traseului. Toate cele cinci staturi sunt la MAX. Timpul este activ, în secunde, măsurat cu pas de simulare echivalent 1/60 s. Înregistrarea încărcăturii la alarmă se face în test, la semnalul existent, fără a modifica logica jocului.

| Locație | Full clear s | Alarmă la s | Obiecte deja încărcate | Cargo deja încărcat | Noise final | Prag | Rămas la ESCAPE s |
|---|---:|---:|---:|---:|---:|---:|---:|
| Apartment | 39,87 | 33,35 | 7 | 12 | 45,36 | 36,40 | 5,48 |
| Suburban House | 50,25 | 41,82 | 8 | 19 | 73,71 | 59,15 | 3,57 |
| Villa | 44,72 | 33,48 | 5 | 22 | 74,52 | 59,80 | 0,77 |
| Electronics Store | 52,22 | 41,77 | 7 | 26 | 69,66 | 55,90 | 1,55 |
| Mansion | 54,12 | 42,28 | 6 | 29 | 93,96 | 75,40 | **0,17** |
| Museum | 50,60 | 39,50 | 5 | 36 | 98,82 | 79,30 | **0,90** |

Obiectul care declanșează alarma este încă în mâini, deci nu este inclus în coloanele „deja încărcat”. Toate rutele au confirmat ESCAPE înainte de timeout și au acordat full clear și plata corectă.

**Mansion și Museum ating ținta 0–5 s.** Alarma limitează acum efectiv timpul disponibil la ambele, iar ultima parte a traseului trebuie parcursă în cele 12 s. Apartment rămâne puțin mai permisiv, fără modificări artificiale.

Date brute, ID-urile rutei, tipurile obiectelor și timpii pe circuit: `tests/challenge_v21_measurements.json`. Câmpuri suplimentare: `loaded_items_at_alarm`, `loaded_cargo_at_alarm`, `noise_at_alarm`, `carried_at_alarm`. Sunt măsurători automate de fezabilitate, nu rezultate de playtest uman.

### Van L20 și Museum SMALL VAN

Formula Van este neschimbată: `8 + 2*(L-1)`. L19 = 44, L20 = 46.

- Museum total **46**: L19 nu poate transporta întregul inventar, strict din capacitate.
- Cu celelalte obiecte însumând 36 cargo, artefactul de 10 cargo este respins la L19 și acceptat la L20.
- Full clear-ul fizic Museum la L20 a încărcat toate cele **46 cargo**, apoi a evadat. Van L20 este acum necesar pentru acest full clear.
- Test separat SMALL VAN Museum: **artefact + statuie = 18 cargo / $4000**, parcurs fizic în **14,38 s**, cu **45,62 s** rămase. Noise final 29,16 / prag 79,30. Contract completat, fără schimbarea țintei sau termenului.

### Toate cele 18 contracte

Fiecare a fost rejucat fizic la MAX și a trecut. Tabelul arată timpul activ până la ESCAPE:

| Locație | RUSH s | SMALL VAN s | CLIENT ORDER s |
|---|---:|---:|---:|
| Apartment | 16,73 | 10,97 | 15,40 |
| Suburban House | 22,82 | 18,62 | 18,82 |
| Villa | 23,75 | 12,82 | 15,30 |
| Electronics Store | 29,43 | 19,73 | 22,80 |
| Mansion | 31,85 | 15,37 | 28,77 |
| Museum | 28,82 | 14,38 | 27,67 |

Niciun contract testat nu a devenit imposibil. Încărcăturile selective ale acestor rute nu ating noul prag de alarmă; termenele și cargo-ul rămân constrângeri. Acest rezultat nu dovedește că Noise este decisiv în orice contract sau că toate sunt accesibile cu orice echipament.

### Teste și verificarea domeniului patch-ului

**457 verificări trecute, 0 eșecuri** în această etapă:

- `tests/challenge_v21.log`: **358** — formula de prag 65%, L1/L20 și raportul 80,2469%, independența pragului, zgomot unic, DROP/repickup, alarma 30→12 și 7→7, continuare/pauză/timeout, costuri și formule păstrate, Museum 46 cargo, L19/L20, șase full clear-uri, 18 contracte și soluția explicită artefact + statuie.
- `tests/core_v21.log`: **78** — regresii pentru transport, coliziuni, input emulat, tranzacții, progres, salvare/corupție, pauză/background și rejucare.
- `tests/ui_v21.log`: **21** — interfață, reguli de sesiune, cumpărări/tier caps, cosmetice, feedback alarmă și cleanup pentru zece cicluri.

Costurile sunt reverificate: exact **80 achiziții / $224.700**. Sursa de gameplay diferă de checkpoint numai în cele patru linii enumerate. Numărul de verificări descrie suita rerulată pentru acest patch; cele 613 din secțiunile anterioare sunt rezultatele istorice V2, nu sunt adunate din nou. Nu a fost necesară repetarea întregii campanii sau a migrării V1→V2 pentru aceste modificări de configurație.

Reproducere: Godot 4.7.1 cu `--headless --path <proiect> --script res://tests/test_challenge_v21.gd`, plus `test_suite.gd` și `test_ui_v2.gd`. Profile QA separate; profilul principal nu este folosit pentru teste.

### Probleme observate, fără ajustări ascunse

- Mansion are doar **0,17 s**, aproximativ zece pași de simulare, rezervă pe ruta testată; ținta este atinsă, dar marja pentru eroare umană este foarte mică. Museum are **0,90 s**. Este necesar playtest uman înainte de a declara dificultatea potrivită.
- Villa este și ea strânsă, cu **0,77 s**. Apartment are **5,48 s**, acceptabil conform cererii de a nu uniformiza artificial nivelurile.
- Contractele selective testate nu declanșează alarma la MAX. Nu au fost modificate ca să o declanșeze forțat.
- Recordurile și realizările istorice sunt păstrate. Un record V2 existent poate fi mai greu de depășit în V2.1; nu s-au resetat în secret.
- Android pe dispozitiv, touch hardware real, FPS mobil și playtestul uman rămân neverificate. Nu au fost făcute schimbări pentru a masca aceste limite.

### Livrabile verificate V2.1

Windows release și Android debug **0.3.1** au fost exportate cu cod de ieșire 0 (`tests/export_windows_v21.log`, `export_android_v21.log`). APK aliniat, semnat și verificat de exportator; manifest ARM64, versionCode 4 / versionName 0.3.1, min SDK 24 / target SDK 36, fără Internet. Avertismentele existente Java native access și icon tematic opțional lipsă în template nu au blocat exportul.

Executabilul Windows exportat a pornit headless și cu randare Compatibility, pe profil separat, cod de ieșire 0 și fără erori (`tests/packaged_v21_headless.log`, `packaged_v21_render.log`). Testarea APK-ului pe dispozitiv rămâne neverificată.

