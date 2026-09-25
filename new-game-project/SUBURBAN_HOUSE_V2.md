# Suburban House V2 — 0.9.4

Casa este detached și deschisă către camera jocului. Are garaj lateral în stânga, fațadă cu ușă de garaj, alee de beton, o mașină decorativă în fața garajului, gazon, cutie poștală, gard, copaci și lumină caldă la verandă. Spațiul interior a fost prelungit spre spate cu 1,6 unități pentru ca baia și camera cu canapeaua să respire. Acoperișul rămâne doar pe conturul exterior.

Loot-ul este distinct în această locație, fără două obiecte de același tip. Living: televizor (singurul obiect furabil de pe măsuță), scaun, bust de aur. Garaj: dulap de scule, imprimantă. Bucătărie: frigider. Baie: toaletă, cadă. Camera din spate: canapea. Măsuța TV, mașina și celelalte propsuri sunt decor și rămân la locul lor. Toate cele nouă obiecte însumează 25 cargo și $2.260. Camera din spate este destinația greedy; garajul și bucătăria oferă rute de mijloc.

Obiectivul semnătură House cere canapeaua. CLIENT ORDER cere canapea + cadă + bust; celelalte reguli de progresie nu sunt schimbate. Vanul este orientat cu spatele spre intrare în fiecare dintre cele opt locații.

Verificare: `tests/test_house_v2.gd`, `tests/test_van_orientation.gd`, `tests/test_suite.gd`, `tests/test_balance_v1.gd`, `tests/test_challenge_v21.gd` și `tests/test_variety_v01.gd` au trecut. Full clear House: 42,25/60 s la MAX; contracte RUSH 22,83/30 s, SMALL VAN 19,72/60 s, CLIENT ORDER 18,48/30 s. Captura reală din joc este [Suburban House](tests/suburban_house_v2.png).
