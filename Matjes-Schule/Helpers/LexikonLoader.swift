//
//  LexikonLoader.swift
//  MatjesSchule
//
//  JSON-Parser fuer Lexikon-Daten (portiert aus V1/V2)
//

import Foundation

class LexikonLoader {

    private static var cachedProdukte: [Produkt]?
    private static var cachedGarmethoden: [Garmethode]?
    private static var cachedSaucen: [Sauce]?

    static func loadProdukte() -> [Produkt] {
        if let cached = cachedProdukte { return cached }
        let result: [Produkt] = loadJSON(named: "Koch_Produkte")
        cachedProdukte = result
        return result
    }

    static func loadGarmethoden() -> [Garmethode] {
        if let cached = cachedGarmethoden { return cached }
        let result: [Garmethode] = loadJSON(named: "Koch_Garmethoden")
        cachedGarmethoden = result
        return result
    }

    static func loadSaucen() -> [Sauce] {
        if let cached = cachedSaucen { return cached }
        let result: [Sauce] = loadJSON(named: "Koch_Saucen")
        cachedSaucen = result
        return result
    }

    static func produktKategorien(in produkte: [Produkt]) -> [String] {
        let kategorien = Set(produkte.map { $0.kategorie })
        return kategorien.sorted()
    }

    static func garmethodenTypen(in methoden: [Garmethode]) -> [String] {
        let typen = Set(methoden.map { $0.typ })
        return typen.sorted()
    }

    static func saucenTypen(in saucen: [Sauce]) -> [String] {
        let typen = Set(saucen.map { $0.typ })
        return typen.sorted()
    }

    // MARK: - Private

    private static func loadJSON<T: Decodable>(named filename: String) -> [T] {
        guard let url = Bundle.main.url(forResource: filename, withExtension: "json") else {
            #if DEBUG
            print("Lexikon-JSON nicht gefunden: \(filename).json")
            #endif
            return []
        }

        do {
            let data = try Data(contentsOf: url)
            return try JSONDecoder().decode([T].self, from: data)
        } catch {
            #if DEBUG
            print("Lexikon-Ladefehler (\(filename)): \(error)")
            #endif
            return []
        }
    }
}
