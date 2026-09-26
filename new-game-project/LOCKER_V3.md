# Locker V3 — Bungee / Lilita One

Pagina Locker (cosmetice) urmează macheta de referință, fără textele decorative. Toată pagina este derulabilă.

1. **Header** partajat (`back_header`): pastile cash/diamante, buton înapoi; titlu **LOCKER** + „YOUR THIEF. YOUR GETAWAY. YOUR STYLE.”.
2. **TODAY'S SHOP** (`TodayShopPanel`): trei oferte din rotația zilnică existentă (`PlayRewards.today_shop`, zi UTC → shop-ul se schimbă la fiecare 24 h; „New looks in Xh YYm” se actualizează în fiecare secundă, „ROTATES DAILY”). Fiecare card (`TodayShopCard_<id>`): nume, tip (THIEF SKIN / GETAWAY VEHICLE / FULL SET), preview 3D live (van-ul cu shell-ul lui sau hoțul purtând skin-ul), preț (cash sau diamante), buton **BUY** galben / **EQUIP** / **EQUIPPED**, iar la vehicule **VIEW** (pagina de detaliu cu BUY & EQUIP).
3. **Echipat acum**: două panouri — THIEF SKIN și GETAWAY VEHICLE — cu numele look-ului purtat, eticheta EQUIPPED, preview 3D și **CUSTOMIZE** (sare la tab-ul potrivit din colecție).
4. **COLLECTION**, delimitată printr-o linie cu titlu: tab-uri **THIEF SKINS** / **VEHICLES** și o grilă de **30 de sloturi** fixe per tab (`LockerCollection.slots`): slotul 1 este look-ul original (ORIGINAL LOOK / GETAWAY VAN), apoi cataloagele de skin-uri (suit + set) și de vehicule în ordinea lor, restul rezervate. Un slot nedeținut arată **„?”** (și „IN TODAY'S SHOP” dacă e în rotația de azi); după deblocare, look-ul apare la locul lui cu arta standard (deocamdată aceeași pentru toate, colorată cu nuanța cosmeticului), numele, eticheta de raritate (COMMON / UNCOMMON / RARE / EPIC / LEGENDARY, derivată din preț / recompensă) și **EQUIP** / **EQUIPPED** (bifă galbenă). Slotul original dez-echipează doar slotul respectiv (`SaveStore.unequip_slot`).

Cod: `scripts/locker_collection.gd` (sloturi, raritate, nume, stare), `MenuCharacterPreview.preview_cosmetic/show_van` (preview de skin fără van), acțiunile `reset_suit` / `reset_van` în `main.gd`. Capturi: `tests/locker_v3_top.png`, `tests/locker_v3_collection.png`, `tests/locker_v3_narrow.png` (din `tests/capture_locker_v3.gd`).

## Raritate pe carduri

Fiecare card ia culoarea rarității look-ului (`LockerCollection.RARITY_COLORS`): COMMON gri, UNCOMMON verde, RARE cyan, EPIC violet, LEGENDARY portocaliu. Ofertele din shop, panourile echipate și sloturile deținute din colecție au chenar și glow în culoarea rarității, fundal ușor nuanțat, eticheta de raritate sub tip/nume și butoanele (VIEW / EQUIP / CUSTOMIZE) în aceeași culoare; BUY rămâne galben. Praguri actuale după preț: ≤ $5.000 COMMON, ≤ $10.000 UNCOMMON, ≤ $30.000 RARE, ≤ $100.000 EPIC, peste LEGENDARY; diamante și Lucky Shop = RARE; recompensele din contracte/trofee = LEGENDARY. Modelele 3D nu se schimbă.
