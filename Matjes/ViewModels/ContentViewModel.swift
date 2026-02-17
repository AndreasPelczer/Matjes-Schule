//
//  ContentViewModel.swift
//  Matjes
//
//  Created by Senior-Entwickler (Mentor) am 09.01.26.
//

import Foundation
import SwiftData
import Combine

/// ContentViewModel: Verwaltet die dynamischen Filter für Hannes.
/// Architektur: Erweitert, um Fachbuch-Kategorien (Hering) und Lager-Kategorien (Natur) zu trennen.
@MainActor
class ContentViewModel: ObservableObject {
    @Published var selectedSource: String = "Alle"
    @Published var dynamicCategories: [String] = []

    
    
    private var modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    /// Scannt sowohl Produkte als auch Lexikon-Einträge, um die Reiter oben zu füllen.
    /// - Parameters:
    ///   - products: Die Liste der Lager-Artikel (Natur/Lieferant)
    ///   - entries: Die Liste der Fachbuch-Einträge (Hering)
    func updateCategories(from products: [Product], and entries: [LexikonEntry]) {
        
        // 1. Kategorien aus dem Lager (Gemüse, Saucen etc.)
        let productCats = products.map { $0.category }
        
        // 2. Kategorien aus dem Fachbuch (Kochtechnik, Garnitur, Warenkunde)
        // Wir nutzen compactMap, da kategorie beim Lexikon optional ist (?)
        let lexikonCats = entries.compactMap { $0.kategorie }
        
        // 3. Alles zusammenwerfen
        let combinedCats = productCats + lexikonCats
        
        // 4. Dubletten entfernen (Set) und alphabetisch sortieren
        // Hannes-Tipp: "Alle" wird in der View meist hart codiert, hier kommen die dynamischen Tabs
        self.dynamicCategories = Array(Set(combinedCats)).sorted()
        
        print("🎯 Tabs aktualisiert: \(dynamicCategories.count) Kategorien aus Lager & Fachbuch gefunden.")
    }
}
