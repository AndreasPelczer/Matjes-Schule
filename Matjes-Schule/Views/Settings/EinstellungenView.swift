//
//  EinstellungenView.swift
//  Matjes
//
//  Einstellungen fuer beide Rollen: Rolle wechseln, Abo verwalten,
//  Klasse beitreten (Azubi), CloudKit-Sync (Ausbilder).
//

import SwiftUI

struct EinstellungenView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var dataStore: DataStore
    var roleManager: RoleManager
    var subscriptionManager: SubscriptionManager

    @State private var showPaywall = false
    @State private var showRollenWechsel = false

    private var currentRole: UserRole {
        roleManager.selectedRole ?? .azubi
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()

                List {
                    // Rolle
                    Section("Rolle") {
                        HStack {
                            Text("Aktuelle Rolle")
                            Spacer()
                            Text(currentRole.displayName)
                                .foregroundColor(.secondary)
                        }
                        Button(action: { showRollenWechsel = true }) {
                            HStack {
                                Image(systemName: "arrow.triangle.2.circlepath")
                                Text("Rolle wechseln")
                            }
                        }
                    }

                    // Abo
                    Section("Abonnement") {
                        if subscriptionManager.isInTrial {
                            HStack {
                                Text("Status")
                                Spacer()
                                Text("Testphase (\(subscriptionManager.trialDaysRemaining) Tage)")
                                    .foregroundColor(.green)
                            }
                        } else if subscriptionManager.isSubscribed {
                            HStack {
                                Text("Status")
                                Spacer()
                                Text(subscriptionManager.isAusbilderSubscribed ? "Ausbilder-Abo" : "Azubi-Abo")
                                    .foregroundColor(.green)
                            }
                        } else {
                            HStack {
                                Text("Status")
                                Spacer()
                                Text("Kein Abo")
                                    .foregroundColor(.red)
                            }
                        }

                        Button(action: { showPaywall = true }) {
                            HStack {
                                Image(systemName: "creditcard.fill")
                                Text("Abo verwalten")
                            }
                        }
                    }

                    // Klasse beitreten (nur Azubi)
                    if currentRole == .azubi {
                        Section("Klasse") {
                            if let schueler = dataStore.aktuellerSchueler {
                                HStack {
                                    Text("Angemeldet als")
                                    Spacer()
                                    Text(schueler.vorname)
                                        .foregroundColor(.secondary)
                                }
                                Button(role: .destructive, action: {
                                    dataStore.schuelerAbmelden()
                                }) {
                                    HStack {
                                        Image(systemName: "xmark.circle")
                                        Text("Von Klasse abmelden")
                                    }
                                }
                            } else {
                                NavigationLink {
                                    SchuelerCodeView()
                                        .environmentObject(dataStore)
                                } label: {
                                    HStack {
                                        Image(systemName: "ticket.fill")
                                        Text("Klasse beitreten")
                                    }
                                }
                            }
                        }
                    }

                    // CloudKit (nur Ausbilder)
                    if currentRole == .ausbilder {
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
                            Button(action: { appState.triggerSync() }) {
                                HStack {
                                    Image(systemName: "arrow.triangle.2.circlepath")
                                    Text("Jetzt synchronisieren")
                                }
                            }
                            .disabled(appState.isSyncing)
                        }
                    }

                    // App Info
                    Section("App") {
                        HStack {
                            Text("Version")
                            Spacer()
                            Text("4.0")
                                .foregroundColor(.secondary)
                        }
                        Link(destination: URL(string: "https://pelczer.de")!) {
                            HStack {
                                Image(systemName: "globe")
                                Text("Support")
                            }
                        }
                        Link(destination: URL(string: "https://pelczer.de/legal/matjes-privacy.html")!) {
                            HStack {
                                Image(systemName: "hand.raised.fill")
                                Text("Datenschutz")
                            }
                        }
                    }

                    // Abmelden (nur Ausbilder, wenn angemeldet)
                    if currentRole == .ausbilder && appState.istAusbilderAngemeldet {
                        Section {
                            Button(action: { appState.abmelden() }) {
                                HStack {
                                    Spacer()
                                    Text("Ausbilder abmelden")
                                        .foregroundColor(.red)
                                        .fontWeight(.bold)
                                    Spacer()
                                }
                            }
                        }
                    }
                }
                .listStyle(.insetGrouped)
            }
            .navigationTitle("Einstellungen")
            .navigationBarTitleDisplayMode(.large)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .sheet(isPresented: $showPaywall) {
                PaywallView(subscriptionManager: subscriptionManager)
            }
            .confirmationDialog("Rolle wechseln", isPresented: $showRollenWechsel) {
                Button("Azubi") { roleManager.selectRole(.azubi) }
                Button("Ausbilder") { roleManager.selectRole(.ausbilder) }
                Button("Abbrechen", role: .cancel) {}
            } message: {
                Text("W\u{00E4}hle deine neue Rolle. Alle Daten bleiben erhalten.")
            }
        }
    }

    // MARK: - Sync Status Helpers

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
}
