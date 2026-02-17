//
//  MatjesSchuleApp.swift
//  MatjesSchule
//
//  "Matjes, der kleine Hering" - Schulversion (V3)
//  Das Ausbildungsspiel der Kueche - Profi-Edition
//
//  Erstellt von Andreas Pelczer
//  Team-ID: F75D7PGFTD
//

import SwiftUI

@main
struct MatjesSchuleApp: App {
    @StateObject private var progressManager = ProgressManager.shared
    @StateObject private var appState = AppState()
    @StateObject private var dataStore = DataStore.shared

    var body: some Scene {
        WindowGroup {
            if appState.istAusbilderAngemeldet {
                AusbilderTabView()
                    .environmentObject(progressManager)
                    .environmentObject(appState)
                    .environmentObject(dataStore)
                    .preferredColorScheme(.dark)
            } else {
                SchuelerTabView()
                    .environmentObject(progressManager)
                    .environmentObject(appState)
                    .environmentObject(dataStore)
                    .preferredColorScheme(.dark)
            }
        }
    }
}
