//
//  AusbilderDashboardView.swift
//  MatjesSchule
//
//  Fortschritts-Dashboard fuer Ausbilder
//

import SwiftUI

struct AusbilderDashboardView: View {
    @EnvironmentObject var appState: AppState

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

                        // Platzhalter-Karten
                        DashboardCard(
                            title: "Klassen",
                            value: "0",
                            subtitle: "Aktive Klassen",
                            icon: "person.3.fill",
                            color: .blue
                        )

                        DashboardCard(
                            title: "Sch\u{00FC}ler",
                            value: "0",
                            subtitle: "Eingeschriebene Sch\u{00FC}ler",
                            icon: "person.fill",
                            color: .green
                        )

                        DashboardCard(
                            title: "Durchschnitt",
                            value: "-%",
                            subtitle: "Gesamtfortschritt",
                            icon: "chart.bar.fill",
                            color: .orange
                        )

                        // Hinweis
                        Text("Dashboard wird mit CloudKit-Integration in Phase 4 vollst\u{00E4}ndig implementiert.")
                            .font(.system(size: 13, weight: .medium, design: .rounded))
                            .foregroundColor(.white.opacity(0.5))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                            .padding(.top, 20)
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
