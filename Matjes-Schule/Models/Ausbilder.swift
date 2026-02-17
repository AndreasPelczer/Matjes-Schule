//
//  Ausbilder.swift
//  MatjesSchule
//
//  Ausbilder-Profil fuer die Schulversion (V3)
//

import Foundation
import CloudKit

struct Ausbilder: Identifiable, Codable {
    let id: UUID
    var name: String
    var email: String
    var schule: String
    var pinHash: String
    var erstelltAm: Date
    var letzterLogin: Date?

    init(name: String, email: String, schule: String, pinHash: String) {
        self.id = UUID()
        self.name = name
        self.email = email
        self.schule = schule
        self.pinHash = pinHash
        self.erstelltAm = Date()
        self.letzterLogin = nil
    }

    /// Vollstaendiger Initialisierer (fuer CloudKit-Sync)
    init(id: UUID, name: String, email: String, schule: String, pinHash: String, erstelltAm: Date, letzterLogin: Date?) {
        self.id = id
        self.name = name
        self.email = email
        self.schule = schule
        self.pinHash = pinHash
        self.erstelltAm = erstelltAm
        self.letzterLogin = letzterLogin
    }
}
