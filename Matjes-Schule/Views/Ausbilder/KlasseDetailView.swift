//
//  KlasseDetailView.swift
//  MatjesSchule
//
//  Detailansicht einer Klasse mit Schueler-Liste und Fortschritten
//

import SwiftUI

struct KlasseDetailView: View {
    let klasse: Klasse
    @EnvironmentObject var dataStore: DataStore
    @State private var showNeuerSchueler = false
    @State private var showCodeListe = false

    private var schueler: [Schueler] {
        dataStore.schuelerInKlasse(klasse.id)
    }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {
                    // Klassen-Info
                    VStack(spacing: 8) {
                        Text(klasse.name)
                            .font(.system(size: 24, weight: .black, design: .rounded))
                            .foregroundColor(.white)
                        Text("\(klasse.lehrjahr). Lehrjahr - \(klasse.schuljahr)")
                            .font(.system(size: 15, weight: .medium, design: .rounded))
                            .foregroundColor(.white.opacity(0.7))
                        Text("\(schueler.count) Sch\u{00FC}ler")
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundColor(.orange)
                    }
                    .padding(.top, 20)

                    // Aktions-Buttons
                    HStack(spacing: 12) {
                        Button(action: { showNeuerSchueler = true }) {
                            Label("Sch\u{00FC}ler hinzuf\u{00FC}gen", systemImage: "person.badge.plus")
                                .font(.system(size: 14, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 10)
                                .background(Color.orange)
                                .cornerRadius(10)
                        }

                        if !schueler.isEmpty {
                            Button(action: { showCodeListe = true }) {
                                Label("Codes", systemImage: "qrcode")
                                    .font(.system(size: 14, weight: .bold, design: .rounded))
                                    .foregroundColor(.orange)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 10)
                                    .background(Color.orange.opacity(0.15))
                                    .cornerRadius(10)
                            }
                        }
                    }

                    // Schueler-Liste
                    if schueler.isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: "person.badge.plus")
                                .font(.system(size: 40))
                                .foregroundColor(.gray)
                            Text("Noch keine Sch\u{00FC}ler in dieser Klasse")
                                .font(.system(size: 15, weight: .medium, design: .rounded))
                                .foregroundColor(.white.opacity(0.6))
                            Text("F\u{00FC}ge Sch\u{00FC}ler hinzu und verteile die Einladungscodes.")
                                .font(.system(size: 13, weight: .medium, design: .rounded))
                                .foregroundColor(.white.opacity(0.4))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 40)
                        }
                        .padding(.top, 40)
                    } else {
                        ForEach(schueler) { s in
                            SchuelerRow(schueler: s, fortschritt: dataStore.fortschrittFuer(schuelerId: s.id))
                        }
                    }
                }
                .padding()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: { showNeuerSchueler = true }) {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showNeuerSchueler) {
            NeuerSchuelerView(klasseId: klasse.id)
                .environmentObject(dataStore)
        }
        .sheet(isPresented: $showCodeListe) {
            CodeListeView(klasse: klasse, schueler: schueler)
        }
    }
}

// MARK: - Schueler-Zeile mit Fortschritt

struct SchuelerRow: View {
    let schueler: Schueler
    let fortschritt: SchuelerFortschritt?

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "person.circle.fill")
                .font(.system(size: 36))
                .foregroundColor(.orange)

            VStack(alignment: .leading, spacing: 4) {
                Text(schueler.vollstaendigerName)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(.white)

                if let fortschritt = fortschritt, fortschritt.gesamtSterne > 0 {
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 11))
                            .foregroundColor(.yellow)
                        Text("\(fortschritt.gesamtSterne)/\(fortschritt.maxSterne) Sterne")
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .foregroundColor(.white.opacity(0.6))
                        Text("- Level \(fortschritt.hoechstesLevel)")
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .foregroundColor(.white.opacity(0.6))
                    }
                } else {
                    Text("Noch nicht gestartet")
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.4))
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text("Code:")
                    .font(.system(size: 10, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.4))
                Text(schueler.einladungsCode)
                    .font(.system(size: 14, weight: .bold, design: .monospaced))
                    .foregroundColor(.orange)
            }
        }
        .padding()
        .background(Color.white.opacity(0.08))
        .cornerRadius(12)
    }
}

// MARK: - Neuen Schueler hinzufuegen

struct NeuerSchuelerView: View {
    let klasseId: UUID
    @EnvironmentObject var dataStore: DataStore
    @Environment(\.dismiss) var dismiss

    @State private var vorname = ""
    @State private var nachname = ""

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()

                VStack(spacing: 24) {
                    Image(systemName: "person.badge.plus")
                        .font(.system(size: 50))
                        .foregroundColor(.orange)
                        .padding(.top, 30)

                    Text("Sch\u{00FC}ler hinzuf\u{00FC}gen")
                        .font(.system(size: 22, weight: .black, design: .rounded))
                        .foregroundColor(.white)

                    VStack(alignment: .leading, spacing: 6) {
                        Text("Vorname")
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                            .foregroundColor(.white.opacity(0.6))
                        TextField("Vorname", text: $vorname)
                            .textFieldStyle(.roundedBorder)
                            .font(.system(size: 16, design: .rounded))
                    }
                    .padding(.horizontal, 30)

                    VStack(alignment: .leading, spacing: 6) {
                        Text("Nachname")
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                            .foregroundColor(.white.opacity(0.6))
                        TextField("Nachname", text: $nachname)
                            .textFieldStyle(.roundedBorder)
                            .font(.system(size: 16, design: .rounded))
                    }
                    .padding(.horizontal, 30)

                    Button(action: hinzufuegen) {
                        Text("Hinzuf\u{00FC}gen")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .frame(maxWidth: 280, minHeight: 50)
                            .background(formIstGueltig ? Color.orange : Color.gray)
                            .cornerRadius(12)
                    }
                    .disabled(!formIstGueltig)

                    Spacer()
                }
            }
            .navigationTitle("Neuer Sch\u{00FC}ler")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Abbrechen") { dismiss() }
                        .foregroundColor(.orange)
                }
            }
        }
    }

    private var formIstGueltig: Bool {
        !vorname.trimmingCharacters(in: .whitespaces).isEmpty &&
        !nachname.trimmingCharacters(in: .whitespaces).isEmpty
    }

    private func hinzufuegen() {
        _ = dataStore.erstelleSchueler(
            vorname: vorname.trimmingCharacters(in: .whitespaces),
            nachname: nachname.trimmingCharacters(in: .whitespaces),
            klasseId: klasseId
        )
        dismiss()
    }
}

// MARK: - Code-Liste zum Ausdrucken/Verteilen

struct CodeListeView: View {
    let klasse: Klasse
    let schueler: [Schueler]
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 16) {
                        Text("Einladungscodes")
                            .font(.system(size: 22, weight: .black, design: .rounded))
                            .foregroundColor(.white)
                            .padding(.top, 20)

                        Text("Verteile jedem Sch\u{00FC}ler seinen pers\u{00F6}nlichen Code.")
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundColor(.white.opacity(0.6))

                        Text(klasse.name)
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundColor(.orange)

                        ForEach(schueler) { s in
                            HStack {
                                Text(s.vollstaendigerName)
                                    .font(.system(size: 16, weight: .medium, design: .rounded))
                                    .foregroundColor(.white)
                                Spacer()
                                Text(s.einladungsCode)
                                    .font(.system(size: 20, weight: .black, design: .monospaced))
                                    .foregroundColor(.orange)
                            }
                            .padding()
                            .background(Color.white.opacity(0.08))
                            .cornerRadius(10)
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Codes")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Fertig") { dismiss() }
                        .foregroundColor(.orange)
                }
            }
        }
    }
}
