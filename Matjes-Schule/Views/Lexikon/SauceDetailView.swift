//
//  SauceDetailView.swift
//  MatjesSchule
//
//  Detailansicht für eine einzelne Sauce/Fond
//

import SwiftUI

struct SauceDetailView: View {
    let sauce: Sauce

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
                    // Header
                    VStack(spacing: 8) {
                        Text(sauce.typ)
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                            .foregroundColor(.purple)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 4)
                            .background(
                                Capsule().fill(Color.purple.opacity(0.15))
                            )

                        Text(sauce.name)
                            .font(.system(size: 24, weight: .black, design: .rounded))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 20)

                    // Basis
                    DetailSection(title: "Basis / Zutaten", icon: "list.bullet.rectangle.fill", color: .orange) {
                        Text(sauce.basis)
                            .font(.system(size: 15, weight: .medium, design: .rounded))
                            .foregroundColor(.white.opacity(0.9))
                    }

                    // Beschreibung / Technik
                    DetailSection(title: "Zubereitung & Technik", icon: "text.book.closed.fill", color: .purple) {
                        Text(sauce.beschreibung)
                            .font(.system(size: 15, weight: .medium, design: .rounded))
                            .foregroundColor(.white.opacity(0.9))
                            .lineSpacing(4)
                    }

                    // Verwendung
                    DetailSection(title: "Verwendung", icon: "fork.knife", color: .green) {
                        Text(sauce.verwendung)
                            .font(.system(size: 15, weight: .medium, design: .rounded))
                            .foregroundColor(.white.opacity(0.9))
                    }

                    // Lagerung
                    DetailSection(title: "Lagerung", icon: "thermometer.snowflake", color: .blue) {
                        Text(sauce.lagerung)
                            .font(.system(size: 15, weight: .medium, design: .rounded))
                            .foregroundColor(.white.opacity(0.9))
                    }

                    // Ableitungen
                    if !sauce.ableitungen.isEmpty {
                        DetailSection(title: "Ableitungen", icon: "arrow.triangle.branch", color: .teal) {
                            Text(sauce.ableitungen)
                                .font(.system(size: 15, weight: .medium, design: .rounded))
                                .foregroundColor(.white.opacity(0.9))
                        }
                    }
                }
                .padding(.bottom, 40)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }
}
