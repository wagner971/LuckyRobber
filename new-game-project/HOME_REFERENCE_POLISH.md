# Home Reference Polish + Natural Rendering — 0.9.24

Home a fost refăcut conform imaginii de referință din 23 septembrie 2026: wallet sus stânga, Settings sus dreapta, logo mare, personajul live în fața vanului, frigider ca obiectiv vizual, platformă 3D, PLAY verde dominant, Upgrades / Collection / Cosmetics în trei carduri egale și Next Target la bază. Navigarea duplicată de jos a fost scoasă din Home. PLAY își păstrează acțiunea contextuală pentru tutorial, Special Job și Final Job; preview-ul live continuă să arate cosmeticele echipate.

Fundalul este [night_warehouse_v1.png](assets/ui/home/night_warehouse_v1.png), generat cu skill-ul imagegen în modul built-in folosind poza utilizatorului ca referință de compoziție. Promptul final a cerut un depozit și o stradă industrială pe timp de noapte, spațiu liber pentru personajul/vanul randate de joc, materiale low-poly cu iluminare cinematică și fără text, UI, personaje, vehicule, platformă sau efect toon. Iconițele celor trei scurtături sunt SVG-uri native ale proiectului.

Filtrul `CameraToonEffect` și shaderul lui au fost eliminate din camera de gameplay și din viewporturile Home, Upgrades, loot, cash și trophies. Nu a fost schimbată geometria blocky a personajului sau regulile de gameplay. Preview-urile Jobs ale celorlalte locații au fost recapturate fără filtru; artul Apartment folosește în continuare ilustrația de referință aprobată anterior.

Capturi: [Home 450×800](tests/home_reference_450x800.png), [Home cu Next Target 720×1280](tests/home_v2_next_target.png), [Home compact](tests/home_v2_compact.png), [Apartment în joc fără toon](tests/apartment_v2_450x800.png).

Verificări: Home V2 0 eșecuri; randare naturală 10/10; Jobs 49/49; gameplay 87/87; Live Menu 50/50; Onboarding 74/74; Gameplay HUD 72/72. Layoutul Home a fost verificat vizual la 450×800, 720×1100 și 720×1280.

Builduri 0.9.24: [Windows DEV](../builds/windows/STEAL%20EVERYTHING.exe), [Windows persistent](../builds/windows/STEAL%20EVERYTHING%20Persistent.exe), [Android DEV](../builds/android/steal-everything-debug.apk), [Android persistent](../builds/android/steal-everything-persistent-debug.apk). Executabilele Windows pornesc fără eroare de script; APK-urile au versionCode 41 și semnătură verificată. `development.enabled=true` a fost restaurat în proiect după exporturile persistente.
