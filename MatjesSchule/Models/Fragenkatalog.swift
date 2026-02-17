//
//  Fragenkatalog.swift
//  MatjesSchule
//
//  Eigene Fragenkataloge des Ausbilders (V3)
//  Ausbilder koennen eigene Fragen erstellen und verwalten.
//

import Foundation

struct Fragenkatalog: Identifiable, Codable {
    let id: UUID
    var name: String
    var beschreibung: String
    var ausbilderId: UUID
    var erstelltAm: Date
    var aktualisiertAm: Date
    var istVeroeffentlicht: Bool

    init(name: String, beschreibung: String, ausbilderId: UUID) {
        self.id = UUID()
        self.name = name
        self.beschreibung = beschreibung
        self.ausbilderId = ausbilderId
        self.erstelltAm = Date()
        self.aktualisiertAm = Date()
        self.istVeroeffentlicht = false
    }
}

struct AusbilderFrage: Identifiable, Codable {
    let id: UUID
    var katalogId: UUID
    var text: String
    var antworten: [String]
    var korrekterIndex: Int
    var erklaerung: String
    var level: Int?
    var erstelltAm: Date
    var aktualisiertAm: Date

    init(katalogId: UUID, text: String, antworten: [String], korrekterIndex: Int, erklaerung: String, level: Int? = nil) {
        self.id = UUID()
        self.katalogId = katalogId
        self.text = text
        self.antworten = antworten
        self.korrekterIndex = korrekterIndex
        self.erklaerung = erklaerung
        self.level = level
        self.erstelltAm = Date()
        self.aktualisiertAm = Date()
    }
}
