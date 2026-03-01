//
//  MatjesSchuleApp.swift
//  Matjes
//
//  "Matjes" - Das Ausbildungsspiel der Kueche (V4)
//  Konsolidierte App: Azubi + Ausbilder in einer App.
//
//  Erstellt von Andreas Pelczer
//  Team-ID: F75D7PGFTD
//  Bundle-ID: de.binda.matjes
//

import SwiftUI

@main
struct MatjesSchuleApp: App {
    @StateObject private var progressManager = ProgressManager.shared
    @StateObject private var appState = AppState()
    @StateObject private var dataStore = DataStore.shared

    private var roleManager: RoleManager { .shared }
    private var subscriptionManager: SubscriptionManager { .shared }

    var body: some Scene {
        WindowGroup {
            Group {
                if !roleManager.hasCompletedOnboarding {
                    // Erster Start: Onboarding / Rollenauswahl
                    OnboardingView { role in
                        roleManager.selectRole(role)
                    }
                } else if let role = roleManager.selectedRole {
                    switch role {
                    case .azubi:
                        SchuelerTabView(
                            roleManager: roleManager,
                            subscriptionManager: subscriptionManager
                        )
                    case .ausbilder:
                        if appState.istAusbilderAngemeldet {
                            AusbilderTabView(
                                roleManager: roleManager,
                                subscriptionManager: subscriptionManager
                            )
                        } else {
                            AusbilderLoginView()
                        }
                    }
                } else {
                    // Fallback: Onboarding erneut anzeigen
                    OnboardingView { role in
                        roleManager.selectRole(role)
                    }
                }
            }
            .environmentObject(progressManager)
            .environmentObject(appState)
            .environmentObject(dataStore)
            .preferredColorScheme(.dark)
            .task {
                appState.onAppStart()
            }
        }
    }
}
