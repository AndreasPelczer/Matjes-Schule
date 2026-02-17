//
//  GarmethodeListView.swift
//  MatjesSchule
//
//  Garmethoden nach Typ gruppiert
//

import SwiftUI

struct GarmethodeListView: View {
    let garmethoden: [Garmethode]

    private var typen: [String] {
        LexikonLoader.garmethodenTypen(in: garmethoden)
    }

    private func methodenFuerTyp(_ typ: String) -> [Garmethode] {
        garmethoden.filter { $0.typ == typ }
    }

    private var typIcon: [String: String] {
        [
            "Feuchte Garmethode": "drop.fill",
            "Trockene Garmethode": "flame.fill",
            "Kombiniert (feucht)": "humidity.fill",
            "Kombinierte Garmethode": "humidity.fill",
            "Chemisch / ohne Wärme": "flask.fill",
        ]
    }

    private var typColor: [String: Color] {
        [
            "Feuchte Garmethode": .blue,
            "Trockene Garmethode": .orange,
            "Kombiniert (feucht)": .teal,
            "Kombinierte Garmethode": .teal,
            "Chemisch / ohne Wärme": .purple,
        ]
    }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            LinearGradient(
                colors: [Color.orange.opacity(0.3), Color.black],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {
                    ForEach(typen, id: \.self) { typ in
                        let methoden = methodenFuerTyp(typ)
                        VStack(alignment: .leading, spacing: 10) {
                            HStack(spacing: 8) {
                                Image(systemName: typIcon[typ] ?? "flame")
                                    .foregroundColor(typColor[typ] ?? .orange)
                                    .font(.system(size: 14))
                                Text(typ)
                                    .font(.system(size: 16, weight: .bold, design: .rounded))
                                    .foregroundColor(typColor[typ] ?? .orange)
                                Text("(\(methoden.count))")
                                    .font(.system(size: 13, weight: .medium, design: .rounded))
                                    .foregroundColor(.gray)
                            }
                            .padding(.horizontal, 24)

                            VStack(spacing: 0) {
                                ForEach(methoden) { methode in
                                    NavigationLink(destination: GarmethodeDetailView(garmethode: methode)) {
                                        GarmethodeRow(garmethode: methode, color: typColor[methode.typ] ?? .orange)
                                    }
                                    if methode.id != methoden.last?.id {
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
                                            .stroke((typColor[typ] ?? .orange).opacity(0.12), lineWidth: 1)
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
        .navigationTitle("Garmethoden")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }
}

// MARK: - Garmethode Zeile

struct GarmethodeRow: View {
    let garmethode: Garmethode
    let color: Color

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 3) {
                Text(garmethode.name)
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                    .lineLimit(1)
                HStack(spacing: 8) {
                    Text(garmethode.temperatur)
                        .font(.system(size: 12, weight: .bold, design: .monospaced))
                        .foregroundColor(color.opacity(0.8))
                    Text("·")
                        .foregroundColor(.gray)
                    Text(garmethode.medium)
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
