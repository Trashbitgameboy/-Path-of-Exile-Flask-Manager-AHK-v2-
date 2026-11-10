✨ Features
🛡️ Zonen-Erkennung: Erkennt dank Log-Überwachung (Client.txt) automatisch, ob du dich in einer Map oder im Hideout / in einer Stadt befindest.

🎛️ Grafische Benutzeroberfläche (GUI): Ein übersichtliches, in dunklen PoE-Farben gehaltenes Interface (Georgia-Schriftart, Dark Theme).

⚙️ Individuelle Steuerung pro Slot:

Aktiv/Inaktiv: Bestimme, welche Flasks überhaupt genutzt werden sollen.

Tastenbelegung: Lege für jeden Slot fest, welche Taste gedrückt werden soll (z. B. 1 bis 5, Q, W, etc.).

Intervall (Sekunden): Einstellbare Wartezeit pro Flask.

Modus-Auswahl: Wähle pro Flask, ob sie in einer Sequenz-Kette nacheinander oder mit einem eigenen Timer (Solo) laufen soll.

💾 Automatisches Speichern: Alle Einstellungen werden in einer lokalen poe_flask_settings.ini gesichert.

⌨️ Hotkeys:

F4 – Makro Ein / Aus schalten

F5 – Einstellungsfenster Ein / Aus blenden

📥 Installation & Voraussetzungen
AutoHotkey v2 muss auf deinem PC installiert sein (Download hier).

Lade dir das Skript (z. B. als poe_flask_manager.ahk) herunter oder kopiere den Quellcode.

Pfad anpassen: Öffne die .ahk-Datei mit einem Editor (z. B. Notepad++) und passe ganz oben den Pfad zu deiner Client.txt an:

AutoHotkey

```global LogPath := "C:\Program Files (x86)\Steam\steamapps\common\Path of Exile\logs\Client.txt"```

(Falls du den Standalone-Client nutzt, gib dort den Pfad zu deinem Installationsordner an).

Starte das Skript per Doppelklick (falls Path of Exile als Administrator läuft, starte das Skript ebenfalls per Rechtsklick als Administrator).
