# Jobs V3 — Bungee / Lilita One

Pagina Jobs urmează macheta de referință: o singură coloană, citită de sus în jos.

1. **Header**: pastile pentru cash (`+` deschide Daily Wheel) și diamante (`+` deschide Lucky Shop), roată de setări în dreapta.
2. **Bara de capitol**: placă „CHAPTER 1” · „NORMAL HEISTS” · punctele de paginare (galben = locația curentă; tap schimbă locația, swipe-ul pe hero rămâne).
3. **Hero**: preview-ul 3D decupat cu colțuri rotunjite (`assets/shaders/jobs_cover.gdshader`: cover-crop, fade la bază, gri pentru locațiile blocate), numele locației jos-stânga, Lucky Block jos-dreapta cu scântei.
4. **NEXT TARGET**: iconița obiectului, titlu, cerința („STR 3 REQUIRED” — cardul este apăsabil și deschide Strength în shop).
5. **Statistici**: `$LOOT | ITEMS | secunde`.
6. **PLAY**: buton galben mare, text violet, încadrat de două Lucky Block-uri cu scântei; Final Job folosește portocaliul existent.
7. Ofertele secundare (Rush Hour, Play Normal, Replay Final Job, Contracts) ca bare late cu chevron.
8. **VAN SPACE 8 / 17 CARGO** cu bară din 8 segmente; **LOADOUT n/5 · TAP TO UPGRADE** cu chip-uri cu iconiță; **OBJECTIVES** cu iconiță, etichetă și inel de bifare.
9. **Navigația** (partajată de toate meniurile): iconiță peste etichetă, tab-ul activ mai deschis și cu glow.

Fonturi: `assets/fonts/Bungee-Regular.ttf` (`GameUI.display_font`: titluri, numere, PLAY) și `assets/fonts/LilitaOne-Regular.ttf` (`GameUI.body_font`: etichete). Lucky Block-ul din UI este `assets/ui/lucky_block.png`, tăiat din referința furnizată.

Capturi: `tests/jobs_v3_apartment.png` (720×1280), `tests/jobs_v3_locked.png`, `tests/jobs_v3_apartment_narrow.png` și `tests/jobs_v3_museum_narrow.png` (450×800, Final Job gata). Generate de `tests/capture_jobs_v3.gd` / `tests/capture_jobs_v3_narrow.gd`.
