//
//  KlassenListView.swift
//  MatjesSchule
//
//  Klassenverwaltung fuer Ausbilder
//

import SwiftUI

struct KlassenListView: View {
    @State private var klassen: [Klasse] = []
    @State private var showNeueKlasse = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()

                if klassen.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "person.3.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.gray)

                        Text("Noch keine Klassen")
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundColor(.white)

                        Text("Erstelle deine erste Klasse, um Sch\u{00FC}ler einzuladen.")
                            .font(.system(size: 15, weight: .medium, design: .rounded))
                            .foregroundColor(.white.opacity(0.6))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)

                        Button(action: { showNeueKlasse = true }) {
                            Label("Neue Klasse", systemImage: "plus.circle.fill")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.orange)
                                .cornerRadius(12)
                        }
                    }
                } else {
                    List(klassen) { klasse in
                        NavigationLink(destination: KlasseDetailView(klasse: klasse)) {
                            HStack {
                                Image(systemName: "person.3.fill")
                                    .foregroundColor(.orange)
                                VStack(alignment: .leading) {
                                    Text(klasse.name)
                                        .font(.system(size: 16, weight: .bold, design: .rounded))
                                    Text("\(klasse.lehrjahr). Lehrjahr - \(klasse.schuljahr)")
                                        .font(.system(size: 13, weight: .medium, design: .rounded))
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("Klassen")
            .navigationBarTitleDisplayMode(.large)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { showNeueKlasse = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
        }
    }
}
