//
//  FortschrittsExporter.swift
//  MatjesSchule
//
//  PDF-Export fuer Schueler-Fortschrittsberichte (V3)
//  Basierend auf HACCPExporter aus Gastro-Grid, angepasst fuer Lernfortschritte.
//

import Foundation

@available(iOS 17.0, *)
struct FortschrittsExporter {

    // MARK: - Textbericht

    /// Generiert einen Fortschrittsbericht als Text fuer einen einzelnen Schueler
    static func generiereSchuelerBericht(
        schueler: Schueler,
        fortschritt: SchuelerFortschritt,
        klasse: Klasse
    ) -> String {
        let df = DateFormatter()
        df.dateFormat = "dd.MM.yyyy"

        var bericht = """
        ══════════════════════════════════════════════════════════
                  MATJES - FORTSCHRITTSBERICHT
                  Sch\u{00FC}ler: \(schueler.vollstaendigerName)
        ══════════════════════════════════════════════════════════

        Klasse: \(klasse.name)
        Lehrjahr: \(klasse.lehrjahr)
        Schuljahr: \(klasse.schuljahr)
        Erstellt am: \(df.string(from: Date()))

        ── \u{00DC}BERSICHT ──────────────────────────────────────────

        Gesamtfortschritt: \(String(format: "%.0f", fortschritt.fortschrittProzent))%
        Gesammelte Sterne: \(fortschritt.gesamtSterne) / \(fortschritt.maxSterne)
        H\u{00F6}chstes Level: \(fortschritt.hoechstesLevel)

        """

        // Level-Details
        bericht += "── LEVEL-FORTSCHRITTE ──────────────────────────────\n\n"

        let halbjahre = [
            (1, "1. Halbjahr (Grundlagen)", 1...5),
            (2, "2. Halbjahr (Warenkunde)", 6...10),
            (3, "3. Halbjahr (Vertiefung)", 11...15),
            (4, "4. Halbjahr (Anwenden)", 16...20)
        ]

        for (_, name, levelRange) in halbjahre {
            bericht += "  \(name):\n"
            for level in levelRange {
                if let lp = fortschritt.levelFortschritte[level] {
                    let sterneText = String(repeating: "\u{2605}", count: lp.stars)
                        + String(repeating: "\u{2606}", count: 3 - lp.stars)
                    let datum = lp.lastPlayed.map { df.string(from: $0) } ?? "-"
                    bericht += "    Level \(String(format: "%2d", level)): \(sterneText) (Fehler: \(lp.bestErrors), Zuletzt: \(datum))\n"
                } else {
                    bericht += "    Level \(String(format: "%2d", level)): ☆☆☆ (noch nicht gespielt)\n"
                }
            }
            bericht += "\n"
        }

        // Pruefungsergebnisse
        bericht += "── PR\u{00DC}FUNGEN ────────────────────────────────────────\n\n"

        if let commis = fortschritt.pruefungsErgebnisse["commis"] {
            bericht += "  Commis-Pr\u{00FC}fung: \(commis.passed ? "BESTANDEN" : "NICHT BESTANDEN")\n"
            bericht += "    Ergebnis: \(String(format: "%.0f", commis.percentage))% (\(commis.correctAnswers)/\(commis.totalQuestions))\n"
            bericht += "    Datum: \(df.string(from: commis.date))\n\n"
        } else {
            bericht += "  Commis-Pr\u{00FC}fung: Noch nicht abgelegt\n\n"
        }

        if let boss = fortschritt.pruefungsErgebnisse["bossfight"] {
            bericht += "  Abschlusspr\u{00FC}fung: \(boss.passed ? "BESTANDEN" : "NICHT BESTANDEN")\n"
            bericht += "    Ergebnis: \(String(format: "%.0f", boss.percentage))% (\(boss.correctAnswers)/\(boss.totalQuestions))\n"
            bericht += "    Datum: \(df.string(from: boss.date))\n\n"
        } else {
            bericht += "  Abschlusspr\u{00FC}fung: Noch nicht abgelegt\n\n"
        }

        // Schwachstellen
        let schwach = fortschritt.schwacheLevel
        if !schwach.isEmpty {
            bericht += "── SCHWACHSTELLEN ─────────────────────────────────\n\n"
            bericht += "  Folgende Level ben\u{00F6}tigen Nacharbeit (0 Sterne):\n"
            for level in schwach {
                bericht += "    - Level \(level)\n"
            }
            bericht += "\n"
        }

        bericht += "── ENDE DES BERICHTS ──────────────────────────────\n"
        bericht += "Generiert: \(Date().description)\n"
        bericht += "System: Matjes Schulversion\n"

        return bericht
    }

    // MARK: - Klassenuebersicht

    /// Generiert eine Klassenuebersicht fuer den Ausbilder
    static func generiereKlassenUebersicht(
        klasse: Klasse,
        schueler: [Schueler],
        fortschritte: [UUID: SchuelerFortschritt]
    ) -> String {
        let df = DateFormatter()
        df.dateFormat = "dd.MM.yyyy"

        var bericht = """
        ══════════════════════════════════════════════════════════
                  MATJES - KLASSEN\u{00DC}BERSICHT
                  Klasse: \(klasse.name)
        ══════════════════════════════════════════════════════════

        Lehrjahr: \(klasse.lehrjahr)
        Schuljahr: \(klasse.schuljahr)
        Anzahl Sch\u{00FC}ler: \(schueler.count)
        Erstellt am: \(df.string(from: Date()))

        ── SCH\u{00DC}LER-\u{00DC}BERSICHT ──────────────────────────────────

        """

        let sortiert = schueler.sorted { $0.nachname < $1.nachname }

        for s in sortiert {
            let fortschritt = fortschritte[s.id]
            let sterne = fortschritt?.gesamtSterne ?? 0
            let prozent = fortschritt?.fortschrittProzent ?? 0
            let hoechstes = fortschritt?.hoechstesLevel ?? 0

            bericht += "  \(s.vollstaendigerName)\n"
            bericht += "    Fortschritt: \(String(format: "%.0f", prozent))% | Sterne: \(sterne)/60 | H\u{00F6}chstes Level: \(hoechstes)\n"

            if let schwach = fortschritt?.schwacheLevel, !schwach.isEmpty {
                bericht += "    Nacharbeit: Level \(schwach.map { String($0) }.joined(separator: ", "))\n"
            }
            bericht += "\n"
        }

        bericht += "── ENDE DER \u{00DC}BERSICHT ──────────────────────────────\n"
        bericht += "System: Matjes Schulversion\n"

        return bericht
    }
}
