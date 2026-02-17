# Matjes, der kleine Hering - Schulversion
## Briefing fuer Ausbilder und Lehrkraefte

---

### Was ist Matjes?

**Matjes** ist eine Lern-App fuer Azubis im Beruf Koch/Koechin (IHK).
Die Schulversion ermoeglicht es Ihnen als Ausbilder, den Lernfortschritt Ihrer Klasse zu verfolgen und eigene Pruefungsfragen zu erstellen.

Die App enthaelt:
- **566 Quizfragen** in 20 Leveln (sortiert nach Lehrjahr)
- **Lexikon** mit 134 Produkten, 20 Garmethoden und 20 Saucen
- **2 Pruefungssimulationen** (Commis-Pruefung + Abschlusspruefung)
- **Fortschritts-Dashboard** fuer Ihre Klasse

---

### Wie funktioniert es in der Klasse?

#### Schritt 1: Geraete vorbereiten

Jeder Schueler braucht ein iPad oder iPhone mit der App "Matjes - Schulversion".
Sie koennen Schul-iPads oder private Geraete der Schueler nutzen.

> **Tipp:** Schul-iPads muessen mit einem Apple-Account angemeldet sein, damit die Cloud-Synchronisation funktioniert. Ein gemeinsamer Schul-Account reicht NICHT - jedes Geraet braucht einen eigenen iCloud-Account fuer die Zuordnung.

#### Schritt 2: Als Ausbilder anmelden

1. Oeffnen Sie die App auf **Ihrem** Geraet
2. Tippen Sie auf den Tab **"Ausbilder"** (ganz rechts)
3. Geben Sie Ihre **4-stellige PIN** ein oder nutzen Sie **Face ID / Touch ID**
4. Sie sehen jetzt das **Ausbilder-Dashboard**

#### Schritt 3: Klasse anlegen

1. Gehen Sie zum Tab **"Klassen"**
2. Tippen Sie auf **"Neue Klasse"**
3. Geben Sie ein:
   - Klassenname (z.B. "Koch 2025/A")
   - Lehrjahr (1, 2 oder 3)
   - Schuljahr (z.B. "2025/2026")
4. Tippen Sie auf **"Erstellen"**

#### Schritt 4: Schueler hinzufuegen

1. Oeffnen Sie Ihre Klasse
2. Tippen Sie auf **"Schueler hinzufuegen"**
3. Geben Sie Vor- und Nachname ein
4. Die App generiert automatisch einen **6-stelligen Einladungscode** (z.B. `K7X2M9`)
5. Geben Sie jedem Schueler seinen persoenlichen Code

> **Wichtig:** Jeder Schueler hat einen eigenen Code. Verteilen Sie die Codes z.B. auf Karteikarten oder per Klassenliste.

#### Schritt 5: Fortschritte verfolgen

Im **Dashboard** sehen Sie auf einen Blick:
- Welcher Schueler welches Level erreicht hat
- Wie viele Sterne pro Level (0-3)
- Wer die Pruefungen bestanden hat
- Wer Hilfe braucht (wenig Fortschritt)

---

### Haeufige Fragen

**Brauchen die Schueler einen eigenen Account?**
Nein. Die Schueler geben nur einmalig ihren 6-stelligen Code ein. Kein Passwort, keine E-Mail.

**Was passiert, wenn ein iPad kaputt geht oder ausgetauscht wird?**
Der Schueler gibt seinen Code auf dem neuen Geraet ein. Sein gesamter Fortschritt ist in der Cloud gespeichert und wird automatisch wiederhergestellt.

**Funktioniert die App ohne Internet?**
Ja. Die Schueler koennen offline Quiz spielen und im Lexikon lesen. Sobald wieder Internet da ist, synchronisiert sich der Fortschritt automatisch.

**Kann ich eigene Fragen erstellen?**
Ja. Im Tab "Fragen" koennen Sie eigene Fragenkataloge erstellen, z.B. fuer bestimmte Themen oder als Vorbereitung auf Pruefungen. Diese Fragen werden nur Ihrer Klasse angezeigt.

**Kann ich mehrere Klassen gleichzeitig betreuen?**
Ja. Sie koennen beliebig viele Klassen anlegen und zwischen ihnen wechseln.

**Kann ich Berichte ausdrucken?**
Ja. Im Dashboard koennen Sie Fortschrittsberichte als PDF exportieren - z.B. als Nachweis fuer die IHK oder fuer Elterngespraeche.

**Kann ich mich auf mehreren Geraeten anmelden?**
Ja. Ihre Daten werden ueber iCloud synchronisiert. Sie koennen z.B. in der Schule das iPad und zuhause das iPhone nutzen.

---

### Die 20 Level im Ueberblick

| Halbjahr | Level | Themen |
|----------|-------|--------|
| **1. Halbjahr** | Level 1-5 | Grundlagen: Hygiene, Schneidetechniken, Grundprodukte |
| **2. Halbjahr** | Level 6-10 | Aufbau: Garmethoden, Saucen, Beilagen |
| **3. Halbjahr** | Level 11-15 | Vertiefung: Menuekunde, Kalkulation, Warenkunde |
| **4. Halbjahr** | Level 16-20 | Pruefungsvorbereitung: Komplexe Fragen, Fachgespraeche |

Nach Level 15 gibt es die **Commis-Pruefung** (Zwischenpruefung).
Nach Level 20 kommt der **Bossfight** (Abschlusspruefung).

---

### Sterne-System

| Sterne | Bedeutung | Fehler erlaubt |
|--------|-----------|----------------|
| ⭐⭐⭐ | Perfekt! | 0-1 Fehler |
| ⭐⭐ | Gut | 2-3 Fehler |
| ⭐ | Bestanden | 4-5 Fehler |
| - | Nicht bestanden | 6+ Fehler |

---

### So sieht der Ablauf aus

```
                    ┌─────────────────────────────┐
                    │     Ausbilder (Sie)          │
                    │                              │
                    │  1. Klasse anlegen           │
                    │  2. Schueler eintragen       │
                    │  3. Codes verteilen          │
                    │  4. Fortschritte beobachten  │
                    │  5. Berichte exportieren     │
                    └──────────────┬──────────────┘
                                   │
                          ☁ iCloud / CloudKit
                                   │
          ┌────────────────────────┼────────────────────────┐
          │                        │                        │
   ┌──────┴──────┐         ┌──────┴──────┐         ┌──────┴──────┐
   │  Schueler 1 │         │  Schueler 2 │         │  Schueler 3 │
   │  Code: K7X2M9│        │  Code: P3R8N4│        │  Code: W5T1L6│
   │             │         │             │         │             │
   │  Quiz spielen│        │  Quiz spielen│        │  Quiz spielen│
   │  Lexikon     │        │  Lexikon     │        │  Lexikon     │
   │  lesen       │        │  lesen       │        │  lesen       │
   └─────────────┘         └─────────────┘         └─────────────┘
```

---

### Technische Voraussetzungen

| Anforderung | Details |
|-------------|---------|
| **Geraete** | iPad oder iPhone |
| **iOS-Version** | iOS 17.0 oder neuer |
| **Internet** | Fuer Ersteinrichtung und Sync (danach auch offline nutzbar) |
| **iCloud** | Muss auf dem Geraet aktiviert sein |
| **Speicher** | Ca. 50 MB |

---

### Hilfe & Kontakt

Bei Fragen oder Problemen wenden Sie sich an:

**Andreas Pelczer** - Entwickler
📧 (Kontakt wird ergaenzt)

---

*Matjes, der kleine Hering - Das Ausbildungsspiel der Kueche*
*Schulversion / Profi-Edition*
