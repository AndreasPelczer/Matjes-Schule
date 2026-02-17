import SwiftUI
import SwiftData
import SafariServices

struct ProductDetailView: View {
    @Environment(\.modelContext) private var modelContext 
    
    let product: Product?
    let lexikonEntry: LexikonEntry?
    
    @State private var isEditing = false
    @State private var editedName = ""
    @State private var editedDescription = ""
    @State private var selectedLinkID: String?
    @State private var navigateToLink = false
    @State private var activeURL: URL?
    @State private var showBrowser = false
    
    @Query private var allLexikonEntries: [LexikonEntry]
    @Query private var allProducts: [Product]

    init(product: Product) { self.product = product; self.lexikonEntry = nil }
    init(entry: LexikonEntry) { self.lexikonEntry = entry; self.product = nil }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 30) {
                headerSection
                
                // Bestands-Anzeige nur für Produkte (Lager)
                if product != nil {
                    inventoryPanel
                        .padding(.horizontal)
                }

                HStack(spacing: 12) {
                    actionButton(title: "YOUTUBE", icon: "play.rectangle.fill", color: .red) { openGastroSearch(prefix: "youtube.com/results?search_query=Profi+Kochen+") }
                    actionButton(title: "WIKI", icon: "book.fill", color: .gray) { openGastroSearch(prefix: "de.wikipedia.org/wiki/") }
                    actionButton(title: "GOOGLE", icon: "globe", color: .blue) { openGastroSearch(prefix: "google.com/search?q=Gastronomie+Warenkunde+") }
                }
                .padding(.horizontal)

                if let p = product, (!p.allergene.isEmpty || !p.zusatzstoffe.isEmpty) {
                    safetyPanel.padding(.horizontal)
                }

                infoBlock.padding(.horizontal)

                VStack(alignment: .leading, spacing: 25) {
                    if let recipe = product?.rezept {
                        recipeSection(for: recipe)
                    }
                    if let p = product, !p.kcal.isEmpty {
                        nutritionGrid(for: p)
                    }
                }
                .padding(.horizontal)
            }
            .padding(.bottom, 40)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle(product?.name ?? lexikonEntry?.name ?? "Details")
        .sheet(isPresented: $showBrowser) { if let url = activeURL { SafariWebView(url: url) } }
        .navigationDestination(isPresented: $navigateToLink) { if let id = selectedLinkID { UniversalDetailSelector(queryID: id) } }
    }

    // MARK: - LAGER LOGIK
    
    private var inventoryPanel: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Label("LAGERBESTAND", systemImage: "snowflake")
                    .font(.caption.bold())
                    .foregroundColor(.blue)
                Spacer()
                Menu(product?.stockUnit ?? "Einheit wählen") {
                    Button("KG") { updateUnit("KG") }
                    Button("Kisten") { updateUnit("Kisten") }
                    Button("Beutel") { updateUnit("Beutel") }
                    Button("Einheiten") { updateUnit("Einheiten") }
                }
                .font(.caption.bold())
            }
            
            HStack(spacing: 20) {
                Button(action: { adjustStock(by: -1) }) {
                    Image(systemName: "minus.circle.fill").font(.title2)
                }
                
                Text("\(String(format: "%.1f", product?.stockQuantity ?? 0))")
                    .font(.title.bold())
                    .frame(minWidth: 60)
                
                Button(action: { adjustStock(by: 1) }) {
                    Image(systemName: "plus.circle.fill").font(.title2)
                }
                
                Text(product?.stockUnit ?? "Stk.")
                    .font(.headline)
            }
        }
        .padding()
        .background(Color.blue.opacity(0.05))
        .cornerRadius(12)
    }

    private func adjustStock(by amount: Double) {
        guard let p = product else { return }
        p.stockQuantity = max(0, p.stockQuantity + amount)
        try? modelContext.save()
    }

    private func updateUnit(_ newUnit: String) {
        product?.stockUnit = newUnit
        try? modelContext.save()
    }
    
    // MARK: - ALLGEMEINE LOGIK
    
    private var linkedPartnerID: String? {
        let currentName = product?.name ?? lexikonEntry?.name ?? ""
        if product != nil {
            return allLexikonEntries.first(where: { $0.name.lowercased() == currentName.lowercased() })?.code
        } else {
            return allProducts.first(where: { $0.id == currentName || $0.name.lowercased() == currentName.lowercased() })?.id
        }
    }
    
    private func startEditing() {
        editedName = product?.name ?? lexikonEntry?.name ?? ""
        editedDescription = product?.beschreibung ?? lexikonEntry?.beschreibung ?? ""
        isEditing = true
    }
    
    private func saveChanges() {
        if let p = product {
            p.objectWillChange.send()
            p.name = editedName
            p.beschreibung = editedDescription
        } else if let e = lexikonEntry {
            e.objectWillChange.send()
            e.name = editedName
            e.beschreibung = (editedDescription.isEmpty ? nil : editedDescription)
        }
        try? product?.modelContext?.save()
        try? lexikonEntry?.modelContext?.save()
        isEditing = false
    }
    
    private func openGastroSearch(prefix: String) {
        let name = product?.name ?? lexikonEntry?.name ?? ""
        if let url = URL(string: "https://\(prefix)\(name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")") {
            self.activeURL = url; self.showBrowser = true
        }
    }
    
    // MARK: - SUBVIEWS
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(product?.category ?? lexikonEntry?.kategorie ?? "INFO").font(.caption.bold()).padding(6).background(Color.blue).foregroundColor(.white).cornerRadius(4)
                Spacer()
                if let partnerID = linkedPartnerID {
                    Button(action: { selectedLinkID = partnerID; navigateToLink = true }) {
                        HStack(spacing: 4) { Image(systemName: product != nil ? "book.closed.fill" : "shippingbox.fill"); Text(product != nil ? "Wissen" : "Lager") }
                            .font(.caption.bold()).padding(.horizontal, 8).padding(.vertical, 4).background(Color.orange.opacity(0.1)).foregroundColor(.orange).cornerRadius(6)
                    }
                }
            }
            if isEditing { TextField("Name", text: $editedName).font(.largeTitle.bold()).textFieldStyle(.roundedBorder) }
            else { Text(product?.name ?? lexikonEntry?.name ?? "").font(.largeTitle.bold()) }
        }
        .padding().background(LinearGradient(colors: [Color.blue.opacity(0.2), Color(.systemGroupedBackground)], startPoint: .top, endPoint: .bottom))
    }
    
    private var infoBlock: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("BESCHREIBUNG").font(.caption.bold()).foregroundColor(.secondary)
                Spacer()
                Button(isEditing ? "Speichern" : "Korrigieren") { if isEditing { saveChanges() } else { startEditing() } }
                    .font(.caption.bold()).padding(5).background(isEditing ? Color.green : Color.blue.opacity(0.1)).foregroundColor(isEditing ? .white : .blue).cornerRadius(6)
            }
            if isEditing { TextEditor(text: $editedDescription).frame(minHeight: 150).padding(4).background(Color(.systemGray6)).cornerRadius(8) }
            else {
                Text(LocalizedStringKey(product?.beschreibung ?? lexikonEntry?.beschreibung ?? "Keine Daten."))
                    .font(.body).lineSpacing(4)
                    .environment(\.openURL, OpenURLAction { url in
                        self.selectedLinkID = url.absoluteString
                        self.navigateToLink = true
                        return .handled
                    })
            }
        }
        .padding().background(Color(.secondarySystemGroupedBackground)).cornerRadius(12)
    }
    
    private var safetyPanel: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack { Image(systemName: "exclamationmark.octagon.fill"); Text("ALLERGEN-CHECK").font(.headline.bold()); Spacer() }.padding().background(Color.red).foregroundColor(.white)
            VStack(alignment: .leading, spacing: 15) {
                if let p = product, !p.allergene.isEmpty {
                    let codes = p.allergene.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespaces) }
                    ForEach(codes, id: \.self) { code in
                        HStack { Text(code.uppercased()).font(.system(size: 16, weight: .black)).frame(width: 40, height: 30).background(Color.red).foregroundColor(.white).cornerRadius(4)
                            Text(GastroLegende.erklärung(for: code).uppercased()).font(.subheadline.bold())
                        }
                    }
                }
            }.padding().background(Color.red.opacity(0.05))
        }.cornerRadius(12).overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.red, lineWidth: 2))
    }
    
    @ViewBuilder
    private func recipeSection(for recipe: Recipe) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("REZEPTUR").font(.caption.bold())
            if let items = recipe.komponenten { ForEach(items) { item in HStack { Text(item.name); Spacer(); Text("\(item.menge) \(item.einheit)").bold() }; Divider() } }
        }.padding().background(Color(.secondarySystemGroupedBackground)).cornerRadius(12)
    }
    
    private func actionButton(title: String, icon: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) { VStack { Image(systemName: icon); Text(title).font(.caption2.bold()) }.frame(maxWidth: .infinity).padding(10).background(color.opacity(0.1)).foregroundColor(color).cornerRadius(8) }
    }
    
    @ViewBuilder
    private func nutritionGrid(for p: Product) -> some View {
        HStack { nutritionItem(label: "KCAL", value: p.kcal); nutritionItem(label: "FETT", value: p.fett); nutritionItem(label: "ZUCKER", value: p.zucker) }
    }
    
    private func nutritionItem(label: String, value: String) -> some View {
        VStack { Text(value).bold(); Text(label).font(.caption2) }.frame(maxWidth: .infinity).padding(8).background(Color.gray.opacity(0.1)).cornerRadius(8)
    }
}

// MARK: - HILFSSTRUKTUREN

struct SafariWebView: UIViewControllerRepresentable {
    let url: URL
    func makeUIViewController(context: Context) -> SFSafariViewController { SFSafariViewController(url: url) }
    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {}
}

struct UniversalDetailSelector: View {
    let queryID: String
    @Query private var products: [Product]
    @Query private var entries: [LexikonEntry]
    var body: some View {
        if let p = products.first(where: { $0.id == queryID || $0.name.lowercased() == queryID.lowercased() }) { ProductDetailView(product: p) }
        else if let e = entries.first(where: { $0.code == queryID || $0.name.lowercased() == queryID.lowercased() }) { ProductDetailView(entry: e) }
        else { ContentUnavailableView("Nicht gefunden", systemImage: "magnifyingglass") }
    }
}

struct GastroLegende {
    static let allergene = ["a":"Gluten", "b":"Krebstiere", "c":"Eier", "d":"Fisch", "e":"Erdnüsse", "f":"Soja", "g":"Milch/Laktose", "h":"Nüsse", "i":"Sellerie", "j":"Senf", "k":"Sesam", "l":"Sulfite", "m":"Lupinen", "n":"Weichtiere"]
    static func erklärung(for code: String) -> String { allergene[code.lowercased().trimmingCharacters(in: .whitespaces)] ?? "Zusatzstoff" }
}
