# Face Auth App

# Installation
Gulp und NPM müssen global installiert sein: 
1. NPM installieren (plattformabhängig)
2. ```npm install -g gulp```

Daraufhin können die development-dependencies installiert werden:
```npm install```

# Assets
- Libraries werden über bower geladen (siehe bower.json)
- Frontend-Logik wird in CoffeeScript implementiert (app/scripts/**/*.coffee)

Die bower-libraries und CoffeeScript Dateien werden mit Hilfe von gulp (```gulp build```) in das /app-Verzeichnis kopiert und übersetzt.
Die kompilierten JavaScript-Dateien befinden sich in app/assets/js und sollten nicht bearbeitet werden, da diese von gulp überschrieben werden!

In der index.html werden dann die von gulp erstellten Dateien referenziert.

# App starten
Die App kann im Entwicklungsmodus über ```gulp run``` gestartet werden.
# Build & Distribute
Mit Hilfe von ```npm run dist``` wird auf Basis der aktuellen Plattform ein distributable package erstellt.
Dieses distributable package kann nun an die App-Nutzer verteilt werden.

# Rate Limits
Die Microsoft Cognitive Services API hat strikte rate limits auf die Anzahl der Requests, die pro Minute gesendet werden dürfen.

Da der gesamte Registrierungs-Prozess viele Requests benötigt (Gesicht im Snapshot erkennen und identifizieren, eine Person an der API anlegen, drei Snapshots hochladen, Training der Person starten, Traningsstatus abrufen), kann es sein, dass das Rate Limit unter Umständen erreicht wird.

In den meisten Fällen versucht die App diese Situation abzufangen - manchmal muss jedoch der gesamte Registrierungsprozess neugestartet werden, da nicht sichergestellt werden kann, dass z.b. alle Snapshots hochgeladen und in der Cognitive Services API einem Gesicht zugeordnet wurden.