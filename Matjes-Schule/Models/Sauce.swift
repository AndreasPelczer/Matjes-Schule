//
//  Sauce.swift
//  MatjesSchule
//
//  Datenmodell fuer Saucen & Fonds / Lexikon (portiert aus V1/V2)
//

import Foundation

struct Sauce: Identifiable, Codable {
    let id: String
    let name: String
    let typ: String
    let basis: String
    let beschreibung: String
    let verwendung: String
    let lagerung: String
    let ableitungen: String
}
