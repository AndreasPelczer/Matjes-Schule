//
//  JSONProduct.swift
//  Matjes
//
//  Created by Senior-Entwickler (Mentor) am 08.01.26.
//

import Foundation

/// JSONProduct: Das Spiegelbild deiner Produkte.json.
/// Muss Codable sein, damit der JSONDecoder die Datei einlesen kann.
struct JSONProduct: Codable {
    let id: String
    let name: String
    let kategorie: String
    let typ: String
    let beschreibung: String
    
    // Wir nutzen optionale Typen (?), falls mal ein Feld im JSON fehlt.
    let metadata: JSONMetadata?
    let rezept: JSONRecipe?
}

/// JSONMetadata: Die Nährwerte und Sicherheitshinweise.
struct JSONMetadata: Codable {
    let allergene: String
    let zusatzstoffe: String
    let kcal_100g: String
    let fett: String
    let zucker: String
}

/// JSONRecipe: Der Bauplan für das Rezept im JSON.
struct JSONRecipe: Codable {
    let portionen: String
    let algorithmus: [String]
    let komponenten: [JSONIngredient]
}

/// JSONIngredient: Die einzelnen Zutaten.
struct JSONIngredient: Codable {
    let name: String
    let menge: String
    let einheit: String
}
