//
//  UserRole.swift
//  Matjes
//
//  Rollenauswahl: Azubi oder Ausbilder.
//  Wird beim Onboarding gewaehlt und in UserDefaults gespeichert.
//

import Foundation

enum UserRole: String, Codable, CaseIterable {
    case azubi = "azubi"
    case ausbilder = "ausbilder"

    var displayName: String {
        switch self {
        case .azubi: return "Azubi"
        case .ausbilder: return "Ausbilder"
        }
    }
}

@Observable
final class RoleManager {
    static let shared = RoleManager()

    private let key = "Matjes_SelectedRole"
    private let onboardingKey = "Matjes_OnboardingCompleted"

    var selectedRole: UserRole? {
        didSet {
            if let role = selectedRole {
                UserDefaults.standard.set(role.rawValue, forKey: key)
            }
        }
    }

    var hasCompletedOnboarding: Bool = false {
        didSet {
            UserDefaults.standard.set(hasCompletedOnboarding, forKey: onboardingKey)
        }
    }

    private init() {
        // Stored properties erst nach init setzen, damit @Observable tracken kann
        hasCompletedOnboarding = UserDefaults.standard.bool(forKey: onboardingKey)
        if let raw = UserDefaults.standard.string(forKey: key),
           let role = UserRole(rawValue: raw) {
            selectedRole = role
        }
    }

    func selectRole(_ role: UserRole) {
        selectedRole = role
        hasCompletedOnboarding = true
    }

    func resetOnboarding() {
        selectedRole = nil
        hasCompletedOnboarding = false
        UserDefaults.standard.removeObject(forKey: key)
        UserDefaults.standard.removeObject(forKey: onboardingKey)
    }
}
