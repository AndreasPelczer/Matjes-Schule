//
//  KlassenListView.swift
//  MatjesSchule
//
//  Klassenverwaltung fuer Ausbilder
//

import SwiftUI

struct KlassenListView: View {
    @EnvironmentObject var dataStore: DataStore
    @State private var showNeueKlasse = false

    private var klassen: [Klasse] {
        dataStore.klassenFuerAusbilder()
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()

                if klassen.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "person.3.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.gray)

                        Text("Noch keine Klassen")
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundColor(.white)

                        Text("Erstelle deine erste Klasse, um Sch\u{00FC}ler einzuladen.")
                            .font(.system(size: 15, weight: .medium, design: .rounded))
                            .foregroundColor(.white.opacity(0.6))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)

                        Button(action: { showNeueKlasse = true }) {
                            Label("Neue Klasse", systemImage: "plus.circle.fill")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.orange)
                                .cornerRadius(12)
                        }
                    }
                } else {
                    List {
                        ForEach(klassen) { klasse in
                            NavigationLink(destination: KlasseDetailView(klasse: klasse)) {
                                HStack {
                                    Image(systemName: "person.3.fill")
                                        .foregroundColor(.orange)
                                    VStack(alignment: .leading) {
                                        Text(klasse.name)
                                            .font(.system(size: 16, weight: .bold, design: .rounded))
                                        let anzahl = dataStore.schuelerInKlasse(klasse.id).count
                                        Text("\(klasse.lehrjahr). Lehrjahr - \(klasse.schuljahr) - \(anzahl) Sch\u{00FC}ler")
                                            .font(.system(size: 13, weight: .medium, design: .rounded))
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                        }
                        .onDelete(perform: loescheKlasse)
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("Klassen")
            .navigationBarTitleDisplayMode(.large)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { showNeueKlasse = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showNeueKlasse) {
                NeueKlasseView()
                    .environmentObject(dataStore)
            }
        }
    }

    private func loescheKlasse(at offsets: IndexSet) {
        for index in offsets {
            dataStore.loescheKlasse(klassen[index])
        }
    }
}

// MARK: - Neue Klasse erstellen

struct NeueKlasseView: View {
    @EnvironmentObject var dataStore: DataStore
    @Environment(\.dismiss) var dismiss

    @State private var name = ""
    @State private var lehrjahr = 1
    @State private var schuljahr = ""

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        Image(systemName: "person.3.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.orange)
                            .padding(.top, 20)

                        Text("Neue Klasse erstellen")
                            .font(.system(size: 22, weight: .black, design: .rounded))
                            .foregroundColor(.white)

                        VStack(alignment: .leading, spacing: 6) {
                            Text("Klassenname")
                                .font(.system(size: 13, weight: .bold, design: .rounded))
                                .foregroundColor(.white.opacity(0.6))
                            TextField("z.B. Koch 2025/A", text: $name)
                                .textFieldStyle(.roundedBorder)
                                .font(.system(size: 16, design: .rounded))
                        }

                        VStack(alignment: .leading, spacing: 6) {
                            Text("Lehrjahr")
                                .font(.system(size: 13, weight: .bold, design: .rounded))
                                .foregroundColor(.white.opacity(0.6))
                            Picker("Lehrjahr", selection: $lehrjahr) {
                                Text("1. Lehrjahr").tag(1)
                                Text("2. Lehrjahr").tag(2)
                                Text("3. Lehrjahr").tag(3)
                            }
                            .pickerStyle(.segmented)
                        }

                        VStack(alignment: .leading, spacing: 6) {
                            Text("Schuljahr")
                                .font(.system(size: 13, weight: .bold, design: .rounded))
                                .foregroundColor(.white.opacity(0.6))
                            TextField("z.B. 2025/2026", text: $schuljahr)
                                .textFieldStyle(.roundedBorder)
                                .font(.system(size: 16, design: .rounded))
                        }

                        Button(action: erstellen) {
                            Text("Klasse erstellen")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                                .frame(maxWidth: 280, minHeight: 50)
                                .background(formIstGueltig ? Color.orange : Color.gray)
                                .cornerRadius(12)
                        }
                        .disabled(!formIstGueltig)
                        .padding(.top, 10)
                    }
                    .padding(.horizontal, 30)
                }
            }
            .navigationTitle("Neue Klasse")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Abbrechen") { dismiss() }
                        .foregroundColor(.orange)
                }
            }
            .onAppear {
                let year = Calendar.current.component(.year, from: Date())
                schuljahr = "\(year)/\(year + 1)"
            }
        }
    }

    private var formIstGueltig: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty &&
        !schuljahr.trimmingCharacters(in: .whitespaces).isEmpty
    }

    private func erstellen() {
        _ = dataStore.erstelleKlasse(
            name: name.trimmingCharacters(in: .whitespaces),
            lehrjahr: lehrjahr,
            schuljahr: schuljahr.trimmingCharacters(in: .whitespaces)
        )
        dismiss()
    }
}
