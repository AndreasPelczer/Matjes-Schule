//
//  SubscriptionManager.swift
//  Matjes
//
//  StoreKit 2 Subscription-Verwaltung mit Free Trial (30 Tage).
//  Abo-Stufen: Azubi (monatlich/jaehrlich) und Ausbilder (monatlich/jaehrlich).
//

import Foundation
import StoreKit

enum SubscriptionTier: String, CaseIterable {
    case azubiMonatlich = "de.binda.matjes.azubi.monatlich"
    case azubiJaehrlich = "de.binda.matjes.azubi.jaehrlich"
    case ausbilderMonatlich = "de.binda.matjes.ausbilder.monatlich"
    case ausbilderJaehrlich = "de.binda.matjes.ausbilder.jaehrlich"

    var isAusbilder: Bool {
        switch self {
        case .ausbilderMonatlich, .ausbilderJaehrlich: return true
        default: return false
        }
    }
}

@Observable
final class SubscriptionManager {
    static let shared = SubscriptionManager()

    // Verfuegbare Produkte
    var products: [Product] = []

    // Aktuelles Abo
    var currentSubscription: Product.SubscriptionInfo.Status?
    var isSubscribed: Bool = false
    var isAusbilderSubscribed: Bool = false

    // Trial
    var isInTrial: Bool = false
    var trialDaysRemaining: Int = 0

    // Loading
    var isLoading: Bool = false

    private let trialStartKey = "Matjes_TrialStartDate"
    private let trialDuration: TimeInterval = 30 * 24 * 60 * 60 // 30 Tage

    private var updateListenerTask: Task<Void, Never>?

    private static let productIds: Set<String> = Set(SubscriptionTier.allCases.map(\.rawValue))

    private init() {
        checkTrialStatus()
        updateListenerTask = listenForTransactions()
        Task { await loadProducts() }
        Task { await updateSubscriptionStatus() }
    }

    deinit {
        updateListenerTask?.cancel()
    }

    // MARK: - Trial

    private func checkTrialStatus() {
        if let startDate = UserDefaults.standard.object(forKey: trialStartKey) as? Date {
            let elapsed = Date().timeIntervalSince(startDate)
            if elapsed < trialDuration {
                isInTrial = true
                trialDaysRemaining = max(0, Int(ceil((trialDuration - elapsed) / (24 * 60 * 60))))
            } else {
                isInTrial = false
                trialDaysRemaining = 0
            }
        } else {
            // Erster App-Start: Trial starten
            UserDefaults.standard.set(Date(), forKey: trialStartKey)
            isInTrial = true
            trialDaysRemaining = 30
        }
    }

    /// Ob der Nutzer vollen Zugriff hat (Trial aktiv ODER Abo aktiv)
    var hasFullAccess: Bool {
        isInTrial || isSubscribed
    }

    /// Ob der Nutzer Ausbilder-Features nutzen darf
    var hasAusbilderAccess: Bool {
        isInTrial || isAusbilderSubscribed
    }

    // MARK: - Products

    func loadProducts() async {
        isLoading = true
        do {
            let storeProducts = try await Product.products(for: Self.productIds)
            await MainActor.run {
                self.products = storeProducts.sorted { $0.price < $1.price }
                self.isLoading = false
            }
        } catch {
            await MainActor.run { self.isLoading = false }
        }
    }

    // MARK: - Purchase

    func purchase(_ product: Product) async throws -> Bool {
        let result = try await product.purchase()

        switch result {
        case .success(let verification):
            let transaction = try checkVerified(verification)
            await transaction.finish()
            await updateSubscriptionStatus()
            return true

        case .userCancelled:
            return false

        case .pending:
            return false

        @unknown default:
            return false
        }
    }

    func restorePurchases() async {
        try? await AppStore.sync()
        await updateSubscriptionStatus()
    }

    // MARK: - Subscription Status

    func updateSubscriptionStatus() async {
        var foundSubscription = false
        var foundAusbilder = false

        for await result in Transaction.currentEntitlements {
            guard let transaction = try? checkVerified(result) else { continue }

            if Self.productIds.contains(transaction.productID) {
                foundSubscription = true
                if let tier = SubscriptionTier(rawValue: transaction.productID), tier.isAusbilder {
                    foundAusbilder = true
                }
            }
        }

        await MainActor.run {
            isSubscribed = foundSubscription
            isAusbilderSubscribed = foundAusbilder
            checkTrialStatus()
        }
    }

    // MARK: - Transaction Listener

    private func listenForTransactions() -> Task<Void, Never> {
        Task.detached {
            for await result in Transaction.updates {
                guard let transaction = try? self.checkVerified(result) else { continue }
                await transaction.finish()
                await self.updateSubscriptionStatus()
            }
        }
    }

    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreError.verificationFailed
        case .verified(let item):
            return item
        }
    }
}

enum StoreError: Error {
    case verificationFailed
}
