//
//  Schueler.swift
//  MatjesSchule
//
//  Schueler/Azubi-Verwaltung fuer die Schulversion (V3)
//  Basierend auf Employee-Konzept aus Gastro-Grid
//

import Foundation

struct Schueler: Identifiable, Codable {
    let id: UUID
    var vorname: String
    var nachname: String
    var klasseId: UUID
    var einladungsCode: String
    var istAktiv: Bool
    var erstelltAm: Date
    var letzteAktivitaet: Date?

    var vollstaendigerName: String {
        "\(vorname) \(nachname)"
    }

    init(vorname: String, nachname: String, klasseId: UUID) {
        self.id = UUID()
        self.vorname = vorname
        self.nachname = nachname
        self.klasseId = klasseId
        self.einladungsCode = Self.generiereCode()
        self.istAktiv = true
        self.erstelltAm = Date()
        self.letzteAktivitaet = nil
    }

    /// Generiert einen 6-stelligen Einladungscode
    private static func generiereCode() -> String {
        let zeichen = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789"
        return String((0..<6).map { _ in zeichen.randomElement()! })
    }
}
