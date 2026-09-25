# PYRAMID — redesenare vizuală și traseu jucabil

Pyramid este primul nivel din Chapter 2, după Museum. Structura rămâne o piramidă deschisă, văzută de sus, cu Sarcofagul și Anubis în stânga, cuferele în Antechamber, Hall of Gods în dreapta și Tronul la capătul camerei din spate. Masca și Scarabeul stau de o parte și de alta a Tronului; mozaicul solar este pe podea în fața lui. Exteriorul urmează referința vizuală: alee de piatră până la poartă, piloni gravați, gardieni, obeliscuri, terase de gresie, torțe, palmieri și ruine pe nisip albastru la amurg. Intrările și punctul de încărcare al dubei își păstrează coliziunile existente; decorurile noi nu blochează drumul.

## Ce s-a schimbat

- Pardoseli și zone cromatice separate, covor central de lapis cu muchii aurii, coloane, panouri cu glife și mozaic solar în camera funerară. Obiectele sunt mai mari și stau pe socluri sau în grupuri cu rol vizual clar.
- 11 obiecte, cu modele 3D procedurale egiptene: urne canopice, cufere, mască, scarabeu, bust, fragment de obelisc, Anubis, tron și sarcofag. Sarcofagul stă transversal în camera stângă, cu Anubis aproape de el și acces liber la ambele obiecte. Cuferele sunt în centru; Masca și Scarabeul încadrează Tronul din spate.
- Interiorul folosește tonuri reci și accente aurii, cu 16 torțe interioare vizibile, 10 lumini locale active, cinci lumini difuze de încăpere și trei accente pentru obiecte importante. La exterior sunt încă patru torțe vizibile, dintre care două luminează efectiv. Lumina direcțională este doar pentru exterior; luminile locale nu proiectează umbre costisitoare pe mobil.
- Timpul de ridicare pentru Tron și Sarcofag este 1,4 s fiecare. Acestea rămân cele mai grele obiecte. Mutarea Tronului până la capăt a necesitat o fereastră de alarmă de 13 s doar în Pyramid; celelalte locații păstrează 12 s. Timpul rundei, Noise, valorile și costurile de cargo nu au fost schimbate.

## Buget și traseu

| Obiecte | Cargo | Noise | Valoare |
|---|---:|---:|---:|
| 2 urne canopice | 2 | 8 | $600 |
| 2 cufere | 6 | 14 | $1.200 |
| Mască + scarabeu | 4 | 11 | $1.550 |
| Bust + obelisc + Anubis | 17 | 31 | $3.650 |
| Sarcofag + Tron | 15 | 36 | $3.500 |
| **Total** | **44** | **100** | **$10.500** |

Van Capacity 19 oferă exact 44 cargo. Cele nouă obiecte mici și mijlocii însumează 64 Noise, sub pragul de 65. Ridicarea Tronului din capătul camerei din spate declanșează alarma cu 9/11 obiecte deja încărcate; apoi se încarcă Tronul și se ridică Sarcofagul din stânga, aproape de ieșire. Runda NORMAL rămâne la 60 s, iar alarma Pyramid la 13 s. Cele două obiective Museum deblochează Pyramid; obiectivele Pyramid sunt $5.000, Sarcofagul și full clear.

Testul de traseu deplasează efectiv personajul, ridică și încarcă fiecare obiect și verifică evadarea. Cu Strength 5, Grip 1, Carry 1, Van 19, Noise 1, full clear lasă **5,32 s**; cu Grip 8/Carry 8 lasă **5,87 s**, iar cu upgradeuri maxime **6,13 s**. Ridicarea Sarcofagului înaintea Tronului lasă 4,27 s. Ridicarea ambelor piese grele la început pornește alarma prematur și pierde full clear. Un playtest pe telefon rămâne necesar pentru confortul controlului tactil.

Verificare automată: `tests/test_pyramid_v1.gd` (buget, progres, Noise, acces la toate cele 11 obiecte, iluminare și cinci trasee fizice). Capturi: [nivel întreg](tests/pyramid_redesign_full.png), [camera Sarcofagului](tests/pyramid_redesign_treasury.png), [cuferele din mijloc](tests/pyramid_redesign_antechamber.png), [Hall of Gods](tests/pyramid_redesign_hall_of_gods.png), [Tronul și mozaicul](tests/pyramid_redesign_burial.png). Checkpoint înaintea acestei mutări: `../checkpoints/before-pyramid-throne-rearrange`.
