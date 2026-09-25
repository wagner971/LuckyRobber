# Money Reward VFX — 0.7.0

Efectul de încărcare în dubă folosește acum mici bundle-uri 3D procedurale, nu cele patru OBJ-uri mari proiectate către HUD. Modelul OBJ furnizat rămâne disponibil în prezentările din meniu și rezultate. Noul VFX nu citește, nu acordă și nu schimbă valoarea loot-ului; `RunManager.commit_load()` păstrează singura actualizare economică.

Fiecare `CashPiece3D` are trei `BoxMesh`: corp verde închis cu grosime 0,024, față verde deschis și bandă crem în relief. Dimensiunea corpului este 0,30 × 0,024 × 0,14 unități. Mesh-urile folosesc materiale 3D reale, fără Sprite3D, billboard, coliziune sau umbre. Se rotesc pe toate cele trei axe.

| Valoare încărcată | Bundle-uri cosmetice |
|---|---:|
| Sub $150 | 9 |
| $150–$499 | 12 |
| $500–$1499 | 16 |
| $1500 și peste | 19 |

`MoneyBurstOrigin` se află pe dubă, deasupra zonei de încărcare. Bundle-urile pornesc de acolo, ies radial până la aproximativ 0,8–1,3 unități în 0,27 s, apoi plutesc 0,08 s. În următoarele 0,40 s accelerează pe curbe ușor diferite către poziția **actuală** a `PlayerMoneyMagnetAnchor`, pe torso. Întârzierea inițială maximă este 0,045 s, deci efectul se termină în aproximativ 0,80 s. Piesele se micșorează spre final și reintră în pool.

Controllerul are maxim 40 de piese active în total, inclusiv burst-uri suprapuse. Dacă limita se atinge, refolosește până la șase piese din cel mai vechi burst și reduce doar numărul vizual; suma încărcată rămâne exactă. Pool-ul este reutilizat în aceeași rundă și dispare odată cu nivelul. Pauza îngheață animația. Finalul rundei curăță piesele active.

`+$valoare` este un singur panou verde cu contur negru și fundal rotunjit lângă dubă; urcă și dispare. VAN LOOT face un count-up de 0,30 s fără a schimba suma reală, apoi pulsează la absorbția ultimei piese. Sunetul de load/WHAM existent rămâne; cue-ul `cash_collect` rulează o singură dată la finalul fiecărui burst vizibil.

Validare: `tests/test_money_reward_vfx.gd` — 40 verificări trecute pentru $50, $340, $1000, $1500 și $2500, volum 3D, origine, rază, rotație, mișcarea playerului, pool, suprapuneri, limită, pauză, rundă nouă și separarea economiei. `test_onboarding.gd` — 73 verificări; `test_gameplay_hud.gd` — 68; `test_suite.gd` — 78; `test_onboarding_route.gd` — 5. Capturi portret în `tests/money_reward_50.png`, `_340.png`, `_1000.png`, `_2500.png` și `tests/onboarding_cash_burst.png`, `onboarding_cash_magnet.png`. Modelul izolat, cu grosime și bandă vizibile, este în `tests/money_reward_model_detail.png`.

Limită rămasă: captura automată demonstrează plasarea și curățarea efectului, dar senzația tactilă, lizibilitatea și performanța pe un telefon fizic trebuie încă verificate. Haptics sunt implementate în Satisfying Pass V1, dar neverificate fizic pe Android.
