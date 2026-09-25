# Museum V2 — finalul Chapter 1

Museum nu mai folosește patru camere egale. Intrarea cu trepte, coloane, bannere și ticket desks duce într-o Grand Gallery deschisă; Ancient Gallery, Sculpture Gallery și Security/Storage se ramifică din ea, iar Time Machine domină Special Exhibit în spate. Vanul are spatele spre intrare. Podelele și lumina diferențiază piatra caldă, marmura rece și accentul cyan al exponatului special. Decorul nu blochează traseele.

Inventarul are opt obiecte, $9.700 și 45 cargo: Giant Diamond, două Large Statues, Time Machine, Ancient Relic, Treasure Chest, Small Safe și Security PC. Toilet și piano au fost eliminate. Time Machine cere Strength 5 și Van 20 pentru un full clear. Normal are 80 s; fereastra de alarmă este 24 s numai pentru Normal și Final Job. Contractele își păstrează ferestrele de alarmă separate.

După obiectivele de bani și Giant Diamond, Jobs oferă **Museum Final Job**. Trebuie încărcate toate cele opt obiecte și evadat; rezultatul arată `TIME MACHINE STOLEN`, apoi `PYRAMID UNLOCKED`. Pyramid rămâne blocat până atunci. Salvările vechi care deblocaseră deja Pyramid primesc automat marcajul de Final Job completat, fără pierderea progresului.

Trasee fizice la upgradeuri maxime: full clear 64,17/80 s; Final Job cu Time Machine luată ultima 64,17/80 s; Rush 27,18/35 s; Small Van 17,82/60 s; Client Order 35,52/45 s. Final Job rămâne realizabil și cu Grip, Carry și Noise la nivelul 10: 69,08/80 s. Verificări automate: [trasee](tests/test_museum_route_v2.gd) 11/11 și [Final Job UI](tests/test_museum_final_job_ui.gd) 5/5, plus suitele Jobs 29/29, Challenge V2.1 394/394, Pyramid 98/98, Variety 194/194, Final Job 24/24 și orientare van 8/8. Buildul necesită și un playtest tactil pe telefon.

[Captură portret 720×1280](tests/museum_v2_720x1280.png) · [Captură 450×800](tests/museum_v2_450x800.png) · [Results](tests/museum_final_job_result.png)
