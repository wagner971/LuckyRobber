# Locker V3 — Bungee / Lilita One

Pagina Locker (cosmetice) urmează macheta de referință, fără textele decorative. Toată pagina este derulabilă.

1. **Header** partajat (`back_header`): pastile cash/diamante, buton înapoi; titlu **LOCKER** + „YOUR THIEF. YOUR GETAWAY. YOUR STYLE.”.
2. **TODAY'S SHOP** (`TodayShopPanel`): trei oferte din rotația zilnică existentă (`PlayRewards.today_shop`, zi UTC → shop-ul se schimbă la fiecare 24 h; „New looks in Xh YYm” se actualizează în fiecare secundă, „ROTATES DAILY”). Fiecare card (`TodayShopCard_<id>`): nume, tip (THIEF SKIN / GETAWAY VEHICLE / FULL SET), preview 3D live (van-ul cu shell-ul lui sau hoțul purtând skin-ul), preț (cash sau diamante), buton **BUY** galben / **EQUIP** / **EQUIPPED**, iar la vehicule **VIEW** (pagina de detaliu cu BUY & EQUIP).
3. **Echipat acum**: două panouri — THIEF SKIN și GETAWAY VEHICLE — cu numele look-ului purtat, eticheta EQUIPPED, preview 3D și **CUSTOMIZE** (sare la tab-ul potrivit din colecție).
4. **COLLECTION**, delimitată printr-o linie cu titlu: tab-uri **THIEF SKINS** / **VEHICLES** și o grilă de **30 de sloturi** fixe per tab (`LockerCollection.slots`): slotul 1 este look-ul original (ORIGINAL LOOK / GETAWAY VAN), apoi cataloagele de skin-uri (suit + set) și de vehicule în ordinea lor, restul rezervate. Un slot nedeținut arată **„?”** (și „IN TODAY'S SHOP” dacă e în rotația de azi); după deblocare, look-ul apare la locul lui cu arta standard (deocamdată aceeași pentru toate, colorată cu nuanța cosmeticului), numele, eticheta de raritate (COMMON / UNCOMMON / RARE / EPIC / LEGENDARY, derivată din preț / recompensă) și **EQUIP** / **EQUIPPED** (bifă galbenă). Slotul original dez-echipează doar slotul respectiv (`SaveStore.unequip_slot`).

Cod: `scripts/locker_collection.gd` (sloturi, raritate, nume, stare), `MenuCharacterPreview.preview_cosmetic/show_van` (preview de skin fără van), acțiunile `reset_suit` / `reset_van` în `main.gd`. Capturi: `tests/locker_v3_top.png`, `tests/locker_v3_collection.png`, `tests/locker_v3_narrow.png` (din `tests/capture_locker_v3.gd`).

## Raritate pe carduri și prețuri automate

Fiecare look din `Balance.COSMETICS` are un câmp **`rarity`** (COMMON / UNCOMMON / RARE / EPIC / LEGENDARY); prețul în cash nu se mai scrie, ci vine din **`Balance.RARITY_PRICES`** (`Balance.cosmetic_price(id)`): COMMON $5.000 · UNCOMMON $8.000 · RARE $15.000 · EPIC $50.000 · LEGENDARY $120.000. Excepții: `gem_price` (se plătește în diamante), `reward` + `target` (se câștigă, nu se vinde) și, dacă e nevoie, un `price` explicit care bate tabelul.

Ca să adaugi un model nou: o intrare în catalog cu `name`, `slot` (`suit` / `van` / `set`), `rarity`, `color` și, pentru vehicule cu shell 3D, `vehicle_style`. Prețul, culoarea cardului, eticheta și butoanele urmează raritatea automat; slotul din colecție apare în ordinea catalogului.

Cardurile (ofertele din shop, panourile echipate, sloturile deținute) sunt „neon” (`locker_card_shell`): placă întunecată, ramă și glow exterior în culoarea rarității (`LockerCollection.RARITY_COLORS`: gri, verde, cyan, violet, portocaliu), o spălare de culoare care urcă de jos, un disc de lumină (`locker_spotlight`) sub preview-ul 3D — cu soclul preview-ului colorat la fel (`VehiclePreview.setup(..., accent)`, `MenuCharacterPreview.set_accent`) —, tipul în nuanța rarității, eticheta de raritate și butoanele VIEW › / EQUIP / CUSTOMIZE › cu fundal închis, ramă și glow în aceeași culoare; BUY rămâne galben. Modelele 3D nu se schimbă.
