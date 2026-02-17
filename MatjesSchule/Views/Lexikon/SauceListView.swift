//
//  SauceListView.swift
//  MatjesSchule
//
//  Saucen & Fonds nach Typ gruppiert
//

import SwiftUI

struct SauceListView: View {
    let saucen: [Sauce]

    private var typen: [String] {
        LexikonLoader.saucenTypen(in: saucen)
    }

    private func saucenFuerTyp(_ typ: String) -> [Sauce] {
        saucen.filter { $0.typ == typ }
    }

    private var typIcon: [String: String] {
        [
            "Grundfond": "flame.fill",
            "Grundsoße (Muttersoße)": "drop.fill",
            "Aufgeschlagene Soße (warm)": "wind",
            "Buttersoße": "circle.fill",
            "Ableitung Hollandaise": "arrow.turn.down.right",
            "Ableitung Béchamel": "arrow.turn.down.right",
            "Ableitung Velouté": "arrow.turn.down.right",
            "Ableitung Espagnole": "arrow.turn.down.right",
            "Ableitung Tomate": "arrow.turn.down.right",
        ]
    }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            LinearGradient(
                colors: [Color.purple.opacity(0.3), Color.black],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {
                    ForEach(typen, id: \.self) { typ in
                        let items = saucenFuerTyp(typ)
                        VStack(alignment: .leading, spacing: 10) {
                            HStack(spacing: 8) {
                                Image(systemName: typIcon[typ] ?? "drop.fill")
                                    .foregroundColor(.purple)
                                    .font(.system(size: 14))
                                Text(typ)
                                    .font(.system(size: 16, weight: .bold, design: .rounded))
                                    .foregroundColor(.purple)
                                Text("(\(items.count))")
                                    .font(.system(size: 13, weight: .medium, design: .rounded))
                                    .foregroundColor(.gray)
                            }
                            .padding(.horizontal, 24)

                            VStack(spacing: 0) {
                                ForEach(items) { sauce in
                                    NavigationLink(destination: SauceDetailView(sauce: sauce)) {
                                        SauceRow(sauce: sauce)
                                    }
                                    if sauce.id != items.last?.id {
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
                                            .stroke(Color.purple.opacity(0.12), lineWidth: 1)
                                    )
                            )
                            .padding(.horizontal, 20)
                        }
                    }
                }
                .padding(.top, 10)
                .padding(.bottom, 30)
            }
        }
        .navigationTitle("Saucen & Fonds")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }
}

// MARK: - Sauce Zeile

struct SauceRow: View {
    let sauce: Sauce

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 3) {
                Text(sauce.name)
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                    .lineLimit(1)
                Text(sauce.basis)
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(.gray)
                    .lineLimit(1)
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
