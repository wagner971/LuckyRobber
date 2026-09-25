# CHARACTER V0.1 — build 0.4.1

Personajul principal este reconstruit din geometrie 3D după imaginea furnizată: cap pătrat cu colțuri teșite, fes negru cu margine groasă, mască, ochi albi cu pupile, zâmbet asimetric, tricou în dungi pe toate laturile și mâneci, pumni blocky, pantaloni închiși și pantofi cu talpă albă.

Modelul este procedural, nativ Godot, în `scripts/thief_visual.gd`. Piesele sunt rigide, grupate în pivoți Body/Head/LeftArm/RightArm/LeftLeg/RightLeg/CarryAnchor. Fără skeleton, skinning, weight painting, Mixamo, retargeting sau root motion. Costumele existente recolorează piesele ținutei, păstrând fața, masca și dungile albe.

## Animații

| Stare | Mișcare |
|---|---|
| IDLE | Respirație verticală de 0,008 unități și rotație mică a capului |
| RUN | Picioare alternante ±25°, brațe opuse ±36°, salt mic și rotație a trunchiului |
| CARRY | Brațe ridicate, umeri urcați și întindere cartoon pentru sprijin; picioarele continuă să meargă |
| HEAVY CARRY | Pentru HEAVY/VERY_HEAVY: pași ±34°, cadență 8,4 în loc de 12 rad/s, înclinare în spate și balans lateral; obiectul urmează aceeași fază a pasului |
| PICKUP | Aplecare în ultimele 0,15 s ale pickup-ului existent; transfer în CarryAnchor la commit și revenire de 0,18 s |
| LOAD | Brațe înainte; obiectul real descrie un arc de 0,26 s spre slotul dubei, se micșorează la dimensiunea existentă 0,38; WHAM și recul al dubei la aterizare |

Alarma înmulțește cadența vizuală cu 1,13. Nu afectează viteza fizică. Intrarea/ieșirea din carry se amestecă rapid, fără salturi între pozițiile brațelor. DROP revine la brațe libere. Pauza îngheață personajul, obiectul din CarryAnchor, zborul spre dubă și reculul acesteia.

Mișcarea fizică rămâne în player.gd; animația rulează separat, citind viteza și starea autorității rundei. Capsula originală de coliziune rămâne radius0,24/height1,3. CarryAnchor este un copil vizual și urmărește direcția personajului; nu influențează colliderul.

## Integrare fără modificarea balansului

Pickup-ul nu are o întârziere nouă: anticiparea se suprapune cu durata existentă. Obiectul intră în CarryAnchor exact la commit_pickup. Load-ul contabilizează cargo exact la commit_load, după durata existentă de 0,30 s. Arcul este exclusiv vizual, fără duplicarea obiectului sau blocarea evadării. Banii se acordă în continuare numai la evadare.

`LootVan.cargo_landed` declanșează sunetul original sintetizat de impact și feedback-ul scurt WHAM. Animațiile și tween-urile sunt eliberate odată cu runda. Progresul, DEV MAX și Special Jobs rămân persistente.

Fișiere modificate: `thief_visual.gd` nou; `models.gd` conectează modelul și cosmeticele; `player.gd` citește starea vizuală; `run_manager.gd` transmite pickup/load/pauză și impact; `van.gd` descrie arcul și reculul; `sound_bank.gd` adaugă impactul WHAM. Nicio modificare în balance.gd, save_store.gd, progression.gd sau special_jobs.gd.

## Verificare

**718 verificări trecute, 0 eșecuri:**

- 32 noi pentru personaj: stări, alternanță, alarmă exclusiv vizuală, pauză, CarryAnchor, coliziune, cosmetice fără afectarea pielii, pickup fără întârziere, cargo unic, arc, impact unic, cleanup și DROP.
- 358 Challenge V2.1, inclusiv toate cele 18 Mastery și șase full clear-uri NORMAL.
- 78 interacțiuni/progresie/UI de bază.
- 21 UI V2, 186 Variety Run, 28 UI Variety și 15 DEV.

Cele 25 de măsurători NORMAL/Mastery sunt identice câmp cu câmp cu checkpointul `../checkpoints/before-character-v01`: aceiași timpi, loot, cargo, Noise, alarmă și rezultate. Șase trasee RUSH HOUR continuă să treacă. Testele folosesc profile QA separate.

Rularea testelor: Godot4.7.1 cu `--headless --path <proiect> --script res://tests/test_character.gd`. Celelalte suite se rulează în același mod.

Capturi inspectate:

- `tests/character_hero.png`: personaj apropiat în iluminare compatibilă cu jocul.
- `tests/character_motion.gif`: demonstrație în șase panouri, 60 de cadre generate în Godot.
- `tests/character_states.png`: stări comparate.
- `tests/character_game_idle.png` și `character_game_fridge.png`: scara reală din HUD și din nivel.

Previzualizarea izolată demonstrează aceleași piese și formule de animație; demonstrația LOAD folosește eșantionarea aceleiași funcții de arc. Integrarea reală, contabilizarea și pauza arcului sunt verificate separat în test_character.gd.

## Livrare

Windows0.4.1 și AndroidARM64 debug0.4.1/code7, DEV activ, salvare persistentă. Documentația, testele și previzualizările sunt excluse din export. Copia anterioară a proiectului este în `../checkpoints/before-character-v01`.

Modelul păstrează stilul și detaliile referinței într-o interpretare procedurală 3D; nu este o scanare exactă. Nu s-a modificat camera sau layoutul nivelurilor. Android pe dispozitiv și performanța mobilă a modelului nou rămân neverificate.

Exporturile Windows și Android au trecut cu cod 0. Windows exportat a pornit headless și cu randare OpenGL, fără erori, pe profil QA separat. APK-ul a trecut alinierea, semnarea și verificarea exportatorului. Loguri: `tests/export_windows_character.log`, `export_android_character.log`, `packaged_character_headless.log`, `packaged_character_render.log`.
