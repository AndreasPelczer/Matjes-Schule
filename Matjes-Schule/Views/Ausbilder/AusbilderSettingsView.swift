//
//  AusbilderSettingsView.swift
//  MatjesSchule
//
//  Einstellungen fuer den Ausbilder-Bereich
//

import SwiftUI

struct AusbilderSettingsView: View {
    @EnvironmentObject var appState: AppState

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
