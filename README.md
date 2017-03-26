# Face Auth App

# Installation
Gulp und NPM müssen global installiert sein: 
1. NPM installieren (plattformabhängig)
2. ```npm install -g gulp```

Daraufhin können die development-dependencies installiert werden:
```npm install```

# Assets
- Libraries werden über bower geladen (siehe bower.json)
- Frontend-Logik wird in CoffeeScript implementiert

Die bower-libraries und CoffeeScript Dateien werden mit Hilfe von gulp gulp (```gulp build```) in das /app-Verzeichnis kopiert und übersetzt.

In der index.html werden dann die von gulp erstellten Dateien referenziert.

# App starten
Die App kann im Entwicklungsmodus über ```gulp run``` gestartet werden.
# Build & Distribute
Mit Hilfe von ```npm run dist``` wird auf Basis der aktuellen Plattform ein distributable package erstellt.
Dieses distributable package kann nun an die App-Nutzer verteilt werden.