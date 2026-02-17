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

    var body: some Scene {
        WindowGroup {
            if appState.istAusbilderAngemeldet {
                AusbilderTabView()
                    .environmentObject(progressManager)
                    .environmentObject(appState)
                    .preferredColorScheme(.dark)
            } else {
                SchuelerTabView()
                    .environmentObject(progressManager)
                    .environmentObject(appState)
                    .preferredColorScheme(.dark)
            }
        }
    }
}
