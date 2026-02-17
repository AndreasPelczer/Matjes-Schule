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

## Phase 2: Quiz-Engine + Ausbilder-UI (NAECHSTER SCHRITT)

- [ ] Xcode-Projekt (.xcodeproj) erstellen (Andreas muss das in Xcode machen)
- [ ] Audio-Dateien hinzufuegen (correct.mp3, wrong.mp3, applaus.wav, click.wav)
- [ ] App kompilieren und Quiz-Flow testen
- [ ] Ausbilder-Login mit persistentem Profil (statt Demo-Login)
- [ ] Klasse erstellen / bearbeiten / loeschen
- [ ] Schueler zu Klasse hinzufuegen (manuell)
- [ ] Fragen-Editor: Neue Fragen erstellen mit 4 Antworten + Erklaerung
- [ ] Fragenkatalog veroeffentlichen (fuer Schueler sichtbar machen)

---

## Phase 3: CoreData-Integration

- [ ] CoreData-Schema definieren (Ausbilder, Klasse, Schueler, Fragenkatalog, AusbilderFrage)
- [ ] Migration von UserDefaults zu CoreData fuer Fortschritte
- [ ] Ausbilder-Profil in CoreData speichern
- [ ] Klassen und Schueler in CoreData speichern
- [ ] Eigene Fragen in CoreData speichern
- [ ] ProgressManager um CoreData-Persistenz erweitern

---

## Phase 4: CloudKit-Sync

- [ ] CloudKit Container konfigurieren
- [ ] CKRecord-Mappings fuer alle Models
- [ ] Schueler-Fortschritte in CloudKit synchronisieren
- [ ] Ausbilder kann Fortschritte aller Schueler sehen
- [ ] Einladungscode-System: Schueler tritt Klasse bei
- [ ] Offline-Faehigkeit: Lokale Aenderungen queuen, bei Verbindung syncen
- [ ] Konfliktloesung bei gleichzeitigen Aenderungen

---

## Phase 5: Export + Reports

- [ ] PDF-Generierung (UIGraphicsPDFRenderer)
- [ ] Einzelner Schueler-Fortschrittsbericht als PDF
- [ ] Klassen-Uebersicht als PDF
- [ ] Schwachstellen-Analyse: Wo hat ein Schueler Luecken?
- [ ] Zertifikat bei bestandener Pruefung (Commis / Bossfight)
- [ ] Export-Teilen via UIActivityViewController (AirDrop, Mail, etc.)

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

1. **Xcode-Projekt fehlt** - Andreas muss `.xcodeproj` in Xcode erstellen und die Swift-Dateien + Ressourcen hinzufuegen
2. **Audio-Dateien fehlen** - correct.mp3, wrong.mp3, applaus.wav, click.wav muessen manuell in Xcode hinzugefuegt werden
3. **Der_junge_Hering.pdf** - Muss fuer BuchReaderView in Resources kopiert werden
4. **App-Icon** - Muss von Andreas erstellt/bereitgestellt werden
5. **Bundle-ID** - Noch festzulegen
6. **CloudKit Container-ID** - Wird in Phase 4 konfiguriert
7. **Demo-Login ersetzen** - AusbilderLoginView hat aktuell einen Demo-Login, muss durch persistentes Profil ersetzt werden
