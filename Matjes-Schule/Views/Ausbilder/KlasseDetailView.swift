//
//  KlasseDetailView.swift
//  MatjesSchule
//
//  Detailansicht einer Klasse mit Schueler-Liste und Fortschritten
//

import SwiftUI

struct KlasseDetailView: View {
    let klasse: Klasse
    @State private var schueler: [Schueler] = []

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {
                    // Klassen-Info
                    VStack(spacing: 8) {
                        Text(klasse.name)
                            .font(.system(size: 24, weight: .black, design: .rounded))
                            .foregroundColor(.white)
                        Text("\(klasse.lehrjahr). Lehrjahr - \(klasse.schuljahr)")
                            .font(.system(size: 15, weight: .medium, design: .rounded))
                            .foregroundColor(.white.opacity(0.7))
                    }
                    .padding(.top, 20)

                    // Schueler-Liste
                    if schueler.isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: "person.badge.plus")
                                .font(.system(size: 40))
                                .foregroundColor(.gray)
                            Text("Noch keine Sch\u{00FC}ler in dieser Klasse")
                                .font(.system(size: 15, weight: .medium, design: .rounded))
                                .foregroundColor(.white.opacity(0.6))
                        }
                        .padding(.top, 40)
                    } else {
                        ForEach(schueler) { s in
                            SchuelerRow(schueler: s)
                        }
                    }
                }
                .padding()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }
}

struct SchuelerRow: View {
    let schueler: Schueler

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "person.circle.fill")
                .font(.system(size: 36))
                .foregroundColor(.orange)

            VStack(alignment: .leading, spacing: 4) {
                Text(schueler.vollstaendigerName)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                Text(schueler.istAktiv ? "Aktiv" : "Inaktiv")
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundColor(schueler.istAktiv ? .green : .gray)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .foregroundColor(.white.opacity(0.3))
        }
        .padding()
        .background(Color.white.opacity(0.08))
        .cornerRadius(12)
    }
}
