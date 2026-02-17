//
//  FragenkatalogView.swift
//  MatjesSchule
//
//  Verwaltung eigener Fragenkataloge (Ausbilder)
//

import SwiftUI

struct FragenkatalogView: View {
    @EnvironmentObject var dataStore: DataStore
    @State private var showNeuenKatalog = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()

                if dataStore.fragenkataloge.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "questionmark.circle.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.gray)

                        Text("Keine Fragenkataloge")
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundColor(.white)

                        Text("Erstelle eigene Fragen f\u{00FC}r deine Sch\u{00FC}ler, zus\u{00E4}tzlich zu den Matjes-Standardfragen.")
                            .font(.system(size: 15, weight: .medium, design: .rounded))
                            .foregroundColor(.white.opacity(0.6))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)

                        Button(action: { showNeuenKatalog = true }) {
                            Label("Neuer Katalog", systemImage: "plus.circle.fill")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.orange)
                                .cornerRadius(12)
                        }
                    }
                } else {
                    List {
                        ForEach(dataStore.fragenkataloge) { katalog in
                            NavigationLink(destination: KatalogDetailView(katalog: katalog)) {
                                HStack {
                                    Image(systemName: "doc.text.fill")
                                        .foregroundColor(.orange)
                                    VStack(alignment: .leading) {
                                        Text(katalog.name)
                                            .font(.system(size: 16, weight: .bold, design: .rounded))
                                        let anzahl = dataStore.fragenInKatalog(katalog.id).count
                                        Text("\(katalog.beschreibung) - \(anzahl) Fragen")
                                            .font(.system(size: 13, weight: .medium, design: .rounded))
                                            .foregroundColor(.secondary)
                                            .lineLimit(1)
                                    }
                                    Spacer()
                                    if katalog.istVeroeffentlicht {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(.green)
                                    }
                                }
                            }
                        }
                        .onDelete(perform: loescheKatalog)
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("Fragenkataloge")
            .navigationBarTitleDisplayMode(.large)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { showNeuenKatalog = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showNeuenKatalog) {
                NeuerKatalogView()
                    .environmentObject(dataStore)
            }
        }
    }

    private func loescheKatalog(at offsets: IndexSet) {
        for index in offsets {
            dataStore.loescheKatalog(dataStore.fragenkataloge[index])
        }
    }
}

// MARK: - Neuen Katalog erstellen

struct NeuerKatalogView: View {
    @EnvironmentObject var dataStore: DataStore
    @Environment(\.dismiss) var dismiss

    @State private var name = ""
    @State private var beschreibung = ""

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()

                VStack(spacing: 24) {
                    Image(systemName: "doc.badge.plus")
                        .font(.system(size: 50))
                        .foregroundColor(.orange)
                        .padding(.top, 30)

                    Text("Neuer Fragenkatalog")
                        .font(.system(size: 22, weight: .black, design: .rounded))
                        .foregroundColor(.white)

                    VStack(alignment: .leading, spacing: 6) {
                        Text("Name")
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                            .foregroundColor(.white.opacity(0.6))
                        TextField("z.B. Hygiene-Quiz", text: $name)
                            .textFieldStyle(.roundedBorder)
                            .font(.system(size: 16, design: .rounded))
                    }
                    .padding(.horizontal, 30)

                    VStack(alignment: .leading, spacing: 6) {
                        Text("Beschreibung")
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                            .foregroundColor(.white.opacity(0.6))
                        TextField("Kurze Beschreibung", text: $beschreibung)
                            .textFieldStyle(.roundedBorder)
                            .font(.system(size: 16, design: .rounded))
                    }
                    .padding(.horizontal, 30)

                    Button(action: erstellen) {
                        Text("Katalog erstellen")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .frame(maxWidth: 280, minHeight: 50)
                            .background(!name.trimmingCharacters(in: .whitespaces).isEmpty ? Color.orange : Color.gray)
                            .cornerRadius(12)
                    }
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)

                    Spacer()
                }
            }
            .navigationTitle("Neuer Katalog")
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

    private func erstellen() {
        _ = dataStore.erstelleKatalog(
            name: name.trimmingCharacters(in: .whitespaces),
            beschreibung: beschreibung.trimmingCharacters(in: .whitespaces)
        )
        dismiss()
    }
}

// MARK: - Katalog-Detail mit Fragen

struct KatalogDetailView: View {
    let katalog: Fragenkatalog
    @EnvironmentObject var dataStore: DataStore
    @State private var showNeueFrage = false

    private var fragen: [AusbilderFrage] {
        dataStore.fragenInKatalog(katalog.id)
    }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 16) {
                    Text(katalog.name)
                        .font(.system(size: 22, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.top, 20)

                    if !katalog.beschreibung.isEmpty {
                        Text(katalog.beschreibung)
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundColor(.white.opacity(0.6))
                    }

                    Text("\(fragen.count) Fragen")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundColor(.orange)

                    Button(action: { showNeueFrage = true }) {
                        Label("Neue Frage", systemImage: "plus.circle.fill")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(Color.orange)
                            .cornerRadius(10)
                    }

                    ForEach(fragen) { frage in
                        VStack(alignment: .leading, spacing: 8) {
                            Text(frage.text)
                                .font(.system(size: 15, weight: .bold, design: .rounded))
                                .foregroundColor(.white)

                            ForEach(frage.antworten.indices, id: \.self) { i in
                                HStack(spacing: 8) {
                                    Image(systemName: i == frage.korrekterIndex ? "checkmark.circle.fill" : "circle")
                                        .foregroundColor(i == frage.korrekterIndex ? .green : .white.opacity(0.4))
                                        .font(.system(size: 14))
                                    Text(frage.antworten[i])
                                        .font(.system(size: 13, weight: .medium, design: .rounded))
                                        .foregroundColor(i == frage.korrekterIndex ? .green : .white.opacity(0.7))
                                }
                            }
                        }
                        .padding()
                        .background(Color.white.opacity(0.06))
                        .cornerRadius(12)
                    }
                }
                .padding()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .sheet(isPresented: $showNeueFrage) {
            NeueFrageView(katalogId: katalog.id)
                .environmentObject(dataStore)
        }
    }
}

// MARK: - Neue Frage erstellen

struct NeueFrageView: View {
    let katalogId: UUID
    @EnvironmentObject var dataStore: DataStore
    @Environment(\.dismiss) var dismiss

    @State private var frageText = ""
    @State private var antwort1 = ""
    @State private var antwort2 = ""
    @State private var antwort3 = ""
    @State private var antwort4 = ""
    @State private var korrekterIndex = 0
    @State private var erklaerung = ""

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        Text("Neue Frage")
                            .font(.system(size: 22, weight: .black, design: .rounded))
                            .foregroundColor(.white)
                            .padding(.top, 20)

                        VStack(alignment: .leading, spacing: 6) {
                            Text("Frage")
                                .font(.system(size: 13, weight: .bold, design: .rounded))
                                .foregroundColor(.white.opacity(0.6))
                            TextField("Fragetext eingeben", text: $frageText, axis: .vertical)
                                .textFieldStyle(.roundedBorder)
                                .lineLimit(3...5)
                        }

                        VStack(alignment: .leading, spacing: 10) {
                            Text("Antworten (tippe auf die richtige)")
                                .font(.system(size: 13, weight: .bold, design: .rounded))
                                .foregroundColor(.white.opacity(0.6))

                            antwortFeld(index: 0, text: $antwort1)
                            antwortFeld(index: 1, text: $antwort2)
                            antwortFeld(index: 2, text: $antwort3)
                            antwortFeld(index: 3, text: $antwort4)
                        }

                        VStack(alignment: .leading, spacing: 6) {
                            Text("Erkl\u{00E4}rung (optional)")
                                .font(.system(size: 13, weight: .bold, design: .rounded))
                                .foregroundColor(.white.opacity(0.6))
                            TextField("Warum ist das die richtige Antwort?", text: $erklaerung, axis: .vertical)
                                .textFieldStyle(.roundedBorder)
                                .lineLimit(2...4)
                        }

                        Button(action: speichern) {
                            Text("Frage speichern")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                                .frame(maxWidth: 280, minHeight: 50)
                                .background(formIstGueltig ? Color.orange : Color.gray)
                                .cornerRadius(12)
                        }
                        .disabled(!formIstGueltig)
                        .padding(.bottom, 40)
                    }
                    .padding(.horizontal, 20)
                }
            }
            .navigationTitle("Neue Frage")
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

    private func antwortFeld(index: Int, text: Binding<String>) -> some View {
        Button(action: { korrekterIndex = index }) {
            HStack(spacing: 10) {
                Image(systemName: korrekterIndex == index ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(korrekterIndex == index ? .green : .white.opacity(0.4))
                TextField("Antwort \(index + 1)", text: text)
                    .textFieldStyle(.roundedBorder)
            }
        }
        .buttonStyle(.plain)
    }

    private var formIstGueltig: Bool {
        !frageText.trimmingCharacters(in: .whitespaces).isEmpty &&
        !antwort1.trimmingCharacters(in: .whitespaces).isEmpty &&
        !antwort2.trimmingCharacters(in: .whitespaces).isEmpty &&
        !antwort3.trimmingCharacters(in: .whitespaces).isEmpty &&
        !antwort4.trimmingCharacters(in: .whitespaces).isEmpty
    }

    private func speichern() {
        _ = dataStore.erstelleFrage(
            katalogId: katalogId,
            text: frageText.trimmingCharacters(in: .whitespaces),
            antworten: [
                antwort1.trimmingCharacters(in: .whitespaces),
                antwort2.trimmingCharacters(in: .whitespaces),
                antwort3.trimmingCharacters(in: .whitespaces),
                antwort4.trimmingCharacters(in: .whitespaces)
            ],
            korrekterIndex: korrekterIndex,
            erklaerung: erklaerung.trimmingCharacters(in: .whitespaces)
        )
        dismiss()
    }
}
