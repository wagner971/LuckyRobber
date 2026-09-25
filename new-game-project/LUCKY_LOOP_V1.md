# Lucky Loop V1 — 0.9.85

O singură buclă, nu sisteme separate: **run → juice la pickup/load → Lucky Block (eveniment) sau Lucky Meter plin → escape → reveal → tokens → Lucky Shop → PLAY NOW**.

## Lucky Meter (`scripts/lucky_meter.gd`)

- Fiecare run non-tutorial umple meter-ul: **+15** la escape, **+1/obiect** (max +12), **+10** la un obiectiv nou, **+15** la full clear; un bust adaugă **+5**.
- La **100** primești un Lucky Block garantat (același reveal ca blocul găsit în run). Surplusul rămâne. Dacă există deja un reveal în așteptare, meter-ul stă la 100 și plătește la următorul run.
- Vizibil pe **Home** (panou „LUCKY METER 72/100” cu tokens + buton LUCKY SHOP), pe **Results** (bară animată de la valoarea veche la cea nouă, „LUCKY BLOCK!” când se umple) și în **Lucky Shop**.
- Blocul aleator din run (30%) rămâne bonus peste meter. `LuckyMeter.award_block` este singurul loc care creează un `lucky_pending`, deci blocul din run și cel din meter plătesc identic.

## Lucky Tokens și Lucky Shop (`scripts/lucky_shop.gd`)

- Orice Lucky Block plătește tokens la acordare: **1** pentru un efect pozitiv, **2** pentru unul negativ (ghinionul consolează). Cardul de reveal afișează „+N LUCKY TOKENS”.
- **LUCKY SHOP** (Home → butonul din panoul meter-ului, sau din reveal): recompense permanente, plătite numai în tokens:

| Recompensă | Tip | Preț |
|---|---|---:|
| Gold Block / Neon Block | skin pentru Lucky Block (model în run + reveal) | 3 / 5 |
| Golden Load | culoarea burst-ului de bani la încărcare | 4 |
| Violet Cash | culoarea pop-up-ului „+$” și a ploii de bani din Results | 4 |
| Firework Escape | confetti suplimentar pe Results la escape | 6 |
| Lucky Suit / Lucky Van | cosmetice (`reward: "lucky"` în catalogul existent; apar în wardrobe) | 6 / 10 |
| Upgrade Token | un nivel gratuit la orice stat; shop-ul arată „FREE · TOKEN” și îl consumă primul | 5 (repetabil) |
| 5 Diamonds | pentru shop-ul de cosmetice | 2 (repetabil) |

- Skin-urile/VFX se echipează cu un tap (toggle); cosmeticele se echipează din wardrobe la cumpărare.
- Salvare: schema **17** (`lucky_meter`, `lucky_tokens`, `lucky_owned`, `lucky_equipped`, `upgrade_tokens`, `lucky_blocks_found`, `last_location`), migrare cu backup `.schema16.bak`; validarea taie valorile, elimină ID-uri necunoscute și dez-echipează ce nu este deținut.

## Lucky Block ca eveniment în run

- Blocul are lumină proprie (OmniLight) și pulsează încet; marker-ul „LUCKY BLOCK” este vizibil prin pereți.
- La spawn: sting audio (`special_reveal`), haptic și toast „LUCKY BLOCK ON THE MAP · GRAB IT!”.

## Reveal → următorul run

- Cardul de reveal are **PLAY NOW ▶** (principal) și „GOT IT · BACK” (secundar). PLAY NOW confirmă reveal-ul și pornește imediat ultima locație jucată (`last_location`), fără Jobs.

## Jobs, Upgrades, juice

- **Jobs**: ordinea de citire este acum harta → NEXT TARGET → „$LOOT · ITEMS · TIME” → **PLAY**; capacitatea vanului, loadout-ul și obiectivele urmează ca informație secundară.
- **Upgrades**: fără linia de descriere; nivelul mai mic; un singur rând de beneficiu + preț; formulele rămân la ⓘ.
- **Pickup/Load**: squash-and-stretch pe personaj, micro-kick de cameră la pickup (pe lângă impactul dubei la load), haptic existent, variație de pitch existentă.

## Verificare

`tests/test_lucky_loop.gd`: matematica meter-ului, prioritatea blocului din run, tokens, cumpărături de fiecare tip, upgrade token cu plafon de tier, persistență/validare și settlement real prin `RunManager`.
