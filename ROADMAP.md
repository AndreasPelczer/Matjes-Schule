# ROADMAP - Matjes Schulversion (V3)

Letzte Aktualisierung: 2026-02-17

---

## Phase 1: Grundgeruest ✅ ERLEDIGT

- [x] Projektstruktur erstellen
- [x] Models aus V1/V2 portieren (Question, Produkt, Garmethode, Sauce, Exam, LevelProgress)
- [x] Neue V3-Models erstellen (Ausbilder, Klasse, Schueler, Fragenkatalog, SchuelerFortschritt)
- [x] JSON-Ressourcen kopieren (166 Fragen, 134 Produkte, 20 Garmethoden, 20 Saucen)
- [x] Helpers portieren (QuestionLoader, LexikonQuizGenerator, LexikonLoader, ProgressManager, SoundManager)
- [x] ViewModels portieren (GameViewModel, ExamViewModel)
- [x] Auth-Modul erstellen (AusbilderAuthentication - Biometrie + PIN)
- [x] Export-Modul erstellen (FortschrittsExporter - Text-Berichte)
- [x] Views portieren (Quiz: 7 Views, Lexikon: 7 Views, Components: 2 Views)
- [x] Neue Ausbilder-Views erstellen (Login, Dashboard, Klassen, Fragen, Settings)
- [x] App Entry Point (MatjesSchuleApp mit Schueler/Ausbilder-Modus)
- [x] CLAUDE.md und ROADMAP.md schreiben

---

## Phase 2: Quiz-Engine + Ausbilder-UI ✅ ERLEDIGT

- [x] Xcode-Projekt (.xcodeproj) erstellen
- [x] Audio-Dateien hinzufuegen (correct.mp3, wrong.mp3, applaus.wav, click.wav)
- [x] App kompilieren und Quiz-Flow testen
- [x] Ausbilder-Login mit persistentem Profil (statt Demo-Login)
- [x] Klasse erstellen / bearbeiten / loeschen
- [x] Schueler zu Klasse hinzufuegen (manuell)
- [x] Fragen-Editor: Neue Fragen erstellen mit 4 Antworten + Erklaerung
- [x] Fragenkatalog veroeffentlichen (fuer Schueler sichtbar machen)

---

## Phase 3: Persistenz + Ausbilder-Funktionen ✅ ERLEDIGT

- [x] DataStore.swift als zentrale JSON/UserDefaults-Persistenz
- [x] Ausbilder-Registrierung, PIN-Login, persistent
- [x] Klassen erstellen, Schueler hinzufuegen, 6-stellige Einladungscodes
- [x] Schueler: Code eingeben im App (Profil-Tab)
- [x] Dashboard zeigt echte Statistiken
- [x] Fragenkataloge: Ausbilder kann eigene Fragen erstellen

---

## Phase 4: CloudKit-Sync ✅ ERLEDIGT

- [x] CKRecordConvertible-Protokoll fuer alle Models (Ausbilder, Klasse, Schueler, SchuelerFortschritt, Fragenkatalog, AusbilderFrage)
- [x] CloudKitManager mit publicDB fuer alle geteilten Daten
- [x] Generic Save/Fetch/Delete mit CKRecord-Konvertierung
- [x] Schueler-Fortschritte in CloudKit synchronisieren (mit Merge-Strategie)
- [x] Ausbilder kann Fortschritte aller Schueler sehen (syncAllesAusbilder)
- [x] Einladungscode-System: Schueler findet seinen Code via CloudKit
- [x] Offline-Faehigkeit: SyncState queued Aenderungen, verarbeitet bei Verbindung
- [x] Konfliktloesung: Fortschritte werden gemerged (beste Ergebnisse behalten)
- [x] DataStore integriert: Lokal speichern, dann CloudKit im Hintergrund
- [x] Sync-Status-Anzeige im Dashboard (iCloud-Icon) und Einstellungen
- [x] Manueller Sync-Button + Pull-to-Refresh

### CloudKit Architektur

| Komponente | Datei | Funktion |
|---|---|---|
| CKRecordConvertible | CloudKit/CKRecordConvertible.swift | Protocol + Mappings fuer alle 6 Models |
| CloudKitManager | CloudKit/CloudKitManager.swift | Save/Fetch/Delete/BatchSave/Merge |
| SyncState | CloudKit/SyncState.swift | Offline-Queue + Sync-Tracking |
| DataStore | Persistence/DataStore.swift | Lokale Persistenz + CloudKit-Integration |
| AppState | App/AppState.swift | Sync-Trigger bei Login/App-Start |

### Noch von Andreas zu tun fuer CloudKit

1. **CloudKit Container in Xcode aktivieren** (Signing & Capabilities > + CloudKit)
2. **Record Types im CloudKit Dashboard anlegen**: Ausbilder, Klasse, Schueler, SchuelerFortschritt, Fragenkatalog, AusbilderFrage
3. **Indexes anlegen** fuer Queries (ausbilderId, klasseId, schuelerId, einladungsCode, katalogId)

---

## Phase 5: Export + Reports ✅ ERLEDIGT

- [x] PDF-Generierung (UIGraphicsPDFRenderer) mit A4-Layout, Matjes-Branding, orangene Akzentfarbe
- [x] Einzelner Schueler-Fortschrittsbericht als PDF (Level-Details, Sterne, Pruefungen, Schwachstellen)
- [x] Klassen-Uebersicht als PDF (Tabelle aller Schueler, Statistiken, Durchschnittswerte)
- [x] Schwachstellen-Analyse: Level mit 0 Sternen werden rot markiert
- [x] Zertifikat bei bestandener Pruefung (Commis de Cuisine / Kuechenmeister) mit dekorativem Rahmen
- [x] Export-Teilen via ShareLink (AirDrop, Mail, Dateien etc.)
- [x] ExportView mit Segmented Picker (Klassenuebersicht / Schueler-Bericht / Zertifikat)
- [x] Inline-PDF-Vorschau vor dem Teilen
- [x] Export-Button in KlasseDetailView integriert

### Export Architektur

| Komponente | Datei | Funktion |
|---|---|---|
| FortschrittsExporter | Export/FortschrittsExporter.swift | Text- und PDF-Generierung (3 PDF-Typen + Textberichte) |
| ExportView | Views/Ausbilder/ExportView.swift | UI fuer Bericht-Auswahl, Vorschau und ShareLink |
| PDFKitPreview | Views/Ausbilder/ExportView.swift | Inline PDF-Vorschau aus Data |
| PDFKitView | Views/Components/PDFKitView.swift | PDF-Anzeige aus URL |

---

## Spaeter (Nice-to-Have)

- [ ] Push-Benachrichtigungen (Lern-Erinnerungen)
- [ ] Abo-Modell (1 Monat kostenlos, dann monatlich/jaehrlich)
- [ ] Halbjahr 5+6 (IHK-Erweiterung, noch nicht in V1/V2)
- [ ] Ausbilder-Reports (automatische Berichte ans Ausbildungsunternehmen)
- [ ] Statistik-Dashboard mit Diagrammen (Charts Framework)
- [ ] Dark/Light Mode Toggle
- [ ] iPad-Optimierung

---

## Bekannte offene Punkte

1. **Audio-Dateien fehlen** - correct.mp3, wrong.mp3, applaus.wav, click.wav muessen manuell in Xcode hinzugefuegt werden
2. **Der_junge_Hering.pdf** - Muss fuer BuchReaderView in Resources kopiert werden
3. **App-Icon** - Muss von Andreas erstellt/bereitgestellt werden
4. **Bundle-ID** - Noch festzulegen
5. **CloudKit Container-ID** - Muss in Xcode konfiguriert werden (Signing & Capabilities)
6. **CloudKit Record Types + Indexes** - Muessen im CloudKit Dashboard angelegt werden
