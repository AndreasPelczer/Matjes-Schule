import Foundation
import SwiftData

@MainActor
class GagaImporter {
    
    static func importJSON(into context: ModelContext) {
        /* // VORÜBERGEHEND AUSSCHALTEN
            // 1. SICHERHEITS-CHECK: Sind schon Daten da?
            let descriptor = FetchDescriptor<Product>()
            let existingCount = (try? context.fetchCount(descriptor)) ?? 0
            
            // Wenn schon Produkte da sind, brechen wir den automatischen Import ab
            if existingCount > 0 {
                print("ℹ️ Gastro-Grid: Daten bereits vorhanden (\(existingCount) Einträge). Überspringe Import, um Korrekturen zu schützen.")
                return
            }
            
            // Nur wenn die Datenbank leer ist, wird gelöscht und neu geladen:
            print("🧹 Speicher ist leer. Starte Erst-Import für GASTRO-GRID...")*/
            
            // 2. Jetzt die Funktionen aufrufen
            importProdukte(into: context)
            importLexikon(into: context)
            
            // 3. Finales Speichern
            do {
                try context.save()
                print("🚀 GASTRO-GRID OMNI: Erst-Import erfolgreich abgeschlossen!")
            } catch {
                print("🚨 Fehler beim finalen Speichern: \(error)")
            }
        }
    
    // MARK: - Private Import-Logik
    
    private static func importProdukte(into context: ModelContext) {
        guard let url = Bundle.main.url(forResource: "Produkte", withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            print("🚨 KRITISCH: Produkte.json nicht gefunden!")
            return
        }
        
        do {
            let decoder = JSONDecoder()
            let decodedProducts = try decoder.decode([JSONProduct].self, from: data)
            
            for jsonP in decodedProducts {
                let p = Product(
                    id: jsonP.id,
                    name: jsonP.name,
                    category: jsonP.kategorie,
                    dataSource: jsonP.typ
                )
                p.beschreibung = jsonP.beschreibung
                
                if let meta = jsonP.metadata {
                    p.allergene = meta.allergene
                    p.zusatzstoffe = meta.zusatzstoffe
                    p.kcal = meta.kcal_100g
                    p.fett = meta.fett
                    p.zucker = meta.zucker
                }
                
                if let jsonRecipe = jsonP.rezept {
                    let newRecipe = Recipe(
                        portionen: jsonRecipe.portionen,
                        algorithmus: jsonRecipe.algorithmus
                    )
                    for jsonIng in jsonRecipe.komponenten {
                        let ingredient = Ingredient(
                            name: jsonIng.name,
                            menge: jsonIng.menge,
                            einheit: jsonIng.einheit
                        )
                        ingredient.recipe = newRecipe
                    }
                    p.rezept = newRecipe
                }
                context.insert(p)
            }
            print("✅ \(decodedProducts.count) Produkte inklusive Allergene & Rezepte geladen.")
        } catch {
            print("🚨 PARSE-FEHLER in Produkte.json: \(error)")
        }
    }
    
    private static func importLexikon(into context: ModelContext) {
        guard let url = Bundle.main.url(forResource: "Lexikon", withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            print("🚨 KRITISCH: Lexikon.json nicht gefunden!")
            return
        }
        
        do {
            let raw = try JSONSerialization.jsonObject(with: data) as? [[String: Any]] ?? []
            for e in raw {
                let code = (e["code"] as? String ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
                let name = (e["name"] as? String ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
                
                if name.isEmpty || code.isEmpty { continue }

                let entry = LexikonEntry(
                    code: code,
                    name: name,
                    kategorie: e["kategorie"] as? String ?? "Fachbuch",
                    beschreibung: e["beschreibung"] as? String ?? "",
                    details: e["details"] as? String ?? ""
                )
                context.insert(entry)
            }
            print("📚 BASIS HERING: \(raw.count) Einträge geladen.")
        } catch {
            print("🚨 PARSE-FEHLER im Lexikon: \(error)")
        }
    }
} // <--- Diese Klammer schließt die Klasse GagaImporter ab.
