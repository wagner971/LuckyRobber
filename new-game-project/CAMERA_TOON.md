# Camera Toon — 0.9.3 (actualizat în 0.9.5)

Din 0.9.5, halftone-ul nu mai este folosit: camera păstrează benzile de culoare și conturul cartoon, iar albul personajului este păstrat luminos. Shaderul vechi pe fiecare obiect a fost eliminat.

Efectul toon este acum un singur shader 2D peste randarea camerei 3D: `assets/shaders/camera_toon.gdshader`. `scripts/camera_toon_effect.gd` îl afișează pe un `CanvasLayer` cu layer `-1`, după lumea 3D și înainte de HUD (`GameUI`, layer `0`). Textul, iconițele și butoanele nu sunt procesate de shader.

Shaderul reduce lin luminozitatea la patru trepte și accentuează contururile din diferențele de culoare vecine. Suprafețele aproape albe își păstrează luminozitatea, iar trecerea respectă transparența previzualizărilor 3D. Camerele gameplay, Home/Upgrades, colecția de trofee și preview-ul banilor folosesc aceeași implementare.

Meshurile procedurale folosesc `StandardMaterial3D` simplu; `Models.set_toon_profile` a rămas un apel de compatibilitate fără efect pentru constructorii existenți. `ToonMaterial` păstrează numai enumul de compatibilitate, iar shaderul halftone vechi a fost șters. Culorile costumului și ale dubei continuă să fie modificabile individual.

Verificare: `tests/test_toon_shader.gd` verifică trecerea pe cameră, ordinea HUD-ului, lipsa materialelor toon vechi, inputul și recolorarea. Capturi: `tests/pyramid_redesign_full.png` și `tests/dev_fresh.png`. Suitele personaj, live menu, HUD, Pyramid, Castle, UI V2 și core au trecut fără eșecuri.

Exporturile curente 0.9.5 sunt în Windows (`../builds/windows/STEAL EVERYTHING.exe`) și Android ARM64 debug (`../builds/android/steal-everything-debug.apk`). Android nu a fost testat pe telefon fizic.
