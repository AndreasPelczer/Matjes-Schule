//
//  ProduktDetailView.swift
//  MatjesSchule
//
//  Detailansicht für ein einzelnes Produkt
//

import SwiftUI

struct ProduktDetailView: View {
    let produkt: Produkt

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
                VStack(spacing: 20) {
                    // Header
                    VStack(spacing: 8) {
                        Text(produkt.kategorie)
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                            .foregroundColor(.green)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 4)
                            .background(
                                Capsule().fill(Color.green.opacity(0.15))
                            )

                        Text(produkt.name)
                            .font(.system(size: 24, weight: .black, design: .rounded))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 20)

                    // Allergen-Warnung
                    if !produkt.allergene.isEmpty {
                        HStack(spacing: 10) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.yellow)
                                .font(.system(size: 20))
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Allergen")
                                    .font(.system(size: 12, weight: .bold, design: .rounded))
                                    .foregroundColor(.yellow)
                                Text(produkt.allergene)
                                    .font(.system(size: 14, weight: .medium, design: .rounded))
                                    .foregroundColor(.white)
                            }
                            Spacer()
                        }
                        .padding(14)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.yellow.opacity(0.1))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.yellow.opacity(0.3), lineWidth: 1)
                                )
                        )
                        .padding(.horizontal, 20)
                    }

                    // Beschreibung
                    DetailSection(title: "Beschreibung", icon: "text.book.closed.fill", color: .green) {
                        Text(produkt.beschreibung)
                            .font(.system(size: 15, weight: .medium, design: .rounded))
                            .foregroundColor(.white.opacity(0.9))
                            .lineSpacing(4)
                    }

                    // Lagerung
                    DetailSection(title: "Lagerung", icon: "thermometer.snowflake", color: .blue) {
                        Text(produkt.lagerung)
                            .font(.system(size: 15, weight: .medium, design: .rounded))
                            .foregroundColor(.white.opacity(0.9))
                            .lineSpacing(4)
                    }

                    // Saison
                    DetailSection(title: "Saison", icon: "calendar", color: .orange) {
                        Text(produkt.saison)
                            .font(.system(size: 15, weight: .medium, design: .rounded))
                            .foregroundColor(.white.opacity(0.9))
                    }

                    // Nährwerte
                    DetailSection(title: "Nährwerte (pro 100g)", icon: "chart.bar.fill", color: .teal) {
                        HStack(spacing: 12) {
                            NaehrwertBadge(label: "kcal", value: "\(produkt.naehrwerte.kcal)", color: .orange)
                            NaehrwertBadge(label: "Fett", value: formatDecimal(produkt.naehrwerte.fett), color: .yellow)
                            NaehrwertBadge(label: "Eiweiß", value: formatDecimal(produkt.naehrwerte.eiweiss), color: .red)
                            NaehrwertBadge(label: "KH", value: formatDecimal(produkt.naehrwerte.kohlenhydrate), color: .green)
                        }
                    }

                    // Zusatzstoffe
                    if !produkt.zusatzstoffe.isEmpty {
                        DetailSection(title: "Zusatzstoffe", icon: "flask.fill", color: .gray) {
                            Text(produkt.zusatzstoffe)
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

    private func formatDecimal(_ value: Double) -> String {
        String(format: "%.1fg", value)
    }
}

// MARK: - Detail-Sektion

struct DetailSection<Content: View>: View {
    let title: String
    let icon: String
    let color: Color
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.system(size: 14))
                Text(title)
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(color)
            }

            content
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.white.opacity(0.06))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(color.opacity(0.15), lineWidth: 1)
                )
        )
        .padding(.horizontal, 20)
    }
}

// MARK: - Nährwert-Badge

struct NaehrwertBadge: View {
    let label: String
    let value: String
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 16, weight: .bold, design: .monospaced))
                .foregroundColor(.white)
            Text(label)
                .font(.system(size: 11, weight: .medium, design: .rounded))
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(color.opacity(0.1))
        )
    }
}
