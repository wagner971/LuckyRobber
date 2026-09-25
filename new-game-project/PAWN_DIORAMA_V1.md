# Pawn Diorama V1 — 0.9.26

Amanetul folosește o singură cameră 3D izometrică, fără joystick. Rafturile, obiectele și casa de marcat pot fi apăsate direct; cardul de sub scenă arată detaliile raftului ales. Rafturile prezintă modelele exacte ale obiectelor furate, iar un obiect rar este mutat în vitrina de sticlă. Doi clienți blocky intră și ies; când o vânzare se încheie cât magazinul este deschis, unul pleacă cu modelul obiectului. Grămada de bani de pe tejghea crește odată cu suma disponibilă la casă.

Economia păstrează decizia de după jaf: vânzare imediată, amanet sau păstrare. Patru rafturi sunt disponibile de la început; extensiile existente ajung la șase. Vânzările offline avansează cel mult șase ore și plătesc doar din obiecte furate, deja puse pe raft. La revenire, câștigul nou apare temporar peste dioramă, iar încasarea rămâne o acțiune explicită.

O comandă de client activă cere un obiect găsibil într-o locație deblocată și accesibilă la Strength-ul curent. Predarea consumă numai exemplarele nepuse în decorul Hideout, plătește de două ori valoarea lor obișnuită, apoi generează următoarea comandă. Butonul `FIND IN JOBS` deschide locația deblocată unde se găsește obiectul. Comanda și rotația ei se validează la încărcarea salvării existente, fără migrare de schemă. Reclamele rewarded, negocierea și alte niveluri de magazin nu sunt adăugate în acest pass.

Capturi: [magazin cu marfă 450×800](tests/pawn_diorama_450x800.png), [720×1280](tests/pawn_diorama_720x1280.png).

Verificări: economia și diorama 39/39, gameplay 87/87, Live Menu 50/50, UI V2 25/25, Jobs 49/49 și settlement 14/14, fără eșecuri. Android a fost exportat, dar aspectul pe un telefon real rămâne de verificat.

Builduri 0.9.26: [Windows DEV](../builds/windows/STEAL%20EVERYTHING.exe), [Windows persistent](../builds/windows/STEAL%20EVERYTHING%20Persistent.exe), [Android DEV](../builds/android/steal-everything-debug.apk), [Android persistent](../builds/android/steal-everything-persistent-debug.apk). Android versionCode 43.
