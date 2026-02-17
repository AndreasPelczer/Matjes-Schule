//
//  Klasse.swift
//  MatjesSchule
//
//  Klassen-/Gruppenverwaltung fuer die Schulversion (V3)
//

import Foundation

struct Klasse: Identifiable, Codable {
    let id: UUID
    var name: String
    var ausbilderId: UUID
    var lehrjahr: Int
    var schuljahr: String
    var erstelltAm: Date
    var istAktiv: Bool

    init(name: String, ausbilderId: UUID, lehrjahr: Int, schuljahr: String) {
        self.id = UUID()
        self.name = name
        self.ausbilderId = ausbilderId
        self.lehrjahr = lehrjahr
        self.schuljahr = schuljahr
        self.erstelltAm = Date()
        self.istAktiv = true
    }

    /// Vollstaendiger Initialisierer (fuer CloudKit-Sync)
    init(id: UUID, name: String, ausbilderId: UUID, lehrjahr: Int, schuljahr: String, erstelltAm: Date, istAktiv: Bool) {
        self.id = id
        self.name = name
        self.ausbilderId = ausbilderId
        self.lehrjahr = lehrjahr
        self.schuljahr = schuljahr
        self.erstelltAm = erstelltAm
        self.istAktiv = istAktiv
    }
}
