//
//  AusbilderAuthentication.swift
//  MatjesSchule
//
//  Ausbilder-Authentifizierung (basierend auf EmployeeAuthentication aus Gastro-Grid)
//  Touch ID / Face ID + 4-stellige PIN als Fallback.
//

import Foundation
import LocalAuthentication
import CryptoKit
import UIKit

struct AusbilderAuthResult {
    let ausbilderId: String
    let method: AuthMethod
    let timestamp: Date
    let deviceId: String

    enum AuthMethod: String {
        case biometric = "BIOMETRIC"
        case pin = "PIN"
    }
}

enum AusbilderAuthError: Error, LocalizedError {
    case biometricNotAvailable
    case authenticationFailed
    case cancelled
    case pinMismatch
    case ausbilderNotFound

    var errorDescription: String? {
        switch self {
        case .biometricNotAvailable: return "Biometrische Authentifizierung nicht verf\u{00FC}gbar"
        case .authenticationFailed: return "Authentifizierung fehlgeschlagen"
        case .cancelled: return "Authentifizierung abgebrochen"
        case .pinMismatch: return "PIN stimmt nicht \u{00FC}berein"
        case .ausbilderNotFound: return "Ausbilder-Profil nicht gefunden"
        }
    }
}

@available(iOS 17.0, *)
struct AusbilderAuthentication {

    /// Biometrische Authentifizierung (Face ID / Touch ID)
    static func authenticate(ausbilderId: String) async throws -> AusbilderAuthResult {
        let context = LAContext()
        var error: NSError?

        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            throw AusbilderAuthError.biometricNotAvailable
        }

        let success = try await context.evaluatePolicy(
            .deviceOwnerAuthenticationWithBiometrics,
            localizedReason: "Als Ausbilder anmelden"
        )

        if success {
            return AusbilderAuthResult(
                ausbilderId: ausbilderId,
                method: .biometric,
                timestamp: Date(),
                deviceId: deviceIdentifier()
            )
        }

        throw AusbilderAuthError.authenticationFailed
    }

    /// PIN-basierte Authentifizierung (Fallback)
    static func authenticateWithPIN(ausbilderId: String, pin: String, storedHash: String) throws -> AusbilderAuthResult {
        let pinHash = hashPIN(pin)

        guard pinHash == storedHash else {
            throw AusbilderAuthError.pinMismatch
        }

        return AusbilderAuthResult(
            ausbilderId: ausbilderId,
            method: .pin,
            timestamp: Date(),
            deviceId: deviceIdentifier()
        )
    }

    /// PIN hashen fuer sichere Speicherung (SHA-256)
    static func hashPIN(_ pin: String) -> String {
        let data = Data(pin.utf8)
        let digest = SHA256.hash(data: data)
        return digest.map { String(format: "%02x", $0) }.joined()
    }

    /// Biometrie verfuegbar?
    static var isBiometricAvailable: Bool {
        let context = LAContext()
        var error: NSError?
        return context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
    }

    // MARK: - Private

    private static func deviceIdentifier() -> String {
        #if os(iOS)
        return UIDevice.current.identifierForVendor?.uuidString ?? "UNKNOWN"
        #else
        return "SIMULATOR"
        #endif
    }
}
