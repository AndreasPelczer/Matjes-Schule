//
//  AusbilderDashboardView.swift
//  MatjesSchule
//
//  Fortschritts-Dashboard fuer Ausbilder
//

import SwiftUI

struct AusbilderDashboardView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var dataStore: DataStore

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        // Begruessung
                        if let ausbilder = appState.aktuellerAusbilder {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Willkommen,")
                                        .font(.system(size: 16, weight: .medium, design: .rounded))
                                        .foregroundColor(.white.opacity(0.7))
                                    Text(ausbilder.name)
                                        .font(.system(size: 24, weight: .black, design: .rounded))
                                        .foregroundColor(.white)
                                }
                                Spacer()
                                Image(systemName: "person.crop.circle.fill")
                                    .font(.system(size: 40))
                                    .foregroundColor(.orange)
                            }
                            .padding()
                        }

                        // Statistik-Karten
                        let anzahlKlassen = dataStore.klassenFuerAusbilder().count
                        let anzahlSchueler = dataStore.gesamtSchuelerAnzahl()
                        let durchschnitt = dataStore.durchschnittsFortschritt()

                        DashboardCard(
                            title: "Klassen",
                            value: "\(anzahlKlassen)",
                            subtitle: "Aktive Klassen",
                            icon: "person.3.fill",
                            color: .blue
                        )

                        DashboardCard(
                            title: "Sch\u{00FC}ler",
                            value: "\(anzahlSchueler)",
                            subtitle: "Eingeschriebene Sch\u{00FC}ler",
                            icon: "person.fill",
                            color: .green
                        )

                        DashboardCard(
                            title: "Durchschnitt",
                            value: anzahlSchueler > 0 ? "\(Int(durchschnitt))%" : "-%",
                            subtitle: "Gesamtfortschritt",
                            icon: "chart.bar.fill",
                            color: .orange
                        )

                        // Klassen-Uebersicht
                        if !dataStore.klassenFuerAusbilder().isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Klassen\u{00FC}bersicht")
                                    .font(.system(size: 18, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)
                                    .padding(.top, 10)

                                ForEach(dataStore.klassenFuerAusbilder()) { klasse in
                                    let schuelerInKlasse = dataStore.schuelerInKlasse(klasse.id)
                                    HStack {
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(klasse.name)
                                                .font(.system(size: 15, weight: .bold, design: .rounded))
                                                .foregroundColor(.white)
                                            Text("\(schuelerInKlasse.count) Sch\u{00FC}ler")
                                                .font(.system(size: 12, weight: .medium, design: .rounded))
                                                .foregroundColor(.white.opacity(0.5))
                                        }
                                        Spacer()
                                        Text("\(klasse.lehrjahr). LJ")
                                            .font(.system(size: 13, weight: .bold, design: .rounded))
                                            .foregroundColor(.orange)
                                    }
                                    .padding()
                                    .background(Color.white.opacity(0.06))
                                    .cornerRadius(10)
                                }
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Dashboard")
            .navigationBarTitleDisplayMode(.large)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
    }
}

struct DashboardCard: View {
    let title: String
    let value: String
    let subtitle: String
    let icon: String
    let color: Color

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 30))
                .foregroundColor(color)
                .frame(width: 50, height: 50)
                .background(color.opacity(0.15))
                .cornerRadius(12)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundColor(.white.opacity(0.6))
                Text(value)
                    .font(.system(size: 28, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                Text(subtitle)
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.5))
            }
            Spacer()
        }
        .padding()
        .background(Color.white.opacity(0.08))
        .cornerRadius(16)
    }
}
