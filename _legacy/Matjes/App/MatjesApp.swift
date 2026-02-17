import SwiftUI
import SwiftData

@main
struct MatjesApp: App {
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Product.self,
            LexikonEntry.self
        ])
        
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            // Wichtig: Hier steht dein Container-Name aus Xcode
            cloudKitDatabase: .private("iCloud.com.deinname.Matjes")
        )

        do {
            // Hier sagen wir SwiftData: Benutze genau diese Cloud-Konfiguration!
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("🚨 ModelContainer-Fehler: \(error)")
        }
    }()
    
    var body: some Scene {
        WindowGroup {
            MainScannerView(modelContext: sharedModelContainer.mainContext)
                .modelContainer(sharedModelContainer)             .onAppear {
                    Task { @MainActor in
                        let context = sharedModelContainer.mainContext
                        
                        // Importiert die JSON-Daten beim ersten Start
                        GagaImporter.importJSON(into: context)
                        
                        do {
                            try context.save()
                            print("✅ Cloud-Sync aktiv: Produkte & Lexikon geladen.")
                        } catch {
                            print("🚨 Fehler beim Sichern: \(error)")
                        }
                    }
                }
        }
    }
}
