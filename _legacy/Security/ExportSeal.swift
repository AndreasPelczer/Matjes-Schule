//
//  ExportSeal.swift
//  iMOPS-Gastro-Grid
//
//  Created by Andreas Pelczer on 07.02.26.
//


//
//  ExportSeal.swift
//  iMOPS-Gastro-Grid
//
//  Export-Versiegelung: SHA-256 Seal über den Export-Payload.
//  Prüfer kann verifizieren, dass der Export nicht nachträglich verändert wurde.
//
//  Verwendung:
//  let seal = ExportSeal.generate(from: exportPayload)
//  let valid = ExportSeal.verify(payload: exportPayload, expectedSeal: seal)
//

import Foundation
import CryptoKit

/// Generates and verifies SHA-256 seals for HACCP exports.
struct ExportSeal {

    /// Generate a SHA-256 seal for the given export payload string.
    static func generate(from payload: String) -> String {
        let data = Data(payload.utf8)
        let digest = SHA256.hash(data: data)
        return digest.map { String(format: "%02x", $0) }.joined()
    }

    /// Verify a seal against the original payload.
    static func verify(payload: String, expectedSeal: String) -> Bool {
        return generate(from: payload) == expectedSeal
    }

    /// Returns a shortened seal for display: "9f3a…c81d"
    static func shortened(_ seal: String) -> String {
        guard seal.count >= 8 else { return seal }
        let prefix = seal.prefix(4)
        let suffix = seal.suffix(4)
        return "\(prefix)…\(suffix)"
    }
}