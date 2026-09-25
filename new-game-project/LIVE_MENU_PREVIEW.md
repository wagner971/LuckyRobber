# LIVE 3D MENU PREVIEW — build 0.5.0

Implementat în proiectul Godot 4.7.1 existent, folosind imaginile furnizate ca referință pentru compoziție, bleumarin/albastru, butoane verzi, accente aurii și titluri groase. Imaginile nu sunt fundaluri sau sprite-uri folosite în joc. Personajul din meniu este modelul 3D real al jocului.

## Ecrane

- **Home** este noul ecran de pornire: bani reali, Settings, titlu, personaj mare animat în prim-plan, frigider și dubă în planul secund, PLAY dominant, Collection, Upgrades, Stats și Trophies. DEV MAX rămâne disponibil când development este activ. PLAY deschide Jobs; nu începe automat o rundă.
- **Upgrades** păstrează toate cele cinci upgradeuri, efectele, costurile și limitele existente. Headerul conține un personaj live mai mic, iar lista derulează separat.
- **Collection** este ecranul ținutelor și culorilor dubei. Preview-ul este fix deasupra listei, astfel încât schimbările rămân vizibile în timpul derulării. Numele și starea EQUIPPED sunt explicite. Trophy Shelf rămâne separat, accesibil de aici și din Home.
- **Jobs** este mai compact și păstrează datele reale, deblocările, obiectivele, recordurile și Special Jobs. Nu conține un viewport suplimentar, pentru a lăsa spațiu cardurilor.
- **Settings** are control audio funcțional și instrucțiuni. Preferința audio persistă în fișierul profilului cu sufixul `.settings.cfg`, separat de progresie.
- **Stats** citește statisticile, trofeele, medaliile, obiectivele și recordurile existente; nu introduce o progresie nouă.

## Componenta reutilizabilă

`scripts/menu_character_preview.gd` definește `MenuCharacterPreview`, un Control reutilizabil care afișează textura unui SubViewport cu lume 3D izolată. Componenta instanțiază `Models.thief()` / `ThiefVisual`, aceeași geometrie și aceiași pivoți ca în runde. Nu instanțiază RunManager sau CharacterBody3D și nu poate porni timerul, modifica progresia sau mișca jucătorul.

Configurația primește SaveStore, tipul prezentării și înălțimea. Personajul folosește IDLE existent, cu respirație, rotire lentă foarte mică și balans subtil. Props-urile sunt modelele existente de dubă și frigider. Camera se ajustează după proporțiile panoului.

Renderul este solicitat la cel mult aproximativ 30 Hz și este limitat la 640×480, păstrând proporțiile. Se folosește o lumină direcțională fără umbre, iluminare ambientală și geometrie simplă, fără particule sau post-procesare grea. Randarea și animația se opresc când aplicația este în fundal. La schimbarea meniului, preview-ul vechi este oprit imediat și eliberat; în gameplay nu rămâne niciun preview de meniu.

## Sincronizarea ținutelor

Sursa unică de date rămâne `SaveStore.data.cosmetics.equipped`, cu sloturile existente `suit`, `van`, `set`. Regulile seturilor și ale pieselor individuale sunt neschimbate.

1. Butonul EQUIP folosește metodele existente SaveStore, care salvează echiparea.
2. SaveStore emite `appearance_changed` după echipare/reset.
3. Preview-ul deja existent apelează `Models.apply_appearance()`, exact aceeași funcție ca playerul și duba din gameplay. Actorul și viewportul nu sunt reconstruite la fiecare echipare.
4. Lista și eticheta EQUIPPED se actualizează, păstrând panoul 3D vizibil.
5. Alte meniuri și următoarea rundă citesc aceeași echipare. Relansarea folosește salvarea existentă.

`Models.apply_appearance()` restaurează întâi paleta originală și apoi aplică ținuta. Astfel, trecerea set→piesă individuală și resetul nu lasă culori vechi. `ThiefVisual` reține culorile originale ale pieselor sale. Capul, masca, pielea și zonele albe rămân conforme cu regulile de recolorare existente. Catalogul actual recolorează ținuta și duba; nu au fost inventate accesorii, monede sau un sistem nou de dressing room.

## Fișiere

| Fișier | Schimbare |
|---|---|
| `scripts/menu_character_preview.gd` | Componentă nouă pentru modelul 3D live și lifecycle |
| `scripts/game_ui.gd` | Home, temă de meniu, preview pe trei ecrane, Collection fixă, Jobs compact, Stats/Settings |
| `scripts/main.gd` | Pornire în Home, navigare, cleanup, preferință audio, suspendare în fundal |
| `scripts/save_store.gd` | Semnal appearance_changed; schema de progresie rămâne 5 |
| `scripts/models.gd` | Aplicare și reset comune ale cosmeticelor |
| `scripts/thief_visual.gd` | Memorarea/restaurarea paletei originale |
| `tests/test_live_menu.gd` | Teste de integrare și capturi |
| `tests/capture_live_menu_motion.gd` | Demonstrație animată a actualizării ținutelor |
| `tests/test_variety_ui.gd` | Testul restaurării ofertei urmează acum Home→PLAY→Jobs |
| `export_presets.cfg` | Windows0.5.0 / Android0.5.0 code8 |

Scenele rămân compuse din cod, ca în proiectul existent. `scenes/main.tscn` este reutilizată; nu s-a introdus un al doilea player sau o scenă paralelă de gameplay.

## Validare

**210 verificări trecute, 0 eșecuri** în această actualizare:

| Suită | Verificări |
|---|---:|
| `test_live_menu.gd` | 35 |
| `test_variety_ui.gd` | 29 |
| `test_suite.gd` | 78 |
| `test_ui_v2.gd` | 21 |
| `test_development.gd` | 15 |
| `test_character.gd` | 32 |

Testele verifică model live animat, rezoluție limitată, layout portret, costumul A→B, recolorarea pălăriei/tricoului/pantalonilor și dubei prin funcția comună, resetul fără culori rămase, echiparea independentă suit+van, aspect identic în gameplay, relansare cu B, input real pe PLAY, preview fără capturarea joystickului, Back din Jobs, audio persistent, oprire în fundal și cleanup după 32 de tranziții. Numărul nodurilor revine la valoarea inițială și rămâne un singur preview activ.

Layout verificat la ferestre 450×800 și dimensiuni portret720×1280,720×1600,720×1100. Capturi inspectate: `tests/menu_home.png`, `menu_home_midnight.png`, `menu_collection_plum.png`, `menu_collection_midnight.png`, `menu_upgrades.png`, `menu_jobs_special.png`.

`tests/live_menu_preview.gif` prezintă animația și schimbarea prin semnal a ținutei: original → Midnight → Plum + Mint. Banii și deblocările din capturi sunt fixture-uri QA; jocul afișează datele profilului real. Testele și capturile nu rescriu salvarea principală.

Reproducere: Godot4.7.1 cu `--path <proiect> --script res://tests/test_live_menu.gd -- --capture`; celelalte suite pot folosi `--headless`. Captura animată se generează prin `capture_live_menu_motion.gd`.

## Limite

Nu s-au schimbat balansul, formulele, fizica jafului, timerul, inventarele sau schedulerul Special Jobs. Nu s-a actualizat motorul. Progresul, DEV MAX și cosmeticele rămân persistente.

Actualul catalog conține recolorări, nu piese vestimentare interschimbabile. Extensiile viitoare se fac în model și în funcția comună de aplicare; preview-ul nu conține reguli cosmetice duplicate. Android pe dispozitiv și măsurarea consumului GPU pe telefon rămân neverificate; limita de randare nu este o promisiune de FPS pe orice telefon.

Checkpoint înainte de modificare: `../checkpoints/before-live-menu`. Builduri: `../builds/windows/STEAL EVERYTHING.exe` și `../builds/android/steal-everything-debug.apk`.

Exporturile Windows și Android0.5.0 au trecut cu cod0. Executabilul Windows a pornit headless și cu randare OpenGL pe profil QA separat, fără erori de script. APK-ul a trecut alinierea, semnarea și verificarea exportatorului. Loguri: `tests/export_windows_live_menu.log`, `export_android_live_menu.log`, `packaged_live_menu_headless.log`, `packaged_live_menu_render.log`. Varianta Home cu ofertă Special Job a fost inspectată suplimentar în `tests/menu_home_pending.png`.
