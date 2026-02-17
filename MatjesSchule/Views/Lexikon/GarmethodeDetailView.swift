//
//  GarmethodeDetailView.swift
//  MatjesSchule
//
//  Detailansicht für eine einzelne Garmethode
//

import SwiftUI

struct GarmethodeDetailView: View {
    let garmethode: Garmethode

    private var typColor: Color {
        switch garmethode.typ {
        case "Feuchte Garmethode": return .blue
        case "Trockene Garmethode": return .orange
        case "Kombiniert (feucht)", "Kombinierte Garmethode": return .teal
        case "Chemisch / ohne Wärme": return .purple
        default: return .orange
        }
    }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            LinearGradient(
                colors: [typColor.opacity(0.3), Color.black],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    VStack(spacing: 8) {
                        Text(garmethode.typ)
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                            .foregroundColor(typColor)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 4)
                            .background(
                                Capsule().fill(typColor.opacity(0.15))
                            )

                        Text(garmethode.name)
                            .font(.system(size: 24, weight: .black, design: .rounded))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)

                        // Temperatur + Medium
                        HStack(spacing: 16) {
                            HStack(spacing: 6) {
                                Image(systemName: "thermometer.medium")
                                    .foregroundColor(.red)
                                    .font(.system(size: 14))
                                Text(garmethode.temperatur)
                                    .font(.system(size: 14, weight: .bold, design: .monospaced))
                                    .foregroundColor(.white)
                            }
                            HStack(spacing: 6) {
                                Image(systemName: "drop.fill")
                                    .foregroundColor(.blue)
                                    .font(.system(size: 14))
                                Text(garmethode.medium)
                                    .font(.system(size: 14, weight: .medium, design: .rounded))
                                    .foregroundColor(.white)
                            }
                        }
                        .padding(.top, 4)
                    }
                    .padding(.top, 20)

                    // Beschreibung
                    DetailSection(title: "Beschreibung", icon: "text.book.closed.fill", color: typColor) {
                        Text(garmethode.beschreibung)
                            .font(.system(size: 15, weight: .medium, design: .rounded))
                            .foregroundColor(.white.opacity(0.9))
                            .lineSpacing(4)
                    }

                    // Beispiele
                    DetailSection(title: "Beispiele", icon: "list.bullet", color: .green) {
                        Text(garmethode.beispiele)
                            .font(.system(size: 15, weight: .medium, design: .rounded))
                            .foregroundColor(.white.opacity(0.9))
                    }

                    // Praxistipps
                    DetailSection(title: "Praxistipps", icon: "lightbulb.fill", color: .yellow) {
                        Text(garmethode.praxistipps)
                            .font(.system(size: 15, weight: .medium, design: .rounded))
                            .foregroundColor(.white.opacity(0.9))
                            .lineSpacing(4)
                    }

                    // Geeignet für / Nicht geeignet für
                    HStack(alignment: .top, spacing: 12) {
                        // Geeignet
                        VStack(alignment: .leading, spacing: 8) {
                            HStack(spacing: 6) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                                    .font(.system(size: 13))
                                Text("Geeignet für")
                                    .font(.system(size: 13, weight: .bold, design: .rounded))
                                    .foregroundColor(.green)
                            }
                            ForEach(garmethode.geeignet_fuer, id: \.self) { item in
                                Text("· \(item)")
                                    .font(.system(size: 13, weight: .medium, design: .rounded))
                                    .foregroundColor(.white.opacity(0.8))
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.green.opacity(0.08))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.green.opacity(0.15), lineWidth: 1)
                                )
                        )

                        // Nicht geeignet
                        VStack(alignment: .leading, spacing: 8) {
                            HStack(spacing: 6) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.red)
                                    .font(.system(size: 13))
                                Text("Nicht geeignet")
                                    .font(.system(size: 13, weight: .bold, design: .rounded))
                                    .foregroundColor(.red)
                            }
                            ForEach(garmethode.nicht_geeignet_fuer, id: \.self) { item in
                                Text("· \(item)")
                                    .font(.system(size: 13, weight: .medium, design: .rounded))
                                    .foregroundColor(.white.opacity(0.8))
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.red.opacity(0.08))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.red.opacity(0.15), lineWidth: 1)
                                )
                        )
                    }
                    .padding(.horizontal, 20)
                }
                .padding(.bottom, 40)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }
}
