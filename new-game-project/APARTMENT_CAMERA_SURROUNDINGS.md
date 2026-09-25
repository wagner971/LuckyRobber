# Apartment Camera Surroundings — 0.9.27

Apartment are un bloc urban vizual mai mare decât zona jucabilă. Trotuarele laterale, fâșiile de verdeață, clădirile vecine cu ferestre luminate, aleea din spate, strada cu marcaje și felinarele umplu cadrul când camera urmărește personajul. Elementele noi sunt decorative și nu modifică coliziunile sau pozițiile obiectelor. Camera Apartment a coborât de la aproximativ 53° la 46° față de orizontală.

Vigneta de alarmă începe aproape de marginea ecranului și dispare înainte de zona centrală. Pulsul de avertizare este discret, iar alarma activă rămâne clar vizibilă fără să coloreze obiectele în roz.

Capturi verificate la 450×800: [centru](tests/apartment_v2_450x800.png), [stânga](tests/apartment_follow_left_450x800.png), [dreapta](tests/apartment_follow_right_450x800.png), [spate](tests/apartment_follow_rear_450x800.png), [van](tests/apartment_follow_van_450x800.png), [avertisment](tests/hud_warning.png), [alarmă](tests/hud_alarm.png).

Verificări: gameplay 87/87 și HUD 72/72. Aspectul pe un telefon Android real rămâne de verificat.

Builduri 0.9.27: [Windows DEV](../builds/windows/STEAL%20EVERYTHING.exe), [Windows persistent](../builds/windows/STEAL%20EVERYTHING%20Persistent.exe), [Android DEV](../builds/android/steal-everything-debug.apk), [Android persistent](../builds/android/steal-everything-persistent-debug.apk). Android versionCode 44. Varianta DEV continuă să înceapă cu progres resetat, iar cea persistentă păstrează progresul; proiectul a rămas în modul DEV după export.
