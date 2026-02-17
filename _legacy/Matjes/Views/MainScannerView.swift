import SwiftUI
import SwiftData

// MARK: - Suchergebnis-Logik
enum SearchResult: Identifiable, Hashable {
    case product(Product)
    case lexikon(LexikonEntry)
    
    var id: String {
        switch self {
        case .product(let p): return p.id
        case .lexikon(let e): return e.code
        }
    }
    
    var displayName: String {
        switch self {
        case .product(let p): return p.name
        case .lexikon(let e): return e.name
        }
    }
}

struct MainScannerView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel: ContentViewModel
    
    @Query(sort: \Product.name) private var allProducts: [Product]
    @Query(sort: \LexikonEntry.name) private var allLexikonEntries: [LexikonEntry]
    
    @State private var searchText: String = ""
    @State private var selectedSource: String = "Alle"
    @State private var selectedCategory: String = "Alle"
    @State private var selectedResult: SearchResult?
    @State private var showAddSheet = false
    @State private var showInventorySheet = false 
    
    init(modelContext: ModelContext) {
        _viewModel = StateObject(wrappedValue: ContentViewModel(modelContext: modelContext))
    }
    
    var body: some View {
        NavigationSplitView {
            VStack(spacing: 0) {
                Picker("Quelle", selection: $selectedSource) {
                    Text("Alle").tag("Alle")
                    Text("Natur").tag("Natur")
                    Text("Hering").tag("Hering")
                    Text("Lieferant").tag("Lieferant")
                }
                .pickerStyle(.segmented).padding()

                TextField("Suchen...", text: $searchText)
                    .padding(10).background(Color(.systemGray6)).cornerRadius(8).padding(.horizontal)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        hannesChip(title: "Alle")
                        ForEach(viewModel.dynamicCategories, id: \.self) { cat in
                            hannesChip(title: cat)
                        }
                    }.padding()
                }
                
                List(combinedResults, selection: $selectedResult) { result in
                    NavigationLink(value: result) { rowView(for: result) }
                }
                .listStyle(.sidebar)
            }
            .navigationTitle("Matjes")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { showInventorySheet = true }) {
                        HStack(spacing: 4) {
                            Image(systemName: "snowflake")
                            Text("\(allProducts.filter { $0.stockQuantity > 0 }.count)")
                                .font(.caption.bold())
                        }
                        .foregroundColor(.blue)
                        .padding(6)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(8)
                    }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button(action: { showAddSheet = true }) {
                        Image(systemName: "plus.circle.fill")
                    }
                }
            }
        } detail: {
            if let res = selectedResult {
                switch res {
                case .product(let p): ProductDetailView(product: p)
                case .lexikon(let e): ProductDetailView(entry: e)
                }
            } else { welcomeScreen }
        }
        .sheet(isPresented: $showAddSheet) {
            AddEntryView().environment(\.modelContext, modelContext)
        }
        .sheet(isPresented: $showInventorySheet) {
            inventorySheetView
        }
        .onAppear {
            viewModel.updateCategories(from: allProducts, and: allLexikonEntries)
        }
    } // HIER endet der body

    // MARK: - Inventory Sheet (Sub-View)
    private var inventorySheetView: some View {
        NavigationStack {
            List {
                let inStock = allProducts.filter { $0.stockQuantity > 0 }
                
                if inStock.isEmpty {
                    ContentUnavailableView("Kühlhaus leer", systemImage: "snowflake", description: Text("Erhöhe den Bestand in der Produkt-Detailansicht."))
                } else {
                    ForEach(inStock) { p in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(p.name).bold()
                                Text(p.category).font(.caption).foregroundColor(.secondary)
                            }
                            Spacer()
                            Text("\(String(format: "%.1f", p.stockQuantity)) \(p.stockUnit)")
                                .font(.headline)
                                .padding(6)
                                .background(Color.blue.opacity(0.1))
                                .cornerRadius(6)
                        }
                    }
                }
            }
            .navigationTitle("Aktueller Bestand")
            .toolbar {
                Button("Fertig") { showInventorySheet = false }
            }
        }
    }

    // MARK: - Hilfs-Views (Chips & Reihen)
    private func hannesChip(title: String) -> some View {
        Button(title) { selectedCategory = title }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(selectedCategory == title ? Color.blue : Color.gray.opacity(0.2))
            .foregroundColor(selectedCategory == title ? .white : .primary)
            .cornerRadius(20)
    }

    @ViewBuilder
    private func rowView(for result: SearchResult) -> some View {
        switch result {
        case .product(let p):
            HStack {
                RoundedRectangle(cornerRadius: 2)
                    .fill(p.dataSource == "Natur" ? .green : .blue)
                    .frame(width: 4, height: 35)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(p.name.uppercased()).bold()
                    Text(p.category).font(.caption).foregroundColor(.secondary)
                }
                Spacer()
                HStack(spacing: 4) {
                    if !p.allergene.isEmpty { Circle().fill(.red).frame(width: 8, height: 8) }
                    if !p.zusatzstoffe.isEmpty { Circle().fill(.yellow).frame(width: 8, height: 8) }
                }
            }
        case .lexikon(let e):
            HStack {
                RoundedRectangle(cornerRadius: 2).fill(.orange).frame(width: 4, height: 35)
                VStack(alignment: .leading, spacing: 2) {
                    Text(e.name.uppercased()).bold()
                    Text(e.kategorie ?? "Lexikon").font(.caption).foregroundColor(.secondary)
                }
            }
        }
    }

    private var combinedResults: [SearchResult] {
        let term = searchText.lowercased().folding(options: [.diacriticInsensitive, .caseInsensitive], locale: .current)
        
        let lexPart = allLexikonEntries.filter { e in
            let matchesSource = (selectedSource == "Alle" || selectedSource == "Hering")
            let matchesCat = (selectedCategory == "Alle" || e.kategorie == selectedCategory)
            let nameMatch = e.name.lowercased().folding(options: [.diacriticInsensitive, .caseInsensitive], locale: .current).contains(term)
            let descMatch = (e.beschreibung ?? "").lowercased().folding(options: [.diacriticInsensitive, .caseInsensitive], locale: .current).contains(term)
            return matchesSource && matchesCat && (searchText.isEmpty || nameMatch || descMatch)
        }.map { SearchResult.lexikon($0) }
        
        let prodPart = allProducts.filter { p in
            let matchesSource = (selectedSource == "Alle" || p.dataSource == selectedSource)
            let matchesCat = (selectedCategory == "Alle" || p.category == selectedCategory)
            let nameMatch = p.name.lowercased().folding(options: [.diacriticInsensitive, .caseInsensitive], locale: .current).contains(term)
            let descMatch = p.beschreibung.lowercased().folding(options: [.diacriticInsensitive, .caseInsensitive], locale: .current).contains(term)
            return matchesSource && matchesCat && (searchText.isEmpty || nameMatch || descMatch)
        }.map { SearchResult.product($0) }
        
        var seenIDs = Set<String>()
        var uniqueResults = [SearchResult]()
        for item in (lexPart + prodPart) {
            if !seenIDs.contains(item.id) {
                uniqueResults.append(item)
                seenIDs.insert(item.id)
            }
        }
        return uniqueResults.sorted { $0.displayName < $1.displayName }
    }

    private var welcomeScreen: some View {
        VStack(spacing: 25) {
            Spacer()
            ZStack {
                Circle().fill(LinearGradient(colors: [.blue, .black], startPoint: .topLeading, endPoint: .bottomTrailing)).frame(width: 120, height: 120)
                Image(systemName: "fork.knife").font(.system(size: 60)).foregroundColor(.white)
            }.shadow(color: .blue.opacity(0.3), radius: 20)
            
            VStack(spacing: 10) {
                Text("GASTRO-GRID OMNI").font(.system(size: 40, weight: .black, design: .serif)).italic()
                Text("FRANKFURTER Gastro-Netzwerk").font(.headline).tracking(3).foregroundColor(.secondary)
            }
            
            HStack(spacing: 20) {
                VStack { Text("\(allProducts.count)").bold(); Text("PRODUKTE").font(.caption2) }
                Rectangle().fill(Color.gray.opacity(0.3)).frame(width: 1, height: 30)
                VStack { Text("\(allLexikonEntries.count)").bold(); Text("EINTRÄGE").font(.caption2) }
            }
            .padding().background(Color.blue.opacity(0.05)).cornerRadius(15)
            
            Spacer()
            Text("Version 1.0 | © 2026 Frankfurt am Main").font(.footnote).foregroundColor(.secondary).padding(.bottom, 20)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
    }
}
