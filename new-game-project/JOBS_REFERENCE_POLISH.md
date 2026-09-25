# Jobs Reference Polish — 0.9.23

Ecranul Jobs a fost ajustat după imaginea de referință din 23 septembrie 2026. Headerul are wallet-ul și Settings în carduri separate; chapter-ul, preview-ul mare, cele trei statistici, bara vanului, obiectivele, butoanele și navigarea folosesc proporțiile și ierarhia din poză. Preview-ul Apartment folosește decupajul ilustrației furnizate de utilizator, fără elemente statice de UI în afara cardului. Celelalte locații își păstrează ilustrațiile existente.

Stările nefinalizate și blocate păstrează acțiunile și explicațiile existente. Obiectivele revendicate au card verde și `CLAIMED`, iar Final Job pregătit are card auriu și butonul `PLAY FINAL JOB`. Swipe-ul și punctele de paginație continuă să selecteze câte un singur nivel. Nu s-au modificat regulile de gameplay sau salvarea.

Verificare: [Final Job pregătit](tests/jobs_final_ready.png), [Apartment la început](tests/jobs_apartment.png), [Van insuficient](tests/jobs_van_blocked.png), [House blocat](tests/jobs_house_locked.png). Jobs 49/49 la 450×800, 720×1280 și 720×1600; Museum Final Job UI 6/6; testul de bază 87/87; UI V2 25/25 și Live Menu 50/50. O nepotrivire din testul UI V2 a fost corectată pentru mesajul actual `POLICE IN Ns` introdus în 0.9.22.

Builduri 0.9.23: [Windows DEV](../builds/windows/STEAL%20EVERYTHING.exe), [Windows persistent](../builds/windows/STEAL%20EVERYTHING%20Persistent.exe), [Android DEV](../builds/android/steal-everything-debug.apk), [Android persistent](../builds/android/steal-everything-persistent-debug.apk). Ambele APK-uri au versionCode 40, au fost semnate și verificate; ambele executabile Windows pornesc fără eroare de script. Setarea proiectului a fost restaurată la `development.enabled=true` după exportul persistent.
