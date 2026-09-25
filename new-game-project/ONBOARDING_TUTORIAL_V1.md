# ONBOARDING / TUTORIAL V1

Introdus în buildul 0.6.0; buildul actual este 0.7.0, 21 septembrie 2026. În DEV, fiecare lansare creează un profil nou în `user://dev_progress.json`, deci tutorialul reîncepe. Progresul rămâne valabil în sesiunea curentă; profilul principal existent nu este modificat. Layer peste Apartment și mecanicile existente; valorile de loot, costurile, cargo, mișcarea, formulele Noise și layouturile normale nu sunt modificate. Checkpoint: `../checkpoints/before-onboarding`. `scripts/balance.gd` este identic cu acesta.

## Flux și state machine

Pe profil nou, Home → PLAY intră direct în Apartment; nu se cere alegerea unei locații. `scripts/onboarding.gd` este singura autoritate pentru pași:

| Stare | Acțiune cerută și tranziție |
|---|---|
| MOVE | DRAG TO MOVE; minimum 0,65 unități de mișcare efectivă cu input. Pickup blocat, timer oprit, statistici estompate. |
| GET_FIRST_ITEM | GET THE TV; numai `apartment.tv_a` poate fi ridicat. În rază: STOP TO PICK UP, auto-pickup existent. |
| CARRY_FIRST_ITEM | TAKE IT TO THE VAN; zona dubei pulsează și are săgeată. |
| LOAD_FIRST_ITEM | Oprire în zona dubei; load automat. Ieșirea din zonă revine la carry. |
| GET_SECOND_ITEM | STEAL ONE MORE ITEM; alegere liberă dintre obiectele eligibile. Explicația ESCAPE TO KEEP IT are prioritate vizuală 1,8 s după primul load. |
| CARRY_SECOND_ITEM | Același sistem de carry și ghidare către dubă. |
| LOAD_SECOND_ITEM | Load prin mecanica normală, fără valoare sau durată specială. |
| RETURN_TO_VAN | RETURN TO THE VAN; dacă playerul este deja în zonă cu mâinile libere, trece la ESCAPE. |
| ESCAPE | Buton explicit ESCAPE & KEEP $XXX; suma este valoarea reală a încărcăturii. |
| COMPLETE | ESCAPED!, $XXX BANKED, wallet count-up și cash 3D, TUTORIAL COMPLETE; CONTINUE revine la Home. |

Pașii avansează prin acțiuni, nu prin timeout. DROP permite recuperarea obiectului și revine la etapa de pickup corespunzătoare. Mișcarea și coliziunile sunt cele reale. După MOVE începe timerul de 90 s, limitat la minimum 10 s; tutorialul nu produce BUSTED din lipsă de timp. Pauza îngheață gameplay-ul și animația încărcării banilor. Noise și Alarm sunt dezactivate numai aici.

## Bani, progres și replay

TV-ul păstrează $140 / 2 cargo; fiecare obiect ulterior păstrează valorile sale. Load adaugă numai VAN LOOT. La escape reușit, suma reală intră o singură dată în wallet, împreună cu salvarea imediată a `tutorial_completed=true`.

Tutorialul nu completează obiective, full clear, best time, trofee sau contracte și nu mărește contorul de Special Jobs/statisticile de runde normale. Abandonul sau închiderea nu acordă bani și nu persistă o rundă incompletă; următorul PLAY reîncepe MOVE într-un Apartment curat.

Settings → REPLAY TUTORIAL folosește aceiași pași, fără a modifica flagurile, walletul, upgradeurile, obiectivele, cosmeticele sau Special Jobs. Rezultatul spune PRACTICE COMPLETE și explică lipsa recompenselor; nu animă un transfer către wallet. CONTINUE revine în meniu.

## HUD, labels și cash

În tutorial: TIME, VAN LOOT, VAN SPACE, PAUSE și acțiunile relevante. Noise este ascuns. Primul target are pulse verde, săgeată și TV / $140 / 2 CARGO. După load: 9 bundle-uri 3D procedurale mici izbucnesc lângă dubă și apoi urmăresc torso-ul playerului; suma `+$valoare` apare lângă dubă, verde cu contur negru pe un dreptunghi rotunjit, iar VAN LOOT face count-up și pulsează. Lacătul și ESCAPE TO KEEP IT explică bankingul. Instrucțiunile sunt într-un panou mic sub HUD-ul de sus, dimensionat după text; acțiunile rămân jos. La rezultat, preview-ul cash existent zboară către wallet iar suma crește vizual în 0,8 s. Detalii: [MONEY_REWARD_VFX.md](MONEY_REWARD_VFX.md).

`assets/cash` conține OBJ-ul, MTL-ul și textura utilizatorului din `assets/Meshy_AI_Cash_Bundle_0820173211_texture_obj` aflat în directorul părinte al proiectului. `CashBurst3D` folosește direct `MeshInstance3D` în nivel, centrează/normalizează OBJ-ul, calculează punctul din lume care se proiectează peste VAN LOOT și mișcă/rotește fiecare instanță în 3D. Zborul nu folosește PNG, `TextureRect` sau `SubViewport`. `CashVisual` rămâne doar pentru prezentarea din rezultate, nu pentru încărcarea în timpul jafului.

`LootGuidance` reutilizează un singur label și după tutorial: targetul curent sau cel mai apropiat obiect eligibil. Afișează nume, valoare, cargo; dacă nu există o opțiune eligibilă relevantă, arată blocajul obiectului apropiat: lacăt + STRENGTH N REQUIRED sau NOT ENOUGH VAN SPACE. Poziția este limitată la zona dintre panourile HUD, evită playerul și feedbackul temporar, iar labelul se ascunde dacă nu există o poziție validă. VAN FULL / ESCAPE TO BANK YOUR LOOT apare contextual când capacitatea blochează selecția, nu permanent.

## Prima rundă Noise și Special Jobs

După tutorial, următorul PLAY pornește Apartment NORMAL: 60 s, Noise și Alarm reale, rewards, obiective și scheduler normal. La început apare scurt NEW: NOISE. Primul pickup adaugă zgomot după formula normală și afișează aproximativ 2 s TOO MUCH NOISE = ALARM, cu pulse pe bară. Atunci se salvează `noise_tutorial_completed=true`; explicația nu se repetă.

Până la această lecție, Special Jobs nu apar peste onboarding și nu pot fi pornite. O ofertă deja existentă rămâne intactă. Runda de Noise poate conta pentru scheduler conform regulilor NORMAL la final; apoi se revine la fluxul complet. Nicio formulă Noise/Alarm nu este simplificată în runda reală.

## Salvare și migrare

Schema6 adaugă două flaguri booleene: `tutorial_completed` și `noise_tutorial_completed`. Profil nou: false/false. Un profil vechi fără flaguri, dar cu wallet, upgradeuri, locații, obiective, contracte, recorduri, cosmetice/trofee, statistici sau progres Special Jobs primește true/true. Un profil vechi gol primește false/false. Flagurile explicite moderne sunt păstrate; Noise complet nu poate exista fără tutorial complet.

Schemele2,3,4,5 sunt acceptate, cu backup `.schemaN.bak`. Schema4/5 păstrează datele existente; schema2/3 folosesc în continuare conversiile V2 deja definite. Scrierea atomică, backupul, recuperarea JSON corupt și protecția pentru scheme necunoscute rămân active. Testele folosesc profile separate; profilul real al utilizatorului nu a fost resetat.

## Logging local

`user://onboarding_events.jsonl` înregistrează `tutorial_started`, `tutorial_step_completed`, `tutorial_completed`, `noise_tutorial_shown`, `tutorial_restarted`. Evenimentele includ profilul și tipul replay; pașii includ timpul activ scurs de la început, inclusiv timpul de citire, fără pauză. Fișierul este rotit la aproximativ 1 MB către `.previous.jsonl`. Loggingul funcționează și în DEV, fără backend sau SDK extern. Fixture-urile `session_only` nu scriu evenimente.

## Verificări executate

**589 verificări trecute, 0 eșecuri** în motorul Godot 4.7.1 (39 Money VFX, 73 onboarding, HUD, core și traseul fizic reluate în0.7.0; celelalte suite provin din0.6.0–0.6.1):

| Suită | Trecute |
|---|---:|
| `test_onboarding.gd` | 73 |
| `test_money_reward_vfx.gd` | 39 |
| `test_onboarding_route.gd` | 5 |
| `test_suite.gd` | 78 |
| `test_ui_v2.gd` | 21 |
| `test_variety_ui.gd` | 29 |
| `test_live_menu.gd` | 35 |
| `test_development.gd` | 23 |
| `test_variety_v01.gd` | 186 |
| `test_gameplay_hud.gd` | 68 |
| `test_character.gd` | 32 |

Acoperire: profil nou, timer înainte de MOVE, target TV, pickup/carry/drop/load, suma din van versus wallet, escape explicit și payout unic, absența recompenselor secundare, replay cu snapshot de progres identic, migrarea schemelor2–5, salvare/reîncărcare reală în profile QA, abandon/restart curat, protecție timer, Noise real și flag persistent, prioritatea față de oferta Special Job, 30 de runde Variety și șase trasee Special fizice.

Traseul suplimentar folosește deplasare și coliziuni reale pentru TV + scaun + escape ($190), fără teleportare, și a măsurat 6,88 s timp activ automat. **Acesta nu este un rezultat de UX și nu demonstrează învățarea de către un om.**

Capturile reale din `tests/onboarding_*.png` au fost inspectate: MOVE, TV, pickup/carry/load, bundle-uri 3D în burst lângă dubă și magnet către player, alegerea secundară, escape/banking, Noise și replay. Poziționarea labelurilor și panoului compact a fost verificată la360×800,450×800,600×800. Exemple: `onboarding_get_tv.png`, `onboarding_cash_burst.png`, `onboarding_cash_magnet.png`, `onboarding_cash_arrived.png`, `onboarding_noise.png`. Logurile actuale sunt `tests/onboarding_money_capture.log`, `money_reward_test.log`, `recheck_test_gameplay_hud.log` și `recheck_test_onboarding_route.log`.

## Playtest uman obligatoriu și limite

**Neefectuat:** obiectivul de învățare în aproximativ 30–45 s cu o persoană care nu a văzut jocul. Procedură: profil QA nou, fără explicații verbale; porniți cronometrul la PLAY și observați mișcarea, ridicarea TV-ului, încărcarea, alegerea celui de-al doilea obiect și escape-ul. Verificați dacă persoana înțelege diferența dintre VAN LOOT și wallet. Dacă întreabă „Ce trebuie să fac acum?”, notați exact starea și timpul; corelați cu logul local. Nu transformați timpul unui bot în scor de învățare.

Windows și Android sunt exportate separat; APK-ul ARM64 este semnat debug, versiunea0.7.0/code15. Executabilul Windows exportat este verificat cu randare OpenGL pe `--test-profile`; salvarea principală rămâne neatinsă. Loguri actuale: `tests/export_windows_money_vfx.log`, `tests/export_android_money_vfx.log`, `../builds/windows/packaged_money_vfx.log`. Inputul touch, performanța și lizibilitatea pe telefon fizic rămân de verificat. Nu există eșecuri funcționale cunoscute în suitele executate. Nici testarea automată, nici capturile nu înlocuiesc aceste verificări umane.

## Fișiere principale

`scripts/onboarding.gd`, `run_manager.gd`, `main.gd`, `save_store.gd`, `game_ui.gd`, `loot_guidance.gd`, `cash_burst_3d.gd`, `cash_visual.gd`, `local_log.gd`, `hud_style.gd`, `assets/hud/lock.svg`, `assets/cash`, `tests/test_onboarding.gd`, `tests/test_onboarding_route.gd`. Fixtures existente au flaguri explicite de profil experimentat pentru a continua să testeze fluxurile lor originale. Scenele continuă să fie construite din cod; nu a fost introdusă o scenă separată de tutorial.
