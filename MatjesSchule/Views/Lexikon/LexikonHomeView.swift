//
//  LexikonHomeView.swift
//  MatjesSchule
//
//  Lexikon-Hauptansicht mit Suche und 3 Kategorien
//

import SwiftUI

struct LexikonHomeView: View {
    let produkte: [Produkt]
    let garmethoden: [Garmethode]
    let saucen: [Sauce]

    @State private var searchText = ""
    @State private var headerVisible = false

    private var filteredProdukte: [Produkt] {
        guard !searchText.isEmpty else { return [] }
        let query = searchText.lowercased()
        return produkte.filter {
            $0.name.lowercased().contains(query) ||
            $0.kategorie.lowercased().contains(query) ||
            $0.beschreibung.lowercased().contains(query)
        }
    }

    private var filteredGarmethoden: [Garmethode] {
        guard !searchText.isEmpty else { return [] }
        let query = searchText.lowercased()
        return garmethoden.filter {
            $0.name.lowercased().contains(query) ||
            $0.typ.lowercased().contains(query) ||
            $0.beschreibung.lowercased().contains(query)
        }
    }

    private var filteredSaucen: [Sauce] {
        guard !searchText.isEmpty else { return [] }
        let query = searchText.lowercased()
        return saucen.filter {
            $0.name.lowercased().contains(query) ||
            $0.typ.lowercased().contains(query) ||
            $0.beschreibung.lowercased().contains(query)
        }
    }

    private var isSearching: Bool {
        !searchText.isEmpty
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                LinearGradient(
                    colors: [Color.teal.opacity(0.4), Color.black],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        // Header
                        VStack(spacing: 8) {
                            Image(systemName: "book.fill")
                                .font(.system(size: 40))
                                .foregroundColor(.teal)
                                .shadow(color: .teal.opacity(0.5), radius: 10)

                            Text("Lexikon")
                                .font(.system(size: 28, weight: .black, design: .rounded))
                                .foregroundColor(.white)

                            Text("Küchenfachkunde nachschlagen")
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                .foregroundColor(.gray)
                        }
                        .padding(.top, 20)
                        .opacity(headerVisible ? 1 : 0)
                        .offset(y: headerVisible ? 0 : -15)

                        // Suchfeld
                        HStack(spacing: 10) {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.gray)
                            TextField("Suchen...", text: $searchText)
                                .foregroundColor(.white)
                                .autocorrectionDisabled()
                            if !searchText.isEmpty {
                                Button {
                                    searchText = ""
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.white.opacity(0.08))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.white.opacity(0.15), lineWidth: 1)
                                )
                        )
                        .padding(.horizontal, 20)

                        if isSearching {
                            // Suchergebnisse
                            searchResultsView
                        } else {
                            // Kategorien
                            kategorienView
                        }
                    }
                    .padding(.bottom, 30)
                }
            }
            .toolbar(.hidden, for: .navigationBar)
            .onAppear {
                withAnimation(.easeOut(duration: 0.5)) {
                    headerVisible = true
                }
            }
        }
    }

    // MARK: - Kategorien Übersicht

    private var kategorienView: some View {
        VStack(spacing: 16) {
            NavigationLink(destination: ProduktListView(produkte: produkte)) {
                LexikonKategorieCard(
                    icon: "carrot.fill",
                    title: "Produkte & Warenkunde",
                    subtitle: "\(produkte.count) Einträge",
                    count: LexikonLoader.produktKategorien(in: produkte).count,
                    countLabel: "Kategorien",
                    color: .green
                )
            }

            NavigationLink(destination: GarmethodeListView(garmethoden: garmethoden)) {
                LexikonKategorieCard(
                    icon: "flame.fill",
                    title: "Garmethoden",
                    subtitle: "\(garmethoden.count) Einträge",
                    count: LexikonLoader.garmethodenTypen(in: garmethoden).count,
                    countLabel: "Typen",
                    color: .orange
                )
            }

            NavigationLink(destination: SauceListView(saucen: saucen)) {
                LexikonKategorieCard(
                    icon: "drop.fill",
                    title: "Saucen & Fonds",
                    subtitle: "\(saucen.count) Einträge",
                    count: LexikonLoader.saucenTypen(in: saucen).count,
                    countLabel: "Typen",
                    color: .purple
                )
            }
        }
        .padding(.horizontal, 20)
    }

    // MARK: - Suchergebnisse

    private var searchResultsView: some View {
        VStack(spacing: 16) {
            let totalResults = filteredProdukte.count + filteredGarmethoden.count + filteredSaucen.count

            if totalResults == 0 {
                VStack(spacing: 12) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 40))
                        .foregroundColor(.gray.opacity(0.5))
                    Text("Keine Ergebnisse")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(.gray)
                }
                .padding(.top, 40)
            } else {
                Text("\(totalResults) Ergebnis\(totalResults == 1 ? "" : "se")")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(.gray)

                if !filteredProdukte.isEmpty {
                    SearchSection(title: "Produkte", color: .green) {
                        ForEach(filteredProdukte) { produkt in
                            NavigationLink(destination: ProduktDetailView(produkt: produkt)) {
                                SearchResultRow(
                                    name: produkt.name,
                                    detail: produkt.kategorie,
                                    color: .green
                                )
                            }
                        }
                    }
                }

                if !filteredGarmethoden.isEmpty {
                    SearchSection(title: "Garmethoden", color: .orange) {
                        ForEach(filteredGarmethoden) { methode in
                            NavigationLink(destination: GarmethodeDetailView(garmethode: methode)) {
                                SearchResultRow(
                                    name: methode.name,
                                    detail: methode.typ,
                                    color: .orange
                                )
                            }
                        }
                    }
                }

                if !filteredSaucen.isEmpty {
                    SearchSection(title: "Saucen & Fonds", color: .purple) {
                        ForEach(filteredSaucen) { sauce in
                            NavigationLink(destination: SauceDetailView(sauce: sauce)) {
                                SearchResultRow(
                                    name: sauce.name,
                                    detail: sauce.typ,
                                    color: .purple
                                )
                            }
                        }
                    }
                }
            }
        }
        .padding(.horizontal, 20)
    }
}

// MARK: - Kategorie-Karte

struct LexikonKategorieCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let count: Int
    let countLabel: String
    let color: Color

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 28))
                .foregroundColor(color)
                .frame(width: 50, height: 50)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(color.opacity(0.15))
                )

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.system(size: 17, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                HStack(spacing: 8) {
                    Text(subtitle)
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundColor(.gray)
                    Text("·")
                        .foregroundColor(.gray)
                    Text("\(count) \(countLabel)")
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundColor(color.opacity(0.8))
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
                .font(.system(size: 14, weight: .bold))
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 18)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.08))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(color.opacity(0.2), lineWidth: 1)
                )
        )
    }
}

// MARK: - Such-Ergebnis Zeile

struct SearchResultRow: View {
    let name: String
    let detail: String
    let color: Color

    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(color.opacity(0.3))
                .frame(width: 8, height: 8)

            VStack(alignment: .leading, spacing: 2) {
                Text(name)
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                Text(detail)
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(.gray)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .foregroundColor(.gray.opacity(0.5))
                .font(.system(size: 12))
        }
        .padding(.vertical, 8)
    }
}

// MARK: - Such-Sektion

struct SearchSection<Content: View>: View {
    let title: String
    let color: Color
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundColor(color)
                .padding(.leading, 4)

            VStack(spacing: 0) {
                content
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color.white.opacity(0.06))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(color.opacity(0.15), lineWidth: 1)
                    )
            )
        }
    }
}
