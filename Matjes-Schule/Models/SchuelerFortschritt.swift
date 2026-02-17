//
//  SchuelerFortschritt.swift
//  MatjesSchule
//
//  Fortschrittsdaten pro Schueler (V3)
//  Wird via CloudKit synchronisiert, damit Ausbilder den Fortschritt sehen.
//

import Foundation

struct SchuelerFortschritt: Identifiable, Codable {
    let id: UUID
    var schuelerId: UUID
    var levelFortschritte: [Int: LevelProgress]
    var pruefungsErgebnisse: [String: ExamResult]
    var aktualisiertAm: Date

    init(schuelerId: UUID) {
        self.id = UUID()
        self.schuelerId = schuelerId
        self.levelFortschritte = [:]
        self.pruefungsErgebnisse = [:]
        self.aktualisiertAm = Date()
    }

    /// Vollstaendiger Initialisierer (fuer CloudKit-Sync)
    init(id: UUID, schuelerId: UUID, levelFortschritte: [Int: LevelProgress], pruefungsErgebnisse: [String: ExamResult], aktualisiertAm: Date) {
        self.id = id
        self.schuelerId = schuelerId
        self.levelFortschritte = levelFortschritte
        self.pruefungsErgebnisse = pruefungsErgebnisse
        self.aktualisiertAm = aktualisiertAm
    }

    /// Gesamtzahl der gesammelten Sterne
    var gesamtSterne: Int {
        levelFortschritte.values.reduce(0) { $0 + $1.stars }
    }

    /// Maximale Sterne (3 pro Level, 20 Level = 60)
    var maxSterne: Int { 60 }

    /// Fortschritt in Prozent
    var fortschrittProzent: Double {
        guard maxSterne > 0 else { return 0 }
        return Double(gesamtSterne) / Double(maxSterne) * 100
    }

    /// Hoechstes abgeschlossenes Level (mindestens 1 Stern)
    var hoechstesLevel: Int {
        levelFortschritte
            .filter { $0.value.stars >= 1 }
            .keys
            .max() ?? 0
    }

    /// Schwache Level (0 Sterne, aber gespielt)
    var schwacheLevel: [Int] {
        levelFortschritte
            .filter { $0.value.stars == 0 && $0.value.lastPlayed != nil }
            .keys
            .sorted()
    }
}
