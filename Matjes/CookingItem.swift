//
//  CookingItem.swift
//  Matjes
//
//  Created by Andreas Pelczer on 06.01.26.
//


//
//  CookingItem.swift
//  ChefApp
//
//  Created by Gemini on 06.01.26.
//  Description: Modell für Koch-Techniken und Rezepte. 
//  Architektur: Striktes MVVM - Dies ist das "Model".
//

import Foundation

/// Das Model repräsentiert einen einzelnen Eintrag aus deiner Liste (Technik oder Rezept).
/// Wir verwenden `Identifiable`, damit wir die Liste später direkt in SwiftUI anzeigen können.
struct CookingItem: Identifiable {
    
    // MARK: - Eigenschaften
    
    let id: String           // Eindeutige ID (z.B. W090)
    let titel: String        // Name des Gerichts oder der Technik
    let typ: String          // Rezept oder Technik
    let beschreibung: String // Kurzer Erklärungstext
    let hardware: String     // Benötigte Werkzeuge
    let videoURL: String     // Link zum Video
    let heringSeite: String  // Referenz zum Hering-Fachbuch
    
    // Diese Felder sind "Optional" (?), da sie bei Techniken leer sein können.
    let zutaten: String?     
    let allergene: String?
    
    // MARK: - Lexikon
    // Optional: Ein Datentyp, der entweder einen Wert enthält oder "nil" (leer) ist.
    // Swift-Sicherheit: Verhindert Abstürze, wenn Daten fehlen.
}

/// Diese Extension kümmert sich um die Logik des Daten-Imports (Business-Logik ausgelagert).
extension CookingItem {
    
    /// Wandelt einen CSV-String in ein Array von CookingItem-Objekten um.
    /// - Parameter csvString: Der gesamte Textinhalt deiner Liste.
    /// - Returns: Ein Array von sauber strukturierten Objekten.
    static func parseCSV(from csvString: String) -> [CookingItem] {
        var items: [CookingItem] = []
        
        // Wir trennen den String in einzelne Zeilen.
        let lines = csvString.components(separatedBy: .newlines)
        
        for line in lines {
            // Überspringe leere Zeilen oder Header.
            if line.isEmpty || line.contains("id;titel") { continue }
            
            // Trennung nach Semikolon.
            let columns = line.components(separatedBy: ";")
            
            // Wir prüfen, ob wir mindestens die Basis-Spalten haben (7 Stück).
            if columns.count >= 7 {
                let item = CookingItem(
                    id: columns[0].trimmingCharacters(in: .whitespaces),
                    titel: columns[1].trimmingCharacters(in: .whitespaces),
                    typ: columns[2].trimmingCharacters(in: .whitespaces),
                    beschreibung: columns[3].trimmingCharacters(in: .whitespaces),
                    hardware: columns[4].trimmingCharacters(in: .whitespaces),
                    videoURL: columns[5].trimmingCharacters(in: .whitespaces),
                    heringSeite: columns[6].trimmingCharacters(in: .whitespaces),
                    // Falls Spalte 7 und 8 existieren, weisen wir sie zu, sonst nil.
                    zutaten: columns.count > 7 && !columns[7].isEmpty ? columns[7] : nil,
                    allergene: columns.count > 8 && !columns[8].isEmpty ? columns[8] : nil
                )
                items.append(item)
            }
        }
        
        return items
    }
}

// MARK: - Erklärungen (Fachbegriffe)
// Parse/Parsing: Das Zerlegen und Analysieren einer Datenstruktur (hier CSV-Text in Swift-Objekte).
// Extension: Eine Erweiterung einer bestehenden Klasse/Struktur um neue Funktionen, um die Datei übersichtlich zu halten.
// Nil: Der Swift-Ausdruck für "kein Wert vorhanden".