# STEAL EVERYTHING — VARIETY RUN V0.1

Build 0.4.0, 21 septembrie 2026. Implementat în proiectul Godot 4.7.1 existent. Singurul tip Special Job este `RUSH_HOUR`. Regulile de balans V2.1 rămân neschimbate.

## Scheduler

`SpecialJobs` este un modul mic, cu definiții identificate prin ID și un scheduler comun. Definiția conține `id`, `display_name`, `description`, `time_override`, `cash_multiplier`. Nu există alte tipuri implementate.

La prima pornire și după consumarea unui special, se alege un număr întreg uniform 2–4, apoi se salvează. Nu se aruncă o șansă după fiecare rundă. `runs_since_special` începe la 0. Un NORMAL început efectiv contează o singură dată la SUCCESS, FAILURE sau abandon manual. Început efectiv = prima intenție de mișcare, aceeași condiție ca pentru timer. Abandonul READY, meniurile, DEV MAX, relansarea, Mastery și specialele nu incrementează contorul.

La atingerea pragului, există un singur pending RUSH_HOUR în locația NORMAL care a atins pragul. Cât timp acesta așteaptă, contorul rămâne înghețat. Continuarea NORMAL, inclusiv în altă locație, nu schimbă oferta și nu acumulează alte oferte. Jocul nu obligă acceptarea.

Oferta se consumă numai după start și rezultat/abandon. Se resetează contorul și se salvează următorul prag 2–4. Back sau abandon înainte de start păstrează oferta. Startul unei alte runde nu poate înlocui silențios una activă. Results oferă CONTINUE NORMAL, nu replay al specialului consumat.

## RUSH HOUR și payout

- Durată 35 s; NORMAL rămâne 60 s.
- Bonus `roundi(base_loot * (1.40 - 1.0))`, o singură rotunjire monetară pe totalul livrat; nu per obiect. Inventarul actual folosește valori pentru care bonusul este întreg exact.
- La succes: `base_loot + rush_bonus + first_clear_bonus`. Bonusul unic existent de full clear ($250) rămâne separat, nemultiplicat și unic între NORMAL/SPECIAL.
- La failure/timeout/abandon: $0. Loot-ul doar purtat, pe jos sau încă în curs de încărcare nu intră în baza bonusului.
- Exemplu verificat: două seifuri SMALL SAFE livrate, $1000 bază + $400 bonus = $1400.
- Obiectivele cash primesc numai baza: $650 + $260 plătește $910, dar nu completează obiectivul $800.
- Obiectivele signature, full clear și trofeele folosesc obiectele efectiv livrate și evadarea reușită. Deblocarea locațiilor funcționează normal.
- Recordurile full clear SPECIAL sunt separate de NORMAL și Mastery. Nu se acordă medalii sau bonusuri Mastery.
- Noise, pragul 65%, alarma `min(remaining,12)`, greutăți, pickup, Carry, Van, Strength, Grip, Noise Control, inventare și poziții sunt aceleași. Sunt testate atât 20→12, cât și 8→8 secunde la alarmă.

## Salvare, relansare și DEV

Schema5 păstrează toate câmpurile permanente și adaugă:

| Câmp | Rol |
|---|---|
| `runs_since_special` | NORMAL terminate în ciclul curent |
| `special_interval` | Pragul deja ales 2–4 |
| `special_pending` | Există o ofertă disponibilă |
| `special_type` | `RUSH_HOUR` |
| `special_location_id` | Locația fixată când s-a atins pragul |
| `special_in_progress` | Marcaj de recuperare pentru un special început |

Intervalul se scrie inclusiv la prima pornire fără nicio rundă. Reload, shop, scene și failure NORMAL nu îl rerollează. Oferta neîncepută reapare identică după închiderea jocului.

După prima mișcare într-un special, se salvează marcajul `special_in_progress`. Închiderea normală finalizează abandonul; după închidere forțată, următorul load consumă încercarea întreruptă fără bani și salvează noul ciclu o singură dată. Astfel, restartul nu oferă repetări gratuite ale unei runde deja începute. NORMAL întrerupt prin închiderea aplicației nu contează ca rezultat și nu schimbă pragul. Rundele incomplete nu sunt restaurate.

Pentru schema4/V2.1 se face backup `.schema4.bak`, se păstrează upgradeurile fără remapare și se adaugă contor0, interval2–4, pendingfalse. Migrarea veche schema2/3 și mecanismele de backup/recuperare rămân disponibile. Profilul real nu a fost folosit pentru QA.

**Conform alegerii utilizatorului, progresul și Special Jobs persistă și în DEV.** Cerința anterioară de resetare la fiecare pornire este înlocuită. DEV MAX rămâne în meniu/shop/results și salvează nivelurile maxime. Nu acordă bani/obiective și nu alterează schedulerul.

Hook pentru teste: `main.dev_force_special(location_id)`. Numai cu development activ, locație deblocată, fără pending și fără rundă nefinalizată. Setează contorul la prag și salvează oferta; nu are buton dedicat. `development/enabled=false` dezactivează hookul și ascunde DEV MAX în producție.

## UI

Location Select păstrează structura existentă. Când există pending, un card distinct de sus arată SPECIAL JOB AVAILABLE, RUSH HOUR, locația, 35 SECONDS și +40% CASH, cu PLAY SPECIAL și CONTINUE NORMAL mai discret. Dispare după consumare. Results la atingerea pragului anunță oferta fără a obliga jucătorul să o accepte.

HUD-ul afișează SPECIAL JOB · RUSH HOUR · +40% CASH și timerul35. Feedback-ul ultimelor10 secunde/Noise/Alarm este păstrat. Results arată Base loot, Rush bonus și Total earned; un eventual FIRST CLEAR BONUS are propria linie.

Capturi inspectate la450×800: `tests/variety_offer.png`, `variety_hud.png`, `variety_results.png`, `variety_normal.png`. Sunt fixture-uri UI, nu măsurători de traseu.

## Validare

717 verificări trecute, 0 eșecuri în versiunile finale ale suitelor:

| Suită | Verificări |
|---|---:|
| `test_variety_v01.gd` | 186 |
| `test_variety_ui.gd` | 28 |
| `test_variety_legacy.gd` | 31 |
| `test_challenge_v21.gd` | 358 |
| `test_suite.gd` | 78 |
| `test_ui_v2.gd` | 21 |
| `test_development.gd` | 15 |

Acoperire cerințe1–25: interval inițial și prag exact2/3/4; un singur pending; SUCCESS/FAILURE/abandon NORMAL; excluderea Mastery/SPECIAL/READY; refuz și continuare NORMAL; pending și interval identic la reload; timere35/60; payout exact și obiective fără bonus; alarmă identică; consum la trei rezultate și păstrare înainte de start; reset de ciclu; migrare fără pierdere; toate18 Mastery și regresie NORMAL. În plus: protecție împotriva rezultatului dublu, relansare după start special, DEV persistent, acces la special înainte de Mastery, hook sigur și recorduri separate.

Cele25 trasee NORMAL/Mastery din `challenge_v21_measurements.json` sunt identice câmp cu câmp cu checkpointul anterior Variety: timpi, bani, cargo, zgomot, alarmă, trasee și rezultate. Cele18 contracte au fost parcurse fizic; niciunul nu a fost rebalansat. Mișcarea, layoutul, obiectele, modelele, duba și sunetele sunt fișiere identice cu checkpointul.

### Simulare30 runde

Seed reproductibil21092026. Folosește ciclul real RunManager cu start și rezultate mixte: timeout, abandon și evadare. Evadările goale sunt valide și plătesc$0. Aceasta testează programarea evenimentelor, nu traseele de loot.

N=NORMAL, S=SPECIAL; barele separă ciclurile:

`N N S | N N N N S | N N S | N N N N S | N N S | N N N S | N N N N S | N N`

23 NORMAL +7 SPECIAL. Intervalele încheiate: **2,4,2,4,2,3,4**. Niciodată consecutive și niciodată mai mult de4 NORMAL până la disponibilitate. Ultimele2 NORMAL sunt în ciclul următor. Refuzul a fost verificat separat cu8 NORMAL după pending, fără schimbarea ofertei sau acumulare.

### Trasee fizice RUSH HOUR

Pilotul existent parcurge CharacterBody3D și interacțiunile reale, la upgradeuri MAX. Sunt rute selective; nu pretind full clear în35 s.

| Locație | Timp | Bază | Bonus40% | Total |
|---|---:|---:|---:|---:|
| Apartment |16,73 s|$840|$336|$1176|
| House |22,82 s|$1480|$592|$2072|
| Villa |23,75 s|$2440|$976|$3416|
| Electronics |29,43 s|$3050|$1220|$4270|
| Mansion |31,85 s|$3900|$1560|$5460|
| Museum |28,82 s|$6000|$2400|$8400|

Full clear SPECIAL și bonusul unic sunt verificate separat prin fixture de interacțiuni cu toate obiectele încărcate; fixture-ul repoziționează personajul și nu este o dovadă de traseu fizic în35 s.

Rezultate automate: `tests/variety_v01_measurements.json`. Reproducere: Godot4.7.1 cu `--headless --path <proiect> --script res://tests/<suita>.gd`. Pentru capturi, `test_variety_ui.gd` fără headless și cu `-- --capture`. Profilele QA sunt separate.

## Builduri și limite

Windows0.4.0 și AndroidARM64 debug0.4.0/code6 folosesc proiectul existent, DEV activ și progres persistent. Testele și documentația sunt excluse din export. Checkpoint: `../checkpoints/before-variety-v01`.

Nu sunt adăugate alte moduri, monede, upgradeuri, locații, layouturi sau modificatori. Nu există erori cunoscute în testele executate. Android pe dispozitiv, touch real și evaluarea umană a întrebării «este mai fun?» rămân neverificate. Testele automate verifică regulile și funcționarea, nu distracția sau retenția.


Exporturile Windows și Android s-au încheiat cu cod0. APK-ul a trecut alinierea, semnarea și verificarea exportatorului. Executabilul Windows exportat a trecut două porniri pe profil QA separat: headless și randare OpenGL; cod0, fără erori de script. Schema5 și intervalul/contorul au rămas identice între lansări. Jurnale: `tests/export_windows_variety.log`, `tests/export_android_variety.log`, `tests/packaged_variety_headless.log`, `tests/packaged_variety_render.log`.

