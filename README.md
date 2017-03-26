# Face Auth App

# Assets
- Libraries werden über bower geladen (siehe bower.json)
- Frontend-Logik wird in CoffeeScript implementiert

Die bower-libraries und CoffeeScript Dateien werden mit Hilfe von gulp gulp (```gulp build```) in das /app-Verzeichnis kopiert und übersetzt.

In der index.html werden dann die von gulp erstellten Dateien referenziert.
