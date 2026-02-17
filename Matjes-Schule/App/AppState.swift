//
//  AppState.swift
//  MatjesSchule
//
//  Globaler App-Zustand: Unterscheidet Schueler- und Ausbilder-Modus.
//  Persistent: Login ueberlebt App-Neustart.
//  CloudKit: Sync wird bei Login und App-Start ausgeloest.
//

import Foundation
import SwiftUI
import Combine

class AppState: ObservableObject {
    @Published var istAusbilderAngemeldet: Bool = false
    @Published var aktuellerAusbilder: Ausbilder? = nil

    // CloudKit Status
    @Published var syncStatus: SyncStatus = .idle
    @Published var isSyncing: Bool = false

    private let loginKey = "MatjesSchule_AusbilderEingeloggt"
    private let syncState = SyncState.shared
    private var cancellables = Set<AnyCancellable>()

    init() {
        // Sync-Status beobachten
        syncState.$status
            .receive(on: DispatchQueue.main)
            .assign(to: &$syncStatus)

        if UserDefaults.standard.bool(forKey: loginKey) {
            let store = DataStore.shared
            if let ausbilder = store.ausbilder {
                aktuellerAusbilder = ausbilder
                istAusbilderAngemeldet = true
            } else {
                UserDefaults.standard.set(false, forKey: loginKey)
            }
        }
    }

    func ausbilderAnmelden(_ ausbilder: Ausbilder) {
        aktuellerAusbilder = ausbilder
        istAusbilderAngemeldet = true
        UserDefaults.standard.set(true, forKey: loginKey)

        // CloudKit-Sync nach Login starten
        triggerSync()
    }

    func abmelden() {
        aktuellerAusbilder = nil
        istAusbilderAngemeldet = false
        UserDefaults.standard.set(false, forKey: loginKey)
    }

    // MARK: - CloudKit Sync

    /// Startet einen CloudKit-Sync im Hintergrund.
    func triggerSync() {
        guard !isSyncing else { return }
        isSyncing = true
        Task {
            await DataStore.shared.syncMitCloudKit()
            await MainActor.run {
                self.isSyncing = false
            }
        }
    }

    /// Wird beim App-Start aufgerufen, um den initialen Sync zu starten.
    func onAppStart() {
        triggerSync()
    }
}
