# Upgrades V3 — Bungee / Lilita One

Pagina Upgrades urmează macheta de referință.

1. **Header** partajat (`currency_header`): pastile cash/diamante; butonul din dreapta este **înapoi** („<”) în loc de setări.
2. Titlu **UPGRADES** (Bungee) + „MAKE YOUR ROBBER STRONGER” (Lilita One).
3. **NEXT TARGET** (`ShopTargetPanel`): iconița obiectului, titlul, cerința cu majuscule („UPGRADE STRENGTH TO LEVEL 3”), buton **GO ›** violet care selectează și derulează la cardul potrivit.
4. **Cinci carduri** (`upgrade_cards`): placă colorată cu arta stat-ului (portocaliu / albastru / verde / roșu / violet — tap = detalii cu formula), nume (Bungee), „LEVEL n / max · NEED k” (NEED în galben), descriere scurtă (Strength adaugă „· x% less noise”), bară de nivel în 5 segmente colorate, **BUY $preț** verde cu iconiță de cash (MAXED / LOCKED / FREE · TOKEN după caz), iar dedesubt linia de beneficiu: loot-ul deblocat pentru Strength (iconițe + nume + „+N”), „+12% PICKUP SPEED”, „WALK +2% · HEAVY LOOT +20%”, „8 → 11 CARGO” cu cuburi de cargo, „−1% NOISE”.
5. Cardul selectat are chenar și glow în culoarea stat-ului; animațiile de cumpărare (puls, flash, bara de nivel, POWER UP! la Strength) rămân neschimbate.
6. Navigația comună (HOME · JOBS · UPGRADES · GARAGE), cu punct roșu pe UPGRADES când există un upgrade accesibil.

Preview-ul 3D al personajului nu mai apare pe această pagină (macheta nu îl are; personajul se vede pe Home, Garage și Locker).

Capturi: `tests/shop_v3.png` (720×1280, fără scroll) și `tests/shop_v3_narrow.png` (450×800), din `tests/capture_shop_v3.gd`.
