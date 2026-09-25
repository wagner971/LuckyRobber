# Chapter 2 lock — 0.9.36

Pyramid și Dracula's Castle se deschid numai după finalizarea Museum Final Job. Două obiective Museum fac Final Job-ul disponibil, dar nu deblochează Chapter 2. Salvările fără indicatorul explicit `museum_final_job_completed` păstrează obiectivele și banii, dar accesul anterior la Pyramid/Castle este retras până la completarea Final Job-ului. Butonul DEV maxează în continuare abilitățile și deblochează locațiile disponibile, fără să sară peste această condiție.

Pe pagina Pyramid din Jobs, previzualizarea rămâne întunecată și apare mesajul „COMPLETE MUSEUM TO UNLOCK THIS CHAPTER”, cu buton „GO TO MUSEUM”. Nu există buton Play până la deblocare. După Final Job, pagina devine cardul jucabil obișnuit.

Verificări: UI Jobs, progresie și salvare, acțiunea DEV și rularea Final Job-ului Museum. [Captura ecranului blocat](tests/jobs_chapter_2_teaser.png).
