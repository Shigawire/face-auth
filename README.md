# Face Auth App

Diese Desktopanwendung läuft auf Basis des [Electron-Frameworks](electron.atom.io). 
Mit Hilfe der Microsoft Cognitive Services API kann eine Gesichtserkennungsfunktion genutzt werden, um einen Nutzer 
für abgesicherte Bereiche einer Applikation zu authentifizieren.

Electron-Applikationen sind plattformunabhäng und können unter Windows, Mac und Linux ausgeführt werden, ohne dass für jede Plattform weiterer Programmieraufwand benötigt würde.

Innerhalb der Applikation werden Webtechnologien verwendet, es steht ein vollständiger Chromium-Browser zur Verfügung. Die Face Auth App benutzt dabei [AngularJS-Framework](http://angularjs.org).

# Datenspeicher
Da nur sehr wenig Daten persistiert werden müssen, wird auf eine Datenbankanbindung verzichtet.
Stattdessen wird auf die localStorage-Implementierung des Chromium Browsers zurückgegriffen.

# Getestete Plattformen
Die App wurde unter Windows 7, Windows 10 und MacOS 10.12 getestet.

# Installation
Gulp, Bower und NPM müssen global installiert sein: 
1. NPM installieren (plattformabhängig)
2. ```npm install -g gulp```
3. ```npm install -g bower```

Daraufhin können die Paketabhängigkeiten installiert werden:

```npm install```

# Assets
- Libraries werden über bower geladen ```bower install``` (siehe bower.json für Pakete)
- Frontend-Logik wird in CoffeeScript implementiert (app/scripts/**/*.coffee)

Die bower-libraries und CoffeeScript Dateien werden mit Hilfe von gulp (```gulp build```) in das /app-Verzeichnis kopiert und übersetzt.
Die kompilierten JavaScript-Dateien befinden sich in app/assets/js und sollten nicht bearbeitet werden, da diese von gulp überschrieben werden!

In der index.html werden die von gulp erstellten JavaScript Dateien referenziert.

Während des Kompilierungsprozesses von CoffeeScript zu JavaScript werden die Kommentare am Quellcode nicht inkludiert - eine 
kommentierte Fassung des Codes befindet sich daher ausschließlich in den CoffeeScript-Dateien.

# App starten
Die Electron-App kann im Entwicklungsmodus über ```gulp run``` gestartet werden.

# Build & Distribute
Mit Hilfe von ```npm run dist``` wird auf Basis der aktuellen Plattform ein distributable package erstellt.
Dieses distributable package kann nun an die App-Nutzer verteilt werden.

Um eine spezifische Plattform anzugeben, können Argumente an das build-script übergeben werden:
Das folgende Kommando erzeugt eine portable Windows-Executable
```
    npm run dist -- --win portable
```

Für OSX:
```
    npm run dist -- --mac
```

# Rate Limits
Die Microsoft Cognitive Services API hat strikte rate limits auf die Anzahl der Requests, die pro Minute gesendet werden dürfen.

Da der gesamte Registrierungs-Prozess viele Requests benötigt (Gesicht im Snapshot erkennen und identifizieren, eine Person an der API anlegen, drei Snapshots hochladen, Training der Person starten, Traningsstatus abrufen), kann es sein, dass das Rate Limit unter Umständen erreicht wird.

In den meisten Fällen versucht die App diese Situation abzufangen - manchmal muss jedoch der gesamte Registrierungsprozess neugestartet werden, da nicht sichergestellt werden kann, dass z.b. alle Snapshots hochgeladen und in der Cognitive Services API einem Gesicht zugeordnet wurden.

# Ablauf der Applikation
## Konfiguration
Zunächst müssen in den Einstellungen der Anwendung der Microsoft Cognitive Services API Key hinterlegt und eine 
personGroup definiert werden. Die personGroup dient dazu, die erstellten Gesichter und Personen in Gruppen abzuspeichern.

## Registrierung
Damit eine Autorisierung mittels Gesichtserkennung möglich ist, muss sich ein Nutzer zuvor in der App registrieren.
Dazu müssen drei Fotos mit der Webcam erstellt werden, auf denen ein Gesicht erkannt werden kann.
Mehrfachregistrierungen mit dem selben Gesicht sind nicht möglich.

## Authentifizierung
Nachdem ein Nutzer registriert ist, kann dieser sich per Gesichtserkennung authentifizieren.