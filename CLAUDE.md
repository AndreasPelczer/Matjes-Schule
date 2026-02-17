# CLAUDE.md - Pflichtlektuere fuer jede neue Claude-Session

> **LIES DIESE DATEI KOMPLETT BEVOR DU IRGENDETWAS TUST.**
> Diese Datei ist das Gedaechtnis des Projekts. Sie ersetzt das Onboarding.

---

## 1. Was ist dieses Projekt?

**"Matjes, der kleine Hering" - Schulversion (V3)**

Eine eigenstaendige iOS-App fuer Berufsschulen und Ausbilder im Koch/Koechin-Beruf (IHK).
Ausbilder koennen Klassen verwalten, Schueler-Fortschritte verfolgen und eigene Fragen erstellen.
Die Schueler spielen das Matjes-Quiz (identisch mit V1/V2) und ihre Fortschritte werden via CloudKit synchronisiert.

### Die 3 Versionen von Matjes

| Version | Zielgruppe | Status | Repo |
|---------|-----------|--------|------|
| **V1 - Kostenlos** | Azubis (1. Lehrjahr) | Im App Store | `AndreasPelczer/AusbildungsSpielKoch` |
| **V2 - Einzelperson** | Azubis (alle Lehrjahre) | In Entwicklung | `AndreasPelczer/AusbildungsSpielKoch` |
| **V3 - Schulen** | Berufsschulen, Ausbilder | **DIESES REPO** | `AndreasPelczer/Matjes-Schule` |

### Architektur-Entscheidungen (festgelegt am 2026-02-17)

| Entscheidung | Ergebnis |
|---|---|
| **Architektur** | Frisches Projekt, beste Teile aus V1/V2 + Gastro-Grid |
| **Backend** | CloudKit |
| **App-Trennung** | Eigenstaendige App (getrennt von V1/V2) |
| **Aus Gastro-Grid** | Employee/Auth + Export (PDF) |
| **Was NICHT** | Kein Kernel/TheBrain, kein Event-Sourcing, kein HACCP |

---

## 2. NAMENSREGELN - KRITISCH

### Verbotene Namen

| Verboten | Warum |
|----------|-------|
| `millonen` / `millonen.xcodeproj` | Alter Xcode-Projektname |
| `KitchenMillionaire` | Alter Codename |
| `Codiclodi` | Alter Arbeitsname |
| `iMOPS-Gastro-Grid` | Anderes Projekt (Kuechenmanagement) |

### Korrekte Benennung

| Kontext | Name |
|---------|------|
| **In der UI / App Store** | "Matjes, der kleine Hering" oder "Matjes" |
| **Untertitel** | "Das Ausbildungsspiel der Kueche" |
| **V3-Zusatz** | "Profi-Edition" oder "Schulversion" |
| **Swift-Modul** | `MatjesSchule` |
| **Bundle-ID** | (noch festzulegen) |

---

## 3. Projektstruktur

```
Matjes-Schule/
├── CLAUDE.md                            ← DIESE DATEI
├── ROADMAP.md                           ← Entwicklungsplan
├── README.md                            ← Projekt-Beschreibung
├── _legacy/                             ← Alte Gastro-Grid-Dateien (nur Referenz)
│
└── MatjesSchule/                        ← Hauptprojekt
    ├── App/
    │   ├── MatjesSchuleApp.swift         ← App Entry Point
    │   └── AppState.swift                ← Globaler Zustand (Schueler/Ausbilder)
    │
    ├── Models/
    │   ├── Question.swift                ← Quiz-Fragen (aus V1/V2)
    │   ├── LevelProgress.swift           ← Sterne pro Level (aus V1/V2)
    │   ├── Produkt.swift                 ← Lebensmittel (aus V1/V2)
    │   ├── Garmethode.swift              ← Garmethoden (aus V1/V2)
    │   ├── Sauce.swift                   ← Saucen & Fonds (aus V1/V2)
    │   ├── Exam.swift                    ← Pruefungskonfiguration (aus V1/V2)
    │   ├── Ausbilder.swift               ← NEU: Ausbilder-Profil
    │   ├── Klasse.swift                  ← NEU: Klassenverwaltung
    │   ├── Schueler.swift                ← NEU: Schueler/Azubi
    │   ├── Fragenkatalog.swift           ← NEU: Eigene Fragen
    │   └── SchuelerFortschritt.swift     ← NEU: Fortschritt pro Schueler
    │
    ├── ViewModels/
    │   ├── GameViewModel.swift           ← Quiz-Logik (aus V1/V2)
    │   └── ExamViewModel.swift           ← Pruefungs-Logik (aus V1/V2)
    │
    ├── Helpers/
    │   ├── QuestionLoader.swift          ← JSON-Fragen laden (aus V1/V2)
    │   ├── LexikonQuizGenerator.swift    ← Bloom-Taxonomie Generator (aus V1/V2)
    │   ├── LexikonLoader.swift           ← Lexikon-Daten laden (aus V1/V2)
    │   ├── ProgressManager.swift         ← Fortschrittsverwaltung (aus V1/V2)
    │   └── SoundManager.swift            ← Audio + Haptics (aus V1/V2)
    │
    ├── Auth/
    │   └── AusbilderAuthentication.swift ← Biometrie + PIN (aus Gastro-Grid)
    │
    ├── Export/
    │   └── FortschrittsExporter.swift    ← PDF-Berichte (aus Gastro-Grid)
    │
    ├── CloudKit/
    │   └── CloudKitManager.swift         ← CloudKit-Sync (Phase 4)
    │
    ├── Views/
    │   ├── SchuelerTabView.swift         ← Tab-Navigation Schueler
    │   ├── AusbilderTabView.swift        ← Tab-Navigation Ausbilder
    │   ├── Quiz/                         ← Quiz-Views (aus V1/V2)
    │   │   ├── StartScreenView.swift
    │   │   ├── LevelGridView.swift
    │   │   ├── LevelGameView.swift
    │   │   ├── ResultView.swift
    │   │   ├── ExamGameView.swift
    │   │   ├── ExamResultView.swift
    │   │   └── BuchReaderView.swift
    │   ├── Lexikon/                      ← Lexikon-Views (aus V1/V2)
    │   │   ├── LexikonHomeView.swift
    │   │   ├── ProduktListView.swift
    │   │   ├── ProduktDetailView.swift
    │   │   ├── GarmethodeListView.swift
    │   │   ├── GarmethodeDetailView.swift
    │   │   ├── SauceListView.swift
    │   │   └── SauceDetailView.swift
    │   ├── Ausbilder/                    ← NEU: Ausbilder-Views
    │   │   ├── AusbilderLoginView.swift
    │   │   ├── AusbilderDashboardView.swift
    │   │   ├── KlassenListView.swift
    │   │   ├── KlasseDetailView.swift
    │   │   ├── FragenkatalogView.swift
    │   │   └── AusbilderSettingsView.swift
    │   └── Components/                   ← Wiederverwendbare Komponenten
    │       ├── AnswerButton.swift
    │       └── PDFKitView.swift
    │
    ├── Resources/                        ← JSON-Daten (aus V1/V2)
    │   ├── Matjes_Fragen_Level1-11.json  ← 166 handkuratierte Fragen
    │   ├── Koch_Produkte.json            ← 134 Produkte
    │   ├── Koch_Garmethoden.json         ← 20 Garmethoden
    │   ├── Koch_Saucen.json              ← 20 Saucen
    │   ├── Koch_Lexikon.json             ← Lexikon-Referenz
    │   ├── Koch_Pruefungskonzept.json    ← Pruefungsstruktur
    │   └── Audio/                        ← Sound-Dateien (von Andreas manuell)
    │
    └── Persistence/                      ← CoreData (Phase 3+4)
```

---

## 4. Technische Basis

| Feld | Wert |
|------|------|
| **Sprache** | Swift / SwiftUI |
| **Architektur** | MVVM |
| **iOS-Minimum** | 17.0 |
| **Persistenz** | UserDefaults (jetzt), CoreData + CloudKit (Phase 3+4) |
| **Backend** | CloudKit (geplant) |
| **Externe Abhaengigkeiten** | Keine |
| **Ersteller** | Andreas Pelczer |
| **Team-ID** | F75D7PGFTD |

---

## 5. Was aus V1/V2 kommt (portiert)

- **166 handkuratierte Fragen** (Level 1-11, JSON)
- **~400 auto-generierte Fragen** (Level 12-20, Bloom-Taxonomie)
- **134 Produkte, 20 Garmethoden, 20 Saucen** (Lexikon)
- **Sterne-System** (0-3 Sterne pro Level)
- **20 Level in 4 Halbjahren** (je 5 Level)
- **2 Pruefungen** (Commis-Pruefung + Bossfight)
- **GameViewModel + ExamViewModel** (Quiz-Logik)
- **Alle Lexikon-Views** (Produkte, Garmethoden, Saucen)
- **AnswerButton** (animiert, mit Shake/Bounce)
- **Konfetti-Effekt** (bei 3 Sternen / Pruefung bestanden)

## 6. Was aus Gastro-Grid kommt (angepasst)

- **AusbilderAuthentication** (Biometrie + PIN, vereinfacht)
- **FortschrittsExporter** (Text-Berichte, spaeter PDF)

## 7. Was NEU ist (V3-spezifisch)

- **Ausbilder-Login** (via AusbilderLoginView)
- **2 Modi** (Schueler-Tab vs. Ausbilder-Tab)
- **Klassen-/Schueler-Verwaltung** (Models + Views)
- **Eigene Fragenkataloge** (Ausbilder kann Fragen erstellen)
- **SchuelerFortschritt** (Fortschritts-Tracking pro Schueler)
- **FortschrittsExporter** (Berichte als Text/PDF)
- **CloudKitManager** (Platzhalter fuer Phase 4)

---

## 8. Entwicklungsphasen

| Phase | Inhalt | Status |
|-------|--------|--------|
| **Phase 1** | Grundgeruest: Projektstruktur, Models, Helpers, Views portieren | ERLEDIGT |
| **Phase 2** | Quiz-Engine testen, Ausbilder-Views vervollstaendigen | NAECHSTER SCHRITT |
| **Phase 3** | CoreData + Ausbilder-Funktionen (Klassen, Schueler, Fragen) | Offen |
| **Phase 4** | CloudKit-Integration (Sync Fortschritte, Einladungscodes) | Offen |
| **Phase 5** | Export (PDF-Berichte, Zertifikate) | Offen |

---

## 9. Git-Workflow

### WICHTIGSTE REGEL
Andreas kennt kein Git und will kein Git lernen.
Wenn Andreas ein Git-Problem hat: **MAXIMAL EINEN einzigen Befehl** zum Kopieren.

### Claudes Workflow

```
1. git fetch origin main
2. git merge origin/main
3. Aufgabe erledigen
4. Commit + Push auf claude/-Branch
5. PR erstellen: gh pr create --base main --title "..." --body "..."
6. Andreas den PR-Link geben → er klickt "Merge"
7. Andreas holt sich den Stand: git pull origin main
```

### Wenn Andreas lokale Aenderungen pushen will

```bash
git add -A && git commit -m "Update" && git push origin HEAD:main
```

---

## 10. Naechste Aufgabe fuer den neuen Chat

1. **Xcode-Projekt erstellen** - Andreas muss in Xcode ein neues Projekt "MatjesSchule" anlegen und die Dateien aus MatjesSchule/ hinzufuegen
2. **Quiz testen** - Laeuft der Quiz-Teil (StartScreen → Level → Fragen → Ergebnis)?
3. **Ausbilder-Login testen** - Funktioniert der Demo-Login?
4. **Phase 2 starten** - Ausbilder-Views vervollstaendigen, CoreData vorbereiten

---

## 11. Kontakt & Entscheidungen

* **Bilder/Icons/Assets**: Immer Andreas fragen
* **Code-Struktur**: Claude kann eigenstaendig entscheiden (MVVM beibehalten)
* **Neue Features**: Mit Andreas absprechen
* **Destructive Git-Ops**: Niemals ohne explizite Erlaubnis
* **Backend-Wahl**: CloudKit (entschieden)

---

## 12. _legacy/ Verzeichnis

Das `_legacy/` Verzeichnis enthaelt die originalen Gastro-Grid-Dateien als Referenz.
Diese werden NICHT kompiliert und NICHT in die App eingebunden.
Sie dienen nur als Nachschlagewerk fuer:
- EventSourcing-Patterns (falls spaeter benoetigt)
- HACCP-Exporter als Vorlage fuer FortschrittsExporter
- CoreData-Models als Referenz fuer Phase 3

**NIEMALS Dateien aus _legacy/ direkt verwenden oder importieren.**

---

Erstellt: 2026-02-17
Von: Claude-Session (Setup V3 Schulversion)
Zweck: Projektgedaechtnis fuer alle zukuenftigen Claude-Sessions
