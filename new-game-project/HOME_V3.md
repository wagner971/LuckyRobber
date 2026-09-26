# Home V3 — garaj 3D, Bungee / Lilita One

Ecranul Home urmează macheta de referință; fundalul este o scenă 3D construită în joc (nu o imagine), cu iluminare și color grading proprii.

## Layout (de sus în jos)

1. **Header** partajat cu Jobs (`GameUI.currency_header`): pastile cash (`+` → Daily Wheel) și diamante (`+` → Lucky Shop), roată de setări (`HomeSettings`).
2. **Titlu**: logo-ul furnizat (`assets/ui/home/logo_lucky_robber.png`, `HomeLogo`, respirație lentă), încadrat de Daily Wheel (stânga) și Daily Gift (dreapta) pe discuri de lumină violetă cu o scânteie. Pe ecrane sub 600 px lățime, iconițele scad la 112 px și logo-ul se strânge.
3. **Personajul** pe soclu rotund întunecat cu inel de neon violet, în fața garajului; sub el, o singură linie tap-abilă „NEXT TARGET · …” (`HomeTargetPanel`) care duce la Jobs / shop / Final Job / Rush Hour.
4. **PLAY** galben (Bungee), cu triunghi negru, puls și sclipire.
5. **UPGRADES · GARAGE · LOCKER**: plăci violet cu artă deasupra etichetei (Lilita One), punct roșu când există un upgrade accesibil.
6. **LUCKY METER**: block-ul din referință, „LUCKY METER 67/100”, bară galbenă, „N TOKENS · FULL METER = LUCKY BLOCK”, buton „LUCKY SHOP >”.

## Scena 3D (`scripts/home_showcase_set.gd`, `scripts/menu_character_preview.gd`)

- Garaj de noapte: perete de beton cu panouri, linie de neon violet, ușă de garaj cu lamele în dreapta personajului, pegboard cu scule, lampă fluorescentă suspendată (con de ceață caldă), rafturi metalice cu Lucky Block-uri și lăzi, cutie de scule roșie, stive de anvelope, con de trafic, plantă.
- Lucky Block-urile 3D folosesc `LuckyEffects.model(tint, frame, mark)` cu ramă și „?” galbene, ca în referință.
- Lumini: cheie caldă cu umbre pentru personaj, rim violet, lampa caldă (2,1) + fill pe perete, două omni violete sub rafturi, glow violet sub soclu, benzi emisive de neon. Podeaua: `home_floor.gdshader` (beton închis cu rosturi).
- Grading 2D (`home_showcase_composite.gdshader`): saturație vivid, contrast +14 %, split-tone (umbre violete / lumini calde), vignetă, întunecare jos pentru lizibilitatea UI-ului.
- Vanul și frigiderul nu mai apar pe Home (rămân în Garage/Locker/Upgrades).

Capturi: `tests/home_v3.png` (720×1280) și `tests/home_v3_narrow.png` (450×800), din `tests/capture_home_v3.gd`.
