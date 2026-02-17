//
//  FortschrittsExporter.swift
//  MatjesSchule
//
//  Text- und PDF-Export fuer Schueler-Fortschrittsberichte und Zertifikate (V3)
//  Basierend auf HACCPExporter aus Gastro-Grid, angepasst fuer Lernfortschritte.
//

import Foundation
import UIKit
import PDFKit

@available(iOS 17.0, *)
struct FortschrittsExporter {

    // MARK: - PDF Konstanten

    private static let pageSize = CGSize(width: 595.28, height: 841.89) // A4
    private static let margin: CGFloat = 50
    private static let contentWidth: CGFloat = 595.28 - 100 // pageSize.width - 2 * margin
    private static let orange = UIColor(red: 1.0, green: 0.6, blue: 0.0, alpha: 1.0)
    private static let darkGray = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
    private static let lightGray = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0)

    private static let df: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "dd.MM.yyyy"
        return f
    }()

    // MARK: - PDF Helper

    private static func titleAttributes(size: CGFloat = 22) -> [NSAttributedString.Key: Any] {
        [.font: UIFont.boldSystemFont(ofSize: size), .foregroundColor: darkGray]
    }

    private static func headingAttributes(size: CGFloat = 14) -> [NSAttributedString.Key: Any] {
        [.font: UIFont.boldSystemFont(ofSize: size), .foregroundColor: orange]
    }

    private static func bodyAttributes(size: CGFloat = 11) -> [NSAttributedString.Key: Any] {
        [.font: UIFont.systemFont(ofSize: size), .foregroundColor: darkGray]
    }

    private static func boldBodyAttributes(size: CGFloat = 11) -> [NSAttributedString.Key: Any] {
        [.font: UIFont.boldSystemFont(ofSize: size), .foregroundColor: darkGray]
    }

    /// Zeichnet den Matjes-Header und gibt die Y-Position danach zurueck.
    private static func zeichneHeader(in context: UIGraphicsPDFRendererContext, titel: String, untertitel: String) -> CGFloat {
        var y: CGFloat = margin

        // Orangener Balken oben
        context.cgContext.setFillColor(orange.cgColor)
        context.cgContext.fill(CGRect(x: 0, y: 0, width: pageSize.width, height: 6))

        // Titel
        let titelRect = CGRect(x: margin, y: y, width: contentWidth, height: 30)
        ("Matjes \u{1F41F} Schulversion" as NSString).draw(in: titelRect, withAttributes: titleAttributes(size: 20))
        y += 28

        // Untertitel
        let subtitelRect = CGRect(x: margin, y: y, width: contentWidth, height: 20)
        (titel as NSString).draw(in: subtitelRect, withAttributes: headingAttributes(size: 16))
        y += 22

        // Detail-Zeile
        let detailRect = CGRect(x: margin, y: y, width: contentWidth, height: 16)
        (untertitel as NSString).draw(in: detailRect, withAttributes: bodyAttributes(size: 10))
        y += 20

        // Trennlinie
        context.cgContext.setStrokeColor(orange.cgColor)
        context.cgContext.setLineWidth(2)
        context.cgContext.move(to: CGPoint(x: margin, y: y))
        context.cgContext.addLine(to: CGPoint(x: pageSize.width - margin, y: y))
        context.cgContext.strokePath()
        y += 15

        return y
    }

    /// Zeichnet einen Abschnittstitel und gibt die Y-Position danach zurueck.
    private static func zeichneAbschnitt(_ text: String, bei y: CGFloat, in context: UIGraphicsPDFRendererContext) -> CGFloat {
        var currentY = y
        let rect = CGRect(x: margin, y: currentY, width: contentWidth, height: 20)
        (text as NSString).draw(in: rect, withAttributes: headingAttributes(size: 13))
        currentY += 18

        context.cgContext.setStrokeColor(orange.cgColor)
        context.cgContext.setLineWidth(0.5)
        context.cgContext.move(to: CGPoint(x: margin, y: currentY))
        context.cgContext.addLine(to: CGPoint(x: pageSize.width - margin, y: currentY))
        context.cgContext.strokePath()
        currentY += 10

        return currentY
    }

    /// Zeichnet eine Textzeile und gibt die Y-Position danach zurueck.
    private static func zeichneZeile(_ text: String, bei y: CGFloat, attrs: [NSAttributedString.Key: Any]? = nil, einrueckung: CGFloat = 0) -> CGFloat {
        let attributes = attrs ?? bodyAttributes()
        let rect = CGRect(x: margin + einrueckung, y: y, width: contentWidth - einrueckung, height: 16)
        (text as NSString).draw(in: rect, withAttributes: attributes)
        return y + 15
    }

    /// Zeichnet die Fusszeile auf jeder Seite.
    private static func zeichneFusszeile(in context: UIGraphicsPDFRendererContext) {
        let y = pageSize.height - 30
        context.cgContext.setStrokeColor(UIColor.lightGray.cgColor)
        context.cgContext.setLineWidth(0.5)
        context.cgContext.move(to: CGPoint(x: margin, y: y))
        context.cgContext.addLine(to: CGPoint(x: pageSize.width - margin, y: y))
        context.cgContext.strokePath()

        let fussText = "Matjes Schulversion \u{00B7} Erstellt am \(df.string(from: Date()))"
        let rect = CGRect(x: margin, y: y + 5, width: contentWidth, height: 14)
        (fussText as NSString).draw(in: rect, withAttributes: [
            .font: UIFont.systemFont(ofSize: 8),
            .foregroundColor: UIColor.gray
        ])
    }

    /// Sterne als Text (★★☆ etc.)
    private static func sterneText(_ anzahl: Int) -> String {
        String(repeating: "\u{2605}", count: anzahl) + String(repeating: "\u{2606}", count: 3 - anzahl)
    }

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

    // MARK: - PDF: Schueler-Fortschrittsbericht

    /// Generiert einen Fortschrittsbericht als PDF-Data fuer einen einzelnen Schueler.
    static func generiereSchuelerBerichtPDF(
        schueler: Schueler,
        fortschritt: SchuelerFortschritt,
        klasse: Klasse
    ) -> Data {
        let format = UIGraphicsPDFRendererFormat()
        let renderer = UIGraphicsPDFRenderer(bounds: CGRect(origin: .zero, size: pageSize), format: format)

        return renderer.pdfData { context in
            context.beginPage()
            var y = zeichneHeader(
                in: context,
                titel: "Fortschrittsbericht",
                untertitel: "Sch\u{00FC}ler: \(schueler.vollstaendigerName) \u{00B7} Klasse: \(klasse.name) \u{00B7} \(klasse.schuljahr)"
            )

            // Uebersicht
            y = zeichneAbschnitt("\u{00DC}bersicht", bei: y, in: context)
            y = zeichneZeile("Gesamtfortschritt: \(String(format: "%.0f", fortschritt.fortschrittProzent))%", bei: y, attrs: boldBodyAttributes())
            y = zeichneZeile("Gesammelte Sterne: \(fortschritt.gesamtSterne) / \(fortschritt.maxSterne)", bei: y)
            y = zeichneZeile("H\u{00F6}chstes Level: \(fortschritt.hoechstesLevel)", bei: y)
            y = zeichneZeile("Lehrjahr: \(klasse.lehrjahr)", bei: y)
            y += 10

            // Fortschrittsbalken
            let barX = margin
            let barWidth = contentWidth
            let barHeight: CGFloat = 12
            context.cgContext.setFillColor(lightGray.cgColor)
            context.cgContext.fill(CGRect(x: barX, y: y, width: barWidth, height: barHeight))
            let filledWidth = barWidth * CGFloat(fortschritt.fortschrittProzent) / 100.0
            context.cgContext.setFillColor(orange.cgColor)
            context.cgContext.fill(CGRect(x: barX, y: y, width: filledWidth, height: barHeight))
            y += barHeight + 15

            // Level-Fortschritte
            let halbjahre = [
                ("1. Halbjahr (Grundlagen)", 1...5),
                ("2. Halbjahr (Warenkunde)", 6...10),
                ("3. Halbjahr (Vertiefung)", 11...15),
                ("4. Halbjahr (Anwenden)", 16...20)
            ]

            y = zeichneAbschnitt("Level-Fortschritte", bei: y, in: context)

            for (name, levelRange) in halbjahre {
                // Neue Seite falls noetig
                if y > pageSize.height - 120 {
                    zeichneFusszeile(in: context)
                    context.beginPage()
                    y = margin + 20
                }

                y = zeichneZeile(name, bei: y, attrs: boldBodyAttributes(size: 11))

                for level in levelRange {
                    if let lp = fortschritt.levelFortschritte[level] {
                        let datum = lp.lastPlayed.map { df.string(from: $0) } ?? "-"
                        let text = "Level \(String(format: "%2d", level)):  \(sterneText(lp.stars))    Fehler: \(lp.bestErrors)    Zuletzt: \(datum)"
                        y = zeichneZeile(text, bei: y, einrueckung: 15)
                    } else {
                        y = zeichneZeile("Level \(String(format: "%2d", level)):  \u{2606}\u{2606}\u{2606}    (noch nicht gespielt)", bei: y, attrs: [
                            .font: UIFont.systemFont(ofSize: 11),
                            .foregroundColor: UIColor.gray
                        ], einrueckung: 15)
                    }
                }
                y += 5
            }

            // Neue Seite falls noetig
            if y > pageSize.height - 140 {
                zeichneFusszeile(in: context)
                context.beginPage()
                y = margin + 20
            }

            // Pruefungen
            y = zeichneAbschnitt("Pr\u{00FC}fungen", bei: y, in: context)

            if let commis = fortschritt.pruefungsErgebnisse["commis"] {
                let status = commis.passed ? "BESTANDEN" : "NICHT BESTANDEN"
                let farbe = commis.passed ? UIColor.systemGreen : UIColor.systemRed
                y = zeichneZeile("Commis-Pr\u{00FC}fung: \(status)", bei: y, attrs: [
                    .font: UIFont.boldSystemFont(ofSize: 11), .foregroundColor: farbe
                ])
                y = zeichneZeile("Ergebnis: \(String(format: "%.0f", commis.percentage))% (\(commis.correctAnswers)/\(commis.totalQuestions)) \u{00B7} Datum: \(df.string(from: commis.date))", bei: y, einrueckung: 15)
            } else {
                y = zeichneZeile("Commis-Pr\u{00FC}fung: Noch nicht abgelegt", bei: y, attrs: [
                    .font: UIFont.systemFont(ofSize: 11), .foregroundColor: UIColor.gray
                ])
            }
            y += 5

            if let boss = fortschritt.pruefungsErgebnisse["bossfight"] {
                let status = boss.passed ? "BESTANDEN" : "NICHT BESTANDEN"
                let farbe = boss.passed ? UIColor.systemGreen : UIColor.systemRed
                y = zeichneZeile("Abschlusspr\u{00FC}fung (Bossfight): \(status)", bei: y, attrs: [
                    .font: UIFont.boldSystemFont(ofSize: 11), .foregroundColor: farbe
                ])
                y = zeichneZeile("Ergebnis: \(String(format: "%.0f", boss.percentage))% (\(boss.correctAnswers)/\(boss.totalQuestions)) \u{00B7} Datum: \(df.string(from: boss.date))", bei: y, einrueckung: 15)
            } else {
                y = zeichneZeile("Abschlusspr\u{00FC}fung: Noch nicht abgelegt", bei: y, attrs: [
                    .font: UIFont.systemFont(ofSize: 11), .foregroundColor: UIColor.gray
                ])
            }
            y += 10

            // Schwachstellen
            let schwach = fortschritt.schwacheLevel
            if !schwach.isEmpty {
                if y > pageSize.height - 100 {
                    zeichneFusszeile(in: context)
                    context.beginPage()
                    y = margin + 20
                }
                y = zeichneAbschnitt("Schwachstellen (Nacharbeit empfohlen)", bei: y, in: context)
                let levelListe = schwach.map { "Level \($0)" }.joined(separator: ", ")
                y = zeichneZeile(levelListe, bei: y, attrs: [
                    .font: UIFont.systemFont(ofSize: 11), .foregroundColor: UIColor.systemRed
                ])
            }

            zeichneFusszeile(in: context)
        }
    }

    // MARK: - PDF: Klassenuebersicht

    /// Generiert eine Klassenuebersicht als PDF-Data.
    static func generiereKlassenUebersichtPDF(
        klasse: Klasse,
        schueler: [Schueler],
        fortschritte: [UUID: SchuelerFortschritt]
    ) -> Data {
        let format = UIGraphicsPDFRendererFormat()
        let renderer = UIGraphicsPDFRenderer(bounds: CGRect(origin: .zero, size: pageSize), format: format)

        return renderer.pdfData { context in
            context.beginPage()
            var y = zeichneHeader(
                in: context,
                titel: "Klassen\u{00FC}bersicht",
                untertitel: "Klasse: \(klasse.name) \u{00B7} Lehrjahr: \(klasse.lehrjahr) \u{00B7} \(klasse.schuljahr) \u{00B7} \(schueler.count) Sch\u{00FC}ler"
            )

            // Tabellen-Header
            y = zeichneAbschnitt("Sch\u{00FC}ler\u{00FC}bersicht", bei: y, in: context)

            // Spaltenkoepfe
            let col1: CGFloat = margin
            let col2: CGFloat = margin + 180
            let col3: CGFloat = margin + 280
            let col4: CGFloat = margin + 350
            let col5: CGFloat = margin + 420

            let headerAttrs = boldBodyAttributes(size: 10)
            ("Name" as NSString).draw(at: CGPoint(x: col1, y: y), withAttributes: headerAttrs)
            ("Fortschritt" as NSString).draw(at: CGPoint(x: col2, y: y), withAttributes: headerAttrs)
            ("Sterne" as NSString).draw(at: CGPoint(x: col3, y: y), withAttributes: headerAttrs)
            ("Level" as NSString).draw(at: CGPoint(x: col4, y: y), withAttributes: headerAttrs)
            ("Nacharbeit" as NSString).draw(at: CGPoint(x: col5, y: y), withAttributes: headerAttrs)
            y += 16

            // Trennlinie
            context.cgContext.setStrokeColor(UIColor.lightGray.cgColor)
            context.cgContext.setLineWidth(0.5)
            context.cgContext.move(to: CGPoint(x: margin, y: y))
            context.cgContext.addLine(to: CGPoint(x: pageSize.width - margin, y: y))
            context.cgContext.strokePath()
            y += 5

            let sortiert = schueler.sorted { $0.nachname < $1.nachname }
            let rowAttrs = bodyAttributes(size: 10)

            for (index, s) in sortiert.enumerated() {
                if y > pageSize.height - 60 {
                    zeichneFusszeile(in: context)
                    context.beginPage()
                    y = margin + 20

                    // Spaltenkoepfe wiederholen
                    ("Name" as NSString).draw(at: CGPoint(x: col1, y: y), withAttributes: headerAttrs)
                    ("Fortschritt" as NSString).draw(at: CGPoint(x: col2, y: y), withAttributes: headerAttrs)
                    ("Sterne" as NSString).draw(at: CGPoint(x: col3, y: y), withAttributes: headerAttrs)
                    ("Level" as NSString).draw(at: CGPoint(x: col4, y: y), withAttributes: headerAttrs)
                    ("Nacharbeit" as NSString).draw(at: CGPoint(x: col5, y: y), withAttributes: headerAttrs)
                    y += 16
                    context.cgContext.setStrokeColor(UIColor.lightGray.cgColor)
                    context.cgContext.setLineWidth(0.5)
                    context.cgContext.move(to: CGPoint(x: margin, y: y))
                    context.cgContext.addLine(to: CGPoint(x: pageSize.width - margin, y: y))
                    context.cgContext.strokePath()
                    y += 5
                }

                // Zeilenhintergrund alternierend
                if index % 2 == 0 {
                    context.cgContext.setFillColor(UIColor(white: 0.97, alpha: 1.0).cgColor)
                    context.cgContext.fill(CGRect(x: margin, y: y - 2, width: contentWidth, height: 16))
                }

                let fortschritt = fortschritte[s.id]
                let prozent = fortschritt?.fortschrittProzent ?? 0
                let sterne = fortschritt?.gesamtSterne ?? 0
                let hoechstes = fortschritt?.hoechstesLevel ?? 0
                let schwach = fortschritt?.schwacheLevel ?? []

                (s.vollstaendigerName as NSString).draw(at: CGPoint(x: col1, y: y), withAttributes: rowAttrs)
                ("\(String(format: "%.0f", prozent))%" as NSString).draw(at: CGPoint(x: col2, y: y), withAttributes: rowAttrs)
                ("\(sterne)/60" as NSString).draw(at: CGPoint(x: col3, y: y), withAttributes: rowAttrs)
                ("\(hoechstes)" as NSString).draw(at: CGPoint(x: col4, y: y), withAttributes: rowAttrs)

                if schwach.isEmpty {
                    ("\u{2013}" as NSString).draw(at: CGPoint(x: col5, y: y), withAttributes: rowAttrs)
                } else {
                    let schwachText = schwach.map { "\($0)" }.joined(separator: ", ")
                    (schwachText as NSString).draw(at: CGPoint(x: col5, y: y), withAttributes: [
                        .font: UIFont.systemFont(ofSize: 10), .foregroundColor: UIColor.systemRed
                    ])
                }

                y += 18
            }

            // Klassen-Statistik
            y += 15
            if y > pageSize.height - 100 {
                zeichneFusszeile(in: context)
                context.beginPage()
                y = margin + 20
            }

            y = zeichneAbschnitt("Klassen-Statistik", bei: y, in: context)
            let alleProzent = sortiert.compactMap { fortschritte[$0.id]?.fortschrittProzent }
            let durchschnitt = alleProzent.isEmpty ? 0.0 : alleProzent.reduce(0, +) / Double(alleProzent.count)
            y = zeichneZeile("Durchschnittlicher Fortschritt: \(String(format: "%.0f", durchschnitt))%", bei: y, attrs: boldBodyAttributes())

            let alleSterne = sortiert.compactMap { fortschritte[$0.id]?.gesamtSterne }
            let durchschnittSterne = alleSterne.isEmpty ? 0.0 : Double(alleSterne.reduce(0, +)) / Double(alleSterne.count)
            y = zeichneZeile("Durchschnittliche Sterne: \(String(format: "%.1f", durchschnittSterne)) / 60", bei: y)

            let bestandeneCommis = sortiert.filter { fortschritte[$0.id]?.pruefungsErgebnisse["commis"]?.passed == true }.count
            y = zeichneZeile("Commis-Pr\u{00FC}fung bestanden: \(bestandeneCommis) / \(sortiert.count)", bei: y)

            let bestandeneBoss = sortiert.filter { fortschritte[$0.id]?.pruefungsErgebnisse["bossfight"]?.passed == true }.count
            _ = zeichneZeile("Abschlusspr\u{00FC}fung bestanden: \(bestandeneBoss) / \(sortiert.count)", bei: y)

            zeichneFusszeile(in: context)
        }
    }

    // MARK: - PDF: Zertifikat

    /// Generiert ein Zertifikat-PDF fuer eine bestandene Pruefung.
    static func generiereZertifikatPDF(
        schueler: Schueler,
        klasse: Klasse,
        pruefungsTyp: String,
        ergebnis: ExamResult
    ) -> Data? {
        guard ergebnis.passed else { return nil }

        let istBossfight = pruefungsTyp == "bossfight"
        let pruefungsName = istBossfight ? "Abschlusspr\u{00FC}fung" : "Commis-Pr\u{00FC}fung"
        let pruefungsTitel = istBossfight ? "K\u{00FC}chenmeister" : "Commis de Cuisine"

        let format = UIGraphicsPDFRendererFormat()
        let renderer = UIGraphicsPDFRenderer(bounds: CGRect(origin: .zero, size: pageSize), format: format)

        return renderer.pdfData { context in
            context.beginPage()

            let centerX = pageSize.width / 2

            // Dekorativer Rahmen
            let rahmenInset: CGFloat = 25
            context.cgContext.setStrokeColor(orange.cgColor)
            context.cgContext.setLineWidth(3)
            context.cgContext.stroke(CGRect(
                x: rahmenInset, y: rahmenInset,
                width: pageSize.width - 2 * rahmenInset,
                height: pageSize.height - 2 * rahmenInset
            ))

            // Innerer Rahmen
            context.cgContext.setLineWidth(1)
            context.cgContext.stroke(CGRect(
                x: rahmenInset + 8, y: rahmenInset + 8,
                width: pageSize.width - 2 * (rahmenInset + 8),
                height: pageSize.height - 2 * (rahmenInset + 8)
            ))

            var y: CGFloat = 80

            // Matjes-Titel
            let matjesAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 14),
                .foregroundColor: UIColor.gray
            ]
            let matjesText = "Matjes, der kleine Hering \u{1F41F}"
            let matjesSize = (matjesText as NSString).size(withAttributes: matjesAttrs)
            (matjesText as NSString).draw(at: CGPoint(x: centerX - matjesSize.width / 2, y: y), withAttributes: matjesAttrs)
            y += 35

            // Zertifikat-Titel
            let zertAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 36),
                .foregroundColor: orange
            ]
            let zertText = "ZERTIFIKAT"
            let zertSize = (zertText as NSString).size(withAttributes: zertAttrs)
            (zertText as NSString).draw(at: CGPoint(x: centerX - zertSize.width / 2, y: y), withAttributes: zertAttrs)
            y += 55

            // Dekorative Linie
            context.cgContext.setStrokeColor(orange.cgColor)
            context.cgContext.setLineWidth(1)
            context.cgContext.move(to: CGPoint(x: 120, y: y))
            context.cgContext.addLine(to: CGPoint(x: pageSize.width - 120, y: y))
            context.cgContext.strokePath()
            y += 40

            // "Hiermit wird bescheinigt, dass"
            let introAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 14),
                .foregroundColor: darkGray
            ]
            let introText = "Hiermit wird bescheinigt, dass"
            let introSize = (introText as NSString).size(withAttributes: introAttrs)
            (introText as NSString).draw(at: CGPoint(x: centerX - introSize.width / 2, y: y), withAttributes: introAttrs)
            y += 45

            // Name des Schuelers (gross)
            let nameAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 28),
                .foregroundColor: darkGray
            ]
            let nameText = schueler.vollstaendigerName
            let nameSize = (nameText as NSString).size(withAttributes: nameAttrs)
            (nameText as NSString).draw(at: CGPoint(x: centerX - nameSize.width / 2, y: y), withAttributes: nameAttrs)
            y += 40

            // Unterstrich unter dem Namen
            context.cgContext.setStrokeColor(UIColor.lightGray.cgColor)
            context.cgContext.setLineWidth(0.5)
            context.cgContext.move(to: CGPoint(x: 150, y: y))
            context.cgContext.addLine(to: CGPoint(x: pageSize.width - 150, y: y))
            context.cgContext.strokePath()
            y += 35

            // Beschreibung
            let beschrAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 14),
                .foregroundColor: darkGray
            ]
            let beschrText = "die \(pruefungsName) erfolgreich bestanden hat"
            let beschrSize = (beschrText as NSString).size(withAttributes: beschrAttrs)
            (beschrText as NSString).draw(at: CGPoint(x: centerX - beschrSize.width / 2, y: y), withAttributes: beschrAttrs)
            y += 30

            let titelLabelAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 13),
                .foregroundColor: darkGray
            ]
            let titelLabelText = "und sich den Titel verdient hat:"
            let titelLabelSize = (titelLabelText as NSString).size(withAttributes: titelLabelAttrs)
            (titelLabelText as NSString).draw(at: CGPoint(x: centerX - titelLabelSize.width / 2, y: y), withAttributes: titelLabelAttrs)
            y += 45

            // Titel (Commis de Cuisine / Kuechenmeister)
            let titelAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 24),
                .foregroundColor: orange
            ]
            let titelSize = (pruefungsTitel as NSString).size(withAttributes: titelAttrs)
            (pruefungsTitel as NSString).draw(at: CGPoint(x: centerX - titelSize.width / 2, y: y), withAttributes: titelAttrs)
            y += 55

            // Ergebnis-Details
            let detailAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 12),
                .foregroundColor: UIColor.gray
            ]
            let detailText = "Ergebnis: \(String(format: "%.0f", ergebnis.percentage))% (\(ergebnis.correctAnswers) von \(ergebnis.totalQuestions) Fragen)"
            let detailSize = (detailText as NSString).size(withAttributes: detailAttrs)
            (detailText as NSString).draw(at: CGPoint(x: centerX - detailSize.width / 2, y: y), withAttributes: detailAttrs)
            y += 22

            let klasseText = "Klasse: \(klasse.name) \u{00B7} Lehrjahr: \(klasse.lehrjahr) \u{00B7} \(klasse.schuljahr)"
            let klasseSize = (klasseText as NSString).size(withAttributes: detailAttrs)
            (klasseText as NSString).draw(at: CGPoint(x: centerX - klasseSize.width / 2, y: y), withAttributes: detailAttrs)
            y += 22

            let datumText = "Datum: \(df.string(from: ergebnis.date))"
            let datumSize = (datumText as NSString).size(withAttributes: detailAttrs)
            (datumText as NSString).draw(at: CGPoint(x: centerX - datumSize.width / 2, y: y), withAttributes: detailAttrs)
            y += 70

            // Dekorative Linie unten
            context.cgContext.setStrokeColor(orange.cgColor)
            context.cgContext.setLineWidth(1)
            context.cgContext.move(to: CGPoint(x: 120, y: y))
            context.cgContext.addLine(to: CGPoint(x: pageSize.width - 120, y: y))
            context.cgContext.strokePath()
            y += 30

            // Sterne-Reihe
            let sterneAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 30),
                .foregroundColor: orange
            ]
            let sterneReihe = "\u{2605} \u{2605} \u{2605}"
            let sterneSize = (sterneReihe as NSString).size(withAttributes: sterneAttrs)
            (sterneReihe as NSString).draw(at: CGPoint(x: centerX - sterneSize.width / 2, y: y), withAttributes: sterneAttrs)

            // Fusszeile
            let fussY = pageSize.height - 60
            let fussAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 9),
                .foregroundColor: UIColor.lightGray
            ]
            let fussText = "Matjes \u{00B7} Das Ausbildungsspiel der K\u{00FC}che \u{00B7} Schulversion"
            let fussSize = (fussText as NSString).size(withAttributes: fussAttrs)
            (fussText as NSString).draw(at: CGPoint(x: centerX - fussSize.width / 2, y: fussY), withAttributes: fussAttrs)
        }
    }

    // MARK: - Hilfsfunktion: PDF als temporaere Datei speichern

    /// Speichert PDF-Data als temporaere Datei und gibt die URL zurueck.
    static func speicherePDFTemp(data: Data, dateiname: String) -> URL? {
        let tempDir = FileManager.default.temporaryDirectory
        let url = tempDir.appendingPathComponent(dateiname)
        do {
            try data.write(to: url)
            return url
        } catch {
            return nil
        }
    }
}
