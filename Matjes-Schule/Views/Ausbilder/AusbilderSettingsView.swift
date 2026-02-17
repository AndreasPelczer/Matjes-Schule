//
//  AusbilderSettingsView.swift
//  MatjesSchule
//
//  Einstellungen fuer den Ausbilder-Bereich
//

import SwiftUI

struct AusbilderSettingsView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var dataStore: DataStore
    @State private var showProfilBearbeiten = false

    private var syncStatusText: String {
        switch appState.syncStatus {
        case .idle: return "Bereit"
        case .syncing: return "Synchronisiert..."
        case .success: return "Aktuell"
        case .error: return "Fehler"
        case .offline: return "Offline"
        case .noAccount: return "Kein iCloud"
        }
    }

    private var syncStatusColor: Color {
        switch appState.syncStatus {
        case .idle: return .secondary
        case .syncing: return .blue
        case .success: return .green
        case .error: return .red
        case .offline: return .orange
        case .noAccount: return .yellow
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()

                List {
                    if let ausbilder = appState.aktuellerAusbilder {
                        Section("Profil") {
                            HStack {
                                Text("Name")
                                Spacer()
                                Text(ausbilder.name)
                                    .foregroundColor(.secondary)
                            }
                            HStack {
                                Text("E-Mail")
                                Spacer()
                                Text(ausbilder.email)
                                    .foregroundColor(.secondary)
                            }
                            HStack {
                                Text("Schule")
                                Spacer()
                                Text(ausbilder.schule)
                                    .foregroundColor(.secondary)
                            }
                        }

                        Section("Statistiken") {
                            HStack {
                                Text("Klassen")
                                Spacer()
                                Text("\(dataStore.klassenFuerAusbilder().count)")
                                    .foregroundColor(.secondary)
                            }
                            HStack {
                                Text("Sch\u{00FC}ler")
                                Spacer()
                                Text("\(dataStore.gesamtSchuelerAnzahl())")
                                    .foregroundColor(.secondary)
                            }
                            HStack {
                                Text("Fragenkataloge")
                                Spacer()
                                Text("\(dataStore.fragenkataloge.count)")
                                    .foregroundColor(.secondary)
                            }
                        }
                    }

                    Section("CloudKit Sync") {
                        HStack {
                            Text("Status")
                            Spacer()
                            HStack(spacing: 6) {
                                if appState.isSyncing {
                                    ProgressView()
                                        .scaleEffect(0.7)
                                }
                                Text(syncStatusText)
                                    .foregroundColor(syncStatusColor)
                            }
                        }
                        if let letzterSync = SyncState.shared.letzterSync {
                            HStack {
                                Text("Letzter Sync")
                                Spacer()
                                Text(letzterSync, style: .relative)
                                    .foregroundColor(.secondary)
                            }
                        }
                        if SyncState.shared.hasPendingOperations {
                            HStack {
                                Text("Ausstehend")
                                Spacer()
                                Text("\(SyncState.shared.pendingOperations.count) \u{00C4}nderungen")
                                    .foregroundColor(.orange)
                            }
                        }
                        Button(action: {
                            appState.triggerSync()
                        }) {
                            HStack {
                                Image(systemName: "arrow.triangle.2.circlepath")
                                Text("Jetzt synchronisieren")
                            }
                        }
                        .disabled(appState.isSyncing)
                    }

                    Section("App") {
                        HStack {
                            Text("Version")
                            Spacer()
                            Text("3.0 (Schulversion)")
                                .foregroundColor(.secondary)
                        }
                    }

                    Section {
                        Button(action: {
                            appState.abmelden()
                        }) {
                            HStack {
                                Spacer()
                                Text("Abmelden")
                                    .foregroundColor(.red)
                                    .fontWeight(.bold)
                                Spacer()
                            }
                        }
                    }
                }
                .listStyle(.insetGrouped)
            }
            .navigationTitle("Einstellungen")
            .navigationBarTitleDisplayMode(.large)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
    }
}
