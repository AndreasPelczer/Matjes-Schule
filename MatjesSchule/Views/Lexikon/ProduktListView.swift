//
//  ProduktListView.swift
//  MatjesSchule
//
//  Produkte nach Kategorien gruppiert
//

import SwiftUI

struct ProduktListView: View {
    let produkte: [Produkt]

    @State private var searchText = ""

    private var kategorien: [String] {
        LexikonLoader.produktKategorien(in: produkte)
    }

    private var filteredProdukte: [Produkt] {
        guard !searchText.isEmpty else { return produkte }
        let query = searchText.lowercased()
        return produkte.filter {
            $0.name.lowercased().contains(query) ||
            $0.kategorie.lowercased().contains(query)
        }
    }

    private func produkteInKategorie(_ kategorie: String) -> [Produkt] {
        filteredProdukte.filter { $0.kategorie == kategorie }
    }

    private var kategorieIcon: [String: String] {
        [
            "Kartoffeln": "leaf.fill",
            "Gemüse": "carrot.fill",
            "Fleisch": "fork.knife",
            "Fisch": "fish.fill",
            "Milchprodukte": "cup.and.saucer.fill",
            "Gewürze": "leaf.circle.fill",
        ]
    }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            LinearGradient(
                colors: [Color.green.opacity(0.3), Color.black],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 16) {
                    // Suchfeld
                    HStack(spacing: 10) {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        TextField("Produkt suchen...", text: $searchText)
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
                    .padding(.top, 10)

                    // Kategorien
                    ForEach(kategorien, id: \.self) { kategorie in
                        let items = produkteInKategorie(kategorie)
                        if !items.isEmpty {
                            VStack(alignment: .leading, spacing: 10) {
                                HStack(spacing: 8) {
                                    Image(systemName: kategorieIcon[kategorie] ?? "circle.fill")
                                        .foregroundColor(.green)
                                        .font(.system(size: 14))
                                    Text(kategorie)
                                        .font(.system(size: 16, weight: .bold, design: .rounded))
                                        .foregroundColor(.green)
                                    Text("(\(items.count))")
                                        .font(.system(size: 13, weight: .medium, design: .rounded))
                                        .foregroundColor(.gray)
                                }
                                .padding(.horizontal, 24)

                                VStack(spacing: 0) {
                                    ForEach(items) { produkt in
                                        NavigationLink(destination: ProduktDetailView(produkt: produkt)) {
                                            ProduktRow(produkt: produkt)
                                        }
                                        if produkt.id != items.last?.id {
                                            Divider()
                                                .background(Color.white.opacity(0.08))
                                                .padding(.leading, 16)
                                        }
                                    }
                                }
                                .padding(.vertical, 4)
                                .background(
                                    RoundedRectangle(cornerRadius: 14)
                                        .fill(Color.white.opacity(0.06))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 14)
                                                .stroke(Color.green.opacity(0.12), lineWidth: 1)
                                        )
                                )
                                .padding(.horizontal, 20)
                            }
                        }
                    }
                }
                .padding(.bottom, 30)
            }
        }
        .navigationTitle("Produkte")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }
}

// MARK: - Produkt Zeile

struct ProduktRow: View {
    let produkt: Produkt

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 3) {
                Text(produkt.name)
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                    .lineLimit(1)

                if !produkt.allergene.isEmpty {
                    HStack(spacing: 4) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 10))
                            .foregroundColor(.yellow)
                        Text(produkt.allergene)
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(.yellow.opacity(0.8))
                            .lineLimit(1)
                    }
                } else {
                    Text("\(produkt.naehrwerte.kcal) kcal")
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundColor(.gray)
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .foregroundColor(.gray.opacity(0.5))
                .font(.system(size: 12))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .contentShape(Rectangle())
    }
}
