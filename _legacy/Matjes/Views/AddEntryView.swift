import SwiftUI
import SwiftData

struct AddEntryView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    // Steuerungs-Variablen
    @State private var entryType: String = "Produkt"
    
    // Gemeinsame Felder
    @State private var name: String = ""
    @State private var idOrCode: String = ""
    @State private var category: String = ""
    @State private var description: String = ""
    
    // Produktspezifisch
    @State private var dataSource: String = "Lieferant"
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Typ auswählen") {
                    Picker("Was erstellst du?", selection: $entryType) {
                        Text("Produkt").tag("Produkt")
                        Text("Technik / Lexikon").tag("Technik")
                    }.pickerStyle(.segmented)
                }
                
                Section("Basis-Infos") {
                    TextField("z. B. Bio-Zitrone oder Räucherlachs", text: $name)
                    TextField(entryType == "Produkt" ? "z. B. Art-Nr. 1005" : "z. B. E-300 oder T-KOCH", text: $idOrCode)
                    TextField("z. B. Obst, Fisch oder Garmethode", text: $category)
                }
                
                Section("Details") {
                    if entryType == "Produkt" {
                        Picker("Quelle", selection: $dataSource) {
                            Text("Natur").tag("Natur")
                            Text("Hering").tag("Hering")
                            Text("Lieferant").tag("Lieferant")
                        }
                    }
                    
                    TextEditor(text: $description)
                        .frame(minHeight: 150)
                        .overlay(alignment: .topLeading) {
                            if description.isEmpty {
                                Text("Beschreibe Herkunft oder Verarbeitung...")
                                    .foregroundColor(.gray.opacity(0.5))
                                    .padding(.top, 8)
                                    .padding(.leading, 5)
                            }
                        }
                }
            }
            .navigationTitle("Neu anlegen")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Abbrechen") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Speichern") { saveEntry() }
                        .disabled(name.isEmpty || idOrCode.isEmpty)
                        .bold()
                }
            }
        }
    }
    
    // MARK: - Speichern-Logik
    private func saveEntry() {
        if entryType == "Produkt" {
            let newProduct = Product(
                id: idOrCode,
                name: name,
                category: category,
                dataSource: dataSource
            )
            newProduct.beschreibung = description
            modelContext.insert(newProduct)
        } else {
            let newEntry = LexikonEntry(
                code: idOrCode,
                name: name,
                kategorie: category,
                beschreibung: description
            )
            modelContext.insert(newEntry)
        }
        
        do {
            try modelContext.save()
            dismiss() // Fenster schließen nach Erfolg
        } catch {
            print("🚨 Fehler beim Speichern: \(error.localizedDescription)")
        }
    }
}
