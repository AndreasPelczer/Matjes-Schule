//
//  AppSession.swift
//  iMOPS-Gastro-Grid
//
//  Source: test25B (einziges Vorkommen)
//  Created by Andreas Pelczer on 12.01.26.
//


import Foundation
import SwiftUI
import Observation

/// Globale Session: Rolle, Sprache, später Login/Benutzer.
@Observable
final class AppSession {

    enum Role: String, CaseIterable, Identifiable {
        case crew
        case dispatcher
        case director

        var id: String { rawValue }

        var title: String {
            switch self {
            case .crew: return "Crew"
            case .dispatcher: return "Dispatcher"
            case .director: return "Director"
            }
        }

        var sfSymbol: String {
            switch self {
            case .crew: return "person.2.fill"
            case .dispatcher: return "app.badge.checkmark"
            case .director: return "crown.fill"
            }
        }
    }

    var role: Role = .crew

    // Optional: Sprache wie in GastroGrid gedacht – kann später ausgebaut werden
    var languageCode: String = "de" {
        didSet { locale = Locale(identifier: languageCode) }
    }
    var locale: Locale = Locale(identifier: "de")
}
