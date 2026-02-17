//
//  Produkt.swift
//  MatjesSchule
//
//  Datenmodell fuer Lebensmittel-Produkte / Lexikon (portiert aus V1/V2)
//

import Foundation

struct Naehrwerte: Codable {
    let kcal: Int
    let fett: Double
    let eiweiss: Double
    let kohlenhydrate: Double
}

struct Produkt: Identifiable, Codable {
    let id: String
    let name: String
    let kategorie: String
    let typ: String
    let beschreibung: String
    let lagerung: String
    let saison: String
    let allergene: String
    let zusatzstoffe: String
    let naehrwerte: Naehrwerte
}
