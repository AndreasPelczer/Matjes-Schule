//
//  PaywallView.swift
//  Matjes
//
//  Paywall nach Ablauf des Free Trials.
//  Zeigt alle Abo-Optionen und erlaubt Kauf/Wiederherstellung.
//

import SwiftUI
import StoreKit

struct PaywallView: View {
    @Environment(\.dismiss) var dismiss
    var subscriptionManager: SubscriptionManager

    @State private var selectedProduct: Product?
    @State private var isPurchasing = false
    @State private var showError = false
    @State private var errorMessage = ""

    private var azubiProducts: [Product] {
        subscriptionManager.products.filter {
            $0.id.contains("azubi")
        }.sorted { $0.price < $1.price }
    }

    private var ausbilderProducts: [Product] {
        subscriptionManager.products.filter {
            $0.id.contains("ausbilder")
        }.sorted { $0.price < $1.price }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                LinearGradient(
                    colors: [Color.orange.opacity(0.2), Color.black],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        headerSection

                        // Azubi-Abo
                        aboSection(
                            titel: "Azubi",
                            untertitel: "Quiz, Lexikon & Fortschritt",
                            produkte: azubiProducts,
                            farbe: .blue
                        )

                        // Ausbilder-Abo
                        aboSection(
                            titel: "Ausbilder",
                            untertitel: "Alles von Azubi + Klassen, Dashboard, Export",
                            produkte: ausbilderProducts,
                            farbe: .orange
                        )

                        // Kauf-Button
                        kaufButton

                        // VPP Hinweis
                        Text("Schulen & Betriebe: \u{00DC}ber Apple Volume Purchase (VPP) verf\u{00FC}gbar")
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .foregroundColor(.white.opacity(0.4))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 30)

                        // Wiederherstellen + Links
                        footerLinks

                        if showError {
                            Text(errorMessage)
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                .foregroundColor(.red)
                                .padding(.horizontal, 30)
                        }
                    }
                    .padding(.vertical, 20)
                }
            }
            .navigationTitle("Abo w\u{00E4}hlen")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                if subscriptionManager.hasFullAccess {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Fertig") { dismiss() }
                            .foregroundColor(.orange)
                    }
                }
            }
        }
    }

    // MARK: - Sections

    private var headerSection: some View {
        VStack(spacing: 12) {
            Text("\u{1F41F}")
                .font(.system(size: 50))

            if subscriptionManager.isInTrial {
                Text("Noch \(subscriptionManager.trialDaysRemaining) Tage kostenlos")
                    .font(.system(size: 22, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                Text("W\u{00E4}hle jetzt ein Abo, damit es nach dem Trial weitergeht.")
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.6))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 30)
            } else {
                Text("Deine Testphase ist abgelaufen")
                    .font(.system(size: 22, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                Text("W\u{00E4}hle ein Abo, um weiterzulernen:")
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.6))
            }
        }
    }

    private func aboSection(titel: String, untertitel: String, produkte: [Product], farbe: Color) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Matjes \(titel)")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(farbe)
                Text(untertitel)
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.5))
            }
            .padding(.horizontal, 30)

            if produkte.isEmpty {
                // Fallback wenn Produkte noch nicht geladen
                HStack(spacing: 12) {
                    produktPlaceholder(
                        name: "\(titel) Monatlich",
                        preis: titel == "Azubi" ? "1,99 \u{20AC}/Monat" : "9,99 \u{20AC}/Monat",
                        farbe: farbe,
                        istJaehrlich: false
                    )
                    produktPlaceholder(
                        name: "\(titel) J\u{00E4}hrlich",
                        preis: titel == "Azubi" ? "9,99 \u{20AC}/Jahr" : "49,99 \u{20AC}/Jahr",
                        farbe: farbe,
                        istJaehrlich: true
                    )
                }
                .padding(.horizontal, 30)
            } else {
                HStack(spacing: 12) {
                    ForEach(produkte, id: \.id) { product in
                        produktButton(product: product, farbe: farbe)
                    }
                }
                .padding(.horizontal, 30)
            }
        }
    }

    private func produktButton(product: Product, farbe: Color) -> some View {
        let isSelected = selectedProduct?.id == product.id
        let istJaehrlich = product.id.contains("jaehrlich")

        return Button(action: { selectedProduct = product }) {
            VStack(spacing: 8) {
                if istJaehrlich {
                    Text("Spart ~60%")
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                        .foregroundColor(.yellow)
                }
                Text(product.displayPrice)
                    .font(.system(size: 20, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                Text(istJaehrlich ? "pro Jahr" : "pro Monat")
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.6))
            }
            .frame(maxWidth: .infinity, minHeight: 90)
            .background(isSelected ? farbe.opacity(0.3) : Color.white.opacity(0.08))
            .cornerRadius(14)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(isSelected ? farbe : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }

    private func produktPlaceholder(name: String, preis: String, farbe: Color, istJaehrlich: Bool) -> some View {
        VStack(spacing: 8) {
            if istJaehrlich {
                Text("Spart ~60%")
                    .font(.system(size: 10, weight: .bold, design: .rounded))
                    .foregroundColor(.yellow)
            }
            Text(preis)
                .font(.system(size: 16, weight: .black, design: .rounded))
                .foregroundColor(.white.opacity(0.5))
        }
        .frame(maxWidth: .infinity, minHeight: 90)
        .background(Color.white.opacity(0.05))
        .cornerRadius(14)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
    }

    private var kaufButton: some View {
        Button(action: kaufen) {
            HStack {
                if isPurchasing {
                    ProgressView()
                        .tint(.white)
                }
                Text(selectedProduct != nil ? "Jetzt abonnieren" : "Abo ausw\u{00E4}hlen")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity, minHeight: 54)
            .background(selectedProduct != nil ? Color.orange : Color.gray.opacity(0.5))
            .cornerRadius(14)
        }
        .disabled(selectedProduct == nil || isPurchasing)
        .padding(.horizontal, 30)
    }

    private var footerLinks: some View {
        HStack(spacing: 20) {
            Button("Wiederherstellen") {
                Task { await subscriptionManager.restorePurchases() }
            }
            .font(.system(size: 13, weight: .semibold, design: .rounded))
            .foregroundColor(.orange.opacity(0.8))

            Link("Nutzungsbedingungen", destination: URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!)
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundColor(.white.opacity(0.4))

            Link("Datenschutz", destination: URL(string: "https://pelczer.de/legal/matjes-privacy.html")!)
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundColor(.white.opacity(0.4))
        }
        .padding(.top, 8)
    }

    // MARK: - Actions

    private func kaufen() {
        guard let product = selectedProduct else { return }
        isPurchasing = true
        showError = false

        Task {
            do {
                let success = try await subscriptionManager.purchase(product)
                await MainActor.run {
                    isPurchasing = false
                    if success { dismiss() }
                }
            } catch {
                await MainActor.run {
                    isPurchasing = false
                    errorMessage = "Kauf fehlgeschlagen: \(error.localizedDescription)"
                    showError = true
                }
            }
        }
    }
}
