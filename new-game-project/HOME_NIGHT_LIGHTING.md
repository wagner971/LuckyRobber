# Home Night Lighting — 0.9.25

Preview-ul 3D din Home folosește acum ambient albastru, o lumină caldă de sus în direcția felinarelor, reflex cald dinspre garaj și contur cyan din spate. Tonemapping Filmic și un color grade discret în preview temperează albul frigiderului și dungilor, precum și galbenul vanului, fără a modifica materialele cosmetice sau lumina din gameplay. Platforma are o muchie cu emisie slabă și o umbră 3D transparentă sub picioarele personajului.

Fundalul este estompat foarte ușor și întunecat cu un shader 2D. Logo-ul a fost coborât ca să nu atingă wallet-ul în portrait. Efectele folosite au fost verificate în Godot 4.7.1 cu rendererul Compatibility; nu sunt necesare SSAO sau contact shadows dependente de Forward+.

Capturi: [450×800](tests/home_reference_450x800.png), [720×1280](tests/home_v2_next_target.png), [720×1100](tests/home_v2_compact.png).

Verificări: Home 26/26, Live Menu 50/50, randare naturală 10/10, gameplay 87/87, toate fără eșecuri. APK-ul Android rămâne de verificat vizual pe un telefon real.

Builduri 0.9.25: [Windows DEV](../builds/windows/STEAL%20EVERYTHING.exe), [Windows persistent](../builds/windows/STEAL%20EVERYTHING%20Persistent.exe), [Android DEV](../builds/android/steal-everything-debug.apk), [Android persistent](../builds/android/steal-everything-persistent-debug.apk). Android versionCode 42.
